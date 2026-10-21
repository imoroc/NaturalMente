import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data' show Endian;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales de idioma y sonido independientes del progreso.
class Idioma extends ChangeNotifier {
  Idioma(this._preferencias, this.traducciones)
    : _codigo = _preferencias.getString('idioma') == 'en' ? 'en' : 'es',
      _sonido = _preferencias.getBool('sonido') ?? true;

  final SharedPreferences _preferencias;
  final Map<String, String> traducciones;
  String _codigo;
  bool _sonido;

  String get codigo => _codigo;
  Locale get locale => Locale(_codigo);
  bool get sonido => _sonido;

  static Future<Idioma> abrir() async {
    final preferencias = await SharedPreferences.getInstance();
    final datos = await rootBundle.load('content/en.json');
    final textos = jsonDecode(
      utf8.decode(
        datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
      ),
    ) as Map<String, dynamic>;
    return Idioma(preferencias, textos.cast<String, String>());
  }

  Future<bool> elegir(String codigo) async {
    if (!const ['es', 'en'].contains(codigo)) return false;
    if (codigo == _codigo) return true;
    if (!await _preferencias.setString('idioma', codigo)) return false;
    _codigo = codigo;
    if (_sonido) {
      reproducirToque();
    }
    notifyListeners();
    return true;
  }

  Future<bool> cambiarSonido(bool activo) async {
    if (activo == _sonido) return true;
    if (!await _preferencias.setBool('sonido', activo)) return false;
    _sonido = activo;
    if (_sonido) {
      reproducirAcierto();
    }
    notifyListeners();
    return true;
  }

  void reproducirToque() {
    if (!_sonido) return;
    _SintetizadorMelodico.reproducir(_EfectoSonoro.toque);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  void reproducirAcierto() {
    if (!_sonido) return;
    _SintetizadorMelodico.reproducir(_EfectoSonoro.acierto);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  void reproducirPista() {
    if (!_sonido) return;
    _SintetizadorMelodico.reproducir(_EfectoSonoro.pista);
    HapticFeedback.lightImpact();
  }

  void reproducirCelebracion() {
    if (!_sonido) return;
    _SintetizadorMelodico.reproducir(_EfectoSonoro.celebracion);
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.heavyImpact();
  }

  String traducir(String texto) {
    if (_codigo == 'es' || texto.isEmpty) return texto;
    return _traducir(texto);
  }

  String _traducir(String texto) {
    final exacta = traducciones[texto];
    if (exacta != null) return exacta;
    final sinMayusculas = _minusculas[texto.toLowerCase()];
    if (sinMayusculas != null) {
      return texto == texto.toUpperCase()
          ? sinMayusculas.toUpperCase()
          : texto == texto.toLowerCase()
          ? sinMayusculas.toLowerCase()
          : sinMayusculas;
    }
    for (final plantilla in _plantillas) {
      final coincidencia = plantilla.$1.firstMatch(texto);
      if (coincidencia != null) {
        return plantilla.$2.replaceAllMapped(RegExp(r'\{(\d+)\}'), (m) {
          return _traducir(coincidencia.group(int.parse(m[1]!) + 1)!);
        });
      }
    }
    // Una respuesta y su pista siguen siendo dos textos del catálogo.
    for (final entrada in traducciones.entries) {
      if (texto.startsWith('${entrada.key} ') && entrada.key.endsWith('.')) {
        return '${entrada.value} ${_traducir(texto.substring(entrada.key.length + 1))}';
      }
    }
    final numerada = RegExp(r'^(\d+)\. (.+)$').firstMatch(texto);
    if (numerada != null) {
      return '${numerada[1]}. ${_traducir(numerada[2]!)}';
    }
    // Composiciones de etiquetas y listas.
    for (final separador in [' · ', '\n', ', ']) {
      if (texto.contains(separador)) {
        final partes = texto.split(separador);
        final traducidas = partes.map(_traducir).toList();
        if (List.generate(
          partes.length,
          (i) => partes[i] != traducidas[i],
        ).any((cambio) => cambio)) {
          return traducidas.join(separador);
        }
      }
    }
    return texto;
  }

  late final Map<String, String> _minusculas = {
    for (final entrada in traducciones.entries)
      entrada.key.toLowerCase(): entrada.value,
  };

  // Las frases más concretas se prueban antes que sus prefijos con parámetros.
  late final List<MapEntry<String, String>> _entradasPlantilla =
      traducciones.entries
          .where((e) => e.key.contains(RegExp(r'\{\d+\}')))
          .toList()
        ..sort(
          (a, b) => b.key
              .replaceAll(RegExp(r'\{\d+\}'), '')
              .length
              .compareTo(a.key.replaceAll(RegExp(r'\{\d+\}'), '').length),
        );

  late final List<(RegExp, String)> _plantillas = [
    for (final entrada in _entradasPlantilla)
      if (entrada.key.contains(RegExp(r'\{\d+\}')))
        (
          RegExp(
            '^${entrada.key.split(RegExp(r'\{\d+\}')).map(RegExp.escape).join('(.*?)')}\$',
          ),
          entrada.value,
        ),
  ];
}

class IdiomaScope extends InheritedNotifier<Idioma> {
  const IdiomaScope({required Idioma idioma, required super.child, super.key})
    : super(notifier: idioma);

  static Idioma? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IdiomaScope>()?.notifier;
}

extension TraduccionContext on BuildContext {
  String traducir(String texto) =>
      IdiomaScope.of(this)?.traducir(texto) ?? texto;

  void sonidoToque() => IdiomaScope.of(this)?.reproducirToque();
  void sonidoAcierto() => IdiomaScope.of(this)?.reproducirAcierto();
  void sonidoPista() => IdiomaScope.of(this)?.reproducirPista();
  void sonidoCelebracion() => IdiomaScope.of(this)?.reproducirCelebracion();
}

enum _EfectoSonoro { toque, acierto, pista, celebracion }

class _NotaMelodica {
  const _NotaMelodica({
    required this.frecuencia,
    required this.inicioSeg,
    required this.duracionSeg,
    required this.volumen,
    this.decaimiento = 11.0,
  });

  final double frecuencia;
  final double inicioSeg;
  final double duracionSeg;
  final double volumen;
  final double decaimiento;
}

/// Sintetizador PCM de 16 bits sin dependencias externas para efectos musicales
/// cálidos estilo marimba/xilófono educativo.
class _SintetizadorMelodico {
  static const MethodChannel _canal = MethodChannel('naturalmente/audio');
  static const int _frecuenciaMuestreo = 22050;
  static final Map<_EfectoSonoro, Uint8List> _cache = {};

  static void reproducir(_EfectoSonoro efecto) {
    final pcm = _cache.putIfAbsent(efecto, () => _generarEfecto(efecto));
    _canal
        .invokeMethod<void>('reproducirPcm', <String, Object>{
          'pcm': pcm,
          'sampleRate': _frecuenciaMuestreo,
        })
        .catchError((_) {});
  }

  static Uint8List _generarEfecto(_EfectoSonoro efecto) {
    return switch (efecto) {
      // Toque de madera cálido y breve al pulsar botones o piezas.
      _EfectoSonoro.toque => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          inicioSeg: 0.0,
          duracionSeg: 0.055,
          volumen: 0.24,
          decaimiento: 34.0,
        ),
        _NotaMelodica(
          frecuencia: 1174.66, // Re6 armónico suave
          inicioSeg: 0.008,
          duracionSeg: 0.045,
          volumen: 0.14,
          decaimiento: 40.0,
        ),
      ]),
      // Doble nota ascendente brillante (Mi5 -> Si5) al acertar un paso.
      _EfectoSonoro.acierto => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 659.25, // Mi5
          inicioSeg: 0.0,
          duracionSeg: 0.12,
          volumen: 0.42,
          decaimiento: 14.0,
        ),
        _NotaMelodica(
          frecuencia: 987.77, // Si5
          inicioSeg: 0.085,
          duracionSeg: 0.24,
          volumen: 0.48,
          decaimiento: 9.5,
        ),
      ]),
      // Marimba suave y amable (Mi4 -> Do4) cuando Natu da una pista para pensar.
      _EfectoSonoro.pista => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 392.00, // Sol4
          inicioSeg: 0.0,
          duracionSeg: 0.11,
          volumen: 0.30,
          decaimiento: 16.0,
        ),
        _NotaMelodica(
          frecuencia: 329.63, // Mi4
          inicioSeg: 0.09,
          duracionSeg: 0.18,
          volumen: 0.28,
          decaimiento: 13.0,
        ),
      ]),
      // Fanfarria alegre ascendente (Do5 -> Mi5 -> Sol5 -> Do6) al completar nivel o cromo.
      _EfectoSonoro.celebracion => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 523.25, // Do5
          inicioSeg: 0.0,
          duracionSeg: 0.12,
          volumen: 0.40,
          decaimiento: 14.0,
        ),
        _NotaMelodica(
          frecuencia: 659.25, // Mi5
          inicioSeg: 0.085,
          duracionSeg: 0.12,
          volumen: 0.42,
          decaimiento: 14.0,
        ),
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          inicioSeg: 0.17,
          duracionSeg: 0.14,
          volumen: 0.45,
          decaimiento: 12.0,
        ),
        _NotaMelodica(
          frecuencia: 1046.50, // Do6
          inicioSeg: 0.26,
          duracionSeg: 0.36,
          volumen: 0.52,
          decaimiento: 7.0,
        ),
      ]),
    };
  }

  static Uint8List _sintetizarNotas(List<_NotaMelodica> notas) {
    var duracionTotal = 0.0;
    for (final nota in notas) {
      final fin = nota.inicioSeg + nota.duracionSeg;
      if (fin > duracionTotal) duracionTotal = fin;
    }
    final totalMuestras = (duracionTotal * _frecuenciaMuestreo).ceil();
    final bytes = ByteData(totalMuestras * 2);

    for (var i = 0; i < totalMuestras; i++) {
      final t = i / _frecuenciaMuestreo;
      var muestra = 0.0;
      for (final nota in notas) {
        final dt = t - nota.inicioSeg;
        if (dt < 0 || dt > nota.duracionSeg) continue;
        // Ataque suave de 6 ms sin chasquidos y caída exponencial tipo marimba.
        final ataque = (dt / 0.006).clamp(0.0, 1.0);
        final caida = math.exp(-dt * nota.decaimiento);
        final cierre = ((nota.duracionSeg - dt) / 0.012).clamp(0.0, 1.0);
        final envolvente = ataque * caida * cierre;
        final fundamental = math.sin(2 * math.pi * nota.frecuencia * dt);
        final armonico2 = 0.28 * math.sin(4 * math.pi * nota.frecuencia * dt);
        final armonico3 = 0.08 * math.sin(6 * math.pi * nota.frecuencia * dt);
        muestra +=
            nota.volumen * envolvente * (fundamental + armonico2 + armonico3);
      }
      final valorPcm = (muestra.clamp(-1.0, 1.0) * 32767).round();
      bytes.setInt16(i * 2, valorPcm, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}
