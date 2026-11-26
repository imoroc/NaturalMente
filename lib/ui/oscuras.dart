import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/oscuras.dart';
import 'package:naturalmente/reglas/oscuras.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_oscuras.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/nivel_recomendado.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Icono de cada opción de montaje.
IconData iconoOpcionOscuras(String id) => switch (id) {
  'ventana' => Icons.wb_sunny_rounded,
  'armario' => Icons.door_back_door_rounded,
  'caja-izquierda' => Icons.west_rounded,
  'caja-arriba' => Icons.north_rounded,
  'caja-derecha' => Icons.east_rounded,
  _ => Icons.help_outline_rounded,
};

IconData _iconoIngrediente(String id) => switch (id) {
  'tierra' => Icons.terrain_rounded,
  'luz' => Icons.wb_sunny_rounded,
  'azucar' => Icons.view_in_ar_rounded,
  'agua' => Icons.water_drop_rounded,
  'aire' => Icons.air_rounded,
  'oxigeno' => Icons.bubble_chart_rounded,
  _ => Icons.circle_outlined,
};

Color _colorIngrediente(String id) => switch (id) {
  'tierra' => const Color(0xFF8B5A2B),
  'luz' => const Color(0xFFEAB308),
  'azucar' => const Color(0xFFDB2777),
  'agua' => const Color(0xFF2563EB),
  'aire' => const Color(0xFF64748B),
  'oxigeno' => const Color(0xFF0EA5E9),
  _ => const Color(0xFF475569),
};

/// «La planta a oscuras»: un experimento con una judía. Se elige dónde va la
/// maceta (o qué le pasará), pasan los días y se ve cómo ha crecido.
class OscurasPage extends StatefulWidget {
  const OscurasPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<OscurasPage> createState() => _OscurasPageState();
}

class _OscurasPageState extends State<OscurasPage>
    with FeedbackAcierto<OscurasPage> {
  PartidaOscuras? _partida;
  bool _guardando = false;
  bool _guardado = false;
  int _vuelta = 0;

  /// Lo que dice Natu si se pulsa el botón sin haber elegido nada.
  String? _aviso;

  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Oscuras get _oscuras => widget.actividad.oscuras!;

  void _empezar(NivelOscuras nivel) {
    ocultarAcierto();
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    setState(() {
      _vuelta += 1;
      _partida = PartidaOscuras(nivel: nivel);
      _aviso = null;
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

  bool get _quieta {
    final partida = _partida;
    return partida == null ||
        partida.completa ||
        partida.resuelto ||
        pasoBloqueado;
  }

  void _elegir(String opcionId) {
    final partida = _partida;
    if (partida == null || _quieta) return;
    context.sonidoSeleccion();
    setState(() {
      _aviso = null;
      partida.elegir(opcionId);
    });
  }

  void _alternar(String ingredienteId) {
    final partida = _partida;
    if (partida == null || _quieta) return;
    context.sonidoSeleccion();
    setState(() {
      _aviso = null;
      partida.alternar(ingredienteId);
    });
  }

  void _probar() {
    final partida = _partida;
    final reto = partida?.retoActual;
    if (partida == null || reto == null || _quieta) return;
    if (!partida.listo) {
      context.sonidoToque();
      setState(
        () => _aviso = reto.tipo == 'fabricar'
            ? 'Toca primero lo que entra en la hoja.'
            : 'Elige primero una opción.',
      );
      return;
    }
    if (!iniciarPasoEvaluado()) return;
    final estabaCompleta = partida.completa;
    late bool bien;
    setState(() {
      _aviso = null;
      bien = partida.probar() ?? false;
    });
    if (bien) {
      _registrarPasoPrecision(true);
      if (partida.completa && !estabaCompleta) {
        mostrarAcierto(finalDeNivel: true);
        _guardarSiCompleta();
      } else {
        // Se deja mirar la planta antes del reto siguiente.
        confirmarPaso(
          alContinuar: () {
            partida.siguiente();
            _aviso = null;
          },
          esperarContinuar: true,
        );
      }
    } else {
      _registrarPasoPrecision(false);
      terminarIntentoConPista();
      context.sonidoPista();
    }
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

  void _mostrarCuriosidad(NivelOscuras nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(widget.actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? 'planta-y-luz' : fichas.first;
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
        _oscuras.niveles,
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
    final niveles = _oscuras.niveles;
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
    NivelOscuras nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final colores = context.coloresNaturales;
    final escenario = _escenarioDe(nivel, null);
    return TarjetaJuego(
      claveAccion: Key('nivel-${nivel.id}'),
      borde: colores.borde(
        hecho ? EstilosJuego.acierto : const Color(0xFF4ADE80),
      ),
      sombra: colores.sombra(
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
                    color: colores.contenido(
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
                ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 72,
                      height: 72 * aspectoEscenaOscuras,
                      child: CustomPaint(
                        painter: PintorOscuras(
                          escenario: escenario,
                          montaje: escenario == 'caja'
                              ? 'caja-derecha'
                              : 'ventana',
                          crecimiento: escenario == 'caja' ? 'derecha' : 'sana',
                          t: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                  color: colores.contenido(const Color(0xFF15803D)),
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

  /// cuarto o caja, según dónde esté la maceta o, si aún no hay sitio, según
  /// las opciones del nivel.
  String _escenarioDe(NivelOscuras nivel, String? montaje) {
    if (montaje != null) return montaje.startsWith('caja') ? 'caja' : 'cuarto';
    return nivel.opciones.any((o) => o.id.startsWith('caja'))
        ? 'caja'
        : 'cuarto';
  }

  // --- El experimento ---

  Widget _juego(PartidaOscuras partida, double ancho) {
    final nivel = partida.nivel;
    final reto = partida.retoActual;
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
            key: const Key('oscuras-progreso'),
            value: partida.progreso,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            semanticsLabel: context.traducir('Progreso del experimento'),
            semanticsValue: '${(partida.progreso * 100).round()} %',
          ),
        ),
        const SizedBox(height: 10),
        Texto(
          'Retos: ${partida.retosHechos} de ${nivel.retos.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (reto != null) ...[
          _pregunta(reto),
          const SizedBox(height: 12),
          if (reto.tipo == 'fabricar')
            _fabrica(partida, reto, math.min(ancho, 420))
          else ...[
            Center(child: _escena(partida, reto, math.min(ancho, 420))),
            const SizedBox(height: 12),
            _opciones(partida, reto),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('oscuras-probar'),
            style: EstilosJuego.accion,
            onPressed: _quieta ? null : _probar,
            icon: Icon(
              reto.tipo == 'fabricar'
                  ? Icons.precision_manufacturing_rounded
                  : Icons.wb_twilight_rounded,
              size: 20,
            ),
            label: Texto(
              reto.tipo == 'fabricar' ? 'Fabricar' : 'Pasan los días',
            ),
          ),
        ],
        const SizedBox(height: 12),
        AnuncioPaso(
          anunciar: true,
          child: Burbuja(
            quien: widget.actividad.quien,
            frase: _aviso ?? partida.resultado?.frase ?? nivel.intro,
            gesto: _aviso != null
                ? 'pensando'
                : partida.resultado?.gesto ?? 'hola',
          ),
        ),
        if (partida.completa) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('curiosidad-oscuras'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('oscuras-cambiar-nivel'),
          style: EstilosJuego.accion,
          onPressed: _guardando
              ? null
              : () {
                  ocultarAcierto();
                  setState(() => _partida = null);
                },
          child: const Texto('Cambiar nivel'),
        ),
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: const Texto('Volver a El invernadero'),
        ),
      ],
    );
  }

  Widget _pregunta(RetoOscuras reto) {
    final colores = context.coloresNaturales;
    return Container(
      key: const Key('oscuras-pregunta'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colores.superficie(const Color(0xFFFEF9C3)),
        borderRadius: BorderRadius.circular(EstilosJuego.radio),
        border: Border.all(
          color: colores.borde(const Color(0xFFFACC15)),
          width: 2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.science_rounded,
            color: colores.contenido(const Color(0xFFB45309)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Texto(
              reto.pregunta,
              style: const TextStyle(fontWeight: FontWeight.w800, height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

  String _descripcion(String? crecimiento) => switch (crecimiento) {
    'sana' => 'La planta ha salido verde y fuerte.',
    'palida' => 'La planta ha salido pálida y larguirucha.',
    'izquierda' => 'La planta se ha doblado hacia la izquierda.',
    'derecha' => 'La planta se ha doblado hacia la derecha.',
    _ => 'Todavía no han pasado los días.',
  };

  Widget _escena(PartidaOscuras partida, RetoOscuras reto, double ancho) {
    final nivel = partida.nivel;
    final montaje = partida.montajeVisible;
    final escenario = _escenarioDe(nivel, montaje);
    final crecimiento = partida.crecimiento;
    final totalDias = nivel.id == 'dificil' ? 10 : 7;
    final sinMovimiento = MediaQuery.disableAnimationsOf(context);
    final alto = ancho * aspectoEscenaOscuras;
    return Semantics(
      container: true,
      liveRegion: true,
      label: context
          .traducir('Maceta con una judía. {0}')
          .replaceFirst('{0}', context.traducir(_descripcion(crecimiento))),
      child: Container(
        key: const Key('oscuras-escena'),
        width: ancho,
        height: alto,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: context.coloresNaturales.borde(
              partida.resuelto ? EstilosJuego.acierto : const Color(0xFFE2DEC9),
            ),
            width: 3,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: TweenAnimationBuilder<double>(
          key: ValueKey('dias-${partida.dias}-${crecimiento ?? 'nada'}'),
          tween: Tween(
            begin: crecimiento == null || sinMovimiento ? 1 : 0,
            end: 1,
          ),
          duration: crecimiento == null || sinMovimiento
              ? Duration.zero
              : const Duration(milliseconds: 1600),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: PintorOscuras(
                    escenario: escenario,
                    montaje: montaje,
                    crecimiento: crecimiento,
                    t: t,
                    meta: reto.meta,
                  ),
                ),
              ),
              if (crecimiento != null)
                Positioned(
                  right: 10,
                  top: 10,
                  child: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        context
                            .traducir('Día {0}')
                            .replaceFirst(
                              '{0}',
                              '${math.max(1, (t * totalDias).round())}',
                            ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Las opciones del nivel, siempre en el mismo orden.
  Widget _opciones(PartidaOscuras partida, RetoOscuras reto) {
    final colores = context.coloresNaturales;
    final opciones = partida.nivel.opciones;
    final probada = partida.probado != null ? partida.elegida : null;
    final fallo = partida.resultado?.acierto == false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          reto.tipo == 'predecir'
              ? 'Qué crees que pasará'
              : 'Dónde pones la maceta',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
            color: colores.contenido(const Color(0xFFB45309)),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < opciones.length; i++) ...[
              Expanded(
                child: _opcion(
                  opciones[i],
                  reto,
                  elegida: partida.elegida == opciones[i].id,
                  fallada: fallo && probada == opciones[i].id,
                  acertada: partida.resuelto && probada == opciones[i].id,
                ),
              ),
              if (i < opciones.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }

  Widget _opcion(
    OpcionOscuras opcion,
    RetoOscuras reto, {
    required bool elegida,
    required bool fallada,
    required bool acertada,
  }) {
    final colores = context.coloresNaturales;
    final nombre = context.traducir(opcion.nombre);
    final borde = acertada
        ? EstilosJuego.acierto
        : fallada
        ? EstilosJuego.fallo
        : elegida
        ? const Color(0xFFF59E0B)
        : const Color(0xFFE2DEC9);
    return Semantics(
      button: true,
      selected: elegida,
      label: elegida
          ? context.traducir('Elegido: {0}').replaceFirst('{0}', nombre)
          : nombre,
      excludeSemantics: true,
      onTap: _quieta ? null : () => _elegir(opcion.id),
      child: GestureDetector(
        key: Key('opcion-${opcion.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _elegir(opcion.id),
        child: AnimatedContainer(
          duration: duracionSeleccionPaso(context),
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: colores.superficie(
              elegida ? const Color(0xFFFEF9C3) : Colors.white,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colores.borde(borde),
              width: elegida || fallada || acertada ? 3 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (reto.tipo == 'predecir')
                SizedBox.square(
                  dimension: 44,
                  child: CustomPaint(painter: PintorPrediccion(opcion.id)),
                )
              else
                Icon(
                  iconoOpcionOscuras(opcion.id),
                  size: 32,
                  color: colores.contenido(
                    opcion.id == 'armario'
                        ? const Color(0xFF5B3A1E)
                        : const Color(0xFFCA8A04),
                  ),
                ),
              const SizedBox(height: 6),
              Texto(
                opcion.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- La hoja fábrica ---

  Widget _fabrica(PartidaOscuras partida, RetoOscuras reto, double ancho) {
    final colores = context.coloresNaturales;
    final metidos = [
      for (final i in reto.ingredientes)
        if (partida.metidos.contains(i.id)) i,
    ];
    final alto = ancho * .6;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Semantics(
            container: true,
            liveRegion: true,
            label: partida.fabricado
                ? '${context.traducir('Sale de la hoja')}: ${context.traducir('Azúcar y oxígeno')}'
                : context
                      .traducir('Dentro de la hoja: {0}')
                      .replaceFirst(
                        '{0}',
                        metidos
                            .map((i) => context.traducir(i.nombre))
                            .join(', '),
                      ),
            child: SizedBox(
              key: const Key('oscuras-hoja'),
              width: ancho,
              height: alto,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: PintorHojaFabrica(encendida: partida.fabricado),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: ancho * .14),
                        child: partida.fabricado
                            ? _salidaHoja()
                            : Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final i in metidos) _fichaHoja(i),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Texto(
          'Qué entra en la hoja',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: .6,
            color: colores.contenido(const Color(0xFFB45309)),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, restricciones) {
            const columnas = 3;
            const separacion = 8.0;
            final lado =
                (restricciones.maxWidth - separacion * (columnas - 1)) /
                columnas;
            return Wrap(
              spacing: separacion,
              runSpacing: separacion,
              children: [
                for (final i in reto.ingredientes)
                  SizedBox(
                    width: lado,
                    child: _ingrediente(
                      i,
                      metido: partida.metidos.contains(i.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _fichaHoja(IngredienteOscuras ingrediente) => ExcludeSemantics(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconoIngrediente(ingrediente.id),
            size: 16,
            color: _colorIngrediente(ingrediente.id),
          ),
          const SizedBox(width: 4),
          Texto(
            ingrediente.nombre,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14532D),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _salidaHoja() => ExcludeSemantics(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Texto(
            'Sale de la hoja',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Color(0xFF15803D),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconoIngrediente('azucar'),
                color: _colorIngrediente('azucar'),
              ),
              const SizedBox(width: 6),
              Icon(
                _iconoIngrediente('oxigeno'),
                color: _colorIngrediente('oxigeno'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Texto(
            'Azúcar y oxígeno',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF14532D),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _ingrediente(IngredienteOscuras ingrediente, {required bool metido}) {
    final colores = context.coloresNaturales;
    final nombre = context.traducir(ingrediente.nombre);
    return Semantics(
      button: true,
      toggled: metido,
      label: nombre,
      excludeSemantics: true,
      onTap: _quieta ? null : () => _alternar(ingrediente.id),
      child: GestureDetector(
        key: Key('ingrediente-${ingrediente.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _alternar(ingrediente.id),
        child: AnimatedContainer(
          duration: duracionSeleccionPaso(context),
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colores.superficie(
              metido ? const Color(0xFFECFDF3) : Colors.white,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colores.borde(
                metido ? EstilosJuego.acierto : const Color(0xFFE2DEC9),
              ),
              width: metido ? 3 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                metido
                    ? Icons.check_circle_rounded
                    : _iconoIngrediente(ingrediente.id),
                size: 28,
                color: colores.contenido(
                  metido
                      ? EstilosJuego.acierto
                      : _colorIngrediente(ingrediente.id),
                ),
              ),
              const SizedBox(height: 4),
              Texto(
                ingrediente.nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
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
}
