import 'package:flutter/material.dart';
import 'package:naturalmente/ui/estilos_juego.dart';

/// Presentación compartida; la selección y validación pertenecen a cada juego.
class TarjetaJuego extends StatelessWidget {
  const TarjetaJuego({
    required this.child,
    required this.borde,
    this.fondo = Colors.white,
    this.sombra,
    this.destacada = false,
    this.radio = EstilosJuego.radio,
    this.onTap,
    this.claveAccion,
    super.key,
  });

  final Widget child;
  final Color borde;
  final Color fondo;
  final Color? sombra;
  final bool destacada;
  final double radio;
  final VoidCallback? onTap;
  final Key? claveAccion;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 120),
    decoration: EstilosJuego.tarjeta(
      fondo: fondo,
      borde: borde,
      sombra: sombra,
      destacada: destacada,
      radio: radio,
    ),
    child: Material(
      color: Colors.transparent,
      child: onTap == null
          ? child
          : InkWell(
              key: claveAccion,
              borderRadius: BorderRadius.circular(radio - 2),
              focusColor: Theme.of(context).colorScheme.primary
                  .withValues(alpha: .2),
              onTap: onTap,
              child: child,
            ),
    ),
  );
}
