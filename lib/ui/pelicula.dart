import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/pelicula.dart';
import 'package:naturalmente/reglas/pelicula.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_pelicula.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/nivel_recomendado.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

const _cinta = Color(0xFF1F2937);
const _cintaClara = Color(0xFF374151);

/// «La película de la planta»: una tira de fotogramas vacía y una bandeja de
/// cartas. Se llena la tira en orden y, al terminar, se proyecta la vida de
/// la planta.
class PeliculaPage extends StatefulWidget {
  const PeliculaPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<PeliculaPage> createState() => _PeliculaPageState();
}

class _PeliculaPageState extends State<PeliculaPage>
    with FeedbackAcierto<PeliculaPage> {
  PartidaPelicula? _partida;
  bool _guardando = false;
  bool _guardado = false;
  int _vuelta = 0;

  /// Lo que dice Natu al tocar una carta que ya está en la tira.
  String? _aviso;

  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Pelicula get _pelicula => widget.actividad.pelicula!;

  void _empezar(NivelPelicula nivel) {
    ocultarAcierto();
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    setState(() {
      _vuelta += 1;
      _partida = PartidaPelicula(nivel: nivel);
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
        partida.proyectando ||
        pasoBloqueado;
  }

  void _poner(String cartaId) {
    final partida = _partida;
    if (partida == null || _quieta) return;
    if (partida.puesta(cartaId)) {
      context.sonidoToque();
      setState(() => _aviso = 'Esa carta ya está en la tira. Elige otra.');
      return;
    }
    if (!iniciarPasoEvaluado()) return;
    final estabaCompleta = partida.completa;
    late JugadaPelicula jugada;
    setState(() {
      _aviso = null;
      jugada = partida.poner(cartaId);
    });
    switch (jugada) {
      case JugadaPelicula.acierto:
        _registrarPasoPrecision(true);
        if (partida.completa && !estabaCompleta) {
          mostrarAcierto(finalDeNivel: true);
          _guardarSiCompleta();
        } else if (partida.proyectando) {
          // Se deja ver la película antes de pasar al rollo siguiente.
          confirmarPaso(
            alContinuar: () {
              partida.siguiente();
              _aviso = null;
            },
            esperarContinuar: true,
          );
        } else {
          confirmarPaso(alContinuar: () {}, conservarTablero: true);
        }
      case JugadaPelicula.fallo:
        _registrarPasoPrecision(false);
        terminarIntentoConPista();
        context.sonidoPista();
      case JugadaPelicula.nada:
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

  void _mostrarCuriosidad(NivelPelicula nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(widget.actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? 'semilla-brote-planta' : fichas.first;
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
        _pelicula.niveles,
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
    final niveles = _pelicula.niveles;
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
    NivelPelicula nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final colores = context.coloresNaturales;
    final rollo = nivel.rollos.first;
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
                // Una tira corta con el primer y el último fotograma.
                ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _cinta,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final f in [
                          rollo.fotogramas.first,
                          rollo.fotogramas.last,
                        ]) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: DibujoPelicula(
                              planta: rollo.planta,
                              fase: rollo.carta(f.id)!.fase,
                              tamano: 40,
                            ),
                          ),
                          if (f != rollo.fotogramas.last)
                            const SizedBox(width: 3),
                        ],
                      ],
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

  // --- La tira y la bandeja ---

  Widget _juego(PartidaPelicula partida, double ancho) {
    final nivel = partida.nivel;
    final rollo = partida.rolloActual;
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
            key: const Key('pelicula-progreso'),
            value: partida.progreso,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            semanticsLabel: context.traducir('Progreso de la película'),
            semanticsValue: '${(partida.progreso * 100).round()} %',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Texto(
                'Rollos: ${partida.rollosHechos} de ${nivel.rollos.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            if (rollo != null) ...[
              Icon(
                Icons.movie_creation_rounded,
                size: 18,
                color: context.coloresNaturales.contenido(
                  const Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 4),
              Texto(
                rollo.titulo,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (rollo != null) ...[
          Center(child: _pantalla(partida, rollo, math.min(ancho, 360))),
          const SizedBox(height: 12),
          _tira(partida, rollo, ancho),
          const SizedBox(height: 14),
          _bandeja(partida, rollo, ancho),
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
            key: const Key('curiosidad-pelicula'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('pelicula-cambiar-nivel'),
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

  /// La pantalla grande: el último fotograma puesto o, al terminar, la
  /// película entera de uno en uno.
  Widget _pantalla(PartidaPelicula partida, RolloPelicula rollo, double ancho) {
    final alto = ancho * .62;
    final puestas = partida.puestas;
    final hueco = partida.hueco;
    Widget contenido;
    if (partida.proyectando) {
      final total = rollo.fotogramas.length;
      final sinMovimiento = MediaQuery.disableAnimationsOf(context);
      contenido = TweenAnimationBuilder<double>(
        key: ValueKey('proyeccion-${rollo.id}-$_vuelta'),
        tween: Tween(begin: sinMovimiento ? total - 1.0 : 0, end: total - 1.0),
        duration: sinMovimiento
            ? Duration.zero
            : Duration(milliseconds: 750 * total),
        builder: (context, valor, _) {
          final i = valor.round().clamp(0, total - 1);
          return _imagenPantalla(
            rollo,
            rollo.fotogramas[i].id,
            alto,
            etiqueta: '${i + 1} / $total',
          );
        },
      );
    } else if (puestas.isNotEmpty) {
      contenido = _imagenPantalla(rollo, puestas.last, alto);
    } else {
      contenido = const SizedBox.shrink();
    }
    final leyenda = partida.proyectando
        ? context.traducir('Proyectando la película')
        : hueco == null
        ? ''
        : context
              .traducir('Fotograma {0}: ¿qué viene ahora?')
              .replaceFirst('{0}', '${hueco + 1}');
    return Semantics(
      container: true,
      liveRegion: true,
      label: leyenda,
      child: Container(
        key: const Key('pelicula-pantalla'),
        width: ancho,
        height: alto,
        decoration: BoxDecoration(
          color: _cinta,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: partida.proyectando ? const Color(0xFFFACC15) : _cintaClara,
            width: 4,
          ),
          boxShadow: [
            if (partida.proyectando)
              const BoxShadow(color: Color(0x66FACC15), blurRadius: 18),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(child: Center(child: contenido)),
            if (!partida.proyectando && hueco != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: ExcludeSemantics(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        leyenda,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (puestas.isEmpty && !partida.proyectando)
              const Positioned.fill(
                child: Center(
                  child: Icon(
                    Icons.movie_filter_rounded,
                    size: 56,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagenPantalla(
    RolloPelicula rollo,
    String cartaId,
    double alto, {
    String? etiqueta,
  }) {
    final carta = rollo.carta(cartaId)!;
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: DibujoPelicula(
            planta: rollo.planta,
            fase: carta.fase,
            tamano: alto - 20,
          ),
        ),
        if (etiqueta != null)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                etiqueta,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// La cinta de fotogramas. Solo el que toca acepta cartas.
  Widget _tira(PartidaPelicula partida, RolloPelicula rollo, double ancho) {
    final total = rollo.fotogramas.length;
    const separacion = 5.0;
    final lado = math.min(
      84.0,
      (ancho - 20 - separacion * (total - 1)) / total,
    );
    final hueco = partida.hueco;
    final puestas = partida.puestas;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _cinta,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _perforaciones(total, lado, separacion),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < total; i++) ...[
                    _fotograma(
                      partida,
                      rollo,
                      i,
                      lado,
                      puesta: i < puestas.length ? puestas[i] : null,
                      actual: i == hueco,
                    ),
                    if (i < total - 1) const SizedBox(width: separacion),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              _perforaciones(total, lado, separacion),
            ],
          ),
        ),
        if (rollo.rueda)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.replay_rounded,
                  size: 18,
                  color: context.coloresNaturales.contenido(
                    const Color(0xFF15803D),
                  ),
                ),
                const SizedBox(width: 4),
                Texto(
                  'Y vuelta a empezar',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: context.coloresNaturales.contenido(
                      const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _perforaciones(int total, double lado, double separacion) {
    final ancho = total * lado + (total - 1) * separacion;
    final agujeros = (ancho / 12).floor();
    return ExcludeSemantics(
      child: SizedBox(
        width: ancho,
        height: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < agujeros; i++)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fotograma(
    PartidaPelicula partida,
    RolloPelicula rollo,
    int indice,
    double lado, {
    required String? puesta,
    required bool actual,
  }) {
    final carta = puesta == null ? null : rollo.carta(puesta);
    final etiqueta = carta != null
        ? context
              .traducir('Fotograma {0}: {1}')
              .replaceFirst('{0}', '${indice + 1}')
              .replaceFirst('{1}', context.traducir(carta.nombre))
        : actual
        ? context
              .traducir('Fotograma {0}, el que toca ahora')
              .replaceFirst('{0}', '${indice + 1}')
        : context
              .traducir('Fotograma {0}, vacío')
              .replaceFirst('{0}', '${indice + 1}');
    return Semantics(
      label: etiqueta,
      excludeSemantics: true,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (_) => actual && !_quieta,
        onAcceptWithDetails: (d) => _poner(d.data),
        builder: (context, candidatas, _) {
          final encima = candidatas.isNotEmpty;
          return AnimatedContainer(
            key: Key('fotograma-$indice'),
            duration: duracionSeleccionPaso(context),
            width: lado,
            height: lado,
            decoration: BoxDecoration(
              color: carta != null
                  ? Colors.white
                  : actual
                  ? (encima ? const Color(0xFFFEF08A) : const Color(0xFF4B5563))
                  : const Color(0xFF111827),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: actual
                    ? const Color(0xFFFACC15)
                    : carta != null
                    ? EstilosJuego.acierto
                    : _cintaClara,
                width: actual ? 3 : 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: carta != null
                ? DibujoPelicula(
                    planta: rollo.planta,
                    fase: carta.fase,
                    tamano: lado,
                  )
                : Center(
                    child: Text(
                      actual ? '?' : '${indice + 1}',
                      style: TextStyle(
                        color: actual
                            ? const Color(0xFFFACC15)
                            : const Color(0xFF6B7280),
                        fontSize: actual ? lado * .4 : lado * .25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// Las cartas en su sitio fijo. Una carta puesta deja su hueco vacío.
  Widget _bandeja(PartidaPelicula partida, RolloPelicula rollo, double ancho) {
    final total = rollo.bandeja.length;
    final columnas = total <= 3 ? 3 : (total <= 6 ? 3 : 4);
    const separacion = 8.0;
    final lado = (ancho - separacion * (columnas - 1)) / columnas;
    final colores = context.coloresNaturales;
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
      child: LayoutBuilder(
        builder: (context, restricciones) {
          final interior = restricciones.maxWidth;
          final ladoCarta = math.min(
            lado,
            (interior - separacion * (columnas - 1)) / columnas,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.style_rounded,
                    size: 16,
                    color: colores.contenido(const Color(0xFFB45309)),
                  ),
                  const SizedBox(width: 6),
                  Texto(
                    'Cartas',
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
                spacing: separacion,
                runSpacing: separacion,
                children: [
                  for (final carta in rollo.bandeja)
                    _carta(partida, rollo, carta, ladoCarta),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _carta(
    PartidaPelicula partida,
    RolloPelicula rollo,
    CartaPelicula carta,
    double lado,
  ) {
    final colores = context.coloresNaturales;
    final puesta = partida.puesta(carta.id);
    final fallada = partida.fallada == carta.id;
    // Las cartas estrechas (cuatro por fila) tienen nombres largos, como
    // «El viento lleva el polen»: les damos una línea más para que no se corten.
    final lineas = lado < 100 ? 3 : 2;
    final alto = lado + 8 + 13 * lineas;
    if (puesta) {
      return Semantics(
        label: context.traducir('Carta ya puesta'),
        child: Container(
          width: lado,
          height: alto,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colores.borde(const Color(0xFFE2DEC9)),
              width: 2,
            ),
          ),
        ),
      );
    }
    final cara = Container(
      width: lado,
      height: alto,
      decoration: BoxDecoration(
        color: colores.superficie(Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colores.borde(
            fallada ? EstilosJuego.fallo : const Color(0xFFE2DEC9),
          ),
          width: fallada ? 3 : 2,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: DibujoPelicula(
              planta: rollo.planta,
              fase: carta.fase,
              tamano: lado - 10,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Center(
              child: Texto(
                carta.nombre,
                textAlign: TextAlign.center,
                maxLines: lineas,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      label: context
          .traducir('Carta: {0}')
          .replaceFirst('{0}', context.traducir(carta.nombre)),
      excludeSemantics: true,
      onTap: _quieta ? null : () => _poner(carta.id),
      child: Draggable<String>(
        key: Key('carta-${carta.id}'),
        data: carta.id,
        maxSimultaneousDrags: _quieta ? 0 : 1,
        feedback: Material(
          color: Colors.transparent,
          child: Opacity(opacity: .9, child: cara),
        ),
        childWhenDragging: Opacity(opacity: .35, child: cara),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _poner(carta.id),
          child: cara,
        ),
      ),
    );
  }
}
