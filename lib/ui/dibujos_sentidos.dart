import 'dart:math' as math;

import 'package:flutter/material.dart';

// Dibujos de «Los cinco sentidos»: los órganos se pintan sobre 100×100 y
// las situaciones de Medio y Difícil usan un icono sobre un círculo de color.

const _organoDeSentido = {
  'vista': 'ojos',
  'oido': 'orejas',
  'olfato': 'nariz',
  'gusto': 'lengua',
  'tacto': 'piel',
};

const _situaciones = <String, (IconData, Color)>{
  'humo': (Icons.local_fire_department_rounded, Color(0xFFEA580C)),
  'piscina': (Icons.pool_rounded, Color(0xFF0284C7)),
  'timbre': (Icons.notifications_active_rounded, Color(0xFFCA8A04)),
  'limon': (Icons.emoji_food_beverage_rounded, Color(0xFF65A30D)),
  'semaforo': (Icons.traffic_rounded, Color(0xFFDC2626)),
  'arena': (Icons.beach_access_rounded, Color(0xFFD97706)),
  'cazuela': (Icons.soup_kitchen_rounded, Color(0xFFB91C1C)),
  'nombre': (Icons.record_voice_over_rounded, Color(0xFF7C3AED)),
  'verde': (Icons.directions_walk_rounded, Color(0xFF16A34A)),
  'leche': (Icons.local_drink_rounded, Color(0xFF0EA5E9)),
  'incendio': (Icons.whatshot_rounded, Color(0xFFEA580C)),
};

/// Ids que sabe dibujar [DibujoSentido].
final idsSentidos = {
  ..._organoDeSentido.keys,
  ..._organoDeSentido.values,
  ..._situaciones.keys,
};

class DibujoSentido extends StatelessWidget {
  const DibujoSentido({required this.id, this.tamano = 56, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final situacion = _situaciones[id];
    if (situacion != null) {
      final (icono, color) = situacion;
      return Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .14),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: .45), width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(icono, color: color, size: tamano * .56),
      );
    }
    return SizedBox.square(
      dimension: tamano,
      child: CustomPaint(
        painter: _PintorOrganoSentido(_organoDeSentido[id] ?? id),
      ),
    );
  }
}

class _PintorOrganoSentido extends CustomPainter {
  const _PintorOrganoSentido(this.organo);

  final String organo;

  static const _piel = Color(0xFFF8C9A0);
  static const _borde = Color(0xFF8A5A3B);

  @override
  void paint(Canvas canvas, Size size) {
    final lado = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - lado) / 2, (size.height - lado) / 2);
    canvas.scale(lado / 100);
    switch (organo) {
      case 'ojos':
        _ojo(canvas);
      case 'orejas':
        _oreja(canvas);
      case 'nariz':
        _nariz(canvas);
      case 'lengua':
        _lengua(canvas);
      default:
        _mano(canvas);
    }
    canvas.restore();
  }

  void _ojo(Canvas canvas) {
    final contorno = Path()
      ..moveTo(10, 50)
      ..quadraticBezierTo(50, 12, 90, 50)
      ..quadraticBezierTo(50, 88, 10, 50)
      ..close();
    canvas.drawPath(contorno, Paint()..color = Colors.white);
    canvas.save();
    canvas.clipPath(contorno);
    canvas.drawCircle(
      const Offset(50, 50),
      20,
      Paint()..color = const Color(0xFF7C4A2D),
    );
    canvas.drawCircle(
      const Offset(50, 50),
      9,
      Paint()..color = const Color(0xFF1E1B18),
    );
    canvas.drawCircle(const Offset(56, 43), 4, Paint()..color = Colors.white);
    canvas.restore();
    canvas.drawPath(contorno, _trazo(_borde, 3));
    for (final x in const [26.0, 38.0, 50.0, 62.0, 74.0]) {
      final y = 50 - math.sin((x - 10) / 80 * math.pi) * 19;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + (x - 50) * .12, y - 9),
        _trazo(_borde, 2.6),
      );
    }
  }

  void _oreja(Canvas canvas) {
    final oreja = Path()
      ..moveTo(40, 88)
      ..cubicTo(28, 80, 26, 64, 34, 52)
      ..cubicTo(22, 36, 30, 10, 54, 10)
      ..cubicTo(78, 10, 84, 38, 72, 56)
      ..cubicTo(62, 72, 62, 86, 48, 90)
      ..close();
    canvas.drawPath(oreja, Paint()..color = _piel);
    canvas.drawPath(oreja, _trazo(_borde, 3));
    final interior = Path()
      ..moveTo(44, 70)
      ..cubicTo(40, 56, 48, 50, 56, 52)
      ..cubicTo(66, 44, 62, 24, 52, 24)
      ..cubicTo(42, 24, 40, 36, 46, 40);
    canvas.drawPath(interior, _trazo(const Color(0xFFD9967A), 4));
    for (final r in const [8.0, 14.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(86, 34), radius: r),
        -math.pi / 3,
        2 * math.pi / 3,
        false,
        _trazo(const Color(0xFF7C3AED), 2.4),
      );
    }
  }

  void _nariz(Canvas canvas) {
    final nariz = Path()
      ..moveTo(48, 12)
      ..cubicTo(46, 40, 30, 58, 30, 70)
      ..cubicTo(30, 82, 44, 84, 50, 78)
      ..cubicTo(56, 84, 70, 82, 70, 70)
      ..cubicTo(70, 58, 56, 40, 54, 12)
      ..close();
    canvas.drawPath(nariz, Paint()..color = _piel);
    canvas.drawPath(nariz, _trazo(_borde, 3));
    for (final x in const [41.0, 59.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 74), width: 9, height: 5),
        Paint()..color = const Color(0xFF8A4B32),
      );
    }
    for (final y in const [20.0, 30.0]) {
      final ola = Path()
        ..moveTo(70, y)
        ..quadraticBezierTo(78, y - 6, 86, y)
        ..quadraticBezierTo(92, y + 6, 98, y);
      canvas.drawPath(ola, _trazo(const Color(0xFF16A34A), 2.4));
    }
  }

  void _lengua(Canvas canvas) {
    final boca = Rect.fromCenter(
      center: const Offset(50, 40),
      width: 70,
      height: 36,
    );
    canvas.drawOval(boca, Paint()..color = const Color(0xFF7F1D1D));
    canvas.drawOval(boca, _trazo(const Color(0xFFE11D48), 4));
    final lengua = Path()
      ..moveTo(32, 46)
      ..cubicTo(30, 78, 70, 78, 68, 46)
      ..close();
    canvas.drawPath(lengua, Paint()..color = const Color(0xFFFB7185));
    canvas.drawPath(lengua, _trazo(const Color(0xFFBE123C), 2.4));
    canvas.drawLine(
      const Offset(50, 50),
      const Offset(50, 66),
      _trazo(const Color(0xFFBE123C), 2),
    );
    for (final p in const [
      Offset(41, 56),
      Offset(58, 56),
      Offset(45, 64),
      Offset(55, 64),
    ]) {
      canvas.drawCircle(p, 1.6, Paint()..color = const Color(0xFFFDA4AF));
    }
  }

  void _mano(Canvas canvas) {
    final palma = RRect.fromRectAndRadius(
      const Rect.fromLTWH(30, 46, 42, 42),
      const Radius.circular(16),
    );
    final relleno = Paint()..color = _piel;
    for (final (x, alto) in const [
      (32.0, 30.0),
      (43.0, 38.0),
      (54.0, 36.0),
      (65.0, 28.0),
    ]) {
      final dedo = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 56 - alto, 10, alto + 4),
        const Radius.circular(5),
      );
      canvas.drawRRect(dedo, relleno);
      canvas.drawRRect(dedo, _trazo(_borde, 2.4));
    }
    final pulgar = RRect.fromRectAndRadius(
      const Rect.fromLTWH(14, 54, 24, 11),
      const Radius.circular(6),
    );
    canvas.drawRRect(pulgar, relleno);
    canvas.drawRRect(pulgar, _trazo(_borde, 2.4));
    canvas.drawRRect(palma, relleno);
    canvas.drawRRect(palma, _trazo(_borde, 3));
    for (final r in const [6.0, 11.0]) {
      canvas.drawCircle(
        const Offset(51, 66),
        r,
        _trazo(const Color(0xFFF59E0B), 1.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PintorOrganoSentido old) =>
      old.organo != organo;
}

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;
