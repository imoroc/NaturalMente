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
import 'package:naturalmente/ui/aula/retos_aula.dart';
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

/// Juega un juego del profesor, con retos de cualquier tipo, con el feedback
/// y el cierre comunes de todos los juegos.
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
  RetoAula get _reto => _juego.preguntas[_paso];
  bool get _ultimo => _paso + 1 >= _juego.preguntas.length;
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

  /// Un intento del niño en el reto actual. Ver [EvaluarReto].
  bool _evaluar(bool correcto, {bool completa = true}) {
    if (_resuelto || _completo || !iniciarPasoEvaluado()) return false;
    if (!correcto) {
      if (_conSemillas) guardarPrecisionPaso(acierto: false);
      setState(() {
        _fallo = true;
        _comboActual = 0;
      });
      terminarIntentoConPista();
      context.sonidoPista();
      return true;
    }
    if (!completa) {
      // Una pareja de varias: se celebra y el reto sigue.
      confirmarPaso(alContinuar: () {}, conservarTablero: true);
      return true;
    }
    final aLaPrimera = !_fallo;
    if (_conSemillas) {
      final nuevoCombo = aLaPrimera ? (_progreso!.comboActual + 1) : 1;
      _semillasSesion += guardarPrecisionPaso(
        acierto: true,
        aLaPrimera: aLaPrimera,
        comboActual: nuevoCombo,
      );
      _comboActual = _progreso!.comboActual;
    } else {
      _comboActual = aLaPrimera ? _comboActual + 1 : 1;
    }
    setState(() {
      _resuelto = true;
      _aLaPrimera.add(aLaPrimera);
      if (_comboActual > _mejorComboSesion) _mejorComboSesion = _comboActual;
    });
    if (!_ultimo) {
      confirmarPaso(
        alContinuar: _siguiente,
        esperarContinuar: _reto.explicacion.isNotEmpty,
      );
      return true;
    }
    _terminar();
    return true;
  }

  /// Tarjeta para leer: no se puntúa ni se celebra.
  void _leido() {
    if (_completo || pasoBloqueado) return;
    context.sonidoToque();
    if (_ultimo) {
      _terminar();
      return;
    }
    setState(_siguiente);
  }

  void _terminar() {
    setState(() => _completo = true);
    mostrarAcierto(finalDeNivel: true);
    _registrarGuardado();
  }

  void _siguiente() {
    _paso++;
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
      total: juego.evaluables.length,
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
        totalPasos: _juego.evaluables.length,
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
        title: Text(_juego.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  : (fondo is ImagenEscena ? const Color(0x00000000) : const Color(0x4DFFFFFF)),
            ),
          ],
          construirContenidoPaso(
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, medidas) {
                  // En tablets apaisadas y en el panel, la pregunta a un lado
                  // y las respuestas al otro.
                  final ancho = medidas.maxWidth >= 760;
                  return SingleChildScrollView(
                    key: ValueKey('aula-${_juego.id}-$_vuelta-$_paso'),
                    padding: EdgeInsets.all(medidas.maxWidth < 380 ? 12 : 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: ancho ? 1100 : 640),
                        child: ancho
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 5, child: _columnaPregunta(context, medidas)),
                                  const SizedBox(width: 24),
                                  Expanded(flex: 4, child: _columnaRespuestas()),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _columnaPregunta(context, medidas),
                                  const SizedBox(height: 14),
                                  _columnaRespuestas(),
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
    final reto = _reto;
    final total = _juego.preguntas.length;
    final estilo = Theme.of(context).textTheme;
    final altoImagen = (medidas.maxHeight * 0.3).clamp(120.0, 260.0);
    final lectura = reto is LecturaAula ? reto : null;
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
                    style: TextStyle(fontWeight: FontWeight.w900, color: colores.tinta),
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
              BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_juego.mostrarNatu && _paso == 0 && _juego.intro.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DibujoMascota(gesto: 'hola', tamano: 46),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_juego.intro, style: estilo.bodyLarge)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              // En «tocar en la imagen» la imagen es el tablero de juego.
              if (reto.imagen case final imagen? when reto is! BuscarAula) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(height: altoImagen, child: ImagenDeAula(imagen)),
                ),
                const SizedBox(height: 12),
              ],
              if (reto.enunciado.isNotEmpty)
                Text(
                  reto.enunciado,
                  key: const Key('enunciado-aula'),
                  textAlign: TextAlign.center,
                  style: estilo.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              if (lectura != null && lectura.texto.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  lectura.texto,
                  key: const Key('lectura-texto'),
                  style: estilo.bodyLarge?.copyWith(fontSize: 18, height: 1.5),
                ),
              ],
            ],
          ),
        ),
        if (_fallo && !_resuelto) ...[
          const SizedBox(height: 12),
          _Aviso(
            key: const Key('pista-aula'),
            gesto: 'pista',
            texto: reto.pista.isNotEmpty ? reto.pista : context.tr('Casi. Piénsalo otra vez.'),
          ),
        ],
        if (_resuelto && reto.explicacion.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Aviso(key: const Key('explicacion-aula'), gesto: 'feliz', texto: reto.explicacion),
        ],
      ],
    );
  }

  Widget _columnaRespuestas() {
    final reto = _reto;
    if (reto is LecturaAula) {
      return FilledButton.icon(
        key: const Key('lectura-continuar'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        onPressed: _completo ? null : _leido,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          context.tr(_ultimo ? '¡Terminado!' : '¡Entendido!'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
      );
    }
    return VistaReto(
      key: ValueKey('reto-$_vuelta-$_paso'),
      reto: reto,
      resuelto: _resuelto,
      evaluar: _evaluar,
      semilla: _juego.id.hashCode ^ (_paso * 131) ^ (_vuelta * 7919),
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
