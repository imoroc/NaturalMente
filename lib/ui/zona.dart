import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/cromos_zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/digestion.dart';
import 'package:naturalmente/ui/ecosistema.dart';
import 'package:naturalmente/ui/herbario.dart';
import 'package:naturalmente/ui/juego.dart';
import 'package:naturalmente/ui/laboratorio_zona.dart';
import 'package:naturalmente/ui/nacimiento.dart';
import 'package:naturalmente/ui/rescate.dart';
import 'package:naturalmente/ui/carrera.dart';
import 'package:naturalmente/ui/linterna.dart';
import 'package:naturalmente/ui/oscuras.dart';
import 'package:naturalmente/ui/pelicula.dart';
import 'package:naturalmente/ui/adivinanza.dart';
import 'package:naturalmente/ui/memoria.dart';
import 'package:naturalmente/ui/texto.dart';

void abrirActividad(BuildContext context, Actividad actividad) {
  context.sonidoToque();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => switch (actividad.tipo) {
        'ecosistema' => EcosistemaPage(actividad: actividad),
        'herbario' => HerbarioPage(actividad: actividad),
        'nacimiento' => NacimientoPage(actividad: actividad),
        'viaje' => ViajePage(actividad: actividad),
        'rescate' => RescatePage(actividad: actividad),
        'carrera' => CarreraPage(actividad: actividad),
        'linterna' => LinternaPage(actividad: actividad),
        'pelicula' => PeliculaPage(actividad: actividad),
        'oscuras' => OscurasPage(actividad: actividad),
        'memoria' => MemoriaPage(actividad: actividad),
        'adivinanza' => AdivinanzaPage(actividad: actividad),
        _ => JuegoPage(actividad: actividad),
      },
    ),
  );
}

class ZonaPage extends StatefulWidget {
  const ZonaPage({required this.zona, super.key});

  final Zona zona;

  @override
  State<ZonaPage> createState() => _ZonaPageState();
}

class _ZonaPageState extends State<ZonaPage> {
  static const _destacados = [
    'hogar',
    'nacimiento',
    'ecosistemas',
    'cuida-reserva',
  ];
  static const _duracionCambio = Duration(milliseconds: 180);
  bool _explorar = false;

  void _seleccionar(bool explorar) {
    if (_explorar == explorar) return;
    context.sonidoToque();
    setState(() => _explorar = explorar);
  }

  List<Actividad> _ordenar(List<Actividad> actividades) {
    if (widget.zona.id != 'reserva') return actividades;
    return [
      for (final id in _destacados)
        ...actividades.where((actividad) => actividad.id == id),
      ...actividades.where((actividad) => !_destacados.contains(actividad.id)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final zona = widget.zona;
    final alcance = Alcance.of(context);
    final colores = context.coloresNaturales;
    final reducido = MediaQuery.disableAnimationsOf(context);
    final duracion = reducido ? Duration.zero : _duracionCambio;
    final actividades = _ordenar(alcance.catalogo.actividadesDe(zona.id));
    final fichas = alcance.catalogo.fichasDe(zona.id);

    return Scaffold(
      backgroundColor: colores.oscuro ? colores.fondo : const Color(0xFFFAF5EC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: LayoutBuilder(
              builder: (context, medidas) {
                final ilustracionAlta = (medidas.maxWidth / 3.55).clamp(
                  42.0,
                  medidas.maxHeight < 520 ? 58.0 : 146.0,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .backButtonTooltip,
                            onPressed: () => Navigator.maybePop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: colores.fondoAcierto,
                              foregroundColor: colores.acierto,
                              side: BorderSide(
                                color: colores.acierto,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Semantics(
                              header: true,
                              child: Texto(
                                zona.nombre,
                                style: _estiloMundo(colores.tinta, 34),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _ArteMundo(
                        'paisaje-${zona.id}',
                        alto: ilustracionAlta,
                        fit: zona.id == 'reserva'
                            ? BoxFit.cover
                            : BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 9, 12, 7),
                      child: _PestanasMundo(
                        explorar: _explorar,
                        duracion: duracion,
                        seleccionar: _seleccionar,
                      ),
                    ),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_explorar),
                        tween: Tween(begin: reducido ? 1 : 0, end: 1),
                        duration: duracion,
                        curve: Curves.easeOutCubic,
                        builder: (context, avance, child) => Opacity(
                          opacity: avance,
                          child: Transform.translate(
                            offset: Offset(0, (1 - avance) * 6),
                            transformHitTests: false,
                            child: child,
                          ),
                        ),
                        child: _ContenidoMundo(
                          zona: zona,
                          explorar: _explorar,
                          actividades: actividades,
                          fichas: fichas,
                          progreso: alcance.progreso,
                          abrirJuego: (actividad) =>
                              abrirActividad(context, actividad),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _estiloMundo(Color color, double tamano) => TextStyle(
  fontFamily: 'NunitoInicio',
  color: color,
  fontSize: tamano,
  fontWeight: FontWeight.w900,
  height: 1.12,
);

class _PestanasMundo extends StatelessWidget {
  const _PestanasMundo({
    required this.explorar,
    required this.duracion,
    required this.seleccionar,
  });

  final bool explorar;
  final Duration duracion;
  final ValueChanged<bool> seleccionar;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.tarjeta,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colores.contorno, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, medidas) => Stack(
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  alignment: explorar
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  duration: duracion,
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: medidas.maxWidth / 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colores.fondoAcierto,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: colores.acierto, width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            color: colores.sombra(colores.acierto),
                          ),
                        ],
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (id, titulo, esExplorar) in [
                    ('jugar', 'Jugar', false),
                    ('explorar', 'Explorar', true),
                  ])
                    Expanded(
                      child: Semantics(
                        selected: explorar == esExplorar,
                        button: true,
                        child: Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            key: Key('mundo-$id'),
                            borderRadius: BorderRadius.circular(17),
                            onTap: () => seleccionar(esExplorar),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 5,
                              ),
                              child: Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.center,
                                  spacing: 7,
                                  runSpacing: 3,
                                  children: [
                                    _ArteMundo(id, ancho: 48, alto: 43),
                                    Texto(
                                      titulo,
                                      style: _estiloMundo(colores.tinta, 21),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContenidoMundo extends StatelessWidget {
  const _ContenidoMundo({
    required this.zona,
    required this.explorar,
    required this.actividades,
    required this.fichas,
    required this.progreso,
    required this.abrirJuego,
  });

  final Zona zona;
  final bool explorar;
  final List<Actividad> actividades;
  final List<Ficha> fichas;
  final Progreso progreso;
  final ValueChanged<Actividad> abrirJuego;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return SingleChildScrollView(
      key: PageStorageKey(
        'mundo-${zona.id}-${explorar ? 'explorar' : 'jugar'}',
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
      child: ListenableBuilder(
        listenable: progreso,
        builder: (context, _) => explorar
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Texto('Explorar', style: _estiloMundo(colores.tinta, 23)),
                  const SizedBox(height: 8),
                  BannerEvolucionZona(zona: zona),
                  const SizedBox(height: 12),
                  TarjetaAccesoLaboratorio(zona: zona),
                  const SizedBox(height: 12),
                  ResumenCromosZona(
                    zona: zona,
                    fichas: fichas,
                    progreso: progreso,
                  ),
                ],
              )
            : Column(
                children: [
                  Texto(
                    zona.id == 'reserva'
                        ? 'Juega y aprende con retos de la reserva.'
                        : 'Elige un juego para empezar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colores.tenue,
                      fontFamily: 'NunitoInicio',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.star_rounded, size: 18),
                        label: Texto(
                          'Estrellas: ${progreso.totalNivelesSuperados(actividades)}/${progreso.totalMaxNiveles(actividades)}',
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.flag_rounded, size: 18),
                        label: Texto(
                          'Misiones: ${actividades.where(progreso.actividadHecha).length}/${actividades.length}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, medidas) {
                      const hueco = 9.0;
                      final escala = MediaQuery.textScalerOf(context).scale(17);
                      final unaColumna = medidas.maxWidth < 285 || escala > 25;
                      final ancho = unaColumna
                          ? medidas.maxWidth
                          : (medidas.maxWidth - hueco) / 2;
                      final arte = (ancho * .49).clamp(74.0, 130.0);
                      return Wrap(
                        spacing: hueco,
                        runSpacing: 11,
                        children: [
                          for (var i = 0; i < actividades.length; i++)
                            SizedBox(
                              width: ancho,
                              height: arte + escala * 2.65 + 15,
                              child: _TarjetaJuegoMundo(
                                actividad: actividades[i],
                                orden: i,
                                altoArte: arte,
                                onTap: () => abrirJuego(actividades[i]),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  Texto(
                    'Cambia entre Jugar y Explorar cuando quieras.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colores.tenue, fontSize: 13),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TarjetaJuegoMundo extends StatefulWidget {
  const _TarjetaJuegoMundo({
    required this.actividad,
    required this.orden,
    required this.altoArte,
    required this.onTap,
  });

  final Actividad actividad;
  final int orden;
  final double altoArte;
  final VoidCallback onTap;

  @override
  State<_TarjetaJuegoMundo> createState() => _TarjetaJuegoMundoState();
}

class _TarjetaJuegoMundoState extends State<_TarjetaJuegoMundo> {
  int? _puntero;
  Offset _inicio = Offset.zero;

  void _presionar(PointerDownEvent evento) {
    if (_puntero != null || evento.buttons != kPrimaryButton) return;
    _inicio = evento.position;
    setState(() => _puntero = evento.pointer);
  }

  void _soltar(PointerEvent evento) {
    if (_puntero == evento.pointer) setState(() => _puntero = null);
  }

  void _desplazar(PointerMoveEvent evento) {
    if ((evento.position - _inicio).distanceSquared > kTouchSlop * kTouchSlop) {
      _soltar(evento);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final reducido = MediaQuery.disableAnimationsOf(context);
    final pulsada = _puntero != null;
    const paletas = [
      (Color(0xFFE1F3D7), Color(0xFF29B45B)),
      (Color(0xFFFFE8CA), Color(0xFFF69A3B)),
      (Color(0xFFD8F0FC), Color(0xFF36B6F5)),
      (Color(0xFFEAF2CD), Color(0xFF9ABC36)),
    ];
    final (fondo, borde) = paletas[widget.orden % paletas.length];
    final radio = BorderRadius.circular(20);
    const recorrido = 3.0;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          top: recorrido,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colores.sombra(
                Color.alphaBlend(const Color(0x38000000), borde),
              ),
              borderRadius: radio,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: recorrido),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: pulsada && !reducido ? recorrido : 0),
            duration: reducido
                ? Duration.zero
                : Duration(milliseconds: pulsada ? 65 : 100),
            curve: Curves.easeOutCubic,
            builder: (context, distancia, child) => Transform.translate(
              offset: Offset(0, distancia),
              transformHitTests: false,
              child: child,
            ),
            child: Material(
              color: colores.superficie(fondo),
              shape: RoundedRectangleBorder(
                borderRadius: radio,
                side: BorderSide(color: colores.borde(borde), width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Listener(
                onPointerDown: _presionar,
                onPointerMove: _desplazar,
                onPointerUp: _soltar,
                onPointerCancel: _soltar,
                child: InkWell(
                  key: Key('juego-${widget.actividad.id}'),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ArteMundo(widget.actividad.id, alto: widget.altoArte),
                        Expanded(
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colores.tarjeta.withValues(alpha: .65),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
                              child: Texto(
                                widget.actividad.titulo,
                                textAlign: TextAlign.center,
                                style: _estiloMundo(colores.tinta, 17),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArteMundo extends StatelessWidget {
  const _ArteMundo(
    this.id, {
    this.ancho,
    required this.alto,
    this.fit = BoxFit.contain,
  });

  final String id;
  final double? ancho;
  final double alto;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/mundos/$id.webp',
    height: alto,
    width: ancho,
    fit: fit,
    excludeFromSemantics: true,
  );
}

void mostrarDetalleFicha(
  BuildContext context,
  Ficha ficha, {
  required bool desbloqueada,
}) {
  if (desbloqueada) {
    context.sonidoDescubrimiento();
  } else {
    context.sonidoPista();
  }
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: context.coloresNaturales.superficie(
      const Color(0xFFFDFBF7),
    ),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.coloresNaturales.superficie(
                      desbloqueada
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.coloresNaturales.borde(
                        desbloqueada
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFCBD5E1),
                      ),
                      width: 2,
                    ),
                  ),
                  child: desbloqueada
                      ? IlustracionFicha(id: ficha.id, alto: 54)
                      : Icon(
                          Icons.lock_rounded,
                          size: 34,
                          color: context.coloresNaturales.contenido(
                            Color(0xFF64748B),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Texto(
                        desbloqueada
                            ? 'CROMO DESBLOQUEADO · ${ficha.curso.toUpperCase()}'
                            : 'CROMO POR DESCUBRIR · ${ficha.curso.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: context.coloresNaturales.contenido(
                            desbloqueada
                                ? const Color(0xFF15803D)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Texto(
                        ficha.titulo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (desbloqueada) ...[
              TarjetaFichaEnciclopedica(fichaId: ficha.id),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.coloresNaturales.superficie(Colors.white),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: context.coloresNaturales.borde(
                      const Color(0xFFE2DEC9),
                    ),
                    width: 2,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: context.coloresNaturales.contenido(
                        Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Texto(
                        ficha.frase,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: context.coloresNaturales.contenido(
                            Color(0xFF1E293B),
                          ),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Burbuja(
                quien: 'Dato curioso de Natu',
                frase: ficha.curiosidad,
                gesto: 'feliz',
              ),
            ] else
              Burbuja(
                quien: 'Pista de Natu',
                frase:
                    '¡Aún no tienes este cromo! ${Progreso.pistaDesbloqueoFicha(ficha.id)}',
                gesto: 'pista',
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('cerrar-detalle-ficha'),
              onPressed: () {
                context.sonidoToque();
                Navigator.of(context).pop();
              },
              child: Texto(desbloqueada ? '¡Genial!' : '¡Voy a descubrirlo!'),
            ),
          ],
        ),
      ),
    ),
  );
}
