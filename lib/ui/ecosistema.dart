import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/ecosistema.dart';
import 'package:naturalmente/reglas/ecosistema.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/escena_ecosistema.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/texto.dart';

class EcosistemaPage extends StatefulWidget {
  const EcosistemaPage({required this.actividad, super.key});
  final Actividad actividad;
  @override
  State<EcosistemaPage> createState() => _EcosistemaPageState();
}

class _EcosistemaPageState extends State<EcosistemaPage> {
  PartidaEcosistema? _partida;
  final ScrollController _scroll = ScrollController();
  final Map<String, List<OpcionEcosistema>> _opciones = {};
  bool _guardando = false, _guardado = false, _falloGuardado = false;
  bool _permitirSalir = false;
  Ecosistema get _ecosistema => widget.actividad.ecosistema!;
  Duration _duracion(int ms) =>
      Duration(milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : ms);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _empezar(NivelEcosistema nivel) {
    _opciones.clear();
    for (final reto in nivel.retos) {
      _opciones[reto.id] =
          BarajadorOpciones.barajarConRespuesta<OpcionEcosistema>(
            clave: 'ecosistemas-${nivel.id}-${reto.id}',
            opciones: reto.opciones,
            idDe: (o) => o.id,
            respuestaCorrecta: reto.respuesta,
          );
    }
    setState(() {
      _partida = PartidaEcosistema(_ecosistema, nivel);
      _guardando = false;
      _guardado = false;
      _falloGuardado = false;
    });
    // Una preferencia fallida no impide jugar ni altera las estrellas.
    Alcance.of(context).progreso.recordarNivelEcosistema(nivel.id);
    _arriba();
  }

  void _arriba() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        if (MediaQuery.disableAnimationsOf(context)) {
          _scroll.jumpTo(0);
        } else {
          _scroll.animateTo(
            0,
            duration: _duracion(240),
            curve: Curves.easeOutCubic,
          );
        }
      }
    });
  }

  void _colocar(String pieza, String destino) {
    setState(() => _partida!.colocar(pieza, destino));
  }

  void _seguir() {
    setState(() => _partida!.seguir());
    if (_partida!.completa) _guardar();
    _arriba();
  }

  Future<void> _guardar() async {
    final partida = _partida!;
    if (_guardando || _guardado || !partida.completa) return;
    final progreso = Alcance.of(context).progreso;
    setState(() {
      _guardando = true;
      _falloGuardado = false;
    });
    try {
      await progreso.marcarNivelEcosistema(widget.actividad, partida.nivel.id);
      if (mounted && identical(partida, _partida)) {
        setState(() => _guardado = true);
      }
    } catch (_) {
      if (mounted && identical(partida, _partida)) {
        setState(() => _falloGuardado = true);
      }
    } finally {
      if (mounted && identical(partida, _partida)) {
        setState(() => _guardando = false);
      }
    }
  }

  Future<bool> _confirmarSalida() async {
    if (_partida == null || _partida!.completa) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Texto('¿Dejamos el claro por ahora?'),
            content: const Texto(
              'Las estrellas que ya tienes se guardan. Este intento empezará de nuevo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Texto('Seguir jugando'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Texto('Salir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _salir() async {
    if (!await _confirmarSalida() || !mounted) return;
    setState(() => _permitirSalir = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> _cambiarNivel() async {
    if (!await _confirmarSalida() || !mounted) return;
    setState(() => _partida = null);
    _arriba();
  }

  void _ayuda() {
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
              Texto(
                'Así damos vida al claro',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 150, child: DibujoEcosistema()),
              const SizedBox(height: 16),
              const Texto('1. Toca el dibujo que pide Natu.'),
              const SizedBox(height: 8),
              const Texto(
                '2. Toca su silueta en el claro. También puedes arrastrarlo.',
              ),
              const SizedBox(height: 12),
              const Texto(
                'Las flechas van del alimento a quien lo come: hierba → conejo → zorro.',
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: EstilosJuego.accion,
                child: const Texto('¡Vamos a jugar!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _partida;
    return PopScope(
      canPop: _permitirSalir || p == null || p.completa,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Texto(widget.actividad.titulo),
          leading: BackButton(onPressed: _salir),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: p == null ? _selector() : _juego(p),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selector() {
    final progreso = Alcance.of(context).progreso;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: const AspectRatio(
                aspectRatio: 2,
                child: DibujoEcosistema(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Burbuja(
          quien: widget.actividad.quien,
          frase: widget.actividad.intro,
          gesto: 'hola',
        ),
        const SizedBox(height: 20),
        Texto(
          'Elige un nivel',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        const Texto(
          'Puedes jugar a cualquiera. Cada nivel descubre algo nuevo.',
        ),
        const SizedBox(height: 16),
        for (final nivel in _ecosistema.niveles) ...[
          TarjetaJuego(
            claveAccion: Key('nivel-${nivel.id}'),
            borde: progreso.nivelEcosistemaHecho(widget.actividad, nivel.id)
                ? EstilosJuego.acierto
                : const Color(0xFF38BDF8),
            onTap: () => _empezar(nivel),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    height: 60,
                    child: DibujoEcosistema(
                      elemento: nivel.id == 'facil'
                          ? 'hierba'
                          : nivel.id == 'medio'
                          ? 'conejo'
                          : 'zorro',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Texto(
                          nivel.nombre,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Texto('Pensado para ${nivel.curso}'),
                        const SizedBox(height: 6),
                        Texto(nivel.resumen),
                        if (progreso.ultimoNivelEcosistema == nivel.id)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Texto('Tu último nivel'),
                          ),
                        if (progreso.nivelEcosistemaHecho(
                          widget.actividad,
                          nivel.id,
                        ))
                          const Texto('✓ Nivel superado'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _juego(PartidaEcosistema p) {
    final instruccion = p.completa
        ? '¡El claro está lleno de conexiones!'
        : p.confirmado
        ? '¡Un nuevo descubrimiento!'
        : p.elementoActual?.instruccion ?? p.retoActual!.pregunta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          children: [
            Texto(
              '${p.nivel.nombre} · ${p.nivel.curso}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            TextButton.icon(
              key: const Key('eco-ayuda'),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: _ayuda,
              icon: const Icon(Icons.help_outline_rounded),
              label: const Texto('Ver cómo'),
            ),
          ],
        ),
        Semantics(
          label: context.traducir('Descubrimientos: ${p.pasos} de ${p.total}'),
          child: LinearProgressIndicator(
            value: p.pasos / p.total,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Texto('Descubrimientos: ${p.pasos} de ${p.total}'),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Texto(
            instruccion,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final escena = _escena(p);
            final controles = _controles(p);
            if (constraints.maxWidth >= 720 &&
                MediaQuery.textScalerOf(context).scale(16) <= 24) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: escena),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: controles),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [escena, const SizedBox(height: 14), controles],
            );
          },
        ),
        if (!p.completa) ...[
          const SizedBox(height: 14),
          TextButton(
            key: const Key('eco-cambiar-nivel'),
            onPressed: _cambiarNivel,
            child: const Texto('Cambiar nivel'),
          ),
        ],
      ],
    );
  }

  Widget _escena(PartidaEcosistema p) => Column(
    children: [
      AspectRatio(
        aspectRatio: 600 / 360,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(child: const DibujoEcosistema(colocados: {})),
              for (final elemento in _ecosistema.elementos)
                _destino(p, elemento, constraints),
            ],
          ),
        ),
      ),
      if (p.relaciones > 0 || p.completa && p.nivel.id != 'facil') ...[
        const SizedBox(height: 10),
        Semantics(
          label: context.traducir(
            p.relaciones > 1
                ? 'La hierba alimenta al conejo y el conejo puede alimentar al zorro.'
                : 'La hierba alimenta al conejo.',
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: DibujoEcosistema(
                      elemento: _ecosistema.elementos[i].id,
                    ),
                  ),
                  if (i < 2)
                    TweenAnimationBuilder<double>(
                      key: ValueKey('flecha-$i-${p.relaciones}'),
                      tween: Tween(begin: 0, end: p.relaciones > i ? 1 : 0),
                      duration: _duracion(420),
                      builder: (_, value, child) =>
                          Opacity(opacity: value, child: child),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF1F8A4C),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        const Texto(
          'La flecha va del alimento a quien lo come.',
          textAlign: TextAlign.center,
        ),
      ],
    ],
  );

  Widget _destino(
    PartidaEcosistema p,
    ElementoEcosistema e,
    BoxConstraints constraints,
  ) {
    final r = zonaElemento(e.id);
    final colocado = p.colocados.contains(e.id);
    final fallido = p.ultimoDestino == e.id && p.acierto == false;
    final disponible = !p.confirmado && p.montando && !colocado;
    return Positioned(
      left: r.left * constraints.maxWidth,
      top: r.top * constraints.maxHeight,
      width: math.max(48, r.width * constraints.maxWidth),
      height: math.max(48, r.height * constraints.maxHeight),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (d) => disponible,
        onAcceptWithDetails: (d) => _colocar(d.data, e.id),
        builder: (context, candidatos, _) {
          final destacado =
              candidatos.isNotEmpty ||
              fallido ||
              (p.intentos > 1 && p.elementoActual?.id == e.id);
          return Semantics(
            label: context.traducir(
              colocado ? '${e.nombre}, colocado' : 'Lugar de ${e.nombre}',
            ),
            button: disponible,
            enabled: disponible,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: Key('eco-destino-${e.id}'),
                borderRadius: BorderRadius.circular(20),
                onTap: disponible
                    ? () {
                        if (p.seleccion != null) {
                          _colocar(p.seleccion!, e.id);
                        } else {
                          setState(
                            () => p.frase =
                                'Primero toca un dibujo de la bandeja.',
                          );
                        }
                      }
                    : null,
                child: AnimatedContainer(
                  duration: _duracion(160),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: destacado
                        ? EstilosJuego.fallo.withValues(alpha: .18)
                        : Colors.transparent,
                    border: destacado
                        ? Border.all(color: EstilosJuego.fallo, width: 3)
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (!colocado)
                        Positioned.fill(
                          child: Opacity(
                            opacity: .18,
                            child: DibujoEcosistema(elemento: e.id),
                          ),
                        ),
                      if (colocado)
                        Positioned.fill(
                          child: TweenAnimationBuilder<double>(
                            key: ValueKey('colocado-${e.id}'),
                            tween: Tween(begin: .88, end: 1),
                            duration: _duracion(280),
                            curve: Curves.easeOutCubic,
                            builder: (_, value, child) =>
                                Transform.scale(scale: value, child: child),
                            child: DibujoEcosistema(elemento: e.id),
                          ),
                        ),
                      if (disponible ||
                          colocado && p.confirmado && p.ultimoDestino == e.id)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF7),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              colocado
                                  ? Icons.check_circle_rounded
                                  : Icons.add_circle_outline_rounded,
                              color: fallido
                                  ? const Color(0xFFB96517)
                                  : const Color(0xFF1F8A4C),
                              size: 22,
                            ),
                          ),
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

  Widget _controles(PartidaEcosistema p) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!p.completa && p.montando && !p.confirmado) ...[
        const Texto(
          'Toca un dibujo y después su lugar. También puedes arrastrarlo.',
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) => Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              for (final e in _ecosistema.elementos.where(
                (e) => !p.colocados.contains(e.id),
              ))
                SizedBox(
                  width: MediaQuery.textScalerOf(context).scale(16) > 24
                      ? c.maxWidth
                      : (c.maxWidth - 20) / 3,
                  child: _pieza(p, e),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
      if (!p.completa && !p.montando && !p.confirmado) ...[
        for (final o in _opciones[p.retoActual!.id]!) ...[
          FilledButton.tonal(
            key: Key('eco-respuesta-${o.id}'),
            style: EstilosJuego.respuesta,
            onPressed: () => setState(() => p.responder(o.id)),
            child: Row(
              children: [
                if (const ['hierba', 'conejo', 'zorro'].contains(o.id)) ...[
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: DibujoEcosistema(elemento: o.id),
                  ),
                  const SizedBox(width: 12),
                ],
                if (o.id == 'agua') ...[
                  const Icon(Icons.water_drop_outlined),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Texto(o.nombre)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
      if (p.frase != null)
        Semantics(
          liveRegion: true,
          child: Burbuja(
            quien: widget.actividad.quien,
            frase: p.frase!,
            gesto: p.acierto == true
                ? 'feliz'
                : p.intentos > 1
                ? 'pista'
                : 'pensando',
          ),
        ),
      if (p.cambio != null) ...[
        const SizedBox(height: 14),
        const Texto(
          'Así podría cambiar el claro',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          key: ValueKey(p.cambio),
          tween: Tween(begin: 0, end: 1),
          duration: _duracion(500),
          builder: (_, value, child) => Opacity(opacity: value, child: child),
          child: _comparacion(p.cambio!),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('eco-restaurar'),
          style: EstilosJuego.accion,
          onPressed: _seguir,
          icon: const Icon(Icons.restore_rounded),
          label: const Texto('Restaurar el claro'),
        ),
      ] else if (p.confirmado) ...[
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('eco-seguir'),
          style: EstilosJuego.accion,
          onPressed: _seguir,
          child: Texto(p.pasos == p.total ? 'Ver mi descubrimiento' : 'Seguir'),
        ),
      ],
      if (p.completa) ..._final(p),
    ],
  );

  Widget _comparacion(String cambio) {
    final id = cambio == 'menos-hierba' ? 'hierba' : 'conejo';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Texto(
            'Imaginamos este cambio:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final despues in [false, true]) ...[
            Texto(despues ? 'Después: hay menos' : 'Antes: hay más'),
            const SizedBox(height: 4),
            ExcludeSemantics(
              child: Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < (despues ? 1 : 3); i++)
                    SizedBox(
                      width: 56,
                      height: 64,
                      child: DibujoEcosistema(elemento: id),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pieza(PartidaEcosistema p, ElementoEcosistema e) {
    final tarjeta = TarjetaJuego(
      claveAccion: Key('eco-pieza-${e.id}'),
      borde: p.seleccion == e.id ? const Color(0xFF1F8A4C) : EstilosJuego.borde,
      destacada: p.seleccion == e.id,
      onTap: () => setState(() => p.seleccionar(e.id)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SizedBox(height: 76, child: DibujoEcosistema(elemento: e.id)),
            Texto(
              e.nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (p.seleccion == e.id)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: Color(0xFF1F8A4C),
              ),
          ],
        ),
      ),
    );
    return Semantics(
      selected: p.seleccion == e.id,
      child: Draggable<String>(
        data: e.id,
        maxSimultaneousDrags: 1,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Transform.translate(
          offset: const Offset(-45, -100),
          child: _dibujoArrastre(e.id),
        ),
        childWhenDragging: Opacity(opacity: .3, child: tarjeta),
        child: tarjeta,
      ),
    );
  }

  Widget _dibujoArrastre(String id) => Material(
    color: Colors.transparent,
    child: SizedBox(
      width: 100,
      height: 110,
      child: DibujoEcosistema(elemento: id),
    ),
  );

  List<Widget> _final(PartidaEcosistema p) => [
    Burbuja(
      quien: widget.actividad.quien,
      frase: p.nivel.id == 'facil'
          ? '¡Has dado vida al claro! Las plantas y los animales están conectados.'
          : '¡Has descubierto conexiones del bosque! En la naturaleza hay muchas más.',
      gesto: 'feliz',
    ),
    const SizedBox(height: 16),
    if (_guardando) const Texto('Guardando tu descubrimiento…'),
    if (_falloGuardado) ...[
      const Texto(
        'Tu claro está completo. Vamos a intentar guardar la estrella otra vez.',
      ),
      FilledButton(onPressed: _guardar, child: const Texto('Guardar de nuevo')),
    ],
    if (_guardado) ...[
      TarjetaJuego(
        borde: const Color(0xFFE6B24E),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFB77713),
                size: 36,
              ),
              const Texto(
                '✓ Nivel superado',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19),
              ),
              const SizedBox(height: 8),
              const Texto('Un bosque conectado'),
              const SizedBox(height: 8),
              const Texto(
                'Tu cromo del bosque está en el álbum de Natu.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
    FilledButton(
      key: const Key('eco-otra-vez'),
      style: EstilosJuego.accion,
      onPressed: _guardando || !_guardado ? null : () => _empezar(p.nivel),
      child: const Texto('Otra vez'),
    ),
    const SizedBox(height: 8),
    OutlinedButton(
      key: const Key('eco-cambiar-nivel'),
      style: EstilosJuego.accion,
      onPressed: _guardando || !_guardado ? null : _cambiarNivel,
      child: const Texto('Cambiar nivel'),
    ),
    const SizedBox(height: 8),
    TextButton(onPressed: _salir, child: const Texto('Volver a La reserva')),
  ];
}
