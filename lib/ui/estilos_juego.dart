import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

abstract final class EstilosJuego {
  static const acierto = Color(0xFF2ECC71);
  static const fallo = Color(0xFFFF9F1C);
  static const borde = Color(0xFFD6CFC0);
  static const radio = 22.0;
  static const separacion = 12.0;

  static BoxDecoration tarjeta(
    BuildContext context, {
    required Color fondo,
    required Color borde,
    Color? sombra,
    bool destacada = false,
    double radio = EstilosJuego.radio,
  }) => BoxDecoration(
    color: context.coloresNaturales.superficie(fondo),
    borderRadius: BorderRadius.circular(radio),
    border: Border.all(
      color: context.coloresNaturales.borde(borde),
      width: destacada ? 3.5 : 2.5,
    ),
    boxShadow: [
      BoxShadow(
        color: context.coloresNaturales.sombra(
          sombra ?? borde.withValues(alpha: .55),
        ),
        offset: const Offset(0, 4),
        blurRadius: 0,
      ),
    ],
  );

  static final respuesta = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(56),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    alignment: Alignment.centerLeft,
  );

  static final accion = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(52),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  );
}
