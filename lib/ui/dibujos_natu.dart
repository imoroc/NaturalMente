import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/ui/texto.dart';

/// Icono vectorial de Semilla de Sabiduría (sustituye cualquier emoji de bellota/semilla).
class IconoSemilla extends StatelessWidget {
  const IconoSemilla({this.tamano = 20, super.key});

  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(painter: _PintorIconoSemilla()),
    );
  }
}

class _PintorIconoSemilla extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    // Cuerpo de la semilla/bellota dorada
    final cuerpoPath = Path()
      ..moveTo(cx - w * 0.30, h * 0.42)
      ..cubicTo(cx - w * 0.34, h * 0.74, cx - w * 0.14, h * 0.92, cx, h * 0.96)
      ..cubicTo(
        cx + w * 0.14,
        h * 0.92,
        cx + w * 0.34,
        h * 0.74,
        cx + w * 0.30,
        h * 0.42,
      )
      ..close();

    canvas.drawPath(
      cuerpoPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [Color(0xFFF59E0B), Color(0xFFB45309)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
    canvas.drawPath(
      cuerpoPath,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075,
    );

    // Brillo lateral de la semilla
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - w * 0.11, h * 0.64),
        width: w * 0.11,
        height: h * 0.22,
      ),
      Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.75),
    );

    // Cúpula superior (sombrero de bellota)
    final cupulaRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(cx, h * 0.36),
        width: w * 0.74,
        height: h * 0.26,
      ),
      topLeft: Radius.circular(w * 0.24),
      topRight: Radius.circular(w * 0.24),
      bottomLeft: Radius.circular(w * 0.08),
      bottomRight: Radius.circular(w * 0.08),
    );
    canvas.drawRRect(cupulaRect, Paint()..color = const Color(0xFF78350F));
    canvas.drawRRect(
      cupulaRect,
      Paint()
        ..color = const Color(0xFF451A03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.065,
    );

    // Textura reticulada de la cúpula
    final pRed = Paint()
      ..color = const Color(0xFF451A03).withValues(alpha: 0.45)
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - w * 0.18, h * 0.28),
      Offset(cx - w * 0.12, h * 0.44),
      pRed,
    );
    canvas.drawLine(Offset(cx, h * 0.26), Offset(cx, h * 0.45), pRed);
    canvas.drawLine(
      Offset(cx + w * 0.18, h * 0.28),
      Offset(cx + w * 0.12, h * 0.44),
      pRed,
    );

    // Tallo y hojita verde brotando arriba
    final tallo = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, h * 0.23), Offset(cx, h * 0.08), tallo);

    final hoja = Path()
      ..moveTo(cx, h * 0.14)
      ..quadraticBezierTo(cx + w * 0.26, h * 0.02, cx + w * 0.32, h * 0.16)
      ..quadraticBezierTo(cx + w * 0.16, h * 0.24, cx, h * 0.14)
      ..close();
    canvas.drawPath(hoja, Paint()..color = const Color(0xFF22C55E));
    canvas.drawPath(
      hoja,
      Paint()
        ..color = const Color(0xFF15803D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icono vectorial de Llama de Racha al estilo Duolingo.
class IconoLlamaRacha extends StatelessWidget {
  const IconoLlamaRacha({
    this.tamano = 22,
    this.activa = true,
    this.intensa = false,
    super.key,
  });

  final double tamano;
  final bool activa;
  final bool intensa;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(
        painter: _PintorLlamaRacha(activa: activa, intensa: intensa),
      ),
    );
  }
}

class _PintorLlamaRacha extends CustomPainter {
  const _PintorLlamaRacha({required this.activa, required this.intensa});

  final bool activa;
  final bool intensa;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final colorExterior = !activa
        ? const Color(0xFF94A3B8)
        : (intensa ? const Color(0xFFEF4444) : const Color(0xFFF97316));
    final colorMedio = !activa
        ? const Color(0xFFCBD5E1)
        : (intensa ? const Color(0xFFF97316) : const Color(0xFFFBBF24));
    final colorNucleo = !activa
        ? const Color(0xFFF1F5F9)
        : const Color(0xFFFEF08A);

    // Llama exterior
    final ext = Path()
      ..moveTo(cx, h * 0.05)
      ..cubicTo(
        cx + w * 0.36,
        h * 0.28,
        cx + w * 0.44,
        h * 0.58,
        cx + w * 0.28,
        h * 0.84,
      )
      ..cubicTo(
        cx + w * 0.16,
        h * 0.96,
        cx - w * 0.16,
        h * 0.96,
        cx - w * 0.28,
        h * 0.84,
      )
      ..cubicTo(
        cx - w * 0.44,
        h * 0.58,
        cx - w * 0.32,
        h * 0.34,
        cx - w * 0.12,
        h * 0.22,
      )
      ..cubicTo(cx - w * 0.08, h * 0.32, cx - w * 0.02, h * 0.30, cx, h * 0.05)
      ..close();

    canvas.drawPath(ext, Paint()..color = colorExterior);
    canvas.drawPath(
      ext,
      Paint()
        ..color = !activa
            ? const Color(0xFF64748B)
            : (intensa ? const Color(0xFF991B1B) : const Color(0xFFC2410C))
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06,
    );

    // Llama intermedia
    final med = Path()
      ..moveTo(cx + w * 0.02, h * 0.28)
      ..cubicTo(
        cx + w * 0.24,
        h * 0.46,
        cx + w * 0.26,
        h * 0.70,
        cx + w * 0.16,
        h * 0.86,
      )
      ..cubicTo(
        cx + w * 0.06,
        h * 0.94,
        cx - w * 0.08,
        h * 0.94,
        cx - w * 0.16,
        h * 0.86,
      )
      ..cubicTo(
        cx - w * 0.26,
        h * 0.70,
        cx - w * 0.18,
        h * 0.46,
        cx + w * 0.02,
        h * 0.28,
      )
      ..close();
    canvas.drawPath(med, Paint()..color = colorMedio);

    // Núcleo incandescente
    final nuc = Path()
      ..moveTo(cx + w * 0.02, h * 0.52)
      ..cubicTo(cx + w * 0.14, h * 0.64, cx + w * 0.14, h * 0.80, cx, h * 0.90)
      ..cubicTo(
        cx - w * 0.14,
        h * 0.80,
        cx - w * 0.12,
        h * 0.64,
        cx + w * 0.02,
        h * 0.52,
      )
      ..close();
    canvas.drawPath(nuc, Paint()..color = colorNucleo);

    if (activa && intensa) {
      final chispa = Paint()..color = const Color(0xFFFDE047);
      canvas.drawCircle(Offset(w * 0.16, h * 0.22), w * 0.06, chispa);
      canvas.drawCircle(Offset(w * 0.84, h * 0.26), w * 0.055, chispa);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorLlamaRacha oldDelegate) =>
      oldDelegate.activa != activa || oldDelegate.intensa != intensa;
}

/// Pintor multi-ranura de alta calidad para los accesorios de Natu sobre DibujoMascota.
/// Soporta un único id ('botanico') o varios separados por comas ('botanico,doctor,guardian').
class PintorAccesorioNatu extends CustomPainter {
  const PintorAccesorioNatu({
    required this.traje,
    required this.enRacha,
    this.gesto = 'hola',
  });

  final String traje;
  final bool enRacha;
  final String gesto;

  Set<String> get _activos => traje
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && s != 'ninguno')
      .toSet();

  void _conTransformacionRanura(
    Canvas canvas,
    double w,
    double h,
    String ranura,
    VoidCallback pintar,
  ) {
    if (gesto == 'icono') {
      pintar();
      return;
    }
    final (
      Offset destino,
      Offset pivoteOriginal,
      double escala,
      double rotacion,
    ) = switch ((ranura, gesto)) {
      // Ranura CABEZA (sombreros, cascos, coronas)
      ('cabeza', 'feliz' || 'racha') => (
        Offset(w * 0.54, h * 0.145),
        Offset(w * 0.50, h * 0.22),
        0.55,
        -0.04,
      ),
      ('cabeza', 'pensando') => (
        Offset(w * 0.61, h * 0.225),
        Offset(w * 0.50, h * 0.22),
        0.54,
        0.08,
      ),
      ('cabeza', 'estudio') => (
        Offset(w * 0.52, h * 0.145),
        Offset(w * 0.50, h * 0.22),
        0.55,
        0.0,
      ),
      ('cabeza', 'pista') => (
        Offset(w * 0.55, h * 0.155),
        Offset(w * 0.50, h * 0.22),
        0.55,
        -0.03,
      ),
      ('cabeza', _) => (
        Offset(w * 0.55, h * 0.16),
        Offset(w * 0.50, h * 0.22),
        0.56,
        -0.02,
      ),

      // Ranura OJOS (gafas, monóculo, visores)
      ('ojos', 'feliz' || 'racha') => (
        Offset(w * 0.55, h * 0.255),
        Offset(w * 0.50, h * 0.47),
        0.52,
        -0.03,
      ),
      ('ojos', 'pensando') => (
        Offset(w * 0.64, h * 0.34),
        Offset(w * 0.50, h * 0.47),
        0.52,
        0.07,
      ),
      ('ojos', 'estudio') => (
        Offset(w * 0.53, h * 0.265),
        Offset(w * 0.50, h * 0.47),
        0.52,
        0.0,
      ),
      ('ojos', 'pista') => (
        Offset(w * 0.57, h * 0.265),
        Offset(w * 0.50, h * 0.47),
        0.52,
        -0.02,
      ),
      ('ojos', _) => (
        Offset(w * 0.57, h * 0.275),
        Offset(w * 0.50, h * 0.47),
        0.52,
        0.0,
      ),

      // Ranura CUELLO (insignias, brújula, emblemas sobre el pañuelo naranja)
      ('cuello', 'feliz' || 'racha') => (
        Offset(w * 0.54, h * 0.49),
        Offset(w * 0.50, h * 0.79),
        0.54,
        0.0,
      ),
      ('cuello', 'pensando') => (
        Offset(w * 0.55, h * 0.55),
        Offset(w * 0.50, h * 0.79),
        0.52,
        0.06,
      ),
      ('cuello', 'estudio') => (
        Offset(w * 0.52, h * 0.48),
        Offset(w * 0.50, h * 0.79),
        0.50,
        0.0,
      ),
      ('cuello', 'pista') => (
        Offset(w * 0.55, h * 0.51),
        Offset(w * 0.50, h * 0.79),
        0.54,
        0.0,
      ),
      (_, _) => (
        Offset(w * 0.55, h * 0.52),
        Offset(w * 0.50, h * 0.79),
        0.55,
        0.0,
      ),
    };

    canvas.save();
    canvas.translate(destino.dx, destino.dy);
    if (rotacion != 0) {
      canvas.rotate(rotacion);
    }
    canvas.scale(escala, escala);
    canvas.translate(-pivoteOriginal.dx, -pivoteOriginal.dy);
    pintar();
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final activos = _activos;

    if (enRacha || activos.contains('leyenda_natu')) {
      final pHalo = Paint()
        ..color = const Color(0xFFFFB703).withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.045;
      canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.46, pHalo);
      _pintarEstrellaDestello(canvas, Offset(w * 0.14, h * 0.18), w * 0.075);
      _pintarEstrellaDestello(canvas, Offset(w * 0.86, h * 0.20), w * 0.065);
    }

    final tieneSombreroCabeza = activos.any(
      (id) =>
          id == 'explorador' ||
          id == 'botanico' ||
          id == 'nocturno' ||
          id == 'apicultor' ||
          id == 'polar' ||
          id == 'maestro_reserva' ||
          id == 'maestro_invernadero',
    );

    // 1. Insignia / Cuello (sobre el nudo del pañuelo naranja de Natu)
    _conTransformacionRanura(canvas, w, h, 'cuello', () {
      if (activos.contains('leyenda_natu')) {
        _pintarMantoLeyenda(canvas, w, h, conCorona: false);
      } else if (activos.contains('racha_fuego')) {
        _pintarEmblemaRachaFuego(canvas, w, h);
      } else if (activos.contains('herbarioro')) {
        _pintarBrocheRobleDorado(canvas, w, h);
      } else if (activos.contains('brujula')) {
        _pintarBrujulaExpedicion(canvas, w, h);
      } else if (activos.contains('guardian')) {
        _pintarInsigniaGuardian(canvas, w, h, conCorona: false);
      }
    });

    // 2. Ojos / Visor (calibrados con los ojos ovalados de la tortuga Natu)
    _conTransformacionRanura(canvas, w, h, 'ojos', () {
      if (activos.contains('maestro_cuerpo')) {
        _pintarVisorBiomedico(canvas, w, h);
      } else if (activos.contains('lupas')) {
        _pintarMonoculoBotanico(canvas, w, h);
      } else if (activos.contains('aviador')) {
        _pintarGafasAviador(canvas, w, h);
      } else if (activos.contains('doctor')) {
        _pintarGafasDoctor(canvas, w, h);
      } else if (activos.contains('marino')) {
        _pintarVisorMarino(canvas, w, h);
      }
    });

    // 3. Cabeza / Sombrero (sobre la coronilla de la tortuga Natu)
    _conTransformacionRanura(canvas, w, h, 'cabeza', () {
      if (activos.contains('maestro_reserva')) {
        _pintarSombreroMaestroReserva(canvas, w, h);
      } else if (activos.contains('maestro_invernadero')) {
        _pintarCoronaMaestroInvernadero(canvas, w, h);
      } else if (activos.contains('polar')) {
        _pintarGorroPolar(canvas, w, h);
      } else if (activos.contains('apicultor')) {
        _pintarSombreroApicultor(canvas, w, h);
      } else if (activos.contains('explorador')) {
        _pintarSombreroExplorador(canvas, w, h);
      } else if (activos.contains('botanico')) {
        _pintarCoronaBotanica(canvas, w, h);
      } else if (activos.contains('nocturno')) {
        _pintarLinternaNocturna(canvas, w, h);
      } else if (!tieneSombreroCabeza && activos.contains('leyenda_natu')) {
        _pintarCoronaMaestroInvernadero(canvas, w, h);
      } else if (!tieneSombreroCabeza && activos.contains('guardian')) {
        _pintarCoronaBotanica(canvas, w, h);
      }
    });
  }

  void _pintarEstrellaDestello(Canvas canvas, Offset c, double r) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD166));
  }

  void _pintarSombreroExplorador(Canvas canvas, double w, double h) {
    const cTrazo = Color(0xFF3B2314);
    final pTrazo = Paint()
      ..color = cTrazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.036
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Ala curva del salacot de explorador (estilo lámina de diseño de Natu)
    final alaFondo = Path()
      ..moveTo(w * 0.08, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.15, w * 0.92, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.29, w * 0.08, h * 0.22)
      ..close();
    canvas.drawPath(alaFondo, Paint()..color = const Color(0xFFD6AD60));
    canvas.drawPath(alaFondo, pTrazo);

    // Cúpula redondeada beige arena con botón superior
    final copaPath = Path()
      ..moveTo(w * 0.20, h * 0.21)
      ..cubicTo(w * 0.20, h * 0.00, w * 0.80, h * 0.00, w * 0.80, h * 0.21)
      ..close();
    canvas.drawPath(copaPath, Paint()..color = const Color(0xFFE9C987));

    // Brillo lateral suave en la cúpula
    final brilloCopa = Path()
      ..moveTo(w * 0.28, h * 0.16)
      ..quadraticBezierTo(w * 0.38, h * 0.05, w * 0.52, h * 0.05)
      ..quadraticBezierTo(w * 0.38, h * 0.09, w * 0.28, h * 0.16)
      ..close();
    canvas.drawPath(
      brilloCopa,
      Paint()..color = const Color(0xFFF7E4B5).withValues(alpha: 0.85),
    );
    canvas.drawPath(copaPath, pTrazo);

    // Botón superior del salacot
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.045),
        width: w * 0.13,
        height: h * 0.045,
      ),
      Paint()..color = const Color(0xFFD6AD60),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.045),
        width: w * 0.13,
        height: h * 0.045,
      ),
      pTrazo,
    );

    // Cinta marrón cuero de explorador
    final cintaRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.19),
        width: w * 0.60,
        height: h * 0.058,
      ),
      Radius.circular(w * 0.025),
    );
    canvas.drawRRect(cintaRect, Paint()..color = const Color(0xFF8C5828));
    canvas.drawRRect(cintaRect, pTrazo);
  }

  void _pintarSombreroMaestroReserva(Canvas canvas, double w, double h) {
    // Sombrero de Guardabosques de Élite con pluma real y huella dorada
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.23),
        width: w * 0.84,
        height: h * 0.13,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.20),
    );

    // Copa con doble hendidura de guardabosques
    final copa = Path()
      ..moveTo(w * 0.22, h * 0.21)
      ..quadraticBezierTo(w * 0.26, h * 0.03, w * 0.40, h * 0.06)
      ..quadraticBezierTo(w * 0.50, h * 0.10, w * 0.60, h * 0.06)
      ..quadraticBezierTo(w * 0.74, h * 0.03, w * 0.78, h * 0.21)
      ..close();
    canvas.drawPath(
      copa,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF854D0E), Color(0xFF422006)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.24)),
    );
    canvas.drawPath(
      copa,
      Paint()
        ..color = const Color(0xFF271202)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );

    // Pluma de águila dorada y turquesa en el lateral
    final pluma = Path()
      ..moveTo(w * 0.68, h * 0.17)
      ..quadraticBezierTo(w * 0.88, h * 0.01, w * 0.84, h * 0.16)
      ..quadraticBezierTo(w * 0.76, h * 0.20, w * 0.68, h * 0.17)
      ..close();
    canvas.drawPath(pluma, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawPath(
      pluma,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );

    // Ala ancha rígida de guardabosques
    final ala = Path()
      ..moveTo(w * 0.08, h * 0.21)
      ..quadraticBezierTo(w * 0.50, h * 0.16, w * 0.92, h * 0.21)
      ..quadraticBezierTo(w * 0.50, h * 0.27, w * 0.08, h * 0.21)
      ..close();
    canvas.drawPath(ala, Paint()..color = const Color(0xFF713F12));
    canvas.drawPath(
      ala,
      Paint()
        ..color = const Color(0xFF271202)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );

    // Escudo dorado de huella de fauna en el centro
    final centro = Offset(w * 0.50, h * 0.14);
    canvas.drawCircle(
      centro,
      w * 0.055,
      Paint()..color = const Color(0xFFFACC15),
    );
    canvas.drawCircle(
      centro,
      w * 0.055,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.15),
      w * 0.022,
      Paint()..color = const Color(0xFF15803D),
    );
  }

  void _pintarCoronaBotanica(Canvas canvas, double w, double h) {
    final rama = Path()
      ..moveTo(w * 0.16, h * 0.25)
      ..quadraticBezierTo(w * 0.50, h * 0.14, w * 0.84, h * 0.25);
    canvas.drawPath(
      rama,
      Paint()
        ..color = const Color(0xFF15803D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round,
    );

    for (final (lx, ly, ang) in [
      (0.22, 0.22, -0.5),
      (0.38, 0.18, -0.2),
      (0.62, 0.18, 0.2),
      (0.78, 0.22, 0.5),
    ]) {
      canvas.save();
      canvas.translate(w * lx, h * ly);
      canvas.rotate(ang);
      final rHoja = Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.13,
        height: h * 0.07,
      );
      canvas.drawOval(rHoja, Paint()..color = const Color(0xFF22C55E));
      canvas.drawOval(
        rHoja,
        Paint()
          ..color = const Color(0xFF14532D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.02,
      );
      canvas.restore();
    }

    _pintarFlorCorona(
      canvas,
      Offset(w * 0.30, h * 0.19),
      w * 0.075,
      const Color(0xFFFB7185),
      const Color(0xFFFEF08A),
    );
    _pintarFlorCorona(
      canvas,
      Offset(w * 0.50, h * 0.16),
      w * 0.09,
      const Color(0xFFFBBF24),
      const Color(0xFF78350F),
    );
    _pintarFlorCorona(
      canvas,
      Offset(w * 0.70, h * 0.19),
      w * 0.075,
      const Color(0xFFC084FC),
      const Color(0xFFFEF08A),
    );
  }

  void _pintarCoronaMaestroInvernadero(Canvas canvas, double w, double h) {
    // Tiara de Cristal Botánico con flor de loto solar y hojas doradas
    final arco = Path()
      ..moveTo(w * 0.14, h * 0.24)
      ..quadraticBezierTo(w * 0.50, h * 0.10, w * 0.86, h * 0.24);
    canvas.drawPath(
      arco,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round,
    );

    for (final (lx, ly, ang) in [
      (0.22, 0.20, -0.45),
      (0.35, 0.16, -0.20),
      (0.65, 0.16, 0.20),
      (0.78, 0.20, 0.45),
    ]) {
      canvas.save();
      canvas.translate(w * lx, h * ly);
      canvas.rotate(ang);
      final rHoja = Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.14,
        height: h * 0.075,
      );
      canvas.drawOval(rHoja, Paint()..color = const Color(0xFF10B981));
      canvas.drawOval(
        rHoja,
        Paint()
          ..color = const Color(0xFFFDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.022,
      );
      canvas.restore();
    }

    // Flor de loto imperial en el centro
    final cx = w * 0.50;
    final cy = h * 0.14;
    for (final dx in [-0.08, 0.0, 0.08]) {
      final petalo = Path()
        ..moveTo(cx, cy + h * 0.05)
        ..quadraticBezierTo(
          cx + w * (dx * 1.6),
          cy - h * 0.06,
          cx + w * dx,
          cy - h * 0.10,
        )
        ..quadraticBezierTo(cx, cy - h * 0.04, cx, cy + h * 0.05)
        ..close();
      canvas.drawPath(
        petalo,
        Paint()
          ..color = dx == 0.0
              ? const Color(0xFFF43F5E)
              : const Color(0xFFFB7185),
      );
      canvas.drawPath(
        petalo,
        Paint()
          ..color = const Color(0xFFFDE047)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.018,
      );
    }
    canvas.drawCircle(
      Offset(cx, cy + h * 0.02),
      w * 0.04,
      Paint()..color = const Color(0xFFFACC15),
    );
  }

  void _pintarFlorCorona(
    Canvas canvas,
    Offset centro,
    double radio,
    Color colorPetalo,
    Color colorCentro,
  ) {
    final pPetalo = Paint()..color = colorPetalo;
    final pBorde = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radio * 0.18;
    for (var i = 0; i < 5; i++) {
      final ang = i * (2 * math.pi / 5) - math.pi / 2;
      final p = Offset(
        centro.dx + math.cos(ang) * radio * 0.55,
        centro.dy + math.sin(ang) * radio * 0.55,
      );
      canvas.drawCircle(p, radio * 0.48, pPetalo);
      canvas.drawCircle(p, radio * 0.48, pBorde);
    }
    canvas.drawCircle(centro, radio * 0.42, Paint()..color = colorCentro);
  }

  void _pintarGafasDoctor(Canvas canvas, double w, double h) {
    final cy = h * 0.47;
    final rLente = w * 0.145;
    final izq = Offset(w * 0.34, cy);
    final der = Offset(w * 0.66, cy);

    final pCristal = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    final pMonturaSombra = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    final pMontura = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.12, cy - h * 0.03),
      Offset(izq.dx - rLente, cy),
      pMonturaSombra,
    );
    canvas.drawLine(
      Offset(der.dx + rLente, cy),
      Offset(w * 0.88, cy - h * 0.03),
      pMonturaSombra,
    );

    canvas.drawCircle(izq, rLente, pCristal);
    canvas.drawCircle(der, rLente, pCristal);
    canvas.drawCircle(izq, rLente, pMonturaSombra);
    canvas.drawCircle(der, rLente, pMonturaSombra);
    canvas.drawCircle(izq, rLente, pMontura);
    canvas.drawCircle(der, rLente, pMontura);

    final puente = Path()
      ..moveTo(izq.dx + rLente * 0.85, cy)
      ..quadraticBezierTo(w * 0.50, cy - h * 0.05, der.dx - rLente * 0.85, cy);
    canvas.drawPath(puente, pMonturaSombra);
    canvas.drawPath(puente, pMontura);

    final pBrillo = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(izq.dx - rLente * 0.45, cy - rLente * 0.45),
      Offset(izq.dx - rLente * 0.10, cy - rLente * 0.10),
      pBrillo,
    );
    canvas.drawLine(
      Offset(der.dx - rLente * 0.45, cy - rLente * 0.45),
      Offset(der.dx - rLente * 0.10, cy - rLente * 0.10),
      pBrillo,
    );

    final esteto = Path()
      ..moveTo(w * 0.28, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.88, w * 0.72, h * 0.72);
    canvas.drawPath(
      esteto,
      Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.042
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.60, h * 0.83),
      w * 0.055,
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawCircle(
      Offset(w * 0.60, h * 0.83),
      w * 0.055,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );
  }

  void _pintarVisorBiomedico(Canvas canvas, double w, double h) {
    // Visor Biomédico Holográfico con trazado de pulso vital ECG
    final cy = h * 0.46;
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, cy),
        width: w * 0.72,
        height: h * 0.22,
      ),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF06B6D4).withValues(alpha: 0.45),
            const Color(0xFF10B981).withValues(alpha: 0.40),
          ],
        ).createShader(visor.outerRect),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.048,
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );

    // Onda ECG en el visor
    final ecg = Path()
      ..moveTo(w * 0.22, cy)
      ..lineTo(w * 0.36, cy)
      ..lineTo(w * 0.41, cy - h * 0.06)
      ..lineTo(w * 0.46, cy + h * 0.06)
      ..lineTo(w * 0.51, cy - h * 0.03)
      ..lineTo(w * 0.56, cy)
      ..lineTo(w * 0.78, cy);
    canvas.drawPath(
      ecg,
      Paint()
        ..color = const Color(0xFFA7F3D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _pintarVisorMarino(Canvas canvas, double w, double h) {
    final cy = h * 0.46;
    final snorkelPath = Path()
      ..moveTo(w * 0.76, cy + h * 0.08)
      ..quadraticBezierTo(w * 0.92, cy + h * 0.08, w * 0.90, h * 0.18);
    canvas.drawPath(
      snorkelPath,
      Paint()
        ..color = const Color(0xFF9A3412)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      snorkelPath,
      Paint()
        ..color = const Color(0xFFFB923C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.048
        ..strokeCap = StrokeCap.round,
    );

    final visorRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, cy),
        width: w * 0.68,
        height: h * 0.25,
      ),
      Radius.circular(w * 0.09),
    );
    canvas.drawRRect(
      visorRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.45),
            const Color(0xFF0284C7).withValues(alpha: 0.35),
          ],
        ).createShader(visorRRect.outerRect),
    );
    canvas.drawRRect(
      visorRRect,
      Paint()
        ..color = const Color(0xFF0369A1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055,
    );
    canvas.drawRRect(
      visorRRect,
      Paint()
        ..color = const Color(0xFFFACC15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );

    canvas.drawLine(
      Offset(w * 0.26, cy - h * 0.05),
      Offset(w * 0.40, cy - h * 0.05),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = w * 0.028
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(w * 0.90, h * 0.09),
      w * 0.032,
      Paint()..color = const Color(0xFFBAE6FD),
    );
  }

  void _pintarLinternaNocturna(Canvas canvas, double w, double h) {
    final cy = h * 0.24;
    final correa = Path()
      ..moveTo(w * 0.15, cy + h * 0.02)
      ..quadraticBezierTo(w * 0.50, cy - h * 0.03, w * 0.85, cy + h * 0.02);
    canvas.drawPath(
      correa,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.075
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      correa,
      Paint()
        ..color = const Color(0xFF334155)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.042
        ..strokeCap = StrokeCap.round,
    );

    final centroFoco = Offset(w * 0.50, cy - h * 0.01);
    canvas.drawCircle(
      centroFoco,
      w * 0.17,
      Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.35),
    );

    final carcasa = RRect.fromRectAndRadius(
      Rect.fromCenter(center: centroFoco, width: w * 0.24, height: h * 0.15),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(carcasa, Paint()..color = const Color(0xFF475569));
    canvas.drawRRect(
      carcasa,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );

    canvas.drawCircle(
      centroFoco,
      w * 0.075,
      Paint()..color = const Color(0xFFFEF08A),
    );
    canvas.drawCircle(
      centroFoco,
      w * 0.075,
      Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );
  }

  void _pintarInsigniaGuardian(
    Canvas canvas,
    double w,
    double h, {
    required bool conCorona,
  }) {
    final cinta = Path()
      ..moveTo(w * 0.30, h * 0.72)
      ..lineTo(w * 0.50, h * 0.84)
      ..lineTo(w * 0.70, h * 0.72);
    canvas.drawPath(
      cinta,
      Paint()
        ..color = const Color(0xFF047857)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.055
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final centroMedalla = Offset(w * 0.50, h * 0.84);
    canvas.drawCircle(
      centroMedalla,
      w * 0.095,
      Paint()..color = const Color(0xFFFBBF24),
    );
    canvas.drawCircle(
      centroMedalla,
      w * 0.095,
      Paint()
        ..color = const Color(0xFF92400E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024,
    );
    canvas.drawCircle(
      centroMedalla,
      w * 0.052,
      Paint()..color = const Color(0xFF10B981),
    );

    if (conCorona) {
      final path = Path()
        ..moveTo(w * 0.24, h * 0.22)
        ..lineTo(w * 0.27, h * 0.06)
        ..lineTo(w * 0.39, h * 0.15)
        ..lineTo(w * 0.50, h * 0.02)
        ..lineTo(w * 0.61, h * 0.15)
        ..lineTo(w * 0.73, h * 0.06)
        ..lineTo(w * 0.76, h * 0.22)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFFDE047), Color(0xFFF59E0B)],
          ).createShader(Rect.fromLTWH(0, 0, w, h * 0.25)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF92400E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03,
      );
      canvas.drawCircle(
        Offset(w * 0.50, h * 0.14),
        w * 0.042,
        Paint()..color = const Color(0xFF10B981),
      );
    }
  }

  void _pintarMantoLeyenda(
    Canvas canvas,
    double w,
    double h, {
    required bool conCorona,
  }) {
    // Manto real esmeralda y oro en los hombros
    final manto = Path()
      ..moveTo(w * 0.16, h * 0.98)
      ..quadraticBezierTo(w * 0.18, h * 0.68, w * 0.34, h * 0.70)
      ..lineTo(w * 0.66, h * 0.70)
      ..quadraticBezierTo(w * 0.82, h * 0.68, w * 0.84, h * 0.98)
      ..close();
    canvas.drawPath(
      manto,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF047857), Color(0xFF064E3B)],
        ).createShader(Rect.fromLTWH(0, h * 0.68, w, h * 0.30)),
    );
    canvas.drawPath(
      manto,
      Paint()
        ..color = const Color(0xFFFBBF24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035,
    );

    // Gran medallón solar de Leyenda Natural
    final centro = Offset(w * 0.50, h * 0.83);
    canvas.drawCircle(
      centro,
      w * 0.11,
      Paint()..color = const Color(0xFFFDE047),
    );
    canvas.drawCircle(
      centro,
      w * 0.11,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.026,
    );
    _pintarEstrellaDestello(canvas, centro, w * 0.075);

    if (conCorona) {
      _pintarInsigniaGuardian(canvas, w, h, conCorona: true);
    }
  }

  void _pintarSombreroApicultor(Canvas canvas, double w, double h) {
    final copa = Path()
      ..moveTo(w * 0.25, h * 0.21)
      ..quadraticBezierTo(w * 0.50, h * 0.02, w * 0.75, h * 0.21)
      ..close();
    canvas.drawPath(copa, Paint()..color = const Color(0xFFFDE047));
    canvas.drawPath(
      copa,
      Paint()
        ..color = const Color(0xFF854D0E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );
    final ala = Path()
      ..moveTo(w * 0.08, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.16, w * 0.92, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.27, w * 0.08, h * 0.22)
      ..close();
    canvas.drawPath(ala, Paint()..color = const Color(0xFFFACC15));
    canvas.drawPath(
      ala,
      Paint()
        ..color = const Color(0xFF854D0E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.03,
    );
    // Abejita polinizadora posada sobre el sombrero
    final cAbeja = Offset(w * 0.74, h * 0.10);
    canvas.drawOval(
      Rect.fromCenter(center: cAbeja, width: w * 0.12, height: h * 0.08),
      Paint()..color = const Color(0xFFFACC15),
    );
    canvas.drawLine(
      cAbeja + Offset(-w * 0.02, -h * 0.03),
      cAbeja + Offset(-w * 0.02, h * 0.03),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = w * 0.025,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: cAbeja + Offset(0, -h * 0.05),
        width: w * 0.08,
        height: h * 0.05,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  void _pintarGorroPolar(Canvas canvas, double w, double h) {
    final domo = Path()
      ..moveTo(w * 0.18, h * 0.24)
      ..cubicTo(w * 0.18, h * 0.02, w * 0.82, h * 0.02, w * 0.82, h * 0.24)
      ..close();
    canvas.drawPath(domo, Paint()..color = const Color(0xFF0284C7));
    canvas.drawPath(
      domo,
      Paint()
        ..color = const Color(0xFF0C4A6E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.032,
    );
    // Ribete de borreguito blanco polar y orejeras laterales
    final ribete = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.22),
        width: w * 0.70,
        height: h * 0.09,
      ),
      Radius.circular(w * 0.045),
    );
    canvas.drawRRect(ribete, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawRRect(
      ribete,
      Paint()
        ..color = const Color(0xFF0C4A6E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );
    for (final dx in [0.17, 0.83]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * dx, h * 0.29),
          width: w * 0.11,
          height: h * 0.15,
        ),
        Paint()..color = const Color(0xFFE0F2FE),
      );
    }
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.06),
      w * 0.055,
      Paint()..color = const Color(0xFFF8FAFC),
    );
  }

  void _pintarGafasAviador(Canvas canvas, double w, double h) {
    final cy = h * 0.46;
    final pCorrea = Paint()
      ..color = const Color(0xFF78350F)
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.12, cy), Offset(w * 0.88, cy), pCorrea);
    for (final cxLente in [w * 0.34, w * 0.66]) {
      final r = Rect.fromCenter(
        center: Offset(cxLente, cy),
        width: w * 0.28,
        height: h * 0.21,
      );
      canvas.drawOval(
        r,
        Paint()..color = const Color(0xFFF59E0B).withValues(alpha: 0.45),
      );
      canvas.drawOval(
        r,
        Paint()
          ..color = const Color(0xFF78350F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.042,
      );
      canvas.drawOval(
        r,
        Paint()
          ..color = const Color(0xFFFBBF24)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.018,
      );
    }
  }

  void _pintarMonoculoBotanico(Canvas canvas, double w, double h) {
    final c = Offset(w * 0.66, h * 0.47);
    final r = w * 0.155;
    // Cadenita dorada colgante
    final cadena = Path()
      ..moveTo(c.dx + r * 0.85, c.dy + r * 0.3)
      ..quadraticBezierTo(w * 0.84, h * 0.66, w * 0.68, h * 0.78);
    canvas.drawPath(
      cadena,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()..color = const Color(0xFF6EE7B7).withValues(alpha: 0.32),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.048,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFFFDE047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02,
    );
  }

  void _pintarBrujulaExpedicion(Canvas canvas, double w, double h) {
    final c = Offset(w * 0.50, h * 0.83);
    canvas.drawCircle(c, w * 0.105, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(
      c,
      w * 0.105,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.026,
    );
    canvas.drawCircle(c, w * 0.075, Paint()..color = const Color(0xFFFEF3C7));
    final agujaNorte = Path()
      ..moveTo(c.dx, c.dy - w * 0.065)
      ..lineTo(c.dx + w * 0.025, c.dy)
      ..lineTo(c.dx - w * 0.025, c.dy)
      ..close();
    canvas.drawPath(agujaNorte, Paint()..color = const Color(0xFFEF4444));
  }

  void _pintarBrocheRobleDorado(Canvas canvas, double w, double h) {
    final c = Offset(w * 0.50, h * 0.83);
    for (final dir in [-1.0, 1.0]) {
      final hoja = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(
          c.dx + dir * w * 0.16,
          c.dy - h * 0.08,
          c.dx + dir * w * 0.18,
          c.dy + h * 0.02,
        )
        ..quadraticBezierTo(c.dx + dir * w * 0.08, c.dy + h * 0.07, c.dx, c.dy);
      canvas.drawPath(hoja, Paint()..color = const Color(0xFF16A34A));
      canvas.drawPath(
        hoja,
        Paint()
          ..color = const Color(0xFFFACC15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.02,
      );
    }
    canvas.drawCircle(c, w * 0.065, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(
      c,
      w * 0.065,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022,
    );
  }

  void _pintarEmblemaRachaFuego(Canvas canvas, double w, double h) {
    final c = Offset(w * 0.50, h * 0.83);
    canvas.drawCircle(c, w * 0.11, Paint()..color = const Color(0xFFEA580C));
    canvas.drawCircle(
      c,
      w * 0.11,
      Paint()
        ..color = const Color(0xFFFDE047)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.028,
    );
    final llama = Path()
      ..moveTo(c.dx, c.dy - w * 0.075)
      ..quadraticBezierTo(c.dx + w * 0.065, c.dy, c.dx, c.dy + w * 0.07)
      ..quadraticBezierTo(c.dx - w * 0.065, c.dy, c.dx, c.dy - w * 0.075)
      ..close();
    canvas.drawPath(llama, Paint()..color = const Color(0xFFFEF08A));
  }

  @override
  bool shouldRepaint(covariant PintorAccesorioNatu oldDelegate) =>
      oldDelegate.traje != traje ||
      oldDelegate.enRacha != enRacha ||
      oldDelegate.gesto != gesto;
}

/// Vista previa vectorial nítida y centrada de cada accesorio para las tarjetas del Armario.
class IconoAccesorioNatu extends StatelessWidget {
  const IconoAccesorioNatu({required this.id, this.tamano = 64, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(painter: _PintorIconoAccesorio(id: id)),
    );
  }
}

class _PintorIconoAccesorio extends CustomPainter {
  const _PintorIconoAccesorio({required this.id});

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.44,
      Paint()..color = const Color(0xFFFDF6E2),
    );

    canvas.save();
    switch (id) {
      case 'explorador':
      case 'botanico':
      case 'nocturno':
      case 'apicultor':
      case 'polar':
      case 'maestro_reserva':
      case 'maestro_invernadero':
        canvas.translate(0, h * 0.28);
        canvas.scale(1.0, 1.15);
        PintorAccesorioNatu(
          traje: id,
          enRacha: false,
          gesto: 'icono',
        ).paint(canvas, size);
      case 'doctor':
      case 'marino':
      case 'aviador':
      case 'lupas':
      case 'maestro_cuerpo':
        canvas.translate(0, h * 0.02);
        PintorAccesorioNatu(
          traje: id,
          enRacha: false,
          gesto: 'icono',
        ).paint(canvas, size);
      case 'guardian':
      case 'brujula':
      case 'herbarioro':
      case 'racha_fuego':
      case 'leyenda_natu':
        canvas.translate(0, -h * 0.24);
        canvas.scale(1.0, 1.12);
        PintorAccesorioNatu(
          traje: id,
          enRacha: true,
          gesto: 'icono',
        ).paint(canvas, size);
      default:
        final hoja = Path()
          ..moveTo(w * 0.5, h * 0.72)
          ..quadraticBezierTo(w * 0.20, h * 0.42, w * 0.5, h * 0.20)
          ..quadraticBezierTo(w * 0.80, h * 0.42, w * 0.5, h * 0.72)
          ..close();
        canvas.drawPath(hoja, Paint()..color = const Color(0xFF80B938));
        canvas.drawPath(
          hoja,
          Paint()
            ..color = const Color(0xFF3B2314)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.04,
        );
        canvas.drawLine(
          Offset(w * 0.5, h * 0.28),
          Offset(w * 0.5, h * 0.74),
          Paint()
            ..color = const Color(0xFF3B2314)
            ..strokeWidth = w * 0.04
            ..strokeCap = StrokeCap.round,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorIconoAccesorio oldDelegate) =>
      oldDelegate.id != id;
}

/// Logotipo ilustrado de `NaturalMente — Ciencias Naturales` con brotes y hojas
/// siguiendo el diseño de la lámina oficial de Natu.
class LogoNaturalMente extends StatelessWidget {
  const LogoNaturalMente({this.compacto = false, super.key});

  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final tamTitulo = compacto ? 20.0 : 23.0;
    final tamSubtitulo = compacto ? 10.5 : 11.5;
    final anchoHojas = compacto ? 24.0 : 30.0;
    final altoHojas = compacto ? 34.0 : 40.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(anchoHojas, altoHojas),
          painter: const _PintorHojasLogoNaturalMente(izquierda: true),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Texto(
                'NaturalMente',
                style: TextStyle(
                  fontSize: tamTitulo,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF3B2314),
                  letterSpacing: -0.4,
                  height: 1.02,
                  shadows: const [
                    Shadow(
                      color: Color(0xFFFDF6E2),
                      offset: Offset(0, 1.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 1),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compacto ? 10 : 14,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF72B034),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Texto(
                      'Ciencias Naturales',
                      style: TextStyle(
                        fontSize: tamSubtitulo,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF54331D),
                        letterSpacing: 0.3,
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: compacto ? 10 : 14,
                    height: 2,
                    decoration: BoxDecoration(
                      color: const Color(0xFF72B034),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        CustomPaint(
          size: Size(anchoHojas, altoHojas),
          painter: const _PintorHojasLogoNaturalMente(izquierda: false),
        ),
      ],
    );
  }
}

class _PintorHojasLogoNaturalMente extends CustomPainter {
  const _PintorHojasLogoNaturalMente({required this.izquierda});

  final bool izquierda;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pTrazo = Paint()
      ..color = const Color(0xFF3B2314)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    if (!izquierda) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    void pintarHoja(
      Offset base,
      Offset punta,
      Offset ctrlSup,
      Offset ctrlInf,
      Color color,
    ) {
      final path = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(ctrlSup.dx, ctrlSup.dy, punta.dx, punta.dy)
        ..quadraticBezierTo(ctrlInf.dx, ctrlInf.dy, base.dx, base.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, pTrazo);
      canvas.drawLine(
        base,
        Offset(
          base.dx + (punta.dx - base.dx) * 0.68,
          base.dy + (punta.dy - base.dy) * 0.68,
        ),
        Paint()
          ..color = const Color(0xFF3B2314)
          ..strokeWidth = w * 0.06
          ..strokeCap = StrokeCap.round,
      );
    }

    // Hoja superior inclinada hacia arriba
    pintarHoja(
      Offset(w * 0.88, h * 0.36),
      Offset(w * 0.22, h * 0.10),
      Offset(w * 0.64, h * 0.04),
      Offset(w * 0.38, h * 0.38),
      const Color(0xFF9BC53D),
    );
    // Hoja central principal
    pintarHoja(
      Offset(w * 0.90, h * 0.54),
      Offset(w * 0.08, h * 0.44),
      Offset(w * 0.42, h * 0.24),
      Offset(w * 0.42, h * 0.68),
      const Color(0xFF72B034),
    );
    // Hoja inferior redondeada
    pintarHoja(
      Offset(w * 0.88, h * 0.68),
      Offset(w * 0.26, h * 0.84),
      Offset(w * 0.44, h * 0.56),
      Offset(w * 0.66, h * 0.92),
      const Color(0xFF9BC53D),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorHojasLogoNaturalMente oldDelegate) =>
      oldDelegate.izquierda != izquierda;
}

/// Pintor vectorial artesanal de la mascota Natu:
/// Tortuga exploradora de cuerpo entero con caparazón vivo de musgo, brotes verdes,
/// florecitas silvestres y pañuelo naranja de explorador.
///
/// Soporta 5 poses de cuerpo completo según [gesto]:
/// - `'hola'` (por defecto): Pose de saludo de pie con una mano levantada saludando.
/// - `'feliz'` / `'racha'`: Pose de celebración saltando en el aire con destellos.
/// - `'pensando'`: Pose de investigación agachada observando un brote con lupa.
/// - `'estudio'`: Pose de lectura sentada con su libro abierto de Ciencias Naturales.
/// - `'pista'`: Pose de motivación señalando con entusiasmo («¡Tú puedes!»).
class PintorMascotaNatu extends CustomPainter {
  const PintorMascotaNatu({required this.gesto});

  final String gesto;

  static const Color _cTrazo = Color(0xFF3B2314);
  static const Color _cPiel = Color(0xFFA8D152);
  static const Color _cPielLuz = Color(0xFFB8DE64);
  static const Color _cPielSombra = Color(0xFF8EB83B);
  static const Color _cMejilla = Color(0xFF7FA935);
  static const Color _cPlastron = Color(0xFFDCF097);
  static const Color _cPlastronLinea = Color(0xFF98C14B);
  static const Color _cBordeCaparazon = Color(0xFF78923D);
  static const Color _cMusgo = Color(0xFF5B852A);
  static const Color _cMusgoClaro = Color(0xFF74A137);
  static const Color _cMusgoOscuro = Color(0xFF395A14);
  static const Color _cPanuelo = Color(0xFFF38333);
  static const Color _cPanueloSombra = Color(0xFFD96518);
  static const Color _cFlor = Color(0xFFF79646);
  static const Color _cBoca = Color(0xFF542116);
  static const Color _cLengua = Color(0xFFF07167);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pTrazo = Paint()
      ..color = _cTrazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.030
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pTrazoFino = Paint()
      ..color = _cTrazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Fondo cálido pergamino crema (#FDF6E2) con halo luminoso suave
    final coloresFondo = switch (gesto) {
      'racha' || 'feliz' => const [Color(0xFFFFFBEB), Color(0xFFFDF3C7)],
      'pensando' => const [Color(0xFFFEFCE8), Color(0xFFFDF6E2)],
      'estudio' => const [Color(0xFFFEFDF6), Color(0xFFF5EBD0)],
      'pista' => const [Color(0xFFFFF7ED), Color(0xFFFDE8C8)],
      _ => const [Color(0xFFFEFBF0), Color(0xFFFDF6E2)],
    };
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.1),
          radius: 0.92,
          colors: coloresFondo,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    switch (gesto) {
      case 'feliz':
      case 'racha':
        _pintarPoseCelebracion(canvas, w, h, pTrazo, pTrazoFino);
      case 'pensando':
        _pintarPoseInvestigacion(canvas, w, h, pTrazo, pTrazoFino);
      case 'estudio':
        _pintarPoseEstudio(canvas, w, h, pTrazo, pTrazoFino);
      case 'pista':
        _pintarPoseMotivacion(canvas, w, h, pTrazo, pTrazoFino);
      default:
        _pintarPoseSaludo(canvas, w, h, pTrazo, pTrazoFino);
    }
  }

  // ===========================================================================
  // POSE 1: SALUDO ('hola') — De pie en 3/4 saludando con una mano levantada
  // ===========================================================================
  void _pintarPoseSaludo(
    Canvas canvas,
    double w,
    double h,
    Paint pTrazo,
    Paint pTrazoFino,
  ) {
    // Sombra suave en el suelo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.48, h * 0.90),
        width: w * 0.56,
        height: h * 0.09,
      ),
      Paint()..color = const Color(0xFFE3D5B8),
    );

    // Caparazón vivo de musgo en la espalda (izquierda-centro)
    _pintarCaparazonMusgo(
      canvas,
      w,
      h,
      centro: Offset(w * 0.34, h * 0.56),
      ancho: w * 0.46,
      alto: h * 0.42,
      rotacion: -0.18,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Colita verde asomando abajo a la izquierda
    final cola = Path()
      ..moveTo(w * 0.22, h * 0.74)
      ..quadraticBezierTo(w * 0.11, h * 0.77, w * 0.13, h * 0.70)
      ..quadraticBezierTo(w * 0.18, h * 0.68, w * 0.24, h * 0.70)
      ..close();
    canvas.drawPath(cola, Paint()..color = _cPielSombra);
    canvas.drawPath(cola, pTrazo);

    // Patita trasera / izquierda y patita derecha plantadas en el suelo
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.41, h * 0.81),
        width: w * 0.14,
        height: h * 0.18,
      ),
      pTrazo,
      pTrazoFino,
    );
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.60, h * 0.81),
        width: w * 0.14,
        height: h * 0.18,
      ),
      pTrazo,
      pTrazoFino,
    );

    // Brazo derecho (izquierda del espectador) relajado hacia abajo
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.37, h * 0.54),
      mano: Offset(w * 0.29, h * 0.68),
      ctrl: Offset(w * 0.27, h * 0.58),
      grosor: w * 0.10,
      pTrazo: pTrazo,
    );

    // Brazo izquierdo (derecha del espectador) levantado saludando alegremente
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.66, h * 0.53),
      mano: Offset(w * 0.84, h * 0.41),
      ctrl: Offset(w * 0.79, h * 0.53),
      grosor: w * 0.10,
      pTrazo: pTrazo,
    );
    // Líneas de movimiento de saludo junto a la mano
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.87, h * 0.38),
        width: w * 0.12,
        height: h * 0.12,
      ),
      -math.pi * 0.45,
      math.pi * 0.55,
      false,
      pTrazoFino,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.89, h * 0.37),
        width: w * 0.17,
        height: h * 0.17,
      ),
      -math.pi * 0.40,
      math.pi * 0.50,
      false,
      pTrazoFino,
    );

    // Torso y plastrón (barriguita crema-lima cuadriculada)
    _pintarTorsoPlastron(
      canvas,
      centro: Offset(w * 0.52, h * 0.64),
      ancho: w * 0.34,
      alto: h * 0.30,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Pañuelo naranja de explorador al cuello
    _pintarPanueloExplorador(
      canvas,
      cuello: Offset(w * 0.55, h * 0.50),
      ancho: w * 0.34,
      alto: h * 0.16,
      pTrazo: pTrazo,
    );

    // Cabeza carismática de tortuga con brote superior
    _pintarCabezaTortuga(
      canvas,
      w,
      h,
      centro: Offset(w * 0.56, h * 0.30),
      ancho: w * 0.40,
      alto: h * 0.31,
      centroOjos: Offset(w * 0.57, h * 0.275),
      modoOjos: 'abiertos',
      modoBoca: 'risa',
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );
  }

  // ===========================================================================
  // POSE 2: CELEBRACIÓN ('feliz' / 'racha') — Saltando en el aire con destellos
  // ===========================================================================
  void _pintarPoseCelebracion(
    Canvas canvas,
    double w,
    double h,
    Paint pTrazo,
    Paint pTrazoFino,
  ) {
    // Sombra más pequeña abajo porque Natu está saltando en el aire
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.92),
        width: w * 0.38,
        height: h * 0.065,
      ),
      Paint()..color = const Color(0xFFE3D5B8),
    );

    // Destellos y estrellas doradas de celebración alrededor
    _pintarDestello4Puntas(
      canvas,
      Offset(w * 0.16, h * 0.22),
      w * 0.065,
      pTrazoFino,
    );
    _pintarDestello4Puntas(
      canvas,
      Offset(w * 0.86, h * 0.20),
      w * 0.060,
      pTrazoFino,
    );
    _pintarDestello4Puntas(
      canvas,
      Offset(w * 0.84, h * 0.66),
      w * 0.050,
      pTrazoFino,
    );
    _pintarDestello4Puntas(
      canvas,
      Offset(w * 0.15, h * 0.72),
      w * 0.045,
      pTrazoFino,
    );

    // Caparazón vivo detrás del salto
    _pintarCaparazonMusgo(
      canvas,
      w,
      h,
      centro: Offset(w * 0.36, h * 0.53),
      ancho: w * 0.44,
      alto: h * 0.40,
      rotacion: -0.22,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Patitas en el aire (una estirada y otra flexionada de alegría)
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.39, h * 0.78),
        width: w * 0.13,
        height: h * 0.16,
      ),
      pTrazo,
      pTrazoFino,
      rotacion: 0.25,
    );
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.65, h * 0.73),
        width: w * 0.13,
        height: h * 0.16,
      ),
      pTrazo,
      pTrazoFino,
      rotacion: -0.45,
    );

    // Ambos brazos levantados en V celebrando
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.38, h * 0.50),
      mano: Offset(w * 0.22, h * 0.35),
      ctrl: Offset(w * 0.25, h * 0.47),
      grosor: w * 0.095,
      pTrazo: pTrazo,
    );
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.65, h * 0.49),
      mano: Offset(w * 0.84, h * 0.34),
      ctrl: Offset(w * 0.78, h * 0.46),
      grosor: w * 0.095,
      pTrazo: pTrazo,
    );

    // Torso y plastrón en el salto
    _pintarTorsoPlastron(
      canvas,
      centro: Offset(w * 0.52, h * 0.60),
      ancho: w * 0.33,
      alto: h * 0.28,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Pañuelo naranja al vuelo
    _pintarPanueloExplorador(
      canvas,
      cuello: Offset(w * 0.54, h * 0.47),
      ancho: w * 0.34,
      alto: h * 0.15,
      pTrazo: pTrazo,
    );

    // Cabeza riendo con ojos cerrados en arco feliz (^ ^)
    _pintarCabezaTortuga(
      canvas,
      w,
      h,
      centro: Offset(w * 0.54, h * 0.28),
      ancho: w * 0.40,
      alto: h * 0.30,
      centroOjos: Offset(w * 0.55, h * 0.255),
      modoOjos: 'feliz_cerrados',
      modoBoca: 'risa_grande',
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );
  }

  // ===========================================================================
  // POSE 3: INVESTIGACIÓN ('pensando') — Agachada con lupa observando un brote
  // ===========================================================================
  void _pintarPoseInvestigacion(
    Canvas canvas,
    double w,
    double h,
    Paint pTrazo,
    Paint pTrazoFino,
  ) {
    // Sombra amplia en el suelo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.48, h * 0.88),
        width: w * 0.72,
        height: h * 0.09,
      ),
      Paint()..color = const Color(0xFFE3D5B8),
    );

    // Cuerpo horizontal inclinado hacia delante y plastrón inferior
    final cuerpoPath = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.67),
        width: w * 0.42,
        height: h * 0.20,
      ),
      Radius.circular(w * 0.10),
    );
    canvas.drawRRect(cuerpoPath, Paint()..color = _cPlastron);
    canvas.drawRRect(cuerpoPath, pTrazo);

    // Caparazón vivo arqueado arriba a la izquierda con brotes y flor
    _pintarCaparazonMusgo(
      canvas,
      w,
      h,
      centro: Offset(w * 0.34, h * 0.48),
      ancho: w * 0.48,
      alto: h * 0.36,
      rotacion: 0.12,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Patitas apoyadas en el suelo
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.24, h * 0.78),
        width: w * 0.13,
        height: h * 0.16,
      ),
      pTrazo,
      pTrazoFino,
    );
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.46, h * 0.79),
        width: w * 0.13,
        height: h * 0.16,
      ),
      pTrazo,
      pTrazoFino,
    );

    // Pañuelo naranja en el cuello inclinado
    _pintarPanueloExplorador(
      canvas,
      cuello: Offset(w * 0.55, h * 0.53),
      ancho: w * 0.30,
      alto: h * 0.15,
      pTrazo: pTrazo,
    );

    // Cabeza inclinada hacia delante mirando al brote con curiosidad
    _pintarCabezaTortuga(
      canvas,
      w,
      h,
      centro: Offset(w * 0.62, h * 0.36),
      ancho: w * 0.38,
      alto: h * 0.29,
      centroOjos: Offset(w * 0.64, h * 0.34),
      modoOjos: 'mirando_abajo',
      modoBoca: 'curiosa',
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Brazo delantero sosteniendo la lupa
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.58, h * 0.58),
      mano: Offset(w * 0.68, h * 0.64),
      ctrl: Offset(w * 0.62, h * 0.65),
      grosor: w * 0.09,
      pTrazo: pTrazo,
    );

    // Montículo de tierra y pequeño brote verde que Natu investiga (abajo derecha)
    final tierra = Path()
      ..moveTo(w * 0.72, h * 0.87)
      ..quadraticBezierTo(w * 0.83, h * 0.79, w * 0.94, h * 0.87)
      ..close();
    canvas.drawPath(tierra, Paint()..color = const Color(0xFF9C6644));
    canvas.drawPath(tierra, pTrazoFino);
    _pintarBroteDoble(
      canvas,
      base: Offset(w * 0.83, h * 0.82),
      escala: w * 0.13,
      pTrazo: pTrazoFino,
    );

    // Lupa científica sostenida por Natu
    canvas.drawLine(
      Offset(w * 0.66, h * 0.66),
      Offset(w * 0.73, h * 0.59),
      Paint()
        ..color = _cTrazo
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round,
    );
    final centroLupa = Offset(w * 0.78, h * 0.54);
    canvas.drawCircle(
      centroLupa,
      w * 0.105,
      Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.75),
    );
    canvas.drawCircle(
      centroLupa,
      w * 0.105,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.036,
    );
    canvas.drawCircle(centroLupa, w * 0.115, pTrazoFino);
    // Reflejo blanco del cristal de la lupa
    canvas.drawLine(
      Offset(centroLupa.dx - w * 0.04, centroLupa.dy - w * 0.04),
      Offset(centroLupa.dx + w * 0.02, centroLupa.dy - w * 0.06),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = w * 0.024
        ..strokeCap = StrokeCap.round,
    );
  }

  // ===========================================================================
  // POSE 4: ESTUDIO ('estudio') — Sentada leyendo un libro de Ciencias
  // ===========================================================================
  void _pintarPoseEstudio(
    Canvas canvas,
    double w,
    double h,
    Paint pTrazo,
    Paint pTrazoFino,
  ) {
    // Sombra en el suelo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.90),
        width: w * 0.64,
        height: h * 0.09,
      ),
      Paint()..color = const Color(0xFFE3D5B8),
    );

    // Caparazón asomando detrás
    _pintarCaparazonMusgo(
      canvas,
      w,
      h,
      centro: Offset(w * 0.34, h * 0.54),
      ancho: w * 0.44,
      alto: h * 0.40,
      rotacion: -0.14,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Patitas sentadas asomando a ambos lados
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.27, h * 0.82),
        width: w * 0.15,
        height: h * 0.13,
      ),
      pTrazo,
      pTrazoFino,
      rotacion: -0.3,
    );
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.75, h * 0.82),
        width: w * 0.15,
        height: h * 0.13,
      ),
      pTrazo,
      pTrazoFino,
      rotacion: 0.3,
    );

    // Torso y pañuelo naranja sobre el libro
    _pintarTorsoPlastron(
      canvas,
      centro: Offset(w * 0.52, h * 0.64),
      ancho: w * 0.34,
      alto: h * 0.28,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );
    _pintarPanueloExplorador(
      canvas,
      cuello: Offset(w * 0.52, h * 0.47),
      ancho: w * 0.34,
      alto: h * 0.14,
      pTrazo: pTrazo,
    );

    // Cabeza concentrada leyendo
    _pintarCabezaTortuga(
      canvas,
      w,
      h,
      centro: Offset(w * 0.52, h * 0.28),
      ancho: w * 0.40,
      alto: h * 0.30,
      centroOjos: Offset(w * 0.53, h * 0.265),
      modoOjos: 'mirando_abajo',
      modoBoca: 'sonrisa',
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Libro abierto de Ciencias Naturales frente al pecho
    final paginasPath = Path()
      ..moveTo(w * 0.26, h * 0.55)
      ..quadraticBezierTo(w * 0.39, h * 0.51, w * 0.52, h * 0.56)
      ..quadraticBezierTo(w * 0.65, h * 0.51, w * 0.78, h * 0.55)
      ..lineTo(w * 0.76, h * 0.80)
      ..quadraticBezierTo(w * 0.64, h * 0.76, w * 0.52, h * 0.81)
      ..quadraticBezierTo(w * 0.40, h * 0.76, w * 0.28, h * 0.80)
      ..close();
    canvas.drawPath(paginasPath, Paint()..color = const Color(0xFFFFFBEB));
    canvas.drawPath(paginasPath, pTrazo);

    final cubiertaPath = Path()
      ..moveTo(w * 0.25, h * 0.58)
      ..quadraticBezierTo(w * 0.39, h * 0.55, w * 0.52, h * 0.60)
      ..quadraticBezierTo(w * 0.65, h * 0.55, w * 0.79, h * 0.58)
      ..lineTo(w * 0.77, h * 0.83)
      ..quadraticBezierTo(w * 0.64, h * 0.79, w * 0.52, h * 0.84)
      ..quadraticBezierTo(w * 0.40, h * 0.79, w * 0.27, h * 0.83)
      ..close();
    canvas.drawPath(cubiertaPath, Paint()..color = const Color(0xFFC86D51));
    canvas.drawPath(cubiertaPath, pTrazo);
    // Lomo central del libro
    canvas.drawLine(
      Offset(w * 0.52, h * 0.56),
      Offset(w * 0.52, h * 0.84),
      pTrazo,
    );
    // Dibujo de hojita en la cubierta izquierda y átomo en la derecha
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.39, h * 0.70),
        width: w * 0.10,
        height: h * 0.06,
      ),
      Paint()..color = _cPiel,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.39, h * 0.70),
        width: w * 0.10,
        height: h * 0.06,
      ),
      pTrazoFino,
    );
    canvas.drawCircle(
      Offset(w * 0.65, h * 0.70),
      w * 0.04,
      Paint()
        ..color = const Color(0xFFFDE68A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018,
    );

    // Manitas verdes sujetando los bordes del libro
    canvas.drawCircle(
      Offset(w * 0.26, h * 0.69),
      w * 0.055,
      Paint()..color = _cPiel,
    );
    canvas.drawCircle(Offset(w * 0.26, h * 0.69), w * 0.055, pTrazo);
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.69),
      w * 0.055,
      Paint()..color = _cPiel,
    );
    canvas.drawCircle(Offset(w * 0.78, h * 0.69), w * 0.055, pTrazo);
  }

  // ===========================================================================
  // POSE 5: MOTIVACIÓN ('pista') — ¡Tú puedes! Señalando con entusiasmo
  // ===========================================================================
  void _pintarPoseMotivacion(
    Canvas canvas,
    double w,
    double h,
    Paint pTrazo,
    Paint pTrazoFino,
  ) {
    // Sombra dinámica en el suelo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.48, h * 0.90),
        width: w * 0.58,
        height: h * 0.09,
      ),
      Paint()..color = const Color(0xFFE3D5B8),
    );

    // Destello motivador junto a la mano que señala
    _pintarDestello4Puntas(
      canvas,
      Offset(w * 0.88, h * 0.34),
      w * 0.06,
      pTrazoFino,
    );

    // Caparazón vivo inclinado con energía
    _pintarCaparazonMusgo(
      canvas,
      w,
      h,
      centro: Offset(w * 0.33, h * 0.54),
      ancho: w * 0.46,
      alto: h * 0.40,
      rotacion: -0.10,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Patitas en postura activa
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.81),
        width: w * 0.14,
        height: h * 0.17,
      ),
      pTrazo,
      pTrazoFino,
      rotacion: 0.12,
    );
    _pintarPataTortuga(
      canvas,
      Rect.fromCenter(
        center: Offset(w * 0.60, h * 0.81),
        width: w * 0.14,
        height: h * 0.17,
      ),
      pTrazo,
      pTrazoFino,
      rotacion: -0.10,
    );

    // Brazo trasero flexionado con energía
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.37, h * 0.54),
      mano: Offset(w * 0.25, h * 0.60),
      ctrl: Offset(w * 0.28, h * 0.52),
      grosor: w * 0.095,
      pTrazo: pTrazo,
    );

    // Brazo delantero extendido hacia delante animando («¡Tú puedes!»)
    _pintarBrazoTortuga(
      canvas,
      hombro: Offset(w * 0.66, h * 0.53),
      mano: Offset(w * 0.86, h * 0.47),
      ctrl: Offset(w * 0.76, h * 0.54),
      grosor: w * 0.095,
      pTrazo: pTrazo,
    );

    // Torso y plastrón
    _pintarTorsoPlastron(
      canvas,
      centro: Offset(w * 0.52, h * 0.63),
      ancho: w * 0.34,
      alto: h * 0.29,
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );

    // Pañuelo naranja
    _pintarPanueloExplorador(
      canvas,
      cuello: Offset(w * 0.55, h * 0.49),
      ancho: w * 0.34,
      alto: h * 0.15,
      pTrazo: pTrazo,
    );

    // Cabeza entusiasta
    _pintarCabezaTortuga(
      canvas,
      w,
      h,
      centro: Offset(w * 0.56, h * 0.29),
      ancho: w * 0.40,
      alto: h * 0.30,
      centroOjos: Offset(w * 0.57, h * 0.265),
      modoOjos: 'motivacion',
      modoBoca: 'risa_grande',
      pTrazo: pTrazo,
      pTrazoFino: pTrazoFino,
    );
  }

  // ===========================================================================
  // COMPONENTES ANATÓMICOS DE NATU (CAPARAZÓN VIVO, PLASTRÓN, PAÑUELO, CABEZA)
  // ===========================================================================

  void _pintarCaparazonMusgo(
    Canvas canvas,
    double w,
    double h, {
    required Offset centro,
    required double ancho,
    required double alto,
    required double rotacion,
    required Paint pTrazo,
    required Paint pTrazoFino,
  }) {
    canvas.save();
    canvas.translate(centro.dx, centro.dy);
    canvas.rotate(rotacion);

    // 1. Brote verde de dos hojas creciendo del caparazón (arriba-izquierda)
    _pintarBroteDoble(
      canvas,
      base: Offset(-ancho * 0.32, -alto * 0.42),
      escala: w * 0.15,
      rotacion: -0.45,
      pTrazo: pTrazoFino,
    );

    // 2. Domo principal del caparazón cubierto de musgo verde bosque
    final domoRect = Rect.fromCenter(
      center: Offset.zero,
      width: ancho,
      height: alto,
    );
    canvas.drawOval(domoRect, Paint()..color = _cMusgo);

    // Bultitos orgánicos de musgo claro en la parte superior del caparazón
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-ancho * 0.12, -alto * 0.18),
        width: ancho * 0.55,
        height: alto * 0.42,
      ),
      Paint()..color = _cMusgoClaro,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(ancho * 0.10, -alto * 0.04),
        width: ancho * 0.44,
        height: alto * 0.36,
      ),
      Paint()..color = _cMusgoClaro,
    );

    // Manchas de musgo profundo para dar textura de bosque
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-ancho * 0.24, alto * 0.08),
        width: ancho * 0.28,
        height: alto * 0.24,
      ),
      Paint()..color = _cMusgoOscuro,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-ancho * 0.04, alto * 0.22),
        width: ancho * 0.30,
        height: alto * 0.22,
      ),
      Paint()..color = _cMusgoOscuro,
    );

    // Borde inferior segmentado del caparazón (#78923D)
    final rebordePath = Path()
      ..moveTo(ancho * 0.36, -alto * 0.32)
      ..quadraticBezierTo(ancho * 0.54, 0, ancho * 0.28, alto * 0.44)
      ..quadraticBezierTo(ancho * 0.12, alto * 0.48, ancho * 0.06, alto * 0.38)
      ..quadraticBezierTo(ancho * 0.34, 0, ancho * 0.20, -alto * 0.36)
      ..close();
    canvas.drawPath(rebordePath, Paint()..color = _cBordeCaparazon);
    canvas.drawPath(rebordePath, pTrazoFino);

    // Trazo exterior del caparazón
    canvas.drawOval(domoRect, pTrazo);

    // 3. Florecita silvestre naranja de 5 pétalos sobre el musgo
    _pintarFlorecitaCaparazon(
      canvas,
      Offset(-ancho * 0.16, -alto * 0.06),
      w * 0.052,
      pTrazoFino,
    );

    canvas.restore();
  }

  void _pintarFlorecitaCaparazon(
    Canvas canvas,
    Offset centro,
    double radio,
    Paint pTrazoFino,
  ) {
    final pPetalo = Paint()..color = _cFlor;
    for (int i = 0; i < 5; i++) {
      final ang = i * (2 * math.pi / 5) - math.pi / 2;
      final cPetalo = Offset(
        centro.dx + math.cos(ang) * radio * 0.62,
        centro.dy + math.sin(ang) * radio * 0.62,
      );
      canvas.drawCircle(cPetalo, radio * 0.46, pPetalo);
      canvas.drawCircle(cPetalo, radio * 0.46, pTrazoFino);
    }
    canvas.drawCircle(
      centro,
      radio * 0.34,
      Paint()..color = const Color(0xFFFDE047),
    );
    canvas.drawCircle(centro, radio * 0.34, pTrazoFino);
  }

  void _pintarBroteDoble(
    Canvas canvas, {
    required Offset base,
    required double escala,
    double rotacion = 0.0,
    required Paint pTrazo,
  }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    if (rotacion != 0) canvas.rotate(rotacion);

    // Tallo corto
    canvas.drawLine(
      Offset.zero,
      Offset(0, -escala * 0.45),
      pTrazo,
    );

    // Hoja izquierda y hoja derecha
    for (final dir in [-1.0, 1.0]) {
      final hoja = Path()
        ..moveTo(0, -escala * 0.40)
        ..quadraticBezierTo(
          dir * escala * 0.45,
          -escala * 0.95,
          dir * escala * 0.82,
          -escala * 0.58,
        )
        ..quadraticBezierTo(
          dir * escala * 0.42,
          -escala * 0.18,
          0,
          -escala * 0.40,
        )
        ..close();
      canvas.drawPath(
        hoja,
        Paint()..color = dir < 0 ? _cPiel : const Color(0xFF80B938),
      );
      canvas.drawPath(hoja, pTrazo);
    }
    canvas.restore();
  }

  void _pintarPataTortuga(
    Canvas canvas,
    Rect rect,
    Paint pTrazo,
    Paint pTrazoFino, {
    double rotacion = 0.0,
  }) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    if (rotacion != 0) canvas.rotate(rotacion);
    final localRect = Rect.fromCenter(
      center: Offset.zero,
      width: rect.width,
      height: rect.height,
    );
    final rrect = RRect.fromRectAndCorners(
      localRect,
      topLeft: Radius.circular(rect.width * 0.45),
      topRight: Radius.circular(rect.width * 0.45),
      bottomLeft: Radius.circular(rect.width * 0.38),
      bottomRight: Radius.circular(rect.width * 0.38),
    );
    canvas.drawRRect(rrect, Paint()..color = _cPiel);
    canvas.drawRRect(rrect, pTrazo);

    // Pequeñas marquitas redondeadas en los deditos de la pata
    for (final dx in [-0.18, 0.18]) {
      canvas.drawLine(
        Offset(rect.width * dx, rect.height * 0.32),
        Offset(rect.width * dx, rect.height * 0.46),
        pTrazoFino,
      );
    }
    canvas.restore();
  }

  void _pintarBrazoTortuga(
    Canvas canvas, {
    required Offset hombro,
    required Offset mano,
    required Offset ctrl,
    required double grosor,
    required Paint pTrazo,
  }) {
    final pRelleno = Paint()
      ..color = _cPiel
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pBordeExterior = Paint()
      ..color = _cTrazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = grosor + pTrazo.strokeWidth * 1.85
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(hombro.dx, hombro.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, mano.dx, mano.dy);
    canvas.drawPath(path, pBordeExterior);
    canvas.drawPath(path, pRelleno);
  }

  void _pintarTorsoPlastron(
    Canvas canvas, {
    required Offset centro,
    required double ancho,
    required double alto,
    required Paint pTrazo,
    required Paint pTrazoFino,
  }) {
    final cuerpoRect = Rect.fromCenter(
      center: centro,
      width: ancho,
      height: alto,
    );
    // Base verde manzana del torso
    canvas.drawOval(cuerpoRect, Paint()..color = _cPiel);
    canvas.drawOval(cuerpoRect, pTrazo);

    // Escudo frontal crema-lima (plastrón) con cuadrícula suave
    final plastronRect = Rect.fromCenter(
      center: Offset(centro.dx + ancho * 0.04, centro.dy + alto * 0.03),
      width: ancho * 0.76,
      height: alto * 0.82,
    );
    canvas.drawOval(plastronRect, Paint()..color = _cPlastron);

    final pGrid = Paint()
      ..color = _cPlastronLinea
      ..style = PaintingStyle.stroke
      ..strokeWidth = pTrazoFino.strokeWidth
      ..strokeCap = StrokeCap.round;

    // Línea vertical central del plastrón
    canvas.drawLine(
      Offset(plastronRect.center.dx, plastronRect.top + alto * 0.08),
      Offset(plastronRect.center.dx, plastronRect.bottom - alto * 0.06),
      pGrid,
    );
    // Dos líneas horizontales ligeramente curvas
    for (final fy in [-0.10, 0.16]) {
      final y = plastronRect.center.dy + alto * fy;
      final lineaH = Path()
        ..moveTo(plastronRect.left + ancho * 0.06, y)
        ..quadraticBezierTo(
          plastronRect.center.dx,
          y + alto * 0.04,
          plastronRect.right - ancho * 0.06,
          y,
        );
      canvas.drawPath(lineaH, pGrid);
    }

    canvas.drawOval(plastronRect, pTrazoFino);
  }

  void _pintarPanueloExplorador(
    Canvas canvas, {
    required Offset cuello,
    required double ancho,
    required double alto,
    required Paint pTrazo,
  }) {
    // Puntas triangulares del pañuelo cayendo sobre el pecho
    final puntas = Path()
      ..moveTo(cuello.dx - ancho * 0.14, cuello.dy + alto * 0.05)
      ..lineTo(cuello.dx - ancho * 0.24, cuello.dy + alto * 0.78)
      ..lineTo(cuello.dx + ancho * 0.02, cuello.dy + alto * 0.42)
      ..lineTo(cuello.dx + ancho * 0.22, cuello.dy + alto * 0.76)
      ..lineTo(cuello.dx + ancho * 0.20, cuello.dy + alto * 0.05)
      ..close();
    canvas.drawPath(puntas, Paint()..color = _cPanueloSombra);
    canvas.drawPath(puntas, pTrazo);

    // Banda principal alrededor del cuello
    final banda = Path()
      ..moveTo(cuello.dx - ancho * 0.48, cuello.dy - alto * 0.22)
      ..quadraticBezierTo(
        cuello.dx,
        cuello.dy + alto * 0.22,
        cuello.dx + ancho * 0.46,
        cuello.dy - alto * 0.18,
      )
      ..quadraticBezierTo(
        cuello.dx + ancho * 0.36,
        cuello.dy + alto * 0.36,
        cuello.dx,
        cuello.dy + alto * 0.34,
      )
      ..quadraticBezierTo(
        cuello.dx - ancho * 0.38,
        cuello.dy + alto * 0.34,
        cuello.dx - ancho * 0.48,
        cuello.dy - alto * 0.22,
      )
      ..close();
    canvas.drawPath(banda, Paint()..color = _cPanuelo);
    canvas.drawPath(banda, pTrazo);

    // Nudo central redondeado del pañuelo
    final nudoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cuello.dx + ancho * 0.02, cuello.dy + alto * 0.18),
        width: ancho * 0.22,
        height: alto * 0.38,
      ),
      Radius.circular(ancho * 0.09),
    );
    canvas.drawRRect(nudoRect, Paint()..color = _cPanuelo);
    canvas.drawRRect(nudoRect, pTrazo);
  }

  void _pintarCabezaTortuga(
    Canvas canvas,
    double w,
    double h, {
    required Offset centro,
    required double ancho,
    required double alto,
    required Offset centroOjos,
    required String modoOjos,
    required String modoBoca,
    required Paint pTrazo,
    required Paint pTrazoFino,
  }) {
    // Cuello corto conectando cabeza y pañuelo
    final cuelloRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centro.dx - ancho * 0.04, centro.dy + alto * 0.52),
        width: ancho * 0.38,
        height: alto * 0.36,
      ),
      Radius.circular(ancho * 0.14),
    );
    canvas.drawRRect(cuelloRect, Paint()..color = _cPielSombra);
    canvas.drawRRect(cuelloRect, pTrazo);

    // Brote verde simpático en la coronilla
    _pintarBroteDoble(
      canvas,
      base: Offset(centro.dx - ancho * 0.04, centro.dy - alto * 0.46),
      escala: w * 0.12,
      rotacion: 0.08,
      pTrazo: pTrazoFino,
    );

    // Silueta redondeada de cabeza de tortuga con mejillas suaves
    final cabezaPath = Path()
      ..moveTo(centro.dx, centro.dy - alto * 0.50)
      ..cubicTo(
        centro.dx + ancho * 0.46,
        centro.dy - alto * 0.50,
        centro.dx + ancho * 0.56,
        centro.dy - alto * 0.08,
        centro.dx + ancho * 0.52,
        centro.dy + alto * 0.20,
      )
      ..cubicTo(
        centro.dx + ancho * 0.48,
        centro.dy + alto * 0.48,
        centro.dx + ancho * 0.22,
        centro.dy + alto * 0.52,
        centro.dx,
        centro.dy + alto * 0.52,
      )
      ..cubicTo(
        centro.dx - ancho * 0.28,
        centro.dy + alto * 0.52,
        centro.dx - ancho * 0.54,
        centro.dy + alto * 0.42,
        centro.dx - ancho * 0.50,
        centro.dy + alto * 0.12,
      )
      ..cubicTo(
        centro.dx - ancho * 0.48,
        centro.dy - alto * 0.22,
        centro.dx - ancho * 0.38,
        centro.dy - alto * 0.50,
        centro.dx,
        centro.dy - alto * 0.50,
      )
      ..close();

    canvas.drawPath(cabezaPath, Paint()..color = _cPiel);

    // Brillo superior suave en la frente
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx - ancho * 0.06, centro.dy - alto * 0.24),
        width: ancho * 0.56,
        height: alto * 0.28,
      ),
      Paint()..color = _cPielLuz.withValues(alpha: 0.75),
    );
    canvas.drawPath(cabezaPath, pTrazo);

    // Mofletes verde oliva cálido
    final izqOjo = Offset(centroOjos.dx - w * 0.08, centroOjos.dy);
    final derOjo = Offset(centroOjos.dx + w * 0.08, centroOjos.dy);
    for (final cMoflete in [
      Offset(izqOjo.dx - w * 0.045, centroOjos.dy + h * 0.065),
      Offset(derOjo.dx + w * 0.040, centroOjos.dy + h * 0.065),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: cMoflete,
          width: w * 0.075,
          height: h * 0.042,
        ),
        Paint()..color = _cMejilla.withValues(alpha: 0.65),
      );
    }

    // Ojos expresivos (separados exactamente 0.16 * w para sincronizar con las gafas)
    if (modoOjos == 'feliz_cerrados') {
      for (final c in [izqOjo, derOjo]) {
        final arco = Path()
          ..moveTo(c.dx - w * 0.048, c.dy + h * 0.015)
          ..quadraticBezierTo(
            c.dx,
            c.dy - h * 0.055,
            c.dx + w * 0.048,
            c.dy + h * 0.015,
          );
        canvas.drawPath(arco, pTrazo);
      }
    } else {
      final desfasePupila = switch (modoOjos) {
        'mirando_abajo' => Offset(w * 0.008, h * 0.014),
        'motivacion' => Offset(w * 0.008, -h * 0.004),
        _ => Offset(w * 0.005, 0),
      };

      for (final c in [izqOjo, derOjo]) {
        final rectOjo = Rect.fromCenter(
          center: c,
          width: w * 0.095,
          height: h * 0.115,
        );
        // Esclerótica blanca
        canvas.drawOval(rectOjo, Paint()..color = Colors.white);
        // Gran pupila ovalada marrón espresso (#3B2314)
        final rectPupila = Rect.fromCenter(
          center: c + desfasePupila,
          width: w * 0.062,
          height: h * 0.082,
        );
        canvas.drawOval(rectPupila, Paint()..color = _cTrazo);
        // Destello blanco vivo arriba a la izquierda
        canvas.drawCircle(
          Offset(c.dx - w * 0.014, c.dy - h * 0.022) + desfasePupila * 0.4,
          w * 0.015,
          Paint()..color = Colors.white,
        );
        canvas.drawOval(rectOjo, pTrazoFino);

        // Cejas expresivas suaves
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy - h * 0.068),
            width: w * 0.08,
            height: h * 0.03,
          ),
          math.pi * 1.15,
          math.pi * 0.70,
          false,
          pTrazoFino,
        );
      }
    }

    // Dos puntitos de naricita entre los ojos
    final yNariz = centroOjos.dy + h * 0.032;
    canvas.drawCircle(
      Offset(centroOjos.dx - w * 0.012, yNariz),
      w * 0.007,
      Paint()..color = _cTrazo,
    );
    canvas.drawCircle(
      Offset(centroOjos.dx + w * 0.014, yNariz),
      w * 0.007,
      Paint()..color = _cTrazo,
    );

    // Boca expresiva con lengua coral
    final cBoca = Offset(centroOjos.dx + w * 0.004, centroOjos.dy + h * 0.082);
    if (modoBoca == 'curiosa') {
      final bocaCuriosa = Path()
        ..moveTo(cBoca.dx - w * 0.035, cBoca.dy - h * 0.005)
        ..quadraticBezierTo(
          cBoca.dx,
          cBoca.dy + h * 0.030,
          cBoca.dx + w * 0.040,
          cBoca.dy - h * 0.008,
        );
      canvas.drawPath(bocaCuriosa, pTrazoFino);
    } else if (modoBoca == 'sonrisa') {
      final bocaSonrisa = Path()
        ..moveTo(cBoca.dx - w * 0.045, cBoca.dy - h * 0.008)
        ..quadraticBezierTo(
          cBoca.dx,
          cBoca.dy + h * 0.042,
          cBoca.dx + w * 0.048,
          cBoca.dy - h * 0.008,
        )
        ..close();
      canvas.drawPath(bocaSonrisa, Paint()..color = _cBoca);
      canvas.drawPath(bocaSonrisa, pTrazoFino);
    } else {
      final escalaBoca = modoBoca == 'risa_grande' ? 1.15 : 1.0;
      final anchoB = w * 0.056 * escalaBoca;
      final altoB = h * 0.062 * escalaBoca;
      final bocaPath = Path()
        ..moveTo(cBoca.dx - anchoB, cBoca.dy - altoB * 0.25)
        ..quadraticBezierTo(
          cBoca.dx,
          cBoca.dy - altoB * 0.15,
          cBoca.dx + anchoB,
          cBoca.dy - altoB * 0.25,
        )
        ..cubicTo(
          cBoca.dx + anchoB * 0.95,
          cBoca.dy + altoB * 0.85,
          cBoca.dx - anchoB * 0.95,
          cBoca.dy + altoB * 0.85,
          cBoca.dx - anchoB,
          cBoca.dy - altoB * 0.25,
        )
        ..close();
      canvas.drawPath(bocaPath, Paint()..color = _cBoca);

      // Lengua rosa coral en la base de la boca
      canvas.save();
      canvas.clipPath(bocaPath);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cBoca.dx, cBoca.dy + altoB * 0.45),
          width: anchoB * 1.45,
          height: altoB * 0.85,
        ),
        Paint()..color = _cLengua,
      );
      canvas.restore();

      canvas.drawPath(bocaPath, pTrazoFino);
    }
  }

  void _pintarDestello4Puntas(
    Canvas canvas,
    Offset c,
    double r,
    Paint pTrazoFino,
  ) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawPath(path, pTrazoFino);
  }

  @override
  bool shouldRepaint(covariant PintorMascotaNatu oldDelegate) =>
      oldDelegate.gesto != gesto;
}

class DibujoAnimalDetallado extends StatelessWidget {
  const DibujoAnimalDetallado({
    required this.id,
    this.ancho = 70,
    this.alto = 60,
    this.sinFondo = false,
    super.key,
  });

  final String id;
  final double ancho;
  final double alto;
  final bool sinFondo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho,
      height: alto,
      child: CustomPaint(
        painter: PintorAnimalDetallado(id: id, sinFondo: sinFondo),
      ),
    );
  }
}

class PintorAnimalDetallado extends CustomPainter {
  const PintorAnimalDetallado({required this.id, this.sinFondo = false});

  final String id;
  final bool sinFondo;

  void _sombraSuelo(
    Canvas canvas,
    Size size, {
    double y = 0.90,
    double ancho = 0.62,
  }) {
    if (!sinFondo) return;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * y),
        width: size.width * ancho,
        height: size.height * 0.11,
      ),
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.18),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (id) {
      case 'rana':
        _pintarRana(canvas, size);
      case 'tucan':
        _pintarTucan(canvas, size);
      case 'delfin':
        _pintarDelfin(canvas, size);
      case 'pinguino':
        _pintarPinguino(canvas, size);
      case 'oso':
        _pintarOso(canvas, size);
      case 'pulpo':
        _pintarPulpo(canvas, size);
      case 'mariposa':
        _pintarMariposa(canvas, size);
      case 'renacuajo':
        _pintarRenacuajo(canvas, size);
      case 'huevo':
        _pintarHuevo(canvas, size);
      case 'aguila':
        _pintarAguila(canvas, size);
      case 'serpiente':
        _pintarSerpiente(canvas, size);
      case 'raton':
        _pintarRaton(canvas, size);
      case 'zorro':
        _pintarZorro(canvas, size);
      case 'conejo':
        _pintarConejo(canvas, size);
      default:
        _pintarCamello(canvas, size);
    }
  }

  void _pintarRana(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final pBorde = Paint()
      ..color = const Color(0xFF14532D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (!sinFondo) {
      final nenufar = Rect.fromCenter(
        center: Offset(cx, h * 0.86),
        width: w * 0.88,
        height: h * 0.22,
      );
      canvas.drawArc(
        nenufar,
        0.25,
        math.pi * 2 - 0.5,
        true,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF15803D)],
          ).createShader(nenufar),
      );
      canvas.drawArc(nenufar, 0.25, math.pi * 2 - 0.5, true, pBorde);
    } else {
      _sombraSuelo(canvas, size, y: 0.88, ancho: 0.68);
    }

    // Ancas traseras musculosas en Z listas para saltar y pies palmeados
    for (final signo in [-1.0, 1.0]) {
      final muslo = Rect.fromCenter(
        center: Offset(cx + signo * w * 0.27, h * 0.67),
        width: w * 0.24,
        height: h * 0.28,
      );
      canvas.drawOval(muslo, Paint()..color = const Color(0xFF16A34A));
      canvas.drawOval(muslo, pBorde);

      final pie = Path()
        ..moveTo(cx + signo * w * 0.20, h * 0.79)
        ..lineTo(cx + signo * w * 0.40, h * 0.83)
        ..lineTo(cx + signo * w * 0.34, h * 0.87)
        ..lineTo(cx + signo * w * 0.28, h * 0.85)
        ..lineTo(cx + signo * w * 0.22, h * 0.88)
        ..lineTo(cx + signo * w * 0.16, h * 0.84)
        ..close();
      canvas.drawPath(pie, Paint()..color = const Color(0xFF4ADE80));
      canvas.drawPath(pie, pBorde);
    }

    // Cuerpo rechoncho de rana arborícola/charca con brillo húmedo
    final rectCuerpo = Rect.fromCenter(
      center: Offset(cx, h * 0.57),
      width: w * 0.56,
      height: h * 0.48,
    );
    canvas.drawOval(
      rectCuerpo,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.35),
          colors: [Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF15803D)],
        ).createShader(rectCuerpo),
    );
    canvas.drawOval(rectCuerpo, pBorde);

    // Saco vocal / vientre crema amarillento con pliegues suaves
    final garganta = Rect.fromCenter(
      center: Offset(cx, h * 0.62),
      width: w * 0.38,
      height: h * 0.29,
    );
    canvas.drawOval(garganta, Paint()..color = const Color(0xFFFEF08A));
    canvas.drawArc(
      garganta,
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = const Color(0xFFCA8A04).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Patitas delanteras apoyadas con deditos redondeados
    for (final signo in [-1.0, 1.0]) {
      final brazo = Path()
        ..moveTo(cx + signo * w * 0.14, h * 0.68)
        ..quadraticBezierTo(
          cx + signo * w * 0.20,
          h * 0.78,
          cx + signo * w * 0.15,
          h * 0.85,
        );
      canvas.drawPath(
        brazo,
        Paint()
          ..color = const Color(0xFF14532D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawPath(
        brazo,
        Paint()
          ..color = const Color(0xFF4ADE80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Grandes ojos saltones superiores con iris dorado/ámbar y pupila horizontal
    for (final signo in [-1.0, 1.0]) {
      final cOjo = Offset(cx + signo * w * 0.16, h * 0.29);
      canvas.drawCircle(
        cOjo,
        w * 0.115,
        Paint()..color = const Color(0xFF22C55E),
      );
      canvas.drawCircle(cOjo, w * 0.115, pBorde);
      canvas.drawCircle(
        cOjo,
        w * 0.082,
        Paint()..color = const Color(0xFFFDE047),
      );
      canvas.drawOval(
        Rect.fromCenter(center: cOjo, width: w * 0.085, height: w * 0.052),
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        cOjo + Offset(-w * 0.025, -w * 0.025),
        1.5,
        Paint()..color = Colors.white,
      );
    }

    // Mofletes sonrojados y sonrisa ancha simpática
    for (final signo in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + signo * w * 0.20, h * 0.47),
          width: w * 0.08,
          height: h * 0.05,
        ),
        Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.35),
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * 0.47),
        width: w * 0.36,
        height: h * 0.13,
      ),
      0.12,
      math.pi - 0.24,
      false,
      pBorde,
    );
  }

  void _pintarTucan(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pBorde = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (!sinFondo) {
      canvas.drawLine(
        Offset(w * 0.06, h * 0.86),
        Offset(w * 0.78, h * 0.82),
        Paint()
          ..color = const Color(0xFF78350F)
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round,
      );
      final hojaRama = Path()
        ..moveTo(w * 0.72, h * 0.82)
        ..quadraticBezierTo(w * 0.86, h * 0.70, w * 0.92, h * 0.82)
        ..quadraticBezierTo(w * 0.82, h * 0.90, w * 0.72, h * 0.82);
      canvas.drawPath(hojaRama, Paint()..color = const Color(0xFF16A34A));
      canvas.drawPath(hojaRama, pBorde);
    } else {
      _sombraSuelo(canvas, size, y: 0.89, ancho: 0.52);
    }

    // Cola larga escalonada con base roja carmesí
    final cola = Path()
      ..moveTo(w * 0.22, h * 0.66)
      ..lineTo(w * 0.05, h * 0.82)
      ..lineTo(w * 0.16, h * 0.89)
      ..lineTo(w * 0.29, h * 0.73)
      ..close();
    canvas.drawPath(cola, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(cola, pBorde);

    // Cuerpo estilizado de tucán toco negro azabache con reflejo azulado
    final rectCuerpo = Rect.fromCenter(
      center: Offset(w * 0.34, h * 0.54),
      width: w * 0.35,
      height: h * 0.58,
    );
    canvas.drawOval(
      rectCuerpo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF334155), Color(0xFF0F172A)],
        ).createShader(rectCuerpo),
    );
    canvas.drawOval(rectCuerpo, pBorde);

    // Babero / garganta amarillo sol con franja pectoral carmesí
    final rectPecho = Rect.fromCenter(
      center: Offset(w * 0.41, h * 0.45),
      width: w * 0.21,
      height: h * 0.33,
    );
    canvas.drawOval(rectPecho, Paint()..color = const Color(0xFFFACC15));
    canvas.drawArc(
      rectPecho,
      0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );

    // Ala negra con plumas marcadas
    final ala = Path()
      ..moveTo(w * 0.24, h * 0.44)
      ..quadraticBezierTo(w * 0.15, h * 0.62, w * 0.30, h * 0.75)
      ..quadraticBezierTo(w * 0.37, h * 0.58, w * 0.24, h * 0.44);
    canvas.drawPath(ala, Paint()..color = const Color(0xFF1E293B));
    canvas.drawPath(ala, pBorde);

    // Gran pico icónico de tucán con degradado amarillo-naranja y mancha negra en la punta
    final pico = Path()
      ..moveTo(w * 0.45, h * 0.23)
      ..quadraticBezierTo(w * 0.78, h * 0.18, w * 0.94, h * 0.38)
      ..quadraticBezierTo(w * 0.74, h * 0.45, w * 0.45, h * 0.42)
      ..close();
    canvas.drawPath(
      pico,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFDE047), Color(0xFFF97316), Color(0xFFEA580C)],
        ).createShader(pico.getBounds()),
    );
    final puntaPico = Path()
      ..moveTo(w * 0.81, h * 0.26)
      ..quadraticBezierTo(w * 0.90, h * 0.31, w * 0.94, h * 0.38)
      ..lineTo(w * 0.80, h * 0.41)
      ..close();
    canvas.drawPath(puntaPico, Paint()..color = const Color(0xFF0F172A));
    canvas.drawPath(pico, pBorde);
    canvas.drawLine(
      Offset(w * 0.46, h * 0.35),
      Offset(w * 0.91, h * 0.37),
      Paint()
        ..color = const Color(0xFF7C2D12)
        ..strokeWidth = 1.6,
    );

    // Ojo vivo con anillo periorbital azul eléctrico
    final cOjo = Offset(w * 0.38, h * 0.33);
    canvas.drawCircle(cOjo, 5.6, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(cOjo, 3.0, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(
      cOjo + const Offset(-1.0, -1.0),
      1.1,
      Paint()..color = Colors.white,
    );

    // Patas celestes zigodáctilas
    for (final gx in [0.31, 0.39]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * gx, h * 0.83),
          width: 6.8,
          height: 4.8,
        ),
        Paint()..color = const Color(0xFF0284C7),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * gx, h * 0.83),
          width: 6.8,
          height: 4.8,
        ),
        pBorde,
      );
    }
  }

  void _pintarCamello(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pBorde = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (!sinFondo) {
      final duna = Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.90),
        width: w * 0.88,
        height: h * 0.18,
      );
      canvas.drawOval(
        duna,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
          ).createShader(duna),
      );
    } else {
      _sombraSuelo(canvas, size, y: 0.90, ancho: 0.68);
    }

    // Cola con mechón oscuro
    final cola = Path()
      ..moveTo(w * 0.18, h * 0.48)
      ..quadraticBezierTo(w * 0.10, h * 0.56, w * 0.12, h * 0.68);
    canvas.drawPath(
      cola,
      Paint()
        ..color = const Color(0xFF92400E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.12, h * 0.70), width: 5, height: 8),
      Paint()..color = const Color(0xFF451A03),
    );

    // 4 patas largas con rodillas callosas y pezuñas anchas almohadilladas
    for (final (lx, colorPata) in [
      (0.24, const Color(0xFF92400E)),
      (0.34, const Color(0xFFD97706)),
      (0.55, const Color(0xFF92400E)),
      (0.65, const Color(0xFFD97706)),
    ]) {
      canvas.drawLine(
        Offset(w * lx, h * 0.56),
        Offset(w * lx, h * 0.87),
        Paint()
          ..color = const Color(0xFF78350F)
          ..strokeWidth = 6.8
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(w * lx, h * 0.56),
        Offset(w * lx, h * 0.87),
        Paint()
          ..color = colorPata
          ..strokeWidth = 4.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        Offset(w * lx, h * 0.72),
        2.6,
        Paint()..color = const Color(0xFF78350F),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * lx + 1.2, h * 0.88),
          width: 7.5,
          height: 4.0,
        ),
        Paint()..color = const Color(0xFF451A03),
      );
    }

    // Cuerpo robusto con dos jorobas bien definidas y pelaje lanoso en las cimas
    final cuerpo = Path()
      ..moveTo(w * 0.17, h * 0.58)
      ..quadraticBezierTo(w * 0.15, h * 0.36, w * 0.27, h * 0.36)
      ..quadraticBezierTo(w * 0.36, h * 0.11, w * 0.46, h * 0.34)
      ..quadraticBezierTo(w * 0.56, h * 0.13, w * 0.65, h * 0.38)
      ..quadraticBezierTo(w * 0.74, h * 0.52, w * 0.68, h * 0.62)
      ..quadraticBezierTo(w * 0.44, h * 0.67, w * 0.17, h * 0.58)
      ..close();
    canvas.drawPath(
      cuerpo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBBF24), Color(0xFFD97706), Color(0xFFB45309)],
        ).createShader(cuerpo.getBounds()),
    );
    for (final hx in [0.36, 0.56]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * hx, h * 0.23),
          width: w * 0.12,
          height: h * 0.08,
        ),
        Paint()..color = const Color(0xFF92400E).withValues(alpha: 0.65),
      );
    }
    canvas.drawPath(cuerpo, pBorde);

    // Cuello curvado en S característico del camello
    final cuello = Path()
      ..moveTo(w * 0.64, h * 0.50)
      ..quadraticBezierTo(w * 0.77, h * 0.48, w * 0.79, h * 0.24);
    canvas.drawPath(
      cuello,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      cuello,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.4
        ..strokeCap = StrokeCap.round,
    );

    // Cabeza expresiva con hocico alargado, oreja redondeada y pestañas largas
    final rectCabeza = Rect.fromCenter(
      center: Offset(w * 0.83, h * 0.22),
      width: w * 0.24,
      height: h * 0.16,
    );
    canvas.drawOval(rectCabeza, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawOval(rectCabeza, pBorde);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.75, h * 0.13),
        width: 6.0,
        height: 8.5,
      ),
      Paint()..color = const Color(0xFFB45309),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.75, h * 0.13),
        width: 6.0,
        height: 8.5,
      ),
      pBorde,
    );
    canvas.drawCircle(
      Offset(w * 0.82, h * 0.20),
      2.7,
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      Offset(w * 0.814, h * 0.19),
      1.0,
      Paint()..color = Colors.white,
    );
    // Nariz y sonrisa tranquila
    canvas.drawCircle(
      Offset(w * 0.91, h * 0.21),
      1.4,
      Paint()..color = const Color(0xFF451A03),
    );
  }

  void _pintarDelfin(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pBorde = Paint()
      ..color = const Color(0xFF0C4A6E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (!sinFondo) {
      // Olas marinas y espuma donde salta el delfín
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.86),
          width: w * 0.88,
          height: h * 0.18,
        ),
        Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.55),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.88),
          width: w * 0.68,
          height: h * 0.10,
        ),
        Paint()..color = const Color(0xFFE0F2FE),
      );
    }

    // 1. Aleta pectoral trasera (más oscura para dar volumen 3D)
    final aletaTrasera = Path()
      ..moveTo(w * 0.62, h * 0.51)
      ..quadraticBezierTo(w * 0.68, h * 0.66, w * 0.58, h * 0.67)
      ..quadraticBezierTo(w * 0.57, h * 0.58, w * 0.58, h * 0.51)
      ..close();
    canvas.drawPath(aletaTrasera, Paint()..color = const Color(0xFF0369A1));
    canvas.drawPath(aletaTrasera, pBorde);

    // 2. Aleta dorsal falcada (curvada hacia atrás con punta redondeada, nunca triangular)
    final dorsal = Path()
      ..moveTo(w * 0.54, h * 0.25)
      ..cubicTo(w * 0.51, h * 0.08, w * 0.36, h * 0.07, w * 0.34, h * 0.14)
      ..quadraticBezierTo(w * 0.41, h * 0.19, w * 0.40, h * 0.27)
      ..close();
    canvas.drawPath(dorsal, Paint()..color = const Color(0xFF0284C7));
    canvas.drawPath(dorsal, pBorde);

    // 3. Aleta caudal horizontal (dos lóbulos simétricos con escotadura central)
    final cola = Path()
      ..moveTo(w * 0.17, h * 0.64)
      ..cubicTo(w * 0.08, h * 0.52, w * 0.01, h * 0.56, w * 0.04, h * 0.65)
      ..quadraticBezierTo(w * 0.09, h * 0.69, w * 0.12, h * 0.70)
      ..quadraticBezierTo(w * 0.08, h * 0.74, w * 0.05, h * 0.80)
      ..cubicTo(w * 0.04, h * 0.88, w * 0.17, h * 0.83, w * 0.20, h * 0.71)
      ..close();
    canvas.drawPath(cola, Paint()..color = const Color(0xFF0284C7));
    canvas.drawPath(cola, pBorde);

    // 4. Cuerpo arqueado de delfín mular (Tursiops truncatus):
    // Frente abombada redonda (melón) + surco bien marcado + pico redondeado en botella (rostro)
    final cuerpo = Path()
      ..moveTo(w * 0.15, h * 0.66)
      // Dorso arqueado suave y elegante
      ..cubicTo(w * 0.24, h * 0.24, w * 0.52, h * 0.17, w * 0.70, h * 0.27)
      // Frente abombada redonda (melón característico del delfín)
      ..cubicTo(w * 0.79, h * 0.31, w * 0.82, h * 0.37, w * 0.81, h * 0.41)
      // Pico / rostro alargado y redondeado ("pico de botella")
      ..cubicTo(w * 0.91, h * 0.42, w * 0.97, h * 0.45, w * 0.95, h * 0.49)
      ..cubicTo(w * 0.93, h * 0.53, w * 0.84, h * 0.53, w * 0.76, h * 0.52)
      // Garganta, pecho y vientre curvo hasta el pedúnculo caudal
      ..cubicTo(w * 0.64, h * 0.54, w * 0.52, h * 0.49, w * 0.38, h * 0.49)
      ..cubicTo(w * 0.28, h * 0.50, w * 0.22, h * 0.60, w * 0.18, h * 0.71)
      ..close();

    canvas.drawPath(
      cuerpo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        ).createShader(cuerpo.getBounds()),
    );

    // 5. Vientre y garganta blanco-crema nacarado (bicolor clásico del delfín)
    final vientre = Path()
      ..moveTo(w * 0.20, h * 0.67)
      ..cubicTo(w * 0.27, h * 0.46, w * 0.44, h * 0.41, w * 0.62, h * 0.44)
      ..cubicTo(w * 0.73, h * 0.46, w * 0.82, h * 0.46, w * 0.93, h * 0.49)
      ..cubicTo(w * 0.90, h * 0.53, w * 0.82, h * 0.53, w * 0.76, h * 0.52)
      ..cubicTo(w * 0.64, h * 0.54, w * 0.52, h * 0.49, w * 0.38, h * 0.49)
      ..cubicTo(w * 0.28, h * 0.50, w * 0.23, h * 0.59, w * 0.20, h * 0.67)
      ..close();
    canvas.drawPath(vientre, Paint()..color = const Color(0xFFF0F9FF));

    // Brillo especular húmedo en el lomo
    final brilloLomo = Path()
      ..moveTo(w * 0.32, h * 0.33)
      ..quadraticBezierTo(w * 0.50, h * 0.22, w * 0.68, h * 0.30);
    canvas.drawPath(
      brilloLomo,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(cuerpo, pBorde);

    // 6. Aleta pectoral delantera curva
    final aletaDelantera = Path()
      ..moveTo(w * 0.55, h * 0.47)
      ..cubicTo(w * 0.54, h * 0.63, w * 0.44, h * 0.69, w * 0.39, h * 0.64)
      ..quadraticBezierTo(w * 0.43, h * 0.54, w * 0.48, h * 0.46)
      ..close();
    canvas.drawPath(aletaDelantera, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawPath(aletaDelantera, pBorde);

    // 7. Sonrisa amigable en el pico, mejilla rosada y gran ojo expresivo
    final sonrisa = Path()
      ..moveTo(w * 0.94, h * 0.48)
      ..quadraticBezierTo(w * 0.84, h * 0.50, w * 0.76, h * 0.45);
    canvas.drawPath(sonrisa, pBorde);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.74, h * 0.44),
        width: w * 0.06,
        height: h * 0.04,
      ),
      Paint()..color = const Color(0xFFFB7185).withValues(alpha: 0.45),
    );

    // Ojo grande y simpático
    canvas.drawCircle(
      Offset(w * 0.73, h * 0.38),
      3.8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.735, h * 0.38),
      2.5,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(
      Offset(w * 0.725, h * 0.37),
      1.1,
      Paint()..color = Colors.white,
    );

    // 8. Espiráculo en la parte superior de la cabeza con chorrito de agua alegre
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.67, h * 0.27),
        width: w * 0.06,
        height: h * 0.03,
      ),
      0.2,
      math.pi * 0.7,
      false,
      pBorde,
    );
    final pChorro = Paint()
      ..color = const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final chorroIzq = Path()
      ..moveTo(w * 0.67, h * 0.25)
      ..quadraticBezierTo(w * 0.65, h * 0.14, w * 0.59, h * 0.16);
    final chorroDer = Path()
      ..moveTo(w * 0.68, h * 0.25)
      ..quadraticBezierTo(w * 0.71, h * 0.14, w * 0.76, h * 0.16);
    canvas.drawPath(chorroIzq, pChorro);
    canvas.drawPath(chorroDer, pChorro);
    canvas.drawCircle(
      Offset(w * 0.58, h * 0.18),
      1.8,
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawCircle(
      Offset(w * 0.77, h * 0.18),
      1.8,
      Paint()..color = const Color(0xFF38BDF8),
    );
  }

  void _pintarPinguino(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final pBorde = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (!sinFondo) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, h * 0.91),
          width: w * 0.78,
          height: h * 0.14,
        ),
        Paint()..color = const Color(0xFFBAE6FD),
      );
    } else {
      _sombraSuelo(canvas, size, y: 0.91, ancho: 0.56);
    }

    final pNaranja = Paint()..color = const Color(0xFFF97316);
    for (final dx in [-w * 0.14, w * 0.14]) {
      final rPie = Rect.fromCenter(
        center: Offset(cx + dx, h * 0.87),
        width: w * 0.22,
        height: h * 0.11,
      );
      canvas.drawOval(rPie, pNaranja);
      canvas.drawOval(rPie, pBorde);
    }

    for (final (dx, ang) in [(-w * 0.28, 0.28), (w * 0.28, -0.28)]) {
      canvas.save();
      canvas.translate(cx + dx, h * 0.54);
      canvas.rotate(ang);
      final rAla = Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.16,
        height: h * 0.38,
      );
      canvas.drawOval(rAla, Paint()..color = const Color(0xFF1E293B));
      canvas.drawOval(rAla, pBorde);
      canvas.restore();
    }

    final rectCuerpo = Rect.fromCenter(
      center: Offset(cx, h * 0.50),
      width: w * 0.58,
      height: h * 0.76,
    );
    canvas.drawOval(
      rectCuerpo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF334155), Color(0xFF0F172A)],
        ).createShader(rectCuerpo),
    );
    canvas.drawOval(rectCuerpo, pBorde);

    // Manchas auriculares amarillo dorado de pingüino emperador y barriga blanca
    for (final signo in [-1.0, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + signo * w * 0.14, h * 0.34),
          width: w * 0.11,
          height: h * 0.13,
        ),
        Paint()..color = const Color(0xFFFDE047),
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.60),
        width: w * 0.40,
        height: h * 0.48,
      ),
      Paint()..color = Colors.white,
    );

    for (final dx in [-w * 0.10, w * 0.10]) {
      canvas.drawCircle(
        Offset(cx + dx, h * 0.28),
        3.8,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(cx + dx, h * 0.28),
        2.3,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawCircle(
        Offset(cx + dx - 0.8, h * 0.27),
        0.9,
        Paint()..color = Colors.white,
      );
    }

    final pico = Path()
      ..moveTo(cx - w * 0.09, h * 0.33)
      ..lineTo(cx + w * 0.09, h * 0.33)
      ..lineTo(cx, h * 0.43)
      ..close();
    canvas.drawPath(pico, pNaranja);
    canvas.drawPath(pico, pBorde);
  }

  void _pintarOso(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    _sombraSuelo(canvas, size, y: 0.91, ancho: 0.72);

    final pPelajeOscuro = Paint()..color = const Color(0xFF78350F);
    final pPelaje = Paint()..color = const Color(0xFF92400E);
    final pClaro = Paint()..color = const Color(0xFFFDE68A);
    final pBorde = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Patas traseras con almohadillas plantígradas
    for (final signo in [-1.0, 1.0]) {
      final pata = Rect.fromCenter(
        center: Offset(cx + signo * w * 0.26, h * 0.82),
        width: w * 0.20,
        height: h * 0.20,
      );
      canvas.drawOval(pata, pPelajeOscuro);
      canvas.drawOval(pata, pBorde);
      canvas.drawCircle(
        Offset(cx + signo * w * 0.26, h * 0.84),
        w * 0.05,
        pClaro,
      );
    }

    // Cuerpo robusto de oso pardo
    final rectCuerpo = Rect.fromCenter(
      center: Offset(cx, h * 0.68),
      width: w * 0.68,
      height: h * 0.46,
    );
    canvas.drawOval(rectCuerpo, pPelajeOscuro);
    canvas.drawOval(rectCuerpo, pBorde);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.71),
        width: w * 0.38,
        height: h * 0.26,
      ),
      pClaro,
    );

    // Orejas redondas de oso
    for (final dx in [-w * 0.22, w * 0.22]) {
      canvas.drawCircle(Offset(cx + dx, h * 0.21), w * 0.12, pPelajeOscuro);
      canvas.drawCircle(Offset(cx + dx, h * 0.21), w * 0.12, pBorde);
      canvas.drawCircle(Offset(cx + dx, h * 0.21), w * 0.06, pClaro);
    }

    // Cabeza redonda y expresiva
    final rectCabeza = Rect.fromCircle(
      center: Offset(cx, h * 0.39),
      radius: w * 0.27,
    );
    canvas.drawOval(rectCabeza, pPelaje);
    canvas.drawOval(rectCabeza, pBorde);

    // Hocico crema, trufa oscura triangular y sonrisa
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.45),
        width: w * 0.25,
        height: h * 0.19,
      ),
      pClaro,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.41),
        width: w * 0.11,
        height: h * 0.075,
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawLine(Offset(cx, h * 0.44), Offset(cx, h * 0.49), pBorde);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * 0.48),
        width: w * 0.14,
        height: h * 0.06,
      ),
      0.1,
      math.pi - 0.2,
      false,
      pBorde,
    );
    for (final dx in [-w * 0.11, w * 0.11]) {
      canvas.drawCircle(
        Offset(cx + dx, h * 0.34),
        3.2,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        Offset(cx + dx - 0.9, h * 0.33),
        1.1,
        Paint()..color = Colors.white,
      );
    }
  }

  void _pintarPulpo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final pTentaculoBorde = Paint()
      ..color = const Color(0xFF701A75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.4
      ..strokeCap = StrokeCap.round;
    final pTentaculo = Paint()
      ..color = const Color(0xFFC026D3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.2
      ..strokeCap = StrokeCap.round;
    final pVentosa = Paint()..color = const Color(0xFFF5D0FE);

    final tentaculos = [
      (
        Offset(cx - 10, h * 0.50),
        Offset(w * 0.10, h * 0.62),
        Offset(w * 0.08, h * 0.80),
      ),
      (
        Offset(cx - 7, h * 0.54),
        Offset(w * 0.22, h * 0.78),
        Offset(w * 0.18, h * 0.92),
      ),
      (
        Offset(cx - 3, h * 0.56),
        Offset(w * 0.36, h * 0.84),
        Offset(w * 0.34, h * 0.95),
      ),
      (
        Offset(cx - 1, h * 0.56),
        Offset(w * 0.46, h * 0.82),
        Offset(w * 0.45, h * 0.94),
      ),
      (
        Offset(cx + 1, h * 0.56),
        Offset(w * 0.54, h * 0.82),
        Offset(w * 0.55, h * 0.94),
      ),
      (
        Offset(cx + 3, h * 0.56),
        Offset(w * 0.64, h * 0.84),
        Offset(w * 0.66, h * 0.95),
      ),
      (
        Offset(cx + 7, h * 0.54),
        Offset(w * 0.78, h * 0.78),
        Offset(w * 0.82, h * 0.92),
      ),
      (
        Offset(cx + 10, h * 0.50),
        Offset(w * 0.90, h * 0.62),
        Offset(w * 0.92, h * 0.80),
      ),
    ];

    for (final t in tentaculos) {
      final path = Path()
        ..moveTo(t.$1.dx, t.$1.dy)
        ..quadraticBezierTo(t.$2.dx, t.$2.dy, t.$3.dx, t.$3.dy);
      canvas.drawPath(path, pTentaculoBorde);
      canvas.drawPath(path, pTentaculo);
      canvas.drawCircle(
        Offset((t.$2.dx + t.$3.dx) / 2, (t.$2.dy + t.$3.dy) / 2),
        1.8,
        pVentosa,
      );
    }

    final manto = Rect.fromCenter(
      center: Offset(cx, h * 0.34),
      width: w * 0.54,
      height: h * 0.48,
    );
    canvas.drawOval(
      manto,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE879F9), Color(0xFFA21CAF)],
        ).createShader(manto),
    );
    canvas.drawOval(
      manto,
      Paint()
        ..color = const Color(0xFF701A75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    for (final dx in [-7.0, 7.0]) {
      canvas.drawCircle(
        Offset(cx + dx, h * 0.38),
        4.5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(cx + dx, h * 0.38),
        2.3,
        Paint()..color = const Color(0xFF1E1B4B),
      );
      canvas.drawCircle(
        Offset(cx + dx - 0.8, h * 0.37),
        0.9,
        Paint()..color = Colors.white,
      );
    }
  }

  void _pintarMariposa(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.52;
    final pBorde = Paint()
      ..color = const Color(0xFF431407)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (final s in [-1.0, 1.0]) {
      final alaSup = Path()
        ..moveTo(cx, cy - h * 0.06)
        ..cubicTo(
          cx + s * w * 0.42,
          h * 0.04,
          cx + s * w * 0.48,
          h * 0.48,
          cx,
          cy + h * 0.04,
        )
        ..close();
      canvas.drawPath(
        alaSup,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFFACC15)],
          ).createShader(alaSup.getBounds()),
      );
      canvas.drawPath(alaSup, pBorde);
      canvas.drawCircle(
        Offset(cx + s * w * 0.24, h * 0.32),
        w * 0.055,
        Paint()..color = const Color(0xFFFEF08A),
      );

      final alaInf = Path()
        ..moveTo(cx, cy + h * 0.02)
        ..cubicTo(
          cx + s * w * 0.38,
          h * 0.50,
          cx + s * w * 0.32,
          h * 0.88,
          cx,
          cy + h * 0.24,
        )
        ..close();
      canvas.drawPath(alaInf, Paint()..color = const Color(0xFFFB923C));
      canvas.drawPath(alaInf, pBorde);
    }

    // Cuerpo y antenas en espiral
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + h * 0.05),
          width: w * 0.09,
          height: h * 0.46,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawCircle(
      Offset(cx, h * 0.26),
      w * 0.06,
      Paint()..color = const Color(0xFF1E293B),
    );
    for (final s in [-1.0, 1.0]) {
      final antena = Path()
        ..moveTo(cx, h * 0.23)
        ..quadraticBezierTo(
          cx + s * w * 0.14,
          h * 0.08,
          cx + s * w * 0.18,
          h * 0.14,
        );
      canvas.drawPath(antena, pBorde);
    }
  }

  void _pintarRenacuajo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * 0.52;
    final pBorde = Paint()
      ..color = const Color(0xFF14532D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Aleta caudal translúcida para nadar
    final aleta = Path()
      ..moveTo(w * 0.44, cy - h * 0.18)
      ..quadraticBezierTo(w * 0.14, cy - h * 0.24, w * 0.06, cy)
      ..quadraticBezierTo(w * 0.14, cy + h * 0.24, w * 0.44, cy + h * 0.18)
      ..close();
    canvas.drawPath(
      aleta,
      Paint()..color = const Color(0xFF86EFAC).withValues(alpha: 0.65),
    );
    canvas.drawPath(aleta, pBorde);

    // Cabeza/cuerpo globular verde oliva con branquias externas y ojo vivo
    final cuerpo = Rect.fromCenter(
      center: Offset(w * 0.62, cy),
      width: w * 0.46,
      height: h * 0.42,
    );
    canvas.drawOval(
      cuerpo,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF4ADE80), Color(0xFF15803D)],
        ).createShader(cuerpo),
    );
    canvas.drawOval(cuerpo, pBorde);
    canvas.drawCircle(
      Offset(w * 0.72, cy - h * 0.05),
      4.0,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.73, cy - h * 0.05),
      2.1,
      Paint()..color = const Color(0xFF0F172A),
    );
  }

  void _pintarHuevo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final pBorde = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    // Nido de ramitas entrelazadas
    final nido = Rect.fromCenter(
      center: Offset(cx, h * 0.78),
      width: w * 0.80,
      height: h * 0.26,
    );
    canvas.drawOval(nido, Paint()..color = const Color(0xFF92400E));
    canvas.drawOval(nido, pBorde);

    // Huevo abriéndose con polluelo asomando
    final huevo = Path()
      ..moveTo(cx - w * 0.24, h * 0.72)
      ..quadraticBezierTo(cx - w * 0.26, h * 0.18, cx, h * 0.16)
      ..quadraticBezierTo(cx + w * 0.26, h * 0.18, cx + w * 0.24, h * 0.72)
      ..close();
    canvas.drawPath(huevo, Paint()..color = const Color(0xFFFEF9C3));
    canvas.drawPath(huevo, pBorde);

    // Grieta en zigzag
    final grieta = Path()
      ..moveTo(cx - w * 0.22, h * 0.48)
      ..lineTo(cx - w * 0.08, h * 0.42)
      ..lineTo(cx + w * 0.02, h * 0.50)
      ..lineTo(cx + w * 0.12, h * 0.41)
      ..lineTo(cx + w * 0.22, h * 0.47);
    canvas.drawPath(grieta, pBorde);
  }

  void _pintarAguila(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final pBorde = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Cola en abanico marrón con banda clara
    final cola = Path()
      ..moveTo(cx - w * 0.10, h * 0.68)
      ..lineTo(cx - w * 0.22, h * 0.90)
      ..quadraticBezierTo(cx, h * 0.95, cx + w * 0.22, h * 0.90)
      ..lineTo(cx + w * 0.10, h * 0.68)
      ..close();
    canvas.drawPath(cola, Paint()..color = const Color(0xFF78350F));
    canvas.drawPath(cola, pBorde);

    // Alas desplegadas majestuosas con rémiges primarias marcadas
    for (final s in [-1.0, 1.0]) {
      final ala = Path()
        ..moveTo(cx, h * 0.44)
        ..cubicTo(
          cx + s * w * 0.28,
          h * 0.14,
          cx + s * w * 0.48,
          h * 0.18,
          cx + s * w * 0.49,
          h * 0.36,
        )
        ..lineTo(cx + s * w * 0.43, h * 0.42)
        ..lineTo(cx + s * w * 0.46, h * 0.48)
        ..quadraticBezierTo(cx + s * w * 0.28, h * 0.60, cx, h * 0.58)
        ..close();
      canvas.drawPath(
        ala,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF92400E), Color(0xFF78350F)],
          ).createShader(ala.getBounds()),
      );
      canvas.drawPath(ala, pBorde);
    }

    // Cuerpo robusto, garras amarillas y cabeza blanca/dorada con pico ganchudo
    final cuerpo = Rect.fromCenter(
      center: Offset(cx, h * 0.56),
      width: w * 0.30,
      height: h * 0.36,
    );
    canvas.drawOval(cuerpo, Paint()..color = const Color(0xFF92400E));
    canvas.drawOval(cuerpo, pBorde);

    // Garras prensiles amarillas
    for (final s in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(cx + s * w * 0.08, h * 0.74),
        3.2,
        Paint()..color = const Color(0xFFF59E0B),
      );
      canvas.drawCircle(Offset(cx + s * w * 0.08, h * 0.74), 3.2, pBorde);
    }

    // Capucha blanca-dorada del águila
    final cabeza = Path()
      ..moveTo(cx - w * 0.14, h * 0.40)
      ..quadraticBezierTo(cx - w * 0.16, h * 0.18, cx, h * 0.18)
      ..quadraticBezierTo(cx + w * 0.16, h * 0.18, cx + w * 0.14, h * 0.40)
      ..lineTo(cx + w * 0.08, h * 0.44)
      ..lineTo(cx, h * 0.41)
      ..lineTo(cx - w * 0.08, h * 0.44)
      ..close();
    canvas.drawPath(cabeza, Paint()..color = const Color(0xFFFEF3C7));
    canvas.drawPath(cabeza, pBorde);

    // Pico rapaz curvado amarillo intenso
    final pico = Path()
      ..moveTo(cx - w * 0.05, h * 0.33)
      ..quadraticBezierTo(cx + w * 0.06, h * 0.33, cx + w * 0.05, h * 0.40)
      ..lineTo(cx + w * 0.01, h * 0.46)
      ..quadraticBezierTo(cx - w * 0.04, h * 0.41, cx - w * 0.05, h * 0.33)
      ..close();
    canvas.drawPath(pico, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawPath(pico, pBorde);

    // Ojos penetrantes con ceja rapaz
    for (final s in [-1.0, 1.0]) {
      canvas.drawCircle(
        Offset(cx + s * w * 0.065, h * 0.30),
        2.5,
        Paint()..color = const Color(0xFF0F172A),
      );
      canvas.drawLine(
        Offset(cx + s * w * 0.02, h * 0.27),
        Offset(cx + s * w * 0.11, h * 0.26),
        pBorde,
      );
    }
  }

  void _pintarSerpiente(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _sombraSuelo(canvas, size, y: 0.88, ancho: 0.76);
    final pBorde = Paint()
      ..color = const Color(0xFF14532D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final serpentina = Path()
      ..moveTo(w * 0.12, h * 0.78)
      ..cubicTo(w * 0.28, h * 0.88, w * 0.32, h * 0.52, w * 0.52, h * 0.64)
      ..cubicTo(w * 0.72, h * 0.74, w * 0.60, h * 0.34, w * 0.76, h * 0.30);
    canvas.drawPath(
      serpentina,
      Paint()
        ..color = const Color(0xFF14532D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 13.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      serpentina,
      Paint()
        ..color = const Color(0xFF22C55E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.2
        ..strokeCap = StrokeCap.round,
    );
    // Vientre escamado amarillo verdoso claro
    canvas.drawPath(
      serpentina,
      Paint()
        ..color = const Color(0xFFBEF264)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    // Cabeza diferenciada y lengua bífida roja
    final cabeza = Rect.fromCenter(
      center: Offset(w * 0.78, h * 0.29),
      width: w * 0.22,
      height: h * 0.16,
    );
    canvas.drawOval(cabeza, Paint()..color = const Color(0xFF16A34A));
    canvas.drawOval(cabeza, pBorde);
    canvas.drawCircle(
      Offset(w * 0.80, h * 0.27),
      3.2,
      Paint()..color = const Color(0xFFFACC15),
    );
    canvas.drawCircle(
      Offset(w * 0.805, h * 0.27),
      1.8,
      Paint()..color = const Color(0xFF0F172A),
    );
    final lengua = Path()
      ..moveTo(w * 0.89, h * 0.30)
      ..lineTo(w * 0.95, h * 0.30)
      ..lineTo(w * 0.98, h * 0.27)
      ..moveTo(w * 0.95, h * 0.30)
      ..lineTo(w * 0.98, h * 0.33);
    canvas.drawPath(
      lengua,
      Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _pintarRaton(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _sombraSuelo(canvas, size, y: 0.88, ancho: 0.66);
    final pBorde = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Cola larga rosada curvada
    final cola = Path()
      ..moveTo(w * 0.24, h * 0.68)
      ..cubicTo(w * 0.04, h * 0.68, w * 0.04, h * 0.42, w * 0.16, h * 0.38);
    canvas.drawPath(
      cola,
      Paint()
        ..color = const Color(0xFFF472B6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    // Oreja trasera
    canvas.drawCircle(
      Offset(w * 0.56, h * 0.38),
      w * 0.11,
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.drawCircle(Offset(w * 0.56, h * 0.38), w * 0.11, pBorde);

    // Cuerpo redondeado de ratón de campo con hocico afilado y patitas rosadas
    final cuerpo = Path()
      ..moveTo(w * 0.24, h * 0.72)
      ..cubicTo(w * 0.20, h * 0.44, w * 0.52, h * 0.40, w * 0.68, h * 0.48)
      ..quadraticBezierTo(w * 0.84, h * 0.55, w * 0.88, h * 0.64)
      ..quadraticBezierTo(w * 0.76, h * 0.76, w * 0.58, h * 0.76)
      ..lineTo(w * 0.30, h * 0.76)
      ..close();
    canvas.drawPath(cuerpo, Paint()..color = const Color(0xFF94A3B8));
    // Barriguita gris perla
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.70),
        width: w * 0.36,
        height: h * 0.12,
      ),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    canvas.drawPath(cuerpo, pBorde);

    // Patitas rosadas
    for (final px in [0.34, 0.64]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * px, h * 0.79),
          width: w * 0.12,
          height: h * 0.07,
        ),
        Paint()..color = const Color(0xFFF9A8D4),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * px, h * 0.79),
          width: w * 0.12,
          height: h * 0.07,
        ),
        pBorde,
      );
    }

    // Gran oreja delantera redonda con interior rosado
    canvas.drawCircle(
      Offset(w * 0.64, h * 0.42),
      w * 0.125,
      Paint()..color = const Color(0xFF94A3B8),
    );
    canvas.drawCircle(Offset(w * 0.64, h * 0.42), w * 0.125, pBorde);
    canvas.drawCircle(
      Offset(w * 0.64, h * 0.42),
      w * 0.078,
      Paint()..color = const Color(0xFFF9A8D4),
    );

    // Ojo negro brillante, bigotes y naricita rosada
    canvas.drawCircle(
      Offset(w * 0.75, h * 0.56),
      3.0,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(
      Offset(w * 0.74, h * 0.55),
      1.0,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.88, h * 0.63),
      3.4,
      Paint()..color = const Color(0xFFF43F5E),
    );
    canvas.drawLine(
      Offset(w * 0.80, h * 0.64),
      Offset(w * 0.72, h * 0.62),
      pBorde,
    );
    canvas.drawLine(
      Offset(w * 0.80, h * 0.66),
      Offset(w * 0.72, h * 0.68),
      pBorde,
    );
  }

  void _pintarZorro(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    _sombraSuelo(canvas, size, y: 0.90, ancho: 0.76);
    final pBorde = Paint()
      ..color = const Color(0xFF431407)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 1. Gran cola tupida de zorro rojo (Vulpes vulpes) erguida con punta blanca en zigzag
    final cola = Path()
      ..moveTo(w * 0.28, h * 0.64)
      ..cubicTo(w * 0.08, h * 0.64, w * 0.01, h * 0.36, w * 0.11, h * 0.22)
      ..cubicTo(w * 0.19, h * 0.14, w * 0.30, h * 0.28, w * 0.33, h * 0.54)
      ..close();
    canvas.drawPath(
      cola,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
        ).createShader(cola.getBounds()),
    );
    // Punta blanca esponjosa característica de la cola del zorro
    final puntaBlancaCola = Path()
      ..moveTo(w * 0.05, h * 0.37)
      ..cubicTo(w * 0.04, h * 0.26, w * 0.08, h * 0.19, w * 0.13, h * 0.21)
      ..quadraticBezierTo(w * 0.21, h * 0.24, w * 0.23, h * 0.35)
      ..lineTo(w * 0.17, h * 0.33)
      ..lineTo(w * 0.14, h * 0.39)
      ..lineTo(w * 0.10, h * 0.34)
      ..close();
    canvas.drawPath(puntaBlancaCola, Paint()..color = const Color(0xFFFFFBEB));
    canvas.drawPath(cola, pBorde);

    // 2. Cuatro patas esbeltas con "calcetines" oscuros (negro-marrón) en los pies
    void pintarPataZorro(double xBase, double yTop, bool trasera) {
      final colorSup = trasera
          ? const Color(0xFFC2410C)
          : const Color(0xFFEA580C);
      final pata = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * xBase - 4.0, h * yTop, 8.0, h * (0.88 - yTop)),
        const Radius.circular(4),
      );
      canvas.drawRRect(pata, Paint()..color = colorSup);
      // Calcetín oscuro inferior típico del zorro rojo
      final calcetin = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * xBase - 4.0, h * 0.75, 8.0, h * 0.13),
        const Radius.circular(4),
      );
      canvas.drawRRect(calcetin, Paint()..color = const Color(0xFF271206));
      canvas.drawRRect(pata, pBorde);
    }

    pintarPataZorro(0.32, 0.64, true);
    pintarPataZorro(0.54, 0.64, true);
    pintarPataZorro(0.39, 0.64, false);
    pintarPataZorro(0.62, 0.64, false);

    // 3. Cuerpo ágil y estilizado naranja rojizo con vientre y pechera crema-blanca
    final cuerpo = Path()
      ..moveTo(w * 0.26, h * 0.60)
      ..cubicTo(w * 0.26, h * 0.45, w * 0.54, h * 0.44, w * 0.67, h * 0.48)
      ..quadraticBezierTo(w * 0.72, h * 0.62, w * 0.62, h * 0.70)
      ..quadraticBezierTo(w * 0.45, h * 0.72, w * 0.28, h * 0.68)
      ..close();
    canvas.drawPath(
      cuerpo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        ).createShader(cuerpo.getBounds()),
    );

    // Pechera y vientre blanco-crema esponjoso
    final pechera = Path()
      ..moveTo(w * 0.58, h * 0.48)
      ..quadraticBezierTo(w * 0.72, h * 0.56, w * 0.64, h * 0.69)
      ..quadraticBezierTo(w * 0.48, h * 0.71, w * 0.36, h * 0.67)
      ..quadraticBezierTo(w * 0.50, h * 0.62, w * 0.58, h * 0.48)
      ..close();
    canvas.drawPath(pechera, Paint()..color = const Color(0xFFFFFBEB));
    canvas.drawPath(cuerpo, pBorde);

    // 4. Orejas puntiagudas grandes con puntas oscuras y pelaje interior crema
    for (final (ox, oy, esTrasera) in [
      (0.58, 0.28, true),
      (0.68, 0.29, false),
    ]) {
      final oreja = Path()
        ..moveTo(w * (ox - 0.05), h * oy)
        ..quadraticBezierTo(
          w * (ox - 0.02),
          h * 0.09,
          w * (ox + 0.04),
          h * 0.11,
        )
        ..quadraticBezierTo(
          w * (ox + 0.09),
          h * 0.20,
          w * (ox + 0.06),
          h * (oy + 0.03),
        )
        ..close();
      canvas.drawPath(
        oreja,
        Paint()
          ..color = esTrasera
              ? const Color(0xFFC2410C)
              : const Color(0xFFEA580C),
      );
      // Punta negra de la oreja
      final punta = Path()
        ..moveTo(w * (ox - 0.01), h * 0.17)
        ..quadraticBezierTo(
          w * (ox + 0.01),
          h * 0.10,
          w * (ox + 0.04),
          h * 0.11,
        )
        ..quadraticBezierTo(
          w * (ox + 0.06),
          h * 0.15,
          w * (ox + 0.05),
          h * 0.18,
        )
        ..close();
      canvas.drawPath(punta, Paint()..color = const Color(0xFF271206));
      if (!esTrasera) {
        final interior = Path()
          ..moveTo(w * (ox - 0.02), h * (oy - 0.01))
          ..quadraticBezierTo(
            w * (ox + 0.02),
            h * 0.16,
            w * (ox + 0.04),
            h * (oy + 0.01),
          )
          ..close();
        canvas.drawPath(interior, Paint()..color = const Color(0xFFFFFBEB));
      }
      canvas.drawPath(oreja, pBorde);
    }

    // 5. Cabeza esculpida de zorro con hocico alargado fino y mejillas blancas
    final cabeza = Path()
      ..moveTo(w * 0.54, h * 0.38)
      ..cubicTo(w * 0.54, h * 0.24, w * 0.75, h * 0.23, w * 0.81, h * 0.35)
      // Hocico fino proyectado hacia la derecha
      ..quadraticBezierTo(w * 0.90, h * 0.39, w * 0.95, h * 0.43)
      ..quadraticBezierTo(w * 0.94, h * 0.50, w * 0.82, h * 0.51)
      // Mejilla peluda con patilla lateral
      ..lineTo(w * 0.68, h * 0.55)
      ..lineTo(w * 0.53, h * 0.49)
      ..close();
    canvas.drawPath(cabeza, Paint()..color = const Color(0xFFF97316));

    // Máscara blanca de las mejillas y mandíbula inferior del zorro
    final mejillaBlanca = Path()
      ..moveTo(w * 0.55, h * 0.46)
      ..quadraticBezierTo(w * 0.67, h * 0.41, w * 0.77, h * 0.43)
      ..lineTo(w * 0.94, h * 0.45)
      ..quadraticBezierTo(w * 0.92, h * 0.50, w * 0.82, h * 0.51)
      ..lineTo(w * 0.68, h * 0.55)
      ..lineTo(w * 0.54, h * 0.49)
      ..close();
    canvas.drawPath(mejillaBlanca, Paint()..color = const Color(0xFFFFFBEB));
    canvas.drawPath(cabeza, pBorde);

    // 6. Ojo expresivo ámbar/oscuro con brillo, trufa negra brillante y sonrisa
    canvas.drawCircle(
      Offset(w * 0.75, h * 0.37),
      3.6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(w * 0.755, h * 0.37),
      2.3,
      Paint()..color = const Color(0xFF271206),
    );
    canvas.drawCircle(
      Offset(w * 0.745, h * 0.36),
      0.9,
      Paint()..color = Colors.white,
    );

    // Trufa negra en la punta del hocico
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.94, h * 0.43),
        width: 6.2,
        height: 4.8,
      ),
      Paint()..color = const Color(0xFF1E1B4B),
    );
    canvas.drawCircle(
      Offset(w * 0.935, h * 0.42),
      1.0,
      Paint()..color = Colors.white,
    );

    // Sonrisa astuta y amigable
    final sonrisa = Path()
      ..moveTo(w * 0.89, h * 0.47)
      ..quadraticBezierTo(w * 0.82, h * 0.49, w * 0.77, h * 0.45);
    canvas.drawPath(sonrisa, pBorde);
  }

  void _pintarConejo(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    _sombraSuelo(canvas, size, y: 0.89, ancho: 0.62);
    final pBorde = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Orejas largas erguidas con interior rosado suave
    for (final (dx, rot) in [(-0.04, -0.15), (0.08, 0.08)]) {
      canvas.save();
      canvas.translate(cx + w * dx, h * 0.25);
      canvas.rotate(rot);
      final oreja = Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.13,
        height: h * 0.34,
      );
      canvas.drawOval(oreja, Paint()..color = const Color(0xFFF8FAFC));
      canvas.drawOval(oreja, pBorde);
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(0, 2),
          width: w * 0.065,
          height: h * 0.22,
        ),
        Paint()..color = const Color(0xFFF9A8D4),
      );
      canvas.restore();
    }

    // Rabito algodón esponjoso detrás
    canvas.drawCircle(
      Offset(cx - w * 0.25, h * 0.70),
      w * 0.09,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(cx - w * 0.25, h * 0.70), w * 0.09, pBorde);

    // Cuerpo regordete y patas traseras fuertes para saltar
    final cuerpo = Rect.fromCenter(
      center: Offset(cx - w * 0.02, h * 0.66),
      width: w * 0.46,
      height: h * 0.36,
    );
    canvas.drawOval(cuerpo, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawOval(cuerpo, pBorde);

    // Pata trasera de salto y patita delantera
    final pataTrasera = Rect.fromCenter(
      center: Offset(cx - w * 0.08, h * 0.81),
      width: w * 0.22,
      height: h * 0.11,
    );
    canvas.drawOval(pataTrasera, Paint()..color = Colors.white);
    canvas.drawOval(pataTrasera, pBorde);
    final pataDelantera = Rect.fromCenter(
      center: Offset(cx + w * 0.14, h * 0.81),
      width: w * 0.12,
      height: h * 0.10,
    );
    canvas.drawOval(pataDelantera, Paint()..color = Colors.white);
    canvas.drawOval(pataDelantera, pBorde);

    // Cabeza con mofletes esponjosos, ojo vivo, bigotes y nariz rosada
    final cabeza = Rect.fromCenter(
      center: Offset(cx + w * 0.10, h * 0.48),
      width: w * 0.34,
      height: h * 0.29,
    );
    canvas.drawOval(cabeza, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawOval(cabeza, pBorde);
    canvas.drawCircle(
      Offset(cx + w * 0.15, h * 0.45),
      3.0,
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawCircle(
      Offset(cx + w * 0.14, h * 0.44),
      1.0,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx + w * 0.25, h * 0.49),
      3.0,
      Paint()..color = const Color(0xFFF43F5E),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + w * 0.16, h * 0.52),
        width: w * 0.08,
        height: h * 0.045,
      ),
      Paint()..color = const Color(0xFFF9A8D4).withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant PintorAnimalDetallado oldDelegate) =>
      oldDelegate.id != id || oldDelegate.sinFondo != sinFondo;
}

class PintorFichaEspecial extends CustomPainter {
  const PintorFichaEspecial({required this.id, required this.color});

  final String id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final pBorde = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (id) {
      case 'huerto':
        // Surcos de tierra fértil con zanahoria y brotes verdes
        final tierra = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, h * 0.58, w * 0.84, h * 0.32),
          const Radius.circular(8),
        );
        canvas.drawRRect(tierra, Paint()..color = const Color(0xFF92400E));
        canvas.drawRRect(tierra, pBorde);
        final zanahoria = Path()
          ..moveTo(cx - w * 0.14, h * 0.58)
          ..lineTo(cx + w * 0.14, h * 0.58)
          ..lineTo(cx, h * 0.84)
          ..close();
        canvas.drawPath(zanahoria, Paint()..color = const Color(0xFFF97316));
        canvas.drawPath(zanahoria, pBorde);
        for (final dx in [-w * 0.10, 0.0, w * 0.10]) {
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(cx + dx, h * 0.38),
              width: w * 0.14,
              height: h * 0.28,
            ),
            Paint()..color = const Color(0xFF22C55E),
          );
        }
      case 'fotosintesis':
        // Sol radiante iluminando una hoja verde con burbujas de oxígeno
        canvas.drawCircle(
          Offset(w * 0.28, h * 0.28),
          w * 0.16,
          Paint()..color = const Color(0xFFFACC15),
        );
        final hoja = Path()
          ..moveTo(w * 0.28, h * 0.78)
          ..quadraticBezierTo(w * 0.42, h * 0.34, w * 0.84, h * 0.38)
          ..quadraticBezierTo(w * 0.72, h * 0.84, w * 0.28, h * 0.78);
        canvas.drawPath(hoja, Paint()..color = const Color(0xFF16A34A));
        canvas.drawPath(hoja, pBorde);
        canvas.drawCircle(
          Offset(w * 0.74, h * 0.22),
          w * 0.08,
          Paint()..color = const Color(0xFF38BDF8),
        );
      case 'higiene':
        // Pastilla de jabón rosada y burbujas cristalinas
        final jabon = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + h * 0.12),
            width: w * 0.62,
            height: h * 0.36,
          ),
          const Radius.circular(10),
        );
        canvas.drawRRect(jabon, Paint()..color = const Color(0xFFF472B6));
        canvas.drawRRect(jabon, pBorde);
        for (final (bx, by, r) in [
          (w * 0.28, h * 0.28, w * 0.12),
          (w * 0.66, h * 0.24, w * 0.15),
          (w * 0.48, h * 0.40, w * 0.09),
        ]) {
          canvas.drawCircle(
            Offset(bx, by),
            r,
            Paint()..color = const Color(0xFFBAE6FD),
          );
          canvas.drawCircle(
            Offset(bx, by),
            r,
            Paint()
              ..color = const Color(0xFF0284C7)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5,
          );
        }
      case 'descanso':
        // Luna creciente dorada con estrellas de sueño reparador
        final luna = Path()
          ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.34));
        final recorte = Path()
          ..addOval(
            Rect.fromCircle(
              center: Offset(cx + w * 0.14, cy - h * 0.08),
              radius: w * 0.28,
            ),
          );
        final creciente = Path.combine(PathOperation.difference, luna, recorte);
        canvas.drawPath(creciente, Paint()..color = const Color(0xFFFACC15));
        canvas.drawPath(creciente, pBorde);
        canvas.drawCircle(
          Offset(w * 0.72, h * 0.28),
          3.2,
          Paint()..color = const Color(0xFF6366F1),
        );
        canvas.drawCircle(
          Offset(w * 0.78, h * 0.52),
          2.4,
          Paint()..color = const Color(0xFF818CF8),
        );
      default:
        // Escudo protector de los sentidos con destello
        final escudo = Path()
          ..moveTo(cx, h * 0.12)
          ..lineTo(w * 0.82, h * 0.26)
          ..quadraticBezierTo(w * 0.80, h * 0.68, cx, h * 0.88)
          ..quadraticBezierTo(w * 0.20, h * 0.68, w * 0.18, h * 0.26)
          ..close();
        canvas.drawPath(escudo, Paint()..color = color.withValues(alpha: 0.25));
        canvas.drawPath(escudo, pBorde);
        canvas.drawCircle(Offset(cx, cy), w * 0.15, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant PintorFichaEspecial oldDelegate) =>
      oldDelegate.id != id || oldDelegate.color != color;
}

class PintorHabitoCartoon extends CustomPainter {
  const PintorHabitoCartoon({required this.id, required this.color});

  final String id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final pBorde = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Halo suave de fondo
    canvas.drawCircle(
      Offset(cx, cy),
      w * 0.42,
      Paint()..color = color.withValues(alpha: 0.14),
    );

    switch (id) {
      case 'lavar-manos':
      case 'ducha-diaria':
        // Grifo con chorro de agua, pastilla de jabón rosa y pompas de espuma
        final grifo = Path()
          ..moveTo(w * 0.18, h * 0.20)
          ..lineTo(w * 0.48, h * 0.20)
          ..quadraticBezierTo(w * 0.56, h * 0.20, w * 0.56, h * 0.30);
        canvas.drawPath(
          grifo,
          Paint()
            ..color = const Color(0xFF64748B)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.5
            ..strokeCap = StrokeCap.round,
        );
        // Gotas de agua limpia
        for (final dy in [0.38, 0.49]) {
          canvas.drawCircle(
            Offset(w * 0.56, h * dy),
            3.2,
            Paint()..color = const Color(0xFF38BDF8),
          );
        }
        final jabon = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.68),
            width: w * 0.52,
            height: h * 0.26,
          ),
          const Radius.circular(10),
        );
        canvas.drawRRect(jabon, Paint()..color = const Color(0xFFF472B6));
        canvas.drawRRect(jabon, pBorde);
        for (final (bx, by, r) in [
          (w * 0.28, h * 0.46, w * 0.10),
          (w * 0.72, h * 0.42, w * 0.11),
          (w * 0.42, h * 0.52, w * 0.08),
        ]) {
          canvas.drawCircle(
            Offset(bx, by),
            r,
            Paint()..color = const Color(0xFFE0F2FE),
          );
          canvas.drawCircle(Offset(bx, by), r, pBorde);
        }
      case 'no-lavarse':
        // Mano manchada de barro con motas oscuras
        canvas.drawCircle(
          Offset(cx, cy + h * 0.06),
          w * 0.22,
          Paint()..color = const Color(0xFFFDBA74),
        );
        canvas.drawCircle(Offset(cx, cy + h * 0.06), w * 0.22, pBorde);
        for (final (dx, dy) in [
          (-0.12, -0.18),
          (-0.04, -0.24),
          (0.05, -0.24),
          (0.13, -0.17),
        ]) {
          canvas.drawLine(
            Offset(cx + w * dx, cy),
            Offset(cx + w * dx, cy + h * dy),
            Paint()
              ..color = const Color(0xFFFDBA74)
              ..strokeWidth = 6.0
              ..strokeCap = StrokeCap.round,
          );
        }
        canvas.drawCircle(
          Offset(cx - w * 0.05, cy + h * 0.05),
          w * 0.09,
          Paint()..color = const Color(0xFF78350F),
        );
        canvas.drawCircle(
          Offset(cx + w * 0.08, cy + h * 0.12),
          w * 0.06,
          Paint()..color = const Color(0xFF65A30D),
        );
      case 'cepillar-dientes':
        // Muela blanca reluciente con raíces y cepillo con pasta turquesa
        final muela = Path()
          ..moveTo(w * 0.24, h * 0.42)
          ..quadraticBezierTo(w * 0.24, h * 0.28, w * 0.36, h * 0.30)
          ..quadraticBezierTo(w * 0.44, h * 0.32, w * 0.52, h * 0.30)
          ..quadraticBezierTo(w * 0.64, h * 0.28, w * 0.64, h * 0.42)
          ..lineTo(w * 0.60, h * 0.76)
          ..lineTo(w * 0.50, h * 0.62)
          ..lineTo(w * 0.44, h * 0.62)
          ..lineTo(w * 0.34, h * 0.76)
          ..close();
        canvas.drawPath(muela, Paint()..color = Colors.white);
        canvas.drawPath(muela, pBorde);
        canvas.drawLine(
          Offset(w * 0.20, h * 0.22),
          Offset(w * 0.84, h * 0.22),
          Paint()
            ..color = const Color(0xFF0D9488)
            ..strokeWidth = 5.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.36, h * 0.15),
            width: w * 0.22,
            height: h * 0.11,
          ),
          Paint()..color = const Color(0xFF38BDF8),
        );
      case 'solo-chuches':
      case 'refresco-azucar':
        // Piruleta en espiral y caramelo envuelto azucarado
        canvas.drawLine(
          Offset(cx - w * 0.06, cy),
          Offset(cx - w * 0.06, h * 0.86),
          Paint()
            ..color = const Color(0xFFFEF3C7)
            ..strokeWidth = 4.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          Offset(cx - w * 0.06, h * 0.38),
          w * 0.22,
          Paint()..color = const Color(0xFFFB7185),
        );
        canvas.drawCircle(Offset(cx - w * 0.06, h * 0.38), w * 0.22, pBorde);
        canvas.drawCircle(
          Offset(cx - w * 0.06, h * 0.38),
          w * 0.11,
          Paint()..color = const Color(0xFFFEF08A),
        );
        // Caramelo envuelto al lado
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.70, h * 0.66),
            width: w * 0.24,
            height: h * 0.16,
          ),
          Paint()..color = const Color(0xFFA855F7),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.70, h * 0.66),
            width: w * 0.24,
            height: h * 0.16,
          ),
          pBorde,
        );
      case 'beber-agua':
      case 'fruta-agua':
        // Vaso cristalino con agua fresca azul y gota brillante arriba
        final vaso = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.58),
            width: w * 0.42,
            height: h * 0.48,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(vaso, Paint()..color = const Color(0xFFE0F2FE));
        final agua = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.64),
            width: w * 0.38,
            height: h * 0.34,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(agua, Paint()..color = const Color(0xFF38BDF8));
        canvas.drawRRect(vaso, pBorde);
        final gota = Path()
          ..moveTo(cx, h * 0.14)
          ..quadraticBezierTo(cx + w * 0.10, h * 0.24, cx, h * 0.30)
          ..quadraticBezierTo(cx - w * 0.10, h * 0.24, cx, h * 0.14)
          ..close();
        canvas.drawPath(gota, Paint()..color = const Color(0xFF0284C7));
      case 'no-desayunar':
      case 'saltarse-desayuno':
        // Plato vacío con cubiertos cruzados indicando falta de desayuno
        canvas.drawCircle(
          Offset(cx, cy + h * 0.04),
          w * 0.30,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.30, pBorde);
        canvas.drawCircle(
          Offset(cx, cy + h * 0.04),
          w * 0.18,
          Paint()
            ..color = const Color(0xFFCBD5E1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        final pCruz = Paint()
          ..color = const Color(0xFFEA580C)
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(w * 0.30, h * 0.34),
          Offset(w * 0.70, h * 0.74),
          pCruz,
        );
        canvas.drawLine(
          Offset(w * 0.70, h * 0.34),
          Offset(w * 0.30, h * 0.74),
          pCruz,
        );
      case 'fruta-verdura':
      case 'desayuno-completo':
        // Manzana roja con hoja verde y ramillete de brócoli/verdura fresca
        canvas.drawCircle(
          Offset(w * 0.36, h * 0.56),
          w * 0.20,
          Paint()..color = const Color(0xFFEF4444),
        );
        canvas.drawCircle(Offset(w * 0.36, h * 0.56), w * 0.20, pBorde);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w * 0.40, h * 0.33),
            width: w * 0.14,
            height: h * 0.08,
          ),
          Paint()..color = const Color(0xFF22C55E),
        );
        // Ramillete de verdura verde al lado
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(w * 0.68, h * 0.68),
            width: w * 0.10,
            height: h * 0.18,
          ),
          Paint()..color = const Color(0xFF86EFAC),
        );
        for (final off in [
          const Offset(-5, -6),
          const Offset(5, -6),
          const Offset(0, -11),
        ]) {
          canvas.drawCircle(
            Offset(w * 0.68, h * 0.56) + off,
            w * 0.10,
            Paint()..color = const Color(0xFF16A34A),
          );
        }
      case 'cena-enorme':
        // Plato rebosante con hamburguesa gigante pesada por la noche
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, h * 0.74),
            width: w * 0.68,
            height: h * 0.16,
          ),
          Paint()..color = const Color(0xFFE2E8F0),
        );
        final panInf = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.66),
            width: w * 0.52,
            height: h * 0.12,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(panInf, Paint()..color = const Color(0xFFD97706));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, h * 0.55),
              width: w * 0.56,
              height: h * 0.11,
            ),
            const Radius.circular(5),
          ),
          Paint()..color = const Color(0xFF78350F),
        );
        final panSup = Path()
          ..moveTo(w * 0.24, h * 0.50)
          ..quadraticBezierTo(cx, h * 0.24, w * 0.76, h * 0.50)
          ..close();
        canvas.drawPath(panSup, Paint()..color = const Color(0xFFF59E0B));
        canvas.drawPath(panSup, pBorde);
      case 'jugar-parque':
        // Balón de fútbol clásico con pentágono central sobre césped
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.28,
          Paint()..color = Colors.white,
        );
        canvas.drawCircle(Offset(cx, cy), w * 0.28, pBorde);
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.11,
          Paint()..color = const Color(0xFF1E293B),
        );
        for (final a in [0.0, 1.25, 2.5, 3.75, 5.0]) {
          canvas.drawLine(
            Offset(cx + math.cos(a) * w * 0.11, cy + math.sin(a) * w * 0.11),
            Offset(cx + math.cos(a) * w * 0.26, cy + math.sin(a) * w * 0.26),
            pBorde,
          );
        }
      case 'moverse-cada-dia':
        // Zapatilla deportiva activa con líneas de movimiento
        final suela = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + w * 0.04, h * 0.68),
            width: w * 0.58,
            height: h * 0.12,
          ),
          const Radius.circular(6),
        );
        final cuerpoZap = Path()
          ..moveTo(w * 0.25, h * 0.62)
          ..lineTo(w * 0.28, h * 0.36)
          ..lineTo(w * 0.48, h * 0.42)
          ..quadraticBezierTo(w * 0.76, h * 0.48, w * 0.80, h * 0.62)
          ..close();
        canvas.drawPath(cuerpoZap, Paint()..color = const Color(0xFF22C55E));
        canvas.drawPath(cuerpoZap, pBorde);
        canvas.drawRRect(suela, Paint()..color = Colors.white);
        canvas.drawRRect(suela, pBorde);
      case 'calentar-deporte':
      case 'calentar-estirar':
        // Figura estirando los brazos en arco de flexibilidad antes del deporte
        canvas.drawCircle(
          Offset(cx, h * 0.34),
          w * 0.10,
          Paint()..color = const Color(0xFFF59E0B),
        );
        canvas.drawCircle(Offset(cx, h * 0.34), w * 0.10, pBorde);
        final pEstirar = Paint()
          ..color = const Color(0xFF16A34A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx, h * 0.44), Offset(cx, h * 0.66), pEstirar);
        canvas.drawLine(
          Offset(cx, h * 0.48),
          Offset(w * 0.24, h * 0.26),
          pEstirar,
        );
        canvas.drawLine(
          Offset(cx, h * 0.48),
          Offset(w * 0.76, h * 0.26),
          pEstirar,
        );
        canvas.drawLine(
          Offset(cx, h * 0.66),
          Offset(w * 0.34, h * 0.84),
          pEstirar,
        );
        canvas.drawLine(
          Offset(cx, h * 0.66),
          Offset(w * 0.66, h * 0.84),
          pEstirar,
        );
      case 'respirar-hondo':
        // Ondas suaves de aire limpio entrando y saliendo en calma
        final pBrisa = Paint()
          ..color = const Color(0xFF0D9488)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        for (final dy in [0.34, 0.50, 0.66]) {
          final onda = Path()
            ..moveTo(w * 0.20, h * dy)
            ..quadraticBezierTo(w * 0.40, h * (dy - 0.10), w * 0.58, h * dy)
            ..quadraticBezierTo(
              w * 0.72,
              h * (dy + 0.08),
              w * 0.82,
              h * (dy - 0.04),
            );
          canvas.drawPath(onda, pBrisa);
        }
      case 'compartir-emociones':
      case 'gritar-enfado':
        // Bocadillo de diálogo con corazón cálido (o rayo si es gritar)
        final burbuja = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, h * 0.46),
            width: w * 0.60,
            height: h * 0.42,
          ),
          const Radius.circular(12),
        );
        canvas.drawRRect(burbuja, Paint()..color = Colors.white);
        canvas.drawRRect(burbuja, pBorde);
        final corazon = Path()
          ..moveTo(cx, h * 0.58)
          ..cubicTo(
            cx - w * 0.18,
            h * 0.46,
            cx - w * 0.10,
            h * 0.32,
            cx,
            h * 0.40,
          )
          ..cubicTo(
            cx + w * 0.10,
            h * 0.32,
            cx + w * 0.18,
            h * 0.46,
            cx,
            h * 0.58,
          )
          ..close();
        canvas.drawPath(
          corazon,
          Paint()
            ..color = id == 'gritar-enfado'
                ? const Color(0xFFEF4444)
                : const Color(0xFFEC4899),
        );
      case 'dormir-diez-horas':
      case 'dormir-examen':
        // Luna creciente dorada y estrella de descanso nocturno
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.28,
          Paint()..color = const Color(0xFFFACC15),
        );
        canvas.drawCircle(Offset(cx, cy), w * 0.28, pBorde);
        canvas.drawCircle(
          Offset(cx + w * 0.10, cy - h * 0.06),
          w * 0.19,
          Paint()..color = const Color(0xFFEEF2FF),
        );
        canvas.drawCircle(
          Offset(w * 0.72, h * 0.28),
          3.5,
          Paint()..color = const Color(0xFFF59E0B),
        );
      case 'pantalla-cama':
      case 'pantalla-cerca':
        // Tableta/pantalla con rayos intensos de brillo azul
        final pantalla = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: w * 0.58,
            height: h * 0.42,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(pantalla, Paint()..color = const Color(0xFF334155));
        canvas.drawRRect(pantalla, pBorde);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: w * 0.46,
              height: h * 0.30,
            ),
            const Radius.circular(4),
          ),
          Paint()..color = const Color(0xFF38BDF8),
        );
        final pDestello = Paint()
          ..color = const Color(0xFFFACC15)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(cx, h * 0.14), Offset(cx, h * 0.22), pDestello);
        canvas.drawLine(
          Offset(w * 0.20, h * 0.20),
          Offset(w * 0.26, h * 0.26),
          pDestello,
        );
        canvas.drawLine(
          Offset(w * 0.80, h * 0.20),
          Offset(w * 0.74, h * 0.26),
          pDestello,
        );
      case 'musica-alta':
        // Auriculares grandes con ondas rojas de volumen excesivo
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: w * 0.50,
            height: h * 0.50,
          ),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFF334155)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5.0
            ..strokeCap = StrokeCap.round,
        );
        for (final dx in [-0.24, 0.24]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(cx + w * dx, cy + h * 0.06),
                width: w * 0.14,
                height: h * 0.24,
              ),
              const Radius.circular(6),
            ),
            Paint()..color = const Color(0xFFDB2777),
          );
        }
        // Rayo rojo de ruido fuerte en el centro
        canvas.drawCircle(
          Offset(cx, cy + h * 0.04),
          w * 0.09,
          Paint()..color = const Color(0xFFEF4444),
        );
      case 'espalda-recta':
        // Silla con respaldo y columna vertebral alineada verticalmente
        final pSilla = Paint()
          ..color = const Color(0xFF64748B)
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(w * 0.34, h * 0.26),
          Offset(w * 0.34, h * 0.80),
          pSilla,
        );
        canvas.drawLine(
          Offset(w * 0.34, h * 0.58),
          Offset(w * 0.66, h * 0.58),
          pSilla,
        );
        canvas.drawLine(
          Offset(w * 0.62, h * 0.58),
          Offset(w * 0.62, h * 0.80),
          pSilla,
        );
        // Columna recta con vértebras verdes alineadas
        for (final dy in [0.28, 0.38, 0.48]) {
          canvas.drawCircle(
            Offset(w * 0.46, h * dy),
            3.6,
            Paint()..color = const Color(0xFF16A34A),
          );
        }
      case 'mochila-pesada':
        // Mochila abultada con correas y peso excesivo
        final mochila = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + h * 0.04),
            width: w * 0.48,
            height: h * 0.52,
          ),
          const Radius.circular(12),
        );
        canvas.drawRRect(mochila, Paint()..color = const Color(0xFFB45309));
        canvas.drawRRect(mochila, pBorde);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, cy + h * 0.12),
              width: w * 0.32,
              height: h * 0.22,
            ),
            const Radius.circular(6),
          ),
          Paint()..color = const Color(0xFFF59E0B),
        );
      default:
        // Corazón de bienestar con escudo protector
        canvas.drawCircle(Offset(cx, cy), w * 0.26, Paint()..color = color);
        canvas.drawCircle(Offset(cx, cy), w * 0.26, pBorde);
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.10,
          Paint()..color = Colors.white,
        );
    }
  }

  @override
  bool shouldRepaint(covariant PintorHabitoCartoon oldDelegate) =>
      oldDelegate.id != id || oldDelegate.color != color;
}

class InsigniaIlustradaZona extends StatelessWidget {
  const InsigniaIlustradaZona({required this.id, this.tamano = 56, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde) = switch (id) {
      'reserva' => (const Color(0xFFECFDF5), const Color(0xFF10B981)),
      'invernadero' => (const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
      'cuerpo' => (const Color(0xFFFFF1F2), const Color(0xFFF43F5E)),
      'expedicion' => (const Color(0xFFFFF7ED), const Color(0xFFF97316)),
      'album' => (const Color(0xFFFFFBEB), const Color(0xFFF59E0B)),
      _ => (const Color(0xFFF0F9FF), const Color(0xFF0284C7)),
    };

    return Container(
      width: tamano,
      height: tamano,
      padding: EdgeInsets.all(tamano * 0.10),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano * 0.32),
        border: Border.all(color: borde, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: borde.withValues(alpha: 0.22),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: CustomPaint(painter: _PintorInsigniaZona(id: id)),
    );
  }
}

class _PintorInsigniaZona extends CustomPainter {
  const _PintorInsigniaZona({required this.id});

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;
    final pBorde = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.048
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (id) {
      case 'reserva':
        // Huella de animal centrada con almohadilla lobulada y cuatro dedos en abanico
        final pRellenoHuella = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: const [Color(0xFF34D399), Color(0xFF10B981)],
          ).createShader(Rect.fromLTWH(0, 0, w, h));

        final almohadilla = Path()
          ..moveTo(cx, h * 0.45)
          ..cubicTo(
            w * 0.68,
            h * 0.45,
            w * 0.80,
            h * 0.64,
            w * 0.74,
            h * 0.78,
          )
          ..cubicTo(
            w * 0.70,
            h * 0.88,
            w * 0.58,
            h * 0.86,
            cx,
            h * 0.81,
          )
          ..cubicTo(
            w * 0.42,
            h * 0.86,
            w * 0.30,
            h * 0.88,
            w * 0.26,
            h * 0.78,
          )
          ..cubicTo(
            w * 0.20,
            h * 0.64,
            w * 0.32,
            h * 0.45,
            cx,
            h * 0.45,
          )
          ..close();
        canvas.drawPath(almohadilla, pRellenoHuella);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx - w * 0.08, h * 0.60),
            width: w * 0.16,
            height: h * 0.10,
          ),
          Paint()..color = const Color(0xFFA7F3D0).withValues(alpha: 0.75),
        );
        canvas.drawPath(almohadilla, pBorde);

        for (final (dx, dy, ang, rx, ry) in [
          (-0.27, 0.38, -0.38, 0.14, 0.20),
          (-0.10, 0.24, -0.14, 0.15, 0.22),
          (0.10, 0.24, 0.14, 0.15, 0.22),
          (0.27, 0.38, 0.38, 0.14, 0.20),
        ]) {
          canvas.save();
          canvas.translate(cx + w * dx, h * dy);
          canvas.rotate(ang);
          final rectDedo = Rect.fromCenter(
            center: Offset.zero,
            width: w * rx,
            height: h * ry,
          );
          canvas.drawOval(rectDedo, pRellenoHuella);
          canvas.drawOval(rectDedo, pBorde);
          canvas.restore();
        }

      case 'invernadero':
        // Maceta de terracota con planta en flor y hojas nervadas
        final maceta = Path()
          ..moveTo(w * 0.28, h * 0.62)
          ..lineTo(w * 0.72, h * 0.62)
          ..lineTo(w * 0.64, h * 0.90)
          ..lineTo(w * 0.36, h * 0.90)
          ..close();
        canvas.drawPath(maceta, Paint()..color = const Color(0xFFEA580C));
        canvas.drawPath(maceta, pBorde);
        canvas.drawLine(
          Offset(cx, h * 0.62),
          Offset(cx, h * 0.26),
          Paint()
            ..color = const Color(0xFF15803D)
            ..strokeWidth = w * 0.07
            ..strokeCap = StrokeCap.round,
        );
        for (final signo in [-1.0, 1.0]) {
          final hoja = Path()
            ..moveTo(cx, h * 0.48)
            ..quadraticBezierTo(
              cx + signo * w * 0.34,
              h * 0.32,
              cx + signo * w * 0.28,
              h * 0.54,
            )
            ..quadraticBezierTo(cx + signo * w * 0.12, h * 0.58, cx, h * 0.48);
          canvas.drawPath(hoja, Paint()..color = const Color(0xFF22C55E));
          canvas.drawPath(hoja, pBorde);
        }
        canvas.drawCircle(
          Offset(cx, h * 0.22),
          w * 0.14,
          Paint()..color = const Color(0xFFFACC15),
        );
        canvas.drawCircle(Offset(cx, h * 0.22), w * 0.14, pBorde);
        canvas.drawCircle(
          Offset(cx, h * 0.22),
          w * 0.06,
          Paint()..color = const Color(0xFFEA580C),
        );

      case 'cuerpo':
        // Corazón anatómico estilizado con pulso vital
        final corazon = Path()
          ..moveTo(cx, h * 0.86)
          ..cubicTo(w * 0.10, h * 0.62, w * 0.08, h * 0.26, w * 0.32, h * 0.20)
          ..cubicTo(w * 0.44, h * 0.18, cx, h * 0.28, cx, h * 0.34)
          ..cubicTo(cx, h * 0.28, w * 0.56, h * 0.18, w * 0.68, h * 0.20)
          ..cubicTo(w * 0.92, h * 0.26, w * 0.90, h * 0.62, cx, h * 0.86)
          ..close();
        canvas.drawPath(
          corazon,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFB7185), Color(0xFFE11D48)],
            ).createShader(corazon.getBounds()),
        );
        canvas.drawPath(corazon, pBorde);
        final pulso = Path()
          ..moveTo(w * 0.24, cy + h * 0.02)
          ..lineTo(w * 0.40, cy + h * 0.02)
          ..lineTo(w * 0.46, cy - h * 0.16)
          ..lineTo(w * 0.54, cy + h * 0.18)
          ..lineTo(w * 0.60, cy + h * 0.02)
          ..lineTo(w * 0.76, cy + h * 0.02);
        canvas.drawPath(
          pulso,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.055
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );

      case 'expedicion':
        // Brújula de expedición con llama solar central
        canvas.drawCircle(
          Offset(cx, cy),
          w * 0.42,
          Paint()..color = const Color(0xFFFEF3C7),
        );
        canvas.drawCircle(Offset(cx, cy), w * 0.42, pBorde);
        final llama = Path()
          ..moveTo(cx, h * 0.14)
          ..quadraticBezierTo(w * 0.82, h * 0.44, w * 0.70, h * 0.72)
          ..quadraticBezierTo(cx, h * 0.90, w * 0.30, h * 0.72)
          ..quadraticBezierTo(w * 0.18, h * 0.44, cx, h * 0.14)
          ..close();
        canvas.drawPath(
          llama,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFDE047), Color(0xFFF97316), Color(0xFFEA580C)],
            ).createShader(llama.getBounds()),
        );
        canvas.drawPath(llama, pBorde);
        canvas.drawCircle(
          Offset(cx, h * 0.62),
          w * 0.11,
          Paint()..color = const Color(0xFFFEF08A),
        );

      case 'album':
      default:
        // Cuaderno de campo abierto con marcador y hoja botánica
        final libro = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy),
            width: w * 0.80,
            height: h * 0.68,
          ),
          Radius.circular(w * 0.10),
        );
        canvas.drawRRect(libro, Paint()..color = const Color(0xFFFDE68A));
        canvas.drawRRect(libro, pBorde);
        final paginas = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy - h * 0.02),
            width: w * 0.70,
            height: h * 0.56,
          ),
          Radius.circular(w * 0.06),
        );
        canvas.drawRRect(paginas, Paint()..color = Colors.white);
        canvas.drawRRect(paginas, pBorde);
        canvas.drawLine(
          Offset(cx, cy - h * 0.30),
          Offset(cx, cy + h * 0.26),
          pBorde,
        );
        canvas.drawCircle(
          Offset(cx - w * 0.17, cy),
          w * 0.09,
          Paint()..color = const Color(0xFF22C55E),
        );
        canvas.drawCircle(
          Offset(cx + w * 0.17, cy),
          w * 0.09,
          Paint()..color = const Color(0xFFF59E0B),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorInsigniaZona oldDelegate) =>
      oldDelegate.id != id;
}

/// Visor botánico interactivo para «Árbol, arbusto o hierba»:
/// muestra cómo el viento curva de forma distinta la copa de un árbol (tronco rígido),
/// las ramas bajas de un arbusto o el tallo entero de una hierba flexible, y dibuja
/// una lente macro sobre la corteza o el tallo tierno al activar la lupa.
class VisorBotanicoInteractivo extends StatelessWidget {
  const VisorBotanicoInteractivo({
    required this.especimenId,
    required this.lupaActiva,
    required this.vientoActivo,
    super.key,
  });

  final String especimenId;
  final bool lupaActiva;
  final bool vientoActivo;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: vientoActivo ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, factorViento, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: lupaActiva ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, factorLupa, _) {
            return CustomPaint(
              painter: _PintorEstudioBotanico(
                especimenId: especimenId,
                viento: factorViento.clamp(0.0, 1.2),
                lupa: factorLupa.clamp(0.0, 1.0),
              ),
              child: const SizedBox.expand(),
            );
          },
        );
      },
    );
  }
}

class _PintorEstudioBotanico extends CustomPainter {
  const _PintorEstudioBotanico({
    required this.especimenId,
    required this.viento,
    required this.lupa,
  });

  final String especimenId;
  final double viento;
  final double lupa;

  String get _porte => switch (especimenId) {
    'encina' || 'pino' || 'olivo' || 'manzano' || 'chopo' => 'arbol',
    'romero' || 'rosal' || 'lavanda' || 'tomillo' => 'arbusto',
    _ => 'hierba',
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sueloY = h * 0.86;

    // Suelo botánico con estrato de tierra y hierba rasa
    final rSuelo = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, sueloY, w * 0.80, h * 0.11),
      const Radius.circular(8),
    );
    canvas.drawRRect(rSuelo, Paint()..color = const Color(0xFF854D0E));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, sueloY, w * 0.80, h * 0.035),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF4ADE80),
    );

    // Corrientes de aire si el viento está activo
    if (viento > 0.02) {
      final pAire = Paint()
        ..color = const Color(0xFF0284C7)
            .withValues(alpha: (0.55 * viento).clamp(0.0, 0.7))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      for (final yRel in [0.22, 0.42, 0.62]) {
        final path = Path()
          ..moveTo(w * 0.22, h * yRel)
          ..quadraticBezierTo(
            w * 0.48,
            h * (yRel - 0.05 * viento),
            w * 0.82,
            h * yRel,
          );
        canvas.drawPath(path, pAire);
      }
    }

    final cx = w * 0.56;
    final porte = _porte;

    if (porte == 'arbol') {
      _pintarArbol(canvas, w, h, cx, sueloY);
    } else if (porte == 'arbusto') {
      _pintarArbusto(canvas, w, h, cx, sueloY);
    } else {
      _pintarHierba(canvas, w, h, cx, sueloY);
    }

    // Lupa macro de tallo/corteza cuando está activa
    if (lupa > 0.02) {
      _pintarLenteMacro(canvas, w, h, cx, sueloY, porte);
    }
  }

  void _pintarArbol(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double sueloY,
  ) {
    // El tronco leñoso NO se dobla con el viento; solo se mece la copa arriba
    final desplazamientoCopa = w * 0.045 * viento;
    final esChopo = especimenId == 'chopo';
    final colorCorteza = esChopo
        ? const Color(0xFF78716C)
        : const Color(0xFF78350F);
    final pTronco = Paint()..color = colorCorteza;
    final pBorde = Paint()
      ..color = const Color(0xFF451A03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final anchoBase = esChopo ? w * 0.055 : w * 0.085;
    final anchoAlto = esChopo ? w * 0.032 : w * 0.048;
    final altoTroncoY = esChopo ? h * 0.36 : h * 0.46;

    final tronco = Path()
      ..moveTo(cx - anchoBase, sueloY)
      ..quadraticBezierTo(
        cx - anchoAlto * 1.1,
        h * 0.64,
        cx - anchoAlto,
        altoTroncoY,
      )
      ..lineTo(cx + anchoAlto, altoTroncoY)
      ..quadraticBezierTo(
        cx + anchoAlto * 1.1,
        h * 0.64,
        cx + anchoBase,
        sueloY,
      )
      ..close();
    canvas.drawPath(tronco, pTronco);
    canvas.drawPath(tronco, pBorde);

    // Surcos de corteza leñosa
    final pSurco = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - w * 0.018, altoTroncoY + 8),
      Offset(cx - w * 0.025, sueloY - 4),
      pSurco,
    );
    canvas.drawLine(
      Offset(cx + w * 0.015, altoTroncoY + 6),
      Offset(cx + w * 0.022, sueloY - 6),
      pSurco,
    );

    // Ramas principales altas
    for (final dir in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(cx, altoTroncoY + 4),
        Offset(
          cx + dir * w * 0.11 + desplazamientoCopa * 0.5,
          altoTroncoY - h * 0.10,
        ),
        Paint()
          ..color = colorCorteza
          ..strokeWidth = 4.2
          ..strokeCap = StrokeCap.round,
      );
    }

    final copaCentro = Offset(cx + desplazamientoCopa, h * 0.28);
    if (especimenId == 'pino') {
      for (final (yCima, yBase, anchoPiso) in [
        (0.24, 0.48, 0.23),
        (0.15, 0.36, 0.18),
        (0.07, 0.25, 0.13),
      ]) {
        final piso = Path()
          ..moveTo(copaCentro.dx, h * yCima)
          ..lineTo(copaCentro.dx - w * anchoPiso, h * yBase)
          ..lineTo(copaCentro.dx + w * anchoPiso, h * yBase)
          ..close();
        canvas.drawPath(piso, Paint()..color = const Color(0xFF15803D));
        canvas.drawPath(
          piso,
          Paint()
            ..color = const Color(0xFF14532D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }
      // Piñas marrones colgando
      for (final off in [
        Offset(-w * 0.09, h * 0.08),
        Offset(w * 0.08, h * 0.04),
      ]) {
        canvas.drawOval(
          Rect.fromCenter(center: copaCentro + off, width: 6, height: 9),
          Paint()..color = const Color(0xFF78350F),
        );
      }
    } else if (esChopo) {
      // Copa piramidal alta y esbelta típica del chopo de ribera
      final copaChopo = Path()
        ..moveTo(copaCentro.dx, h * 0.06)
        ..quadraticBezierTo(
          copaCentro.dx + w * 0.18,
          h * 0.26,
          copaCentro.dx + w * 0.12,
          h * 0.46,
        )
        ..quadraticBezierTo(
          copaCentro.dx,
          h * 0.50,
          copaCentro.dx - w * 0.12,
          h * 0.46,
        )
        ..quadraticBezierTo(
          copaCentro.dx - w * 0.18,
          h * 0.26,
          copaCentro.dx,
          h * 0.06,
        )
        ..close();
      canvas.drawPath(copaChopo, Paint()..color = const Color(0xFF22C55E));
      canvas.drawPath(
        copaChopo,
        Paint()
          ..color = const Color(0xFF15803D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      // Volúmenes internos de hojas acorazonadas de chopo
      for (final dy in [0.18, 0.28, 0.38]) {
        canvas.drawCircle(
          Offset(copaCentro.dx - w * 0.04, h * dy),
          w * 0.055,
          Paint()..color = const Color(0xFF4ADE80).withValues(alpha: 0.65),
        );
      }
    } else {
      // Copa frondosa multicapa (encina, manzano, olivo)
      final colorCopa = switch (especimenId) {
        'olivo' => const Color(0xFF4D7C0F),
        'manzano' => const Color(0xFF16A34A),
        _ => const Color(0xFF15803D),
      };
      final colorLuz = switch (especimenId) {
        'olivo' => const Color(0xFF84CC16),
        'manzano' => const Color(0xFF4ADE80),
        _ => const Color(0xFF22C55E),
      };
      for (final (ox, oy, r) in [
        (-0.14, 0.06, 0.11),
        (0.14, 0.06, 0.11),
        (-0.08, -0.04, 0.12),
        (0.08, -0.04, 0.12),
        (0.0, -0.09, 0.12),
        (0.0, 0.03, 0.13),
      ]) {
        final c = copaCentro + Offset(w * ox, h * oy);
        canvas.drawCircle(c, w * r, Paint()..color = colorCopa);
        canvas.drawCircle(
          c + const Offset(-2, -2),
          w * r * 0.65,
          Paint()..color = colorLuz.withValues(alpha: 0.38),
        );
      }
      if (especimenId == 'manzano') {
        // Manzanas rojas brillantes con hoja verde
        for (final off in [
          Offset(-w * 0.11, h * 0.04),
          Offset(w * 0.10, h * 0.05),
          Offset(-w * 0.03, -h * 0.05),
          Offset(w * 0.06, -h * 0.04),
          Offset(0, h * 0.07),
        ]) {
          final posM = copaCentro + off;
          canvas.drawCircle(
            posM,
            5.2,
            Paint()..color = const Color(0xFFEF4444),
          );
          canvas.drawCircle(
            posM,
            5.2,
            Paint()
              ..color = const Color(0xFF991B1B)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2,
          );
          canvas.drawCircle(
            posM + const Offset(-1.5, -1.5),
            1.5,
            Paint()..color = const Color(0xFFFECACA),
          );
        }
      } else {
        // Bellotas o aceitunas
        final colorFruto = especimenId == 'olivo'
            ? const Color(0xFF365314)
            : const Color(0xFFB45309);
        for (final off in [
          Offset(-w * 0.09, h * 0.03),
          Offset(w * 0.09, -h * 0.01),
          Offset(0, h * 0.05),
        ]) {
          canvas.drawOval(
            Rect.fromCenter(center: copaCentro + off, width: 6, height: 8),
            Paint()..color = colorFruto,
          );
        }
      }
    }
  }

  void _pintarArbusto(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double sueloY,
  ) {
    // Mata leñosa baja cuyos tallos nacen directamente desde la tierra y están cubiertos de hojitas
    final inclinacion = w * 0.09 * viento;
    final esTomillo = especimenId == 'tomillo';
    final pRama = Paint()
      ..color = const Color(0xFF713F12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = esTomillo ? 2.4 : 3.2
      ..strokeCap = StrokeCap.round;

    // Almohadilla verde de base arbustiva para que parezca una mata real y no palos sueltos
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          cx + inclinacion * 0.4,
          sueloY - h * (esTomillo ? 0.12 : 0.18),
        ),
        width: w * 0.46,
        height: h * (esTomillo ? 0.24 : 0.34),
      ),
      Paint()..color = const Color(0xFF15803D).withValues(alpha: 0.45),
    );

    final angulos = [-0.22, -0.11, 0.0, 0.11, 0.22];
    for (final a in angulos) {
      final alturaTallo = esTomillo ? 0.56 : 0.42;
      final finX = cx + w * a + inclinacion;
      final finY = h * (alturaTallo + a.abs() * 0.28);
      final baseX = cx + w * a * 0.20;
      final ctrlX = cx + w * a * 0.65 + inclinacion * 0.4;
      final ctrlY = h * 0.68;

      final path = Path()
        ..moveTo(baseX, sueloY)
        ..quadraticBezierTo(ctrlX, ctrlY, finX, finY);
      canvas.drawPath(path, pRama);

      // Pares de hojitas a lo largo de todo el tallo leñoso
      for (final t in [0.30, 0.52, 0.74, 0.92]) {
        final px = baseX + (finX - baseX) * t;
        final py = sueloY + (finY - sueloY) * t;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(px - 4.5, py),
            width: 7.5,
            height: 4.0,
          ),
          Paint()..color = const Color(0xFF16A34A),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(px + 4.5, py),
            width: 7.5,
            height: 4.0,
          ),
          Paint()..color = const Color(0xFF22C55E),
        );
      }

      // Inflorescencia terminal según especie
      final colorFlor = switch (especimenId) {
        'rosal' => const Color(0xFFE11D48),
        'lavanda' => const Color(0xFF9333EA),
        'tomillo' => const Color(0xFFF472B6),
        _ => const Color(0xFF60A5FA),
      };
      for (final off in [
        const Offset(0, -4),
        const Offset(-4, 0),
        const Offset(4, 0),
      ]) {
        canvas.drawCircle(
          Offset(finX, finY) + off,
          3.6,
          Paint()..color = colorFlor,
        );
      }
      canvas.drawCircle(
        Offset(finX, finY - 2),
        1.8,
        Paint()..color = const Color(0xFFFEF08A),
      );
    }
  }

  void _pintarHierba(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double sueloY,
  ) {
    final doblado = w * 0.24 * viento;

    if (especimenId == 'cesped') {
      // Mata densa de briznas de hierba finas y tiernas que se doblan todas juntas con el viento
      final desplazamientos = [
        -0.22,
        -0.17,
        -0.12,
        -0.07,
        -0.02,
        0.03,
        0.08,
        0.13,
        0.18,
        0.23,
      ];
      for (var i = 0; i < desplazamientos.length; i++) {
        final dxBase = cx + w * desplazamientos[i];
        final alt = h * (0.48 + (i % 3) * 0.06 + 0.08 * viento);
        final brizna = Path()
          ..moveTo(dxBase, sueloY)
          ..quadraticBezierTo(
            dxBase + doblado * 0.45,
            h * 0.68,
            dxBase + doblado + (i - 4.5) * 2.2,
            alt,
          );
        canvas.drawPath(
          brizna,
          Paint()
            ..color = i.isEven
                ? const Color(0xFF16A34A)
                : const Color(0xFF22C55E)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round,
        );
      }
      return;
    }

    if (especimenId == 'tomatera') {
      // Tallo herbáceo verde jugoso con ramas laterales, hojas dentadas y tomates rojos brillantes
      final puntaX = cx + doblado * 0.85;
      final puntaY = h * (0.32 + 0.08 * viento);
      final pTallo = Paint()
        ..color = const Color(0xFF16A34A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round;

      final tallo = Path()
        ..moveTo(cx, sueloY)
        ..quadraticBezierTo(cx + doblado * 0.40, h * 0.58, puntaX, puntaY);
      canvas.drawPath(tallo, pTallo);

      // Ramas laterales con hojas verdes y tomates rojos maduros
      for (final (t, dir) in [(0.38, -1.0), (0.62, 1.0), (0.82, -1.0)]) {
        final rx = cx + (puntaX - cx) * t;
        final ry = sueloY + (puntaY - sueloY) * t;
        final finRx = rx + dir * w * 0.13 + doblado * 0.25;
        final finRy = ry - h * 0.04;
        canvas.drawLine(
          Offset(rx, ry),
          Offset(finRx, finRy),
          pTallo..strokeWidth = 2.8,
        );
        // Hoja compuesta
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(finRx, finRy - 4),
            width: 14,
            height: 7,
          ),
          Paint()..color = const Color(0xFF22C55E),
        );
        // Tomate rojo redondo con cáliz verde
        final posTomate = Offset(finRx - dir * 4, finRy + 7);
        canvas.drawCircle(
          posTomate,
          7.2,
          Paint()..color = const Color(0xFFEF4444),
        );
        canvas.drawCircle(
          posTomate,
          7.2,
          Paint()
            ..color = const Color(0xFF991B1B)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3,
        );
        canvas.drawCircle(
          posTomate + const Offset(-2, -2),
          2.0,
          Paint()..color = const Color(0xFFFECACA),
        );
        canvas.drawCircle(
          posTomate + const Offset(0, -6.5),
          2.5,
          Paint()..color = const Color(0xFF15803D),
        );
      }
      // Florecilla amarilla apical de la tomatera
      canvas.drawCircle(
        Offset(puntaX, puntaY),
        4.5,
        Paint()..color = const Color(0xFFFACC15),
      );
      return;
    }

    // Tallo herbáceo verde/dorado, fino y muy flexible que se dobla entero con el viento
    final puntaX = cx + doblado;
    final puntaY = h * (0.38 + 0.10 * viento);

    final tallo = Path()
      ..moveTo(cx, sueloY)
      ..quadraticBezierTo(cx + doblado * 0.45, h * 0.60, puntaX, puntaY);
    canvas.drawPath(
      tallo,
      Paint()
        ..color = especimenId == 'trigo'
            ? const Color(0xFFCA8A04)
            : const Color(0xFF22C55E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round,
    );

    // Hojas basales tiernas en el tallo
    for (final dir in [-1.0, 1.0]) {
      final hoja = Path()
        ..moveTo(cx + doblado * 0.25, h * 0.68)
        ..quadraticBezierTo(
          cx + dir * w * 0.10 + doblado * 0.35,
          h * 0.60,
          cx + dir * w * 0.14 + doblado * 0.4,
          h * 0.65,
        )
        ..quadraticBezierTo(
          cx + dir * w * 0.08 + doblado * 0.3,
          h * 0.72,
          cx + doblado * 0.25,
          h * 0.68,
        );
      canvas.drawPath(
        hoja,
        Paint()
          ..color = especimenId == 'trigo'
              ? const Color(0xFFEAB308)
              : const Color(0xFF16A34A),
      );
    }

    if (especimenId == 'amapola') {
      // Flor de amapola silvestre con 4 grandes pétalos rojos sedosos superpuestos y centro negro con estambres
      final centroFlor = Offset(puntaX, puntaY);
      final pBordePetalo = Paint()
        ..color = const Color(0xFF991B1B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (final (ox, oy, rx, ry, tono) in [
        (-9.0, -2.0, 13.0, 11.0, const Color(0xFFDC2626)),
        (9.0, -2.0, 13.0, 11.0, const Color(0xFFDC2626)),
        (0.0, -9.0, 14.0, 11.5, const Color(0xFFEF4444)),
        (0.0, 6.0, 14.5, 11.5, const Color(0xFFF87171)),
      ]) {
        final rectPetalo = Rect.fromCenter(
          center: centroFlor + Offset(ox, oy),
          width: rx * 2,
          height: ry * 2,
        );
        canvas.drawOval(rectPetalo, Paint()..color = tono);
        canvas.drawOval(rectPetalo, pBordePetalo);
      }

      // Centro oscuro de la cápsula y corona de estambres
      canvas.drawCircle(
        centroFlor,
        6.2,
        Paint()..color = const Color(0xFF1E293B),
      );
      for (var i = 0; i < 8; i++) {
        final ang = i * math.pi / 4;
        canvas.drawCircle(
          centroFlor + Offset(math.cos(ang) * 7.8, math.sin(ang) * 7.8),
          1.4,
          Paint()..color = const Color(0xFFFEF08A),
        );
      }
      canvas.drawCircle(
        centroFlor,
        2.6,
        Paint()..color = const Color(0xFF4ADE80),
      );
    } else if (especimenId == 'trigo') {
      for (var i = 0; i < 5; i++) {
        final posGrano = Offset(puntaX - i * 2.0 * viento, puntaY + i * 5.2);
        canvas.drawOval(
          Rect.fromCenter(
            center: posGrano + const Offset(-3.5, 0),
            width: 7,
            height: 4.5,
          ),
          Paint()..color = const Color(0xFFEAB308),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: posGrano + const Offset(3.5, 0),
            width: 7,
            height: 4.5,
          ),
          Paint()..color = const Color(0xFFFACC15),
        );
      }
    } else {
      // Trébol de 3 foliolos verdes acorazonados
      for (final off in [
        const Offset(-7, -3),
        const Offset(7, -3),
        const Offset(0, -10),
      ]) {
        canvas.drawCircle(
          Offset(puntaX, puntaY) + off,
          6.5,
          Paint()..color = const Color(0xFF16A34A),
        );
        canvas.drawCircle(
          Offset(puntaX, puntaY) + off,
          3.0,
          Paint()..color = const Color(0xFF86EFAC),
        );
      }
    }
  }

  void _pintarLenteMacro(
    Canvas canvas,
    double w,
    double h,
    double cx,
    double sueloY,
    String porte,
  ) {
    final centroLupa = Offset(cx + w * 0.14, h * 0.62);
    final radio = w * 0.18 * lupa;
    if (radio < 4) return;

    // Mango de la lupa
    canvas.drawLine(
      centroLupa + Offset(radio * 0.68, radio * 0.68),
      centroLupa + Offset(radio * 1.35, radio * 1.35),
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round,
    );

    // Fondo interior de la lente macro
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: centroLupa, radius: radio)),
    );
    canvas.drawCircle(
      centroLupa,
      radio,
      Paint()..color = const Color(0xFFFEFCE8),
    );

    if (porte == 'arbol') {
      // Textura macro de corteza rugosa y anillos de madera dura
      canvas.drawRect(
        Rect.fromCenter(
          center: centroLupa,
          width: radio * 1.3,
          height: radio * 2,
        ),
        Paint()..color = const Color(0xFF78350F),
      );
      final pGrieta = Paint()
        ..color = const Color(0xFF451A03)
        ..strokeWidth = 2.2;
      for (final dx in [-0.35, 0.0, 0.35]) {
        canvas.drawLine(
          Offset(centroLupa.dx + radio * dx, centroLupa.dy - radio),
          Offset(centroLupa.dx + radio * (dx * 0.8), centroLupa.dy + radio),
          pGrieta,
        );
      }
    } else if (porte == 'arbusto') {
      // Macro de varios tallos leñosos ramificando desde el cuello de la raíz
      final pRama = Paint()
        ..color = const Color(0xFF854D0E)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      for (final dx in [-0.55, -0.20, 0.20, 0.55]) {
        canvas.drawLine(
          Offset(centroLupa.dx, centroLupa.dy + radio * 0.85),
          Offset(centroLupa.dx + radio * dx, centroLupa.dy - radio * 0.75),
          pRama,
        );
      }
    } else {
      // Macro de tallo herbáceo verde tierno con haces vasculares y pelillos
      canvas.drawRect(
        Rect.fromCenter(
          center: centroLupa,
          width: radio * 0.72,
          height: radio * 2,
        ),
        Paint()..color = const Color(0xFF4ADE80),
      );
      canvas.drawLine(
        Offset(centroLupa.dx, centroLupa.dy - radio),
        Offset(centroLupa.dx, centroLupa.dy + radio),
        Paint()
          ..color = const Color(0xFF15803D)
          ..strokeWidth = 2.0,
      );
    }
    canvas.restore();

    // Aro dorado de la lupa y reflejo de cristal
    canvas.drawCircle(
      centroLupa,
      radio,
      Paint()
        ..color = const Color(0xFFD97706)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2,
    );
    canvas.drawArc(
      Rect.fromCircle(center: centroLupa, radius: radio * 0.78),
      -2.4,
      0.9,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorEstudioBotanico oldDelegate) =>
      oldDelegate.especimenId != especimenId ||
      oldDelegate.viento != viento ||
      oldDelegate.lupa != lupa;
}

/// Panel interactivo de bienestar y energía corporal para «¿Me cuida o no?».
class BandejaHabitosInteractiva extends StatelessWidget {
  const BandejaHabitosInteractiva({
    required this.retoActualId,
    required this.retosIds,
    required this.retosNombres,
    required this.resueltos,
    this.onSeleccionarReto,
    super.key,
  });

  final String retoActualId;
  final List<String> retosIds;
  final List<String> retosNombres;
  final Set<String> resueltos;
  final ValueChanged<String>? onSeleccionarReto;

  (String sistema, String pistaCuerpo, IconData icono, Color color) _infoHabito(
    String id,
  ) {
    return switch (id) {
      'dormir' || 'descansar' => (
        'Descanso cerebral',
        'El cerebro y los músculos recuperan energía mientras dormimos.',
        Icons.bedtime_rounded,
        const Color(0xFF6366F1),
      ),
      'dientes' || 'manos' || 'ducha' => (
        'Higiene protectora',
        'Elimina microbios de la piel, manos y dientes para evitar infecciones.',
        Icons.clean_hands_rounded,
        const Color(0xFF0284C7),
      ),
      'fruta' || 'agua' || 'desayuno' || 'verdura' => (
        'Nutrición e hidratación',
        'Aporta agua, vitaminas y energía limpia a todas nuestras células.',
        Icons.water_drop_rounded,
        const Color(0xFF16A34A),
      ),
      'jugar' || 'deporte' || 'calentar' => (
        'Movimiento activo',
        'Fortalece el corazón, los pulmones, los huesos y la coordinación.',
        Icons.directions_run_rounded,
        const Color(0xFFEA580C),
      ),
      'postura' || 'mochila' => (
        'Cuidado de la espalda',
        'Protege la columna vertebral para que no sufra sobrecargas.',
        Icons.accessibility_new_rounded,
        const Color(0xFF0D9488),
      ),
      _ => (
        'Equilibrio diario',
        'Observa si esta costumbre recarga o agota la energía de tu cuerpo.',
        Icons.favorite_rounded,
        const Color(0xFFE11D48),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final (sistema, pista, icono, color) = _infoHabito(retoActualId);
    final total = retosIds.isEmpty ? 1 : retosIds.length;
    final progresoVital = (resueltos.length / total).clamp(0.12, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Texto(
                  '$sistema · $pista',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 12,
                      color: Color(0xFF16A34A),
                    ),
                    const SizedBox(width: 3),
                    Texto(
                      '${(progresoVital * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < retosIds.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Builder(
                    builder: (context) {
                      final id = retosIds[i];
                      final nombre = retosNombres[i];
                      final hecho = resueltos.contains(id);
                      final activo = id == retoActualId;
                      return InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => onSeleccionarReto?.call(id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: hecho
                                ? const Color(0xFFDCFCE7)
                                : (activo
                                      ? color.withValues(alpha: 0.14)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: hecho
                                  ? const Color(0xFF22C55E)
                                  : (activo ? color : const Color(0xFFCBD5E1)),
                              width: activo ? 1.8 : 1.1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hecho) ...[
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: Color(0xFF16A34A),
                                ),
                                const SizedBox(width: 3),
                              ],
                              Texto(
                                nombre,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: hecho
                                      ? const Color(0xFF15803D)
                                      : (activo
                                            ? color
                                            : const Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ENCICLOPEDIA CIENTÍFICA DE CROMOS Y SANTUARIO DE BIOMAS INTERACTIVO
// ============================================================================

class DatosEnciclopedicosFicha {
  const DatosEnciclopedicosFicha({
    required this.clasificacion,
    required this.habitatOSistema,
    required this.locomocionOFuncion,
    required this.alimentacionOProceso,
    required this.datoCientifico,
    required this.tipoMovimiento,
  });

  final String clasificacion;
  final String habitatOSistema;
  final String locomocionOFuncion;
  final String alimentacionOProceso;
  final String datoCientifico;
  final String tipoMovimiento; // 'vuelo', 'nado', 'salto', 'paso', 'pulso'

  static DatosEnciclopedicosFicha de(String id) {
    return switch (id) {
      'camello' => const DatosEnciclopedicosFicha(
        clasificacion: 'Vertebrado · Mamífero terrestre',
        habitatOSistema: 'Desierto cálido y dunas de arena',
        locomocionOFuncion:
            'Camina sobre la arena con almohadillas anchas sin hundirse',
        alimentacionOProceso:
            'Herbívoro y vivíparo · Reserva grasa energética en su joroba',
        datoCientifico: 'Sus fosas nasales se cierran como ventanitas durante las tormentas de arena.',
        tipoMovimiento: 'paso',
      ),
      'pinguino' => const DatosEnciclopedicosFicha(
        clasificacion: 'Vertebrado · Ave marina no voladora',
        habitatOSistema: 'Costas heladas y aguas polares',
        locomocionOFuncion:
            'Camina erguido en el hielo y «vuela» bajo el agua con sus aletas',
        alimentacionOProceso:
            'Carnívoro piscívoro y ovíparo · Incuba su huevo sobre las patas',
        datoCientifico: 'Tiene una capa densa de plumas impermeables y grasa bajo la piel contra el frío.',
        tipoMovimiento: 'paso',
      ),
      'delfin' => const DatosEnciclopedicosFicha(
        clasificacion: 'Vertebrado · Mamífero marino',
        habitatOSistema: 'Océanos y mares abiertos',
        locomocionOFuncion: 'Nada a gran velocidad impulsándose de arriba abajo con su aleta caudal',
        alimentacionOProceso:
            'Carnívoro y vivíparo · Respira aire por su espiráculo superior',
        datoCientifico: 'Se comunica con silbidos y chasquidos usando ecolocalización bajo el agua.',
        tipoMovimiento: 'nado',
      ),
      'oso' => const DatosEnciclopedicosFicha(
        clasificacion: 'Vertebrado · Mamífero plantígrado',
        habitatOSistema: 'Bosques templados de montaña y ríos',
        locomocionOFuncion: 'Camina apoyando toda la planta de sus cuatro patas con fuertes garras',
        alimentacionOProceso:
            'Omnívoro y vivíparo · Come frutos, raíces, miel y salmones',
        datoCientifico: 'En invierno reduce su ritmo cardíaco y duerme en su osera para ahorrar energía.',
        tipoMovimiento: 'paso',
      ),
      'rana' => const DatosEnciclopedicosFicha(
        clasificacion: 'Vertebrado · Anfibio de piel húmeda',
        habitatOSistema: 'Charcas, orillas de ríos y humedales',
        locomocionOFuncion: 'Da grandes saltos con sus largas patas traseras y nada con membranas',
        alimentacionOProceso: 'Carnívoro insectívoro y ovíparo · Sufre metamorfosis desde renacuajo',
        datoCientifico: 'Respira tanto por los pulmones como a través de su piel fina y siempre húmeda.',
        tipoMovimiento: 'salto',
      ),
      'tucan' => const DatosEnciclopedicosFicha(
        clasificacion: 'Vertebrado · Ave tropical arborícola',
        habitatOSistema: 'Dosel alto de la selva húmeda tropical',
        locomocionOFuncion:
            'Vuela entre las copas y salta de rama en rama con patas prensiles',
        alimentacionOProceso: 'Frugívoro / omnívoro y ovíparo · Alcanza frutos lejanos con su pico',
        datoCientifico: 'Su enorme pico tiene estructura de panal de aire por dentro: es rígido pero muy ligero.',
        tipoMovimiento: 'vuelo',
      ),
      'pulpo' => const DatosEnciclopedicosFicha(
        clasificacion: 'Invertebrado · Molusco cefalópodo',
        habitatOSistema: 'Fondos marinos rocosos y arrecifes',
        locomocionOFuncion: 'Reptación con 8 tentáculos con ventosas y propulsión a chorro de agua',
        alimentacionOProceso:
            'Carnívoro marino y ovíparo · Caza cangrejos y almejas de noche',
        datoCientifico: 'Posee tres corazones, sangre azulada y células en la piel para camuflarse al instante.',
        tipoMovimiento: 'nado',
      ),
      'huevo' => const DatosEnciclopedicosFicha(
        clasificacion: 'Reproducción · Desarrollo ovíparo',
        habitatOSistema: 'Nidos en árboles, tierra o agua',
        locomocionOFuncion:
            'Protege y nutre al embrión dentro del cascarón hasta la eclosión',
        alimentacionOProceso:
            'Aves, reptiles, anfibios, peces e insectos nacen de huevos',
        datoCientifico: 'La cáscara tiene miles de poros microscópicos por los que entra oxígeno para la cría.',
        tipoMovimiento: 'pulso',
      ),
      'renacuajo' => const DatosEnciclopedicosFicha(
        clasificacion: 'Ciclo vital · Larva acuática de anfibio',
        habitatOSistema: 'Aguas dulces tranquilas de charcas y arroyos',
        locomocionOFuncion: 'Nada ondulando su larga cola antes de desarrollar las cuatro patas',
        alimentacionOProceso:
            'Respira por branquias en el agua y luego desarrolla pulmones',
        datoCientifico: 'Durante la metamorfosis, su cola no se cae: el cuerpo la reabsorbe para crecer.',
        tipoMovimiento: 'nado',
      ),
      'mariposa' => const DatosEnciclopedicosFicha(
        clasificacion: 'Invertebrado · Artrópodo insecto',
        habitatOSistema: 'Praderas floridas, jardines y bosques',
        locomocionOFuncion: 'Vuela batiendo cuatro alas cubiertas de escamas microscópicas de colores',
        alimentacionOProceso: 'Nectarívora con espiritrompa · Metamorfosis: huevo, oruga, crisálida, adulta',
        datoCientifico: 'Sus sensores del gusto están en las patas: sabe si una hoja es dulce al posarse.',
        tipoMovimiento: 'vuelo',
      ),
      'claro-bosque' => const DatosEnciclopedicosFicha(
        clasificacion: 'Ecología · Ecosistema terrestre',
        habitatOSistema: 'Bosque mediterráneo con sol, suelo, agua y aire',
        locomocionOFuncion: 'Red trófica en equilibrio entre productores, herbívoros y depredadores',
        alimentacionOProceso: 'La encina produce bellotas, el ratón las come y la culebra y el águila cazan',
        datoCientifico: 'Si desaparece un solo eslabón del ecosistema, todas las demás especies se ven afectadas.',
        tipoMovimiento: 'paso',
      ),
      'raiz' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano vegetal subterráneo',
        habitatOSistema: 'Subsuelo rico en agua y sales minerales',
        locomocionOFuncion: 'Fija la planta al suelo e impide que el viento o la lluvia la arranquen',
        alimentacionOProceso: 'Absorbe agua y sales minerales mediante pelos radicales formando savia bruta',
        datoCientifico: 'Las raíces crecen siempre hacia abajo buscando humedad gracias a la gravedad.',
        tipoMovimiento: 'pulso',
      ),
      'tallo' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano vegetal de sostén y transporte',
        habitatOSistema: 'Eje aéreo entre la raíz y las hojas',
        locomocionOFuncion:
            'Sostiene hojas, flores y frutos y los eleva hacia la luz del sol',
        alimentacionOProceso: 'Transporta savia bruta hacia arriba (xilema) y savia elaborada (floema)',
        datoCientifico: 'Cada anillo en el interior de un tronco leñoso corresponde a un año de vida del árbol.',
        tipoMovimiento: 'pulso',
      ),
      'hoja' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano vegetal laminar · Fotosíntesis',
        habitatOSistema: 'Ramas iluminadas en contacto con el aire',
        locomocionOFuncion:
            'Abre y cierra poros microscópicos llamados estomas para respirar',
        alimentacionOProceso: 'Capta luz solar con la clorofila verde para fabricar el alimento de la planta',
        datoCientifico: 'Al realizar la fotosíntesis durante el día, las hojas liberan el oxígeno que respiramos.',
        tipoMovimiento: 'pulso',
      ),
      'flor' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano reproductor de las plantas',
        habitatOSistema: 'Brotes florales en primavera y verano',
        locomocionOFuncion: 'Atrae insectos polinizadores con sus pétalos de colores y su aroma',
        alimentacionOProceso: 'Los estambres producen polen y el pistilo se transforma en fruto al fecundarse',
        datoCientifico: 'Las abejas transportan el polen de flor en flor mientras recolectan néctar dulce.',
        tipoMovimiento: 'pulso',
      ),
      'fruto' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano protector y dispersor de semillas',
        habitatOSistema: 'Ramas de árboles, arbustos y plantas de huerto',
        locomocionOFuncion: 'Envuelve y protege las semillas hasta que están maduras para germinar',
        alimentacionOProceso: 'Nace de la flor tras la polinización y ayuda a dispersar las semillas',
        datoCientifico: 'Cuando los animales comen frutos carnosos, llevan las semillas lejos para que nazcan nuevas plantas.',
        tipoMovimiento: 'pulso',
      ),
      'semilla' => const DatosEnciclopedicosFicha(
        clasificacion: 'Embrión vegetal en reposo',
        habitatOSistema: 'Interior del fruto y tierra húmeda del suelo',
        locomocionOFuncion: 'Viaja con el viento, el agua o los animales hasta encontrar suelo fértil',
        alimentacionOProceso: 'Guarda reservas nutritivas para alimentar al brote hasta que tenga hojas',
        datoCientifico: 'Una semilla puede esperar dormida meses hasta sentir la humedad y el calor adecuados.',
        tipoMovimiento: 'pulso',
      ),
      'huerto' => const DatosEnciclopedicosFicha(
        clasificacion: 'Cultivo botánico · Germinación',
        habitatOSistema: 'Tierra fértil aireada con riego y luz solar',
        locomocionOFuncion: 'Primero brota la radícula hacia abajo y después el talluelo hacia el sol',
        alimentacionOProceso: 'Necesita agua justa, aire en la tierra y temperatura templada para germinar',
        datoCientifico: 'Las lombrices excavan galerías en el huerto que airean la tierra y nutren las raíces.',
        tipoMovimiento: 'pulso',
      ),
      'fotosintesis' => const DatosEnciclopedicosFicha(
        clasificacion: 'Proceso vital · Nutrición autótrofa',
        habitatOSistema: 'Cloroplastos de las hojas verdes bajo el sol',
        locomocionOFuncion:
            'Transforma agua, sales minerales y dióxido de carbono en alimento',
        alimentacionOProceso:
            'Savia bruta + CO₂ + Luz solar → Savia elaborada + Oxígeno (O₂)',
        datoCientifico: 'Las plantas son los únicos seres vivos terrestres capaces de fabricar su propio alimento con luz.',
        tipoMovimiento: 'pulso',
      ),
      'encina' => const DatosEnciclopedicosFicha(
        clasificacion: 'Porte botánico · Árbol leñoso',
        habitatOSistema: 'Bosque mediterráneo y dehesas',
        locomocionOFuncion: 'Un único tronco grueso y leñoso del que salen ramas en la copa alta',
        alimentacionOProceso: 'Hoja perenne dura que resiste sequías y produce bellotas nutritivas',
        datoCientifico: 'Una encina puede vivir más de quinientos años y dar sombra y alimento a decenas de especies.',
        tipoMovimiento: 'pulso',
      ),
      'romero' => const DatosEnciclopedicosFicha(
        clasificacion: 'Porte botánico · Arbusto aromático',
        habitatOSistema: 'Matorral soleado y laderas secas',
        locomocionOFuncion: 'Varios tallos leñosos y duros que se ramifican desde la base del suelo',
        alimentacionOProceso: 'Hojas pequeñas con aceites esenciales que evitan perder agua con el calor',
        datoCientifico: 'Sus flores azules o lilas alimentan a las abejas durante casi todo el año.',
        tipoMovimiento: 'pulso',
      ),
      'trigo' => const DatosEnciclopedicosFicha(
        clasificacion: 'Porte botánico · Hierba gramínea',
        habitatOSistema: 'Praderas y campos de cultivo',
        locomocionOFuncion: 'Tallo fino, verde y muy flexible que se dobla con el viento sin partirse',
        alimentacionOProceso: 'Planta anual cuyas espigas contienen los granos con los que se hace harina',
        datoCientifico: 'Las hierbas crecen muy rápido y completan su ciclo desde semilla hasta espiga en pocos meses.',
        tipoMovimiento: 'pulso',
      ),
      'cerebro' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano vital · Sistema nervioso central',
        habitatOSistema: 'Cabeza · Protegido por los huesos del cráneo',
        locomocionOFuncion:
            'Dirige el pensamiento, la memoria, las emociones y el movimiento',
        alimentacionOProceso: 'Recibe información de los 5 sentidos y envía órdenes por los nervios',
        datoCientifico: '¡Aunque estés durmiendo, tu cerebro sigue activo controlando tu respiración y tus sueños!',
        tipoMovimiento: 'pulso',
      ),
      'pulmones' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órganos vitales · Aparato respiratorio',
        habitatOSistema: 'Tórax · Protegidos por la caja torácica (costillas)',
        locomocionOFuncion:
            'Se expanden al inspirar aire fresco y se contraen al espirar',
        alimentacionOProceso: 'Pasan el oxígeno del aire a la sangre y expulsan el dióxido de carbono',
        datoCientifico: 'El pulmón izquierdo es un poquito más pequeño para dejar espacio al corazón.',
        tipoMovimiento: 'pulso',
      ),
      'corazon' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano muscular · Aparato circulatorio',
        habitatOSistema:
            'Centro del pecho, ligeramente inclinado a la izquierda',
        locomocionOFuncion: 'Late sin descanso como una bomba impulsando la sangre por todo el cuerpo',
        alimentacionOProceso: 'Envía oxígeno y nutrientes por las arterias y recoge desechos por las venas',
        datoCientifico: 'Tu corazón tiene aproximadamente el tamaño de tu puño cerrado y late unas 100.000 veces al día.',
        tipoMovimiento: 'pulso',
      ),
      'estomago' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órgano interno · Aparato digestivo',
        habitatOSistema: 'Parte superior del abdomen, bajo las costillas',
        locomocionOFuncion: 'Sus paredes musculares se mueven para batir y mezclar los alimentos',
        alimentacionOProceso: 'Segrega jugos gástricos que transforman el bolo alimenticio en una papilla',
        datoCientifico: 'Tiene una capa protectora interna para que sus propios jugos digestivos no lo dañen.',
        tipoMovimiento: 'pulso',
      ),
      'intestinos' => const DatosEnciclopedicosFicha(
        clasificacion: 'Órganos tubulares · Aparato digestivo',
        habitatOSistema:
            'Cavidad abdominal (intestino delgado e intestino grueso)',
        locomocionOFuncion: 'Impulsan los alimentos digeridos mediante movimientos suaves en onda',
        alimentacionOProceso: 'El intestino delgado absorbe los nutrientes a la sangre y el grueso el agua',
        datoCientifico: 'El intestino delgado está muy plegado: si se estirara mediría varios metros de largo.',
        tipoMovimiento: 'pulso',
      ),
      'esqueleto' => const DatosEnciclopedicosFicha(
        clasificacion: 'Estructura ósea · Aparato locomotor',
        habitatOSistema: 'Armazón interno de todo el cuerpo humano',
        locomocionOFuncion: 'Sostiene el cuerpo, da forma y se mueve junto con los músculos y articulaciones',
        alimentacionOProceso: 'Protege órganos delicados: el cráneo al cerebro y las costillas al corazón y pulmones',
        datoCientifico: 'El cuerpo humano adulto tiene 206 huesos, y el más largo y fuerte es el fémur del muslo.',
        tipoMovimiento: 'pulso',
      ),
      _ => const DatosEnciclopedicosFicha(
        clasificacion: 'Ciencias de la Naturaleza · Salud y Vida',
        habitatOSistema: 'Cuerpo humano y funciones vitales',
        locomocionOFuncion: 'Nutrición, relación con el entorno, crecimiento e higiene saludable',
        alimentacionOProceso: 'Hábitos saludables, sentidos alerta y cuidado diario del organismo',
        datoCientifico: 'Dormir bien, beber agua, comer variado y hacer ejercicio mantiene todos tus sistemas al 100 %.',
        tipoMovimiento: 'pulso',
      ),
    };
  }
}

class TarjetaFichaEnciclopedica extends StatelessWidget {
  const TarjetaFichaEnciclopedica({required this.fichaId, super.key});

  final String fichaId;

  @override
  Widget build(BuildContext context) {
    final datos = DatosEnciclopedicosFicha.de(fichaId);
    final items = [
      (
        Icons.category_rounded,
        'Clasificación',
        datos.clasificacion,
        const Color(0xFF0284C7),
      ),
      (
        Icons.public_rounded,
        'Hábitat / Sistema',
        datos.habitatOSistema,
        const Color(0xFF16A34A),
      ),
      (
        Icons.directions_run_rounded,
        'Locomoción / Función',
        datos.locomocionOFuncion,
        const Color(0xFFD97706),
      ),
      (
        Icons.bolt_rounded,
        'Nutrición / Proceso',
        datos.alimentacionOProceso,
        const Color(0xFF9333EA),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.science_rounded,
                size: 18,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Texto(
                  'FICHA ENCICLOPÉDica DE CAMPO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: items[i].$4.withValues(alpha: 0.35)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(items[i].$1, size: 17, color: items[i].$4),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Texto(
                          items[i].$2.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: items[i].$4,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Texto(
                          items[i].$3,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1) const SizedBox(height: 6),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF93C5FD)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  size: 16,
                  color: Color(0xFF1D4ED8),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Texto(
                    datos.datoCientifico,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Calcula el desplazamiento (dx, dy) en píxeles y el ángulo de inclinación
/// según la locomoción real de cada especie (vuelo, nado, salto o paso).
/// Las plantas y órganos del cuerpo permanecen fijos en su posición (Offset.zero).
(Offset, double, String) calcularLocomocionRealEspecie({
  required String id,
  required double fase,
  required bool activo,
  double amplitud = 1.0,
}) {
  final datos = DatosEnciclopedicosFicha.de(id);
  final anguloBase = fase * 2 * math.pi;
  if (!activo) {
    return (Offset.zero, 0.0, datos.tipoMovimiento);
  }
  return switch (datos.tipoMovimiento) {
    'vuelo' => (
      Offset(
        math.sin(anguloBase) * 14.0 * amplitud,
        math.cos(anguloBase * 2) * 6.5 * amplitud,
      ),
      math.cos(anguloBase) * 0.10 * amplitud,
      'Volando por el aire',
    ),
    'nado' => (
      Offset(
        math.cos(anguloBase) * 16.0 * amplitud,
        math.sin(anguloBase * 2) * 4.5 * amplitud,
      ),
      math.sin(anguloBase) * 0.08 * amplitud,
      'Nadando en el agua',
    ),
    'salto' => (
      Offset(
        math.sin(anguloBase) * 11.0 * amplitud,
        -math.sin(anguloBase * 2).abs() * 12.0 * amplitud,
      ),
      math.cos(anguloBase * 2) * 0.12 * amplitud,
      'Saltando en la charca',
    ),
    'paso' => (
      Offset(
        math.sin(anguloBase) * 11.0 * amplitud,
        -math.sin(anguloBase * 3).abs() * 3.5 * amplitud,
      ),
      math.sin(anguloBase * 3) * 0.05 * amplitud,
      'Caminando por su bioma',
    ),
    _ => (Offset.zero, 0.0, 'Fijo en su posición natural'),
  };
}

class PintorBiomasSantuarioDetallado extends CustomPainter {
  const PintorBiomasSantuarioDetallado({
    required this.zonaId,
    required this.progresoAnim,
    required this.efectoActivo,
    required this.modoAmbiente,
  });

  final String zonaId;
  final double progresoAnim;
  final bool efectoActivo;
  final int modoAmbiente;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    if (zonaId == 'reserva') {
      _pintarSantuarioReserva(canvas, w, h, rect);
    } else if (zonaId == 'invernadero') {
      _pintarMapaBotanicoTerrenos(canvas, w, h, rect);
    } else {
      _pintarEstacionAnatomicaCuerpo(canvas, w, h, rect);
    }
  }

  void _pintarSantuarioReserva(Canvas canvas, double w, double h, Rect rect) {
    // 1. Cielo panorámico con degradado atmosférico
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: modoAmbiente == 0
              ? const [Color(0xFF38BDF8), Color(0xFFBAE6FD), Color(0xFFDCFCE7)]
              : const [Color(0xFFF59E0B), Color(0xFFFDE68A), Color(0xFFDCFCE7)],
        ).createShader(rect),
    );

    final solPos = Offset(w * 0.50, h * 0.11);
    canvas.drawCircle(
      solPos,
      26,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.45),
    );
    canvas.drawCircle(solPos, 15, Paint()..color = const Color(0xFFFACC15));

    // Cordillera montañosa lejana (hábitat de las rapaces y cumbres)
    final montanas = Path()
      ..moveTo(w * 0.22, h * 0.42)
      ..lineTo(w * 0.38, h * 0.14)
      ..lineTo(w * 0.50, h * 0.30)
      ..lineTo(w * 0.62, h * 0.12)
      ..lineTo(w * 0.78, h * 0.42)
      ..close();
    canvas.drawPath(
      montanas,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64748B), Color(0xFF94A3B8)],
        ).createShader(montanas.getBounds()),
    );
    final nieveCumbre = Path()
      ..moveTo(w * 0.34, h * 0.21)
      ..lineTo(w * 0.38, h * 0.14)
      ..lineTo(w * 0.42, h * 0.21)
      ..close();
    canvas.drawPath(nieveCumbre, Paint()..color = Colors.white);

    // 2. BIOMA SELVA TROPICAL (arriba-izquierda): dosel frondoso, tronco, rama y lianas
    final copaSelva = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.36, 0)
      ..quadraticBezierTo(w * 0.34, h * 0.28, w * 0.18, h * 0.33)
      ..quadraticBezierTo(w * 0.08, h * 0.36, 0, h * 0.31)
      ..close();
    canvas.drawPath(
      copaSelva,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF14532D), Color(0xFF16A34A)],
        ).createShader(copaSelva.getBounds()),
    );
    final ramaSelva = Path()
      ..moveTo(0, h * 0.28)
      ..quadraticBezierTo(w * 0.15, h * 0.24, w * 0.29, h * 0.27);
    canvas.drawPath(
      ramaSelva,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..strokeCap = StrokeCap.round,
    );

    // 3. BIOMA GLACIAR Y COSTA HELADA (arriba-derecha): témpanos y plataforma de hielo
    final glaciar = Path()
      ..moveTo(w * 0.70, h * 0.36)
      ..lineTo(w * 0.78, h * 0.10)
      ..lineTo(w * 0.86, h * 0.20)
      ..lineTo(w * 0.94, h * 0.07)
      ..lineTo(w, h * 0.18)
      ..lineTo(w, h * 0.38)
      ..close();
    canvas.drawPath(
      glaciar,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFBAE6FD)],
        ).createShader(glaciar.getBounds()),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.85, h * 0.35),
        width: w * 0.28,
        height: h * 0.09,
      ),
      Paint()..color = const Color(0xFFE0F2FE),
    );

    // 4. VALLE CENTRAL: Colinas verdes del bosque templado con cueva del oso y pinos
    final colinaBosque = Path()
      ..moveTo(0, h * 0.36)
      ..quadraticBezierTo(w * 0.35, h * 0.29, w * 0.68, h * 0.35)
      ..quadraticBezierTo(w * 0.85, h * 0.38, w, h * 0.36)
      ..lineTo(w, h * 0.70)
      ..lineTo(0, h * 0.70)
      ..close();
    canvas.drawPath(
      colinaBosque,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF86EFAC), Color(0xFF4ADE80), Color(0xFF22C55E)],
        ).createShader(colinaBosque.getBounds()),
    );

    // Cueva rocosa del bosque templado (hogar del oso)
    final cueva = Path()
      ..moveTo(w * 0.33, h * 0.56)
      ..quadraticBezierTo(w * 0.40, h * 0.36, w * 0.47, h * 0.56)
      ..close();
    canvas.drawPath(cueva, Paint()..color = const Color(0xFF64748B));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.40, h * 0.52),
        width: w * 0.07,
        height: h * 0.08,
      ),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Pinos del bosque templado
    for (final tx in [0.31, 0.48, 0.55]) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(w * tx, h * 0.47), width: 6, height: 18),
        Paint()..color = const Color(0xFF78350F),
      );
      final copaPino = Path()
        ..moveTo(w * tx, h * 0.31)
        ..lineTo(w * tx - 14, h * 0.45)
        ..lineTo(w * tx + 14, h * 0.45)
        ..close();
      canvas.drawPath(copaPino, Paint()..color = const Color(0xFF15803D));
    }

    // BIOMA DESIERTO DE DUNAS CÁLIDAS (izquierda-media) con dunas curvas y cactus saguaro
    final dunas = Path()
      ..moveTo(0, h * 0.43)
      ..quadraticBezierTo(w * 0.16, h * 0.36, w * 0.30, h * 0.54)
      ..quadraticBezierTo(w * 0.22, h * 0.67, 0, h * 0.69)
      ..close();
    canvas.drawPath(
      dunas,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
        ).createShader(dunas.getBounds()),
    );
    final pCactus = Paint()
      ..color = const Color(0xFF15803D)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.06, h * 0.48),
      Offset(w * 0.06, h * 0.62),
      pCactus,
    );
    canvas.drawLine(
      Offset(w * 0.035, h * 0.54),
      Offset(w * 0.085, h * 0.54),
      pCactus,
    );

    // BIOMA CHARCA Y HUMEDAL DULCE (derecha-media) con juncos y nenúfares
    final charca = Rect.fromCenter(
      center: Offset(w * 0.72, h * 0.56),
      width: w * 0.42,
      height: h * 0.20,
    );
    canvas.drawOval(
      charca,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF7DD3FC), Color(0xFF0284C7)],
        ).createShader(charca),
    );
    for (final (nx, ny) in [(0.64, 0.56), (0.76, 0.58), (0.84, 0.54)]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * nx, h * ny), width: 20, height: 10),
        Paint()..color = const Color(0xFF22C55E),
      );
    }

    // 5. BIOMA OCÉANO Y ARRECIFE DE CORAL (franja inferior curva con olas y corales)
    final marPath = Path()
      ..moveTo(0, h * 0.69)
      ..quadraticBezierTo(w * 0.25, h * 0.65, w * 0.50, h * 0.69)
      ..quadraticBezierTo(w * 0.75, h * 0.73, w, h * 0.68)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      marPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0EA5E9), Color(0xFF0369A1), Color(0xFF1E3A8A)],
        ).createShader(Rect.fromLTWH(0, h * 0.66, w, h * 0.34)),
    );
    final pOla = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final olaPath = Path();
    for (var i = 0; i <= 24; i++) {
      final ox = (i / 24.0) * w;
      final oy =
          h * 0.71 + math.sin((i * 0.6) + progresoAnim * 2 * math.pi) * 3.2;
      if (i == 0) {
        olaPath.moveTo(ox, oy);
      } else {
        olaPath.lineTo(ox, oy);
      }
    }
    canvas.drawPath(olaPath, pOla);

    // Arrecife de coral, algas marinas y cueva submarina del pulpo
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.54, h * 0.95),
        width: 78,
        height: 28,
      ),
      Paint()..color = const Color(0xFF334155),
    );
    for (final (ax, colorCoral) in [
      (0.12, const Color(0xFF10B981)),
      (0.44, const Color(0xFFF43F5E)),
      (0.66, const Color(0xFFF59E0B)),
      (0.88, const Color(0xFF10B981)),
    ]) {
      final alga = Path()
        ..moveTo(w * ax, h)
        ..quadraticBezierTo(w * ax - 6, h * 0.88, w * ax + 4, h * 0.80);
      canvas.drawPath(
        alga,
        Paint()
          ..color = colorCoral
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Acción «Alimentar»: comida reconocible en cada bioma (bayas, bellotas, hojas, pececillos) y corazones ♥
    if (efectoActivo) {
      final rebote = math.sin(progresoAnim * 4 * math.pi) * 3.5;

      // Bayas tropicales rojas en la rama de la selva (para el tucán)
      for (final (bx, by) in [(0.14, 0.25), (0.16, 0.27), (0.22, 0.26)]) {
        final c = Offset(w * bx, h * by + rebote * 0.5);
        canvas.drawCircle(c, 5.2, Paint()..color = const Color(0xFFEF4444));
        canvas.drawCircle(
          c,
          5.2,
          Paint()
            ..color = const Color(0xFF7F1D1D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        canvas.drawCircle(
          c + const Offset(-1.5, -1.5),
          1.4,
          Paint()..color = Colors.white,
        );
      }

      // Bellotas y miel dorada en el bosque templado (para el oso y el zorro)
      for (final (ax, ay) in [(0.36, 0.55), (0.49, 0.56), (0.58, 0.42)]) {
        final c = Offset(w * ax, h * ay + rebote * 0.4);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 9, height: 11),
          Paint()..color = const Color(0xFFD97706),
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: c + const Offset(0, -3),
            width: 11,
            height: 7,
          ),
          math.pi,
          math.pi,
          true,
          Paint()..color = const Color(0xFF78350F),
        );
      }

      // Brotes verdes tiernos en el desierto y la charca
      for (final (hx, hy) in [(0.19, 0.57), (0.66, 0.53), (0.78, 0.59)]) {
        final c = Offset(w * hx, h * hy + rebote * 0.4);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 11, height: 6),
          Paint()..color = const Color(0xFF22C55E),
        );
      }

      // Pececillos plateados en el hielo y el mar (para pingüino, delfín y pulpo)
      for (final (px, py) in [
        (0.82, 0.34),
        (0.28, 0.82),
        (0.56, 0.85),
        (0.78, 0.83),
      ]) {
        final c = Offset(w * px + rebote, h * py);
        canvas.drawOval(
          Rect.fromCenter(center: c, width: 13, height: 6.5),
          Paint()..color = const Color(0xFFE2E8F0),
        );
        final colaPez = Path()
          ..moveTo(c.dx - 6, c.dy)
          ..lineTo(c.dx - 11, c.dy - 4)
          ..lineTo(c.dx - 11, c.dy + 4)
          ..close();
        canvas.drawPath(colaPez, Paint()..color = const Color(0xFF94A3B8));
        canvas.drawCircle(
          c + const Offset(3.5, -0.5),
          1.1,
          Paint()..color = const Color(0xFF0F172A),
        );
      }

      // Corazones de bienestar animal ascendiendo suavemente
      for (final (cxHeart, cyBase) in [
        (0.15, 0.16),
        (0.42, 0.42),
        (0.72, 0.46),
        (0.86, 0.20),
        (0.32, 0.74),
        (0.68, 0.76),
      ]) {
        final dyFlotante = ((progresoAnim * 1.5 + cxHeart) % 1.0) * 18.0;
        _pintarCorazonMini(
          canvas,
          Offset(w * cxHeart, h * cyBase - dyFlotante),
          6.5,
          const Color(0xFFF43F5E),
        );
      }
    }
  }

  void _pintarMapaBotanicoTerrenos(
    Canvas canvas,
    double w,
    double h,
    Rect rect,
  ) {
    // 1. Cielo luminoso y cálido con sol radiante y haces de luz
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: modoAmbiente == 0
              ? const [Color(0xFF7DD3FC), Color(0xFFE0F2FE), Color(0xFFFEF9C3)]
              : const [Color(0xFFFDE047), Color(0xFFFEF3C7), Color(0xFFDCFCE7)],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.45)),
    );

    final sol = Offset(w * 0.48, h * 0.09);
    for (var i = 0; i < 7; i++) {
      final ang = (i / 6.0) * math.pi;
      final rayo = Path()
        ..moveTo(sol.dx, sol.dy)
        ..lineTo(
          sol.dx + math.cos(ang) * w * 0.45,
          sol.dy + math.sin(ang) * h * 0.45,
        )
        ..lineTo(
          sol.dx + math.cos(ang + 0.12) * w * 0.45,
          sol.dy + math.sin(ang + 0.12) * h * 0.45,
        )
        ..close();
      canvas.drawPath(
        rayo,
        Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.18),
      );
    }
    canvas.drawCircle(
      sol,
      22,
      Paint()..color = const Color(0xFFFEF08A).withValues(alpha: 0.55),
    );
    canvas.drawCircle(sol, 13, Paint()..color = const Color(0xFFFACC15));

    // 2. TERRENO 1 (Arriba-Izquierda): DEHESA Y BOSQUE MEDITERRÁNEO (para la Encina)
    final dehesa = Path()
      ..moveTo(0, h * 0.18)
      ..quadraticBezierTo(w * 0.18, h * 0.13, w * 0.36, h * 0.24)
      ..lineTo(w * 0.36, h * 0.48)
      ..lineTo(0, h * 0.48)
      ..close();
    canvas.drawPath(
      dehesa,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF86EFAC), Color(0xFF15803D)],
        ).createShader(dehesa.getBounds()),
    );

    // 3. TERRENO 2 (Arriba-Centro): PRADERA FLORIDA CON COLMENA (para la Flor y Fotosíntesis)
    final praderaFlorida = Path()
      ..moveTo(w * 0.32, h * 0.22)
      ..quadraticBezierTo(w * 0.50, h * 0.16, w * 0.70, h * 0.24)
      ..lineTo(w * 0.70, h * 0.48)
      ..lineTo(w * 0.32, h * 0.48)
      ..close();
    canvas.drawPath(
      praderaFlorida,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBEF264), Color(0xFF4ADE80)],
        ).createShader(praderaFlorida.getBounds()),
    );

    // Colmena de madera tradicional en la pradera para que las abejas polinicen
    final colmenaPos = Offset(w * 0.61, h * 0.23);
    canvas.drawRect(
      Rect.fromCenter(
        center: colmenaPos + const Offset(0, 10),
        width: 4,
        height: 10,
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: colmenaPos + Offset(0, (2 - i) * 4.5 - 3),
            width: 18.0 - i * 3.0,
            height: 5.5,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFF59E0B),
      );
    }
    canvas.drawCircle(
      colmenaPos,
      2.2,
      Paint()..color = const Color(0xFF451A03),
    );

    // 4. TERRENO 3 (Arriba-Derecha): MONTE BAJO PEDREGOSO Y SOLEADO (para el Romero)
    final laderaRocosa = Path()
      ..moveTo(w * 0.66, h * 0.22)
      ..quadraticBezierTo(w * 0.84, h * 0.13, w, h * 0.19)
      ..lineTo(w, h * 0.48)
      ..lineTo(w * 0.66, h * 0.48)
      ..close();
    canvas.drawPath(
      laderaRocosa,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
        ).createShader(laderaRocosa.getBounds()),
    );
    // Rocas calizas del matorral mediterráneo
    for (final (rx, ry, rw, rh) in [
      (0.75, 0.30, 22.0, 12.0),
      (0.91, 0.33, 26.0, 14.0),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * rx, h * ry), width: rw, height: rh),
        Paint()..color = const Color(0xFFCBD5E1),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * rx, h * ry), width: rw, height: rh),
        Paint()
          ..color = const Color(0xFF64748B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // 5. TERRENO 4 (Media-Izquierda): RIBERA HÚMEDA Y ARROYO CRISTALINO (para Hoja y Tallo)
    final ribera = Path()
      ..moveTo(0, h * 0.44)
      ..quadraticBezierTo(w * 0.20, h * 0.41, w * 0.40, h * 0.46)
      ..lineTo(w * 0.40, h * 0.72)
      ..lineTo(0, h * 0.72)
      ..close();
    canvas.drawPath(
      ribera,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
        ).createShader(ribera.getBounds()),
    );
    // Arroyo serpenteante de agua dulce
    final arroyo = Path()
      ..moveTo(0, h * 0.56)
      ..quadraticBezierTo(w * 0.14, h * 0.50, w * 0.26, h * 0.58)
      ..quadraticBezierTo(w * 0.34, h * 0.63, w * 0.40, h * 0.60);
    canvas.drawPath(
      arroyo,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      arroyo,
      Paint()
        ..color = const Color(0xFFBAE6FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round,
    );

    // 6. TERRENO 5 (Media-Centro): VERGEL Y HUERTA DE CULTIVO CON SURCOS (para Fruto, Semilla y Huerto)
    final huerta = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.37, h * 0.46, w * 0.31, h * 0.25),
      const Radius.circular(12),
    );
    canvas.drawRRect(huerta, Paint()..color = const Color(0xFF92400E));
    canvas.drawRRect(
      huerta,
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // Surcos de tierra fértil labrada
    for (var i = 1; i <= 3; i++) {
      final sy = h * (0.46 + i * 0.06);
      canvas.drawLine(
        Offset(w * 0.39, sy),
        Offset(w * 0.66, sy),
        Paint()
          ..color = const Color(0xFF78350F)
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // 7. TERRENO 6 (Media-Derecha): CAMPIÑA DORADA DE SECANO (para el Trigo)
    final campina = Path()
      ..moveTo(w * 0.66, h * 0.45)
      ..quadraticBezierTo(w * 0.84, h * 0.42, w, h * 0.46)
      ..lineTo(w, h * 0.72)
      ..lineTo(w * 0.66, h * 0.72)
      ..close();
    canvas.drawPath(
      campina,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDE047), Color(0xFFEAB308)],
        ).createShader(campina.getBounds()),
    );

    // 8. TERRENO 7 (Franja Inferior): CORTE DEL SUBSUELO MINERAL Y ACUÍFERO (para la Raíz y Semilla)
    final subsuelo = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.25, h * 0.67, w * 0.50, h * 0.70)
      ..quadraticBezierTo(w * 0.75, h * 0.73, w, h * 0.69)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      subsuelo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF78350F), Color(0xFF5C2D0C), Color(0xFF3B1A06)],
        ).createShader(Rect.fromLTWH(0, h * 0.67, w, h * 0.33)),
    );
    // Venas de agua subterránea y sales minerales brillantes
    final pVenaAgua = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.08, h * 0.86)
        ..quadraticBezierTo(w * 0.28, h * 0.80, w * 0.46, h * 0.88)
        ..quadraticBezierTo(w * 0.68, h * 0.94, w * 0.90, h * 0.85),
      pVenaAgua,
    );

    // 9. ELEMENTOS DINÁMICOS DEL ECOSISTEMA BOTÁNICO (Viento suave, abejas polinizadoras y mariposa)
    final ang = progresoAnim * 2 * math.pi;
    final pBrisa = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    for (final (bx, by) in [(0.16, 0.12), (0.64, 0.11), (0.76, 0.52)]) {
      final dxBrisa = math.sin(ang + bx * 5) * 10.0;
      final brisa = Path()
        ..moveTo(w * bx + dxBrisa, h * by)
        ..quadraticBezierTo(
          w * (bx + 0.06) + dxBrisa,
          h * (by - 0.02),
          w * (bx + 0.12) + dxBrisa,
          h * by,
        );
      canvas.drawPath(brisa, pBrisa);
    }

    // 2 Abejas melíferas animadas volando entre la colmena, la flor y el romero
    final abeja1 = Offset(
      w * 0.46 + math.cos(ang) * w * 0.12,
      h * 0.24 + math.sin(ang * 2) * h * 0.05,
    );
    final abeja2 = Offset(
      w * 0.74 + math.sin(ang) * w * 0.10,
      h * 0.27 + math.cos(ang * 2) * h * 0.04,
    );
    _pintarAbejaMini(canvas, abeja1);
    _pintarAbejaMini(canvas, abeja2);

    // Acción «Regar»: lluvia azul diagonal, ondas de agua en los terrenos y polen dorado (nunca bolas blancas)
    if (efectoActivo) {
      final pGota = Paint()
        ..color = const Color(0xFF0284C7)
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      final pOnda = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      for (var i = 0; i < 16; i++) {
        final gx = ((i * 61) % 94 + 3) / 100.0 * w;
        final gy = (((i * 37) % 100) / 100.0 + progresoAnim * 0.9) % 0.82 * h;
        canvas.drawLine(Offset(gx, gy), Offset(gx - 3.5, gy + 9.0), pGota);
        if (i.isEven) {
          final ry = h * (0.42 + (i % 4) * 0.11);
          canvas.drawOval(
            Rect.fromCenter(center: Offset(gx, ry), width: 14, height: 5),
            pOnda,
          );
        }
      }
      // Polen dorado flotando entre las flores
      for (var i = 0; i < 8; i++) {
        final px = w * (0.34 + (i * 0.07)) + math.sin(ang + i) * 6.0;
        final py = h * (0.24 + (i % 3) * 0.06) + math.cos(ang + i) * 4.0;
        canvas.drawCircle(
          Offset(px, py),
          2.6,
          Paint()..color = const Color(0xFFFACC15),
        );
      }
    }
  }

  void _pintarEstacionAnatomicaCuerpo(
    Canvas canvas,
    double w,
    double h,
    Rect rect,
  ) {
    // 1. Fondo clínico-científico cálido con cuadrícula de atlas biomédico
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: modoAmbiente == 0
              ? const [Color(0xFFF8FAFC), Color(0xFFEFF6FF), Color(0xFFF0FDF4)]
              : const [Color(0xFFFAF5FF), Color(0xFFEFF6FF), Color(0xFFECFDF5)],
        ).createShader(rect),
    );

    final pGrid = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.35)
      ..strokeWidth = 1.0;
    for (var x = 24.0; x < w; x += 24.0) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), pGrid);
    }
    for (var y = 24.0; y < h; y += 24.0) {
      canvas.drawLine(Offset(0, y), Offset(w, y), pGrid);
    }

    // 2. Tres paneles científicos estructurados:
    // Panel Izquierdo: Relación, Sentidos y Locomotor (x: 0.02..0.28)
    final panelIzq = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.02, h * 0.04, w * 0.26, h * 0.92),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      panelIzq,
      Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.65),
    );
    canvas.drawRRect(
      panelIzq,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Panel Derecho: Nutrición Celular, Desarrollo y Hábitos (x: 0.72..0.98)
    final panelDer = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.72, h * 0.04, w * 0.26, h * 0.92),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      panelDer,
      Paint()..color = const Color(0xFFDCFCE7).withValues(alpha: 0.65),
    );
    canvas.drawRRect(
      panelDer,
      Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // 3. Figura humana anatómica amplia y proporcionada en el Panel Central (x: 0.31..0.69)
    final cx = w * 0.50;
    final pPiel = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE68A), Color(0xFFFDBA74)],
      ).createShader(Rect.fromLTWH(w * 0.32, h * 0.04, w * 0.36, h * 0.94));
    final pBordeCuerpo = Paint()
      ..color = const Color(0xFF9A3412)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Cabeza amplia para alojar cerebro (0.13) y boca/dientes (0.28) sin solaparse
    final rectCabeza = Rect.fromCenter(
      center: Offset(cx, h * 0.20),
      width: w * 0.20,
      height: h * 0.28,
    );
    canvas.drawOval(rectCabeza, pPiel);
    canvas.drawOval(rectCabeza, pBordeCuerpo);

    // Cavidad craneal translúcida superior
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.135),
        width: w * 0.15,
        height: h * 0.12,
      ),
      Paint()..color = const Color(0xFFFFF1F2).withValues(alpha: 0.85),
    );

    // Cuello, hombros, brazos, torso amplio y piernas
    final siluetaCuerpo = Path()
      ..moveTo(cx - w * 0.04, h * 0.33)
      ..lineTo(cx + w * 0.04, h * 0.33)
      ..lineTo(cx + w * 0.15, h * 0.37)
      ..quadraticBezierTo(cx + w * 0.18, h * 0.40, cx + w * 0.18, h * 0.66)
      ..lineTo(cx + w * 0.14, h * 0.66)
      ..lineTo(cx + w * 0.13, h * 0.44)
      ..lineTo(cx + w * 0.12, h * 0.86)
      ..lineTo(cx + w * 0.10, h * 0.97)
      ..lineTo(cx + w * 0.03, h * 0.97)
      ..lineTo(cx + w * 0.02, h * 0.88)
      ..lineTo(cx - w * 0.02, h * 0.88)
      ..lineTo(cx - w * 0.03, h * 0.97)
      ..lineTo(cx - w * 0.10, h * 0.97)
      ..lineTo(cx - w * 0.12, h * 0.86)
      ..lineTo(cx - w * 0.13, h * 0.44)
      ..lineTo(cx - w * 0.14, h * 0.66)
      ..lineTo(cx - w * 0.18, h * 0.66)
      ..quadraticBezierTo(cx - w * 0.18, h * 0.40, cx - w * 0.15, h * 0.37)
      ..close();
    canvas.drawPath(siluetaCuerpo, pPiel);
    canvas.drawPath(siluetaCuerpo, pBordeCuerpo);

    // Ventana anatómica torácica y abdominal amplia (aloja pulmones/corazón, digestivo/estómago e intestinos)
    final cavidadTorso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, h * 0.63),
        width: w * 0.24,
        height: h * 0.48,
      ),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      cavidadTorso,
      Paint()..color = const Color(0xFFFFF7ED).withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      cavidadTorso,
      Paint()
        ..color = const Color(0xFFEA580C).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Diafragma separando tórax (y=0.45) y abdomen (y=0.63..0.82)
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, h * 0.54),
        width: w * 0.21,
        height: h * 0.05,
      ),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFE11D48).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 4. Líneas de conexión neural (columna izquierda -> cerebro/médula) y metabólica (torso -> columna derecha)
    final pNervio = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    for (final (xNodo, yNodo) in [
      (0.15, 0.14),
      (0.15, 0.39),
      (0.15, 0.63),
      (0.15, 0.87),
    ]) {
      final rutaIzq = Path()
        ..moveTo(w * xNodo, h * yNodo)
        ..quadraticBezierTo(
          w * 0.30,
          h * yNodo,
          cx,
          h * (yNodo < 0.5 ? 0.12 : 0.46),
        );
      canvas.drawPath(rutaIzq, pNervio);
    }

    final pArteria = Paint()
      ..color = const Color(0xFFE11D48).withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    for (final (xNodo, yNodo) in [
      (0.85, 0.14),
      (0.85, 0.39),
      (0.85, 0.63),
      (0.85, 0.87),
    ]) {
      final rutaDer = Path()
        ..moveTo(cx + w * 0.08, h * 0.46)
        ..quadraticBezierTo(w * 0.70, h * yNodo, w * xNodo, h * yNodo);
      canvas.drawPath(rutaDer, pArteria);
    }

    // 5. Acción «Impulso»: impulsos nerviosos dorados viajando al cerebro y ondas arteriales rojas desde el corazón
    if (efectoActivo) {
      final t = progresoAnim;
      final cCorazon = Offset(cx + w * 0.09, h * 0.46);
      for (var i = 0; i < 3; i++) {
        final faseOnda = (t + i / 3.0) % 1.0;
        canvas.drawCircle(
          cCorazon,
          12.0 + faseOnda * 56.0,
          Paint()
            ..color = const Color(0xFFE11D48)
                .withValues(alpha: (1.0 - faseOnda) * 0.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }

      final nodosIzq = [(0.15, 0.14), (0.15, 0.39), (0.15, 0.63), (0.15, 0.87)];
      for (var i = 0; i < nodosIzq.length; i++) {
        final (xOr, yOr) = nodosIzq[i];
        final avance = (t * 1.6 + i * 0.25) % 1.0;
        final px = w * xOr + (cx - w * xOr) * avance;
        final py = h * yOr + (h * 0.12 - h * yOr) * avance;
        canvas.drawCircle(
          Offset(px, py),
          5.5,
          Paint()..color = const Color(0xFFFACC15).withValues(alpha: 0.45),
        );
        canvas.drawCircle(
          Offset(px, py),
          3.0,
          Paint()..color = const Color(0xFFFEF08A),
        );
      }

      final nodosDer = [(0.85, 0.14), (0.85, 0.39), (0.85, 0.63), (0.85, 0.87)];
      for (var i = 0; i < nodosDer.length; i++) {
        final (xDest, yDest) = nodosDer[i];
        final avance = (t * 1.4 + i * 0.22) % 1.0;
        final px = cCorazon.dx + (w * xDest - cCorazon.dx) * avance;
        final py = cCorazon.dy + (h * yDest - cCorazon.dy) * avance;
        canvas.drawCircle(
          Offset(px, py),
          3.5,
          Paint()..color = const Color(0xFF10B981),
        );
      }
    }
  }

  void _pintarAbejaMini(Canvas canvas, Offset c) {
    // Alitas translúcidas superiores
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(-2, -4), width: 6, height: 4),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawOval(
      Rect.fromCenter(center: c + const Offset(2, -4), width: 6, height: 4),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    // Cuerpo amarillo con rayas negras
    final rCuerpo = Rect.fromCenter(center: c, width: 10, height: 6.5);
    canvas.drawOval(rCuerpo, Paint()..color = const Color(0xFFFACC15));
    canvas.drawOval(
      rCuerpo,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      c + const Offset(-1, -2.8),
      c + const Offset(-1, 2.8),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      c + const Offset(2, -2.5),
      c + const Offset(2, 2.5),
      Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 1.5,
    );
  }

  void _pintarCorazonMini(Canvas canvas, Offset c, double r, Color color) {
    final path = Path()
      ..moveTo(c.dx, c.dy + r * 0.65)
      ..cubicTo(
        c.dx - r * 1.1,
        c.dy + r * 0.1,
        c.dx - r * 0.9,
        c.dy - r * 0.7,
        c.dx - r * 0.4,
        c.dy - r * 0.7,
      )
      ..cubicTo(
        c.dx - r * 0.1,
        c.dy - r * 0.7,
        c.dx,
        c.dy - r * 0.35,
        c.dx,
        c.dy - r * 0.2,
      )
      ..cubicTo(
        c.dx,
        c.dy - r * 0.35,
        c.dx + r * 0.1,
        c.dy - r * 0.7,
        c.dx + r * 0.4,
        c.dy - r * 0.7,
      )
      ..cubicTo(
        c.dx + r * 0.9,
        c.dy - r * 0.7,
        c.dx + r * 1.1,
        c.dy + r * 0.1,
        c.dx,
        c.dy + r * 0.65,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(covariant PintorBiomasSantuarioDetallado oldDelegate) {
    return oldDelegate.progresoAnim != progresoAnim ||
        oldDelegate.efectoActivo != efectoActivo ||
        oldDelegate.modoAmbiente != modoAmbiente ||
        oldDelegate.zonaId != zonaId;
  }
}
