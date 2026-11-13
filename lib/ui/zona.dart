import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/cromos_zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/digestion.dart';
import 'package:naturalmente/ui/ecosistema.dart';
import 'package:naturalmente/ui/herbario.dart';
import 'package:naturalmente/ui/juego.dart';
import 'package:naturalmente/ui/laboratorio_zona.dart';
import 'package:naturalmente/ui/nacimiento.dart';
import 'package:naturalmente/ui/rescate.dart';
import 'package:naturalmente/ui/adivinanza.dart';
import 'package:naturalmente/ui/memoria.dart';
import 'package:naturalmente/ui/texto.dart';

class ZonaPage extends StatelessWidget {
  const ZonaPage({required this.zona, super.key});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final progreso = alcance.progreso;
    final actividades = catalogo.actividadesDe(zona.id);
    final fichas = catalogo.fichasDe(zona.id);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Texto(zona.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListenableBuilder(
        listenable: progreso,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.coloresNaturales.superficie(
                          Colors.white,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: context.coloresNaturales.borde(
                            const Color(0xFFE2DEC9),
                          ),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.coloresNaturales.sombra(
                              Color(0xFFD6CFC0),
                            ),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          DibujoMascota(
                            gesto: progreso.poseEquipada,
                            tamano: 52,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Texto(
                                  zona.bloque.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                    color: context.coloresNaturales.contenido(
                                      Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Texto(
                                  zona.resumen,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: context.coloresNaturales.contenido(
                                      Color(0xFF334155),
                                    ),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.coloresNaturales.superficie(
                          const Color(0xFFDCFCE7),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.coloresNaturales.borde(
                            const Color(0xFF86EFAC),
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.public_rounded,
                            size: 20,
                            color: context.coloresNaturales.contenido(
                              Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Texto(
                              '1. EXPOSITOR DE BIOMAS EN VIVO',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: context.coloresNaturales.contenido(
                                      const Color(0xFF14532D),
                                    ),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.coloresNaturales.superficie(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Texto(
                              'Toca o arrastra',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: context.coloresNaturales.contenido(
                                  Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    BannerEvolucionZona(zona: zona),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.coloresNaturales.superficie(
                          const Color(0xFFE0F2FE),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.coloresNaturales.borde(
                            const Color(0xFF7DD3FC),
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.videogame_asset_rounded,
                            size: 22,
                            color: context.coloresNaturales.contenido(
                              Color(0xFF0369A1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Texto(
                              'MISIONES DE LA ZONA',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: context.coloresNaturales.contenido(
                                      const Color(0xFF0C4A6E),
                                    ),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.coloresNaturales.superficie(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Texto(
                              'Toca para jugar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: context.coloresNaturales.contenido(
                                  Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final actividad in actividades) ...[
                      _BotonMision(
                        id: actividad.id,
                        titulo: actividad.titulo,
                        curso: actividad.curso,
                        hecha: progreso.actividadHecha(actividad),
                        estrellas: progreso.nivelesSuperadosDe(actividad),
                        maxEstrellas: progreso.maxNivelesDe(actividad),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => switch (actividad.tipo) {
                                'ecosistema' => EcosistemaPage(
                                  actividad: actividad,
                                ),
                                'herbario' => HerbarioPage(
                                  actividad: actividad,
                                ),
                                'nacimiento' => NacimientoPage(
                                  actividad: actividad,
                                ),
                                'viaje' => ViajePage(actividad: actividad),
                                'rescate' => RescatePage(actividad: actividad),
                                'memoria' => MemoriaPage(actividad: actividad),
                                'adivinanza' => AdivinanzaPage(
                                  actividad: actividad,
                                ),
                                _ => JuegoPage(actividad: actividad),
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.coloresNaturales.superficie(
                          const Color(0xFFF3E8FF),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: context.coloresNaturales.borde(
                            const Color(0xFFD8B4FE),
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.science_rounded,
                            size: 20,
                            color: context.coloresNaturales.contenido(
                              Color(0xFF7E22CE),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Texto(
                              '3. LABORATORIO DE EXPERIMENTACIÓN',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: context.coloresNaturales.contenido(
                                      const Color(0xFF581C87),
                                    ),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.coloresNaturales.superficie(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Texto(
                              'Simulador libre',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: context.coloresNaturales.contenido(
                                  Color(0xFF7E22CE),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TarjetaAccesoLaboratorio(zona: zona),
                    const SizedBox(height: 14),
                    ResumenCromosZona(
                      zona: zona,
                      fichas: fichas,
                      progreso: progreso,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BotonMision extends StatelessWidget {
  const _BotonMision({
    required this.id,
    required this.titulo,
    required this.curso,
    required this.hecha,
    required this.estrellas,
    required this.maxEstrellas,
    required this.onTap,
  });

  final String id;
  final String titulo;
  final String curso;
  final bool hecha;
  final int estrellas;
  final int maxEstrellas;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorBorde = hecha
        ? const Color(0xFF2ECC71)
        : const Color(0xFF0284C7);
    final colorSombra = hecha
        ? const Color(0xFF15803D)
        : const Color(0xFF0369A1);

    return TarjetaJuego(
      borde: context.coloresNaturales.borde(colorBorde),
      sombra: context.coloresNaturales.sombra(colorSombra),
      radio: 22,
      claveAccion: Key('juego-$id'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.coloresNaturales.superficie(
                  hecha ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.coloresNaturales.borde(
                    colorBorde.withValues(alpha: 0.5),
                  ),
                  width: 1.8,
                ),
              ),
              child: Icon(
                hecha
                    ? Icons.videogame_asset_rounded
                    : Icons.sports_esports_rounded,
                color: context.coloresNaturales.contenido(colorSombra),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.coloresNaturales.superficie(
                        hecha
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFE0F2FE),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Texto(
                      'JUEGO INTERACTIVO · $curso',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        letterSpacing: 0.3,
                        color: context.coloresNaturales.contenido(colorSombra),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Texto(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.5,
                      color: context.coloresNaturales.contenido(
                        Color(0xFF1B3022),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.coloresNaturales.superficie(
                            estrellas > 0
                                ? const Color(0xFFFEF3C7)
                                : const Color(0xFFF1F5F9),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < maxEstrellas; i++)
                              Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: context.coloresNaturales.contenido(
                                  i < estrellas
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Texto(
                                '$estrellas/$maxEstrellas niveles',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: context.coloresNaturales.contenido(
                                    estrellas > 0
                                        ? const Color(0xFF92400E)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hecha)
                        Texto(
                          '✓ Actividad superada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: context.coloresNaturales.contenido(
                              Color(0xFF15803D),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: context.coloresNaturales.superficie(colorSombra),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Texto(
                    'Jugar',
                    style: TextStyle(
                      color: context.coloresNaturales.contenido(Colors.white),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: context.coloresNaturales.contenido(Colors.white),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TarjetaCromoFicha extends StatelessWidget {
  const TarjetaCromoFicha({
    required this.ficha,
    required this.desbloqueada,
    super.key,
  });

  final Ficha ficha;
  final bool desbloqueada;

  @override
  Widget build(BuildContext context) {
    final colorBorde = desbloqueada
        ? const Color(0xFFF59E0B)
        : const Color(0xFFCBD5E1);
    final colorFondo = desbloqueada ? Colors.white : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: context.coloresNaturales.superficie(colorFondo),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.coloresNaturales.borde(colorBorde),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.coloresNaturales.sombra(
              desbloqueada ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
            ),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: context.coloresNaturales.superficie(Colors.transparent),
        child: InkWell(
          key: Key('cromo-${ficha.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              mostrarDetalleFicha(context, ficha, desbloqueada: desbloqueada),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: context.coloresNaturales.superficie(
                      desbloqueada
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: context.coloresNaturales.borde(
                        desbloqueada
                            ? const Color(0xFFFCD34D)
                            : const Color(0xFFCBD5E1),
                      ),
                      width: 1.8,
                    ),
                  ),
                  child: desbloqueada
                      ? IlustracionFicha(id: ficha.id, alto: 44)
                      : Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: context.coloresNaturales.contenido(
                              Color(0xFF64748B),
                            ),
                            size: 24,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Texto(
                              ficha.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: context.coloresNaturales.contenido(
                                  desbloqueada
                                      ? const Color(0xFF78350F)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: context.coloresNaturales.superficie(
                                desbloqueada
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: context.coloresNaturales.borde(
                                  desbloqueada
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            child: Texto(
                              desbloqueada ? '¡Cromo!' : 'Por descubrir',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: context.coloresNaturales.contenido(
                                  desbloqueada
                                      ? const Color(0xFFB45309)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Texto(
                        desbloqueada
                            ? ficha.frase
                            : Progreso.pistaDesbloqueoFicha(ficha.id),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w600,
                          color: context.coloresNaturales.contenido(
                            desbloqueada
                                ? const Color(0xFF334155)
                                : const Color(0xFF64748B),
                          ),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  desbloqueada
                      ? Icons.menu_book_rounded
                      : Icons.info_outline_rounded,
                  color: context.coloresNaturales.contenido(
                    desbloqueada
                        ? const Color(0xFFD97706)
                        : const Color(0xFF94A3B8),
                  ),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void mostrarDetalleFicha(
  BuildContext context,
  Ficha ficha, {
  required bool desbloqueada,
}) {
  if (desbloqueada) {
    context.sonidoDescubrimiento();
  } else {
    context.sonidoPista();
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.coloresNaturales.superficie(
      const Color(0xFFFDFBF7),
    ),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.coloresNaturales.superficie(
                      desbloqueada
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.coloresNaturales.borde(
                        desbloqueada
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFCBD5E1),
                      ),
                      width: 2,
                    ),
                  ),
                  child: desbloqueada
                      ? IlustracionFicha(id: ficha.id, alto: 54)
                      : Icon(
                          Icons.lock_rounded,
                          size: 34,
                          color: context.coloresNaturales.contenido(
                            Color(0xFF64748B),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Texto(
                        desbloqueada
                            ? 'CROMO DESBLOQUEADO · ${ficha.curso.toUpperCase()}'
                            : 'CROMO POR DESCUBRIR · ${ficha.curso.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: context.coloresNaturales.contenido(
                            desbloqueada
                                ? const Color(0xFF15803D)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Texto(
                        ficha.titulo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (desbloqueada) ...[
              TarjetaFichaEnciclopedica(fichaId: ficha.id),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.coloresNaturales.superficie(Colors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: context.coloresNaturales.borde(
                      const Color(0xFFE2DEC9),
                    ),
                    width: 2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: context.coloresNaturales.contenido(
                        Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Texto(
                        ficha.frase,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.coloresNaturales.contenido(
                            Color(0xFF1E293B),
                          ),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Burbuja(
                quien: 'Dato curioso de Natu',
                frase: ficha.curiosidad,
                gesto: 'feliz',
              ),
            ] else
              Burbuja(
                quien: 'Pista de Natu',
                frase:
                    '¡Aún no tienes este cromo! ${Progreso.pistaDesbloqueoFicha(ficha.id)}',
                gesto: 'pista',
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('cerrar-detalle-ficha'),
              onPressed: () {
                context.sonidoToque();
                Navigator.of(context).pop();
              },
              child: Texto(desbloqueada ? '¡Genial!' : '¡Voy a descubrirlo!'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  String _filtroZona = 'todas';

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final progreso = alcance.progreso;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Texto(
          'Álbum de cromos de Natu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListenableBuilder(
        listenable: progreso,
        builder: (context, _) {
          final todas = catalogo.fichas;
          final desbloqueadasTotal = todas
              .where((f) => progreso.fichaDesbloqueada(f.id))
              .length;
          final fichasVisibles = _filtroZona == 'todas'
              ? todas
              : todas.where((f) => f.zona == _filtroZona).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.coloresNaturales.superficie(
                          const Color(0xFFFFFBEB),
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: context.coloresNaturales.borde(
                            const Color(0xFFF59E0B),
                          ),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.coloresNaturales.sombra(
                              Color(0xFFD97706),
                            ),
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const ExcludeSemantics(
                                child: DibujoMascota(
                                  gesto: 'feliz',
                                  tamano: 52,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Texto(
                                      'Cromos conseguidos: $desbloqueadasTotal de ${todas.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: context.coloresNaturales
                                                .contenido(
                                                  const Color(0xFF78350F),
                                                ),
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Texto(
                                      'Supera los niveles Fácil, Medio y Difícil de cada juego para completar toda la colección.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.3,
                                        fontWeight: FontWeight.w700,
                                        color: context.coloresNaturales
                                            .contenido(Color(0xFF92400E)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: context.coloresNaturales.superficie(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: context.coloresNaturales.borde(
                                  const Color(0xFFFCD34D),
                                ),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: todas.isEmpty
                                    ? 0
                                    : desbloqueadasTotal / todas.length,
                                minHeight: 9,
                                backgroundColor: context.coloresNaturales
                                    .superficie(const Color(0xFFFEF3C7)),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FiltroAlbumChip(
                            etiqueta: 'Todos (${todas.length})',
                            activo: _filtroZona == 'todas',
                            alTocar: () =>
                                setState(() => _filtroZona = 'todas'),
                          ),
                          const SizedBox(width: 8),
                          for (final z in catalogo.zonas) ...[
                            _FiltroAlbumChip(
                              etiqueta: z.bloque,
                              activo: _filtroZona == z.id,
                              alTocar: () => setState(() => _filtroZona = z.id),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final ficha in fichasVisibles) ...[
                      TarjetaCromoFicha(
                        ficha: ficha,
                        desbloqueada: progreso.fichaDesbloqueada(ficha.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FiltroAlbumChip extends StatelessWidget {
  const _FiltroAlbumChip({
    required this.etiqueta,
    required this.activo,
    required this.alTocar,
  });

  final String etiqueta;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Texto(
        etiqueta,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: context.coloresNaturales.contenido(
            activo ? Colors.white : const Color(0xFF78350F),
          ),
        ),
      ),
      selected: activo,
      selectedColor: context.coloresNaturales.contenido(
        const Color(0xFFD97706),
      ),
      backgroundColor: context.coloresNaturales.superficie(
        const Color(0xFFFFFBEB),
      ),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: context.coloresNaturales.borde(
          activo ? const Color(0xFFB45309) : const Color(0xFFFCD34D),
        ),
        width: 1.5,
      ),
      onSelected: (_) {
        context.sonidoSeleccion();
        alTocar();
      },
    );
  }
}
