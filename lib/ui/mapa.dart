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
            final conseguida = alcance.progreso.medallaConseguida(
              alcance.catalogo.actividades,
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              children: [
                _CabeceraBrote(conseguida: conseguida),
                const SizedBox(height: 16),
                for (final zona in alcance.catalogo.zonas) ...[
                  _ZonaTarjeta(zona: zona),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                _Medalla(conseguida: conseguida),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CabeceraBrote extends StatelessWidget {
  const _CabeceraBrote({required this.conseguida});

  final bool conseguida;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5DFCF), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD6CFC0),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          DibujoMascota(
            gesto: conseguida ? 'feliz' : 'hola',
            tamano: 60,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NaturalMente',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Elige por dónde empezar. No hay un orden.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
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
    final actividades = alcance.catalogo.actividadesDe(zona.id);
    final hechas = actividades.where(alcance.progreso.actividadHecha).length;
    final estilo = _estiloZona(zona.id);

    return Container(
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(24),
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
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => ZonaPage(zona: zona)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                                color: Colors.white.withValues(alpha: 0.85),
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
                              color: hechas == actividades.length && actividades.isNotEmpty
                                  ? const Color(0xFF2ECC71)
                                  : Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$hechas/${actividades.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: hechas == actividades.length && actividades.isNotEmpty
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
                      const SizedBox(height: 4),
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
          ),
        ),
      ),
    );
  }
}

class _Medalla extends StatelessWidget {
  const _Medalla({required this.conseguida});

  final bool conseguida;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: conseguida ? const Color(0xFFFFF8DB) : const Color(0xFF1E3A2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: conseguida ? const Color(0xFFFFB703) : const Color(0xFF14281E),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: conseguida ? const Color(0xFFD99000) : const Color(0xFF0E1D15),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: conseguida ? const Color(0xFFFFB703) : const Color(0xFF2D5240),
              shape: BoxShape.circle,
            ),
            child: Icon(
              conseguida ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conseguida ? 'Explorador NaturalMente' : 'Medalla por conseguir',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: conseguida
                        ? const Color(0xFF92400E)
                        : const Color(0xFFF6F1E6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  conseguida
                      ? 'Has llevado los animales a su sitio, has hecho brotar la judía y has colocado las piezas del cuerpo.'
                      : 'Se consigue al terminar el hogar de los animales, la germinación y las piezas del cuerpo.',
                  style: TextStyle(
                    color: conseguida
                        ? const Color(0xFF78350F)
                        : const Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
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
