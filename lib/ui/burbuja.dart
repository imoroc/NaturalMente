import 'package:flutter/material.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/texto.dart';

class Burbuja extends StatelessWidget {
  const Burbuja({
    required this.quien,
    required this.frase,
    this.gesto = 'pensando',
    super.key,
  });

  final String quien;
  final String frase;
  final String gesto;

  @override
  Widget build(BuildContext context) {
    final (colorFondo, colorBorde, colorSombra, colorTitulo) = switch (gesto) {
      'feliz' => (
        const Color(0xFFECFDF3),
        const Color(0xFF2ECC71),
        const Color(0xFF239E56),
        const Color(0xFF157347),
      ),
      'pista' => (
        const Color(0xFFFFF7ED),
        const Color(0xFFFB923C),
        const Color(0xFFEA580C),
        const Color(0xFFC2410C),
      ),
      'hola' => (
        const Color(0xFFF2FBF6),
        const Color(0xFF34D399),
        const Color(0xFF059669),
        const Color(0xFF0F766E),
      ),
      _ => (
        const Color(0xFFFFF8EC),
        const Color(0xFFFFB703),
        const Color(0xFFD99000),
        const Color(0xFFB45309),
      ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: colorSombra.withValues(alpha: 0.32),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DibujoMascota(gesto: gesto, tamano: 46),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Texto(
                  quien,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                    color: colorTitulo,
                  ),
                ),
                const SizedBox(height: 2),
                Texto(
                  frase,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    height: 1.25,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
