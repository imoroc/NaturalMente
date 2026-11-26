import 'package:flutter_tts/flutter_tts.dart';

/// Lee textos en voz alta con la voz del propio sistema (Android, iOS,
/// navegador u ordenador). Si el dispositivo no tiene voz, no hace nada.
abstract final class Voz {
  static FlutterTts? _tts;
  static bool _disponible = true;

  static Future<void> decir(String texto, String idioma) async {
    if (!_disponible || texto.trim().isEmpty) return;
    try {
      final tts = _tts ??= FlutterTts();
      await tts.stop();
      await tts.setLanguage(idioma == 'en' ? 'en-GB' : 'es-ES');
      // Un poco más despacio: lo escuchan niños de 6 a 12 años.
      await tts.setSpeechRate(0.45);
      await tts.speak(texto);
    } catch (_) {
      _disponible = false;
    }
  }

  static Future<void> parar() async {
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
