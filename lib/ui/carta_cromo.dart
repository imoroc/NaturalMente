import 'package:flutter/material.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

class ArteCromo extends StatelessWidget {
  const ArteCromo(this.nombre, {required this.alto, this.ancho, super.key});
  final String nombre;
  final double alto;
  final double? ancho;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/cromos/$nombre.webp',
    height: alto,
    width: ancho,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}

/// El mismo marco representa una ficha en el álbum y en la celebración.
class CartaCromo extends StatelessWidget {
  const CartaCromo({
    required this.ficha,
    required this.conseguida,
    required this.altoArte,
    this.destacada = false,
    this.miniatura = false,
    super.key,
  });

  final Ficha ficha;
  final bool conseguida;
  final bool destacada;
  final bool miniatura;
  final double altoArte;

  @override
  Widget build(BuildContext context) {
    const oro = Color(0xFFC58520);
    final colores = context.coloresNaturales;
    final radio = BorderRadius.circular(miniatura ? 16 : 28);
    final papel = colores.superficie(const Color(0xFFFFF4D6));
    final marco = colores.borde(conseguida ? oro : const Color(0xFF928565));
    return Material(
      color: papel,
      shape: RoundedRectangleBorder(
        borderRadius: radio,
        side: BorderSide(color: marco, width: miniatura ? 2 : 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colores.superficie(const Color(0xFFFFF9E9)),
              papel,
              colores.superficie(const Color(0xFFFFE2A2)),
            ],
          ),
          borderRadius: radio,
          border: Border.all(color: marco, width: miniatura ? 2 : 4),
        ),
        child: Padding(
          padding: EdgeInsets.all(miniatura ? 8 : 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: marco.withValues(alpha: .58)),
              borderRadius: BorderRadius.circular(miniatura ? 10 : 19),
            ),
            child: Padding(
              padding: EdgeInsets.all(miniatura ? 6 : 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: altoArte,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        FittedBox(
                          fit: BoxFit.contain,
                          child: conseguida
                              ? (ficha.id == 'camello'
                                    ? const ArteCromo(
                                        'camello',
                                        alto: 180,
                                        ancho: 235,
                                      )
                                    : IlustracionFicha(id: ficha.id, alto: 180))
                              : Icon(
                                  Icons.lock_rounded,
                                  size: 58,
                                  color: colores.tenue,
                                ),
                        ),
                        if (destacada && !miniatura)
                          Align(
                            alignment: Alignment.topRight,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: MediaQuery.disableAnimationsOf(context)
                                    ? 1
                                    : 0,
                                end: 1,
                              ),
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 360),
                              curve: Curves.easeOut,
                              builder: (_, opacity, child) =>
                                  Opacity(opacity: opacity, child: child),
                              child: const ArteCromo(
                                'destellos',
                                alto: 46,
                                ancho: 48,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Texto(
                    ficha.titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NunitoInicio',
                      fontWeight: FontWeight.w900,
                      fontSize: miniatura ? 16 : 29,
                      color: colores.tinta,
                      height: 1.1,
                    ),
                  ),
                  if (!conseguida) ...[
                    const SizedBox(height: 4),
                    Texto(
                      'Por descubrir',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colores.tenue, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
