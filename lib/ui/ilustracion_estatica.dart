import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Usa el WebP del grupo cuando está incluido en el paquete de recursos.
/// El pintor cubre los dibujos pendientes y el tiempo de decodificación.
class IlustracionEstatica extends StatelessWidget {
  const IlustracionEstatica({
    required this.grupo,
    required this.id,
    required this.respaldo,
    super.key,
  });

  final String grupo;
  final String id;
  final Widget respaldo;

  static final _recursosPorBundle = Expando<Future<Set<String>>>();

  @override
  Widget build(BuildContext context) {
    final bundle = DefaultAssetBundle.of(context);
    final recursos = _recursosPorBundle[bundle] ??=
        AssetManifest.loadFromAssetBundle(bundle)
            .then((manifest) => manifest.listAssets().toSet());
    final ruta = 'assets/ilustraciones/$grupo/$id.webp';

    return FutureBuilder<Set<String>>(
      future: recursos,
      builder: (context, snapshot) {
        if (snapshot.data?.contains(ruta) != true) return respaldo;

        return Image.asset(
          ruta,
          bundle: bundle,
          fit: BoxFit.fill,
          excludeFromSemantics: true,
          frameBuilder: (context, imagen, fotograma, _) =>
              fotograma == null ? respaldo : imagen,
          errorBuilder: (context, error, stackTrace) => respaldo,
        );
      },
    );
  }
}
