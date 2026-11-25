import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/carrera.dart';
import 'package:naturalmente/reglas/carrera.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_carrera.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/nivel_recomendado.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// «Carrera de relevos»: se coloca a cada corredor en un tramo de la pista y
/// al pulsar «¡Ya!» el relevo la recorre en orden. Los tramos no cambian de
/// sitio; lo que se baraja es el orden de los corredores en la salida.
class CarreraPage extends StatefulWidget {
  const CarreraPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<CarreraPage> createState() => _CarreraPageState();
}

class _CarreraPageState extends State<CarreraPage>
    with FeedbackAcierto<CarreraPage>, SingleTickerProviderStateMixin {
  PartidaCarrera? _partida;
  bool _guardando = false;
  bool _guardado = false;
  int _vuelta = 0;

  /// Orden de los corredores en la salida, por ronda.
  final Map<String, List<String>> _orden = {};

  /// Quién estaba en cada tramo al dar la salida, para animar el relevo
  /// aunque el que se atasca ya haya vuelto a la salida.
  Map<String, CorredorCarrera> _enCarrera = const {};

  late final AnimationController _relevo = AnimationController(vsync: this);

  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Carrera get _carrera => widget.actividad.carrera!;

  @override
  void dispose() {
    _relevo.dispose();
    super.dispose();
  }

  void _empezar(NivelCarrera nivel) {
    ocultarAcierto();
    final orden = <String, List<String>>{};
    for (final ronda in nivel.rondas) {
      // El primer corredor de la salida nunca es el del primer tramo, y la
      // posición cambia entre rondas.
      orden[ronda.id] = BarajadorOpciones.barajarConRespuesta<CorredorCarrera>(
        clave: 'carrera-${ronda.id}',
        opciones: ronda.corredores,
        idDe: (c) => c.id,
        respuestaCorrecta: ronda.corredores
            .firstWhere((c) => c.tramo == nivel.tramos.first.id)
            .id,
      ).map((c) => c.id).toList();
    }
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    _relevo.value = 0;
    setState(() {
      _vuelta += 1;
      _partida = PartidaCarrera(nivel: nivel);
      _orden
        ..clear()
        ..addAll(orden);
      _enCarrera = const {};
      _guardando = false;
      _guardado = false;
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
      guardarPrecisionPaso(
        acierto: true,
        aLaPrimera: aLaPrimera,
        comboActual: nuevoCombo,
      );
    } else {
      setState(() {
        _comboActual = 0;
        _pistaEnPaso = true;
        _pistasSesion++;
      });
      guardarPrecisionPaso(acierto: false);
    }
  }

  bool get _corriendo => _relevo.isAnimating;

  /// Colocar, seleccionar o quitar no se evalúa: solo mueve piezas.
  void _mover(void Function(PartidaCarrera partida) accion) {
    final partida = _partida;
    if (partida == null || partida.completa || pasoBloqueado || _corriendo) {
      return;
    }
    context.sonidoSeleccion();
    setState(() => accion(partida));
  }

  void _salir() {
    final partida = _partida!;
    final estabaCompleta = partida.completa;
    if (estabaCompleta || !partida.listo || _corriendo) return;
    if (!iniciarPasoEvaluado()) return;
    final enCarrera = {
      for (final tramo in partida.nivel.tramos)
        tramo.id: partida.enTramo(tramo.id)!,
    };
    final anterior = partida.resultado;
    setState(() {
      partida.salir();
      _enCarrera = enCarrera;
    });
    final resultado = partida.resultado;
    if (resultado == null || identical(resultado, anterior)) {
      terminarIntentoConPista();
      return;
    }
    _animarRelevo(partida.nivel.tramos.length);
    _registrarPasoPrecision(resultado.acierto);
    if (partida.completa && !estabaCompleta) {
      mostrarAcierto(finalDeNivel: true);
      _guardarSiCompleta();
    } else if (resultado.acierto) {
      confirmarPaso(
        alContinuar: () {
          partida.siguiente();
          _enCarrera = const {};
          _relevo.value = 0;
        },
        // En Difícil se descubre de quién era cada parte: se deja leer.
        esperarContinuar: partida.nivel.lupa,
      );
    } else {
      terminarIntentoConPista();
      context.sonidoPista();
    }
  }

  void _animarRelevo(int tramos) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _relevo.value = 1;
      return;
    }
    _relevo.duration = Duration(milliseconds: math.min(1100, 220 * tramos));
    _relevo.forward(from: 0);
  }

  Future<void> _guardarSiCompleta() async {
    final partida = _partida;
    if (partida == null || !partida.completa || _guardando || _guardado) return;
    final progreso = Alcance.of(context).progreso;
    final actividadGuardada = widget.actividad;
    final nivelGuardado = partida.nivel.id;
    setState(() => _guardando = true);
    await registrarGuardadoFinal(() async {
      try {
        await progreso.marcarNivelJuego(actividadGuardada, nivelGuardado);
        if (mounted && identical(partida, _partida)) {
          setState(() => _guardado = true);
        }
        return true;
      } catch (_) {
        return false;
      } finally {
        if (mounted && identical(partida, _partida)) {
          setState(() => _guardando = false);
        }
      }
    });
    if (mounted && identical(partida, _partida)) {
      setState(() => _guardando = false);
    }
  }

  void _mostrarCuriosidad(NivelCarrera nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(widget.actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? 'vuela-nada-anda' : fichas.first;
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
                  IlustracionFicha(id: fichaId, alto: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Texto(
                          'CUADERNO DE NATU',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                            color: context.coloresNaturales.contenido(
                              const Color(0xFF15803D),
                            ),
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
  DatosFinJuego? construirFinJuego() {
    if (!(_partida?.completa == true)) return null;
    final nivel = _partida!.nivel;
    return DatosFinJuego(
      actividad: widget.actividad.titulo,
      nivel: nivel.nombre,
      siguiente: prepararSiguienteNivel(
        _carrera.niveles,
        nivel,
        (nivel) => nivel.nombre,
        _empezar,
      ),
      resumen: ResumenPrecisionFinal(
        semillasGanadas: _semillasSesion,
        mejorComboSesion: _mejorComboSesion,
        sinPistas: _pistasSesion == 0,
      ),
      onRepetir: () => _empezar(nivel),
      onCambiarNivel: () {
        ocultarAcierto();
        setState(() => _partida = null);
      },
      onVolver: () => Navigator.of(context).pop(),
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
            combo: presentarCombo(_comboActual),
            discreta: true,
            semillasSesion: _semillasSesion,
          ),
        ],
      ),
      body: construirContenidoPaso(
        SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              key: ValueKey('${partida?.nivel.id ?? 'selector'}-$_vuelta'),
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: partida == null
                      ? _selector()
                      : _juego(
                          partida,
                          math.min(constraints.maxWidth - 32, 640),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Selector de nivel ---

  Widget _selector() {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichasCatalogo = {
      for (final f in alcance.catalogo.fichas) f.id: f.titulo,
    };
    final niveles = _carrera.niveles;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: widget.actividad.quien,
            frase: widget.actividad.intro,
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
    NivelCarrera nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final primera = nivel.rondas.first.corredores;
    final muestras = <Widget>[
      for (final corredor in primera.take(2))
        nivel.lupa && corredor.lupa != null
            ? LupaParte(
                dibujo: corredor.dibujo,
                lupa: corredor.lupa!,
                tamano: 38,
              )
            : DibujoCorredor(id: corredor.dibujo, tamano: 38),
    ];
    return TarjetaJuego(
      claveAccion: Key('nivel-${nivel.id}'),
      borde: context.coloresNaturales.borde(
        hecho ? EstilosJuego.acierto : const Color(0xFF4ADE80),
      ),
      sombra: context.coloresNaturales.sombra(
        hecho ? const Color(0xFF239E56) : const Color(0xFF15803D),
      ),
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
                    color: context.coloresNaturales.contenido(
                      hecho ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                    ),
                  ),
              ],
            ),
            Texto(
              'Pensado para ${nivel.curso}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            EtiquetaRecomendado(nivelId: nivel.id),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final m in muestras) ...[m, const SizedBox(width: 4)],
                const SizedBox(width: 6),
                Expanded(child: Texto(nivel.resumen)),
              ],
            ),
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
              Texto(
                '✓ Nivel superado',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: context.coloresNaturales.contenido(
                    const Color(0xFF15803D),
                  ),
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
        color: context.coloresNaturales.superficie(
          desbloqueado ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.coloresNaturales.borde(
            desbloqueado ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
          ),
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
            color: context.coloresNaturales.contenido(
              desbloqueado ? const Color(0xFFB45309) : const Color(0xFF64748B),
            ),
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
                color: context.coloresNaturales.contenido(
                  desbloqueado
                      ? const Color(0xFF92400E)
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- La carrera ---

  Widget _juego(PartidaCarrera partida, double ancho) {
    final nivel = partida.nivel;
    final ronda = partida.rondaActual;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          '${nivel.nombre} · Pensado para ${nivel.curso}. Puedes jugarlo igual.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ProgresoPaso(
          child: LinearProgressIndicator(
            key: const Key('carrera-progreso'),
            value: partida.progreso,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            semanticsLabel: context.traducir('Progreso de la carrera'),
            semanticsValue: '${(partida.progreso * 100).round()} %',
          ),
        ),
        const SizedBox(height: 10),
        Texto(
          'Relevos: ${partida.rondasHechas} de ${nivel.rondas.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (ronda != null) ...[
          _salida(partida, ronda),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _relevo,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < nivel.tramos.length; i++)
                  _carril(partida, nivel.tramos[i], i, ancho),
              ],
            ),
          ),
          const SizedBox(height: 4),
          FilledButton.icon(
            key: const Key('carrera-ya'),
            style: EstilosJuego.accion,
            onPressed: partida.listo && !partida.completa ? _salir : null,
            icon: const Icon(Icons.flag_rounded),
            label: const Texto('¡Ya!'),
          ),
        ],
        const SizedBox(height: 12),
        AnuncioPaso(
          anunciar: true,
          child: Burbuja(
            quien: widget.actividad.quien,
            frase:
                partida.resultado?.frase ??
                (partida.listo
                    ? nivel.intro
                    : partida.seleccionado != null
                    ? context
                          .traducir('Toca un tramo para colocar a {0}.')
                          .replaceFirst(
                            '{0}',
                            context.traducir(
                              _nombreVisible(partida, partida.seleccionado!),
                            ),
                          )
                    : nivel.intro),
            gesto: partida.resultado?.gesto ?? 'hola',
          ),
        ),
        if (partida.completa) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('curiosidad-carrera'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('carrera-cambiar-nivel'),
          style: EstilosJuego.accion,
          onPressed: _guardando
              ? null
              : () {
                  ocultarAcierto();
                  _relevo.value = 0;
                  setState(() => _partida = null);
                },
          child: const Texto('Cambiar nivel'),
        ),
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Texto('Volver a La reserva'),
        ),
      ],
    );
  }

  /// En Difícil se ve la parte del cuerpo hasta llegar a la meta.
  String _nombreVisible(PartidaCarrera partida, String corredorId) {
    final corredor = partida.rondaActual!.corredores.firstWhere(
      (c) => c.id == corredorId,
    );
    return partida.nivel.lupa && !partida.descubierto
        ? corredor.parte
        : corredor.nombre;
  }

  Widget _salida(PartidaCarrera partida, RondaCarrera ronda) {
    final orden = _orden[ronda.id] ?? [for (final c in ronda.corredores) c.id];
    final enSalida = {for (final c in partida.enSalida) c.id: c};
    return DragTarget<String>(
      onAcceptWithDetails: (detalles) => _mover((p) => p.quitar(detalles.data)),
      builder: (context, _, _) => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: context.coloresNaturales.superficie(const Color(0xFFF8F5EC)),
          borderRadius: BorderRadius.circular(EstilosJuego.radio),
          border: Border.all(
            color: context.coloresNaturales.borde(const Color(0xFFE2DEC9)),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Texto(
              partida.nivel.lupa ? 'Partes del cuerpo' : 'Corredores',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
                color: context.coloresNaturales.contenido(
                  const Color(0xFFB45309),
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (enSalida.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Texto(
                  partida.descubierto ? '' : '¡Todos en su sitio!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              )
            else
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in orden)
                    if (enSalida[id] case final corredor?)
                      _arrastrable(partida, corredor, enPista: false),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _arrastrable(
    PartidaCarrera partida,
    CorredorCarrera corredor, {
    required bool enPista,
  }) {
    final tarjeta = _tarjetaCorredor(partida, corredor, enPista: enPista);
    return Draggable<String>(
      data: corredor.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: const Offset(-36, -36),
          child: _figura(partida, corredor, 72),
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: tarjeta),
      onDragStarted: () {
        if (partida.seleccionado != corredor.id) {
          setState(() => partida.seleccionado = null);
        }
      },
      child: tarjeta,
    );
  }

  Widget _figura(PartidaCarrera partida, CorredorCarrera corredor, double t) {
    if (partida.nivel.lupa && !partida.descubierto && corredor.lupa != null) {
      return LupaParte(
        dibujo: corredor.dibujo,
        lupa: corredor.lupa!,
        tamano: t,
      );
    }
    return DibujoCorredor(id: corredor.dibujo, tamano: t);
  }

  Widget _tarjetaCorredor(
    PartidaCarrera partida,
    CorredorCarrera corredor, {
    required bool enPista,
  }) {
    final elegido = partida.seleccionado == corredor.id;
    final atascado = !enPista && partida.atascado == corredor.id;
    final colores = context.coloresNaturales;
    final nombre = _nombreVisible(partida, corredor.id);
    final ancho = partida.nivel.lupa ? 104.0 : 88.0;
    return Semantics(
      button: true,
      selected: elegido,
      label: context.traducir(nombre),
      child: GestureDetector(
        key: Key('corredor-${corredor.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => enPista
            ? _mover((p) => p.tocarTramo(p.tramoDe(corredor.id)!))
            : _mover((p) => p.seleccionar(corredor.id)),
        child: AnimatedContainer(
          duration: duracionSeleccionPaso(context),
          width: ancho,
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
          decoration: BoxDecoration(
            color: colores.superficie(
              elegido ? const Color(0xFFECFDF3) : Colors.white,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colores.borde(
                elegido
                    ? EstilosJuego.acierto
                    : atascado
                    ? EstilosJuego.fallo
                    : const Color(0xFFE2DEC9),
              ),
              width: elegido || atascado ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colores.sombra(const Color(0xFFD0C9B8)),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _figura(partida, corredor, enPista ? 44 : 56),
              const SizedBox(height: 2),
              Texto(
                nombre,
                textAlign: TextAlign.center,
                maxLines: enPista && !partida.nivel.lupa ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avance del relevo en el tramo [i], de 0 a 1.
  double _avance(int i, int tramos) {
    final t = _relevo.value * tramos - i;
    return t.clamp(0.0, 1.0);
  }

  Widget _carril(
    PartidaCarrera partida,
    TramoCarrera tramo,
    int i,
    double ancho,
  ) {
    final colores = context.coloresNaturales;
    final tramos = partida.nivel.tramos.length;
    final corriendo = _corriendo && _enCarrera.isNotEmpty;
    final avance = corriendo ? _avance(i, tramos) : 0.0;
    final atasco = partida.resultado?.acierto == false;
    final esAtasco = atasco && partida.atascado != null && i == partida.llegada;
    final pasado = atasco && i > partida.llegada;
    final enMeta = partida.descubierto;
    final corredor = corriendo || (esAtasco && _relevo.value < 1)
        ? _enCarrera[tramo.id]
        : partida.enTramo(tramo.id);
    final alto = partida.nivel.lupa ? 118.0 : 104.0;
    final borde = enMeta
        ? EstilosJuego.acierto
        : esAtasco
        ? EstilosJuego.fallo
        : const Color(0xFFD6CFC0);
    // El corredor salta en su tramo; el que se atasca tiembla.
    final salto = corriendo && !(esAtasco) && !pasado
        ? -math.sin(avance * math.pi) * 10
        : 0.0;
    final temblor = corriendo && esAtasco
        ? math.sin(avance * math.pi * 6) * 6
        : 0.0;
    final carril = AnimatedOpacity(
      opacity: pasado && corriendo ? .55 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        height: alto,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colores.borde(borde), width: 2.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: FondoTramo(id: tramo.id)),
            Positioned(
              left: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colores.superficie(Colors.white).withValues(alpha: .9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      iconoTramo(tramo.id),
                      size: 18,
                      color: colores.contenido(const Color(0xFF334155)),
                    ),
                    const SizedBox(width: 5),
                    Texto(
                      tramo.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: colores.contenido(const Color(0xFF1E293B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 4,
              bottom: 4,
              child: Center(
                child: Transform.translate(
                  offset: Offset(temblor, salto),
                  child: corredor == null
                      ? _hueco(partida)
                      : _arrastrable(partida, corredor, enPista: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    final nombreTramo = context.traducir(tramo.nombre);
    return Semantics(
      button: true,
      label: corredor == null
          ? context.traducir('Tramo: {0}').replaceFirst('{0}', nombreTramo)
          : context
                .traducir('{0} en el tramo {1}')
                .replaceFirst(
                  '{0}',
                  context.traducir(_nombreVisible(partida, corredor.id)),
                )
                .replaceFirst('{1}', nombreTramo),
      child: DragTarget<String>(
        onAcceptWithDetails: (detalles) =>
            _mover((p) => p.colocar(detalles.data, tramo.id)),
        builder: (context, candidatos, _) => GestureDetector(
          key: Key('tramo-${tramo.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _mover((p) => p.tocarTramo(tramo.id)),
          child: candidatos.isEmpty
              ? carril
              : DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: EstilosJuego.acierto.withValues(alpha: .45),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: carril,
                ),
        ),
      ),
    );
  }

  Widget _hueco(PartidaCarrera partida) {
    final colores = context.coloresNaturales;
    final elegido = partida.seleccionado != null;
    return Container(
      width: partida.nivel.lupa ? 104 : 88,
      height: 80,
      decoration: BoxDecoration(
        color: colores.superficie(Colors.white).withValues(alpha: .55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colores.borde(
            elegido ? EstilosJuego.acierto : const Color(0xFF94A3B8),
          ),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.add_rounded,
        color: colores.contenido(const Color(0xFF64748B)),
      ),
    );
  }
}
