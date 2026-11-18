import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Etiqueta «Recomendado para ti» en la tarjeta del nivel que corresponde al
/// curso elegido. No aparece si no hay curso o si el nivel es otro; todos los
/// niveles siguen abiertos.
class EtiquetaRecomendado extends StatelessWidget {
  const EtiquetaRecomendado({required this.nivelId, super.key});

  final String nivelId;

  @override
  Widget build(BuildContext context) {
    final recomendado = Alcance.maybeOf(context)?.progreso.nivelRecomendado;
    if (recomendado == null || recomendado != nivelId) {
      return const SizedBox.shrink();
    }
    final colores = context.coloresNaturales;
    final color = colores.contenido(const Color(0xFF7C3AED));
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          key: Key('recomendado-$nivelId'),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colores.superficie(const Color(0xFFF3E8FF)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: colores.borde(const Color(0xFFA78BFA)),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 15, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Texto(
                  'Recomendado para ti',
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
