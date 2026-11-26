import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Acción con borde y relieve, compartida por los resultados y los cromos.
class AccionNatu extends StatelessWidget {
  const AccionNatu({
    this.arte,
    this.icono,
    required this.titulo,
    this.fondo = const Color(0xFFE5F5D8),
    this.borde = const Color(0xFF24A85D),
    required this.onTap,
    this.detalle,
    super.key,
  }) : assert((arte == null) != (icono == null));

  final String? arte;
  final IconData? icono;
  final String titulo;
  final String? detalle;
  final Color fondo;
  final Color borde;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final radio = BorderRadius.circular(19);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.sombra(borde),
        borderRadius: radio,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Material(
          color: colores.superficie(fondo),
          shape: RoundedRectangleBorder(
            borderRadius: radio,
            side: BorderSide(color: colores.borde(borde), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Opacity(
              opacity: onTap == null ? .55 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    if (arte case final String nombre)
                      Image.asset(
                        'assets/cromos/$nombre.webp',
                        width: 62,
                        height: 49,
                        excludeFromSemantics: true,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox.square(
                          dimension: 42,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colores.tarjeta,
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: colores.borde(borde)),
                            ),
                            child: Icon(
                              icono,
                              color: colores.contenido(borde),
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Texto(
                            titulo,
                            style: TextStyle(
                              fontFamily: 'NunitoInicio',
                              color: colores.tinta,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          if (detalle case final nivel?)
                            Texto(
                              nivel,
                              style: TextStyle(color: colores.tenue),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
