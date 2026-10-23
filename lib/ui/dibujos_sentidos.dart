import 'dart:math' as math;

import 'package:flutter/material.dart';

const idsSentidos = <String>{
  'vista',
  'oido',
  'olfato',
  'gusto',
  'tacto',
  'ojos',
  'orejas',
  'nariz',
  'lengua',
  'piel',
  'arcoiris',
  'tambor',
  'jazmin',
  'fresa',
  'peluche',
  'tostada',
  'ducha',
  'timbre',
  'limon',
  'semaforo',
  'arena',
  'cazuela',
  'nombre',
  'verde',
  'leche',
  'incendio',
};

class DibujoSentido extends StatelessWidget {
  const DibujoSentido({required this.id, this.tamano = 64, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final idNormalizado = switch (id) {
      'vista' => 'ojos',
      'oido' => 'orejas',
      'olfato' => 'nariz',
      'gusto' => 'lengua',
      'tacto' => 'piel',
      _ => id,
    };
    return construirDibujoSentidos(
      id: idNormalizado,
      color: const Color(0xFF1E293B),
      tamano: tamano,
      key: ValueKey('dibujo-sentido-$id'),
    );
  }
}

Widget construirDibujoSentidos({
  required String id,
  required Color color,
  required double tamano,
  required Key key,
}) {
  switch (id) {
    case 'ojos':
      return SizedBox(
        key: key,
        width: tamano,
        height: tamano,
        child: CustomPaint(painter: _Ojos(color)),
      );
    case 'orejas':
      return SizedBox(
        key: key,
        width: tamano,
        height: tamano,
        child: CustomPaint(painter: _Oreja(color)),
      );
    case 'nariz':
      return SizedBox(
        key: key,
        width: tamano,
        height: tamano,
        child: CustomPaint(painter: _Nariz(color)),
      );
    case 'lengua':
      return SizedBox(
        key: key,
        width: tamano,
        height: tamano,
        child: CustomPaint(painter: _Lengua(color)),
      );
    case 'piel':
      return SizedBox(
        key: key,
        width: tamano,
        height: tamano,
        child: CustomPaint(painter: _Mano(color)),
      );
    default:
      return SizedBox(
        key: key,
        width: tamano,
        height: tamano,
        child: CustomPaint(painter: _PintorSituacionSentido(id, color)),
      );
  }
}

class _Ojos extends CustomPainter {
  _Ojos(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Fondo suave circular
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.42,
      Paint()..color = const Color(0xFFE3F2FD).withValues(alpha: 0.7),
    );

    for (final cx in [w * 0.30, w * 0.70]) {
      final ojoPath = Path()
        ..moveTo(cx - w * 0.17, h * 0.54)
        ..quadraticBezierTo(cx, h * 0.36, cx + w * 0.17, h * 0.54)
        ..quadraticBezierTo(cx, h * 0.72, cx - w * 0.17, h * 0.54)
        ..close();

      canvas.drawPath(ojoPath, Paint()..color = Colors.white);
      canvas.drawPath(ojoPath, trazo);

      // Iris azul celeste
      canvas.drawCircle(
        Offset(cx, h * 0.54),
        w * 0.085,
        Paint()..color = const Color(0xFF29B6F6),
      );
      // Pupila
      canvas.drawCircle(
        Offset(cx, h * 0.54),
        w * 0.045,
        Paint()..color = const Color(0xFF1A2530),
      );
      // Brillo vivo
      canvas.drawCircle(
        Offset(cx - w * 0.024, h * 0.515),
        w * 0.02,
        Paint()..color = Colors.white,
      );

      // Ceja expresiva y pestañas
      final ceja = Path()
        ..moveTo(cx - w * 0.14, h * 0.36)
        ..quadraticBezierTo(cx, h * 0.28, cx + w * 0.14, h * 0.36);
      canvas.drawPath(ceja, trazo);
    }
  }

  @override
  bool shouldRepaint(covariant _Ojos oldDelegate) => oldDelegate.color != color;
}

class _Oreja extends CustomPainter {
  _Oreja(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.42,
      Paint()..color = const Color(0xFFF3E5F5).withValues(alpha: 0.75),
    );

    final pabellon = Path()
      ..moveTo(w * 0.34, h * 0.30)
      ..cubicTo(w * 0.24, h * 0.12, w * 0.72, h * 0.12, w * 0.68, h * 0.46)
      ..cubicTo(w * 0.66, h * 0.68, w * 0.56, h * 0.86, w * 0.38, h * 0.80)
      ..quadraticBezierTo(w * 0.28, h * 0.74, w * 0.32, h * 0.62);
    canvas.drawPath(
      pabellon,
      Paint()..color = const Color(0xFFFFCCBC),
    );
    canvas.drawPath(pabellon, trazo);

    final pliegue = Path()
      ..moveTo(w * 0.42, h * 0.34)
      ..cubicTo(w * 0.58, h * 0.30, w * 0.58, h * 0.58, w * 0.42, h * 0.62);
    canvas.drawPath(pliegue, trazo);

    // Ondas sonoras vibrantes entrando al oído
    final ondaPaint = Paint()
      ..color = const Color(0xFF8E24AA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.66, h * 0.48), radius: w * 0.14),
      -0.7,
      1.4,
      false,
      ondaPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.66, h * 0.48), radius: w * 0.23),
      -0.7,
      1.4,
      false,
      ondaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _Oreja oldDelegate) =>
      oldDelegate.color != color;
}

class _Nariz extends CustomPainter {
  _Nariz(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.42,
      Paint()..color = const Color(0xFFE8F5E9).withValues(alpha: 0.78),
    );

    final silueta = Path()
      ..moveTo(w * 0.48, h * 0.20)
      ..lineTo(w * 0.36, h * 0.56)
      ..quadraticBezierTo(w * 0.24, h * 0.64, w * 0.34, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.78, w * 0.66, h * 0.72)
      ..quadraticBezierTo(w * 0.76, h * 0.64, w * 0.64, h * 0.56)
      ..lineTo(w * 0.54, h * 0.20);

    canvas.drawPath(silueta, Paint()..color = const Color(0xFFFFCCBC));
    canvas.drawPath(silueta, trazo);

    // Fosas nasales
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.41, h * 0.67),
        width: w * 0.08,
        height: h * 0.045,
      ),
      Paint()..color = color,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.59, h * 0.67),
        width: w * 0.08,
        height: h * 0.045,
      ),
      Paint()..color = color,
    );

    // Estelas aromáticas verdes
    final aromaPaint = Paint()
      ..color = const Color(0xFF43A047)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    final aromaIzq = Path()
      ..moveTo(w * 0.38, h * 0.86)
      ..quadraticBezierTo(w * 0.30, h * 0.79, w * 0.39, h * 0.74);
    final aromaDer = Path()
      ..moveTo(w * 0.62, h * 0.86)
      ..quadraticBezierTo(w * 0.70, h * 0.79, w * 0.61, h * 0.74);
    canvas.drawPath(aromaIzq, aromaPaint);
    canvas.drawPath(aromaDer, aromaPaint);
  }

  @override
  bool shouldRepaint(covariant _Nariz oldDelegate) =>
      oldDelegate.color != color;
}

class _Lengua extends CustomPainter {
  _Lengua(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.42,
      Paint()..color = const Color(0xFFFCE4EC).withValues(alpha: 0.78),
    );

    // Sonrisa / boca abierta
    final boca = Path()
      ..moveTo(w * 0.22, h * 0.38)
      ..quadraticBezierTo(w * 0.50, h * 0.46, w * 0.78, h * 0.38)
      ..quadraticBezierTo(w * 0.74, h * 0.68, w * 0.50, h * 0.68)
      ..quadraticBezierTo(w * 0.26, h * 0.68, w * 0.22, h * 0.38)
      ..close();
    canvas.drawPath(boca, Paint()..color = const Color(0xFF6D1B28));
    canvas.drawPath(boca, trazo);

    // Lengua rosada con papilas gustativas
    final lengua = Path()
      ..moveTo(w * 0.33, h * 0.46)
      ..lineTo(w * 0.33, h * 0.68)
      ..quadraticBezierTo(w * 0.50, h * 0.88, w * 0.67, h * 0.68)
      ..lineTo(w * 0.67, h * 0.46)
      ..close();
    canvas.drawPath(lengua, Paint()..color = const Color(0xFFF06292));
    canvas.drawPath(lengua, trazo);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.48),
      Offset(w * 0.50, h * 0.74),
      trazo,
    );
    // Papilas gustativas
    for (final pt in [
      Offset(w * 0.41, h * 0.62),
      Offset(w * 0.59, h * 0.62),
      Offset(w * 0.44, h * 0.71),
      Offset(w * 0.56, h * 0.71),
    ]) {
      canvas.drawCircle(
        pt,
        w * 0.022,
        Paint()..color = const Color(0xFFFCE4EC),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Lengua oldDelegate) =>
      oldDelegate.color != color;
}

class _Mano extends CustomPainter {
  _Mano(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final relleno = Paint()
      ..color = const Color(0xFFFFCCBC)
      ..style = PaintingStyle.fill;
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.52),
      w * 0.42,
      Paint()..color = const Color(0xFFFFF3E0).withValues(alpha: 0.82),
    );

    final palma = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.44, w * 0.44, h * 0.36),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(palma, relleno);
    canvas.drawRRect(palma, trazo);

    const xs = [0.31, 0.41, 0.51, 0.61];
    const hs = [0.24, 0.29, 0.27, 0.21];
    for (var i = 0; i < xs.length; i++) {
      final dedo = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          w * xs[i],
          h * (0.46 - hs[i]),
          w * 0.09,
          h * hs[i],
        ),
        Radius.circular(w * 0.045),
      );
      canvas.drawRRect(dedo, relleno);
      canvas.drawRRect(dedo, trazo);
    }

    final pulgar = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.17, h * 0.48, w * 0.15, h * 0.11),
      Radius.circular(w * 0.055),
    );
    canvas.drawRRect(pulgar, relleno);
    canvas.drawRRect(pulgar, trazo);

    // Ondas táctiles en las yemas
    final tactoPaint = Paint()
      ..color = const Color(0xFFFB8C00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.46, h * 0.18), radius: w * 0.10),
      -2.4,
      1.6,
      false,
      tactoPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _Mano oldDelegate) => oldDelegate.color != color;
}

class _PintorSituacionSentido extends CustomPainter {
  _PintorSituacionSentido(this.id, this.color);

  final String id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Medallón de escena ilustrado
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.45,
      Paint()..color = color.withValues(alpha: 0.11),
    );
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.45,
      Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.025,
    );

    switch (id) {
      case 'humo':
        _pintarHumoTostada(canvas, w, h, trazo);
        return;
      case 'piscina':
        _pintarPiscina(canvas, w, h, trazo);
        return;
      case 'timbre':
        _pintarTimbre(canvas, w, h, trazo);
        return;
      case 'limon':
        _pintarLimon(canvas, w, h, trazo);
        return;
      case 'semaforo':
        _pintarSemaforo(canvas, w, h, trazo);
        return;
      case 'arena':
        _pintarArenaSol(canvas, w, h, trazo);
        return;
      case 'cazuela':
        _pintarCazuelaSopa(canvas, w, h, trazo);
        return;
      case 'nombre':
        _pintarLlamadaVoz(canvas, w, h, trazo);
        return;
      case 'verde':
        _pintarSemaforoPeatonVerde(canvas, w, h, trazo);
        return;
      case 'leche':
        _pintarVasoLeche(canvas, w, h, trazo);
        return;
      case 'incendio':
        _pintarIncendioBosque(canvas, w, h, trazo);
        return;
      default:
        _pintarLimon(canvas, w, h, trazo);
    }
  }

  void _pintarHumoTostada(Canvas canvas, double w, double h, Paint trazo) {
    // Tostadora roja/metálica
    final cuerpo = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.52, w * 0.52, h * 0.28),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(cuerpo, Paint()..color = const Color(0xFFEF5350));
    canvas.drawRRect(cuerpo, trazo);

    // Tostada oscura asomando
    final tostada = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.38, w * 0.32, h * 0.18),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(tostada, Paint()..color = const Color(0xFF4E342E));
    canvas.drawRRect(tostada, trazo);

    // Columnas de humo gris oscuro subiendo
    final humoPaint = Paint()
      ..color = const Color(0xFF546E7A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    for (final dx in [w * 0.38, w * 0.50, w * 0.62]) {
      final p = Path()
        ..moveTo(dx, h * 0.35)
        ..quadraticBezierTo(dx - w * 0.06, h * 0.25, dx + w * 0.04, h * 0.18)
        ..quadraticBezierTo(dx + w * 0.08, h * 0.12, dx, h * 0.08);
      canvas.drawPath(p, humoPaint);
    }
  }

  void _pintarPiscina(Canvas canvas, double w, double h, Paint trazo) {
    // Agua azul helada con ondas y cristales de frío
    final agua = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.48, w * 0.68, h * 0.32),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(agua, Paint()..color = const Color(0xFF29B6F6));
    canvas.drawRRect(agua, trazo);

    // Olas blancas
    final olaPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    final ola = Path()
      ..moveTo(w * 0.22, h * 0.58)
      ..quadraticBezierTo(w * 0.34, h * 0.51, w * 0.46, h * 0.58)
      ..quadraticBezierTo(w * 0.58, h * 0.65, w * 0.76, h * 0.58);
    canvas.drawPath(ola, olaPaint);

    // Termómetro azul de agua fría + copo
    final bulbo = Offset(w * 0.50, h * 0.36);
    canvas.drawLine(
      Offset(w * 0.50, h * 0.16),
      bulbo,
      Paint()
        ..color = Colors.white
        ..strokeWidth = w * 0.09
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(w * 0.50, h * 0.24),
      bulbo,
      Paint()
        ..color = const Color(0xFF0288D1)
        ..strokeWidth = w * 0.045
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(bulbo, w * 0.065, Paint()..color = const Color(0xFF0288D1));
  }

  void _pintarTimbre(Canvas canvas, double w, double h, Paint trazo) {
    // Campana dorada escolar vibrando
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.48),
      w * 0.24,
      Paint()..color = const Color(0xFFFFCA28),
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.24, trazo);
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.48),
      w * 0.06,
      Paint()..color = const Color(0xFFF57F17),
    );
    // Martillo golpeador
    canvas.drawCircle(
      Offset(w * 0.76, h * 0.34),
      w * 0.055,
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawLine(
      Offset(w * 0.64, h * 0.66),
      Offset(w * 0.76, h * 0.34),
      trazo,
    );
    // Ondas de sonido vibrantes
    final onda = Paint()
      ..color = const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.48), radius: w * 0.33),
      -2.6,
      1.1,
      false,
      onda,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.48), radius: w * 0.39),
      -2.6,
      1.1,
      false,
      onda,
    );
  }

  void _pintarLimon(Canvas canvas, double w, double h, Paint trazo) {
    // Rodaja jugosa de limón amarillo ácido
    final c = Offset(w * 0.50, h * 0.52);
    canvas.drawCircle(c, w * 0.28, Paint()..color = const Color(0xFFFDD835));
    canvas.drawCircle(c, w * 0.23, Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawCircle(c, w * 0.28, trazo);

    for (var i = 0; i < 6; i++) {
      final a = i * (math.pi / 3);
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: w * 0.19),
        a + 0.12,
        (math.pi / 3) - 0.24,
        true,
        Paint()..color = const Color(0xFFFFEE58),
      );
    }
    // Gotas ácidas saltando
    final gotaPaint = Paint()..color = const Color(0xFFFBC02D);
    canvas.drawCircle(Offset(w * 0.24, h * 0.22), w * 0.035, gotaPaint);
    canvas.drawCircle(Offset(w * 0.76, h * 0.24), w * 0.03, gotaPaint);
  }

  void _pintarSemaforo(Canvas canvas, double w, double h, Paint trazo) {
    final caja = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.14, w * 0.36, h * 0.68),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(caja, Paint()..color = const Color(0xFF37474F));
    canvas.drawRRect(caja, trazo);

    // Luz roja encendida con halo brillante
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.28),
      w * 0.13,
      Paint()..color = const Color(0xFFFF5252).withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.28),
      w * 0.085,
      Paint()..color = const Color(0xFFFF1744),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.48),
      w * 0.075,
      Paint()..color = const Color(0xFF616161),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.67),
      w * 0.075,
      Paint()..color = const Color(0xFF616161),
    );
  }

  void _pintarArenaSol(Canvas canvas, double w, double h, Paint trazo) {
    // Sol radiante arriba
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.28),
      w * 0.12,
      Paint()..color = const Color(0xFFFFB300),
    );
    // Duna de arena dorada ardiente con ondas de calor
    final duna = Path()
      ..moveTo(w * 0.14, h * 0.72)
      ..quadraticBezierTo(w * 0.50, h * 0.50, w * 0.86, h * 0.72)
      ..lineTo(w * 0.80, h * 0.82)
      ..lineTo(w * 0.20, h * 0.82)
      ..close();
    canvas.drawPath(duna, Paint()..color = const Color(0xFFFFCA28));
    canvas.drawPath(duna, trazo);

    // Líneas de calor subiendo de la arena
    final calor = Paint()
      ..color = const Color(0xFFFF7043)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    for (final dx in [w * 0.34, w * 0.50, w * 0.66]) {
      final p = Path()
        ..moveTo(dx, h * 0.56)
        ..quadraticBezierTo(dx - w * 0.04, h * 0.48, dx + w * 0.04, h * 0.42);
      canvas.drawPath(p, calor);
    }
  }

  void _pintarCazuelaSopa(Canvas canvas, double w, double h, Paint trazo) {
    // Olla humeante de sopa casera
    final olla = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.46, w * 0.52, h * 0.32),
      Radius.circular(w * 0.07),
    );
    canvas.drawRRect(olla, Paint()..color = const Color(0xFF26A69A));
    canvas.drawRRect(olla, trazo);

    // Caldo dorado en el borde superior
    canvas.drawOval(
      Rect.fromLTWH(w * 0.25, h * 0.42, w * 0.50, h * 0.10),
      Paint()..color = const Color(0xFFFFCC80),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.25, h * 0.42, w * 0.50, h * 0.10),
      trazo,
    );

    // Vapor aromático
    final vapor = Paint()
      ..color = const Color(0xFF66BB6A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;
    for (final dx in [w * 0.38, w * 0.52, w * 0.64]) {
      final p = Path()
        ..moveTo(dx, h * 0.38)
        ..quadraticBezierTo(dx - w * 0.05, h * 0.26, dx + w * 0.04, h * 0.16);
      canvas.drawPath(p, vapor);
    }
  }

  void _pintarLlamadaVoz(Canvas canvas, double w, double h, Paint trazo) {
    // Bocadillo / megáfono de voz llamando por tu nombre
    final bocadillo = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.20, h * 0.24, w * 0.46, h * 0.34),
      Radius.circular(w * 0.10),
    );
    canvas.drawRRect(bocadillo, Paint()..color = const Color(0xFFAB47BC));
    canvas.drawRRect(bocadillo, trazo);

    // Ondas acústicas saliendo
    final onda = Paint()
      ..color = const Color(0xFF7B1FA2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.64, h * 0.42), radius: w * 0.13),
      -0.8,
      1.6,
      false,
      onda,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.64, h * 0.42), radius: w * 0.22),
      -0.8,
      1.6,
      false,
      onda,
    );
  }

  void _pintarSemaforoPeatonVerde(
    Canvas canvas,
    double w,
    double h,
    Paint trazo,
  ) {
    final caja = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.16, w * 0.44, h * 0.66),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(caja, Paint()..color = const Color(0xFF263238));
    canvas.drawRRect(caja, trazo);

    // Luz roja apagada arriba
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.32),
      w * 0.09,
      Paint()..color = const Color(0xFF546E7A),
    );
    // Luz verde peatón brillante abajo
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.62),
      w * 0.15,
      Paint()..color = const Color(0xFF00E676).withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.62),
      w * 0.11,
      Paint()..color = const Color(0xFF00C853),
    );
  }

  void _pintarVasoLeche(Canvas canvas, double w, double h, Paint trazo) {
    final vaso = Path()
      ..moveTo(w * 0.30, h * 0.24)
      ..lineTo(w * 0.35, h * 0.78)
      ..lineTo(w * 0.65, h * 0.78)
      ..lineTo(w * 0.70, h * 0.24)
      ..close();
    canvas.drawPath(vaso, Paint()..color = Colors.white);
    canvas.drawPath(vaso, trazo);

    // Leche dentro del vaso
    final leche = Path()
      ..moveTo(w * 0.32, h * 0.40)
      ..lineTo(w * 0.35, h * 0.76)
      ..lineTo(w * 0.65, h * 0.76)
      ..lineTo(w * 0.68, h * 0.40)
      ..close();
    canvas.drawPath(leche, Paint()..color = const Color(0xFFFFF8E1));

    // Onda aromática/sabor extraño para que olfato y gusto actúen juntos
    final onda = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    final p = Path()
      ..moveTo(w * 0.44, h * 0.20)
      ..quadraticBezierTo(w * 0.40, h * 0.13, w * 0.48, h * 0.09);
    canvas.drawPath(p, onda);
  }

  void _pintarIncendioBosque(Canvas canvas, double w, double h, Paint trazo) {
    // Árboles del bosque + llama naranja + humo + sirena acústica
    final copa = Path()
      ..moveTo(w * 0.28, h * 0.32)
      ..lineTo(w * 0.16, h * 0.64)
      ..lineTo(w * 0.40, h * 0.64)
      ..close();
    canvas.drawPath(copa, Paint()..color = const Color(0xFF43A047));
    canvas.drawPath(copa, trazo);

    // Llama viva
    final llama = Path()
      ..moveTo(w * 0.58, h * 0.72)
      ..quadraticBezierTo(w * 0.42, h * 0.56, w * 0.58, h * 0.32)
      ..quadraticBezierTo(w * 0.74, h * 0.56, w * 0.58, h * 0.72)
      ..close();
    canvas.drawPath(llama, Paint()..color = const Color(0xFFFF5722));
    canvas.drawPath(llama, trazo);

    // Humo subiendo + onda de alarma
    final humo = Paint()
      ..color = const Color(0xFF607D8B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    final p = Path()
      ..moveTo(w * 0.58, h * 0.28)
      ..quadraticBezierTo(w * 0.50, h * 0.18, w * 0.62, h * 0.10);
    canvas.drawPath(p, humo);
  }

  @override
  bool shouldRepaint(covariant _PintorSituacionSentido oldDelegate) =>
      oldDelegate.id != id || oldDelegate.color != color;
}
