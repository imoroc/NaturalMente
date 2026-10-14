import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/herbario.dart';
import 'package:naturalmente/reglas/herbario.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/planta.dart';

class HerbarioPage extends StatefulWidget {
  const HerbarioPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<HerbarioPage> createState() => _HerbarioPageState();
}

class _HerbarioPageState extends State<HerbarioPage> {
  PartidaHerbario? _partida;
  bool _guardando = false;
  bool _guardado = false;
  bool _falloGuardado = false;

  Herbario get _herbario => widget.actividad.herbario!;

  void _empezar(NivelHerbario nivel) {
    setState(() {
      _partida = PartidaHerbario(herbario: _herbario, nivel: nivel);
      _guardado = false;
      _falloGuardado = false;
    });
  }

  void _colocar(String pieza, String destino) {
    final partida = _partida!;
    setState(() => partida.colocar(pieza, destino));
    _guardarSiCompleta();
  }

  void _responder(String parte, String opcion) {
    if (_partida!.preguntaActual != parte) return;
    setState(() => _partida!.responder(opcion));
    _guardarSiCompleta();
  }

  Future<void> _guardarSiCompleta() async {
    final partida = _partida!;
    if (!partida.completa || _guardando || _guardado) return;
    final progreso = Alcance.of(context).progreso;
    setState(() {
      _guardando = true;
      _falloGuardado = false;
    });
    try {
      await progreso.marcarNivelHerbario(widget.actividad, partida.nivel.id);
      if (mounted) setState(() => _guardado = true);
    } catch (_) {
      if (mounted) setState(() => _falloGuardado = true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _consultar(String id) {
    final partida = _partida!;
    if (!partida.puedeConsultar(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero descubre para qué sirve esta parte.'),
        ),
      );
      return;
    }
    final parte = _herbario.parte(id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parte.nombre,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(parte.funcion),
              const SizedBox(height: 12),
              Text(parte.curiosidad),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('cerrar-ficha'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Seguir jugando'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partida = _partida;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.actividad.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: partida == null
                    ? _selector()
                    : _juego(partida, math.min(constraints.maxWidth - 32, 780)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selector() {
    final progreso = Alcance.of(context).progreso;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Elige un nivel',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Puedes jugar a cualquiera y cambiar cuando quieras.'),
          const SizedBox(height: 16),
          for (final nivel in _herbario.niveles) ...[
            OutlinedButton(
              key: Key('nivel-${nivel.id}'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(72),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () => _empezar(nivel),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nivel.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Pensado para ${nivel.curso}'),
                  Text(
                    nivel.preguntaFunciones
                        ? 'Cinco rótulos y sus funciones'
                        : '${nivel.partes.length == 3 ? 'Tres' : 'Cinco'} partes con dibujo',
                  ),
                  if (progreso.nivelHerbarioHecho(widget.actividad, nivel.id))
                    const Text('✓ Nivel superado'),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _juego(PartidaHerbario partida, double ancho) {
    final nivel = partida.nivel;
    final idPregunta = partida.preguntaActual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${nivel.nombre} · Pensado para ${nivel.curso}. Puedes jugarlo igual.',
        ),
        const SizedBox(height: 8),
        Text(widget.actividad.intro),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            'Partes colocadas: ${partida.colocadas.length} de ${nivel.partes.length}',
          ),
        ),
        if (nivel.preguntaFunciones)
          Text(
            'Funciones descubiertas: ${partida.funcionesAcertadas} de ${nivel.partes.length}',
          ),
        const SizedBox(height: 12),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(300, math.min(440, ancho)),
              child: PlantaHerbario(
                nombres: {
                  for (final id in nivel.partes) id: _herbario.parte(id).nombre,
                },
                colocadas: partida.colocadas,
                seleccionada: partida.seleccionada,
                onColocar: _colocar,
                onConsultar: _consultar,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!partida.colocacionTerminada) ...[
          Text(
            partida.seleccionada == null
                ? 'Elige una pieza y toca su sitio, o arrástrala.'
                : 'Seleccionada: ${_herbario.parte(partida.seleccionada!).nombre}. Toca su sitio.',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in nivel.partes)
                if (!partida.colocadas.contains(id))
                  _pieza(_herbario.parte(id), partida),
            ],
          ),
        ] else if (!partida.completa)
          const Text(
            'Las piezas están colocadas. Ahora descubre sus funciones.',
          ),
        if (partida.resultado != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Burbuja(
              quien: widget.actividad.quien,
              frase: partida.resultado!.frase,
              gesto: partida.resultado!.gesto,
            ),
          ),
        ],
        if (idPregunta != null) ...[
          const SizedBox(height: 16),
          Text(
            _herbario.parte(idPregunta).pregunta.enunciado,
            key: Key('pregunta-$idPregunta'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (final opcion
              in _herbario.parte(idPregunta).pregunta.opciones) ...[
            OutlinedButton(
              key: Key('funcion-$idPregunta-${opcion.id}'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              onPressed: () => _responder(idPregunta, opcion.id),
              child: Text(opcion.nombre),
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (partida.colocadas.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Consulta las partes que has descubierto:'),
          Wrap(
            spacing: 8,
            children: [
              for (final id in nivel.partes)
                if (partida.puedeConsultar(id))
                  TextButton.icon(
                    key: Key('ficha-$id'),
                    onPressed: () => _consultar(id),
                    icon: const Icon(Icons.info_outline),
                    label: Text(_herbario.parte(id).nombre),
                  ),
            ],
          ),
        ],
        if (partida.completa) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              '¡Has completado el herbario!',
              key: const Key('herbario-completo'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          if (_guardando) const Text('Guardando tu progreso…'),
          if (_guardado)
            const Text('Nivel superado y guardado en este dispositivo.'),
          if (_falloGuardado) ...[
            const Text(
              'No he podido guardar tu progreso. Puedes intentarlo otra vez.',
            ),
            TextButton(
              onPressed: _guardarSiCompleta,
              child: const Text('Guardar de nuevo'),
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('herbario-otra-vez'),
            onPressed: _guardando ? null : () => _empezar(nivel),
            child: const Text('Otra vez'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('herbario-cambiar-nivel'),
          onPressed: _guardando ? null : () => setState(() => _partida = null),
          child: const Text('Cambiar nivel'),
        ),
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('Volver al invernadero'),
        ),
      ],
    );
  }

  Widget _pieza(PartePlanta parte, PartidaHerbario partida) {
    final seleccionada = partida.seleccionada == parte.id;
    final rotulo = partida.nivel.preguntaFunciones;
    Widget contenido() => ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!rotulo) ...[
              IconoParte(id: parte.id, size: 32),
              const SizedBox(width: 8),
            ],
            Text(parte.nombre),
            if (seleccionada) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, size: 20),
            ],
          ],
        ),
      ),
    );
    return Draggable<String>(
      data: parte.id,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(16),
        child: contenido(),
      ),
      childWhenDragging: Opacity(opacity: .35, child: contenido()),
      child: Semantics(
        selected: seleccionada,
        label: 'Pieza ${parte.nombre}',
        child: Material(
          color: seleccionada
              ? Theme.of(context).colorScheme.primaryContainer
              : const Color(0xFFFFF6E8),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: Key('pieza-${parte.id}'),
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => partida.seleccionar(parte.id)),
            child: contenido(),
          ),
        ),
      ),
    );
  }
}
