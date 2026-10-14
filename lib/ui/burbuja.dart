import 'package:flutter/material.dart';
import 'package:naturalmente/ui/dibujos.dart';

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
    final esFeliz = gesto == 'feliz';
    final colorFondo = esFeliz ? const Color(0xFFECFDF3) : const Color(0xFFFFF8EC);
    final colorBorde = esFeliz ? const Color(0xFF2ECC71) : const Color(0xFFFFB703);
    final colorSombra = esFeliz ? const Color(0xFF239E56) : const Color(0xFFD99000);
    final colorTitulo = esFeliz ? const Color(0xFF157347) : const Color(0xFFB45309);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: colorSombra.withValues(alpha: 0.35),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DibujoMascota(gesto: gesto, tamano: 48),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quien,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: colorTitulo,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
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
