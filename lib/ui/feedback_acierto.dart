import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/fin_juego.dart';

/// Un único acierto sobre toda la pantalla, ligado a la vida del juego.
mixin FeedbackAcierto<T extends StatefulWidget> on State<T> {
  OverlayEntry? _acierto;
  int _version = 0;
  bool _finAbierto = false;
  bool _victoriaEnCurso = false;
  Future<bool>? _guardadoFinal;
  Future<bool> Function()? _guardarDeNuevo;

  DatosFinJuego? construirFinJuego() => null;

  /// Captura solo el guardado, para reintentarlo sin repetir puntos ni respuestas.
  Future<bool> registrarGuardadoFinal(Future<bool> Function() guardar) {
    _guardarDeNuevo = guardar;
    return _guardadoFinal = () async {
      try {
        return await guardar();
      } catch (_) {
        return false;
      }
    }();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carga el audio antes de la respuesta para evitar la espera del primer uso.
    IdiomaScope.of(context)?.prepararAciertos();
  }

  void mostrarAcierto({bool finalDeNivel = false}) {
    if (!mounted) return;
    if (finalDeNivel && (_victoriaEnCurso || _finAbierto)) return;
    ocultarAcierto();
    _victoriaEnCurso = finalDeNivel;
    final version = _version;
    if (finalDeNivel) {
      _guardadoFinal = null;
      _guardarDeNuevo = null;
    }
    final idioma = IdiomaScope.of(context);
    late final OverlayEntry entrada;
    entrada = OverlayEntry(
      builder: (_) {
        final animacion = AnimacionAcierto(
          finalDeNivel: finalDeNivel,
          etiqueta: context.tr(
            finalDeNivel ? '¡Nivel superado!' : '¡Muy bien!',
          ),
          alAparecer: () {
            if (finalDeNivel) {
              idioma?.reproducirCelebracion();
            } else {
              idioma?.reproducirAcierto();
            }
          },
          alTerminar: () {
            if (!identical(_acierto, entrada)) return;
            _retirarAcierto();
            _victoriaEnCurso = false;
            if (finalDeNivel) _mostrarFinJuego(version);
          },
        );
        return Positioned.fill(
          child: finalDeNivel && construirFinJuego() != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Evita reiniciar o abrir otra ruta antes de presentar
                    // las opciones. Los aciertos intermedios siguen libres.
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.transparent,
                    ),
                    animacion,
                  ],
                )
              : animacion,
        );
      },
    );
    _acierto = entrada;
    Overlay.of(context).insert(entrada);
  }

  void ocultarAcierto() {
    _version++;
    _victoriaEnCurso = false;
    _retirarAcierto();
  }

  void _retirarAcierto() {
    _acierto?.remove();
    _acierto?.dispose();
    _acierto = null;
  }

  Future<void> _mostrarFinJuego(int version) async {
    if (!mounted ||
        version != _version ||
        _finAbierto ||
        ModalRoute.of(context)?.isCurrent != true ||
        construirFinJuego() == null) {
      return;
    }
    _finAbierto = true;
    var ultimosDatos = construirFinJuego()!;
    final reducido = MediaQuery.disableAnimationsOf(context);
    final accion = await showGeneralDialog<AccionFinJuego>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: reducido ? 0 : 280),
      pageBuilder: (_, _, _) => FinJuego(
        // La ruta sigue montada mientras se desvanece, aunque el juego ya
        // haya empezado otro nivel como respuesta a una de las acciones.
        datos: () => ultimosDatos = construirFinJuego() ?? ultimosDatos,
        guardado: _guardadoFinal ?? Future.value(true),
        onGuardarDeNuevo: () => registrarGuardadoFinal(_guardarDeNuevo!),
      ),
      transitionBuilder: (_, animacion, _, child) => FadeTransition(
        opacity: animacion,
        child: ScaleTransition(
          scale: Tween(begin: .97, end: 1.0).animate(
            CurvedAnimation(parent: animacion, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
    );
    _finAbierto = false;
    if (!mounted || version != _version) return;
    final datos = construirFinJuego();
    if (datos == null) return;
    switch (accion) {
      case AccionFinJuego.repetir:
        datos.onRepetir?.call();
      case AccionFinJuego.nivel:
        datos.onCambiarNivel?.call();
      case AccionFinJuego.volver:
        datos.onVolver();
      case AccionFinJuego.extra:
        datos.onExtra?.call();
      case AccionFinJuego.explorar:
      case null:
        break;
    }
  }

  @override
  void dispose() {
    ocultarAcierto();
    super.dispose();
  }
}

/// Pop breve y salida suave; la victoria acompaña la fanfarria completa.
class AnimacionAcierto extends StatefulWidget {
  const AnimacionAcierto({
    required this.finalDeNivel,
    required this.etiqueta,
    required this.alAparecer,
    required this.alTerminar,
    super.key,
  });

  final bool finalDeNivel;
  final String etiqueta;
  final VoidCallback alAparecer;
  final VoidCallback alTerminar;

  static const duracion = Duration(milliseconds: 1250);
  static const duracionFinal = Duration(milliseconds: 2350);

  @override
  State<AnimacionAcierto> createState() => _AnimacionAciertoState();
}

class _AnimacionAciertoState extends State<AnimacionAcierto>
    with SingleTickerProviderStateMixin {
  static final _entradaSuave = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: .76,
        end: 1.025,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 70,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.025,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 30,
    ),
  ]);
  late final AnimationController _controlador;
  bool _iniciada = false;

  @override
  void initState() {
    super.initState();
    _controlador =
        AnimationController(
          vsync: this,
          duration: widget.finalDeNivel
              ? AnimacionAcierto.duracionFinal
              : AnimacionAcierto.duracion,
          // La preferencia de movimiento reducido se resuelve en el dibujo:
          // conserva el tiempo de lectura y el desvanecimiento, sin rebote.
          animationBehavior: AnimationBehavior.preserve,
        )..addStatusListener((estado) {
          if (estado == AnimationStatus.completed) widget.alTerminar();
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciada) return;
    _iniciada = true;
    // Audio, vibración y reloj visual comienzan en el mismo fotograma.
    widget.alAparecer();
    _controlador.forward();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducido = MediaQuery.disableAnimationsOf(context);
    final lado = math.min(
      widget.finalDeNivel ? 300.0 : 232.0,
      MediaQuery.sizeOf(context).shortestSide * .72,
    );
    return IgnorePointer(
      child: Semantics(
        liveRegion: true,
        label: widget.etiqueta,
        child: Center(
          child: AnimatedBuilder(
            animation: _controlador,
            builder: (context, _) {
              final ms =
                  _controlador.value * _controlador.duration!.inMilliseconds;
              final entrada = (ms / 420).clamp(0.0, 1.0);
              final inicioSalida = widget.finalDeNivel ? 1700 : 780;
              final salida =
                  ((ms - inicioSalida) /
                          (_controlador.duration!.inMilliseconds -
                              inicioSalida))
                      .clamp(0.0, 1.0);
              final retirada = Curves.easeInOutCubic.transform(salida);
              final respiracion = widget.finalDeNivel
                  ? .012 * math.sin(math.pi * ((ms - 420) / 1280).clamp(0, 1))
                  : 0.0;
              final escala = reducido
                  ? 1.0
                  : _entradaSuave.transform(entrada) +
                        respiracion -
                        .045 * retirada;
              return Opacity(
                opacity:
                    Curves.easeOutCubic.transform((ms / 140).clamp(0.0, 1.0)) *
                    (1 - retirada),
                child: Transform.scale(
                  scale: escala,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      key: const Key('check-acierto'),
                      size: Size.square(lado),
                      painter: _PintorAcierto(
                        tiempo: ms,
                        reducido: reducido,
                        finalDeNivel: widget.finalDeNivel,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PintorAcierto extends CustomPainter {
  const _PintorAcierto({
    required this.tiempo,
    required this.reducido,
    required this.finalDeNivel,
  });

  final double tiempo;
  final bool reducido;
  final bool finalDeNivel;

  double _fase(double inicio, double duracion) =>
      ((tiempo - inicio) / duracion).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.shortestSide * .34;
    final disco = Rect.fromCircle(center: centro, radius: radio);
    final onda = reducido ? 1.0 : _fase(40, 850);
    final pintura = Paint();

    // Resplandor localizado: la medalla se separa del ejercicio sin oscurecerlo.
    final halo = Rect.fromCircle(center: centro, radius: radio * 1.48);
    canvas.drawCircle(
      centro,
      radio * 1.48,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x552ECC71), Color(0x182ECC71), Color(0x002ECC71)],
          stops: [0, .65, 1],
        ).createShader(halo),
    );
    if (!reducido) {
      canvas.drawCircle(
        centro,
        radio * (1.02 + .37 * Curves.easeOutCubic.transform(onda)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = const Color(0xFF46C782)
              .withValues(alpha: .38 * math.pow(1 - onda, 2)),
      );
    }

    // Sombra corta y borde inferior: volumen suave, sin una sombra pesada.
    canvas.drawShadow(
      Path()..addOval(disco.shift(Offset(0, radio * .025))),
      const Color(0x49105C36),
      9,
      false,
    );
    canvas.drawCircle(
      centro + Offset(0, radio * .035),
      radio,
      Paint()..color = const Color(0xFF65C88F),
    );
    canvas.drawCircle(
      centro,
      radio,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECFFF2), Color(0xFFC6F4D5), Color(0xFF8EDFAC)],
          stops: [0, .55, 1],
        ).createShader(disco),
    );
    canvas.drawCircle(
      centro,
      radio - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xEEFFFFFF), Color(0x8872D59A)],
        ).createShader(disco),
    );
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio * .91),
      math.pi * 1.08,
      math.pi * .62,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radio * .025
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x8AFFFFFF),
    );

    // Un brillo ancho y tenue cruza la superficie una sola vez.
    final brillo = reducido ? 0.0 : _fase(280, 700);
    if (brillo > 0 && brillo < 1) {
      canvas.save();
      canvas.clipPath(Path()..addOval(disco));
      canvas.translate(centro.dx + radio * (brillo * 4 - 2), centro.dy);
      canvas.rotate(-.42);
      final franja = Rect.fromLTWH(
        -radio * .38,
        -radio * 2,
        radio * .76,
        radio * 4,
      );
      canvas.drawRect(
        franja,
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0x00FFFFFF),
              Colors.white.withValues(alpha: .32 * math.sin(math.pi * brillo)),
              const Color(0x00FFFFFF),
            ],
          ).createShader(franja),
      );
      canvas.restore();
    }

    final check = reducido
        ? 1.0
        : Curves.easeInOutCubic.transform(_fase(65, 300));
    final trazo = Path()
      ..moveTo(centro.dx - radio * .43, centro.dy + radio * .01)
      ..lineTo(centro.dx - radio * .12, centro.dy + radio * .31)
      ..lineTo(centro.dx + radio * .46, centro.dy - radio * .32);
    final metrica = trazo.computeMetrics().first;
    final visible = metrica.extractPath(0, metrica.length * check);
    pintura
      ..style = PaintingStyle.stroke
      ..strokeWidth = radio * .145
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      visible.shift(Offset(0, radio * .025)),
      pintura..color = const Color(0x18105C36),
    );
    canvas.drawPath(
      visible,
      pintura
        ..color = Colors.white
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF20A564), Color(0xFF087443)],
        ).createShader(disco),
    );

    if (!finalDeNivel || reducido) return;
    // Estrellas con salida escalonada y pequeñas motas, sin azar entre fotogramas.
    for (var i = 0; i < 10; i++) {
      final progreso = _fase(120 + (i % 3) * 45, 950);
      if (progreso <= 0 || progreso >= 1) continue;
      final expansion = Curves.easeOutCubic.transform(progreso);
      final angulo = i * math.pi / 5 - math.pi / 2;
      final distancia = radio * (1.06 + .34 * expansion);
      final punto =
          centro + Offset(math.cos(angulo), math.sin(angulo)) * distancia;
      final aparicion = Curves.easeOutCubic.transform(
        (progreso / .24).clamp(0.0, 1.0),
      );
      final opacidad = aparicion * (1 - Curves.easeInCubic.transform(progreso));
      final largo = radio * (i.isEven ? .085 : .055) * aparicion;
      final estrella = Path()
        ..moveTo(punto.dx, punto.dy - largo)
        ..quadraticBezierTo(
          punto.dx + largo * .18,
          punto.dy - largo * .18,
          punto.dx + largo,
          punto.dy,
        )
        ..quadraticBezierTo(
          punto.dx + largo * .18,
          punto.dy + largo * .18,
          punto.dx,
          punto.dy + largo,
        )
        ..quadraticBezierTo(
          punto.dx - largo * .18,
          punto.dy + largo * .18,
          punto.dx - largo,
          punto.dy,
        )
        ..quadraticBezierTo(
          punto.dx - largo * .18,
          punto.dy - largo * .18,
          punto.dx,
          punto.dy - largo,
        )
        ..close();
      final color = i.isEven
          ? const Color(0xFF32B977)
          : const Color(0xFFE2B647);
      canvas.drawPath(
        estrella,
        Paint()..color = color.withValues(alpha: opacidad),
      );
      final mota =
          centro +
          Offset(math.cos(angulo + .19), math.sin(angulo + .19)) *
              (distancia * .94);
      canvas.drawCircle(
        mota,
        radio * .016 * aparicion,
        Paint()..color = color.withValues(alpha: opacidad * .6),
      );
    }
  }

  @override
  bool shouldRepaint(_PintorAcierto oldDelegate) =>
      tiempo != oldDelegate.tiempo ||
      reducido != oldDelegate.reducido ||
      finalDeNivel != oldDelegate.finalDeNivel;
}
