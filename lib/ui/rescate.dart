import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/rescate.dart';
import 'package:naturalmente/reglas/rescate.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_rescate.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/texto.dart';

/// Animales de la escena que ya tienen dibujo en los juegos nuevos.
const _animalesEscena = {'pez': 'trucha-arroyo', 'rana': 'rana-charca'};

class RescatePage extends StatefulWidget {
  const RescatePage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<RescatePage> createState() => _RescatePageState();
}

class _RescatePageState extends State<RescatePage>
    with FeedbackAcierto<RescatePage> {
  PartidaRescate? _partida;
  bool _guardando = false;
  bool _guardado = false;
  int _vuelta = 0;
  final Map<String, List<Opcion>> _opciones = {};
  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Rescate get _rescate => widget.actividad.rescate!;

  void _empezar(NivelRescate nivel) {
    ocultarAcierto();
    final opciones = <String, List<Opcion>>{};
    for (final especie in nivel.especies) {
      for (final (paso, pregunta) in [
        ('amenaza', especie.amenaza),
        ('ayuda', especie.ayuda),
      ]) {
        opciones['${especie.id}-$paso'] =
            BarajadorOpciones.barajarConRespuesta<Opcion>(
              clave: 'rescate-${especie.id}-$paso',
              opciones: pregunta.opciones,
              idDe: (o) => o.id,
              respuestaCorrecta: pregunta.respuesta,
            );
      }
    }
    final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
    setState(() {
      _vuelta += 1;
      _partida = PartidaRescate(nivel: nivel);
      _opciones
        ..clear()
        ..addAll(opciones);
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

  void _cambiar(void Function(PartidaRescate partida) accion) {
    final partida = _partida!;
    final estabaCompleta = partida.completa;
    if (estabaCompleta) return;
    setState(() => accion(partida));
    final resultado = partida.resultado;
    if (resultado == null) return;
    _registrarPasoPrecision(resultado.acierto);
    if (partida.completa && !estabaCompleta) {
      mostrarAcierto(finalDeNivel: true);
      _guardarSiCompleta();
    } else if (resultado.acierto) {
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
    final partida = _partida;
    if (partida == null || !partida.completa || _guardando || _guardado) {
      return;
    }
    final progreso = Alcance.of(context).progreso;
    setState(() => _guardando = true);
    try {
      await progreso.marcarNivelJuego(widget.actividad, partida.nivel.id);
      if (mounted) setState(() => _guardado = true);
    } catch (_) {
      // El componente común FinJuego gestiona el reintento si falla el guardado.
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarCuriosidad(NivelRescate nivel) {
    context.sonidoDescubrimiento();
    final fichas = Progreso.fichasDeNivel(widget.actividad.id, nivel.id);
    final fichaId = fichas.isEmpty ? 'menos-plasticos' : fichas.first;
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
  DatosFinJuego? construirFinJuego() {
    if (!(_partida?.completa == true)) return null;
    final nivel = _partida!.nivel;
    return DatosFinJuego(
      actividad: widget.actividad.titulo,
      nivel: nivel.nombre,
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
            combo: _comboActual,
            semillasSesion: _semillasSesion,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            // Al cambiar de nivel o de vuelta la pantalla vuelve arriba.
            key: ValueKey('${partida?.nivel.id ?? 'selector'}-$_vuelta'),
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
    final niveles = _rescate.niveles;
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
    NivelRescate nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final muestras = <Widget>[
      if (nivel.esEscena) ...[
        const DibujoResiduo(id: 'botella', tamano: 38),
        const DibujoResiduo(id: 'lata', tamano: 38),
      ],
      if (nivel.esContenedores) ...[
        const DibujoContenedor(id: 'amarillo', tamano: 38),
        const DibujoContenedor(id: 'azul', tamano: 38),
      ],
      if (nivel.esEspecies) ...[
        const DibujoNuevoJuego(id: 'lince-cazador', tamano: 38),
        const DibujoNuevoJuego(id: 'oso-pardo', tamano: 38),
      ],
    ];
    return TarjetaJuego(
      claveAccion: Key('nivel-${nivel.id}'),
      borde: hecho ? EstilosJuego.acierto : const Color(0xFF4ADE80),
      sombra: hecho ? const Color(0xFF239E56) : const Color(0xFF15803D),
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

  Widget _juego(PartidaRescate partida, double ancho) {
    final nivel = partida.nivel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          '${nivel.nombre} · Pensado para ${nivel.curso}. Puedes jugarlo igual.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          key: const Key('rescate-progreso'),
          value: partida.progreso,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          semanticsLabel: context.traducir('Progreso de la reserva'),
          semanticsValue: '${(partida.progreso * 100).round()} %',
        ),
        const SizedBox(height: 12),
        if (nivel.esEscena) ..._escena(partida, ancho),
        if (nivel.esContenedores) ..._contenedores(partida, ancho),
        if (nivel.esEspecies) ..._especies(partida),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Burbuja(
            quien: widget.actividad.quien,
            frase: partida.resultado?.frase ?? nivel.intro,
            gesto: partida.resultado?.gesto ?? 'hola',
          ),
        ),
        if (partida.completa) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('curiosidad-rescate'),
            style: EstilosJuego.accion,
            onPressed: () => _mostrarCuriosidad(nivel),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Texto('Ver curiosidad'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(
          key: const Key('rescate-cambiar-nivel'),
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
          child: const Texto('Volver a La reserva'),
        ),
      ],
    );
  }

  // --- Fácil: la escena del bosque y el río ---

  List<Widget> _escena(PartidaRescate partida, double ancho) {
    final nivel = partida.nivel;
    final alto = math.min(ancho * .72, 420.0);
    final tamano = math.max(44.0, math.min(64.0, ancho / 7));
    return [
      Texto(
        'Basura recogida: ${partida.basuraRecogida} de ${partida.basuraTotal}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: alto,
          child: Stack(
            children: [
              const Positioned.fill(child: EscenaReserva()),
              for (final objeto in nivel.objetos)
                Positioned(
                  left: objeto.x * (ancho - tamano),
                  top: objeto.y * (alto - tamano),
                  width: tamano,
                  height: tamano,
                  child: _objetoEscena(partida, objeto, tamano),
                ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _objetoEscena(
    PartidaRescate partida,
    ObjetoEscena objeto,
    double tamano,
  ) {
    final recogido = partida.recogido(objeto.id);
    final fallo =
        partida.resultado?.acierto == false &&
        partida.ultimaEleccion == objeto.id;
    final animal = _animalesEscena[objeto.id];
    return IgnorePointer(
      ignoring: recogido,
      child: AnimatedOpacity(
        opacity: recogido ? 0 : 1,
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 350,
        ),
        child: Semantics(
          button: true,
          label: context.traducir(objeto.nombre),
          child: GestureDetector(
            key: Key('objeto-${objeto.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: () => _cambiar((p) => p.tocar(objeto.id)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: fallo
                    ? Border.all(color: EstilosJuego.fallo, width: 3)
                    : null,
              ),
              child: animal == null
                  ? DibujoResiduo(id: objeto.id, tamano: tamano)
                  : DibujoNuevoJuego(id: animal, tamano: tamano),
            ),
          ),
        ),
      ),
    );
  }

  // --- Medio: los contenedores ---

  List<Widget> _contenedores(PartidaRescate partida, double ancho) {
    final nivel = partida.nivel;
    final residuo = partida.residuoActual;
    final enColumna = ancho < 420;
    return [
      Texto(
        'Residuos separados: ${partida.residuosColocados} de ${nivel.residuos.length}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      if (residuo != null)
        Center(
          child: Draggable<String>(
            data: residuo.id,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.translate(
                offset: const Offset(-40, -40),
                child: DibujoResiduo(id: residuo.id, tamano: 80),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: .35,
              child: _tarjetaResiduo(residuo),
            ),
            child: _tarjetaResiduo(residuo),
          ),
        ),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: enColumna ? 2 : 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .95,
        children: [
          for (final contenedor in nivel.contenedores)
            _botonContenedor(partida, contenedor),
        ],
      ),
    ];
  }

  Widget _tarjetaResiduo(Residuo residuo) {
    return Container(
      key: ValueKey('residuo-${residuo.id}'),
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Color(0xFFD0C9B8), offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DibujoResiduo(id: residuo.id, tamano: 84),
          const SizedBox(height: 4),
          Texto(
            residuo.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _botonContenedor(PartidaRescate partida, Opcion contenedor) {
    final fallo =
        partida.resultado?.acierto == false &&
        partida.ultimaEleccion == contenedor.id;
    final (claro, oscuro) = coloresContenedor(contenedor.id);
    return DragTarget<String>(
      onAcceptWithDetails: (_) => _cambiar((p) => p.tirar(contenedor.id)),
      builder: (context, candidatos, _) {
        final encima = candidatos.isNotEmpty;
        return Semantics(
          button: true,
          label: context.traducir(contenedor.nombre),
          child: TarjetaJuego(
            claveAccion: Key('contenedor-${contenedor.id}'),
            onTap: () => _cambiar((p) => p.tirar(contenedor.id)),
            borde: fallo
                ? EstilosJuego.fallo
                : encima
                ? EstilosJuego.acierto
                : oscuro,
            fondo: claro.withValues(alpha: encima ? .55 : .25),
            destacada: encima || fallo,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: DibujoContenedor(id: contenedor.id, tamano: 90),
                  ),
                  Texto(
                    contenedor.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Difícil: especies amenazadas ---

  List<Widget> _especies(PartidaRescate partida) {
    final nivel = partida.nivel;
    final especie = partida.especieActual;
    if (especie == null) {
      return [
        Texto(
          'Especies ayudadas: ${nivel.especies.length} de ${nivel.especies.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ];
    }
    final paso = partida.preguntaAyuda ? 'ayuda' : 'amenaza';
    final pregunta = partida.preguntaAyuda ? especie.ayuda : especie.amenaza;
    final opciones = _opciones['${especie.id}-$paso'] ?? pregunta.opciones;
    return [
      Texto(
        'Especies ayudadas: ${partida.especiesAyudadas} de ${nivel.especies.length}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF4ADE80), width: 2.5),
        ),
        child: Row(
          children: [
            DibujoNuevoJuego(id: especie.dibujo, tamano: 92),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Texto(
                    especie.nombre,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Texto(especie.presentacion),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Texto(
        partida.preguntaAyuda ? 'Qué la ayuda' : 'Qué la amenaza',
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
        key: Key('pregunta-${especie.id}-$paso'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      for (final opcion in opciones) ...[
        FilledButton.tonal(
          key: Key('respuesta-${especie.id}-${opcion.id}'),
          style: EstilosJuego.respuesta,
          onPressed: () => _cambiar((p) => p.responder(opcion.id)),
          child: Texto(opcion.nombre),
        ),
        const SizedBox(height: 8),
      ],
    ];
  }
}
