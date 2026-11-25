import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Ilustración de la tarjeta de Aula: una pizarra con dibujos de tiza, unos
/// libros y una manzana. Está dibujada con código para verse nítida a
/// cualquier tamaño.
class IlustracionAula extends StatelessWidget {
  const IlustracionAula({this.ancho = 76, this.alto = 54, super.key});

  final double ancho;
  final double alto;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: ancho,
      height: alto,
      child: const CustomPaint(painter: PintorAula()),
    ),
  );
}

class PintorAula extends CustomPainter {
  const PintorAula();

  @override
  void paint(Canvas canvas, Size size) {
    // Se dibuja en una caja de 140 x 100 y se escala sin deformar.
    final escala = math.min(size.width / 140, size.height / 100);
    canvas
      ..save()
      ..translate(
        (size.width - 140 * escala) / 2,
        (size.height - 100 * escala) / 2,
      )
      ..scale(escala);

    Paint p(Color color) => Paint()..color = color;
    final trazo = Paint()
      ..color = const Color(0xFF3B2314)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    final tiza = Paint()
      ..color = const Color(0xFFF4FBF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Patas del caballete.
    final pata = Paint()
      ..color = const Color(0xFFB7793F)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(const Offset(30, 70), const Offset(22, 96), pata)
      ..drawLine(const Offset(92, 70), const Offset(100, 96), pata);

    // Marco de madera y pizarra.
    final marco = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 6, 106, 70),
      const Radius.circular(10),
    );
    canvas
      ..drawRRect(marco.shift(const Offset(0, 3)), p(const Color(0x33000000)))
      ..drawRRect(marco, p(const Color(0xFFD9954E)))
      ..drawRRect(marco, trazo);
    final pizarra = RRect.fromRectAndRadius(
      const Rect.fromLTWH(15, 12, 92, 56),
      const Radius.circular(6),
    );
    canvas
      ..drawRRect(pizarra, p(const Color(0xFF2F7A57)))
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(19, 15, 40, 10),
          const Radius.circular(5),
        ),
        p(const Color(0x22FFFFFF)),
      );

    // Garabatos de tiza: un sol, una planta y una casilla marcada.
    canvas.drawCircle(const Offset(32, 30), 6, tiza);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(32 + math.cos(a) * 9, 30 + math.sin(a) * 9),
        Offset(32 + math.cos(a) * 12, 30 + math.sin(a) * 12),
        tiza,
      );
    }
    canvas
      ..drawLine(const Offset(58, 60), const Offset(58, 40), tiza)
      ..drawPath(
        Path()
          ..moveTo(58, 48)
          ..quadraticBezierTo(48, 44, 47, 36)
          ..quadraticBezierTo(56, 37, 58, 48),
        tiza,
      )
      ..drawPath(
        Path()
          ..moveTo(58, 44)
          ..quadraticBezierTo(68, 40, 69, 32)
          ..quadraticBezierTo(60, 33, 58, 44),
        tiza,
      );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(78, 26, 18, 18),
          const Radius.circular(3),
        ),
        tiza,
      )
      ..drawPath(
        Path()
          ..moveTo(81, 35)
          ..lineTo(86, 40)
          ..lineTo(95, 28),
        tiza..color = const Color(0xFFFFE066),
      );

    // Repisa con tiza.
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(14, 70, 94, 6),
          const Radius.circular(3),
        ),
        p(const Color(0xFFB7793F)),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(70, 66, 14, 4),
          const Radius.circular(2),
        ),
        p(const Color(0xFFFFFFFF)),
      );

    // Libros apilados.
    void libro(double y, double x, double ancho, Color color) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, ancho, 9),
        const Radius.circular(2.5),
      );
      canvas
        ..drawRRect(r, p(color))
        ..drawRect(
          Rect.fromLTWH(x + ancho - 8, y + 2, 6, 5),
          p(const Color(0xFFFFF6E0)),
        )
        ..drawRRect(r, trazo..strokeWidth = 2.2);
    }

    libro(88, 100, 34, const Color(0xFF4F9BD9));
    libro(79, 104, 30, const Color(0xFFF29026));
    libro(70, 102, 28, const Color(0xFF8B5CF6));

    // Manzana encima de los libros.
    canvas
      ..drawCircle(const Offset(112, 61), 8, p(const Color(0xFFE5484D)))
      ..drawCircle(const Offset(122, 61), 8, p(const Color(0xFFE5484D)))
      ..drawCircle(const Offset(113, 58), 2.6, p(const Color(0x55FFFFFF)))
      ..drawLine(
        const Offset(117, 54),
        const Offset(118, 47),
        Paint()
          ..color = const Color(0xFF6D4C2F)
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      )
      ..drawPath(
        Path()
          ..moveTo(118, 50)
          ..quadraticBezierTo(126, 44, 130, 49)
          ..quadraticBezierTo(124, 54, 118, 50),
        p(const Color(0xFF40BE70)),
      );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PintorAula oldDelegate) => false;
}
