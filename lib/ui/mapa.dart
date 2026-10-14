import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/zona.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: alcance.progreso,
          builder: (context, _) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CabeceraNatu(),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.public_rounded,
                              size: 20,
                              color: Color(0xFF15803D),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'MUNDOS PARA EXPLORAR',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final zona in alcance.catalogo.zonas) ...[
                        _ZonaTarjeta(zona: zona),
                        const SizedBox(height: 14),
                      ],
                      const _TarjetaAlbumPrincipal(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CabeceraNatu extends StatelessWidget {
  const _CabeceraNatu();

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final progreso = alcance.progreso;

    final totalMisiones = catalogo.actividades.length;
    final misionesHechas = catalogo.actividades
        .where(progreso.actividadHecha)
        .length;
    final estrellas = progreso.totalNivelesSuperados(catalogo.actividades);
    final maxEstrellas = progreso.totalMaxNiveles(catalogo.actividades);
    final totalCromos = catalogo.fichas.length;
    final cromos = catalogo.fichas
        .where((f) => progreso.fichaDesbloqueada(f.id))
        .length;
    final albumCompleto = totalCromos > 0 && cromos == totalCromos;

    final String rango;
    final String saludo;
    if (albumCompleto) {
      rango = 'GUARDIÁN DE LA NATURALEZA';
      saludo =
          '¡Increíble! Has completado todos los cromos del álbum de Natu.';
    } else if (estrellas > 0 || cromos > 0) {
      rango = 'EXPLORADOR EN RUTA';
      saludo =
          '¡Vas genial! Elige cualquier mundo para seguir sumando estrellas y cromos a tu álbum.';
    } else {
      rango = 'CUADERNO DE CAMPO DE NATU';
      saludo = 'Elige por dónde empezar. No hay un orden.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF5FBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF86EFAC), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF4ADE80),
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF86EFAC),
                    width: 2,
                  ),
                ),
                child: DibujoMascota(
                  gesto: albumCompleto ? 'feliz' : 'hola',
                  tamano: 64,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rango,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NaturalMente',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      saludo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InsigniaResumen(
                    icono: Icons.star_rounded,
                    colorIcono: const Color(0xFFF59E0B),
                    colorFondo: const Color(0xFFFFFBEB),
                    valor: '$estrellas/$maxEstrellas',
                    etiqueta: 'Estrellas',
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 32,
                  color: const Color(0xFFE2E8F0),
                ),
                Expanded(
                  child: _InsigniaResumen(
                    icono: Icons.flag_rounded,
                    colorIcono: const Color(0xFF16A34A),
                    colorFondo: const Color(0xFFF0FDF4),
                    valor: '$misionesHechas/$totalMisiones',
                    etiqueta: 'Misiones',
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 32,
                  color: const Color(0xFFE2E8F0),
                ),
                Expanded(
                  child: InkWell(
                    key: const Key('abrir-album'),
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _mostrarAlbumCompleto(context),
                    child: _InsigniaResumen(
                      icono: Icons.auto_stories_rounded,
                      colorIcono: const Color(0xFF0284C7),
                      colorFondo: const Color(0xFFF0F9FF),
                      valor: '$cromos/$totalCromos',
                      etiqueta: 'Ver álbum',
                      destacado: true,
                    ),
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

class _InsigniaResumen extends StatelessWidget {
  const _InsigniaResumen({
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.valor,
    required this.etiqueta,
    this.destacado = false,
  });

  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String valor;
  final String etiqueta;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorFondo,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: colorIcono, size: 19),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: destacado
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF64748B),
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

class _ZonaTarjeta extends StatelessWidget {
  const _ZonaTarjeta({required this.zona});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final progreso = alcance.progreso;
    final actividades = catalogo.actividadesDe(zona.id);
    final hechas = actividades.where(progreso.actividadHecha).length;
    final estrellasZona = actividades.fold<int>(
      0,
      (acc, a) => acc + progreso.nivelesSuperadosDe(a),
    );
    final maxEstrellasZona = actividades.fold<int>(
      0,
      (acc, a) => acc + progreso.maxNivelesDe(a),
    );
    final fichasZona = catalogo.fichasDe(zona.id);
    final cromosZona = fichasZona
        .where((f) => progreso.fichaDesbloqueada(f.id))
        .length;
    final estilo = _estiloZona(zona.id);
    final muestras = _muestrasZona(zona.id);

    return Container(
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: estilo.borde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: estilo.sombra,
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('zona-${zona.id}'),
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => ZonaPage(zona: zona)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: estilo.borde, width: 2),
                      ),
                      child: Icon(estilo.icono, color: estilo.acento, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    zona.bloque,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: estilo.acento,
                                    ),
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
                                  color:
                                      hechas == actividades.length &&
                                          actividades.isNotEmpty
                                      ? const Color(0xFF2ECC71)
                                      : Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$hechas/${actividades.length}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color:
                                        hechas == actividades.length &&
                                            actividades.isNotEmpty
                                        ? Colors.white
                                        : estilo.acento,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            zona.nombre,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            zona.resumen,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: estilo.borde.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final idMuestra in muestras) ...[
                            Container(
                              width: 34,
                              height: 34,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: estilo.borde.withValues(alpha: 0.5),
                                ),
                              ),
                              child: IlustracionFicha(id: idMuestra, alto: 26),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$estrellasZona/$maxEstrellasZona',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.style_rounded,
                            size: 15,
                            color: estilo.acento,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$cromosZona/${fichasZona.length} cromos',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: estilo.acento,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explorar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _mostrarAlbumCompleto(BuildContext context) {
  final alcance = Alcance.of(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: const Color(0xFFF6F1E6),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) => ListenableBuilder(
        listenable: alcance.progreso,
        builder: (context, _) {
          final total = alcance.catalogo.fichas.length;
          final desbloqueadas = alcance.catalogo.fichas
              .where((f) => alcance.progreso.fichaDesbloqueada(f.id))
              .length;
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
            children: [
              Row(
                children: [
                  const DibujoMascota(gesto: 'feliz', tamano: 52),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Álbum de cromos de Natu',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Has descubierto $desbloqueadas de $total cromos naturales.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final zona in alcance.catalogo.zonas) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 8),
                  child: Text(
                    '${zona.nombre.toUpperCase()} · ${zona.bloque.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
                for (final ficha in alcance.catalogo.fichasDe(zona.id)) ...[
                  TarjetaCromoFicha(
                    ficha: ficha,
                    desbloqueada: alcance.progreso.fichaDesbloqueada(ficha.id),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
    ),
  );
}

List<String> _muestrasZona(String id) {
  switch (id) {
    case 'reserva':
      return const ['camello', 'delfin', 'tucan'];
    case 'invernadero':
      return const ['semilla', 'flor', 'fruto'];
    case 'cuerpo':
      return const ['cerebro', 'corazon', 'pulmones'];
    default:
      return const [];
  }
}

class _EstiloZona {
  const _EstiloZona({
    required this.fondo,
    required this.borde,
    required this.sombra,
    required this.acento,
    required this.icono,
  });

  final Color fondo;
  final Color borde;
  final Color sombra;
  final Color acento;
  final IconData icono;
}

_EstiloZona _estiloZona(String id) {
  switch (id) {
    case 'reserva':
      return const _EstiloZona(
        fondo: Color(0xFFE8F8EE),
        borde: Color(0xFF2ECC71),
        sombra: Color(0xFF239E56),
        acento: Color(0xFF15803D),
        icono: Icons.pets_rounded,
      );
    case 'invernadero':
      return const _EstiloZona(
        fondo: Color(0xFFFFF5E5),
        borde: Color(0xFFFF9F1C),
        sombra: Color(0xFFD97706),
        acento: Color(0xFFB45309),
        icono: Icons.local_florist_rounded,
      );
    case 'cuerpo':
      return const _EstiloZona(
        fondo: Color(0xFFE8F4FD),
        borde: Color(0xFF38BDF8),
        sombra: Color(0xFF0284C7),
        acento: Color(0xFF0369A1),
        icono: Icons.accessibility_new_rounded,
      );
    default:
      return const _EstiloZona(
        fondo: Color(0xFFF6F1E6),
        borde: Color(0xFFD6CFC0),
        sombra: Color(0xFFB8B0A0),
        acento: Color(0xFF334155),
        icono: Icons.explore_rounded,
      );
  }
}

class _TarjetaAlbumPrincipal extends StatelessWidget {
  const _TarjetaAlbumPrincipal();

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final progreso = alcance.progreso;
    final total = catalogo.fichas.length;
    final desbloqueados = catalogo.fichas
        .where((f) => progreso.fichaDesbloqueada(f.id))
        .length;
    final fraccion = total == 0 ? 0.0 : desbloqueados / total;

    return Material(
      color: const Color(0xFFF5F3FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFA855F7), width: 2.5),
      ),
      child: InkWell(
        key: const Key('tarjeta-album-principal'),
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AlbumPage()));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF9333EA),
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
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFC084FC),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFF7E22CE),
                      size: 28,
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
                              child: Text(
                                'Álbum de cromos de Natu',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: const Color(0xFF4C1D95),
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7E22CE),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$desbloqueados/$total',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Colecciona animales, plantas y órganos en Fácil, Medio y Difícil y lee sus curiosidades.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B21B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF7E22CE),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: fraccion,
                  minHeight: 8,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF9333EA),
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

