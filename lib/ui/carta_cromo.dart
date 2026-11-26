import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

class ArteCromo extends StatelessWidget {
  const ArteCromo(
    this.nombre, {
    required this.alto,
    this.ancho,
    this.anchoDecodificado,
    super.key,
  });
  final String nombre;
  final double alto;
  final double? ancho;
  final int? anchoDecodificado;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/cromos/$nombre.webp',
    height: alto,
    width: ancho,
    cacheWidth: anchoDecodificado,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}

/// Arte propio del álbum, con respaldo para las fichas en producción.
class IlustracionCromo extends StatelessWidget {
  const IlustracionCromo(this.ficha, {required this.alto, super.key});

  final Ficha ficha;
  final double alto;

  @override
  Widget build(BuildContext context) {
    if (!ficha.arteCromo) return IlustracionFicha(id: ficha.id, alto: alto);
    final ancho = alto * 1.09;
    final densidad = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    return ArteCromo(
      ficha.id,
      alto: alto,
      ancho: ancho,
      anchoDecodificado: (ancho * densidad).ceil().clamp(1, 460),
    );
  }
}

/// Miniatura estática de la cuadrícula del álbum.
class CartaCromo extends StatelessWidget {
  const CartaCromo({required this.ficha, required this.conseguida, super.key});

  final Ficha ficha;
  final bool conseguida;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final radio = BorderRadius.circular(16);
    final acento = !conseguida
        ? const Color(0xFF928565)
        : switch (ficha.acabado) {
            AcabadoCromo.laton => const Color(0xFFC58520),
            AcabadoCromo.nacar => const Color(0xFF708E89),
          };
    final marco = colores.borde(acento);
    final papel = colores.superficie(const Color(0xFFFFF4D6));
    final estiloTitulo = TextStyle(
      fontFamily: 'NunitoInicio',
      fontWeight: FontWeight.w900,
      fontSize: 16,
      color: colores.tinta,
      height: 1.1,
    );
    final medidaTitulo = TextPainter(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.merge(estiloTitulo),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    );
    final altoTitulo = 2 * medidaTitulo.preferredLineHeight.ceilToDouble();
    medidaTitulo.dispose();

    return Material(
      color: papel,
      shape: RoundedRectangleBorder(
        borderRadius: radio,
        side: BorderSide(color: marco, width: 2),
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
          border: Border.all(color: marco, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: marco.withValues(alpha: .58)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: conseguida
                          ? IlustracionCromo(ficha, alto: 90)
                          : Semantics(
                              label: context.tr('Por descubrir'),
                              child: Icon(
                                Icons.lock_rounded,
                                size: 58,
                                color: colores.tenue,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: altoTitulo,
                    child: Center(
                      child: Texto(
                        ficha.titulo,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: estiloTitulo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
