import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

/// En el navegador no hay código nativo: este es el mismo canal
/// `naturalmente/audio` que usan Android e iOS, hecho con Web Audio.
/// Los navegadores solo dejan sonar después del primer toque del usuario.
void registrarAudioWeb() {
  final canal = MethodChannel(
    'naturalmente/audio',
    const StandardMethodCodec(),
    webPluginRegistrar,
  );
  final audio = _AudioWeb();
  canal.setMethodCallHandler(audio.atender);
}

class _AudioWeb {
  web.AudioContext? _contexto;
  final Map<String, web.AudioBuffer> _decodificados = {};
  web.AudioBufferSourceNode? _musica;

  web.AudioContext get _ctx => _contexto ??= web.AudioContext();

  Future<Object?> atender(MethodCall llamada) async {
    try {
      final args = (llamada.arguments as Map?)?.cast<String, Object?>() ?? const {};
      switch (llamada.method) {
        case 'reproducirArchivo':
          final buffer = await _archivo(args['id']! as String, args['bytes']! as Uint8List);
          _sonar(buffer, volumen: 1);
        case 'reproducirPcm':
          final clave = 'pcm-${args['id']}';
          final buffer = _decodificados[clave] ??=
              _pcm(args['pcm']! as Uint8List, args['sampleRate']! as int);
          _sonar(buffer, volumen: 1);
        case 'iniciarMusicaArchivo':
          final buffer = await _archivo('musica', args['bytes']! as Uint8List);
          _iniciarMusica(buffer);
        case 'iniciarMusicaPcm':
          final buffer = _decodificados['musica-pcm'] ??=
              _pcm(args['pcm']! as Uint8List, args['sampleRate']! as int);
          _iniciarMusica(buffer);
        case 'detenerMusicaPcm':
          _detenerMusica();
      }
    } catch (_) {
      // Un sonido que no se puede reproducir nunca debe romper el juego.
    }
    return null;
  }

  Future<web.AudioBuffer> _archivo(String id, Uint8List bytes) async {
    final guardado = _decodificados[id];
    if (guardado != null) return guardado;
    // decodeAudioData se queda con el buffer: se le pasa una copia.
    final copia = Uint8List.fromList(bytes);
    final buffer = await _ctx.decodeAudioData(copia.buffer.toJS).toDart;
    return _decodificados[id] = buffer;
  }

  /// PCM de 16 bits con signo, mono y little-endian, como en Android.
  web.AudioBuffer _pcm(Uint8List bytes, int frecuencia) {
    final datos = ByteData.sublistView(bytes);
    final muestras = bytes.lengthInBytes ~/ 2;
    final flotantes = Float32List(muestras);
    for (var i = 0; i < muestras; i++) {
      flotantes[i] = datos.getInt16(i * 2, Endian.little) / 32768;
    }
    final buffer = _ctx.createBuffer(1, muestras, frecuencia);
    buffer.copyToChannel(flotantes.toJS, 0);
    return buffer;
  }

  void _sonar(web.AudioBuffer buffer, {required double volumen}) {
    final ctx = _ctx;
    if (ctx.state == 'suspended') ctx.resume();
    final fuente = ctx.createBufferSource()..buffer = buffer;
    final ganancia = ctx.createGain()..gain.value = volumen;
    fuente
      ..connect(ganancia)
      ..start();
    ganancia.connect(ctx.destination);
  }

  void _iniciarMusica(web.AudioBuffer buffer) {
    _detenerMusica();
    final ctx = _ctx;
    if (ctx.state == 'suspended') ctx.resume();
    final fuente = ctx.createBufferSource()
      ..buffer = buffer
      ..loop = true;
    final ganancia = ctx.createGain()..gain.value = 0.35;
    fuente.connect(ganancia);
    ganancia.connect(ctx.destination);
    fuente.start();
    _musica = fuente;
  }

  void _detenerMusica() {
    try {
      _musica?.stop();
    } catch (_) {}
    _musica = null;
  }
}
