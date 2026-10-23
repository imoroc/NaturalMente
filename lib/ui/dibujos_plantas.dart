import 'dart:math' as math;

import 'package:flutter/material.dart';

// Plantas del entorno para «Árbol, arbusto o hierba» y juegos del Invernadero.
// Se pintan sobre un lienzo de 100×100 con el suelo en la base para comparar
// claramente su porte (árbol de tronco único alto, arbusto ramificado desde
// la base o hierba de tallo tierno y flexible).

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
    _suelo(canvas, esHuerta: id == 'tomatera' || id == 'manzano');
    switch (id) {
      case 'encina':
        _encina(canvas);
      case 'manzano':
        _manzano(canvas);
      case 'arbol':
        _arbolClasico(canvas);
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
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _suelo(Canvas canvas, {bool esHuerta = false}) {
  // Sombra y montículo de tierra con briznas de hierba
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 93.5), width: 86, height: 11),
    _relleno(esHuerta ? const Color(0xFF78350F) : const Color(0xFF92400E)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 92), width: 78, height: 8),
    _relleno(esHuerta ? const Color(0xFF9A3412) : const Color(0xFFB45309)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(50, 93), width: 86, height: 10.5),
    _trazo(const Color(0xFF451A03), 1.6),
  );
}

void _dibujarManzanaDetallada(Canvas canvas, Offset c, double r) {
  // Cuerpo acorazonado de la manzana roja
  final path = Path()
    ..moveTo(c.dx, c.dy - r * 0.72)
    ..cubicTo(
      c.dx - r * 0.95,
      c.dy - r * 1.15,
      c.dx - r * 1.25,
      c.dy + r * 0.55,
      c.dx - r * 0.25,
      c.dy + r * 0.95,
    )
    ..quadraticBezierTo(c.dx, c.dy + r * 0.78, c.dx + r * 0.25, c.dy + r * 0.95)
    ..cubicTo(
      c.dx + r * 1.25,
      c.dy + r * 0.55,
      c.dx + r * 0.95,
      c.dy - r * 1.15,
      c.dx,
      c.dy - r * 0.72,
    )
    ..close();

  canvas.drawPath(path, _relleno(const Color(0xFFDC2626)));
  canvas.drawPath(path, _trazo(const Color(0xFF7F1D1D), 1.1));

  // Brillo blanco lateral
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(c.dx - r * 0.36, c.dy - r * 0.18),
      width: r * 0.42,
      height: r * 0.65,
    ),
    _relleno(Colors.white.withValues(alpha: 0.65)),
  );

  // Rabillo marrón
  canvas.drawLine(
    Offset(c.dx, c.dy - r * 0.68),
    Offset(c.dx + r * 0.18, c.dy - r * 1.25),
    _trazo(const Color(0xFF451A03), 1.3),
  );

  // Hojita verde junto al rabillo
  final hoja = Path()
    ..moveTo(c.dx + r * 0.05, c.dy - r * 0.88)
    ..quadraticBezierTo(
      c.dx + r * 0.75,
      c.dy - r * 1.35,
      c.dx + r * 0.85,
      c.dy - r * 0.72,
    )
    ..quadraticBezierTo(
      c.dx + r * 0.40,
      c.dy - r * 0.60,
      c.dx + r * 0.05,
      c.dy - r * 0.88,
    )
    ..close();
  canvas.drawPath(hoja, _relleno(const Color(0xFF4ADE80)));
}

void _manzano(Canvas canvas) {
  // 1. Sombra de copa trasera (profundidad de árbol frutal alto)
  for (final (dx, dy, r) in [
    (25.0, 38.0, 16.0),
    (75.0, 38.0, 16.0),
    (50.0, 21.0, 19.0),
    (34.0, 26.0, 17.0),
    (66.0, 26.0, 17.0),
  ]) {
    canvas.drawCircle(Offset(dx, dy), r, _relleno(const Color(0xFF15803D)));
  }

  // 2. Tronco leñoso alto con raíces y tres grandes ramas principales (cruz del árbol)
  final tronco = Path()
    ..moveTo(39, 92)
    ..quadraticBezierTo(44, 82, 44, 56)
    ..lineTo(31, 41)
    ..lineTo(35, 38)
    ..lineTo(46, 50)
    ..lineTo(48, 36)
    ..lineTo(52, 36)
    ..lineTo(54, 50)
    ..lineTo(65, 38)
    ..lineTo(69, 41)
    ..lineTo(56, 56)
    ..quadraticBezierTo(56, 82, 61, 92)
    ..close();
  canvas.drawPath(tronco, _relleno(const Color(0xFF78350F)));
  canvas.drawPath(tronco, _trazo(const Color(0xFF451A03), 2.0));

  // Vetas de corteza y nudo de madera
  canvas.drawLine(
    const Offset(48, 88),
    const Offset(48, 56),
    _trazo(const Color(0xFF9A3412), 1.8),
  );
  canvas.drawLine(
    const Offset(52, 85),
    const Offset(53, 62),
    _trazo(const Color(0xFF451A03), 1.4),
  );

  // 3. Copa frondosa del manzano en capas iluminadas (deja ver la horquilla del tronco)
  final pomosCopa = [
    (22.0, 40.0, 14.5, const Color(0xFF16A34A)),
    (78.0, 40.0, 14.5, const Color(0xFF16A34A)),
    (33.0, 44.0, 14.0, const Color(0xFF22C55E)),
    (67.0, 44.0, 14.0, const Color(0xFF22C55E)),
    (28.0, 27.0, 15.5, const Color(0xFF22C55E)),
    (72.0, 27.0, 15.5, const Color(0xFF22C55E)),
    (50.0, 34.0, 16.5, const Color(0xFF22C55E)),
    (40.0, 20.0, 15.5, const Color(0xFF4ADE80)),
    (60.0, 20.0, 15.5, const Color(0xFF4ADE80)),
    (50.0, 16.0, 15.0, const Color(0xFF4ADE80)),
  ];
  for (final (dx, dy, r, col) in pomosCopa) {
    canvas.drawCircle(Offset(dx, dy), r, _relleno(col));
  }

  // Contorno exterior de la copa del árbol para estética cartoon limpia
  for (final (dx, dy, r) in [
    (22.0, 40.0, 14.5),
    (28.0, 27.0, 15.5),
    (40.0, 20.0, 15.5),
    (50.0, 16.0, 15.0),
    (60.0, 20.0, 15.5),
    (72.0, 27.0, 15.5),
    (78.0, 40.0, 14.5),
  ]) {
    canvas.drawArc(
      Rect.fromCircle(center: Offset(dx, dy), radius: r),
      math.pi * 0.9,
      math.pi * 1.2,
      false,
      _trazo(const Color(0xFF14532D), 1.8),
    );
  }

  // 4. Manzanas rojas brillantes colgando claramente por toda la copa
  for (final pos in const [
    Offset(24, 38),
    Offset(37, 25),
    Offset(50, 18),
    Offset(64, 25),
    Offset(76, 38),
    Offset(41, 41),
    Offset(59, 41),
  ]) {
    _dibujarManzanaDetallada(canvas, pos, 5.2);
  }
}

void _dibujarBellota(Canvas canvas, Offset c) {
  // Cuerpo ovalado de la bellota
  canvas.drawOval(
    Rect.fromCenter(center: Offset(c.dx, c.dy + 2.2), width: 6.2, height: 8.5),
    _relleno(const Color(0xFFD97706)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: Offset(c.dx, c.dy + 2.2), width: 6.2, height: 8.5),
    _trazo(const Color(0xFF451A03), 1.0),
  );
  // Cúpula rugosa (cascabillo)
  canvas.drawArc(
    Rect.fromCenter(center: Offset(c.dx, c.dy - 0.5), width: 7.6, height: 6.0),
    math.pi,
    math.pi,
    true,
    _relleno(const Color(0xFF78350F)),
  );
  canvas.drawArc(
    Rect.fromCenter(center: Offset(c.dx, c.dy - 0.5), width: 7.6, height: 6.0),
    math.pi,
    math.pi,
    true,
    _trazo(const Color(0xFF451A03), 1.0),
  );
  canvas.drawLine(
    Offset(c.dx, c.dy - 3.5),
    Offset(c.dx, c.dy - 5.5),
    _trazo(const Color(0xFF451A03), 1.2),
  );
}

void _encina(Canvas canvas) {
  // Copa aparasolada ancha típica de la encina mediterránea
  for (final (dx, dy, rx, ry, col) in [
    (50.0, 32.0, 42.0, 20.0, const Color(0xFF14532D)),
    (24.0, 36.0, 18.0, 13.0, const Color(0xFF166534)),
    (76.0, 36.0, 18.0, 13.0, const Color(0xFF166534)),
    (36.0, 24.0, 20.0, 14.0, const Color(0xFF15803D)),
    (64.0, 24.0, 20.0, 14.0, const Color(0xFF15803D)),
    (50.0, 20.0, 22.0, 14.0, const Color(0xFF16A34A)),
  ]) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dx, dy), width: rx * 2, height: ry * 2),
      _relleno(col),
    );
  }

  // Tronco robusto, oscuro y nudoso con grandes brazos horizontales
  final tronco = Path()
    ..moveTo(36, 92)
    ..quadraticBezierTo(42, 78, 42, 54)
    ..lineTo(24, 40)
    ..lineTo(28, 36)
    ..lineTo(45, 48)
    ..lineTo(48, 35)
    ..lineTo(52, 35)
    ..lineTo(55, 48)
    ..lineTo(72, 36)
    ..lineTo(76, 40)
    ..lineTo(58, 54)
    ..quadraticBezierTo(58, 78, 64, 92)
    ..close();
  canvas.drawPath(tronco, _relleno(const Color(0xFF573B26)));
  canvas.drawPath(tronco, _trazo(const Color(0xFF291C14), 2.2));

  // Follaje frontal verde oliva
  for (final (dx, dy, rx, ry) in [
    (28.0, 34.0, 15.0, 10.0),
    (72.0, 34.0, 15.0, 10.0),
    (50.0, 28.0, 20.0, 12.0),
  ]) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dx, dy), width: rx * 2, height: ry * 2),
      _relleno(const Color(0xFF22C55E).withValues(alpha: 0.85)),
    );
  }

  // Bellotas características
  for (final pos in const [
    Offset(22, 38),
    Offset(36, 26),
    Offset(50, 22),
    Offset(64, 26),
    Offset(78, 38),
    Offset(50, 36),
  ]) {
    _dibujarBellota(canvas, pos);
  }
}

void _arbolClasico(Canvas canvas) {
  final tronco = Path()
    ..moveTo(41, 92)
    ..quadraticBezierTo(45, 76, 45, 52)
    ..lineTo(35, 39)
    ..lineTo(39, 36)
    ..lineTo(48, 46)
    ..lineTo(52, 46)
    ..lineTo(61, 36)
    ..lineTo(65, 39)
    ..lineTo(55, 52)
    ..quadraticBezierTo(55, 76, 59, 92)
    ..close();
  canvas.drawPath(tronco, _relleno(const Color(0xFF8B5A2B)));
  canvas.drawPath(tronco, _trazo(const Color(0xFF451A03), 2.0));

  for (final (dx, dy, r, col) in [
    (31.0, 38.0, 16.0, const Color(0xFF15803D)),
    (69.0, 38.0, 16.0, const Color(0xFF15803D)),
    (50.0, 23.0, 20.0, const Color(0xFF16A34A)),
    (38.0, 29.0, 16.0, const Color(0xFF22C55E)),
    (62.0, 29.0, 16.0, const Color(0xFF22C55E)),
    (50.0, 19.0, 15.0, const Color(0xFF4ADE80)),
  ]) {
    canvas.drawCircle(Offset(dx, dy), r, _relleno(col));
  }
}

void _chopo(Canvas canvas) {
  // Tronco esbelto de corteza clara con marcas horizontales (lenticelas)
  final tronco = RRect.fromRectAndRadius(
    const Rect.fromLTWH(46, 58, 8, 34),
    const Radius.circular(3),
  );
  canvas.drawRRect(tronco, _relleno(const Color(0xFFD6D3D1)));
  canvas.drawRRect(tronco, _trazo(const Color(0xFF57534E), 1.8));

  // Copa piramidal / columnar alta típica del chopo de ribera
  final copa = Path()
    ..moveTo(50, 7)
    ..quadraticBezierTo(73, 28, 70, 54)
    ..quadraticBezierTo(68, 69, 50, 69)
    ..quadraticBezierTo(32, 69, 30, 54)
    ..quadraticBezierTo(27, 28, 50, 7)
    ..close();
  canvas.drawPath(copa, _relleno(const Color(0xFF65A30D)));
  canvas.drawPath(copa, _trazo(const Color(0xFF365314), 2.0));

  final copaLuz = Path()
    ..moveTo(50, 12)
    ..quadraticBezierTo(63, 30, 61, 52)
    ..quadraticBezierTo(59, 63, 50, 63)
    ..close();
  canvas.drawPath(copaLuz, _relleno(const Color(0xFF84CC16)));

  // Nervadura central y ramas ascendentes visibles
  canvas.drawLine(
    const Offset(50, 68),
    const Offset(50, 18),
    _trazo(const Color(0xFF365314), 2.0),
  );
  for (final (y, dx) in [(54.0, 10.0), (42.0, 9.0), (30.0, 7.0)]) {
    canvas.drawLine(
      Offset(50, y),
      Offset(50 - dx, y - 7),
      _trazo(const Color(0xFF365314), 1.5),
    );
    canvas.drawLine(
      Offset(50, y),
      Offset(50 + dx, y - 7),
      _trazo(const Color(0xFF365314), 1.5),
    );
  }
}

void _romero(Canvas canvas) {
  // Arbusto mediterráneo leñoso ramificado desde la misma base (sin tronco único)
  final ramas = [
    (const Offset(48, 91), const Offset(20, 42)),
    (const Offset(49, 91), const Offset(34, 30)),
    (const Offset(50, 91), const Offset(50, 24)),
    (const Offset(51, 91), const Offset(66, 30)),
    (const Offset(52, 91), const Offset(80, 42)),
  ];
  for (final (ini, fin) in ramas) {
    canvas.drawLine(ini, fin, _trazo(const Color(0xFF78350F), 3.0));
    // Hojas aciculares (en aguja) y florecillas azul-violeta del romero
    for (var t = 0.22; t <= 0.96; t += 0.14) {
      final p = Offset.lerp(ini, fin, t)!;
      final dir = (fin - ini);
      final norm = Offset(-dir.dy, dir.dx) / dir.distance;
      canvas.drawLine(
        p,
        p + norm * 6.5 - Offset(0, 3),
        _trazo(const Color(0xFF15803D), 2.4),
      );
      canvas.drawLine(
        p,
        p - norm * 6.5 - Offset(0, 3),
        _trazo(const Color(0xFF16A34A), 2.4),
      );
      if (t > 0.45) {
        canvas.drawCircle(
          p + norm * 4.5,
          2.1,
          _relleno(const Color(0xFFA78BFA)),
        );
        canvas.drawCircle(
          p - norm * 4.5,
          1.9,
          _relleno(const Color(0xFFC4B5FD)),
        );
      }
    }
  }
}

void _tomillo(Canvas canvas) {
  // Mata baja almohadillada muy ramificada desde el suelo con flores rosadas
  final ramas = [
    (const Offset(46, 91), const Offset(16, 62)),
    (const Offset(48, 91), const Offset(28, 52)),
    (const Offset(50, 91), const Offset(44, 48)),
    (const Offset(50, 91), const Offset(56, 48)),
    (const Offset(52, 91), const Offset(72, 52)),
    (const Offset(54, 91), const Offset(84, 62)),
  ];
  for (final (ini, fin) in ramas) {
    canvas.drawLine(ini, fin, _trazo(const Color(0xFF78350F), 2.4));
    for (var t = 0.3; t <= 0.9; t += 0.2) {
      final p = Offset.lerp(ini, fin, t)!;
      canvas.drawCircle(p, 5.2, _relleno(const Color(0xFF4D7C0F)));
      canvas.drawCircle(
        p.translate(0, -1.5),
        3.8,
        _relleno(const Color(0xFF65A30D)),
      );
    }
    // Inflorescencia rosada/lila en el extremo
    canvas.drawCircle(fin, 4.5, _relleno(const Color(0xFFF472B6)));
    canvas.drawCircle(
      fin.translate(-2, -1),
      2.2,
      _relleno(const Color(0xFFFBCFE8)),
    );
    canvas.drawCircle(
      fin.translate(2, -1),
      2.2,
      _relleno(const Color(0xFFFBCFE8)),
    );
  }
}

void _cesped(Canvas canvas) {
  // Hierba tierna, verde y flexible que nace directamente del suelo
  final briznas = [
    (20.0, 12.0, 44.0, const Color(0xFF15803D)),
    (28.0, 20.0, 34.0, const Color(0xFF22C55E)),
    (36.0, 26.0, 38.0, const Color(0xFF16A34A)),
    (44.0, 40.0, 28.0, const Color(0xFF4ADE80)),
    (50.0, 52.0, 24.0, const Color(0xFF16A34A)),
    (58.0, 68.0, 32.0, const Color(0xFF22C55E)),
    (66.0, 78.0, 36.0, const Color(0xFF15803D)),
    (74.0, 86.0, 42.0, const Color(0xFF4ADE80)),
    (80.0, 90.0, 48.0, const Color(0xFF16A34A)),
  ];
  for (final (xBase, xPunta, yPunta, color) in briznas) {
    final brizna = Path()
      ..moveTo(xBase - 2.5, 92)
      ..quadraticBezierTo((xBase + xPunta) / 2, (92 + yPunta) / 2, xPunta, yPunta)
      ..quadraticBezierTo(
        (xBase + xPunta) / 2 + 2.5,
        (92 + yPunta) / 2 + 2,
        xBase + 2.5,
        92,
      )
      ..close();
    canvas.drawPath(brizna, _relleno(color));
  }
}

void _amapola(Canvas canvas) {
  // Tallo herbáceo fino y flexible con pelillos y capullo lateral
  final tallo = Path()
    ..moveTo(50, 92)
    ..cubicTo(44, 72, 54, 52, 48, 32);
  canvas.drawPath(tallo, _trazo(const Color(0xFF15803D), 3.6));

  // Tallo secundario con capullo cerrado
  final talloCapullo = Path()
    ..moveTo(49, 76)
    ..quadraticBezierTo(66, 64, 70, 46);
  canvas.drawPath(talloCapullo, _trazo(const Color(0xFF16A34A), 2.6));
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(71, 43), width: 9, height: 13),
    _relleno(const Color(0xFF16A34A)),
  );
  canvas.drawArc(
    Rect.fromCenter(center: const Offset(71, 41), width: 8, height: 9),
    math.pi,
    math.pi,
    true,
    _relleno(const Color(0xFFEF4444)),
  );

  // Hojas basales dentadas de la amapola
  for (final dir in [-1.0, 1.0]) {
    final hoja = Path()
      ..moveTo(49, 78)
      ..quadraticBezierTo(49 + 18 * dir, 66, 49 + 26 * dir, 72)
      ..quadraticBezierTo(49 + 14 * dir, 82, 49, 82)
      ..close();
    canvas.drawPath(hoja, _relleno(const Color(0xFF22C55E)));
    canvas.drawPath(hoja, _trazo(const Color(0xFF14532D), 1.2));
  }

  // Gran flor roja de 4 pétalos sedosos con centro negro estrellado
  for (final (dx, dy, w, h) in [
    (-12.0, -2.0, 22.0, 20.0),
    (12.0, -2.0, 22.0, 20.0),
    (0.0, -11.0, 24.0, 19.0),
    (0.0, 7.0, 24.0, 19.0),
  ]) {
    final rect = Rect.fromCenter(
      center: Offset(48 + dx, 28 + dy),
      width: w,
      height: h,
    );
    canvas.drawOval(rect, _relleno(const Color(0xFFEF4444)));
    canvas.drawOval(rect, _trazo(const Color(0xFF991B1B), 1.4));
  }
  canvas.drawCircle(const Offset(48, 28), 6.5, _relleno(const Color(0xFF1E293B)));
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    canvas.drawCircle(
      Offset(48 + math.cos(a) * 8, 28 + math.sin(a) * 8),
      1.3,
      _relleno(const Color(0xFFFDE047)),
    );
  }
}

void _trigo(Canvas canvas) {
  // Tres cañas herbáceas doradas con hojas acintadas y espigas granadas con barbas (aristas)
  for (final (xBase, xEspiga, inclinacion) in [
    (36.0, 28.0, -0.14),
    (50.0, 50.0, 0.0),
    (64.0, 72.0, 0.14),
  ]) {
    final tallo = Path()
      ..moveTo(xBase, 92)
      ..quadraticBezierTo((xBase + xEspiga) / 2, 64, xEspiga, 42);
    canvas.drawPath(tallo, _trazo(const Color(0xFFD97706), 3.0));

    // Hoja envainadora dorada
    final hoja = Path()
      ..moveTo((xBase + xEspiga) / 2, 68)
      ..quadraticBezierTo(xEspiga + (inclinacion >= 0 ? 14 : -14), 56, xEspiga + (inclinacion >= 0 ? 18 : -18), 62)
      ..quadraticBezierTo(xEspiga + (inclinacion >= 0 ? 8 : -8), 70, (xBase + xEspiga) / 2, 72)
      ..close();
    canvas.drawPath(hoja, _relleno(const Color(0xFFF59E0B)));

    // Espiga de granos de trigo con aristas finas arriba
    canvas.save();
    canvas.translate(xEspiga, 42);
    canvas.rotate(inclinacion);
    for (var i = 0; i < 6; i++) {
      final y = -i * 4.5;
      // Aristas (barbas del trigo)
      canvas.drawLine(
        Offset(-3, y - 2),
        Offset(-7, y - 11),
        _trazo(const Color(0xFFB45309), 0.9),
      );
      canvas.drawLine(
        Offset(3, y - 2),
        Offset(7, y - 11),
        _trazo(const Color(0xFFB45309), 0.9),
      );
      // Granos pareados
      for (final dx in [-3.4, 3.4]) {
        final grano = Rect.fromCenter(
          center: Offset(dx, y),
          width: 5.5,
          height: 8.2,
        );
        canvas.drawOval(grano, _relleno(const Color(0xFFFACC15)));
        canvas.drawOval(grano, _trazo(const Color(0xFFB45309), 1.0));
      }
    }
    canvas.restore();
  }
}

void _dibujarHojaTomatera(
  Canvas canvas,
  Offset base,
  Offset punta,
) {
  final dir = punta - base;
  final norm = Offset(-dir.dy, dir.dx) / (dir.distance == 0 ? 1 : dir.distance);
  // Raquis central de la hoja compuesta
  canvas.drawLine(base, punta, _trazo(const Color(0xFF15803D), 1.8));
  // Folíolos laterales y folíolo terminal
  for (final t in [0.38, 0.72]) {
    final c = Offset.lerp(base, punta, t)!;
    for (final s in [-1.0, 1.0]) {
      final fCenter = c + norm * (4.2 * s);
      canvas.drawOval(
        Rect.fromCenter(center: fCenter, width: 7.5, height: 4.8),
        _relleno(const Color(0xFF22C55E)),
      );
      canvas.drawOval(
        Rect.fromCenter(center: fCenter, width: 7.5, height: 4.8),
        _trazo(const Color(0xFF14532D), 0.9),
      );
    }
  }
  canvas.drawOval(
    Rect.fromCenter(center: punta, width: 8.5, height: 5.5),
    _relleno(const Color(0xFF16A34A)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: punta, width: 8.5, height: 5.5),
    _trazo(const Color(0xFF14532D), 0.9),
  );
}

void _dibujarTomate(
  Canvas canvas,
  Offset c,
  double r, {
  Color color = const Color(0xFFEF4444),
}) {
  // Fruto globoso achatado (baya del tomate)
  final rect = Rect.fromCenter(center: c, width: r * 2.25, height: r * 1.95);
  canvas.drawOval(rect, _relleno(color));
  canvas.drawOval(rect, _trazo(const Color(0xFF7F1D1D), 1.2));

  // Brillo jugoso
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(c.dx - r * 0.42, c.dy - r * 0.25),
      width: r * 0.55,
      height: r * 0.40,
    ),
    _relleno(Colors.white.withValues(alpha: 0.7)),
  );

  // Cáliz verde en estrella (sépalos característicos del tomate en la parte superior)
  final caliz = Path();
  for (var i = 0; i < 5; i++) {
    final a = -math.pi / 2 + (i - 2) * 0.55;
    caliz
      ..moveTo(c.dx, c.dy - r * 0.78)
      ..lineTo(
        c.dx + math.cos(a) * r * 0.95,
        c.dy - r * 0.75 + math.sin(a) * r * 0.55,
      );
  }
  canvas.drawPath(caliz, _trazo(const Color(0xFF14532D), 1.6));
}

void _dibujarFlorTomate(Canvas canvas, Offset c) {
  // Florecilla amarilla estrellada de 5 pétalos típica de las solanáceas
  for (var i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5 - math.pi / 2;
    final p = Path()
      ..moveTo(c.dx, c.dy)
      ..lineTo(c.dx + math.cos(a - 0.28) * 3.0, c.dy + math.sin(a - 0.28) * 3.0)
      ..lineTo(c.dx + math.cos(a) * 6.2, c.dy + math.sin(a) * 6.2)
      ..lineTo(c.dx + math.cos(a + 0.28) * 3.0, c.dy + math.sin(a + 0.28) * 3.0)
      ..close();
    canvas.drawPath(p, _relleno(const Color(0xFFFACC15)));
  }
  canvas.drawCircle(c, 1.8, _relleno(const Color(0xFFD97706)));
}

void _tomatera(Canvas canvas) {
  // 1. Tutor de madera del huerto clavado en la tierra para guiar la mata
  final tutor = RRect.fromRectAndRadius(
    const Rect.fromLTWH(47.5, 12, 5, 80),
    const Radius.circular(2),
  );
  canvas.drawRRect(tutor, _relleno(const Color(0xFFA16207)));
  canvas.drawRRect(tutor, _trazo(const Color(0xFF451A03), 1.4));

  // 2. Tallos ramificados desde la base que trepan apoyados en el tutor
  final talloCentral = Path()
    ..moveTo(50, 91)
    ..cubicTo(42, 74, 57, 52, 48, 18);
  final talloIzq = Path()
    ..moveTo(47, 91)
    ..quadraticBezierTo(28, 72, 24, 42);
  final talloDer = Path()
    ..moveTo(53, 91)
    ..quadraticBezierTo(72, 70, 76, 40);

  canvas.drawPath(talloIzq, _trazo(const Color(0xFF15803D), 3.4));
  canvas.drawPath(talloDer, _trazo(const Color(0xFF15803D), 3.4));
  canvas.drawPath(talloCentral, _trazo(const Color(0xFF16A34A), 4.0));

  // Ataduras de cuerda de esparto al tutor
  for (final yAtadura in [34.0, 58.0, 76.0]) {
    canvas.drawLine(
      Offset(45.5, yAtadura),
      Offset(54.5, yAtadura),
      _trazo(const Color(0xFFFDE68A), 2.0),
    );
  }

  // 3. Hojas compuestas dentadas de tomatera
  _dibujarHojaTomatera(canvas, const Offset(34, 72), const Offset(14, 64));
  _dibujarHojaTomatera(canvas, const Offset(66, 70), const Offset(86, 62));
  _dibujarHojaTomatera(canvas, const Offset(28, 52), const Offset(11, 40));
  _dibujarHojaTomatera(canvas, const Offset(72, 50), const Offset(89, 38));
  _dibujarHojaTomatera(canvas, const Offset(48, 30), const Offset(27, 20));
  _dibujarHojaTomatera(canvas, const Offset(51, 28), const Offset(73, 18));

  // 4. Flores amarillas en la parte alta de la mata
  _dibujarFlorTomate(canvas, const Offset(38, 18));
  _dibujarFlorTomate(canvas, const Offset(62, 19));

  // 5. Racimos de tomates rojos maduros y uno envero (naranja) con cáliz en estrella
  _dibujarTomate(canvas, const Offset(33, 64), 6.8);
  _dibujarTomate(canvas, const Offset(65, 62), 7.0);
  _dibujarTomate(canvas, const Offset(25, 46), 6.2);
  _dibujarTomate(canvas, const Offset(73, 44), 6.4);
  _dibujarTomate(canvas, const Offset(44, 42), 6.6);
  _dibujarTomate(
    canvas,
    const Offset(58, 34),
    5.6,
    color: const Color(0xFFF97316), // Tomate madurando (envero)
  );
}
