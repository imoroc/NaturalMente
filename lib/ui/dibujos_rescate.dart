import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fondo de «Cuida la reserva»: cielo, montes, árboles y un río.
class EscenaReserva extends StatelessWidget {
  const EscenaReserva({super.key});

  @override
  Widget build(BuildContext context) =>
      const CustomPaint(painter: _PintorEscena(), size: Size.infinite);
}

class _PintorEscena extends CustomPainter {
  const _PintorEscena();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE6FF), Color(0xFFE8F7FF)],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset(w * .86, h * .14),
      h * .07,
      Paint()..color = const Color(0xFFFFE082),
    );
    final montes = Path()
      ..moveTo(0, h * .42)
      ..quadraticBezierTo(w * .2, h * .2, w * .42, h * .38)
      ..quadraticBezierTo(w * .62, h * .18, w, h * .36)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(montes, Paint()..color = const Color(0xFFA5D6A7));
    final prado = Path()
      ..moveTo(0, h * .5)
      ..quadraticBezierTo(w * .5, h * .42, w, h * .5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(prado, Paint()..color = const Color(0xFF8BC34A));
    // Árboles del fondo.
    for (final (x, y, r) in const [
      (.08, .44, .07),
      (.2, .4, .06),
      (.7, .41, .065),
      (.92, .45, .07),
    ]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(w * x, h * (y + r * 1.1)),
          width: w * .02,
          height: h * r * 1.4,
        ),
        Paint()..color = const Color(0xFF795548),
      );
      canvas.drawCircle(
        Offset(w * x, h * y),
        h * r,
        Paint()..color = const Color(0xFF388E3C),
      );
    }
    // El río cruza la parte de abajo.
    final rio = Path()
      ..moveTo(0, h * .7)
      ..cubicTo(w * .3, h * .62, w * .55, h * .82, w, h * .72)
      ..lineTo(w, h * .9)
      ..cubicTo(w * .6, h * .98, w * .3, h * .8, 0, h * .88)
      ..close();
    canvas.drawPath(
      rio,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
        ).createShader(rect),
    );
    final ola = Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final (x, y) in const [(.15, .78), (.45, .8), (.75, .82)]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(w * x, h * y),
          width: w * .08,
          height: h * .03,
        ),
        math.pi,
        math.pi,
        false,
        ola,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorEscena oldDelegate) => false;
}

/// Contenedor de reciclaje con su color.
class DibujoContenedor extends StatelessWidget {
  const DibujoContenedor({required this.id, this.tamano = 64, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(painter: _PintorContenedor(id)),
  );
}

/// Colores (claro, oscuro) de cada contenedor.
(Color, Color) coloresContenedor(String id) => switch (id) {
  'amarillo' => (const Color(0xFFFFEB3B), const Color(0xFFF9A825)),
  'azul' => (const Color(0xFF64B5F6), const Color(0xFF1565C0)),
  'verde' => (const Color(0xFF81C784), const Color(0xFF2E7D32)),
  _ => (const Color(0xFFBCAAA4), const Color(0xFF6D4C41)),
};

class _PintorContenedor extends CustomPainter {
  const _PintorContenedor(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 100;
    canvas.save();
    canvas.scale(s);
    final (claro, oscuro) = coloresContenedor(id);
    final cuerpo = RRect.fromRectAndRadius(
      const Rect.fromLTWH(18, 30, 64, 60),
      const Radius.circular(8),
    );
    final tapa = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 20, 76, 14),
      const Radius.circular(6),
    );
    final blanco = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(cuerpo, blanco);
    canvas.drawRRect(tapa, blanco);
    canvas.drawRRect(
      cuerpo,
      Paint()
        ..shader = LinearGradient(colors: [claro, oscuro])
            .createShader(cuerpo.outerRect),
    );
    canvas.drawRRect(tapa, Paint()..color = oscuro);
    final borde = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(cuerpo, borde);
    canvas.drawRRect(tapa, borde);
    // Flechas del reciclaje.
    final flecha = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(50, 60), radius: 14),
        i * 2 * math.pi / 3,
        1.5,
        false,
        flecha,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorContenedor oldDelegate) => id != oldDelegate.id;
}

/// Residuos y elementos de la escena, como pegatinas.
class DibujoResiduo extends StatelessWidget {
  const DibujoResiduo({required this.id, this.tamano = 56, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(painter: _PintorResiduo(id)),
  );
}

class _Capa {
  const _Capa(this.forma, this.colores, this.borde);

  final Path forma;
  final List<Color> colores;
  final Color borde;
}

Path _ovalo(double x, double y, double a, double b) =>
    Path()..addOval(Rect.fromCenter(center: Offset(x, y), width: a, height: b));

Path _caja(double x, double y, double a, double b, [double r = 4]) =>
    Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: a, height: b),
        Radius.circular(r),
      ),
    );

Path _union(List<Path> p) =>
    p.reduce((a, b) => Path.combine(PathOperation.union, a, b));

List<_Capa> _capas(String id) {
  const verde = [Color(0xFF9CCC65), Color(0xFF388E3C)];
  const bordeVerde = Color(0xFF1B5E20);
  switch (id) {
    case 'botella':
      return [
        _Capa(
          _union([_caja(50, 60, 30, 56, 8), _caja(50, 28, 14, 14, 3)]),
          const [Color(0xFFE1F5FE), Color(0xFF81D4FA)],
          const Color(0xFF0277BD),
        ),
        _Capa(_caja(50, 20, 16, 8, 2), const [
          Color(0xFF42A5F5),
          Color(0xFF1565C0),
        ], const Color(0xFF0D3C78)),
        _Capa(_caja(50, 60, 30, 14, 2), const [
          Color(0xFFEF5350),
          Color(0xFFC62828),
        ], const Color(0xFF7F0000)),
      ];
    case 'lata':
      return [
        _Capa(_caja(50, 54, 36, 58, 8), const [
          Color(0xFFB0BEC5),
          Color(0xFF607D8B),
        ], const Color(0xFF263238)),
        _Capa(_caja(50, 54, 36, 22, 2), const [
          Color(0xFF66BB6A),
          Color(0xFF2E7D32),
        ], const Color(0xFF1B5E20)),
      ];
    case 'bolsa':
      return [
        _Capa(
          Path()
            ..moveTo(26, 34)
            ..lineTo(74, 34)
            ..quadraticBezierTo(80, 62, 72, 88)
            ..lineTo(28, 88)
            ..quadraticBezierTo(20, 62, 26, 34)
            ..close(),
          const [Color(0xFFFFFFFF), Color(0xFFE0E0E0)],
          const Color(0xFF757575),
        ),
        _Capa(
          Path.combine(
            PathOperation.difference,
            _ovalo(38, 30, 16, 22),
            _ovalo(38, 30, 8, 14),
          ),
          const [Color(0xFFFFFFFF), Color(0xFFE0E0E0)],
          const Color(0xFF757575),
        ),
        _Capa(
          Path.combine(
            PathOperation.difference,
            _ovalo(62, 30, 16, 22),
            _ovalo(62, 30, 8, 14),
          ),
          const [Color(0xFFFFFFFF), Color(0xFFE0E0E0)],
          const Color(0xFF757575),
        ),
      ];
    case 'envoltorio':
      return [
        _Capa(
          _union([
            _ovalo(50, 56, 40, 26),
            Path()
              ..moveTo(32, 56)
              ..lineTo(14, 42)
              ..lineTo(14, 70)
              ..close(),
            Path()
              ..moveTo(68, 56)
              ..lineTo(86, 42)
              ..lineTo(86, 70)
              ..close(),
          ]),
          const [Color(0xFFFF80AB), Color(0xFFD81B60)],
          const Color(0xFF880E4F),
        ),
      ];
    case 'brik':
      return [
        _Capa(
          _union([
            _caja(50, 58, 40, 58, 3),
            Path()
              ..moveTo(30, 30)
              ..lineTo(50, 18)
              ..lineTo(70, 30)
              ..close(),
          ]),
          const [Color(0xFFFFFFFF), Color(0xFFBBDEFB)],
          const Color(0xFF1565C0),
        ),
        _Capa(_caja(50, 60, 40, 18, 1), const [
          Color(0xFF90CAF9),
          Color(0xFF1E88E5),
        ], const Color(0xFF0D47A1)),
      ];
    case 'periodico':
      return [
        _Capa(_caja(50, 56, 58, 46, 3), const [
          Color(0xFFFAFAFA),
          Color(0xFFE0E0E0),
        ], const Color(0xFF616161)),
      ];
    case 'caja':
      return [
        _Capa(_caja(50, 58, 60, 44, 3), const [
          Color(0xFFD7A86E),
          Color(0xFFA1673A),
        ], const Color(0xFF5D3A1A)),
        _Capa(_caja(50, 40, 60, 8, 2), const [
          Color(0xFFE0B98B),
          Color(0xFFB98454),
        ], const Color(0xFF5D3A1A)),
      ];
    case 'tarro':
      return [
        _Capa(_caja(50, 58, 40, 50, 8), const [
          Color(0xFFE8F5E9),
          Color(0xFFA5D6A7),
        ], const Color(0xFF2E7D32)),
        _Capa(_caja(50, 30, 36, 10, 3), const [
          Color(0xFFFFB74D),
          Color(0xFFE65100),
        ], const Color(0xFF8D3B00)),
      ];
    case 'botella-vidrio':
      return [
        _Capa(
          _union([_caja(50, 64, 30, 46, 8), _caja(50, 30, 12, 26, 3)]),
          const [Color(0xFFA5D6A7), Color(0xFF2E7D32)],
          const Color(0xFF1B5E20),
        ),
      ];
    case 'cascara':
      return [
        _Capa(
          Path()
            ..moveTo(50, 30)
            ..quadraticBezierTo(20, 50, 24, 86)
            ..quadraticBezierTo(40, 70, 50, 54)
            ..quadraticBezierTo(60, 70, 76, 86)
            ..quadraticBezierTo(80, 50, 50, 30)
            ..close(),
          const [Color(0xFFFFF176), Color(0xFFFBC02D)],
          const Color(0xFF8D6E00),
        ),
      ];
    case 'manzana-mordida':
      return [
        _Capa(
          Path.combine(
            PathOperation.difference,
            _union([_ovalo(42, 58, 40, 46), _ovalo(58, 58, 40, 46)]),
            _union([_ovalo(80, 52, 22, 22), _ovalo(78, 70, 18, 18)]),
          ),
          const [Color(0xFFFF6B6B), Color(0xFFC62828)],
          const Color(0xFF7F0000),
        ),
        _Capa(
          Path()
            ..moveTo(50, 36)
            ..lineTo(52, 22)
            ..lineTo(55, 23)
            ..lineTo(53, 36)
            ..close(),
          const [Color(0xFF8D6E63), Color(0xFF5D4037)],
          const Color(0xFF3E2723),
        ),
      ];
    case 'flor':
      return [
        _Capa(_caja(50, 72, 5, 34, 2), verde, bordeVerde),
        _Capa(
          _union([
            for (var i = 0; i < 5; i++)
              _ovalo(
                50 + math.cos(i * 1.256) * 12,
                40 + math.sin(i * 1.256) * 12,
                18,
                18,
              ),
          ]),
          const [Color(0xFFE1BEE7), Color(0xFF8E24AA)],
          const Color(0xFF4A148C),
        ),
        _Capa(_ovalo(50, 40, 12, 12), const [
          Color(0xFFFFEE58),
          Color(0xFFF9A825),
        ], const Color(0xFF8D6E00)),
      ];
    case 'seta':
      return [
        _Capa(_caja(50, 70, 18, 30, 6), const [
          Color(0xFFFFFFFF),
          Color(0xFFEEEEEE),
        ], const Color(0xFF9E9E9E)),
        _Capa(
          Path()
            ..moveTo(18, 58)
            ..quadraticBezierTo(50, 10, 82, 58)
            ..close(),
          const [Color(0xFFEF5350), Color(0xFFB71C1C)],
          const Color(0xFF5F0B0B),
        ),
      ];
    case 'hoja':
      return [
        _Capa(
          Path()
            ..moveTo(22, 80)
            ..quadraticBezierTo(18, 30, 78, 22)
            ..quadraticBezierTo(76, 76, 22, 80)
            ..close(),
          const [Color(0xFFFFB74D), Color(0xFFE65100)],
          const Color(0xFF8D3B00),
        ),
      ];
    case 'pina':
      return [
        _Capa(_ovalo(50, 56, 38, 54), const [
          Color(0xFFBCAAA4),
          Color(0xFF6D4C41),
        ], const Color(0xFF3E2723)),
      ];
  }
  return [_Capa(_ovalo(50, 54, 40, 40), verde, bordeVerde)];
}

class _PintorResiduo extends CustomPainter {
  const _PintorResiduo(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 100;
    canvas.save();
    canvas.translate((size.width - 100 * s) / 2, (size.height - 100 * s) / 2);
    canvas.scale(s);
    final capas = _capas(id);
    final pegatina = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.round;
    for (final capa in capas) {
      canvas.drawPath(capa.forma, pegatina);
    }
    for (final capa in capas) {
      canvas.drawPath(
        capa.forma,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: capa.colores,
          ).createShader(capa.forma.getBounds()),
      );
      canvas.drawPath(
        capa.forma,
        Paint()
          ..color = capa.borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }
    final linea = Paint()
      ..color = const Color(0xFF757575)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    switch (id) {
      case 'periodico':
        for (final y in [42.0, 50.0, 58.0, 66.0]) {
          canvas.drawLine(Offset(28, y), Offset(y == 42 ? 72 : 60, y), linea);
        }
      case 'seta':
        final punto = Paint()..color = Colors.white;
        for (final (x, y) in const [(40.0, 40.0), (56.0, 34.0), (64.0, 48.0)]) {
          canvas.drawCircle(Offset(x, y), 4, punto);
        }
      case 'hoja':
        canvas.drawLine(
          const Offset(24, 78),
          const Offset(74, 26),
          linea..color = const Color(0xFF8D3B00),
        );
      case 'pina':
        final escama = Paint()
          ..color = const Color(0xFF3E2723)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        for (var y = 38.0; y < 80; y += 9) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(50, y), width: 30, height: 10),
            0,
            math.pi,
            false,
            escama,
          );
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PintorResiduo oldDelegate) => id != oldDelegate.id;
}
