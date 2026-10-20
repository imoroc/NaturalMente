import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';

class SelectorIdioma extends StatelessWidget {
  const SelectorIdioma({super.key});

  @override
  Widget build(BuildContext context) {
    final idioma = IdiomaScope.of(context);
    if (idioma == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PopupMenuButton<String>(
        key: const Key('selector-idioma'),
        tooltip: context.traducir('Elegir idioma'),
        initialValue: idioma.codigo,
        position: PopupMenuPosition.under,
        color: const Color(0xFFFFFDF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF2ECC71), width: 2),
        ),
        onSelected: (codigo) async {
          final guardado = await idioma.elegir(codigo);
          if (!guardado && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.traducir(
                    'No se ha podido guardar el idioma. Inténtalo de nuevo.',
                  ),
                ),
              ),
            );
          }
        },
        itemBuilder: (context) => [
          for (final opcion in const [('es', 'Español'), ('en', 'English')])
            CheckedPopupMenuItem<String>(
              key: Key('idioma-${opcion.$1}'),
              value: opcion.$1,
              checked: idioma.codigo == opcion.$1,
              child: Text(opcion.$2),
            ),
        ],
        child: Container(
          constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2ECC71), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.translate_rounded,
                color: Color(0xFF15803D),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                idioma.codigo.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
