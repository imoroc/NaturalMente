import 'package:flutter/material.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/datos/alcance.dart';
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
  final Map<String, String> _valores = {};
  final List<String> _orden = [];
  List<Opcion> _sitiosBarajados = const [];
  List<Opcion> _adaptacionOpcionesBarajadas = const [];
  List<Opcion> _finalOpcionesBarajadas = const [];
  List<Opcion> _pasosBarajados = const [];

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

  bool get _pideAdaptacion => _nivelActual?.preguntaAdaptacion == true;

  bool get _retoCompleto =>
      _lugarAcertado && (!_pideAdaptacion || _adaptacionAcertada);

  String get _cursoActual => _nivelActual?.curso ?? widget.actividad.curso;

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
    if (widget.actividad.pasos.isNotEmpty) {
      _pasosBarajados = BarajadorOpciones.barajarPasos(
        clave: 'pasos-${widget.actividad.id}-${_nivelActual?.id ?? 'base'}',
        pasos: widget.actividad.pasos,
        ordenCorrecto: widget.actividad.respuesta,
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
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
                      ? (_reto < retos.length - 1 ? 'Siguiente' : 'Volver')
                      : null,
                  onSalirNivel: _tieneNiveles ? _salirAlSelector : null,
                  onSoltar: _soltar,
                  onResponderAdaptacion: _responderAdaptacion,
                  onCuriosidad: () => _mostrarCuriosidad(retos[_reto]),
                  onPie: _retoCompleto
                      ? (_reto < retos.length - 1 ? _siguiente : _volver)
                      : _volver,
                ),
                'controles' => _Controles(
                  actividad: actividad,
                  nivelActual: _nivelActual,
                  curso: _cursoActual,
                  controles: _controlesActuales,
                  valores: _valores,
                  resultado: _resultado,
                  frase: _fraseControles(),
                  mostrarPreguntaFinal:
                      _baseCompletada &&
                      _nivelActual?.preguntaFinal != null &&
                      !_preguntaFinalAcertada,
                  preguntaFinal: _preguntaFinalActualBarajada,
                  preguntaFinalElegida: _preguntaFinalElegida,
                  onSalirNivel: _tieneNiveles ? _salirAlSelector : null,
                  onElegir: (control, opcion) =>
                      setState(() => _valores[control] = opcion),
                  onAvanzar: _avanzar,
                  onResponderFinal: _responderPreguntaFinal,
                  onOtraVez:
                      (_baseCompletada &&
                          (_nivelActual?.preguntaFinal == null ||
                              _preguntaFinalAcertada))
                      ? _otraVez
                      : null,
                ),
                _ => _Orden(
                  actividad: actividad,
                  nivelActual: _nivelActual,
                  curso: _cursoActual,
                  pasosDisponibles: _pasosBarajados.isNotEmpty
                      ? _pasosBarajados
                      : actividad.pasos,
                  orden: _orden,
                  resultado: _resultado,
                  mostrarPreguntaFinal:
                      _baseCompletada &&
                      _nivelActual?.preguntaFinal != null &&
                      !_preguntaFinalAcertada,
                  preguntaFinal: _preguntaFinalActualBarajada,
                  preguntaFinalElegida: _preguntaFinalElegida,
                  onSalirNivel: _tieneNiveles ? _salirAlSelector : null,
                  onAnadir: (id) => setState(() {
                    _orden.add(id);
                    _resultado = null;
                  }),
                  onQuitar: (indice) => setState(() {
                    _orden.removeAt(indice);
                    _resultado = null;
                  }),
                  onComprobar: _comprobar,
                  onResponderFinal: _responderPreguntaFinal,
                ),
              },
      ),
    );
  }

  Widget _selector() {
    final progreso = Alcance.of(context).progreso;
    final niveles = widget.actividad.nivelesLugar;
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Burbuja(
            quien: widget.actividad.quien,
            frase:
                'Elige un nivel. Puedes jugar a cualquiera y cambiar cuando quieras.',
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
                          child: Text(
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
                    Text('Pensado para ${niveles[i].curso}'),
                    if (niveles[i].resumen.isNotEmpty) Text(niveles[i].resumen),
                    if (progreso.nivelLugarHecho(widget.actividad, niveles[i].id))
                      const Text(
                        '✓ Nivel superado',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF15803D),
                        ),
                      ),
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
      return widget.actividad.intro.isNotEmpty
          ? widget.actividad.intro
          : 'Elige cuánta agua, cuánta luz y qué suelo necesita la semilla.';
    }
    if (resultado.estado != 'falta') return resultado.frase;
    final faltan = [
      for (final control in _controlesActuales)
        if (!_valores.containsKey(control.id)) control.nombre,
    ];
    if (faltan.isEmpty) return resultado.frase;
    if (faltan.length == 1) return 'Falta elegir ${faltan.single}.';
    return 'Falta elegir ${faltan.join(', ')}.';
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
      _valores.clear();
      _orden.clear();
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
      _valores.clear();
      _orden.clear();
    });
  }

  Future<void> _soltar(String sitio) async {
    if (_lugarAcertado) return;
    final actividad = widget.actividad;
    final reto = _retosLugar[_reto];
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
          _reto == _retosLugar.length - 1) {
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
      }
    });
    if (resultado.acierto) {
      final progreso = Alcance.of(context).progreso;
      await progreso.desbloquearFicha(reto.id);
      if (_nivelActual != null && _reto == _retosLugar.length - 1) {
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
                        const Text(
                          'CUADERNO DE NATU',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
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
                child: const Text('¡Qué interesante!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _siguiente() {
    setState(() {
      _reto += 1;
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
    Navigator.of(context).pop();
  }

  Future<void> _avanzar() async {
    final actividad = widget.actividad;
    final resultado = resolverControles(
      actividad: actividad,
      valores: _valores,
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

  void _otraVez() {
    setState(() {
      _valores.clear();
      _resultado = null;
      _baseCompletada = false;
      _preguntaFinalAcertada = false;
      _preguntaFinalElegida = null;
      _prepararBarajadoNivel();
    });
  }

  Future<void> _comprobar() async {
    final actividad = widget.actividad;
    final resultado = resolverOrden(actividad: actividad, orden: _orden);
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
          child: Text(
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
            label: const Text(
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
                child: Text(
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
                child: Text(
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
          Text(
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
                child: Text(
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
    required this.onResponderAdaptacion,
    required this.onCuriosidad,
    required this.onPie,
  });

  final Actividad actividad;
  final NivelLugar? nivelActual;
  final String curso;
  final List<Opcion> opciones;
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
  final ValueChanged<String> onSoltar;
  final ValueChanged<String> onResponderAdaptacion;
  final VoidCallback onCuriosidad;
  final VoidCallback onPie;

  @override
  Widget build(BuildContext context) {
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
            (indice +
                (retoCompleto ? 1.0 : (lugarAcertado ? 0.65 : 0.25))) /
            total;

        Widget cabeceraReto() {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD6CFC0),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Draggable<String>(
                  data: reto.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _Miniatura(id: reto.id),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _Miniatura(id: reto.id),
                  ),
                  child: _Miniatura(id: reto.id, tamano: 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reto.pregunta,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                      ),
                      if (retoCompleto && reto.curiosidad.isNotEmpty) ...[
                        const SizedBox(height: 6),
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
                                  child: Text(
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
                    value: progresoValor,
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
                  FilledButton(
                    key: const Key('boton-pie-lugar'),
                    onPressed: onPie,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: Text(pie!),
                  ),
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
                  value: progresoValor,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE5DFCF),
                  color: const Color(0xFF2ECC71),
                ),
              ),
              const SizedBox(height: 6),
              cabeceraReto(),
              const SizedBox(height: 8),
              Expanded(child: zonaCentral(usarAlturaFija: false)),
              const SizedBox(height: 8),
              burbujaWidget,
              if (pie != null) ...[
                const SizedBox(height: 8),
                FilledButton(
                  key: const Key('boton-pie-lugar'),
                  onPressed: onPie,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(pie!),
                ),
              ],
            ],
          ),
        );
      },
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
                  const SizedBox(height: 6),
                  Text(
                    opcion.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
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
}

class _Controles extends StatelessWidget {
  const _Controles({
    required this.actividad,
    required this.nivelActual,
    required this.curso,
    required this.controles,
    required this.valores,
    required this.resultado,
    required this.frase,
    required this.mostrarPreguntaFinal,
    required this.preguntaFinal,
    required this.preguntaFinalElegida,
    required this.onSalirNivel,
    required this.onElegir,
    required this.onAvanzar,
    required this.onResponderFinal,
    required this.onOtraVez,
  });

  final Actividad actividad;
  final NivelLugar? nivelActual;
  final String curso;
  final List<Control> controles;
  final Map<String, String> valores;
  final Resultado? resultado;
  final String? frase;
  final bool mostrarPreguntaFinal;
  final PreguntaExtra? preguntaFinal;
  final String? preguntaFinalElegida;
  final VoidCallback? onSalirNivel;
  final void Function(String control, String opcion) onElegir;
  final VoidCallback onAvanzar;
  final ValueChanged<String> onResponderFinal;
  final VoidCallback? onOtraVez;

  @override
  Widget build(BuildContext context) {
    final finalActual = preguntaFinal ?? nivelActual?.preguntaFinal;
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
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              children: [
                DibujoSemilla(
                  estado: mostrarPreguntaFinal
                      ? 'brote'
                      : (resultado?.estado ?? 'seca'),
                ),
                const SizedBox(height: 8),
                if (mostrarPreguntaFinal && finalActual != null)
                  _TarjetaPreguntaExtra(
                    etiquetaSuperior: '✓ Semilla germinada',
                    subtituloDerecho: '¡Pregunta extra!',
                    pregunta: finalActual,
                    elegida: preguntaFinalElegida,
                    prefijoKey: 'final-${actividad.id}',
                    onResponder: onResponderFinal,
                  )
                else ...[
                  Text(
                    actividad.sujeto,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  for (final control in controles) ...[
                    Text(
                      control.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (var i = 0; i < control.opciones.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          Expanded(
                            child: _OpcionControl(
                              nombre: control.opciones[i].nombre,
                              elegido:
                                  valores[control.id] == control.opciones[i].id,
                              onTap: () => onElegir(
                                control.id,
                                control.opciones[i].id,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
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
            FilledButton(
              key: const Key('avanzar'),
              onPressed: onAvanzar,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(actividad.boton),
            ),
          ],
          if (onOtraVez != null) ...[
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: onOtraVez,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Otra vez'),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpcionControl extends StatelessWidget {
  const _OpcionControl({
    required this.nombre,
    required this.elegido,
    required this.onTap,
  });

  final String nombre;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final texto = Text(
      nombre,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    );
    final boton = elegido
        ? FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
            child: texto,
          )
        : FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
            child: texto,
          );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 46),
      child: boton,
    );
  }
}

class _Orden extends StatelessWidget {
  const _Orden({
    required this.actividad,
    required this.nivelActual,
    required this.curso,
    required this.pasosDisponibles,
    required this.orden,
    required this.resultado,
    required this.mostrarPreguntaFinal,
    required this.preguntaFinal,
    required this.preguntaFinalElegida,
    required this.onSalirNivel,
    required this.onAnadir,
    required this.onQuitar,
    required this.onComprobar,
    required this.onResponderFinal,
  });

  final Actividad actividad;
  final NivelLugar? nivelActual;
  final String curso;
  final List<Opcion> pasosDisponibles;
  final List<String> orden;
  final Resultado? resultado;
  final bool mostrarPreguntaFinal;
  final PreguntaExtra? preguntaFinal;
  final String? preguntaFinalElegida;
  final VoidCallback? onSalirNivel;
  final ValueChanged<String> onAnadir;
  final ValueChanged<int> onQuitar;
  final VoidCallback onComprobar;
  final ValueChanged<String> onResponderFinal;

  @override
  Widget build(BuildContext context) {
    String nombre(String id) =>
        actividad.pasos.firstWhere((paso) => paso.id == id).nombre;
    final fraseInicial = actividad.intro.isNotEmpty
        ? actividad.intro
        : 'Toca los pasos en orden del primero al último.';
    final finalActual = preguntaFinal ?? nivelActual?.preguntaFinal;

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
          const SizedBox(height: 6),
          if (mostrarPreguntaFinal && finalActual != null)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: _TarjetaPreguntaExtra(
                    etiquetaSuperior: '✓ Ciclo ordenado',
                    subtituloDerecho: '¡Pregunta extra!',
                    pregunta: finalActual,
                    elegida: preguntaFinalElegida,
                    prefijoKey: 'final-${actividad.id}',
                    onResponder: onResponderFinal,
                  ),
                ),
              ),
            )
          else ...[
            for (var i = 0; i < actividad.pasos.length; i++) ...[
              if (i < orden.length)
                FilledButton.tonal(
                  key: Key('hueco-$i'),
                  onPressed: () => onQuitar(i),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text('${i + 1}. ${nombre(orden[i])}'),
                )
              else
                Container(
                  height: 44,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD6CFC0),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: [
                  for (final paso in pasosDisponibles)
                    if (!orden.contains(paso.id)) ...[
                      FilledButton(
                        key: Key('paso-${paso.id}'),
                        onPressed: () => onAnadir(paso.id),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                        ),
                        child: Text(paso.nombre),
                      ),
                      const SizedBox(height: 6),
                    ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 6),
          Burbuja(
            quien: actividad.quien,
            frase: resultado?.frase ?? fraseInicial,
            gesto: resultado?.gesto ?? 'hola',
          ),
          if (!mostrarPreguntaFinal) ...[
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('comprobar'),
              onPressed: onComprobar,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(actividad.boton),
            ),
          ],
        ],
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
