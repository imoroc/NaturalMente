import 'package:flutter/foundation.dart';

/// Los 16 dibujos de la llave mágica, en el mismo orden y con los mismos ids
/// que `private.generar_llave()` en la base de datos: id → (emoji, nombre).
const dibujosLlave = <String, (String, String)>{
  'zorro': ('🦊', 'Zorro'),
  'pino': ('🌲', 'Pino'),
  'nube': ('☁️', 'Nube'),
  'sol': ('☀️', 'Sol'),
  'luna': ('🌙', 'Luna'),
  'flor': ('🌸', 'Flor'),
  'hoja': ('🍃', 'Hoja'),
  'pez': ('🐟', 'Pez'),
  'rana': ('🐸', 'Rana'),
  'seta': ('🍄', 'Seta'),
  'estrella': ('⭐', 'Estrella'),
  'gota': ('💧', 'Gota'),
  'abeja': ('🐝', 'Abeja'),
  'caracol': ('🐌', 'Caracol'),
  'arcoiris': ('🌈', 'Arcoíris'),
  'montana': ('⛰️', 'Montaña'),
};

/// Llave mágica: tres dibujos y un número de 00 a 99.
@immutable
class Llave {
  const Llave(this.dibujos, this.numero);

  /// Lee el formato de la base de datos: `zorro-pino-nube-07`.
  static Llave? leer(String texto) {
    final partes = texto.trim().toLowerCase().split('-');
    if (partes.length != 4) return null;
    final dibujos = partes.take(3).toList();
    final numero = int.tryParse(partes[3]);
    if (dibujos.any((d) => !dibujosLlave.containsKey(d)) ||
        numero == null ||
        numero < 0 ||
        numero > 99) {
      return null;
    }
    return Llave(dibujos, numero);
  }

  final List<String> dibujos;
  final int numero;

  String get texto =>
      '${dibujos.join('-')}-${numero.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) => other is Llave && other.texto == texto;
  @override
  int get hashCode => texto.hashCode;
}
