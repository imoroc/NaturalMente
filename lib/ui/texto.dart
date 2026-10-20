import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';

/// Traduce al presentar, también al cambiar de idioma en una ruta ya abierta.
/// Conserva los textos originales del catálogo y los identificadores del juego.
class Texto extends StatelessWidget {
  const Texto(
    this.data, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) => Text(
    context.traducir(data),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
  );
}
