import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/linterna.dart';
import 'package:naturalmente/reglas/linterna.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_linterna.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/nivel_recomendado.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// «Linterna y microscopio»: un dibujo a oscuras que se explora moviendo la
/// luz. Arriba está la lista de lo que hay que encontrar, siempre en el mismo
/// orden; se toca el dibujo donde está lo que se busca.
class LinternaPage extends StatefulWidget {
  const LinternaPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<LinternaPage> createState() => _LinternaPageState();
}

const _centro = Offset(.5, .5);

class _LinternaPageState extends State<LinternaPage>
    with FeedbackAcierto<LinternaPage> {
  PartidaLinterna? _partida;
  bool _guardando = false;
  bool _guardado = false;
  int _vuelta = 0;

  /// Dónde está la luz, de 0 a 1.
  Offset _luz = _centro;

  /// Lo que dice Natu al tocar donde no hay nada o algo ya encontrado.
  String? _aviso;

  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Linterna get _linterna => widget.actividad.linterna!;

  void _empezar(NivelLinterna nivel) {
    ocultarAcierto();
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    setState(() {
      _vuelta += 1;
      _partida = PartidaLinterna(nivel: nivel);
      _luz = _centro;
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
        partida.iluminada ||
        pasoBloqueado;
  }

  /// Mover la luz no se evalúa.
  void _moverLuz(Offset local, Size size) {
    if (_quieta) return;
    setState(() => _luz = _normalizar(local, size));
  }

  Offset _normalizar(Offset local, Size size) => Offset(
    (local.dx / size.width).clamp(0.0, 1.0),
    (local.dy / size.height).clamp(0.0, 1.0),
  );

  void _tocar(Offset local, Size size) {
    final partida = _partida;
    if (partida == null || _quieta) return;
    final punto = _normalizar(local, size);
    final debajo = partida.queHay(punto.dx, punto.dy);
    if (debajo == null || partida.encontrado(debajo.id)) {
      context.sonidoToque();
      setState(() {
        _luz = punto;
        partida.tocado = null;
        _aviso = debajo == null
            ? 'Aquí no hay nada de la lista. Mueve la luz y sigue buscando.'
            : 'Eso ya está encendido. Busca lo siguiente de la lista.';
      });
      return;
    }
    if (!iniciarPasoEvaluado()) return;
    final estabaCompleta = partida.completa;
    late ToqueLinterna toque;
    setState(() {
      _luz = punto;
      _aviso = null;
      toque = partida.tocar(punto.dx, punto.dy);
    });
    if (toque == ToqueLinterna.acierto) {
      _registrarPasoPrecision(true);
      if (partida.completa && !estabaCompleta) {
        mostrarAcierto(finalDeNivel: true);
        _guardarSiCompleta();
      } else if (partida.iluminada) {
        // Se enciende la luz entera: se deja mirar el dibujo.
        confirmarPaso(
          alContinuar: () {
            partida.siguiente();
            _luz = _centro;
            _aviso = null;
          },
          esperarContinuar: true,
        );
      } else {
        confirmarPaso(alContinuar: () {}, conservarTablero: true);
      }
    } else if (toque == ToqueLinterna.otro) {
      _registrarPasoPrecision(false);
      terminarIntentoConPista();
      context.sonidoPista();
    } else {
      terminarIntentoConPista();
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

  void _mostrarCuriosidad(NivelLinterna nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(widget.actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? 'partes-del-cuerpo' : fichas.first;
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
        _linterna.niveles,
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
    final niveles = _linterna.niveles;
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
    NivelLinterna nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final colores = context.coloresNaturales;
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colores.superficie(const Color(0xFF1E293B)),
                  ),
                  child: Icon(
                    iconoHerramienta(nivel.herramienta),
                    color: const Color(0xFFFDE68A),
                  ),
                ),
                const SizedBox(width: 6),
                MiniaturaLinterna(dibujo: nivel.escenas.first.dibujo),
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

  // --- La búsqueda ---

  Widget _juego(PartidaLinterna partida, double ancho) {
    final nivel = partida.nivel;
    final escena = partida.escenaActual;
    final buscado = partida.buscado;
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
            key: const Key('linterna-progreso'),
            value: partida.progreso,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            semanticsLabel: context.traducir('Progreso de la búsqueda'),
            semanticsValue: '${(partida.progreso * 100).round()} %',
          ),
        ),
        const SizedBox(height: 10),
        Texto(
          'Escenas: ${partida.escenasHechas} de ${nivel.escenas.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (escena != null) ...[
          _lista(partida, escena),
          const SizedBox(height: 12),
          Center(child: _escena(partida, escena, math.min(ancho, 400))),
        ],
        const SizedBox(height: 12),
        AnuncioPaso(
          anunciar: true,
          child: Burbuja(
            quien: widget.actividad.quien,
            frase:
                _aviso ??
                partida.resultado?.frase ??
                (buscado == null
                    ? nivel.intro
                    : '${context.traducir(nivel.intro)} ${context.traducir('Busca: {0}').replaceFirst('{0}', context.traducir(buscado.nombre))}'),
            gesto: _aviso != null
                ? 'pensando'
                : partida.resultado?.gesto ?? 'hola',
          ),
        ),
        if (partida.completa) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('curiosidad-linterna'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('linterna-cambiar-nivel'),
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
          child: const Texto('Volver a Dentro de mí'),
        ),
      ],
    );
  }

  /// La lista de lo que hay que buscar. Su orden no cambia nunca.
  Widget _lista(PartidaLinterna partida, EscenaLinterna escena) {
    final colores = context.coloresNaturales;
    final buscado = partida.buscado;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: colores.superficie(const Color(0xFFF8F5EC)),
        borderRadius: BorderRadius.circular(EstilosJuego.radio),
        border: Border.all(
          color: colores.borde(const Color(0xFFE2DEC9)),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                iconoHerramienta(partida.nivel.herramienta),
                size: 16,
                color: colores.contenido(const Color(0xFFB45309)),
              ),
              const SizedBox(width: 6),
              Texto(
                'Busca',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                  color: colores.contenido(const Color(0xFFB45309)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < escena.objetivos.length; i++)
                _chipObjetivo(
                  partida,
                  escena.objetivos[i],
                  i + 1,
                  actual: buscado?.id == escena.objetivos[i].id,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipObjetivo(
    PartidaLinterna partida,
    ObjetivoLinterna objetivo,
    int numero, {
    required bool actual,
  }) {
    final colores = context.coloresNaturales;
    final hecho = partida.encontrado(objetivo.id);
    final tocado = partida.tocado == objetivo.id;
    final nombre = context.traducir(objetivo.nombre);
    return Semantics(
      label: hecho
          ? context.traducir('Encontrado: {0}').replaceFirst('{0}', nombre)
          : actual
          ? context.traducir('Busca: {0}').replaceFirst('{0}', nombre)
          : nombre,
      excludeSemantics: true,
      child: AnimatedContainer(
        key: Key('objetivo-${objetivo.id}'),
        duration: duracionSeleccionPaso(context),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: colores.superficie(
            hecho
                ? const Color(0xFFECFDF3)
                : actual
                ? const Color(0xFFFEF9C3)
                : Colors.white,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: colores.borde(
              hecho
                  ? EstilosJuego.acierto
                  : tocado
                  ? EstilosJuego.fallo
                  : actual
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFE2DEC9),
            ),
            width: actual || hecho ? 3 : 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            hecho
                ? Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: colores.contenido(EstilosJuego.acierto),
                  )
                : Texto(
                    '$numero',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: colores.contenido(const Color(0xFF92400E)),
                    ),
                  ),
            const SizedBox(width: 6),
            Texto(
              objetivo.nombre,
              style: TextStyle(
                fontWeight: actual ? FontWeight.w900 : FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _escena(PartidaLinterna partida, EscenaLinterna escena, double ancho) {
    final nivel = partida.nivel;
    final alto = ancho * aspectoEscenaLinterna;
    final size = Size(ancho, alto);
    final encendidas = [
      for (final objetivo in escena.objetivos)
        if (partida.encontrado(objetivo.id)) ...objetivo.zonas,
    ];
    final buscado = partida.buscado;
    final zonas = [
      for (final objetivo in escena.objetivos)
        for (var i = 0; i < objetivo.zonas.length; i++)
          (objetivo, i, objetivo.zonas[i]),
    ]..sort((a, b) => (a.$3.y - b.$3.y).sign.toInt());
    return Semantics(
      container: true,
      label: partida.iluminada || buscado == null
          ? context.traducir('Dibujo iluminado.')
          : context
                .traducir(
                  'Dibujo a oscuras. Arrastra para mover la luz y toca para buscar {0}.',
                )
                .replaceFirst('{0}', context.traducir(buscado.nombre)),
      child: GestureDetector(
        key: const Key('linterna-escena'),
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _moverLuz(d.localPosition, size),
        onPanUpdate: (d) => _moverLuz(d.localPosition, size),
        onTapUp: (d) => _tocar(d.localPosition, size),
        child: Container(
          width: ancho,
          height: alto,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: context.coloresNaturales.borde(
                partida.iluminada
                    ? EstilosJuego.acierto
                    : const Color(0xFF334155),
              ),
              width: 3,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: EscenaLinternaPintor(escena.dibujo),
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: partida.iluminada ? 0 : 1,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 600),
                  child: CustomPaint(
                    painter: OscuridadLinternaPintor(
                      herramienta: nivel.herramienta,
                      luz: _luz,
                      radio: nivel.luz,
                      encendidas: encendidas,
                    ),
                  ),
                ),
              ),
              for (final objetivo in escena.objetivos)
                if (partida.encontrado(objetivo.id))
                  _marca(objetivo, size, nombre: partida.iluminada),
              // Zonas para quien usa un lector de pantalla. El toque llega
              // siempre al dibujo, que decide por la posición.
              for (var n = 0; n < zonas.length; n++)
                _zonaAccesible(partida, zonas[n], n + 1, size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _marca(ObjetivoLinterna objetivo, Size size, {required bool nombre}) {
    final zona = objetivo.zonas.first;
    const lado = 26.0;
    return Positioned(
      left: zona.x * size.width - lado / 2,
      top: zona.y * size.height - lado / 2,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: lado,
                height: lado,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EstilosJuego.acierto,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              if (nombre)
                Container(
                  margin: const EdgeInsets.only(left: 3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Texto(
                    objetivo.nombre,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF14532D),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zonaAccesible(
    PartidaLinterna partida,
    (ObjetivoLinterna, int, ZonaLinterna) entrada,
    int numero,
    Size size,
  ) {
    final (objetivo, indice, zona) = entrada;
    final lado = zona.r * size.width * 2;
    final centro = Offset(zona.x * size.width, zona.y * size.height);
    final hecho = partida.encontrado(objetivo.id);
    return Positioned(
      left: centro.dx - lado / 2,
      top: centro.dy - lado / 2,
      width: lado,
      height: lado,
      child: Semantics(
        key: Key('zona-${objetivo.id}-$indice'),
        container: true,
        button: !hecho,
        label: hecho
            ? context
                  .traducir('Zona {0}: {1}')
                  .replaceFirst('{0}', '$numero')
                  .replaceFirst('{1}', context.traducir(objetivo.nombre))
            : context.traducir('Zona {0}').replaceFirst('{0}', '$numero'),
        onTap: _quieta ? null : () => _tocar(centro, size),
        // Se deja tocar para que las pruebas lleguen aquí, pero el toque lo
        // recoge el dibujo, que está debajo.
        child: const Listener(
          behavior: HitTestBehavior.opaque,
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}
