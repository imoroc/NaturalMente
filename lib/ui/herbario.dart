import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/herbario.dart';
import 'package:naturalmente/reglas/herbario.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/planta.dart';

class HerbarioPage extends StatefulWidget {
  const HerbarioPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<HerbarioPage> createState() => _HerbarioPageState();
}

class _HerbarioPageState extends State<HerbarioPage> {
  PartidaHerbario? _partida;
  final _pregunta = GlobalKey();
  bool _guardando = false;
  bool _guardado = false;
  bool _falloGuardado = false;
  List<String> _partesBandeja = const [];
  final Map<String, List<Opcion>> _opcionesFuncion = {};

  Herbario get _herbario => widget.actividad.herbario!;

  void _empezar(NivelHerbario nivel) {
    final opcionesPorParte = <String, List<Opcion>>{};
    for (final id in nivel.partes) {
      final pregunta = _herbario.parte(id).pregunta;
      opcionesPorParte[id] = BarajadorOpciones.barajarConRespuesta<Opcion>(
        clave: 'herbario-funcion-${nivel.id}-$id',
        opciones: pregunta.opciones,
        idDe: (o) => o.id,
        respuestaCorrecta: pregunta.respuesta,
      );
    }
    setState(() {
      _partida = PartidaHerbario(herbario: _herbario, nivel: nivel);
      _partesBandeja = BarajadorOpciones.barajarIds(
        clave: 'herbario-bandeja-${nivel.id}',
        ids: nivel.partes,
      );
      _opcionesFuncion
        ..clear()
        ..addAll(opcionesPorParte);
      _guardado = false;
      _falloGuardado = false;
    });
  }

  void _colocar(String pieza, String destino) {
    final partida = _partida!;
    setState(() => partida.colocar(pieza, destino));
    if (partida.puedeConsultar(destino)) {
      Alcance.of(context).progreso.desbloquearFicha(destino);
    }
    _mostrarPregunta();
    _guardarSiCompleta();
  }

  void _responder(String parte, String opcion) {
    final partida = _partida!;
    if (partida.preguntaActual != parte) return;
    setState(() => partida.responder(opcion));
    if (partida.puedeConsultar(parte)) {
      Alcance.of(context).progreso.desbloquearFicha(parte);
    }
    _mostrarPregunta();
    _guardarSiCompleta();
  }

  void _mostrarPregunta() {
    if (_partida!.preguntaActual == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = _pregunta.currentContext;
      if (mounted && contexto != null) {
        Scrollable.ensureVisible(
          contexto,
          duration: const Duration(milliseconds: 250),
          alignment: 0,
        );
      }
    });
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
    final niveles = _herbario.niveles;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: widget.actividad.quien,
            frase:
                'Elige un nivel. Puedes jugar a cualquiera y cambiar cuando quieras.',
            gesto: 'hola',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < niveles.length; i++) ...[
            TarjetaJuego(
              claveAccion: Key('nivel-${niveles[i].id}'),
              borde: progreso.nivelHerbarioHecho(widget.actividad, niveles[i].id)
                  ? EstilosJuego.acierto
                  : const Color(0xFF38BDF8),
              sombra: progreso.nivelHerbarioHecho(widget.actividad, niveles[i].id)
                  ? const Color(0xFF239E56)
                  : const Color(0xFF0284C7),
              radio: 20,
              onTap: () => _empezar(niveles[i]),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            niveles[i].nombre,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var s = 0; s <= i; s++)
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: progreso.nivelHerbarioHecho(
                                  widget.actividad,
                                  niveles[i].id,
                                )
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFCBD5E1),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Pensado para ${niveles[i].curso}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      niveles[i].preguntaFunciones
                          ? 'Cinco rótulos y sus funciones'
                          : '${niveles[i].partes.length == 3 ? 'Tres' : 'Cinco'} partes con dibujo',
                    ),
                    if (progreso.nivelHerbarioHecho(
                      widget.actividad,
                      niveles[i].id,
                    ))
                      const Text(
                        '✓ Nivel superado',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: EstilosJuego.separacion + 4),
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
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(
          partida.colocacionTerminada
              ? (partida.completa
                    ? '¡Todas las partes descubiertas!'
                    : 'Ahora descubre para qué sirve cada parte.')
              : 'Construye la planta, pieza a pieza.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            'Partes colocadas: ${partida.colocadas.length} de ${nivel.partes.length}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        if (nivel.preguntaFunciones)
          Text(
            'Funciones descubiertas: ${partida.funcionesAcertadas} de ${nivel.partes.length}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          key: const Key('herbario-progreso'),
          value: partida.progreso,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          semanticsLabel: 'Progreso del herbario',
          semanticsValue: '${(partida.progreso * 100).round()} %',
        ),
        const SizedBox(height: 16),
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
                ultimoDestino: partida.ultimoDestino,
                falloColocacion: partida.falloColocacion,
                consultables: {
                  for (final id in nivel.partes)
                    if (partida.puedeConsultar(id)) id,
                },
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
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id
                  in _partesBandeja.isNotEmpty ? _partesBandeja : nivel.partes)
                if (!partida.colocadas.contains(id))
                  _pieza(_herbario.parte(id), partida, ancho),
            ],
          ),
        ] else if (!partida.completa)
          const Text(
            'Las piezas están colocadas. Ahora descubre sus funciones.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        Column(
          key: _pregunta,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Burbuja(
                quien: widget.actividad.quien,
                frase: partida.resultado?.frase ?? widget.actividad.intro,
                gesto: partida.resultado?.gesto ?? 'hola',
              ),
            ),
            if (idPregunta != null) ...[
              const SizedBox(height: 16),
              Text(
                _herbario.parte(idPregunta).pregunta.enunciado,
                key: Key('pregunta-$idPregunta'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final opcion
                  in _opcionesFuncion[idPregunta] ??
                      _herbario.parte(idPregunta).pregunta.opciones) ...[
                FilledButton.tonal(
                  key: Key('funcion-$idPregunta-${opcion.id}'),
                  style: EstilosJuego.respuesta,
                  onPressed: () => _responder(idPregunta, opcion.id),
                  child: Text(opcion.nombre),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
        if (partida.colocadas.any(partida.puedeConsultar)) ...[
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
            style: EstilosJuego.accion,
            onPressed: _guardando ? null : () => _empezar(nivel),
            child: const Text('Otra vez'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('herbario-cambiar-nivel'),
          style: EstilosJuego.accion,
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

  Widget _pieza(PartePlanta parte, PartidaHerbario partida, double disponible) {
    final seleccionada = partida.seleccionada == parte.id;
    final rotulo = partida.nivel.preguntaFunciones;
    final textoGrande = MediaQuery.textScalerOf(context).scale(14) > 20;
    final ancho = textoGrande
        ? math.min(340.0, disponible)
        : math.min(240.0, (disponible - 8) / 2);
    Widget tarjeta({VoidCallback? onTap, Key? clave}) => SizedBox(
      width: ancho,
      child: TarjetaJuego(
        claveAccion: clave,
        onTap: onTap,
        borde: seleccionada
            ? Theme.of(context).colorScheme.primary
            : EstilosJuego.borde,
        fondo: seleccionada
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.white,
        destacada: seleccionada,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (!rotulo) ...[
                  IconoParte(id: parte.id, size: 32),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parte.nombre,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (seleccionada)
                        Text(
                          'Seleccionada',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  seleccionada ? Icons.check_circle : Icons.touch_app_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Draggable<String>(
      data: parte.id,
      feedback: Material(color: Colors.transparent, child: tarjeta()),
      childWhenDragging: Opacity(opacity: .35, child: tarjeta()),
      child: Semantics(
        selected: seleccionada,
        label: 'Pieza ${parte.nombre}',
        child: tarjeta(
          clave: Key('pieza-${parte.id}'),
          onTap: () => setState(() => partida.seleccionar(parte.id)),
        ),
      ),
    );
  }
}
