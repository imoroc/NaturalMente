import 'package:flutter/material.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/hogar.dart';
import 'package:naturalmente/ui/sin_juego.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({required this.zonas, super.key});

  final List<Zona> zonas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('NaturalMente', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            const Text('Elige por dónde empezar. No hay un orden.'),
            const SizedBox(height: 16),
            for (final zona in zonas) ...[
              _ZonaTarjeta(zona: zona),
              const SizedBox(height: 10),
            ],
          ],
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
          final pagina = zona.id == 'reserva'
              ? const HogarPage()
              : SinJuegoPage(zona: zona);
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => pagina),
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
