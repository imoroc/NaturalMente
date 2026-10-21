import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data' show Endian;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias locales de idioma, efectos sonoros, música y vibración.
class Idioma extends ChangeNotifier {
  Idioma(this._preferencias, this.traducciones)
    : _codigo = _preferencias.getString('idioma') == 'en' ? 'en' : 'es',
      _sonido = _preferencias.getBool('sonido') ?? true,
      _musica = _preferencias.getBool('musica') ?? false,
      _vibracion = _preferencias.getBool('vibracion') ?? true {
    if (_musica) {
      _SintetizadorMelodico.sincronizarMusica(true);
    }
  }

  final SharedPreferences _preferencias;
  final Map<String, String> traducciones;
  String _codigo;
  bool _sonido;
  bool _musica;
  bool _vibracion;

  String get codigo => _codigo;
  Locale get locale => Locale(_codigo);
  bool get sonido => _sonido;
  bool get musica => _musica;
  bool get vibracion => _vibracion;

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
    reproducirToque();
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

  Future<bool> cambiarMusica(bool activa) async {
    if (activa == _musica) return true;
    if (!await _preferencias.setBool('musica', activa)) return false;
    _musica = activa;
    _SintetizadorMelodico.sincronizarMusica(_musica);
    if (_sonido) {
      reproducirToque();
    }
    notifyListeners();
    return true;
  }

  Future<bool> cambiarVibracion(bool activa) async {
    if (activa == _vibracion) return true;
    if (!await _preferencias.setBool('vibracion', activa)) return false;
    _vibracion = activa;
    if (_vibracion) {
      HapticFeedback.mediumImpact();
    }
    if (_sonido) {
      reproducirToque();
    }
    notifyListeners();
    return true;
  }

  void reproducirToque() {
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.toque);
      SystemSound.play(SystemSoundType.click);
    }
    if (_vibracion) {
      HapticFeedback.selectionClick();
    }
  }

  void reproducirAcierto() {
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.acierto);
      SystemSound.play(SystemSoundType.click);
    }
    if (_vibracion) {
      HapticFeedback.mediumImpact();
    }
  }

  void reproducirPista() {
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.pista);
    }
    if (_vibracion) {
      HapticFeedback.lightImpact();
    }
  }

  void reproducirCelebracion() {
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.celebracion);
      SystemSound.play(SystemSoundType.click);
    }
    if (_vibracion) {
      HapticFeedback.heavyImpact();
    }
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
/// cálidos estilo marimba/xilófono educativo y melodía ambiental de fondo.
class _SintetizadorMelodico {
  static const MethodChannel _canal = MethodChannel('naturalmente/audio');
  static const int _frecuenciaMuestreo = 22050;
  static final Map<_EfectoSonoro, Uint8List> _cache = {};
  static Uint8List? _cacheMusica;

  static void reproducir(_EfectoSonoro efecto) {
    final pcm = _cache.putIfAbsent(efecto, () => _generarEfecto(efecto));
    _canal
        .invokeMethod<void>('reproducirPcm', <String, Object>{
          'pcm': pcm,
          'sampleRate': _frecuenciaMuestreo,
        })
        .catchError((_) {});
  }

  static void sincronizarMusica(bool activa) {
    if (!activa) {
      _canal.invokeMethod<void>('detenerMusicaPcm').catchError((_) {});
      return;
    }
    final pcm = _cacheMusica ??= _generarBucleAmbiental();
    _canal
        .invokeMethod<void>('iniciarMusicaPcm', <String, Object>{
          'pcm': pcm,
          'sampleRate': _frecuenciaMuestreo,
        })
        .catchError((_) {});
  }

  static Uint8List _generarEfecto(_EfectoSonoro efecto) {
    return switch (efecto) {
      // Toque de madera cálido y satisfactorio al pulsar botones o piezas.
      _EfectoSonoro.toque => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 659.25, // Mi5
          inicioSeg: 0.0,
          duracionSeg: 0.065,
          volumen: 0.34,
          decaimiento: 28.0,
        ),
        _NotaMelodica(
          frecuencia: 987.77, // Si5
          inicioSeg: 0.014,
          duracionSeg: 0.060,
          volumen: 0.24,
          decaimiento: 32.0,
        ),
      ]),
      // Doble nota ascendente brillante estilo Duolingo (Re5 -> La5) al acertar un paso.
      _EfectoSonoro.acierto => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 587.33, // Re5
          inicioSeg: 0.0,
          duracionSeg: 0.13,
          volumen: 0.48,
          decaimiento: 13.0,
        ),
        _NotaMelodica(
          frecuencia: 880.00, // La5
          inicioSeg: 0.085,
          duracionSeg: 0.28,
          volumen: 0.56,
          decaimiento: 8.5,
        ),
        _NotaMelodica(
          frecuencia: 1174.66, // Re6 brillo
          inicioSeg: 0.090,
          duracionSeg: 0.24,
          volumen: 0.22,
          decaimiento: 10.0,
        ),
      ]),
      // Marimba suave y amable (Sol4 -> Mi4) cuando Natu da una pista para pensar.
      _EfectoSonoro.pista => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 392.00, // Sol4
          inicioSeg: 0.0,
          duracionSeg: 0.12,
          volumen: 0.36,
          decaimiento: 15.0,
        ),
        _NotaMelodica(
          frecuencia: 329.63, // Mi4
          inicioSeg: 0.095,
          duracionSeg: 0.20,
          volumen: 0.34,
          decaimiento: 12.0,
        ),
      ]),
      // Fanfarria alegre ascendente (Do5 -> Mi5 -> Sol5 -> Do6) al completar nivel o cromo.
      _EfectoSonoro.celebracion => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 523.25, // Do5
          inicioSeg: 0.0,
          duracionSeg: 0.13,
          volumen: 0.46,
          decaimiento: 13.0,
        ),
        _NotaMelodica(
          frecuencia: 659.25, // Mi5
          inicioSeg: 0.09,
          duracionSeg: 0.13,
          volumen: 0.48,
          decaimiento: 13.0,
        ),
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          inicioSeg: 0.18,
          duracionSeg: 0.15,
          volumen: 0.52,
          decaimiento: 11.0,
        ),
        _NotaMelodica(
          frecuencia: 1046.50, // Do6
          inicioSeg: 0.27,
          duracionSeg: 0.42,
          volumen: 0.60,
          decaimiento: 6.5,
        ),
        _NotaMelodica(
          frecuencia: 523.25, // Acorde base Do5
          inicioSeg: 0.27,
          duracionSeg: 0.40,
          volumen: 0.24,
          decaimiento: 7.5,
        ),
      ]),
    };
  }

  /// Genera un bucle pentatónico tranquilo de 8 segundos estilo cuaderno de naturaleza.
  static Uint8List _generarBucleAmbiental() {
    const paso = 0.5;
    const secuencia = <double>[
      261.63, // Do4
      329.63, // Mi4
      392.00, // Sol4
      440.00, // La4
      523.25, // Do5
      392.00, // Sol4
      329.63, // Mi4
      392.00, // Sol4
      293.66, // Re4
      392.00, // Sol4
      440.00, // La4
      587.33, // Re5
      523.25, // Do5
      440.00, // La4
      392.00, // Sol4
      329.63, // Mi4
    ];
    final notas = <_NotaMelodica>[
      for (var i = 0; i < secuencia.length; i++)
        _NotaMelodica(
          frecuencia: secuencia[i],
          inicioSeg: i * paso,
          duracionSeg: 0.48,
          volumen: 0.09,
          decaimiento: 5.5,
        ),
      const _NotaMelodica(
        frecuencia: 130.81, // Do3
        inicioSeg: 0.0,
        duracionSeg: 1.9,
        volumen: 0.06,
        decaimiento: 1.8,
      ),
      const _NotaMelodica(
        frecuencia: 196.00, // Sol3
        inicioSeg: 2.0,
        duracionSeg: 1.9,
        volumen: 0.06,
        decaimiento: 1.8,
      ),
      const _NotaMelodica(
        frecuencia: 146.83, // Re3
        inicioSeg: 4.0,
        duracionSeg: 1.9,
        volumen: 0.06,
        decaimiento: 1.8,
      ),
      const _NotaMelodica(
        frecuencia: 164.81, // Mi3
        inicioSeg: 6.0,
        duracionSeg: 1.9,
        volumen: 0.06,
        decaimiento: 1.8,
      ),
    ];
    return _sintetizarNotas(notas);
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
