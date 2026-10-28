import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data' show Endian;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
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

  int _secuenciaSonido = 0;
  bool _toqueEnCola = false;

  void reproducirToque() {
    if (_toqueEnCola) return;
    _toqueEnCola = true;
    final turno = _secuenciaSonido;
    Future.microtask(() {
      _toqueEnCola = false;
      if (_secuenciaSonido != turno) return;
      if (_sonido) {
        _SintetizadorMelodico.reproducir(_EfectoSonoro.toque);
      }
      if (_vibracion) {
        HapticFeedback.selectionClick();
      }
    });
  }

  void reproducirSeleccion() {
    _secuenciaSonido++;
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.seleccion);
    }
    if (_vibracion) {
      HapticFeedback.selectionClick();
    }
  }

  void reproducirPaso([int paso = 1]) {
    _secuenciaSonido++;
    final indice = paso.clamp(1, 6);
    final efecto = switch (indice) {
      1 => _EfectoSonoro.paso1,
      2 => _EfectoSonoro.paso2,
      3 => _EfectoSonoro.paso3,
      4 => _EfectoSonoro.paso4,
      5 => _EfectoSonoro.paso5,
      _ => _EfectoSonoro.paso6,
    };
    if (_sonido) {
      _SintetizadorMelodico.reproducir(efecto);
    }
    if (_vibracion) {
      HapticFeedback.lightImpact();
    }
  }

  void reproducirQuitar() {
    _secuenciaSonido++;
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.quitar);
    }
    if (_vibracion) {
      HapticFeedback.selectionClick();
    }
  }

  void reproducirDescubrimiento() {
    _secuenciaSonido++;
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.descubrimiento);
    }
    if (_vibracion) {
      HapticFeedback.mediumImpact();
    }
  }

  void reproducirAcierto() {
    _secuenciaSonido++;
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.acierto);
    }
    if (_vibracion) {
      _VibracionAcierto.reproducir();
    }
  }

  /// Prepara los dos efectos de feedback sin reproducirlos.
  Future<void> prepararAciertos() => _SintetizadorMelodico.prepararAciertos();

  void reproducirPista() {
    _secuenciaSonido++;
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.pista);
    }
    if (_vibracion) {
      HapticFeedback.lightImpact();
    }
  }

  void reproducirCelebracion() {
    _secuenciaSonido++;
    if (_sonido) {
      _SintetizadorMelodico.reproducir(_EfectoSonoro.celebracion);
    }
    if (_vibracion) {
      _VibracionAcierto.reproducir(finalDeNivel: true);
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
  String tr(String texto) => traducir(texto);

  void sonidoToque() => IdiomaScope.of(this)?.reproducirToque();
  void sonidoSeleccion() => IdiomaScope.of(this)?.reproducirSeleccion();
  void sonidoPaso([int paso = 1]) =>
      IdiomaScope.of(this)?.reproducirPaso(paso);
  void sonidoQuitar() => IdiomaScope.of(this)?.reproducirQuitar();
  void sonidoDescubrimiento() =>
      IdiomaScope.of(this)?.reproducirDescubrimiento();
  void sonidoAcierto() => IdiomaScope.of(this)?.reproducirAcierto();
  void sonidoPista() => IdiomaScope.of(this)?.reproducirPista();
  void sonidoCelebracion() => IdiomaScope.of(this)?.reproducirCelebracion();
}

/// Pulso propio en Android; confirmación del sistema en las demás plataformas.
abstract final class _VibracionAcierto {
  static const _canal = MethodChannel('naturalmente/haptica');

  static Future<void> reproducir({bool finalDeNivel = false}) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final reproducida = await _canal.invokeMethod<bool>('acierto', {
          'finalDeNivel': finalDeNivel,
        });
        if (reproducida == true) return;
      } on MissingPluginException {
        // Permite ejecutar la app con un motor que aún no incluya el canal.
      } on PlatformException {
        // Conserva el feedback estándar si el dispositivo rechaza el patrón.
      }
    }
    if (finalDeNivel) {
      await HapticFeedback.successNotification();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }
}

enum _EfectoSonoro {
  toque,
  seleccion,
  paso1,
  paso2,
  paso3,
  paso4,
  paso5,
  paso6,
  quitar,
  descubrimiento,
  acierto,
  pista,
  celebracion,
}

class _NotaMelodica {
  const _NotaMelodica({
    required this.frecuencia,
    required this.inicioSeg,
    required this.duracionSeg,
    required this.volumen,
    this.frecuenciaFinal,
    this.decaimiento = 11.0,
    this.brillo = 0.30,
    this.ataqueSeg = 0.0035,
  });

  final double frecuencia;
  final double? frecuenciaFinal;
  final double inicioSeg;
  final double duracionSeg;
  final double volumen;
  final double decaimiento;
  final double brillo;
  final double ataqueSeg;
}

/// Sintetizador PCM de 16 bits a 44.1 kHz sin dependencias externas para
/// efectos sonoros estilo Duolingo (pops con barrido de tono, escala ascendente
/// de combos, «ba-DING» de acierto y fanfarria de victoria).
class _SintetizadorMelodico {
  static const MethodChannel _canal = MethodChannel('naturalmente/audio');
  static const int _frecuenciaMuestreo = 44100;
  static final Map<_EfectoSonoro, Uint8List> _cache = {};
  static final Map<String, (Uint8List, String)?> _cacheArchivos = {};
  static Uint8List? _cacheMusica;
  static Future<void>? _preparacionAciertos;

  static Future<void> prepararAciertos() => _preparacionAciertos ??= () async {
    for (final efecto in const [
      _EfectoSonoro.acierto,
      _EfectoSonoro.celebracion,
    ]) {
      final archivo = await _cargarArchivoPersonalizado(_candidatosEfecto(efecto));
      if (archivo == null) {
        _cache.putIfAbsent(efecto, () => _generarEfecto(efecto));
      }
    }
  }();

  static List<String> _candidatosEfecto(_EfectoSonoro efecto) => switch (efecto) {
    _EfectoSonoro.paso1 ||
    _EfectoSonoro.paso2 ||
    _EfectoSonoro.paso3 ||
    _EfectoSonoro.paso4 ||
    _EfectoSonoro.paso5 ||
    _EfectoSonoro.paso6 => [efecto.name, 'paso'],
    _ => [efecto.name],
  };

  static Future<(Uint8List, String)?> _cargarArchivoPersonalizado(
    List<String> nombres,
  ) async {
    final clave = nombres.first;
    if (_cacheArchivos.containsKey(clave)) {
      return _cacheArchivos[clave];
    }
    for (final nombre in nombres) {
      for (final ext in const ['mp3', 'wav', 'ogg']) {
        try {
          final data = await rootBundle.load('assets/sonidos/$nombre.$ext');
          if (data.lengthInBytes > 0) {
            final bytes = data.buffer.asUint8List(
              data.offsetInBytes,
              data.lengthInBytes,
            );
            final resultado = (bytes, ext);
            _cacheArchivos[clave] = resultado;
            return resultado;
          }
        } catch (_) {}
      }
    }
    _cacheArchivos[clave] = null;
    return null;
  }

  static void reproducir(_EfectoSonoro efecto) {
    _reproducirAsync(efecto);
  }

  static Future<void> _reproducirAsync(_EfectoSonoro efecto) async {
    final personalizado = await _cargarArchivoPersonalizado(
      _candidatosEfecto(efecto),
    );
    if (personalizado != null) {
      _canal
          .invokeMethod<void>('reproducirArchivo', <String, Object>{
            'id': efecto.name,
            'bytes': personalizado.$1,
            'ext': personalizado.$2,
          })
          .catchError((_) {});
      return;
    }
    final pcm = _cache.putIfAbsent(efecto, () => _generarEfecto(efecto));
    _canal
        .invokeMethod<void>('reproducirPcm', <String, Object>{
          'id': efecto.name,
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
    _iniciarMusicaAsync();
  }

  static Future<void> _iniciarMusicaAsync() async {
    final personalizado = await _cargarArchivoPersonalizado(const ['musica']);
    if (personalizado != null) {
      _canal
          .invokeMethod<void>('iniciarMusicaArchivo', <String, Object>{
            'bytes': personalizado.$1,
            'ext': personalizado.$2,
          })
          .catchError((_) {});
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

  static List<_NotaMelodica> _notasEscalaCombo(double baseHz) => [
    _NotaMelodica(
      frecuencia: baseHz * 0.94,
      frecuenciaFinal: baseHz,
      inicioSeg: 0.0,
      duracionSeg: 0.14,
      volumen: 0.62,
      decaimiento: 15.0,
      brillo: 0.38,
      ataqueSeg: 0.0025,
    ),
    _NotaMelodica(
      frecuencia: baseHz * 2.0,
      inicioSeg: 0.006,
      duracionSeg: 0.11,
      volumen: 0.28,
      decaimiento: 20.0,
      brillo: 0.22,
      ataqueSeg: 0.0025,
    ),
  ];

  static Uint8List _generarEfecto(_EfectoSonoro efecto) {
    return switch (efecto) {
      // Pop táctil estilo Duolingo con barrido ascendente rápido al tocar botones.
      _EfectoSonoro.toque => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 430.0,
          frecuenciaFinal: 690.0,
          inicioSeg: 0.0,
          duracionSeg: 0.052,
          volumen: 0.56,
          decaimiento: 32.0,
          brillo: 0.22,
          ataqueSeg: 0.002,
        ),
        _NotaMelodica(
          frecuencia: 860.0,
          frecuenciaFinal: 1180.0,
          inicioSeg: 0.008,
          duracionSeg: 0.042,
          volumen: 0.26,
          decaimiento: 38.0,
          brillo: 0.15,
          ataqueSeg: 0.002,
        ),
      ]),
      // Pop elástico brillante al elegir una ficha, pieza o cuidado.
      _EfectoSonoro.seleccion => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 523.25, // Do5
          frecuenciaFinal: 587.33,
          inicioSeg: 0.0,
          duracionSeg: 0.065,
          volumen: 0.54,
          decaimiento: 22.0,
          brillo: 0.30,
          ataqueSeg: 0.002,
        ),
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          frecuenciaFinal: 830.61,
          inicioSeg: 0.032,
          duracionSeg: 0.095,
          volumen: 0.52,
          decaimiento: 18.0,
          brillo: 0.34,
          ataqueSeg: 0.002,
        ),
      ]),
      // Escala ascendente de combo (Do5 -> Re5 -> Mi5 -> Sol5 -> La5 -> Do6)
      // al colocar pasos seguidos, masticar o avanzar etapas.
      _EfectoSonoro.paso1 => _sintetizarNotas(_notasEscalaCombo(523.25)), // Do5
      _EfectoSonoro.paso2 => _sintetizarNotas(_notasEscalaCombo(587.33)), // Re5
      _EfectoSonoro.paso3 => _sintetizarNotas(_notasEscalaCombo(659.25)), // Mi5
      _EfectoSonoro.paso4 => _sintetizarNotas(_notasEscalaCombo(783.99)), // Sol5
      _EfectoSonoro.paso5 => _sintetizarNotas(_notasEscalaCombo(880.00)), // La5
      _EfectoSonoro.paso6 => _sintetizarNotas(_notasEscalaCombo(1046.50)), // Do6
      // Pop descendente suave al devolver un paso o retroceder.
      _EfectoSonoro.quitar => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 740.0,
          frecuenciaFinal: 440.0,
          inicioSeg: 0.0,
          duracionSeg: 0.085,
          volumen: 0.48,
          decaimiento: 20.0,
          brillo: 0.18,
          ataqueSeg: 0.0025,
        ),
      ]),
      // Destello mágico de glockenspiel al abrir un cromo o curiosidad de Natu.
      _EfectoSonoro.descubrimiento => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          inicioSeg: 0.0,
          duracionSeg: 0.12,
          volumen: 0.46,
          decaimiento: 14.0,
          brillo: 0.42,
        ),
        _NotaMelodica(
          frecuencia: 987.77, // Si5
          inicioSeg: 0.055,
          duracionSeg: 0.13,
          volumen: 0.50,
          decaimiento: 13.0,
          brillo: 0.44,
        ),
        _NotaMelodica(
          frecuencia: 1174.66, // Re6
          inicioSeg: 0.11,
          duracionSeg: 0.16,
          volumen: 0.54,
          decaimiento: 11.0,
          brillo: 0.46,
        ),
        _NotaMelodica(
          frecuencia: 1567.98, // Sol6
          inicioSeg: 0.165,
          duracionSeg: 0.34,
          volumen: 0.62,
          decaimiento: 7.5,
          brillo: 0.50,
        ),
      ]),
      // Icónico «ba-DING!» de Duolingo (Fa5 -> acorde brillante de Si♭ Mayor).
      _EfectoSonoro.acierto => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 698.46, // Fa5
          inicioSeg: 0.0,
          duracionSeg: 0.11,
          volumen: 0.64,
          decaimiento: 14.0,
          brillo: 0.38,
          ataqueSeg: 0.0025,
        ),
        _NotaMelodica(
          frecuencia: 349.23, // Cuerpo Fa4
          inicioSeg: 0.0,
          duracionSeg: 0.09,
          volumen: 0.28,
          decaimiento: 16.0,
          brillo: 0.18,
          ataqueSeg: 0.0025,
        ),
        _NotaMelodica(
          frecuencia: 932.33, // Si♭5 principal
          inicioSeg: 0.088,
          duracionSeg: 0.38,
          volumen: 0.72,
          decaimiento: 6.8,
          brillo: 0.46,
          ataqueSeg: 0.0025,
        ),
        _NotaMelodica(
          frecuencia: 1174.66, // Re6 tercera mayor brillante
          inicioSeg: 0.088,
          duracionSeg: 0.36,
          volumen: 0.42,
          decaimiento: 7.5,
          brillo: 0.40,
          ataqueSeg: 0.003,
        ),
        _NotaMelodica(
          frecuencia: 1396.91, // Fa6 quinta cristalina
          inicioSeg: 0.092,
          duracionSeg: 0.34,
          volumen: 0.34,
          decaimiento: 8.2,
          brillo: 0.35,
          ataqueSeg: 0.003,
        ),
      ]),
      // Doble toque grave y amable de madera cálida estilo Duolingo al dar pista.
      _EfectoSonoro.pista => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 349.23, // Fa4
          frecuenciaFinal: 329.63,
          inicioSeg: 0.0,
          duracionSeg: 0.11,
          volumen: 0.54,
          decaimiento: 16.0,
          brillo: 0.14,
          ataqueSeg: 0.003,
        ),
        _NotaMelodica(
          frecuencia: 261.63, // Do4
          frecuenciaFinal: 246.94,
          inicioSeg: 0.092,
          duracionSeg: 0.22,
          volumen: 0.52,
          decaimiento: 12.0,
          brillo: 0.12,
          ataqueSeg: 0.003,
        ),
      ]),
      // Fanfarria triunfal de fin de lección estilo Duolingo.
      _EfectoSonoro.celebracion => _sintetizarNotas(const [
        _NotaMelodica(
          frecuencia: 523.25, // Do5
          inicioSeg: 0.0,
          duracionSeg: 0.11,
          volumen: 0.58,
          decaimiento: 13.0,
          brillo: 0.40,
        ),
        _NotaMelodica(
          frecuencia: 659.25, // Mi5
          inicioSeg: 0.082,
          duracionSeg: 0.11,
          volumen: 0.60,
          decaimiento: 13.0,
          brillo: 0.42,
        ),
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          inicioSeg: 0.164,
          duracionSeg: 0.13,
          volumen: 0.64,
          decaimiento: 11.5,
          brillo: 0.44,
        ),
        _NotaMelodica(
          frecuencia: 1046.50, // Do6
          inicioSeg: 0.246,
          duracionSeg: 0.11,
          volumen: 0.66,
          decaimiento: 12.0,
          brillo: 0.46,
        ),
        _NotaMelodica(
          frecuencia: 783.99, // Sol5 apoyo rítmico
          inicioSeg: 0.34,
          duracionSeg: 0.10,
          volumen: 0.56,
          decaimiento: 13.0,
          brillo: 0.42,
        ),
        // Gran acorde final de Do Mayor brillante
        _NotaMelodica(
          frecuencia: 1046.50, // Do6
          inicioSeg: 0.43,
          duracionSeg: 0.54,
          volumen: 0.72,
          decaimiento: 5.2,
          brillo: 0.48,
        ),
        _NotaMelodica(
          frecuencia: 1318.51, // Mi6
          inicioSeg: 0.43,
          duracionSeg: 0.52,
          volumen: 0.42,
          decaimiento: 5.8,
          brillo: 0.40,
        ),
        _NotaMelodica(
          frecuencia: 783.99, // Sol5
          inicioSeg: 0.43,
          duracionSeg: 0.52,
          volumen: 0.40,
          decaimiento: 5.8,
          brillo: 0.36,
        ),
        _NotaMelodica(
          frecuencia: 523.25, // Do5 bajo
          inicioSeg: 0.43,
          duracionSeg: 0.50,
          volumen: 0.36,
          decaimiento: 6.0,
          brillo: 0.28,
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
          volumen: 0.11,
          decaimiento: 5.5,
        ),
      const _NotaMelodica(
        frecuencia: 130.81, // Do3
        inicioSeg: 0.0,
        duracionSeg: 1.9,
        volumen: 0.07,
        decaimiento: 1.8,
      ),
      const _NotaMelodica(
        frecuencia: 196.00, // Sol3
        inicioSeg: 2.0,
        duracionSeg: 1.9,
        volumen: 0.07,
        decaimiento: 1.8,
      ),
      const _NotaMelodica(
        frecuencia: 146.83, // Re3
        inicioSeg: 4.0,
        duracionSeg: 1.9,
        volumen: 0.07,
        decaimiento: 1.8,
      ),
      const _NotaMelodica(
        frecuencia: 164.81, // Mi3
        inicioSeg: 6.0,
        duracionSeg: 1.9,
        volumen: 0.07,
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
        final ataque = (dt / nota.ataqueSeg).clamp(0.0, 1.0);
        final caida = math.exp(-dt * nota.decaimiento);
        final cierre = ((nota.duracionSeg - dt) / 0.010).clamp(0.0, 1.0);
        final envolvente = ataque * caida * cierre;

        final f0 = nota.frecuencia;
        final f1 = nota.frecuenciaFinal ?? f0;
        final fase =
            2 *
            math.pi *
            (f0 * dt + ((f1 - f0) / (2 * nota.duracionSeg)) * dt * dt);

        final fundamental = math.sin(fase);
        final armonico2 = nota.brillo * math.sin(2 * fase);
        final armonico3 = (nota.brillo * 0.35) * math.sin(3 * fase);
        final golpe =
            dt < 0.009
                ? 0.22 * math.exp(-dt * 260.0) * math.sin(4.2 * fase)
                : 0.0;

        muestra +=
            nota.volumen *
            envolvente *
            (fundamental + armonico2 + armonico3 + golpe);
      }
      final saturada = muestra / (1.0 + 0.22 * muestra.abs());
      final valorPcm = (saturada.clamp(-1.0, 1.0) * 32767).round();
      bytes.setInt16(i * 2, valorPcm, Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}
