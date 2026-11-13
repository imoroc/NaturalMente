import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/texto.dart';

/// Datos de un nivel que necesita el armazón común de los juegos propios.
class NivelJuegoPropio {
  const NivelJuegoPropio({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.curiosidad,
    required this.muestras,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String curiosidad;

  /// Dibujos pequeños que salen en la tarjeta del nivel.
  final List<Widget> muestras;
}

/// Armazón común de «Memoria de las plantas» y «¿Quién soy?»: selector de
/// nivel, precisión y semillas, curiosidad, guardado y cierre con
/// [FeedbackAcierto] y [FinJuego], igual que en los demás juegos propios.
///
/// Cada juego implementa la partida ([construirJuego]) y avisa de cada jugada
/// evaluada con [registrarJugada].
mixin JuegoPropio<T extends StatefulWidget> on State<T>, FeedbackAcierto<T> {
  Actividad get actividad;
  List<NivelJuegoPropio> get nivelesJuego;

  /// Nivel en juego, o null en el selector.
  String? get nivelActual;
  bool get partidaCompleta;

  /// Prepara una partida nueva del nivel. Se llama ya dentro de setState.
  void iniciarPartida(String nivelId);

  /// Quita la partida y vuelve al selector. Se llama ya dentro de setState.
  void quitarPartida();

  Widget construirJuego(BuildContext context, double ancho);

  String get volverA;

  bool _guardando = false;
  bool _guardado = false;
  int _vuelta = 0;
  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  NivelJuegoPropio get _nivel =>
      nivelesJuego.firstWhere((n) => n.id == nivelActual);

  void empezar(String nivelId) {
    ocultarAcierto();
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    setState(() {
      _vuelta += 1;
      iniciarPartida(nivelId);
      _guardado = false;
      _comboActual = comboGlobal;
      _mejorComboSesion = comboGlobal;
      _semillasSesion = 0;
      _pistaEnPaso = false;
      _pistasSesion = 0;
    });
  }

  /// Marca que en esta jugada se ha usado ayuda, sin contarla como fallo.
  void usarAyuda() {
    if (_pistaEnPaso) return;
    setState(() {
      _pistaEnPaso = true;
      _pistasSesion++;
    });
  }

  /// Se llama después de cada jugada evaluada, con la partida ya cambiada.
  void registrarJugada({required bool acierto, required bool estabaCompleta}) {
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
    if (partidaCompleta && !estabaCompleta) {
      mostrarAcierto(finalDeNivel: true);
      _guardarSiCompleta();
    } else if (acierto) {
      mostrarAcierto();
    } else {
      context.sonidoPista();
    }
  }

  Future<void> _guardarSiCompleta() async {
    if (_guardando || _guardado) return;
    await registrarGuardadoFinal(() async {
      await _persistirFinal();
      return _guardado;
    });
  }

  Future<void> _persistirFinal() async {
    final nivelId = nivelActual;
    if (nivelId == null || !partidaCompleta || _guardando || _guardado) return;
    final progreso = Alcance.of(context).progreso;
    setState(() => _guardando = true);
    try {
      await progreso.marcarNivelJuego(actividad, nivelId);
      if (mounted) setState(() => _guardado = true);
    } catch (_) {
      // El componente común FinJuego gestiona el reintento si falla el guardado.
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _cambiarNivel() {
    ocultarAcierto();
    setState(quitarPartida);
  }

  @override
  DatosFinJuego? construirFinJuego() {
    final nivelId = nivelActual;
    if (nivelId == null || !partidaCompleta) return null;
    return DatosFinJuego(
      actividad: actividad.titulo,
      nivel: _nivel.nombre,
      resumen: ResumenPrecisionFinal(
        semillasGanadas: _semillasSesion,
        mejorComboSesion: _mejorComboSesion,
        sinPistas: _pistasSesion == 0,
      ),
      onRepetir: () => empezar(nivelId),
      onCambiarNivel: _cambiarNivel,
      onVolver: () => Navigator.of(context).pop(),
    );
  }

  Widget construirPagina(BuildContext context) {
    final enJuego = nivelActual != null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Texto(
          actividad.titulo,
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
            key: ValueKey('${nivelActual ?? 'selector'}-$_vuelta'),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: enJuego
                    ? _juego(context, constraints.maxWidth - 32)
                    : _selector(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _juego(BuildContext context, double ancho) {
    final nivel = _nivel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          '${nivel.nombre} · Pensado para ${nivel.curso}. Puedes jugarlo igual.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        construirJuego(context, ancho.clamp(0, 780).toDouble()),
        if (partidaCompleta) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: Key('curiosidad-${actividad.id}'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(context, nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: Key('${actividad.id}-cambiar-nivel'),
          style: EstilosJuego.accion,
          onPressed: _guardando ? null : _cambiarNivel,
          child: const Texto('Cambiar nivel'),
        ),
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(),
          child: Texto(volverA),
        ),
      ],
    );
  }

  Widget _selector(BuildContext context) {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichasCatalogo = {
      for (final f in alcance.catalogo.fichas) f.id: f.titulo,
    };
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: actividad.quien,
            frase: actividad.intro,
            gesto: 'hola',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < nivelesJuego.length; i++) ...[
            _tarjetaNivel(
              context,
              nivelesJuego[i],
              estrellas: i + 1,
              hecho: progreso.nivelJuegoHecho(actividad, nivelesJuego[i].id),
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
    BuildContext context,
    NivelJuegoPropio nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    return TarjetaJuego(
      claveAccion: Key('nivel-${nivel.id}'),
      borde: context.coloresNaturales.borde(
        hecho ? EstilosJuego.acierto : const Color(0xFF4ADE80),
      ),
      sombra: context.coloresNaturales.sombra(
        hecho ? const Color(0xFF239E56) : const Color(0xFF15803D),
      ),
      radio: 20,
      onTap: () => empezar(nivel.id),
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
            const SizedBox(height: 8),
            Row(
              children: [
                for (final m in nivel.muestras) ...[
                  m,
                  const SizedBox(width: 4),
                ],
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
                  actividad.id,
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
                  color: context.coloresNaturales.contenido(Color(0xFF15803D)),
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

  void _mostrarCuriosidad(BuildContext context, NivelJuegoPropio nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? '' : fichas.first;
    final titulo =
        Alcance.of(context).catalogo.fichas
            .where((f) => f.id == fichaId)
            .firstOrNull
            ?.titulo ??
        actividad.titulo;
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
                              Color(0xFF15803D),
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
}
