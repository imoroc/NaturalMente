import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/aula/aula.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/ui/aula/escenas.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/tema.dart';

/// Imagen de un juego de Aula: de la galería de la app o subida por el profe.
class ImagenDeAula extends StatelessWidget {
  const ImagenDeAula(this.imagen, {this.ajuste = BoxFit.contain, super.key});

  final ImagenAula imagen;
  final BoxFit ajuste;

  /// Cómo se cargan las fotos subidas por el profe. En la app se guardan en
  /// el dispositivo para jugar sin conexión. En el panel web ya las guarda el
  /// navegador (se suben con caché de un año). Las pruebas lo sustituyen.
  static ImageProvider Function(String url) proveedorRed = (url) =>
      kIsWeb ? NetworkImage(url) : CachedNetworkImageProvider(url);

  @override
  Widget build(BuildContext context) => switch (imagen) {
    ImagenEscena(:final id) => EscenaAula(id),
    ImagenGaleria(:final asset) => Image.asset(asset, fit: ajuste),
    ImagenSubida(:final url) => Image(
      image: proveedorRed(url),
      fit: ajuste,
      errorBuilder: (_, _, _) => const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 32),
      ),
    ),
  };
}

/// Juega un test del profesor (opción múltiple o verdadero/falso) con el
/// feedback y el cierre comunes de todos los juegos.
class JuegoAulaPage extends StatefulWidget {
  const JuegoAulaPage({
    required this.juego,
    this.vistaPrevia = false,
    super.key,
  });

  final JuegoAula juego;

  /// En el panel del profesor: no guarda nada ni da semillas.
  final bool vistaPrevia;

  @override
  State<JuegoAulaPage> createState() => _JuegoAulaPageState();
}

class _JuegoAulaPageState extends State<JuegoAulaPage>
    with FeedbackAcierto<JuegoAulaPage> {
  int _paso = 0;
  int? _elegida;
  final Set<int> _descartadas = {};
  bool _resuelto = false;
  bool _fallo = false;
  bool _completo = false;
  bool _conSemillas = false;
  final List<bool> _aLaPrimera = [];
  int _semillasSesion = 0;
  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _vuelta = 0;
  bool _inicializado = false;

  JuegoAula get _juego => widget.juego;
  PreguntaAula get _pregunta => _juego.preguntas[_paso];
  Progreso? get _progreso => Alcance.maybeOf(context)?.progreso;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      _prepararPartida();
    }
  }

  void _prepararPartida() {
    final progreso = _progreso;
    _paso = 0;
    _elegida = null;
    _descartadas.clear();
    _resuelto = false;
    _fallo = false;
    _completo = false;
    _aLaPrimera.clear();
    _semillasSesion = 0;
    // Las semillas solo se dan la primera vez que se completa esta versión.
    _conSemillas =
        !widget.vistaPrevia &&
        progreso != null &&
        !progreso.juegoAulaHecho(_juego.id, _juego.version);
    _comboActual = _conSemillas ? progreso!.comboActual : 0;
    _mejorComboSesion = _comboActual;
  }

  void _empezarDeNuevo() {
    ocultarAcierto();
    setState(() {
      _vuelta++;
      _prepararPartida();
    });
  }

  void _elegir(int indice) {
    if (_resuelto || _completo || _descartadas.contains(indice)) return;
    if (!iniciarPasoEvaluado()) return;
    final pregunta = _pregunta;
    if (indice != pregunta.correcta) {
      if (_conSemillas) guardarPrecisionPaso(acierto: false);
      setState(() {
        _elegida = indice;
        _descartadas.add(indice);
        _fallo = true;
        _comboActual = 0;
      });
      terminarIntentoConPista();
      context.sonidoPista();
      return;
    }
    final aLaPrimera = !_fallo;
    if (_conSemillas) {
      final nuevoCombo = aLaPrimera ? (_progreso!.comboActual + 1) : 1;
      final ganadas = guardarPrecisionPaso(
        acierto: true,
        aLaPrimera: aLaPrimera,
        comboActual: nuevoCombo,
      );
      _semillasSesion += ganadas;
      _comboActual = _progreso!.comboActual;
    } else {
      _comboActual = aLaPrimera ? _comboActual + 1 : 1;
    }
    setState(() {
      _elegida = indice;
      _resuelto = true;
      _aLaPrimera.add(aLaPrimera);
      if (_comboActual > _mejorComboSesion) _mejorComboSesion = _comboActual;
    });
    if (_paso + 1 < _juego.preguntas.length) {
      confirmarPaso(
        alContinuar: _siguiente,
        esperarContinuar: pregunta.explicacion.isNotEmpty,
      );
      return;
    }
    setState(() => _completo = true);
    mostrarAcierto(finalDeNivel: true);
    _registrarGuardado();
  }

  void _siguiente() {
    _paso++;
    _elegida = null;
    _descartadas.clear();
    _resuelto = false;
    _fallo = false;
  }

  void _registrarGuardado() {
    if (widget.vistaPrevia) {
      registrarGuardadoFinal(() async => true);
      return;
    }
    // Todo lo que se guarda se calcula ahora, antes de cualquier espera.
    final progreso = _progreso;
    final aula = AulaScope.maybeOf(context);
    final perfilId = PerfilesScope.maybeOf(context)?.activo.id;
    final juego = _juego;
    final resultado = ResultadoAula(
      idLocal:
          aula?.nuevoIdPartida() ?? '${DateTime.now().microsecondsSinceEpoch}',
      juegoId: juego.id,
      version: juego.version,
      aciertos: _aLaPrimera.where((a) => a).length,
      total: juego.preguntas.length,
      jugado: DateTime.now(),
      respuestas: List.of(_aLaPrimera),
    );
    registrarGuardadoFinal(() async {
      try {
        if (progreso != null) {
          await progreso.marcarJuegoAula(juego.id, juego.version);
        }
        if (aula != null && perfilId != null) {
          return await aula.guardarResultado(perfilId, resultado);
        }
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  @override
  DatosFinJuego? construirFinJuego() {
    if (!_completo) return null;
    return DatosFinJuego(
      actividad: _juego.titulo,
      nivel: 'Aula',
      resumen: ResumenPrecisionFinal(
        aciertosALaPrimera: _aLaPrimera.where((a) => a).length,
        totalPasos: _juego.preguntas.length,
        mejorComboSesion: _mejorComboSesion,
        semillasGanadas: _semillasSesion,
      ),
      onRepetir: _empezarDeNuevo,
      textoVolver: widget.vistaPrevia ? 'Volver al editor' : 'Volver a Aula',
      onVolver: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final fondo = _juego.fondo;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _juego.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_conSemillas)
            InsigniaPrecisionAppBar(
              comboActual: presentarCombo(_comboActual),
              discreta: true,
              semillasSesion: _semillasSesion,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (fondo != null) ...[
            ExcludeSemantics(child: ImagenDeAula(fondo, ajuste: BoxFit.cover)),
            // Velo para que el texto se lea sobre cualquier fondo.
            ColoredBox(
              color: colores.oscuro
                  ? const Color(0x73000000)
                  : (fondo is ImagenEscena
                        ? const Color(0x00000000)
                        : const Color(0x4DFFFFFF)),
            ),
          ],
          construirContenidoPaso(
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, medidas) {
                  // En tablets apaisadas y en el panel, la pregunta a un lado
                  // y las respuestas al otro: todo cabe sin desplazar.
                  final ancho = medidas.maxWidth >= 760;
                  return SingleChildScrollView(
                    key: ValueKey('aula-${_juego.id}-$_vuelta-$_paso'),
                    padding: EdgeInsets.all(medidas.maxWidth < 380 ? 12 : 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: ancho ? 1100 : 640,
                        ),
                        child: ancho
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: _columnaPregunta(context, medidas),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 4,
                                    child: _columnaRespuestas(context),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _columnaPregunta(context, medidas),
                                  const SizedBox(height: 14),
                                  _columnaRespuestas(context),
                                ],
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _columnaPregunta(BuildContext context, BoxConstraints medidas) {
    final colores = context.coloresNaturales;
    final pregunta = _pregunta;
    final total = _juego.preguntas.length;
    final estilo = Theme.of(context).textTheme;
    final altoImagen = (medidas.maxHeight * 0.3).clamp(120.0, 260.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: context.tr('Pregunta ${_paso + 1} de $total'),
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colores.tarjeta.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: (_paso + (_resuelto ? 1 : 0)) / total,
                        minHeight: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_paso + 1}/$total',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: colores.tinta,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colores.tarjeta,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colores.contorno, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_juego.mostrarNatu &&
                  _paso == 0 &&
                  _juego.intro.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DibujoMascota(gesto: 'hola', tamano: 46),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_juego.intro, style: estilo.bodyLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (pregunta.imagen case final imagen?) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: altoImagen,
                    child: ImagenDeAula(imagen),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (pregunta.enunciado.isNotEmpty)
                Text(
                  pregunta.enunciado,
                  key: const Key('enunciado-aula'),
                  textAlign: TextAlign.center,
                  style: estilo.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
        ),
        if (_fallo && !_resuelto && _elegida != null) ...[
          const SizedBox(height: 12),
          _Aviso(
            key: const Key('pista-aula'),
            gesto: 'pista',
            texto: pregunta.pista.isNotEmpty
                ? pregunta.pista
                : context.tr('Casi. Piénsalo otra vez.'),
          ),
        ],
        if (_resuelto && pregunta.explicacion.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Aviso(
            key: const Key('explicacion-aula'),
            gesto: 'feliz',
            texto: pregunta.explicacion,
          ),
        ],
      ],
    );
  }

  Widget _columnaRespuestas(BuildContext context) {
    final pregunta = _pregunta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < pregunta.opciones.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _BotonOpcion(
            key: Key('opcion-aula-$i'),
            opcion: pregunta.opciones[i],
            traducir: _juego.plantilla == PlantillaAula.verdaderoFalso,
            estado: _resuelto && i == pregunta.correcta
                ? _EstadoOpcion.correcta
                : (_descartadas.contains(i)
                      ? _EstadoOpcion.descartada
                      : _EstadoOpcion.normal),
            onTap: () => _elegir(i),
          ),
        ],
      ],
    );
  }
}

enum _EstadoOpcion { normal, correcta, descartada }

class _BotonOpcion extends StatelessWidget {
  const _BotonOpcion({
    required this.opcion,
    required this.estado,
    required this.onTap,
    required this.traducir,
    super.key,
  });

  final OpcionAula opcion;
  final _EstadoOpcion estado;
  final VoidCallback onTap;

  /// Solo «Verdadero» y «Falso» son nuestros; el resto lo escribe el profe.
  final bool traducir;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final (fondo, borde, icono) = switch (estado) {
      _EstadoOpcion.correcta => (
        colores.fondoAcierto,
        colores.acierto,
        Icons.check_circle_rounded,
      ),
      _EstadoOpcion.descartada => (
        colores.fondoPista,
        colores.pista,
        Icons.close_rounded,
      ),
      _EstadoOpcion.normal => (colores.tarjeta, colores.contorno, null),
    };
    final texto = traducir ? context.tr(opcion.texto) : opcion.texto;
    return Semantics(
      button: true,
      selected: estado == _EstadoOpcion.correcta,
      enabled: estado != _EstadoOpcion.descartada,
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: estado == _EstadoOpcion.descartada ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borde, width: 2.5),
            ),
            child: Row(
              children: [
                if (opcion.imagen case final imagen?) ...[
                  SizedBox(width: 64, height: 64, child: ImagenDeAula(imagen)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (icono != null) Icon(icono, color: borde),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto, required this.gesto, super.key});

  final String texto;
  final String gesto;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: gesto == 'pista' ? colores.fondoPista : colores.fondoAcierto,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: DibujoMascota(gesto: gesto, tamano: 40)),
            const SizedBox(width: 10),
            Expanded(child: Text(texto, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
