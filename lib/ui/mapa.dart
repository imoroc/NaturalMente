import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/zona.dart';
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Text(
                  'NaturalMente',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text('Elige por dónde empezar. No hay un orden.'),
                const SizedBox(height: 16),
                for (final zona in alcance.catalogo.zonas) ...[
                  _ZonaTarjeta(zona: zona),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                _Medalla(conseguida: conseguida),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ZonaTarjeta extends StatelessWidget {
  const _ZonaTarjeta({required this.zona});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _color(zona.id),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: Key('zona-${zona.id}'),
        borderRadius: BorderRadius.circular(16),
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
              Text(zona.nombre, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(zona.bloque, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(zona.resumen),
            ],
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
    return Card(
      color: const Color(0xFF1E3A2C),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conseguida ? 'Explorador NaturalMente' : 'Medalla por conseguir',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFF6F1E6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              conseguida
                  ? 'Has llevado los animales a su sitio, has hecho brotar la judía y has colocado las piezas del cuerpo.'
                  : 'Se consigue al terminar el hogar de los animales, la germinación y las piezas del cuerpo.',
              style: const TextStyle(color: Color(0xFFF6F1E6), height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

Color _color(String id) {
  switch (id) {
    case 'reserva':
      return const Color(0xFFE5F4EA);
    case 'invernadero':
      return const Color(0xFFFFF3E6);
    case 'cuerpo':
      return const Color(0xFFE7F4F8);
    default:
      return const Color(0xFFF6F1E6);
  }
}
