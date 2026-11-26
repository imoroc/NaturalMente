import 'package:flutter/material.dart';

import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/panel/repositorio_panel.dart';
import 'package:naturalmente/ui/dibujos.dart';

/// Quién ha jugado, cómo le ha ido y qué preguntas cuestan más.
class ResultadosPage extends StatefulWidget {
  const ResultadosPage({
    required this.repositorio,
    required this.juego,
    super.key,
  });

  final RepositorioPanel repositorio;
  final JuegoAula juego;

  @override
  State<ResultadosPage> createState() => _ResultadosPageState();
}

class _ResultadosPageState extends State<ResultadosPage> {
  late final Future<List<PartidaPanel>> _partidas = widget.repositorio.partidas(
    widget.juego.id,
  );

  @override
  Widget build(BuildContext context) {
    final juego = widget.juego;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF5EC),
        title: Text('Resultados · ${juego.titulo}'),
      ),
      body: FutureBuilder<List<PartidaPanel>>(
        future: _partidas,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('No se han podido cargar los resultados.'),
            );
          }
          final partidas = snapshot.data;
          if (partidas == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (partidas.isEmpty) {
            return const Center(
              key: Key('resultados-vacio'),
              child: Text(
                'Todavía no ha jugado nadie a este juego.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          final resumen = ResumenResultados.calcular(partidas, juego);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _Dato(
                            'Niños que han jugado',
                            '${resumen.porPerfil.length}',
                          ),
                          _Dato('Partidas', '${partidas.length}'),
                          _Dato(
                            'Aciertos a la primera (media)',
                            '${resumen.mediaPorcentaje}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Preguntas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Porcentaje de niños que la aciertan a la primera, en la versión actual.',
                      ),
                      const SizedBox(height: 10),
                      for (final (i, reto) in juego.evaluables.indexed)
                        _BarraPregunta(
                          numero: i + 1,
                          enunciado: reto.enunciado.isNotEmpty
                              ? reto.enunciado
                              : reto.tipo.nombre,
                          porcentaje: resumen.porPregunta[i],
                        ),
                      const SizedBox(height: 28),
                      const Text(
                        'Niños',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        child: Column(
                          children: [
                            for (final fila in resumen.porPerfil)
                              ListTile(
                                leading: DibujoMascota(
                                  tamano: 40,
                                  traje: 'ninguno',
                                  colorPanuelo: fila.perfil.colorPanuelo,
                                ),
                                title: Text(fila.perfil.mote('es')),
                                subtitle: Text(
                                  '${fila.partidas} ${fila.partidas == 1 ? 'partida' : 'partidas'} · '
                                  'última el ${fila.ultima.day}/${fila.ultima.month} a las '
                                  '${fila.ultima.hour}:${fila.ultima.minute.toString().padLeft(2, '0')}',
                                ),
                                trailing: Text(
                                  'Mejor: ${fila.mejor}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Los niños aparecen con su mote de la app: NaturalMente no guarda sus nombres.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Cálculos del panel de resultados, separados para poder probarlos.
class ResumenResultados {
  const ResumenResultados({
    required this.porPerfil,
    required this.porPregunta,
    required this.mediaPorcentaje,
  });

  final List<FilaPerfil> porPerfil;

  /// Por pregunta de la versión actual: % de primeras partidas que la
  /// aciertan a la primera, o `null` si nadie la ha jugado aún.
  final List<int?> porPregunta;
  final int mediaPorcentaje;

  static ResumenResultados calcular(
    List<PartidaPanel> partidas,
    JuegoAula juego,
  ) {
    final perfiles = <String, List<PartidaPanel>>{};
    for (final p in partidas) {
      (perfiles[p.perfilId] ??= []).add(p);
    }
    final filas = [
      for (final MapEntry(value: lista) in perfiles.entries)
        FilaPerfil(
          perfil: lista.first.perfil,
          partidas: lista.length,
          mejor: lista
              .map((p) => (p.aciertos * 100 / p.total).round())
              .reduce((a, b) => a > b ? a : b),
          ultima: lista
              .map((p) => p.jugado)
              .reduce((a, b) => a.isAfter(b) ? a : b),
        ),
    ]..sort((a, b) => b.mejor.compareTo(a.mejor));

    // La primera partida de cada niño con la versión actual: es la que dice
    // qué sabía, antes de aprenderse las respuestas.
    final primeras = [
      for (final lista in perfiles.values)
        ?(lista.where((p) => p.version == juego.version).toList()
              ..sort((a, b) => a.jugado.compareTo(b.jugado)))
            .firstOrNull,
    ];
    final porPregunta = [
      // Los resultados guardan un acierto por reto puntuable, en orden.
      for (var i = 0; i < juego.evaluables.length; i++)
        () {
          final respuestas = [
            for (final p in primeras)
              if (i < p.respuestas.length) p.respuestas[i],
          ];
          if (respuestas.isEmpty) return null;
          return (respuestas.where((r) => r).length * 100 / respuestas.length)
              .round();
        }(),
    ];
    final media = partidas.isEmpty
        ? 0
        : (partidas
                      .map((p) => p.aciertos * 100 / p.total)
                      .reduce((a, b) => a + b) /
                  partidas.length)
              .round();
    return ResumenResultados(
      porPerfil: filas,
      porPregunta: porPregunta,
      mediaPorcentaje: media,
    );
  }
}

class FilaPerfil {
  const FilaPerfil({
    required this.perfil,
    required this.partidas,
    required this.mejor,
    required this.ultima,
  });

  final Perfil perfil;
  final int partidas;
  final int mejor;
  final DateTime ultima;
}

class _Dato extends StatelessWidget {
  const _Dato(this.titulo, this.valor);
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 260,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo),
            Text(
              valor,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BarraPregunta extends StatelessWidget {
  const _BarraPregunta({
    required this.numero,
    required this.enunciado,
    required this.porcentaje,
  });

  final int numero;
  final String enunciado;
  final int? porcentaje;

  @override
  Widget build(BuildContext context) {
    final valor = porcentaje;
    final color = valor == null
        ? Colors.grey
        : valor >= 70
        ? const Color(0xFF16A34A)
        : valor >= 40
        ? const Color(0xFFF59E0B)
        : const Color(0xFFDC2626);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$numero. $enunciado'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: (valor ?? 0) / 100,
                    minHeight: 14,
                    color: color,
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 64,
                child: Text(
                  valor == null ? 'Sin datos' : '$valor%',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
