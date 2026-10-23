import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/digestion.dart';
import 'package:naturalmente/reglas/digestion.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_digestion.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/texto.dart';

class ViajePage extends StatefulWidget {
  const ViajePage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<ViajePage> createState() => _ViajePageState();
}

class _ViajePageState extends State<ViajePage> {
  PartidaViaje? _partida;
  final _pregunta = GlobalKey();
  bool _guardando = false;
  bool _guardado = false;
  bool _falloGuardado = false;
  int _ronda = 0;
  List<String> _destinos = const [];
  final Map<String, List<Opcion>> _opciones = {};
  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Viaje get _viaje => widget.actividad.viaje!;

  void _empezar(NivelViaje nivel) {
    final opciones = <String, List<Opcion>>{};
    for (final parada in nivel.paradas) {
      final pregunta = parada.pregunta;
      if (pregunta == null) continue;
      opciones[parada.id] = BarajadorOpciones.barajarConRespuesta<Opcion>(
        clave: 'viaje-${nivel.id}-${parada.id}',
        opciones: pregunta.opciones,
        idDe: (o) => o.id,
        respuestaCorrecta: pregunta.respuesta,
      );
    }
    final preguntaFinal = nivel.preguntaFinal;
    if (preguntaFinal != null) {
      opciones['final'] = BarajadorOpciones.barajarConRespuesta<Opcion>(
        clave: 'viaje-${nivel.id}-final',
        opciones: preguntaFinal.opciones,
        idDe: (o) => o.id,
        respuestaCorrecta: preguntaFinal.respuesta,
      );
    }
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    setState(() {
      _ronda += 1;
      _partida = PartidaViaje(viaje: _viaje, nivel: nivel);
      _destinos = BarajadorOpciones.barajarIds(
        clave: 'viaje-destinos-${nivel.id}',
        ids: [...nivel.ruta, ...nivel.despistes],
      );
      _opciones
        ..clear()
        ..addAll(opciones);
      _guardado = false;
      _falloGuardado = false;
      _comboActual = comboGlobal;
      _mejorComboSesion = comboGlobal;
      _semillasSesion = 0;
      _pistaEnPaso = false;
      _pistasSesion = 0;
    });
  }

  void _registrarPasoPrecision(bool acierto) {
    final prog = Alcance.maybeOf(context)?.progreso;
    final baseCombo = prog?.comboActual ?? _comboActual;
    if (acierto) {
      final aLaPrimera = !_pistaEnPaso;
      final nuevoCombo = aLaPrimera ? baseCombo + 1 : 1;
      final ganadas = aLaPrimera
          ? (nuevoCombo >= 3 ? 3 : (nuevoCombo == 2 ? 2 : 1))
          : 1;
      setState(() {
        _comboActual = nuevoCombo;
        if (nuevoCombo > _mejorComboSesion) _mejorComboSesion = nuevoCombo;
        _semillasSesion += ganadas;
        _pistaEnPaso = false;
      });
      prog?.registrarAciertoPrecision(
        aLaPrimera: aLaPrimera,
        comboActual: nuevoCombo,
      );
    } else {
      setState(() {
        _comboActual = 0;
        _pistaEnPaso = true;
        _pistasSesion++;
      });
      prog?.romperComboPrecision();
    }
  }

  void _cambiar(void Function(PartidaViaje partida) accion) {
    final estabaCompleta = _partida?.completa ?? false;
    setState(() => accion(_partida!));
    final partida = _partida!;
    if (partida.resultado?.acierto == true &&
        partida.resultado?.estado != 'masticar') {
      _registrarPasoPrecision(true);
    } else if (partida.resultado?.acierto == false) {
      _registrarPasoPrecision(false);
    }
    if (partida.completa && !estabaCompleta) {
      context.sonidoCelebracion();
    } else if (partida.resultado?.acierto == true) {
      context.sonidoAcierto();
    } else if (partida.resultado?.estado == 'masticar') {
      context.sonidoPaso(partida.mordiscos);
    } else if (partida.resultado?.acierto == false) {
      context.sonidoPista();
    }
    _verPregunta();
    _guardarSiCompleta();
  }

  void _verPregunta() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = _pregunta.currentContext;
      if (mounted && contexto != null) {
        Scrollable.ensureVisible(
          contexto,
          duration: const Duration(milliseconds: 250),
          alignment: .1,
        );
      }
    });
  }

  Future<void> _guardarSiCompleta() async {
    final partida = _partida;
    if (partida == null || !partida.completa || _guardando || _guardado) {
      return;
    }
    final progreso = Alcance.of(context).progreso;
    setState(() {
      _guardando = true;
      _falloGuardado = false;
    });
    try {
      await progreso.marcarNivelJuego(widget.actividad, partida.nivel.id);
      if (mounted) setState(() => _guardado = true);
    } catch (_) {
      if (mounted) setState(() => _falloGuardado = true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _nombre(NivelViaje nivel, String id) => nivel.ruta.contains(id)
      ? nivel.parada(id).nombre
      : _viaje.despiste(id).nombre;

  void _mostrarCuriosidad(NivelViaje nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(widget.actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? 'aparato-digestivo' : fichas.first;
    final titulo =
        Alcance.of(context).catalogo.fichas
            .where((f) => f.id == fichaId)
            .firstOrNull
            ?.titulo ??
        widget.actividad.titulo;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFDFBF7),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IlustracionFicha(id: fichaId, alto: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Texto(
                          'CUADERNO DE NATU',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Texto(
                          titulo,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Burbuja(
                quien: 'Dato curioso de Natu',
                frase: nivel.curiosidad,
                gesto: 'feliz',
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('cerrar-curiosidad'),
                onPressed: () {
                  context.sonidoToque();
                  Navigator.of(context).pop();
                },
                child: const Texto('¡Qué interesante!'),
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
        centerTitle: false,
        title: Texto(
          widget.actividad.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          InsigniaPrecisionAppBar(
            combo: _comboActual,
            semillasSesion: _semillasSesion,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Al cambiar de nivel o de ronda la pantalla vuelve arriba.
            key: ValueKey('${partida?.nivel.id ?? 'selector'}-$_ronda'),
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
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichasCatalogo = {
      for (final f in alcance.catalogo.fichas) f.id: f.titulo,
    };
    final niveles = _viaje.niveles;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: widget.actividad.quien,
            frase: 'Elige un nivel. Cada dificultad desbloquea un cromo sobre cómo aprovecha el cuerpo la comida.',
            gesto: 'hola',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < niveles.length; i++) ...[
            _tarjetaNivel(
              niveles[i],
              estrellas: i + 1,
              hecho: progreso.nivelJuegoHecho(widget.actividad, niveles[i].id),
              progreso: progreso,
              fichasCatalogo: fichasCatalogo,
            ),
            const SizedBox(height: EstilosJuego.separacion + 4),
          ],
        ],
      ),
    );
  }

  Widget _tarjetaNivel(
    NivelViaje nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final (etiqueta, muestras) = switch (nivel.id) {
      'facil' => ('Boca y barriga, masticando', const ['boca', 'barriga']),
      'medio' => (
        'Cuatro paradas y una pregunta',
        const ['esofago', 'estomago'],
      ),
      _ => (
        'Cinco partes y qué pasa en cada una',
        const ['intestino-delgado', 'intestino-grueso'],
      ),
    };
    return TarjetaJuego(
      claveAccion: Key('nivel-${nivel.id}'),
      borde: hecho ? EstilosJuego.acierto : const Color(0xFF38BDF8),
      sombra: hecho ? const Color(0xFF239E56) : const Color(0xFF0284C7),
      radio: 20,
      onTap: () => _empezar(nivel),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Texto(
                    nivel.nombre,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                for (var s = 0; s < estrellas; s++)
                  Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: hecho
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFCBD5E1),
                  ),
              ],
            ),
            Texto(
              'Pensado para ${nivel.curso}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final id in muestras) ...[
                  IconoParada(id: id, tamano: 34),
                  const SizedBox(width: 6),
                ],
                const SizedBox(width: 2),
                Expanded(
                  child: Texto(
                    etiqueta,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (nivel.resumen.isNotEmpty) ...[
              const SizedBox(height: 6),
              Texto(nivel.resumen),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final fichaId in Progreso.fichasDeNivel(
                  widget.actividad.id,
                  nivel.id,
                ))
                  _chipCromo(
                    fichasCatalogo[fichaId] ?? fichaId,
                    progreso.fichaDesbloqueada(fichaId),
                  ),
              ],
            ),
            if (hecho) ...[
              const SizedBox(height: 6),
              const Texto(
                '✓ Nivel superado',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chipCromo(String titulo, bool desbloqueado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: desbloqueado ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: desbloqueado
              ? const Color(0xFFF59E0B)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            desbloqueado
                ? Icons.auto_stories_rounded
                : Icons.lock_outline_rounded,
            size: 13,
            color: desbloqueado
                ? const Color(0xFFB45309)
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Texto(
              'Cromo: $titulo',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: desbloqueado
                    ? const Color(0xFF92400E)
                    : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _juego(PartidaViaje partida, double ancho) {
    final nivel = partida.nivel;
    final pendiente = partida.preguntaPendiente;
    final posicion = partida.posicion;
    final activas = [...nivel.ruta, ...nivel.despistes];
    final libre = !partida.recorridoTerminado;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          '${nivel.nombre} · Pensado para ${nivel.curso}. Puedes jugarlo igual.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Texto(
          partida.recorridoTerminado
              ? '¡La manzana ha terminado su viaje!'
              : '¿Adónde va ahora la manzana?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Texto(
            'Paradas recorridas: ${partida.paradasAlcanzadas} de ${nivel.ruta.length}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          key: const Key('viaje-progreso'),
          value: partida.progreso,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          semanticsLabel: context.traducir('Progreso del viaje de la comida'),
          semanticsValue: '${(partida.progreso * 100).round()} %',
        ),
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: math.min(ancho, 340),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
              ),
              padding: const EdgeInsets.all(8),
              child: DiagramaDigestivo(
                key: const Key('diagrama-digestivo'),
                activas: libre ? activas : const [],
                alcanzadas: partida.alcanzadas,
                posicion: posicion,
                estadoBocado: partida.estadoBocado,
                resaltado: partida.ultimoDestino,
                fallo: partida.falloDestino,
                etiqueta: context.traducir(
                  'Cuerpo con el aparato digestivo. La manzana está en: ${posicion == null ? 'el plato' : _nombre(nivel, posicion)}',
                ),
                onElegir: (id) => _cambiar((p) => p.mover(id)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (libre) ...[
          Row(
            children: [
              Draggable<String>(
                data: 'bocado',
                dragAnchorStrategy: pointerDragAnchorStrategy,
                onDragStarted: () => context.sonidoSeleccion(),
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.translate(
                    offset: const Offset(-28, -28),
                    child: DibujoBocado(
                      estado: partida.estadoBocado,
                      tamano: 56,
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: .35,
                  child: _bocadoArrastrable(partida),
                ),
                child: Semantics(
                  label: context.traducir('Arrastra la manzana'),
                  child: _bocadoArrastrable(partida),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Texto(
                  'Toca la siguiente parada en el cuerpo o en los botones, o arrastra la manzana.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (partida.faltaMasticar) ...[
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('masticar'),
              style: EstilosJuego.accion,
              onPressed: () => _cambiar((p) => p.masticar()),
              icon: const Icon(Icons.restaurant_rounded),
              label: Texto(
                'Masticar (${partida.mordiscos}/$mordiscosNecesarios)',
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in _destinos.isNotEmpty ? _destinos : activas)
                _botonDestino(id, partida, ancho),
            ],
          ),
        ],
        const SizedBox(height: 12),
        KeyedSubtree(
          key: _pregunta,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                liveRegion: true,
                child: Burbuja(
                  quien: widget.actividad.quien,
                  frase: partida.resultado?.frase ?? nivel.intro,
                  gesto: partida.resultado?.gesto ?? 'hola',
                ),
              ),
              if (pendiente != null)
                ..._bloquePregunta(
                  etiqueta: 'Pregunta de la parada',
                  pregunta: nivel.parada(pendiente).pregunta!,
                  clave: pendiente,
                  opciones: _opciones[pendiente],
                  onResponder: (o) => _cambiar((p) => p.responder(o)),
                ),
              if (partida.mostrarPreguntaFinal)
                ..._bloquePregunta(
                  etiqueta: 'Pregunta final',
                  pregunta: nivel.preguntaFinal!,
                  clave: 'final',
                  opciones: _opciones['final'],
                  onResponder: (o) => _cambiar((p) => p.responderFinal(o)),
                ),
            ],
          ),
        ),
        if (partida.completa) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('curiosidad-viaje'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Texto(
              '¡Has completado el viaje de la comida!',
              key: const Key('viaje-completo'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          ResumenPrecisionFinal(
            semillasGanadas: _semillasSesion,
            mejorComboSesion: _mejorComboSesion,
            sinPistas: _pistasSesion == 0,
          ),
          const SizedBox(height: 6),
          if (_guardando) const Texto('Guardando tu progreso…'),
          if (_guardado)
            const Texto('Nivel superado y guardado en este dispositivo.'),
          if (_falloGuardado) ...[
            const Texto(
              'No he podido guardar tu progreso. Puedes intentarlo otra vez.',
            ),
            TextButton(
              onPressed: _guardarSiCompleta,
              child: const Texto('Guardar de nuevo'),
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('viaje-otra-vez'),
            style: EstilosJuego.accion,
            onPressed: _guardando
                ? null
                : () {
                    context.sonidoToque();
                    _empezar(nivel);
                  },
            child: const Texto('Otra vez'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('viaje-cambiar-nivel'),
          style: EstilosJuego.accion,
          onPressed: _guardando
              ? null
              : () {
                  context.sonidoToque();
                  setState(() => _partida = null);
                },
          child: const Texto('Cambiar nivel'),
        ),
        TextButton(
          onPressed: _guardando
              ? null
              : () {
                  context.sonidoToque();
                  Navigator.of(context).pop();
                },
          child: const Texto('Volver a Dentro de mí'),
        ),
      ],
    );
  }

  Widget _bocadoArrastrable(PartidaViaje partida) {
    return Container(
      key: const Key('bocado'),
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF59E0B), width: 2.5),
      ),
      child: DibujoBocado(estado: partida.estadoBocado, tamano: 52),
    );
  }

  Widget _botonDestino(String id, PartidaViaje partida, double disponible) {
    final nivel = partida.nivel;
    final alcanzada = partida.alcanzadas.contains(id);
    final aqui = partida.posicion == id;
    final fallo = partida.falloDestino && partida.ultimoDestino == id;
    final textoGrande = MediaQuery.textScalerOf(context).scale(14) > 20;
    final ancho = textoGrande
        ? math.min(340.0, disponible)
        : math.min(240.0, (disponible - 8) / 2);
    final nombre = _nombre(nivel, id);
    return SizedBox(
      width: ancho,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data == 'bocado',
        onAcceptWithDetails: (_) => _cambiar((p) => p.mover(id)),
        builder: (context, candidatos, _) {
          final arrastrandoEncima = candidatos.isNotEmpty;
          return Semantics(
            button: true,
            label: context.traducir('Parada: $nombre'),
            child: TarjetaJuego(
              claveAccion: Key('destino-$id'),
              onTap: () => _cambiar((p) => p.mover(id)),
              borde: arrastrandoEncima
                  ? const Color(0xFF0EA5E9)
                  : fallo
                  ? EstilosJuego.fallo
                  : alcanzada
                  ? EstilosJuego.acierto
                  : EstilosJuego.borde,
              fondo: arrastrandoEncima
                  ? const Color(0xFFE0F2FE)
                  : aqui
                  ? const Color(0xFFECFDF5)
                  : Colors.white,
              destacada: arrastrandoEncima || fallo || aqui,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 60),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconoParada(id: id, tamano: 44),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Texto(
                          nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (alcanzada)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: EstilosJuego.acierto,
                          size: 20,
                        )
                      else if (fallo)
                        const Icon(
                          Icons.replay_rounded,
                          color: EstilosJuego.fallo,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _bloquePregunta({
    required String etiqueta,
    required PreguntaExtra pregunta,
    required String clave,
    required List<Opcion>? opciones,
    required ValueChanged<String> onResponder,
  }) {
    return [
      const SizedBox(height: 16),
      Texto(
        etiqueta,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
          color: Color(0xFFB45309),
        ),
      ),
      const SizedBox(height: 4),
      Texto(
        pregunta.enunciado,
        key: Key('pregunta-$clave'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      for (final opcion in opciones ?? pregunta.opciones) ...[
        FilledButton.tonal(
          key: Key('respuesta-$clave-${opcion.id}'),
          style: EstilosJuego.respuesta,
          onPressed: () => onResponder(opcion.id),
          child: Texto(opcion.nombre),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }
}
