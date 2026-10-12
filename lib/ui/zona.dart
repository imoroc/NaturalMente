import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/juego.dart';

class ZonaPage extends StatelessWidget {
  const ZonaPage({required this.zona, super.key});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    final catalogo = Alcance.of(context).catalogo;
    final actividades = catalogo.actividadesDe(zona.id);
    final fichas = catalogo.fichasDe(zona.id);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(zona.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(zona.resumen),
          const SizedBox(height: 16),
          for (final actividad in actividades) ...[
            OutlinedButton(
              key: Key('juego-${actividad.id}'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => JuegoPage(actividad: actividad),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                alignment: Alignment.centerLeft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text('Pensado para ${actividad.curso}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          Text('FICHAS', style: Theme.of(context).textTheme.labelLarge),
          for (final ficha in fichas)
            ExpansionTile(
              title: Text(ficha.titulo),
              subtitle: Text('Pensado para ${ficha.curso}'),
              children: [
                ListTile(title: Text(ficha.frase)),
                ListTile(title: Text(ficha.curiosidad)),
              ],
            ),
        ],
      ),
    );
  }
}
