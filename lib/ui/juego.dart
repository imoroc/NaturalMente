import 'package:naturalmente/ui/selector_idioma.dart';
import 'package:naturalmente/ui/texto.dart';
import 'package:flutter/material.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/dibujos.dart';

class JuegoPage extends StatefulWidget {
  const JuegoPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<JuegoPage> createState() => _JuegoPageState();
}

class _JuegoPageState extends State<JuegoPage> {
  int? _nivelIdx;
  var _reto = 0;
  var _listo = false;
  int _intento = 1;
  Resultado? _resultado;
  String? _sitioElegido;
  bool _lugarAcertado = false;
  bool _adaptacionAcertada = false;
  String? _adaptacionElegida;
  bool _baseCompletada = false;
  bool _preguntaFinalAcertada = false;
  String? _preguntaFinalElegida;
  int _etapaGerminacion = 1;
  final Map<String, String> _valores = {};
  final List<String> _orden = [];
  final Set<String> _retosResueltosNivel = {};
  List<Opcion> _sitiosBarajados = const [];
  List<Opcion> _adaptacionOpcionesBarajadas = const [];
  List<Opcion> _finalOpcionesBarajadas = const [];
  List<Opcion> _pasosBarajados = const [];
  List<Control> _controlesBarajados = const [];

  bool get _tieneNiveles => widget.actividad.nivelesLugar.isNotEmpty;

  NivelLugar? get _nivelActual => (!_tieneNiveles || _nivelIdx == null)
      ? null
      : widget.actividad.nivelesLugar[_nivelIdx!];

  List<Opcion> get _opcionesLugar =>
      _nivelActual?.opciones.isNotEmpty == true
          ? _nivelActual!.opciones
          : widget.actividad.opciones;

  List<Reto> get _retosLugar =>
      _nivelActual?.retos.isNotEmpty == true
          ? _nivelActual!.retos
          : widget.actividad.retos;

  List<Control> get _controlesActuales =>
      _nivelActual?.controles.isNotEmpty == true
          ? _nivelActual!.controles
          : widget.actividad.controles;

  List<Opcion> get _pasosActuales =>
      _nivelActual?.pasos.isNotEmpty == true
          ? _nivelActual!.pasos
          : widget.actividad.pasos;

  List<String> get _respuestaOrdenActual =>
      _nivelActual?.respuesta.isNotEmpty == true
          ? _nivelActual!.respuesta
          : widget.actividad.respuesta;

  bool get _pideAdaptacion => _nivelActual?.preguntaAdaptacion == true;

  bool get _retoCompleto =>
      _lugarAcertado && (!_pideAdaptacion || _adaptacionAcertada);

  String get _cursoActual => _nivelActual?.curso ?? widget.actividad.curso;

  int? _siguienteRetoPendiente() {
    final retos = _retosLugar;
    for (var step = 1; step <= retos.length; step++) {
      final idx = (_reto + step) % retos.length;
      if (!_retosResueltosNivel.contains(retos[idx].id)) {
        return idx;
      }
    }
    return null;
  }

  PreguntaExtra? get _adaptacionActualBarajada {
    final retos = _retosLugar;
    if (retos.isEmpty || _reto >= retos.length) return null;
    final original = retos[_reto].adaptacion;
    if (original == null) return null;
    return PreguntaExtra(
      enunciado: original.enunciado,
      opciones: _adaptacionOpcionesBarajadas.isNotEmpty
          ? _adaptacionOpcionesBarajadas
          : original.opciones,
      respuesta: original.respuesta,
      frases: original.frases,
    );
  }

  PreguntaExtra? get _preguntaFinalActualBarajada {
    final original = _nivelActual?.preguntaFinal;
    if (original == null) return null;
    return PreguntaExtra(
      enunciado: original.enunciado,
      opciones: _finalOpcionesBarajadas.isNotEmpty
          ? _finalOpcionesBarajadas
          : original.opciones,
      respuesta: original.respuesta,
      frases: original.frases,
    );
  }

  void _prepararBarajadoReto() {
    final retos = _retosLugar;
    if (retos.isEmpty || _reto >= retos.length) {
      _sitiosBarajados = _opcionesLugar;
      _adaptacionOpcionesBarajadas = const [];
      return;
    }
    final retoActual = retos[_reto];
    _sitiosBarajados = BarajadorOpciones.barajarConRespuesta<Opcion>(
      clave: 'sitios-${widget.actividad.id}-${_nivelActual?.id ?? 'base'}-${retoActual.id}',
      opciones: _opcionesLugar,
      idDe: (o) => o.id,
      respuestaCorrecta: retoActual.respuesta,
    );
    final adaptacion = retoActual.adaptacion;
    _adaptacionOpcionesBarajadas = adaptacion == null
        ? const []
        : BarajadorOpciones.barajarConRespuesta<Opcion>(
            clave: 'adaptacion-${widget.actividad.id}-${retoActual.id}',
            opciones: adaptacion.opciones,
            idDe: (o) => o.id,
            respuestaCorrecta: adaptacion.respuesta,
          );
  }

  void _prepararBarajadoNivel() {
    _prepararBarajadoReto();
    final preguntaFinal = _nivelActual?.preguntaFinal;
    _finalOpcionesBarajadas = preguntaFinal == null
        ? const []
        : BarajadorOpciones.barajarConRespuesta<Opcion>(
            clave: 'final-${widget.actividad.id}-${_nivelActual?.id ?? 'base'}',
            opciones: preguntaFinal.opciones,
            idDe: (o) => o.id,
            respuestaCorrecta: preguntaFinal.respuesta,
          );
    if (_controlesActuales.isNotEmpty) {
      _controlesBarajados = [
        for (final control in _controlesActuales)
          Control(
            id: control.id,
            nombre: control.nombre,
            opciones: BarajadorOpciones.barajarConRespuesta<Opcion>(
              clave:
                  'control-${widget.actividad.id}-${_nivelActual?.id ?? 'base'}-${control.id}',
              opciones: control.opciones,
              idDe: (o) => o.id,
              respuestaCorrecta: respuestaOptimaControl(control.id),
            ),
          ),
      ];
    } else {
      _controlesBarajados = const [];
    }
    if (_pasosActuales.isNotEmpty) {
      _pasosBarajados = BarajadorOpciones.barajarPasos(
        clave: 'pasos-${widget.actividad.id}-${_nivelActual?.id ?? 'base'}',
        pasos: _pasosActuales,
        ordenCorrecto: _respuestaOrdenActual,
      );
    } else {
      _pasosBarajados = const [];
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listo) return;
    _listo = true;
    final actividad = widget.actividad;
    if (_tieneNiveles) return;
    if (actividad.tipo == 'lugar' && _retosLugar.isNotEmpty) {
      final progreso = Alcance.of(context).progreso;
      final pendiente = _retosLugar.indexWhere(
        (reto) => !progreso.retoHecho(actividad, reto),
      );
      _reto = pendiente < 0 ? 0 : pendiente;
    }
    _prepararBarajadoNivel();
  }

  @override
  Widget build(BuildContext context) {
    final actividad = widget.actividad;
    final enSelector = _tieneNiveles && _nivelIdx == null;
    final retos = _retosLugar;
    final hayMasRetos = _siguienteRetoPendiente() != null;
    return Scaffold(
      appBar: AppBar(
        actions: const [SelectorIdioma()],
        centerTitle: false,
        title: Texto(
          enSelector ? actividad.titulo : _titulo(actividad),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        top: false,
        child: enSelector
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 780),
                    child: _selector(),
                  ),
                ),
              )
            : switch (actividad.tipo) {
                'lugar' => _Lugar(
                  actividad: actividad,
                  nivelActual: _nivelActual,
                  curso: _cursoActual,
                  opciones: _sitiosBarajados.isNotEmpty
                      ? _sitiosBarajados
                      : _opcionesLugar,
                  retosNivel: retos,
                  organosColocados: {
                    ..._retosResueltosNivel,
                    if (_lugarAcertado) retos[_reto].id,
                  },
                  reto: retos[_reto],
                  preguntaAdaptacion: _adaptacionActualBarajada,
                  indice: _reto,
                  total: retos.length,
                  sitioElegido: _sitioElegido,
                  lugarAcertado: _lugarAcertado,
                  mostrarPreguntaAdaptacion:
                      _lugarAcertado && _pideAdaptacion && !_adaptacionAcertada,
                  adaptacionElegida: _adaptacionElegida,
                  retoCompleto: _retoCompleto,
                  resultado: _resultado,
                  pie: _retoCompleto
                      ? (hayMasRetos ? 'Siguiente' : 'Volver')
                      : null,
                  onSalirNivel: _tieneNiveles ? _salirAlSelector : null,
                  onSoltar: _soltar,
                  onSeleccionarReto: _seleccionarReto,
                  onResponderAdaptacion: _responderAdaptacion,
                  onCuriosidad: () => _mostrarCuriosidad(retos[_reto]),
                  onOtraVez: (_retoCompleto && !hayMasRetos)
                      ? () => _empezarNivel(_nivelIdx ?? 0)
                      : null,
                  onPie: _retoCompleto
                      ? (hayMasRetos ? _siguiente : _volver)
                      : _volver,
                ),
                'controles' => _Controles(
                  actividad: actividad,
                  nivelActual: _nivelActual,
                  curso: _cursoActual,
                  controles: _controlesBarajados.isNotEmpty
                      ? _controlesBarajados
                      : _controlesActuales,
                  valores: _valores,
                  etapaActual: _etapaGerminacion,
                  resultado: _resultado,
                  baseCompletada: _baseCompletada,
                  frase: _fraseControles(),
                  mostrarPreguntaFinal:
                      _baseCompletada &&
                      _nivelActual?.preguntaFinal != null &&
                      !_preguntaFinalAcertada,
                  preguntaFinal: _preguntaFinalActualBarajada,
                  preguntaFinalElegida: _preguntaFinalElegida,
                  onSalirNivel: _tieneNiveles ? _salirAlSelector : null,
                  onElegir: (control, opcion) => setState(() {
                    _valores[control] = opcion;
                    if (_baseCompletada) {
                      _baseCompletada = false;
                      _preguntaFinalAcertada = false;
                      _preguntaFinalElegida = null;
                    }
                    _resultado = null;
                  }),
                  onAvanzar: _avanzar,
                  onReiniciarBote: _otraVez,
                  onResponderFinal: _responderPreguntaFinal,
                  onCuriosidad:
                      (_nivelActual?.curiosidad.isNotEmpty == true)
                      ? _mostrarCuriosidadControles
                      : null,
                  onOtraVez:
                      (_baseCompletada &&
                          (_nivelActual?.preguntaFinal == null ||
                              _preguntaFinalAcertada))
                      ? _otraVez
                      : null,
                  onVolver: _volver,
                ),
                _ => _Orden(
                  actividad: actividad,
                  nivelActual: _nivelActual,
                  curso: _cursoActual,
                  pasosTotales: _pasosActuales,
                  pasosDisponibles: _pasosBarajados.isNotEmpty
                      ? _pasosBarajados
                      : _pasosActuales,
                  orden: _orden,
                  resultado: _resultado,
                  baseCompletada:
                      _baseCompletada &&
                      (_nivelActual?.preguntaFinal == null ||
                          _preguntaFinalAcertada),
                  mostrarPreguntaFinal:
                      _baseCompletada &&
                      _nivelActual?.preguntaFinal != null &&
                      !_preguntaFinalAcertada,
                  preguntaFinal: _preguntaFinalActualBarajada,
                  preguntaFinalElegida: _preguntaFinalElegida,
                  onSalirNivel: _tieneNiveles ? _salirAlSelector : null,
                  onAnadir: (id) => setState(() {
                    if (!_orden.contains(id)) {
                      _orden.add(id);
                      _resultado = null;
                    }
                  }),
                  onQuitar: (indice) => setState(() {
                    _orden.removeAt(indice);
                    _resultado = null;
                  }),
                  onComprobar: _comprobar,
                  onResponderFinal: _responderPreguntaFinal,
                  onCuriosidad:
                      (_nivelActual?.curiosidad.isNotEmpty == true)
                      ? _mostrarCuriosidadControles
                      : null,
                  onOtraVez: _otraVez,
                  onVolver: _volver,
                ),
              },
      ),
    );
  }

  Widget _selector() {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichasCatalogo = {
      for (final f in alcance.catalogo.fichas) f.id: f.titulo,
    };
    final niveles = widget.actividad.nivelesLugar;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: widget.actividad.quien,
            frase:
                'Elige un nivel. Cada dificultad enseña nuevos retos y desbloquea sus propios cromos del cuaderno.',
            gesto: 'hola',
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < niveles.length; i++) ...[
            TarjetaJuego(
              claveAccion: Key('nivel-${niveles[i].id}'),
              borde: progreso.nivelLugarHecho(widget.actividad, niveles[i].id)
                  ? EstilosJuego.acierto
                  : const Color(0xFF38BDF8),
              sombra: progreso.nivelLugarHecho(widget.actividad, niveles[i].id)
                  ? const Color(0xFF239E56)
                  : const Color(0xFF0284C7),
              radio: 20,
              onTap: () => _empezarNivel(i),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Texto(
                            niveles[i].nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Color(0xFF1B3022),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var s = 0; s <= i; s++)
                              Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: progreso.nivelLugarHecho(
                                  widget.actividad,
                                  niveles[i].id,
                                )
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFCBD5E1),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Texto('Pensado para ${niveles[i].curso}'),
                    if (niveles[i].resumen.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Texto(niveles[i].resumen),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final fichaId in Progreso.fichasDeNivel(
                          widget.actividad.id,
                          niveles[i].id,
                        ))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: progreso.fichaDesbloqueada(fichaId)
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: progreso.fichaDesbloqueada(fichaId)
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  progreso.fichaDesbloqueada(fichaId)
                                      ? Icons.auto_stories_rounded
                                      : Icons.lock_outline_rounded,
                                  size: 13,
                                  color: progreso.fichaDesbloqueada(fichaId)
                                      ? const Color(0xFFB45309)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Texto(
                                    'Cromo: ${fichasCatalogo[fichaId] ?? fichaId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: progreso.fichaDesbloqueada(fichaId)
                                          ? const Color(0xFF92400E)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (progreso.nivelLugarHecho(widget.actividad, niveles[i].id)) ...[
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
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  String _titulo(Actividad actividad) {
    if (actividad.tipo != 'lugar') return actividad.titulo;
    return '${actividad.titulo} · ${_reto + 1} de ${_retosLugar.length}';
  }

  String? _fraseControles() {
    final resultado = _resultado;
    if (resultado == null) {
      if (_etapaGerminacion == 2) {
        return 'Día 3: ¡Ya asoma la raíz blanca! Como ha bebido el agua del primer día, vuelve a elegir «Riego suave» para que suba el tallo.';
      }
      if (_etapaGerminacion == 3) {
        return 'Día 5: ¡El tallo ya sube hacia arriba! Dale otro «Riego suave» y abre la ventana al sol para que salgan sus hojas verdes en el Día 7.';
      }
      if (_etapaGerminacion == 4) {
        return 'Día 7: La planta ha llegado al último día. Elige «Sol de ventana» para que sus hojas sean verdes.';
      }
      final introNivel = _nivelActual?.intro ?? '';
      if (introNivel.isNotEmpty) return introNivel;
      return widget.actividad.intro.isNotEmpty
          ? widget.actividad.intro
          : 'Elige la base de la maceta, dale un riego suave y ajusta la luz de la ventana.';
    }
    if (resultado.estado != 'falta') return resultado.frase;
    final faltan = [
      for (final control in _controlesActuales)
        if (!_valores.containsKey(control.id)) control.nombre,
    ];
    if (faltan.isEmpty) return resultado.frase;
    if (faltan.length == 1) return 'Falta preparar ${faltan.single}.';
    return 'Falta preparar ${faltan.join(', ')}.';
  }

  void _empezarNivel(int idx) {
    if (idx < 0 || idx >= widget.actividad.nivelesLugar.length) return;
    setState(() {
      _nivelIdx = idx;
      _reto = 0;
      _intento = 1;
      _resultado = null;
      _sitioElegido = null;
      _lugarAcertado = false;
      _adaptacionAcertada = false;
      _adaptacionElegida = null;
      _baseCompletada = false;
      _preguntaFinalAcertada = false;
      _preguntaFinalElegida = null;
      _etapaGerminacion = 1;
      _valores.clear();
      _orden.clear();
      _retosResueltosNivel.clear();
      _prepararBarajadoNivel();
    });
  }

  void _salirAlSelector() {
    setState(() {
      _nivelIdx = null;
      _reto = 0;
      _intento = 1;
      _resultado = null;
      _sitioElegido = null;
      _lugarAcertado = false;
      _adaptacionAcertada = false;
      _adaptacionElegida = null;
      _baseCompletada = false;
      _preguntaFinalAcertada = false;
      _preguntaFinalElegida = null;
      _etapaGerminacion = 1;
      _valores.clear();
      _orden.clear();
      _retosResueltosNivel.clear();
    });
  }

  void _seleccionarReto(String retoId) {
    if (_lugarAcertado) return;
    final retos = _retosLugar;
    final idx = retos.indexWhere((r) => r.id == retoId);
    if (idx < 0 || idx == _reto || _retosResueltosNivel.contains(retoId)) {
      return;
    }
    setState(() {
      _reto = idx;
      _intento = 1;
      _resultado = null;
      _sitioElegido = null;
      _prepararBarajadoReto();
    });
  }

  Future<void> _soltar(String sitio, {String? organoArrastrado}) async {
    if (_lugarAcertado) return;
    final actividad = widget.actividad;
    final retos = _retosLugar;
    if (organoArrastrado != null &&
        organoArrastrado != retos[_reto].id &&
        !_retosResueltosNivel.contains(organoArrastrado)) {
      final idx = retos.indexWhere((r) => r.id == organoArrastrado);
      if (idx >= 0) {
        _reto = idx;
        _intento = 1;
        _prepararBarajadoReto();
      }
    }
    final reto = retos[_reto];
    final resultado = resolverLugar(
      reto: reto,
      eleccion: sitio,
      intento: _intento,
    );
    setState(() {
      _sitioElegido = sitio;
      _resultado = resultado;
      if (resultado.acierto) {
        _lugarAcertado = true;
        if (!_pideAdaptacion) {
          _adaptacionAcertada = true;
          _retosResueltosNivel.add(reto.id);
        }
      } else {
        _intento += 1;
      }
    });
    if (resultado.acierto) {
      final progreso = Alcance.of(context).progreso;
      if (_nivelActual == null || _nivelActual!.id == 'facil') {
        await progreso.marcarReto(actividad, reto);
      }
      if (!_pideAdaptacion) {
        await progreso.desbloquearFicha(reto.id);
      }
      if (!_pideAdaptacion &&
          _nivelActual != null &&
          _siguienteRetoPendiente() == null) {
        await progreso.marcarNivelLugar(actividad, _nivelActual!.id);
        await progreso.marcarActividad(actividad);
      }
    }
  }

  Future<void> _responderAdaptacion(String eleccion) async {
    if (!_lugarAcertado || _adaptacionAcertada) return;
    final actividad = widget.actividad;
    final reto = _retosLugar[_reto];
    final resultado = resolverAdaptacion(reto: reto, eleccion: eleccion);
    setState(() {
      _adaptacionElegida = eleccion;
      _resultado = resultado;
      if (resultado.acierto) {
        _adaptacionAcertada = true;
        _retosResueltosNivel.add(reto.id);
      }
    });
    if (resultado.acierto) {
      final progreso = Alcance.of(context).progreso;
      await progreso.desbloquearFicha(reto.id);
      if (_nivelActual != null && _siguienteRetoPendiente() == null) {
        await progreso.marcarNivelLugar(actividad, _nivelActual!.id);
        await progreso.marcarActividad(actividad);
      }
    }
  }

  void _mostrarCuriosidad(Reto reto) {
    if (reto.curiosidad.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFDFBF7),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Miniatura(id: reto.id, tamano: 64),
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
                          reto.nombre,
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
                frase: reto.curiosidad,
                gesto: 'feliz',
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('cerrar-curiosidad'),
                onPressed: () => Navigator.of(context).pop(),
                child: const Texto('¡Qué interesante!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarCuriosidadControles() {
    final curiosidad = _nivelActual?.curiosidad ?? '';
    if (curiosidad.isEmpty) return;
    final fichasNivel = Progreso.fichasDeNivel(
      widget.actividad.id,
      _nivelActual?.id ?? 'facil',
    );
    final fichaId = fichasNivel.isNotEmpty
        ? fichasNivel.first
        : (widget.actividad.id == 'vida' ? 'una-vida' : 'semilla');
    final fichasCatalogo = Alcance.of(context).catalogo.fichas;
    final ficha = fichasCatalogo.where((f) => f.id == fichaId).firstOrNull;
    final tituloModal =
        ficha?.titulo ??
        (widget.actividad.sujeto.isNotEmpty
            ? widget.actividad.sujeto
            : widget.actividad.titulo);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFDFBF7),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IlustracionFicha(id: fichaId, alto: 58),
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
                          tituloModal,
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Texto('¡Qué interesante!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _siguiente() {
    final siguienteIdx = _siguienteRetoPendiente();
    if (siguienteIdx == null) return;
    setState(() {
      _reto = siguienteIdx;
      _intento = 1;
      _resultado = null;
      _sitioElegido = null;
      _lugarAcertado = false;
      _adaptacionAcertada = false;
      _adaptacionElegida = null;
      _prepararBarajadoReto();
    });
  }

  void _volver() {
    if (_tieneNiveles && _nivelIdx != null) {
      _salirAlSelector();
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _avanzar() async {
    final actividad = widget.actividad;
    final paso = resolverPasoGerminacion(
      actividad: actividad,
      valores: _valores,
      etapaActual: _etapaGerminacion,
      nivel: _nivelActual,
    );
    final pideFinal = _nivelActual?.preguntaFinal != null;
    setState(() {
      _etapaGerminacion = paso.etapaAlcanzada;
      _resultado = Resultado(
        acierto: paso.experimentoCompletado,
        estado: paso.estado,
        frase: paso.frase,
        gesto: paso.gesto,
      );
      if (paso.avanzaEtapa && paso.etapaAlcanzada < 4) {
        // Al crecer entre días, la semilla bebe el agua del bote
        // para que el alumno vuelva a regarla en el nuevo día.
        _valores['agua'] = 'poca';
      }
      if (paso.experimentoCompletado) {
        _baseCompletada = true;
        if (!pideFinal) {
          _preguntaFinalAcertada = true;
        }
      }
    });
    if (paso.experimentoCompletado && !pideFinal) {
      final progreso = Alcance.of(context).progreso;
      if (_nivelActual != null) {
        await progreso.marcarNivelLugar(actividad, _nivelActual!.id);
      }
      await progreso.marcarActividad(actividad);
    }
  }

  void _otraVez() {
    setState(() {
      _valores.clear();
      _orden.clear();
      _resultado = null;
      _baseCompletada = false;
      _preguntaFinalAcertada = false;
      _preguntaFinalElegida = null;
      _etapaGerminacion = 1;
      _prepararBarajadoNivel();
    });
  }

  Future<void> _comprobar() async {
    final actividad = widget.actividad;
    final resultado = resolverOrden(
      actividad: actividad,
      orden: _orden,
      nivel: _nivelActual,
    );
    final pideFinal = _nivelActual?.preguntaFinal != null;
    setState(() {
      _resultado = resultado;
      if (resultado.acierto) {
        _baseCompletada = true;
        if (!pideFinal) {
          _preguntaFinalAcertada = true;
        }
      }
    });
    if (resultado.acierto && !pideFinal) {
      final progreso = Alcance.of(context).progreso;
      if (_nivelActual != null) {
        await progreso.marcarNivelLugar(actividad, _nivelActual!.id);
      }
      await progreso.marcarActividad(actividad);
    }
  }

  Future<void> _responderPreguntaFinal(String eleccion) async {
    final pregunta = _nivelActual?.preguntaFinal;
    if (!_baseCompletada || _preguntaFinalAcertada || pregunta == null) return;
    final actividad = widget.actividad;
    final resultado = resolverPreguntaExtra(
      pregunta: pregunta,
      eleccion: eleccion,
    );
    setState(() {
      _preguntaFinalElegida = eleccion;
      _resultado = resultado;
      if (resultado.acierto) {
        _preguntaFinalAcertada = true;
      }
    });
    if (resultado.acierto) {
      final progreso = Alcance.of(context).progreso;
      if (_nivelActual != null) {
        await progreso.marcarNivelLugar(actividad, _nivelActual!.id);
      }
      await progreso.marcarActividad(actividad);
    }
  }
}

class _CabeceraNivel extends StatelessWidget {
  const _CabeceraNivel({
    required this.nivel,
    required this.curso,
    this.onCambiarNivel,
  });

  final NivelLugar? nivel;
  final String curso;
  final VoidCallback? onCambiarNivel;

  @override
  Widget build(BuildContext context) {
    final texto = nivel != null
        ? '${nivel!.nombre} · Pensado para $curso. Puedes jugarlo igual.'
        : 'Pensado para $curso. Puedes jugarlo igual.';
    return Row(
      children: [
        Expanded(
          child: Texto(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        if (onCambiarNivel != null) ...[
          const SizedBox(width: 8),
          TextButton.icon(
            key: const Key('cambiar-nivel'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: onCambiarNivel,
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: const Texto(
              'Cambiar nivel',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }
}

class _TarjetaPreguntaExtra extends StatelessWidget {
  const _TarjetaPreguntaExtra({
    required this.etiquetaSuperior,
    required this.subtituloDerecho,
    required this.pregunta,
    required this.elegida,
    required this.prefijoKey,
    required this.onResponder,
  });

  final String etiquetaSuperior;
  final String subtituloDerecho;
  final PreguntaExtra pregunta;
  final String? elegida;
  final String prefijoKey;
  final ValueChanged<String> onResponder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF38BDF8),
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFBAE6FD),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Texto(
                  etiquetaSuperior,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Texto(
                  subtituloDerecho,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFF0284C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Texto(
            pregunta.enunciado,
            key: Key('pregunta-$prefijoKey'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final opcion in pregunta.opciones) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                key: Key('$prefijoKey-${opcion.id}'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  backgroundColor: elegida == opcion.id
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF8FAFC),
                  side: BorderSide(
                    color: elegida == opcion.id
                        ? const Color(0xFFFB923C)
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => onResponder(opcion.id),
                child: Texto(
                  opcion.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Lugar extends StatelessWidget {
  const _Lugar({
    required this.actividad,
    required this.nivelActual,
    required this.curso,
    required this.opciones,
    required this.retosNivel,
    required this.organosColocados,
    required this.reto,
    required this.preguntaAdaptacion,
    required this.indice,
    required this.total,
    required this.sitioElegido,
    required this.lugarAcertado,
    required this.mostrarPreguntaAdaptacion,
    required this.adaptacionElegida,
    required this.retoCompleto,
    required this.resultado,
    required this.pie,
    required this.onSalirNivel,
    required this.onSoltar,
    this.onSeleccionarReto,
    required this.onResponderAdaptacion,
    required this.onCuriosidad,
    required this.onPie,
    this.onOtraVez,
  });

  final Actividad actividad;
  final NivelLugar? nivelActual;
  final String curso;
  final List<Opcion> opciones;
  final List<Reto> retosNivel;
  final Set<String> organosColocados;
  final Reto reto;
  final PreguntaExtra? preguntaAdaptacion;
  final int indice;
  final int total;
  final String? sitioElegido;
  final bool lugarAcertado;
  final bool mostrarPreguntaAdaptacion;
  final String? adaptacionElegida;
  final bool retoCompleto;
  final Resultado? resultado;
  final String? pie;
  final VoidCallback? onSalirNivel;
  final void Function(String sitio, {String? organoArrastrado}) onSoltar;
  final ValueChanged<String>? onSeleccionarReto;
  final ValueChanged<String> onResponderAdaptacion;
  final VoidCallback onCuriosidad;
  final VoidCallback onPie;
  final VoidCallback? onOtraVez;

  @override
  Widget build(BuildContext context) {
    final esCuerpo = actividad.zona == 'cuerpo';
    final fraseInicial = actividad.intro.isNotEmpty
        ? actividad.intro
        : 'Arrastra cada figura a su lugar o toca directamente la tarjeta.';
    final nombreSitioCorrecto = opciones
        .firstWhere(
          (o) => o.id == reto.respuesta,
          orElse: () => Opcion(id: reto.respuesta, nombre: reto.respuesta),
        )
        .nombre;

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final escalaTexto = MediaQuery.textScalerOf(context).scale(1.0);
        final pantallaBaja =
            outerConstraints.maxHeight < 540 || escalaTexto > 1.25;
        final progresoValor =
            (organosColocados.length +
                (retoCompleto ? 0.0 : (lugarAcertado ? 0.65 : 0.25))) /
            total;

        Widget cabeceraReto() {
          final pista = _pistaReto(reto.id);
          final etiquetaTipo = esCuerpo ? 'Pieza' : 'Reto';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2DEC9), width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD6CFC0),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Draggable<String>(
                  data: reto.id,
                  dragAnchorStrategy: pointerDragAnchorStrategy,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _Miniatura(id: reto.id),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _Miniatura(id: reto.id, tamano: 48),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: _Miniatura(id: reto.id, tamano: 48),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Texto(
                              '$etiquetaTipo ${indice + 1} de $total · ${reto.nombre}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                          if (pista != null && !retoCompleto)
                            Texto(
                              pista,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Texto(
                        reto.pregunta,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: esCuerpo ? 14.5 : null,
                              height: 1.15,
                            ),
                      ),
                      if (retoCompleto && reto.curiosidad.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        InkWell(
                          key: Key('curiosidad-${reto.id}'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: onCuriosidad,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 1.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 15,
                                  color: Color(0xFFB45309),
                                ),
                                SizedBox(width: 4),
                                Flexible(
                                  child: Texto(
                                    'Ver curiosidad',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        Widget zonaCentral({required bool usarAlturaFija}) {
          final adaptacion = preguntaAdaptacion ?? reto.adaptacion;
          if (mostrarPreguntaAdaptacion && adaptacion != null) {
            final tarjeta = _TarjetaPreguntaExtra(
              etiquetaSuperior: '✓ Lugar: $nombreSitioCorrecto',
              subtituloDerecho: '¡Pregunta extra!',
              pregunta: adaptacion,
              elegida: adaptacionElegida,
              prefijoKey: 'adaptacion-${reto.id}',
              onResponder: onResponderAdaptacion,
            );
            if (usarAlturaFija) return tarjeta;
            return Center(child: SingleChildScrollView(child: tarjeta));
          }

          if (esCuerpo) {
            final tablero = _TableroCuerpoHerbario(
              opciones: opciones,
              retosNivel: retosNivel,
              organosColocados: organosColocados,
              organoActual: reto.id,
              sitioElegido: sitioElegido,
              lugarAcertado: lugarAcertado,
              onElegirSitio: onSoltar,
              onSeleccionarOrgano: onSeleccionarReto,
            );
            if (usarAlturaFija) {
              return SizedBox(height: 330, child: tablero);
            }
            return tablero;
          }

          if (usarAlturaFija) {
            final filas = (opciones.length / 2).ceil();
            final alturaGrid = filas * 96.0 + (filas - 1) * 10.0;
            return SizedBox(
              height: alturaGrid,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: (outerConstraints.maxWidth - 42) / 2 / 96.0,
                children: [
                  for (final opcion in opciones)
                    _Sitio(
                      opcion: opcion,
                      elegido: sitioElegido == opcion.id,
                      acierto: lugarAcertado && sitioElegido == opcion.id,
                      criatura: reto.id,
                      onElegir: () => onSoltar(opcion.id),
                    ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              const separacion = 10.0;
              final columnas =
                  constraints.maxWidth > 520 && opciones.length >= 4 ? 3 : 2;
              final filas = (opciones.length / columnas).ceil();
              final ancho =
                  (constraints.maxWidth - separacion * (columnas - 1)) /
                  columnas;
              final alto =
                  (constraints.maxHeight - separacion * (filas - 1)) / filas;
              return GridView.count(
                crossAxisCount: columnas,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: separacion,
                crossAxisSpacing: separacion,
                childAspectRatio: (ancho / alto).clamp(0.6, 4.5),
                children: [
                  for (final opcion in opciones)
                    _Sitio(
                      opcion: opcion,
                      elegido: sitioElegido == opcion.id,
                      acierto: lugarAcertado && sitioElegido == opcion.id,
                      criatura: reto.id,
                      onElegir: () => onSoltar(opcion.id),
                    ),
                ],
              );
            },
          );
        }

        final burbujaWidget = Burbuja(
          quien: actividad.quien,
          frase: resultado?.frase ?? fraseInicial,
          gesto: resultado?.gesto ?? 'hola',
        );

        Widget botoneraPie(double alturaBoton) {
          if (onOtraVez != null) {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('otra-vez-lugar'),
                    onPressed: onOtraVez,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.fromHeight(alturaBoton),
                    ),
                    child: const Texto('Otra vez'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    key: const Key('boton-pie-lugar'),
                    onPressed: onPie,
                    style: FilledButton.styleFrom(
                      minimumSize: Size.fromHeight(alturaBoton),
                    ),
                    child: Texto(pie!),
                  ),
                ),
              ],
            );
          }
          return FilledButton(
            key: const Key('boton-pie-lugar'),
            onPressed: onPie,
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(alturaBoton),
            ),
            child: Texto(pie!),
          );
        }

        if (pantallaBaja) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CabeceraNivel(
                  nivel: nivelActual,
                  curso: curso,
                  onCambiarNivel: onSalirNivel,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progresoValor.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE5DFCF),
                    color: const Color(0xFF2ECC71),
                  ),
                ),
                const SizedBox(height: 8),
                cabeceraReto(),
                const SizedBox(height: 10),
                zonaCentral(usarAlturaFija: true),
                const SizedBox(height: 8),
                burbujaWidget,
                if (pie != null) ...[
                  const SizedBox(height: 8),
                  botoneraPie(50),
                ],
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CabeceraNivel(
                nivel: nivelActual,
                curso: curso,
                onCambiarNivel: onSalirNivel,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progresoValor.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5DFCF),
                  color: const Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(height: 6),
              cabeceraReto(),
              const SizedBox(height: 6),
              Expanded(child: zonaCentral(usarAlturaFija: false)),
              const SizedBox(height: 6),
              burbujaWidget,
              if (pie != null) ...[
                const SizedBox(height: 6),
                botoneraPie(48),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TableroCuerpoHerbario extends StatelessWidget {
  const _TableroCuerpoHerbario({
    required this.opciones,
    required this.retosNivel,
    required this.organosColocados,
    required this.organoActual,
    required this.sitioElegido,
    required this.lugarAcertado,
    required this.onElegirSitio,
    this.onSeleccionarOrgano,
  });

  final List<Opcion> opciones;
  final List<Reto> retosNivel;
  final Set<String> organosColocados;
  final String organoActual;
  final String? sitioElegido;
  final bool lugarAcertado;
  final void Function(String sitio, {String? organoArrastrado}) onElegirSitio;
  final ValueChanged<String>? onSeleccionarOrgano;

  @override
  Widget build(BuildContext context) {
    final idsOrganos = [for (final r in retosNivel) r.id];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD6CBB5), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD6CFC0),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lámina anatómica a ancho completo con zonas interactivas en el propio cuerpo
            Expanded(
              child: CuerpoHerbario(
                organosNivel: idsOrganos,
                colocados: organosColocados,
                organoActual: organoActual,
                zonaDestacada: sitioElegido,
                aciertoZona: lugarAcertado,
                opciones: opciones,
                bloqueado: lugarAcertado,
                onColocarEnZona: (zonaId, {organoArrastrado}) =>
                    onElegirSitio(zonaId, organoArrastrado: organoArrastrado),
              ),
            ),
            // Bandeja inferior de órganos arrastrables estilo Herbario
            Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F3E8).withValues(alpha: 0.96),
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2D9C5), width: 1.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Texto(
                        'BANDEJA DE ÓRGANOS · ARRÁSTRALOS AL CUERPO',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Color(0xFF5C4B3B),
                        ),
                      ),
                      Texto(
                        '${organosColocados.length}/${retosNivel.length} en su sitio',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final r in retosNivel) ...[
                          _FichaMiniOrganoHerbario(
                            reto: r,
                            colocado: organosColocados.contains(r.id),
                            activo: r.id == organoActual,
                            bloqueado: lugarAcertado,
                            onTap: () => onSeleccionarOrgano?.call(r.id),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FichaMiniOrganoHerbario extends StatelessWidget {
  const _FichaMiniOrganoHerbario({
    required this.reto,
    required this.colocado,
    required this.activo,
    required this.bloqueado,
    this.onTap,
  });

  final Reto reto;
  final bool colocado;
  final bool activo;
  final bool bloqueado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('pieza-cuerpo-${reto.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: (!colocado && !bloqueado) ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colocado
                ? const Color(0xFFDCFCE7)
                : (activo ? const Color(0xFFE0F2FE) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colocado
                  ? const Color(0xFF22C55E)
                  : (activo
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFCBD5E1)),
              width: activo ? 2.2 : 1.4,
            ),
            boxShadow: activo && !colocado
                ? const [
                    BoxShadow(
                      color: Color(0x330284C7),
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconoOrgano(id: reto.id, size: 24),
              const SizedBox(width: 5),
              Texto(
                reto.nombre,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: colocado
                      ? const Color(0xFF166534)
                      : (activo
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF334155)),
                ),
              ),
              const SizedBox(width: 4),
              if (colocado)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF16A34A),
                )
              else
                Icon(
                  Icons.open_with_rounded,
                  size: 13,
                  color: activo
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF94A3B8),
                ),
            ],
          ),
        ),
      ),
    );

    if (colocado || bloqueado) return badge;
    return Draggable<String>(
      data: reto.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onTap,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0284C7), width: 2.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconoOrgano(id: reto.id, size: 40),
              const SizedBox(width: 6),
              Texto(
                reto.nombre,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: badge),
      child: badge,
    );
  }
}

class _Sitio extends StatelessWidget {
  const _Sitio({
    required this.opcion,
    required this.elegido,
    required this.acierto,
    required this.criatura,
    required this.onElegir,
  });

  final Opcion opcion;
  final bool elegido;
  final bool acierto;
  final String criatura;
  final VoidCallback onElegir;

  @override
  Widget build(BuildContext context) {
    final colorFondo = _colorSitio(opcion.id);
    final colorBorde = elegido
        ? (acierto ? EstilosJuego.acierto : EstilosJuego.fallo)
        : _bordeSitio(opcion.id);
    final subtitulo = _subtituloSitio(opcion.id);

    return DragTarget<String>(
      onAcceptWithDetails: (_) => onElegir(),
      builder: (context, candidatos, _) {
        final encima = candidatos.isNotEmpty;
        return TarjetaJuego(
          fondo: colorFondo,
          borde: encima ? EstilosJuego.acierto : colorBorde,
          sombra: colorBorde.withValues(alpha: .55),
          destacada: encima || elegido,
          claveAccion: Key('sitio-${opcion.id}'),
          onTap: onElegir,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (elegido)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _Miniatura(id: criatura, tamano: 48),
                        if (acierto)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF16A34A),
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    )
                  else
                    IconoSitio(id: opcion.id),
                  const SizedBox(height: 5),
                  Texto(
                    opcion.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Texto(
                      subtitulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Controles extends StatelessWidget {
  const _Controles({
    required this.actividad,
    required this.nivelActual,
    required this.curso,
    required this.controles,
    required this.valores,
    required this.etapaActual,
    required this.resultado,
    required this.baseCompletada,
    required this.frase,
    required this.mostrarPreguntaFinal,
    required this.preguntaFinal,
    required this.preguntaFinalElegida,
    required this.onSalirNivel,
    required this.onElegir,
    required this.onAvanzar,
    required this.onReiniciarBote,
    required this.onResponderFinal,
    required this.onCuriosidad,
    required this.onOtraVez,
    required this.onVolver,
  });

  final Actividad actividad;
  final NivelLugar? nivelActual;
  final String curso;
  final List<Control> controles;
  final Map<String, String> valores;
  final int etapaActual;
  final Resultado? resultado;
  final bool baseCompletada;
  final String? frase;
  final bool mostrarPreguntaFinal;
  final PreguntaExtra? preguntaFinal;
  final String? preguntaFinalElegida;
  final VoidCallback? onSalirNivel;
  final void Function(String control, String opcion) onElegir;
  final VoidCallback onAvanzar;
  final VoidCallback onReiniciarBote;
  final ValueChanged<String> onResponderFinal;
  final VoidCallback? onCuriosidad;
  final VoidCallback? onOtraVez;
  final VoidCallback onVolver;

  String _textoBotonAvance() {
    return switch (etapaActual) {
      1 => 'Pasar al Día 3 · Ver si sale raíz',
      2 => 'Pasar al Día 5 · Ver si sube el tallo',
      3 => 'Pasar al Día 7 · Ver abrir las hojas',
      _ =>
        valores['luz'] == 'poca'
            ? 'Terminar en oscuridad (o abre antes el sol)'
            : 'Completar experimento del Día 7',
    };
  }

  String _etiquetaProgreso(bool nivelCompletado) {
    if (nivelCompletado) return '✓ ¡Experimento de 7 días completado!';
    if (mostrarPreguntaFinal) return '✓ Día 7 alcanzado · Pregunta final';
    return switch (etapaActual) {
      1 => 'Día 1 de 7 · Siembra e hidratación',
      2 => 'Día 3 de 7 · La raíz absorbe agua',
      3 => 'Día 5 de 7 · El tallo busca la luz',
      _ => 'Día 7 de 7 · Primeras hojas',
    };
  }

  @override
  Widget build(BuildContext context) {
    final finalActual = preguntaFinal ?? nivelActual?.preguntaFinal;
    final nivelCompletado = onOtraVez != null;
    final progresoEtapa = baseCompletada
        ? 1.0
        : ((etapaActual - 1) / 3.0).clamp(0.08, 0.92);
    final estadoTerrario = resultado == null || resultado!.estado == 'falta'
        ? (etapaActual > 1
              ? (valores['luz'] == 'poca' && etapaActual >= 3
                    ? 'palida'
                    : 'brote')
              : 'esperando')
        : resultado!.estado;

    Control? buscarControl(String id) {
      for (final c in controles) {
        if (c.id == id) return c;
      }
      return null;
    }

    final controlSuelo = buscarControl('suelo');
    final controlAgua = buscarControl('agua');
    final controlLuz = buscarControl('luz');
    final controlTemperatura = buscarControl('temperatura');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CabeceraNivel(
                nivel: nivelActual,
                curso: curso,
                onCambiarNivel: onSalirNivel,
              ),
              _BarraProgreso(
                progreso: progresoEtapa,
                etiqueta: _etiquetaProgreso(nivelCompletado),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CabeceraTerrario(
                        sujeto: actividad.sujeto,
                        estado: estadoTerrario,
                        etapaActual: etapaActual,
                        agua: valores['agua'],
                        luz: valores['luz'],
                        suelo: valores['suelo'],
                        temperatura: valores['temperatura'],
                        baseCompletada: baseCompletada,
                        onAplicarHerramienta: onElegir,
                        onReiniciarBote:
                            (!baseCompletada &&
                                (valores.isNotEmpty || etapaActual > 1))
                            ? onReiniciarBote
                            : null,
                        onCuriosidad: baseCompletada ? onCuriosidad : null,
                      ),
                      const SizedBox(height: 10),
                      if (mostrarPreguntaFinal && finalActual != null)
                        _TarjetaPreguntaExtra(
                          etiquetaSuperior: '✓ Día 7 completado',
                          subtituloDerecho: '¡Pregunta extra!',
                          pregunta: finalActual,
                          elegida: preguntaFinalElegida,
                          prefijoKey: 'final-${actividad.id}',
                          onResponder: onResponderFinal,
                        )
                      else ...[
                        if (controlSuelo != null) ...[
                          _EstacionSustrato(
                            control: controlSuelo,
                            sueloElegido: valores['suelo'],
                            etapaActual: etapaActual,
                            onElegirSuelo: (id) => onElegir('suelo', id),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (controlAgua != null) ...[
                          _EstacionRiegoInteractiva(
                            control: controlAgua,
                            aguaElegida: valores['agua'],
                            etapaActual: etapaActual,
                            onElegirAgua: (id) => onElegir('agua', id),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (controlLuz != null) ...[
                          _EstacionVentanaLaboratorio(
                            control: controlLuz,
                            luzElegida: valores['luz'],
                            etapaActual: etapaActual,
                            onElegirLuz: (id) => onElegir('luz', id),
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (controlTemperatura != null) ...[
                          _EstacionTermostatoLaboratorio(
                            control: controlTemperatura,
                            temperaturaElegida: valores['temperatura'],
                            onElegirTemperatura: (id) =>
                                onElegir('temperatura', id),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (frase != null) ...[
                const SizedBox(height: 6),
                Burbuja(
                  quien: actividad.quien,
                  frase: frase!,
                  gesto: resultado?.gesto ?? 'hola',
                ),
              ],
              if (!mostrarPreguntaFinal) ...[
                const SizedBox(height: 8),
                if (nivelCompletado)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('otra-vez'),
                          onPressed: onOtraVez,
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          label: const Texto('Otra vez'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          key: const Key('volver-controles'),
                          onPressed: onVolver,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          label: const Texto('Volver'),
                        ),
                      ),
                    ],
                  )
                else
                  FilledButton.icon(
                    key: const Key('avanzar'),
                    onPressed: onAvanzar,
                    icon: const Icon(Icons.fast_forward_rounded, size: 22),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    label: Texto(
                      _textoBotonAvance(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AccionHerramienta {
  const _AccionHerramienta({
    required this.controlId,
    required this.opcionId,
    required this.etiqueta,
    required this.icono,
    required this.color,
  });

  final String controlId;
  final String opcionId;
  final String etiqueta;
  final IconData icono;
  final Color color;
}

class _BarraProgreso extends StatelessWidget {
  const _BarraProgreso({
    required this.progreso,
    required this.etiqueta,
  });

  final double progreso;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final porcentaje = progreso.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Texto(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Texto(
              '${(porcentaje * 100).round()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Color(0xFF15803D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: porcentaje,
            minHeight: 7,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
          ),
        ),
      ],
    );
  }
}

class _CabeceraTerrario extends StatefulWidget {
  const _CabeceraTerrario({
    required this.sujeto,
    required this.estado,
    required this.etapaActual,
    required this.agua,
    required this.luz,
    required this.suelo,
    required this.temperatura,
    required this.baseCompletada,
    required this.onAplicarHerramienta,
    required this.onReiniciarBote,
    required this.onCuriosidad,
  });

  final String sujeto;
  final String estado;
  final int etapaActual;
  final String? agua;
  final String? luz;
  final String? suelo;
  final String? temperatura;
  final bool baseCompletada;
  final void Function(String controlId, String opcionId) onAplicarHerramienta;
  final VoidCallback? onReiniciarBote;
  final VoidCallback? onCuriosidad;

  @override
  State<_CabeceraTerrario> createState() => _CabeceraTerrarioState();
}

class _CabeceraTerrarioState extends State<_CabeceraTerrario> {
  late int _etapaVista = widget.etapaActual;

  static const _fasesGerminacion = [
    (
      1,
      'Día 1 · Siembra',
      'La semilla bebe agua del bote, se hincha y despierta.',
    ),
    (
      2,
      'Día 3 · Raíz',
      'Se abre la cáscara y baja la primera raíz para sujetarse y beber agua.',
    ),
    (
      3,
      'Día 5 · Tallo',
      'El tallo sube hacia arriba usando el alimento guardado en la semilla.',
    ),
    (
      4,
      'Día 7 · Hojas',
      'Se abren las primeras hojas verdes que fabrican su propio alimento con la luz del sol.',
    ),
  ];

  @override
  void didUpdateWidget(covariant _CabeceraTerrario oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.etapaActual != oldWidget.etapaActual ||
        widget.baseCompletada != oldWidget.baseCompletada) {
      _etapaVista = widget.etapaActual;
    }
  }

  String _resumenSuelo() {
    return switch (widget.suelo) {
      'algodon' => '☁️ Algodón',
      'huerto' => '🌱 Tierra',
      'arena' => '🏖️ Arena',
      'piedras' => '🪨 Piedras',
      _ => 'Sin base',
    };
  }

  String _resumenAgua() {
    return switch (widget.agua) {
      'poca' => '🌵 Sin regar',
      'justa' => '💧 Riego suave',
      'mucha' => '🌊 Demasiada agua',
      _ => 'Sin regar',
    };
  }

  String _resumenLuz() {
    return switch (widget.luz) {
      'poca' => '🌙 A oscuras',
      'justa' => '☀️ Luz del sol',
      'excesiva' || 'mucha' => '🔥 Sol abrasador',
      _ => 'Sin elegir luz',
    };
  }

  @override
  Widget build(BuildContext context) {
    final maxEtapaDesbloqueada = widget.baseCompletada ? 4 : widget.etapaActual;
    final descripcionEtapa = _fasesGerminacion
        .firstWhere(
          (f) => f.$1 == _etapaVista,
          orElse: () => _fasesGerminacion.first,
        )
        .$3;

    return DragTarget<_AccionHerramienta>(
      key: const Key('maceta-terrario'),
      onAcceptWithDetails: (details) {
        final accion = details.data;
        widget.onAplicarHerramienta(accion.controlId, accion.opcionId);
      },
      builder: (context, candidatos, _) {
        final arrastrandoEncima = candidatos.isNotEmpty;
        final colorBorde = arrastrandoEncima
            ? const Color(0xFF0284C7)
            : widget.baseCompletada
            ? const Color(0xFF22C55E)
            : const Color(0xFFCBD5E1);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: arrastrandoEncima
                ? const Color(0xFFF0F9FF)
                : widget.baseCompletada
                ? const Color(0xFFF0FDF4)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorBorde, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: colorBorde.withValues(alpha: 0.35),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (var i = 0; i < _fasesGerminacion.length; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    Expanded(
                      child: InkWell(
                        key: Key(
                          'etapa-germinacion-${_fasesGerminacion[i].$1}',
                        ),
                        borderRadius: BorderRadius.circular(10),
                        onTap: _fasesGerminacion[i].$1 <= maxEtapaDesbloqueada
                            ? () => setState(
                                () => _etapaVista = _fasesGerminacion[i].$1,
                              )
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _etapaVista == _fasesGerminacion[i].$1
                                ? const Color(0xFF15803D)
                                : _fasesGerminacion[i].$1 <=
                                      maxEtapaDesbloqueada
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  _fasesGerminacion[i].$1 <=
                                      maxEtapaDesbloqueada
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Texto(
                            _fasesGerminacion[i].$2,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: _etapaVista == _fasesGerminacion[i].$1
                                  ? Colors.white
                                  : _fasesGerminacion[i].$1 <=
                                        maxEtapaDesbloqueada
                                  ? const Color(0xFF14532D)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              DibujoSemilla(
                estado: widget.estado,
                agua: widget.agua,
                luz: widget.luz,
                suelo: widget.suelo,
                temperatura: widget.temperatura,
                etapaGerminacion: _etapaVista,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _ChipEstadoBote(texto: _resumenSuelo()),
                  _ChipEstadoBote(texto: _resumenAgua()),
                  _ChipEstadoBote(texto: _resumenLuz()),
                  if (widget.temperatura != null)
                    _ChipEstadoBote(
                      texto: switch (widget.temperatura) {
                        'fria' => '❄️ 4 °C',
                        'templada' => '🌤️ 20 °C',
                        'calor' => '🔥 42 °C',
                        _ => widget.temperatura!,
                      },
                    ),
                  if (widget.onReiniciarBote != null)
                    InkWell(
                      key: const Key('reiniciar-bote'),
                      borderRadius: BorderRadius.circular(999),
                      onTap: widget.onReiniciarBote,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restart_alt_rounded,
                              size: 13,
                              color: Color(0xFFB91C1C),
                            ),
                            SizedBox(width: 3),
                            Texto(
                              'Empezar Día 1',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Texto(
                            '${widget.sujeto} · ${_fasesGerminacion[(_etapaVista - 1).clamp(0, 3)].$2}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Texto(
                            arrastrandoEncima
                                ? '¡Suelta aquí tu elección para aplicarla al bote!'
                                : descripcionEtapa,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: arrastrandoEncima
                                  ? const Color(0xFF0369A1)
                                  : widget.baseCompletada
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onCuriosidad != null) ...[
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        key: const Key('curiosidad-germinacion'),
                        onPressed: widget.onCuriosidad,
                        icon: const Icon(
                          Icons.auto_stories_rounded,
                          size: 16,
                          color: Color(0xFF15803D),
                        ),
                        label: const Texto('Ver curiosidad'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDCFCE7),
                          foregroundColor: const Color(0xFF14532D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChipEstadoBote extends StatelessWidget {
  const _ChipEstadoBote({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Texto(
        texto,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _EstacionSustrato extends StatelessWidget {
  const _EstacionSustrato({
    required this.control,
    required this.sueloElegido,
    required this.etapaActual,
    required this.onElegirSuelo,
  });

  final Control control;
  final String? sueloElegido;
  final int etapaActual;
  final ValueChanged<String> onElegirSuelo;

  String _pistaSustrato(String id) {
    return switch (id) {
      'algodon' => 'Guarda el agua',
      'huerto' => 'Agua y nutrientes',
      'arena' => 'Escurre el agua',
      'piedras' => 'Duras y secas',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF78350F);
    const colorFondo = Color(0xFFFEFCE8);
    return _ContenedorEstacion(
      icono: Icons.science_rounded,
      colorPrincipal: colorPrincipal,
      colorFondo: colorFondo,
      titulo: etapaActual == 1
          ? '1. ¿Dónde pones la semilla? (Toca o arrastra al bote)'
          : '1. Base del bote (puedes cambiarla si no guarda el agua)',
      subtitulo:
          'Elige un suelo esponjoso que mantenga la humedad alrededor de la semilla.',
      child: Row(
        children: [
          for (var i = 0; i < control.opciones.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _OpcionControl(
                key: Key('control-suelo-${control.opciones[i].id}'),
                controlId: 'suelo',
                opcionId: control.opciones[i].id,
                nombre: control.opciones[i].nombre,
                subtitulo: _pistaSustrato(control.opciones[i].id),
                colorAcento: colorPrincipal,
                colorFondo: colorFondo,
                elegido: sueloElegido == control.opciones[i].id,
                onTap: () => onElegirSuelo(control.opciones[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EstacionRiegoInteractiva extends StatelessWidget {
  const _EstacionRiegoInteractiva({
    required this.control,
    required this.aguaElegida,
    required this.etapaActual,
    required this.onElegirAgua,
  });

  final Control control;
  final String? aguaElegida;
  final int etapaActual;
  final ValueChanged<String> onElegirAgua;

  String _pistaAgua(String id) {
    return switch (id) {
      'poca' => 'Tierra seca',
      'justa' => 'Húmeda y con aire',
      'mucha' => 'Ahoga sin aire',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    const colorAgua = Color(0xFF0284C7);
    const colorFondo = Color(0xFFF0F9FF);
    final dia = switch (etapaActual) {
      1 => 1,
      2 => 3,
      3 => 5,
      _ => 7,
    };

    return _ContenedorEstacion(
      icono: Icons.water_drop_rounded,
      colorPrincipal: colorAgua,
      colorFondo: colorFondo,
      titulo: '2. ¿Cuánta agua le echas en el Día $dia?',
      subtitulo: etapaActual == 1
          ? 'La semilla necesita humedad para despertar, pero también aire para respirar.'
          : '¡Al crecer la planta se bebió el agua! Elige «Riego suave» para regarla hoy.',
      child: Row(
        children: [
          for (var i = 0; i < control.opciones.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _OpcionControl(
                key: Key('control-agua-${control.opciones[i].id}'),
                controlId: 'agua',
                opcionId: control.opciones[i].id,
                nombre: control.opciones[i].nombre,
                subtitulo: _pistaAgua(control.opciones[i].id),
                colorAcento: colorAgua,
                colorFondo: colorFondo,
                elegido: aguaElegida == control.opciones[i].id,
                onTap: () => onElegirAgua(control.opciones[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EstacionVentanaLaboratorio extends StatelessWidget {
  const _EstacionVentanaLaboratorio({
    required this.control,
    required this.luzElegida,
    required this.etapaActual,
    required this.onElegirLuz,
  });

  final Control control;
  final String? luzElegida;
  final int etapaActual;
  final ValueChanged<String> onElegirLuz;

  String _pistaLuz(String id) {
    return switch (id) {
      'poca' => 'Sin luz del sol',
      'justa' => 'Luz suave ideal',
      'excesiva' || 'mucha' => 'Calienta y seca',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    const colorLuz = Color(0xFFD97706);
    const colorFondo = Color(0xFFFFFBEB);
    return _ContenedorEstacion(
      icono: Icons.wb_sunny_rounded,
      colorPrincipal: colorLuz,
      colorFondo: colorFondo,
      titulo: '3. ¿Qué luz entra por la ventana?',
      subtitulo: etapaActual < 3
          ? 'Mientras está bajo tierra no usa la luz, pero cuando asome el tallo necesitará sol.'
          : '¡Ya tiene tallo! Con «Luz del sol» sus hojas serán verdes; a oscuras saldrán amarillas.',
      child: Row(
        children: [
          for (var i = 0; i < control.opciones.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _OpcionControl(
                key: Key('control-luz-${control.opciones[i].id}'),
                controlId: 'luz',
                opcionId: control.opciones[i].id,
                nombre: control.opciones[i].nombre,
                subtitulo: _pistaLuz(control.opciones[i].id),
                colorAcento: colorLuz,
                colorFondo: colorFondo,
                elegido: luzElegida == control.opciones[i].id,
                onTap: () => onElegirLuz(control.opciones[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EstacionTermostatoLaboratorio extends StatelessWidget {
  const _EstacionTermostatoLaboratorio({
    required this.control,
    required this.temperaturaElegida,
    required this.onElegirTemperatura,
  });

  final Control control;
  final String? temperaturaElegida;
  final ValueChanged<String> onElegirTemperatura;

  String _pistaTemperatura(String id) {
    return switch (id) {
      'fria' => 'Frío de nevera',
      'templada' => 'Templado ideal',
      'calor' => 'Seca la maceta',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    const colorTemp = Color(0xFF0D9488);
    const colorFondo = Color(0xFFF0FDFA);
    return _ContenedorEstacion(
      icono: Icons.thermostat_rounded,
      colorPrincipal: colorTemp,
      colorFondo: colorFondo,
      titulo: '4. ¿Qué temperatura hace en el invernadero?',
      subtitulo:
          'Con mucho frío la semilla sigue dormida y con demasiado calor se seca el agua.',
      child: Row(
        children: [
          for (var i = 0; i < control.opciones.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _OpcionControl(
                key: Key('control-temperatura-${control.opciones[i].id}'),
                controlId: 'temperatura',
                opcionId: control.opciones[i].id,
                nombre: control.opciones[i].nombre,
                subtitulo: _pistaTemperatura(control.opciones[i].id),
                colorAcento: colorTemp,
                colorFondo: colorFondo,
                elegido: temperaturaElegida == control.opciones[i].id,
                onTap: () => onElegirTemperatura(control.opciones[i].id),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContenedorEstacion extends StatelessWidget {
  const _ContenedorEstacion({
    required this.icono,
    required this.colorPrincipal,
    required this.colorFondo,
    required this.titulo,
    required this.subtitulo,
    required this.child,
  });

  final IconData icono;
  final Color colorPrincipal;
  final Color colorFondo;
  final String titulo;
  final String subtitulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorPrincipal.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorPrincipal.withValues(alpha: 0.16),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: colorFondo,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorPrincipal.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icono, size: 18, color: colorPrincipal),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Texto(
                      titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: colorPrincipal,
                      ),
                    ),
                    Texto(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InsigniaHerramientaArrastre extends StatelessWidget {
  const _InsigniaHerramientaArrastre({required this.accion});

  final _AccionHerramienta accion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accion.color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(accion.icono, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Texto(
            accion.etiqueta,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionControl extends StatelessWidget {
  const _OpcionControl({
    super.key,
    required this.controlId,
    required this.opcionId,
    required this.nombre,
    this.subtitulo = '',
    required this.colorAcento,
    required this.colorFondo,
    required this.elegido,
    required this.onTap,
  });

  final String controlId;
  final String opcionId;
  final String nombre;
  final String subtitulo;
  final Color colorAcento;
  final Color colorFondo;
  final bool elegido;
  final VoidCallback onTap;

  IconData _iconoOpcion() {
    return switch ((controlId, opcionId)) {
      ('agua', 'poca') => Icons.water_drop_outlined,
      ('agua', 'justa') => Icons.water_drop_rounded,
      ('agua', 'mucha') => Icons.waves_rounded,
      ('luz', 'poca') => Icons.nightlight_round,
      ('luz', 'justa') => Icons.wb_sunny_rounded,
      ('luz', 'mucha') => Icons.wb_sunny_outlined,
      ('luz', 'excesiva') => Icons.flare_rounded,
      ('suelo', 'piedras') => Icons.grain_rounded,
      ('suelo', 'arena') => Icons.hourglass_bottom_rounded,
      ('suelo', 'algodon') => Icons.cloud_rounded,
      ('suelo', 'huerto') => Icons.spa_rounded,
      ('temperatura', 'fria') => Icons.ac_unit_rounded,
      ('temperatura', 'templada') => Icons.thermostat_rounded,
      ('temperatura', 'calor') => Icons.local_fire_department_rounded,
      _ => Icons.circle_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final icono = _iconoOpcion();
    final accion = _AccionHerramienta(
      controlId: controlId,
      opcionId: opcionId,
      etiqueta: nombre,
      icono: icono,
      color: colorAcento,
    );
    final tarjeta = Material(
      color: elegido ? colorAcento : colorFondo,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: elegido
                  ? colorAcento
                  : colorAcento.withValues(alpha: 0.28),
              width: elegido ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                size: 18,
                color: elegido ? Colors.white : colorAcento,
              ),
              const SizedBox(height: 2),
              Texto(
                nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: elegido ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              if (subtitulo.isNotEmpty) ...[
                const SizedBox(height: 1),
                Texto(
                  subtitulo,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: elegido
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return Draggable<_AccionHerramienta>(
      data: accion,
      feedback: Material(
        color: Colors.transparent,
        child: _InsigniaHerramientaArrastre(accion: accion),
      ),
      childWhenDragging: Opacity(opacity: 0.45, child: tarjeta),
      child: tarjeta,
    );
  }
}

class _Orden extends StatefulWidget {
  const _Orden({
    required this.actividad,
    required this.nivelActual,
    required this.curso,
    required this.pasosTotales,
    required this.pasosDisponibles,
    required this.orden,
    required this.resultado,
    required this.baseCompletada,
    required this.mostrarPreguntaFinal,
    required this.preguntaFinal,
    required this.preguntaFinalElegida,
    required this.onSalirNivel,
    required this.onAnadir,
    required this.onQuitar,
    required this.onComprobar,
    required this.onResponderFinal,
    required this.onOtraVez,
    required this.onVolver,
    this.onCuriosidad,
  });

  final Actividad actividad;
  final NivelLugar? nivelActual;
  final String curso;
  final List<Opcion> pasosTotales;
  final List<Opcion> pasosDisponibles;
  final List<String> orden;
  final Resultado? resultado;
  final bool baseCompletada;
  final bool mostrarPreguntaFinal;
  final PreguntaExtra? preguntaFinal;
  final String? preguntaFinalElegida;
  final VoidCallback? onSalirNivel;
  final ValueChanged<String> onAnadir;
  final ValueChanged<int> onQuitar;
  final VoidCallback onComprobar;
  final ValueChanged<String> onResponderFinal;
  final VoidCallback onOtraVez;
  final VoidCallback onVolver;
  final VoidCallback? onCuriosidad;

  @override
  State<_Orden> createState() => _OrdenState();
}

class _OrdenState extends State<_Orden> {
  String? _etapaFoco;

  @override
  void didUpdateWidget(covariant _Orden oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nivelActual?.id != widget.nivelActual?.id) {
      _etapaFoco = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actividad = widget.actividad;
    final nivelActual = widget.nivelActual;
    final pasosNivel = widget.pasosTotales.isNotEmpty
        ? widget.pasosTotales
        : actividad.pasos;
    final totalPasos = pasosNivel.length;
    final orden = widget.orden;
    String nombre(String id) => pasosNivel
        .firstWhere(
          (paso) => paso.id == id,
          orElse: () => actividad.pasos.firstWhere(
            (p) => p.id == id,
            orElse: () => Opcion(id: id, nombre: id),
          ),
        )
        .nombre;
    final introNivel = nivelActual?.intro ?? '';
    final fraseInicial = introNivel.isNotEmpty
        ? introNivel
        : (actividad.intro.isNotEmpty
              ? actividad.intro
              : 'Explora el laboratorio arriba y ordena las etapas de la vida.');
    final finalActual = widget.preguntaFinal ?? nivelActual?.preguntaFinal;
    final idsPasosNivel = {for (final p in pasosNivel) p.id};
    final etapaPorDefecto = pasosNivel.isNotEmpty
        ? pasosNivel.first.id
        : 'celulas';
    final focoValido =
        (_etapaFoco != null && idsPasosNivel.contains(_etapaFoco))
        ? _etapaFoco
        : null;
    final etapaActiva =
        focoValido ?? (orden.isNotEmpty ? orden.last : etapaPorDefecto);
    final compacto = totalPasos > 4;
    final altoCasilla = compacto ? 44.0 : 48.0;

    Widget casillaHistoria(int i) {
      final ocupada = i < orden.length;
      if (ocupada) {
        final pasoId = orden[i];
        return Material(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            key: Key('hueco-$i'),
            borderRadius: BorderRadius.circular(13),
            onTap: () {
              setState(() => _etapaFoco = pasoId);
              if (!widget.baseCompletada) {
                widget.onQuitar(i);
              }
            },
            child: Container(
              height: altoCasilla,
              padding: EdgeInsets.symmetric(
                horizontal: compacto ? 5 : 7,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFF10B981), width: 1.8),
              ),
              child: Row(
                children: [
                  DibujoPasoVida(id: pasoId, tamano: compacto ? 26 : 30),
                  SizedBox(width: compacto ? 4 : 6),
                  Expanded(
                    child: Texto(
                      '${i + 1}. ${nombre(pasoId)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compacto ? 10.2 : 11.2,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ),
                  Icon(
                    widget.baseCompletada
                        ? Icons.check_circle_rounded
                        : Icons.close_rounded,
                    size: compacto ? 13 : 15,
                    color: const Color(0xFF047857),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return DragTarget<String>(
        onAcceptWithDetails: (details) {
          setState(() => _etapaFoco = details.data);
          widget.onAnadir(details.data);
        },
        builder: (context, candidatos, _) {
          final encima = candidatos.isNotEmpty;
          return Container(
            height: altoCasilla,
            padding: EdgeInsets.symmetric(
              horizontal: compacto ? 6 : 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: encima ? const Color(0xFFE0F2FE) : Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: encima
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFCBD5E1),
                width: 1.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: compacto ? 20 : 23,
                  height: compacto ? 20 : 23,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF94A3B8)),
                  ),
                  child: Texto(
                    '${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: compacto ? 10.5 : 11.5,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                SizedBox(width: compacto ? 5 : 7),
                Expanded(
                  child: Texto(
                    i == orden.length ? 'Siguiente' : 'Paso ${i + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compacto ? 10.5 : 11.2,
                      fontWeight: FontWeight.w800,
                      color: i == orden.length
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget muralPasos() {
      if (totalPasos == 5) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: casillaHistoria(0)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(1)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(2)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: casillaHistoria(3)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(4)),
              ],
            ),
          ],
        );
      }
      if (totalPasos >= 6) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: casillaHistoria(0)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(1)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(2)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: casillaHistoria(3)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(4)),
                const SizedBox(width: 6),
                Expanded(child: casillaHistoria(5)),
              ],
            ),
          ],
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: casillaHistoria(0)),
              const SizedBox(width: 8),
              Expanded(child: casillaHistoria(1)),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(child: casillaHistoria(2)),
              const SizedBox(width: 8),
              Expanded(child: casillaHistoria(3)),
            ],
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CabeceraNivel(
            nivel: nivelActual,
            curso: widget.curso,
            onCambiarNivel: widget.onSalirNivel,
          ),
          const SizedBox(height: 4),
          if (widget.mostrarPreguntaFinal && finalActual != null)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: _TarjetaPreguntaExtra(
                    etiquetaSuperior: '✓ Ciclo ordenado',
                    subtituloDerecho: '¡Pregunta extra!',
                    pregunta: finalActual,
                    elegida: widget.preguntaFinalElegida,
                    prefijoKey: 'final-${actividad.id}',
                    onResponder: widget.onResponderFinal,
                  ),
                ),
              ),
            )
          else ...[
            EscenaVidaInteractiva(
              etapaActiva: etapaActiva,
              nivelId: nivelActual?.id ?? 'facil',
              onSeleccionarEtapa: (id) => setState(() => _etapaFoco = id),
            ),
            const SizedBox(height: 5),
            muralPasos(),
            const SizedBox(height: 5),
            Expanded(
              child: orden.length == totalPasos
                  ? Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.baseCompletada
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFBAE6FD),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Texto(
                                widget.baseCompletada
                                    ? '¡Historia de la vida completada! Toca cualquier viñeta o pestaña superior para explorar.'
                                    : '¡Las $totalPasos viñetas están colocadas! Pulsa «${actividad.boton}» o toca una viñeta si quieres cambiarla.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (widget.baseCompletada &&
                                  widget.onCuriosidad != null) ...[
                                const SizedBox(height: 6),
                                OutlinedButton.icon(
                                  key: const Key('curiosidad-vida'),
                                  onPressed: widget.onCuriosidad,
                                  icon: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 16,
                                  ),
                                  label: const Texto('Ver curiosidad'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        for (final paso in widget.pasosDisponibles)
                          if (!orden.contains(paso.id)) ...[
                            Draggable<String>(
                              data: paso.id,
                              dragAnchorStrategy: pointerDragAnchorStrategy,
                              feedback: Material(
                                color: Colors.transparent,
                                child: DibujoPasoVida(id: paso.id, tamano: 52),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.4,
                                child: _TarjetaPasoVida(
                                  paso: paso,
                                  explicacion: _explicacionPasoVida(
                                    paso.id,
                                    nivelActual?.id,
                                  ),
                                  onTap: () {
                                    setState(() => _etapaFoco = paso.id);
                                    widget.onAnadir(paso.id);
                                  },
                                ),
                              ),
                              child: _TarjetaPasoVida(
                                key: Key('paso-${paso.id}'),
                                paso: paso,
                                explicacion: _explicacionPasoVida(
                                  paso.id,
                                  nivelActual?.id,
                                ),
                                onTap: () {
                                  setState(() => _etapaFoco = paso.id);
                                  widget.onAnadir(paso.id);
                                },
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                      ],
                    ),
            ),
          ],
          const SizedBox(height: 4),
          Burbuja(
            quien: actividad.quien,
            frase: widget.resultado?.frase ?? fraseInicial,
            gesto: widget.resultado?.gesto ?? 'hola',
          ),
          if (!widget.mostrarPreguntaFinal) ...[
            const SizedBox(height: 6),
            if (widget.baseCompletada)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('otra-vez-orden'),
                      onPressed: widget.onOtraVez,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Texto('Otra vez'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      key: const Key('volver-orden'),
                      onPressed: widget.onVolver,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Texto('Volver'),
                    ),
                  ),
                ],
              )
            else
              FilledButton(
                key: const Key('comprobar'),
                onPressed: widget.onComprobar,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Texto(actividad.boton),
              ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaPasoVida extends StatelessWidget {
  const _TarjetaPasoVida({
    super.key,
    required this.paso,
    required this.explicacion,
    required this.onTap,
  });

  final Opcion paso;
  final String explicacion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFE2E8F0),
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              DibujoPasoVida(id: paso.id, tamano: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Texto(
                      paso.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Texto(
                      explicacion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.2,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF0284C7),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.id, this.tamano = 64});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Criatura(id: id),
      ),
    );
  }
}

String? _pistaReto(String id) => switch (id) {
  'corazon' => 'Late sin parar para impulsar la sangre',
  'pulmones' => 'Dos esponjas rosas que toman aire',
  'estomago' => 'Mezcla y transforma la comida',
  'cerebro' => 'Piensa, recuerda y dirige el cuerpo',
  'esqueleto' => 'Huesos que nos sostienen y mueven',
  'intestinos' => 'Absorben los nutrientes y el agua',
  _ => null,
};

String? _subtituloSitio(String id) => switch (id) {
  'cabeza' => 'Cráneo y cerebro',
  'pecho' => 'Protegido por las costillas',
  'barriga' => 'Estómago e intestinos',
  'extremidades' => 'Brazos y piernas en movimiento',
  _ => null,
};

String _explicacionPasoVida(String pasoId, String? nivelId) {
  return switch ((pasoId, nivelId)) {
    ('celulas', 'dificil') =>
      '2 células reproductoras se fusionan en 1 única célula inicial llamada cigoto (2 → 1).',
    ('celulas', _) =>
      'Dos células diminutas se unen en una sola para iniciar una nueva vida.',
    ('division', _) =>
      'No se separan: esa primera célula fabrica copias de sí misma (1 → 2 → 4 → 8 → 16 células).',
    ('tejidos', _) =>
      'Las células multiplicadas se reparten tareas y forman los primeros tejidos y órganos.',
    ('embrion', _) =>
      'En los primeros meses el embrión es diminuto, pero su corazón ya empieza a latir.',
    ('feto', _) =>
      'El feto ya tiene forma de bebé y se alimenta en el útero por el cordón umbilical.',
    ('utero', 'dificil') =>
      'El feto crece protegido en el útero recibiendo oxígeno y nutrientes por la placenta.',
    ('utero', _) =>
      'Durante unos nueve meses crece calentito y protegido dentro del útero materno.',
    ('nace', 'dificil') =>
      'Al nacer, sus pulmones se llenan de aire por primera vez y el cordón deja el ombligo.',
    ('nace', _) =>
      'Cuando ya está preparado, el bebé sale al exterior y respira aire por sí mismo.',
    ('organismo', _) =>
      'Tras nacer, crecemos pasando por la infancia, la adolescencia y la etapa adulta.',
    ('cuidados', _) =>
      'Necesita leche, cariño, descanso y cuidados diarios para crecer sano y fuerte.',
    ('embarazo', _) =>
      'Durante nueve meses el bebé se forma y crece protegido dentro del útero materno.',
    ('bebe', _) =>
      'Toma leche, le salen los primeros dientes de leche y aprende a gatear y caminar.',
    _ => '',
  };
}

Color _colorSitio(String id) {
  switch (id) {
    case 'desierto':
      return const Color(0xFFFFF3C4);
    case 'mar':
      return const Color(0xFFE0F2FE);
    case 'polo':
      return const Color(0xFFF0F9FF);
    case 'bosque':
      return const Color(0xFFDCFCE7);
    case 'selva':
      return const Color(0xFFD1FAE5);
    case 'rio':
      return const Color(0xFFCFFAFE);
    case 'cabeza':
      return const Color(0xFFF3E8FF);
    case 'pecho':
      return const Color(0xFFFFE4E6);
    case 'barriga':
      return const Color(0xFFFEF3C7);
    case 'extremidades':
      return const Color(0xFFE0F2FE);
    default:
      return const Color(0xFFF6F1E6);
  }
}

Color _bordeSitio(String id) {
  switch (id) {
    case 'desierto':
      return const Color(0xFFF59E0B);
    case 'mar':
      return const Color(0xFF38BDF8);
    case 'polo':
      return const Color(0xFF7DD3FC);
    case 'bosque':
      return const Color(0xFF4ADE80);
    case 'selva':
      return const Color(0xFF10B981);
    case 'rio':
      return const Color(0xFF06B6D4);
    case 'cabeza':
      return const Color(0xFFC084FC);
    case 'pecho':
      return const Color(0xFFFB7185);
    case 'barriga':
      return const Color(0xFFFBBF24);
    case 'extremidades':
      return const Color(0xFF38BDF8);
    default:
      return const Color(0xFFD6CFC0);
  }
}
