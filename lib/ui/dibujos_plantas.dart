import 'dart:math' as math;

import 'package:flutter/material.dart';

// Plantas del entorno para «Árbol, arbusto o hierba». Se pintan sobre un
// lienzo de 100×100 con el suelo abajo, para compararlas por su porte.

const plantasEntorno = {
  'arbol',
  'arbusto',
  'hierba',
  'encina',
  'chopo',
  'manzano',
  'romero',
  'tomillo',
  'cesped',
  'amapola',
  'trigo',
  'tomatera',
};

class DibujoPlanta extends StatelessWidget {
  const DibujoPlanta({required this.id, this.tamano = 56, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(painter: _PintorPlanta(id)),
  );
}

class _PintorPlanta extends CustomPainter {
  const _PintorPlanta(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final lado = math.min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - lado) / 2, (size.height - lado) / 2);
    canvas.scale(lado / 100);
    _suelo(canvas);
    switch (id) {
      case 'arbol' || 'encina':
        _arbolRedondo(
          canvas,
          copa: const Color(0xFF3F7D3A),
          frutos: id == 'encina' ? const Color(0xFF92400E) : null,
        );
      case 'manzano':
        _arbolRedondo(
          canvas,
          copa: const Color(0xFF65A30D),
          frutos: const Color(0xFFEF4444),
        );
      case 'chopo':
        _chopo(canvas);
      case 'arbusto' || 'romero':
        _romero(canvas);
      case 'tomillo':
        _tomillo(canvas);
      case 'hierba' || 'cesped':
        _cesped(canvas);
      case 'amapola':
        _amapola(canvas);
      case 'trigo':
        _trigo(canvas);
      case 'tomatera':
        _tomatera(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorPlanta old) => old.id != id;
}

Paint _relleno(Color color) => Paint()..color = color;

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round;

void _suelo(Canvas canvas) {
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 93), width: 84, height: 10),
    _relleno(const Color(0xFFB98B5E)),
  );
}

void _arbolRedondo(Canvas canvas, {required Color copa, Color? frutos}) {
  final tronco = Path()
    ..moveTo(44, 92)
    ..lineTo(46, 58)
    ..lineTo(54, 58)
    ..lineTo(56, 92)
    ..close();
  canvas.drawPath(tronco, _relleno(const Color(0xFF8B5A2B)));
  canvas.drawLine(
    const Offset(50, 66),
    const Offset(38, 54),
    _trazo(const Color(0xFF8B5A2B), 4),
  );
  canvas.drawLine(
    const Offset(50, 64),
    const Offset(62, 52),
    _trazo(const Color(0xFF8B5A2B), 4),
  );
  final oscura = Color.lerp(copa, Colors.black, .25)!;
  for (final (x, y, r) in const [
    (32.0, 44.0, 17.0),
    (68.0, 44.0, 17.0),
    (50.0, 30.0, 21.0),
    (50.0, 50.0, 19.0),
  ]) {
    canvas.drawCircle(Offset(x, y + 1.5), r, _relleno(oscura));
    canvas.drawCircle(Offset(x, y), r, _relleno(copa));
  }
  canvas.drawCircle(
    const Offset(43, 26),
    6,
    _relleno(Colors.white.withValues(alpha: .18)),
  );
  if (frutos != null) {
    for (final p in const [
      Offset(36, 46),
      Offset(58, 34),
      Offset(64, 52),
      Offset(46, 54),
    ]) {
      canvas.drawCircle(p, 3.4, _relleno(frutos));
    }
  }
}

void _chopo(Canvas canvas) {
  canvas.drawLine(
    const Offset(50, 92),
    const Offset(50, 60),
    _trazo(const Color(0xFF8B5A2B), 6),
  );
  final copa = Rect.fromCenter(
    center: const Offset(50, 42),
    width: 32,
    height: 74,
  );
  canvas.drawOval(copa, _relleno(const Color(0xFF4D7C0F)));
  canvas.drawOval(copa.deflate(4), _relleno(const Color(0xFF65A30D)));
  for (final y in const [24.0, 38.0, 52.0]) {
    canvas.drawLine(
      Offset(44, y),
      Offset(56, y + 6),
      _trazo(const Color(0xFF84CC16), 2),
    );
  }
}

void _romero(Canvas canvas) {
  // Muchos tallos leñosos que salen desde abajo: así es un arbusto.
  const tallo = Color(0xFF7C5A3A);
  const hoja = Color(0xFF4D7C6B);
  for (var i = 0; i < 9; i++) {
    final angulo = -math.pi / 2 + (i - 4) * .2;
    final fin = Offset(50 + math.cos(angulo) * 52, 92 + math.sin(angulo) * 60);
    canvas.drawLine(const Offset(50, 92), fin, _trazo(tallo, 2.6));
    for (var j = 1; j <= 5; j++) {
      final t = j / 6;
      final p = Offset.lerp(const Offset(50, 92), fin, t)!;
      canvas.drawLine(p, p + const Offset(-4, -3), _trazo(hoja, 2));
      canvas.drawLine(p, p + const Offset(4, -3), _trazo(hoja, 2));
    }
    canvas.drawCircle(fin, 2.6, _relleno(const Color(0xFF818CF8)));
  }
}

void _tomillo(Canvas canvas) {
  final mata = Rect.fromLTWH(18, 58, 64, 40);
  canvas.drawArc(
    mata,
    math.pi,
    math.pi,
    true,
    _relleno(const Color(0xFF6B8F71)),
  );
  for (var i = 0; i < 7; i++) {
    final x = 24.0 + i * 8.5;
    canvas.drawLine(
      Offset(x, 90),
      Offset(x + 2, 66),
      _trazo(const Color(0xFF7C5A3A), 1.8),
    );
  }
  for (final p in const [
    Offset(30, 66),
    Offset(42, 61),
    Offset(55, 60),
    Offset(67, 65),
    Offset(36, 74),
    Offset(62, 73),
  ]) {
    canvas.drawCircle(p, 2.8, _relleno(const Color(0xFFF0ABFC)));
  }
}

void _cesped(Canvas canvas) {
  for (var i = 0; i < 14; i++) {
    final x = 16.0 + i * 5;
    final alto = 46.0 + (i % 3) * 8;
    final hoja = Path()
      ..moveTo(x - 2, 92)
      ..quadraticBezierTo(
        x + 1,
        92 - alto / 2,
        x + (i.isEven ? 4 : -3),
        92 - alto,
      )
      ..quadraticBezierTo(x + 2, 92 - alto / 2, x + 2, 92)
      ..close();
    canvas.drawPath(
      hoja,
      _relleno(i.isEven ? const Color(0xFF22C55E) : const Color(0xFF16A34A)),
    );
  }
}

void _amapola(Canvas canvas) {
  final tallo = Path()
    ..moveTo(50, 92)
    ..quadraticBezierTo(44, 60, 52, 34);
  canvas.drawPath(tallo, _trazo(const Color(0xFF65A30D), 3));
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(40, 70), width: 16, height: 6),
    _relleno(const Color(0xFF65A30D)),
  );
  for (final d in const [
    Offset(-9, -4),
    Offset(9, -4),
    Offset(-7, 7),
    Offset(7, 7),
  ]) {
    canvas.drawCircle(
      const Offset(52, 30) + d,
      11,
      _relleno(const Color(0xFFDC2626)),
    );
  }
  canvas.drawCircle(const Offset(52, 31), 5, _relleno(const Color(0xFF1F2937)));
}

void _trigo(Canvas canvas) {
  for (final (x, inclina) in const [(36.0, -6.0), (50.0, 0.0), (64.0, 6.0)]) {
    final arriba = Offset(x + inclina, 30);
    canvas.drawLine(
      Offset(x, 92),
      arriba,
      _trazo(const Color(0xFFCA8A04), 2.4),
    );
    for (var j = 0; j < 5; j++) {
      final p = Offset.lerp(arriba, Offset(x, 92), j * .07)!;
      canvas.drawOval(
        Rect.fromCenter(center: p + const Offset(-3.5, 0), width: 6, height: 9),
        _relleno(const Color(0xFFEAB308)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: p + const Offset(3.5, 0), width: 6, height: 9),
        _relleno(const Color(0xFFFACC15)),
      );
    }
  }
}

void _tomatera(Canvas canvas) {
  // Tutor de caña: es una planta que cuidamos en el huerto.
  canvas.drawLine(
    const Offset(62, 92),
    const Offset(62, 20),
    _trazo(const Color(0xFFD6B98C), 3),
  );
  final tallo = Path()
    ..moveTo(48, 92)
    ..quadraticBezierTo(44, 60, 56, 26);
  canvas.drawPath(tallo, _trazo(const Color(0xFF4D7C0F), 3.4));
  for (final (p, giro) in const [
    (Offset(38, 64), -.5),
    (Offset(60, 52), .5),
    (Offset(42, 40), -.4),
  ]) {
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(giro);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 10),
      _relleno(const Color(0xFF65A30D)),
    );
    canvas.restore();
  }
  for (final p in const [Offset(54, 70), Offset(36, 50), Offset(58, 38)]) {
    canvas.drawCircle(p, 6.5, _relleno(const Color(0xFFEF4444)));
    canvas.drawCircle(p + const Offset(-2, -2), 1.6, _relleno(Colors.white70));
  }
}
