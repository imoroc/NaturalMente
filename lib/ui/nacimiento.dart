import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/nacimiento.dart';
import 'package:naturalmente/reglas/nacimiento.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/dibujos_nacimiento.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/texto.dart';

class NacimientoPage extends StatefulWidget {
  const NacimientoPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<NacimientoPage> createState() => _NacimientoPageState();
}

class _NacimientoPageState extends State<NacimientoPage>
    with FeedbackAcierto<NacimientoPage> {
  NivelNacimiento? _nivel;
  PartidaClasificar? _clasificar;
  PartidaCiclos? _ciclos;
  final _pregunta = GlobalKey();
  bool _guardando = false;
  bool _guardado = false;
  bool _falloGuardado = false;
  int _ronda = 0;
  List<String> _animalesBandeja = const [];
  final Map<String, List<Opcion>> _pasosBandeja = {};
  final Map<String, List<Opcion>> _opcionesPregunta = {};
  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _semillasSesion = 0;
  bool _pistaEnPaso = false;
  int _pistasSesion = 0;

  Nacimiento get _nacimiento => widget.actividad.nacimiento!;

  bool get _completa =>
      _clasificar?.completa == true || _ciclos?.completa == true;

  void _empezar(NivelNacimiento nivel) {
    ocultarAcierto();
    final pasos = <String, List<Opcion>>{};
    final opciones = <String, List<Opcion>>{};
    for (final ciclo in nivel.ciclos) {
      pasos[ciclo.id] = BarajadorOpciones.barajarPasos(
        clave: 'nacimiento-pasos-${nivel.id}-${ciclo.id}',
        pasos: ciclo.pasos,
        ordenCorrecto: ciclo.respuesta,
      );
      opciones[ciclo.id] = BarajadorOpciones.barajarConRespuesta<Opcion>(
        clave: 'nacimiento-pregunta-${nivel.id}-${ciclo.id}',
        opciones: ciclo.pregunta.opciones,
        idDe: (o) => o.id,
        respuestaCorrecta: ciclo.pregunta.respuesta,
      );
    }
    setState(() {
      _ronda += 1;
      _nivel = nivel;
      _clasificar = nivel.ordenaCiclos
          ? null
          : PartidaClasificar(nacimiento: _nacimiento, nivel: nivel);
      _ciclos = nivel.ordenaCiclos ? PartidaCiclos(nivel: nivel) : null;
      _animalesBandeja = BarajadorOpciones.barajarIds(
        clave: 'nacimiento-animales-${nivel.id}',
        ids: nivel.animales,
      );
      _pasosBandeja
        ..clear()
        ..addAll(pasos);
      _opcionesPregunta
        ..clear()
        ..addAll(opciones);
      final comboGlobal = Alcance.maybeOf(context)?.progreso.comboActual ?? 0;
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

  void _salirAlSelector() {
    ocultarAcierto();
    context.sonidoToque();
    setState(() {
      _nivel = null;
      _clasificar = null;
      _ciclos = null;
    });
  }

  Future<void> _guardarSiCompleta() async {
    if (_guardando || _guardado) return;
    await registrarGuardadoFinal(() async {
      await _persistirFinal();
      return _guardado;
    });
  }

  Future<void> _persistirFinal() async {
    final nivel = _nivel;
    if (nivel == null || !_completa || _guardando || _guardado) return;
    final progreso = Alcance.of(context).progreso;
    setState(() {
      _guardando = true;
      _falloGuardado = false;
    });
    try {
      await progreso.marcarNivelJuego(widget.actividad, nivel.id);
      if (mounted) setState(() => _guardado = true);
    } catch (_) {
      if (mounted) setState(() => _falloGuardado = true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
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

  // ----- Fácil: separar animales -----

  void _colocarAnimal(String animal, String nido) {
    setState(() => _clasificar!.colocar(animal, nido));
    final acierto = _clasificar!.resultado?.acierto ?? false;
    _registrarPasoPrecision(acierto);
    if (acierto) {
      if (_completa) {
        mostrarAcierto(finalDeNivel: true);
      } else {
        mostrarAcierto();
      }
    } else {
      context.sonidoPista();
    }
    _verPregunta();
    _guardarSiCompleta();
  }

  void _tocarNido(String nido) {
    final partida = _clasificar!;
    final elegido = partida.seleccionado;
    if (elegido == null) {
      context.sonidoPista();
      setState(() {
        partida.resultado = const Resultado(
          acierto: false,
          frase: 'Elige primero un animal.',
          estado: 'falta',
          gesto: 'hola',
        );
      });
      return;
    }
    _colocarAnimal(elegido, nido);
  }

  // ----- Medio y Difícil: ordenar ciclos -----

  void _comprobarCiclo() {
    setState(() => _ciclos!.comprobar());
    final acierto = _ciclos!.resultado?.acierto ?? false;
    _registrarPasoPrecision(acierto);
    if (acierto) {
      mostrarAcierto();
    } else {
      context.sonidoPista();
    }
    _verPregunta();
  }

  void _responder(String opcion) {
    var acierto = false;
    setState(() {
      _ciclos!.responder(opcion);
      acierto = _ciclos!.resultado?.acierto ?? false;
      if (acierto && _ciclos!.cicloTerminado && _ciclos!.hayOtroCiclo) {
        _ciclos!.siguiente();
      }
    });
    _registrarPasoPrecision(acierto);
    if (acierto) {
      if (_completa) {
        mostrarAcierto(finalDeNivel: true);
      } else {
        mostrarAcierto();
      }
    } else {
      context.sonidoPista();
    }
    _verPregunta();
    _guardarSiCompleta();
  }

  void _mostrarCuriosidad({
    required Widget dibujo,
    required String titulo,
    required String curiosidad,
  }) {
    context.sonidoDescubrimiento();
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
                  dibujo,
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
                frase: curiosidad,
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
    if (!(_completa)) return null;
    final nivel = _nivel!;
    return DatosFinJuego(
      actividad: widget.actividad.titulo,
      nivel: nivel.nombre,
      resumen: ResumenPrecisionFinal(
        semillasGanadas: _semillasSesion,
        mejorComboSesion: _mejorComboSesion,
        sinPistas: _pistasSesion == 0,
      ),
      onRepetir: () => _empezar(nivel),
      onCambiarNivel: _salirAlSelector,
      onVolver: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nivel = _nivel;
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
            // Al cambiar de nivel, de ronda o de ciclo la pantalla vuelve arriba.
            key: ValueKey(
              '${nivel?.id ?? 'selector'}-$_ronda-${_ciclos?.indice ?? 0}',
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: nivel == null
                    ? _selector()
                    : _juego(nivel, math.min(constraints.maxWidth - 32, 780)),
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
    final niveles = _nacimiento.niveles;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: widget.actividad.quien,
            frase: 'Elige un nivel. Cada dificultad desbloquea un cromo sobre cómo nacen y crecen los animales.',
            gesto: 'hola',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < niveles.length; i++) ...[
            _tarjetaNivel(
              niveles[i],
              estrellas: i + 1,
              hecho: progreso.nivelJuegoHecho(
                widget.actividad,
                niveles[i].id,
              ),
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
    NivelNacimiento nivel, {
    required int estrellas,
    required bool hecho,
    required Progreso progreso,
    required Map<String, String> fichasCatalogo,
  }) {
    final etiqueta = switch (nivel.id) {
      'facil' => 'Seis animales para separar',
      'medio' => 'Dos ciclos de vida con pregunta',
      _ => 'Dos metamorfosis con vocabulario científico',
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
              ],
            ),
            Texto(
              'Pensado para ${nivel.curso}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final id in _muestrasNivel(nivel)) ...[
                  DibujoNacimiento(id: id, tamano: 34),
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

  List<String> _muestrasNivel(NivelNacimiento nivel) => switch (nivel.id) {
    'facil' => const ['huevo', 'barriga'],
    'medio' => const ['renacuajo', 'oruga'],
    _ => const ['patas', 'crisalida'],
  };

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

  Widget _juego(NivelNacimiento nivel, double ancho) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          '${nivel.nombre} · Pensado para ${nivel.curso}. Puedes jugarlo igual.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (_clasificar != null)
          ..._juegoClasificar(_clasificar!, ancho)
        else
          ..._juegoCiclos(_ciclos!, ancho),
        if (_completa) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Texto(
              _clasificar != null
                  ? '¡Has separado a todos los animales!'
                  : '¡Has ordenado todos los ciclos de vida!',
              key: const Key('nacimiento-completo'),
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
            key: const Key('nacimiento-otra-vez'),
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
          key: const Key('nacimiento-cambiar-nivel'),
          style: EstilosJuego.accion,
          onPressed: _guardando ? null : _salirAlSelector,
          child: const Texto('Cambiar nivel'),
        ),
        TextButton(
          onPressed: _guardando
              ? null
              : () {
                  context.sonidoToque();
                  Navigator.of(context).pop();
                },
          child: const Texto('Volver a la reserva'),
        ),
      ],
    );
  }

  Widget _barra(double valor) => LinearProgressIndicator(
    key: const Key('nacimiento-progreso'),
    value: valor,
    minHeight: 10,
    borderRadius: BorderRadius.circular(10),
    semanticsLabel: context.traducir('Progreso de ¿Huevo o barriga?'),
    semanticsValue: '${(valor * 100).round()} %',
  );

  Widget _burbuja(Resultado? resultado, String inicial) => Semantics(
    liveRegion: true,
    child: Burbuja(
      quien: widget.actividad.quien,
      frase: resultado?.frase ?? inicial,
      gesto: resultado?.gesto ?? 'hola',
    ),
  );

  List<Widget> _juegoClasificar(PartidaClasificar partida, double ancho) {
    final nivel = partida.nivel;
    final seleccionado = partida.seleccionado;
    return [
      Texto(
        partida.completa
            ? '¡Cada animal está en su sitio!'
            : '¿Nace de un huevo o de la barriga de su madre?',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Semantics(
        liveRegion: true,
        child: Texto(
          'Animales colocados: ${partida.colocados.length} de ${nivel.animales.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 8),
      _barra(partida.progreso),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final nido in _nacimiento.nidos) ...[
            if (nido != _nacimiento.nidos.first) const SizedBox(width: 12),
            Expanded(child: _nido(nido, partida)),
          ],
        ],
      ),
      const SizedBox(height: 12),
      if (!partida.completa) ...[
        Texto(
          seleccionado == null
              ? 'Elige un animal y toca cómo nace, o arrástralo.'
              : 'Seleccionado: ${_nacimiento.animal(seleccionado).nombre}. Toca cómo nace.',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final id
                in _animalesBandeja.isNotEmpty
                    ? _animalesBandeja
                    : nivel.animales)
              if (!partida.colocados.containsKey(id))
                _tarjetaAnimal(_nacimiento.animal(id), partida, ancho),
          ],
        ),
      ],
      if (partida.colocados.isNotEmpty) ...[
        const SizedBox(height: 8),
        const Texto('Toca un animal colocado para leer su curiosidad.'),
      ],
      const SizedBox(height: 12),
      KeyedSubtree(
        key: _pregunta,
        child: _burbuja(partida.resultado, nivel.intro),
      ),
    ];
  }

  Widget _nido(Opcion nido, PartidaClasificar partida) {
    final (fondo, borde) = coloresNacimiento(nido.id);
    final fallo = partida.falloColocacion && partida.ultimoNido == nido.id;
    final colocados = partida.enNido(nido.id);
    return DragTarget<String>(
      onWillAcceptWithDetails: (detalles) =>
          !partida.colocados.containsKey(detalles.data),
      onAcceptWithDetails: (detalles) => _colocarAnimal(detalles.data, nido.id),
      builder: (context, candidatos, _) {
        final encima = candidatos.isNotEmpty;
        final nombres = [
          for (final id in colocados)
            context.traducir(_nacimiento.animal(id).nombre),
        ].join(', ');
        return Semantics(
          button: true,
          label: fallo
              ? context.traducir('${nido.nombre}. Prueba otro sitio')
              : context.traducir(
                  '${nido.nombre}. Colocados: ${colocados.length}',
                ),
          value: nombres,
          child: TarjetaJuego(
            claveAccion: Key('nido-${nido.id}'),
            onTap: () => _tocarNido(nido.id),
            borde: fallo
                ? EstilosJuego.fallo
                : encima || partida.seleccionado != null
                ? Theme.of(context).colorScheme.primary
                : borde,
            fondo: encima ? Colors.white : fondo,
            destacada: encima || partida.seleccionado != null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 170),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        DibujoNacimiento(id: nido.id, tamano: 76),
                        if (fallo)
                          const Positioned(
                            right: -6,
                            top: -6,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: EstilosJuego.fallo,
                              child: Icon(
                                Icons.replay_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Texto(
                      nido.nombre,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Color(0xFF1B3022),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final id in colocados)
                          _animalColocado(_nacimiento.animal(id)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _animalColocado(Reto animal) {
    return Tooltip(
      message: context.traducir(animal.nombre),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('colocado-${animal.id}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => _mostrarCuriosidad(
            dibujo: IlustracionFicha(id: animal.id, alto: 64),
            titulo: animal.nombre,
            curiosidad: animal.curiosidad,
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: IlustracionFicha(id: animal.id, alto: 40),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaAnimal(
    Reto animal,
    PartidaClasificar partida,
    double disponible,
  ) {
    final seleccionado = partida.seleccionado == animal.id;
    final textoGrande = MediaQuery.textScalerOf(context).scale(14) > 20;
    final ancho = textoGrande
        ? math.min(340.0, disponible)
        : math.min(240.0, (disponible - 8) / 2);
    Widget tarjeta({VoidCallback? onTap, Key? clave}) => SizedBox(
      width: ancho,
      child: TarjetaJuego(
        claveAccion: clave,
        onTap: onTap,
        borde: seleccionado
            ? Theme.of(context).colorScheme.primary
            : EstilosJuego.borde,
        fondo: seleccionado
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.white,
        destacada: seleccionado,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                IlustracionFicha(id: animal.id, alto: 46),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Texto(
                        animal.nombre,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (seleccionado)
                        Texto(
                          'Seleccionado',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  seleccionado ? Icons.check_circle : Icons.touch_app_outlined,
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
      data: animal.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () {
        context.sonidoSeleccion();
        setState(() => partida.seleccionar(animal.id));
      },
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: const Offset(-48, -48),
          child: IlustracionFicha(id: animal.id, alto: 96),
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: tarjeta()),
      child: Semantics(
        selected: seleccionado,
        label: context.traducir('Animal ${animal.nombre}'),
        child: tarjeta(
          clave: Key('animal-${animal.id}'),
          onTap: () {
            context.sonidoSeleccion();
            setState(() => partida.seleccionar(animal.id));
          },
        ),
      ),
    );
  }

  List<Widget> _juegoCiclos(PartidaCiclos partida, double ancho) {
    final ciclo = partida.ciclo;
    final total = partida.nivel.ciclos.length;
    final textoGrande = MediaQuery.textScalerOf(context).scale(14) > 20;
    final columnas = textoGrande || ancho < 300 ? 1 : 2;
    final anchoHueco = (ancho - 10 * (columnas - 1)) / columnas;
    final bandeja = _pasosBandeja[ciclo.id] ?? ciclo.pasos;
    final opciones = _opcionesPregunta[ciclo.id] ?? ciclo.pregunta.opciones;
    return [
      Texto(
        'Ciclo ${partida.indice + 1} de $total: ${ciclo.nombre}',
        key: Key('ciclo-${ciclo.id}'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 4),
      Texto(ciclo.intro),
      const SizedBox(height: 8),
      Semantics(
        liveRegion: true,
        child: Texto(
          'Pasos colocados: ${partida.colocados} de ${ciclo.pasos.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      const SizedBox(height: 8),
      _barra(partida.progreso),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < ciclo.pasos.length; i++)
            SizedBox(width: anchoHueco, child: _hueco(partida, i)),
        ],
      ),
      if (partida.cicloOrdenado) ...[
        const SizedBox(height: 8),
        const Texto(
          '↻ El adulto pone huevos y el ciclo vuelve a empezar.',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF15803D),
          ),
        ),
      ] else ...[
        if (partida.colocados < ciclo.pasos.length) ...[
          const SizedBox(height: 12),
          const Texto(
            'Toca un paso para ponerlo en el primer hueco libre, o arrástralo a su hueco.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final paso in bandeja)
                if (!partida.estaColocado(paso.id))
                  _tarjetaPaso(paso, partida, ancho),
            ],
          ),
        ],
        if (partida.colocados > 0) ...[
          const SizedBox(height: 8),
          const Texto('Toca un hueco ocupado para devolver el paso.'),
        ],
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('comprobar-ciclo'),
          style: EstilosJuego.accion,
          onPressed: _comprobarCiclo,
          child: const Texto('Comprobar'),
        ),
      ],
      const SizedBox(height: 12),
      KeyedSubtree(
        key: _pregunta,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _burbuja(partida.resultado, ciclo.intro),
            if (partida.cicloOrdenado && !partida.preguntaAcertada) ...[
              const SizedBox(height: 16),
              const Texto(
                'Pregunta del ciclo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(height: 4),
              Texto(
                ciclo.pregunta.enunciado,
                key: Key('pregunta-${ciclo.id}'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              for (final opcion in opciones) ...[
                FilledButton.tonal(
                  key: Key('respuesta-${ciclo.id}-${opcion.id}'),
                  style: EstilosJuego.respuesta,
                  onPressed: () => _responder(opcion.id),
                  child: Texto(opcion.nombre),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
      if (partida.cicloOrdenado) ...[
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('curiosidad-ciclo'),
          style: EstilosJuego.accion,
          onPressed: () => _mostrarCuriosidad(
            dibujo: DibujoNacimiento(id: ciclo.respuesta[1], tamano: 64),
            titulo: ciclo.nombre,
            curiosidad: ciclo.curiosidad,
          ),
          icon: const Icon(Icons.auto_awesome_rounded, size: 18),
          label: const Texto('Ver curiosidad'),
        ),
      ],
    ];
  }

  Widget _hueco(PartidaCiclos partida, int indice) {
    final ciclo = partida.ciclo;
    final pasoId = partida.orden[indice];
    final ordenado = partida.cicloOrdenado;
    final fallo = partida.primerFallo == indice;
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !ordenado,
      onAcceptWithDetails: (detalles) {
          setState(() => partida.colocarEn(detalles.data, indice));
          context.sonidoPaso(partida.colocados);
        },
      builder: (context, candidatos, _) {
        final encima = candidatos.isNotEmpty;
        final borde = ordenado
            ? EstilosJuego.acierto
            : fallo
            ? EstilosJuego.fallo
            : encima
            ? Theme.of(context).colorScheme.primary
            : pasoId == null
            ? const Color(0xFFCBD5E1)
            : const Color(0xFF38BDF8);
        final nombre = pasoId == null ? null : ciclo.paso(pasoId).nombre;
        return Semantics(
          button: pasoId != null && !ordenado,
          label: nombre == null
              ? context.traducir('Hueco ${indice + 1} vacío')
              : context.traducir('Hueco ${indice + 1}: $nombre'),
          hint: fallo ? context.traducir('Prueba otro paso aquí') : null,
          child: TarjetaJuego(
            claveAccion: Key('hueco-$indice'),
            onTap: pasoId == null || ordenado
                ? null
                : () {
                    setState(() => partida.quitar(indice));
                    context.sonidoQuitar();
                  },
            borde: borde,
            fondo: ordenado
                ? const Color(0xFFECFDF5)
                : encima
                ? const Color(0xFFE0F2FE)
                : Colors.white,
            destacada: encima || fallo,
            radio: 18,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.all(8),
                // Dibujo arriba y nombre debajo, a lo ancho del hueco, para
                // que palabras como «Renacuajo» no se partan en el móvil.
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 13,
                          backgroundColor: ordenado
                              ? EstilosJuego.acierto
                              : const Color(0xFFF1F5F9),
                          child: Texto(
                            '${indice + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: ordenado
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: pasoId == null
                                ? const SizedBox(height: 52)
                                : DibujoNacimiento(id: pasoId, tamano: 52),
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          child: pasoId == null || ordenado
                              ? null
                              : Icon(
                                  fallo
                                      ? Icons.replay_rounded
                                      : Icons.close_rounded,
                                  size: 18,
                                  color: fallo
                                      ? EstilosJuego.fallo
                                      : const Color(0xFF64748B),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Texto(
                      nombre ?? 'Paso ${indice + 1}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: nombre == null
                            ? FontWeight.w700
                            : FontWeight.w800,
                        fontSize: 13.5,
                        color: nombre == null
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tarjetaPaso(Opcion paso, PartidaCiclos partida, double disponible) {
    final textoGrande = MediaQuery.textScalerOf(context).scale(14) > 20;
    final ancho = textoGrande
        ? math.min(340.0, disponible)
        : math.min(240.0, (disponible - 8) / 2);
    Widget tarjeta({VoidCallback? onTap, Key? clave}) => SizedBox(
      width: ancho,
      child: TarjetaJuego(
        claveAccion: clave,
        onTap: onTap,
        borde: const Color(0xFFBAE6FD),
        radio: 18,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                DibujoNacimiento(id: paso.id, tamano: 48),
                const SizedBox(width: 8),
                Expanded(
                  child: Texto(
                    paso.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFF0284C7),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Draggable<String>(
      data: paso.id,
      onDragStarted: () => context.sonidoSeleccion(),
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: const Offset(-36, -36),
          child: DibujoNacimiento(id: paso.id, tamano: 72),
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: tarjeta()),
      child: Semantics(
        label: context.traducir('Paso ${paso.nombre}'),
        child: tarjeta(
          clave: Key('paso-${paso.id}'),
          onTap: () {
            setState(() => partida.anadir(paso.id));
            context.sonidoPaso(partida.colocados);
          },
        ),
      ),
    );
  }
}
