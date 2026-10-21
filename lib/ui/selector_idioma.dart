import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/texto.dart';

class SelectorIdioma extends StatelessWidget {
  const SelectorIdioma({super.key});

  PopupMenuItem<String> _itemAjusteInterruptor({
    required Key key,
    required String valor,
    required Idioma idioma,
    required bool Function(Idioma) leerActivo,
    required IconData iconoActivo,
    required IconData iconoInactivo,
    required String titulo,
    required String etiquetaActivo,
    required String etiquetaInactivo,
  }) {
    return PopupMenuItem<String>(
      key: key,
      value: valor,
      child: ListenableBuilder(
        listenable: idioma,
        builder: (context, _) {
          final activo = leerActivo(idioma);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: activo
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: activo
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  activo ? iconoActivo : iconoInactivo,
                  size: 20,
                  color: activo
                      ? const Color(0xFF15803D)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Texto(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: activo
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF94A3B8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Texto(
                    activo ? etiquetaActivo : etiquetaInactivo,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idioma = IdiomaScope.of(context);
    if (idioma == null) return const SizedBox.shrink();
    final sonidoActivo = idioma.sonido;
    final musicaActiva = idioma.musica;

    return PopupMenuButton<String>(
      key: const Key('selector-idioma'),
      tooltip: context.traducir('Ajustes de sonido e idioma'),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      color: const Color(0xFFFFFDF7),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFF2ECC71), width: 2.5),
      ),
      onOpened: () => context.sonidoToque(),
      onSelected: (valor) async {
        if (valor == 'sonido') {
          await idioma.cambiarSonido(!idioma.sonido);
          return;
        }
        if (valor == 'musica') {
          await idioma.cambiarMusica(!idioma.musica);
          return;
        }
        if (valor == 'vibracion') {
          await idioma.cambiarVibracion(!idioma.vibracion);
          return;
        }
        final guardado = await idioma.elegir(valor);
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
        PopupMenuItem<String>(
          enabled: false,
          height: 36,
          child: Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 18,
                color: Color(0xFF15803D),
              ),
              const SizedBox(width: 8),
              Texto(
                'AJUSTES DE NATU',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),
        _itemAjusteInterruptor(
          key: const Key('ajuste-sonido'),
          valor: 'sonido',
          idioma: idioma,
          leerActivo: (i) => i.sonido,
          iconoActivo: Icons.volume_up_rounded,
          iconoInactivo: Icons.volume_off_rounded,
          titulo: 'Efectos de sonido',
          etiquetaActivo: 'Activado',
          etiquetaInactivo: 'Silenciado',
        ),
        _itemAjusteInterruptor(
          key: const Key('ajuste-musica'),
          valor: 'musica',
          idioma: idioma,
          leerActivo: (i) => i.musica,
          iconoActivo: Icons.music_note_rounded,
          iconoInactivo: Icons.music_off_rounded,
          titulo: 'Música de fondo',
          etiquetaActivo: 'Activada',
          etiquetaInactivo: 'Desactivada',
        ),
        _itemAjusteInterruptor(
          key: const Key('ajuste-vibracion'),
          valor: 'vibracion',
          idioma: idioma,
          leerActivo: (i) => i.vibracion,
          iconoActivo: Icons.vibration_rounded,
          iconoInactivo: Icons.smartphone_rounded,
          titulo: 'Vibración al tocar',
          etiquetaActivo: 'Activada',
          etiquetaInactivo: 'Desactivada',
        ),
        const PopupMenuDivider(height: 12),
        PopupMenuItem<String>(
          enabled: false,
          height: 28,
          child: Row(
            children: [
              const Icon(
                Icons.translate_rounded,
                size: 16,
                color: Color(0xFF475569),
              ),
              const SizedBox(width: 6),
              Texto(
                'Elegir idioma',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
        for (final opcion in const [('es', 'Español'), ('en', 'English')])
          CheckedPopupMenuItem<String>(
            key: Key('idioma-${opcion.$1}'),
            value: opcion.$1,
            checked: idioma.codigo == opcion.$1,
            child: Text(
              opcion.$2,
              style: TextStyle(
                fontWeight: idioma.codigo == opcion.$1
                    ? FontWeight.w900
                    : FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
      ],
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2ECC71), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF86EFAC),
              offset: Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.settings_rounded,
              color: Color(0xFF15803D),
              size: 18,
            ),
            const SizedBox(width: 5),
            Icon(
              sonidoActivo
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: sonidoActivo
                  ? const Color(0xFF15803D)
                  : const Color(0xFF64748B),
              size: 16,
            ),
            if (musicaActiva) ...[
              const SizedBox(width: 3),
              const Icon(
                Icons.music_note_rounded,
                color: Color(0xFF15803D),
                size: 15,
              ),
            ],
            const SizedBox(width: 4),
            Text(
              idioma.codigo.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF15803D),
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
