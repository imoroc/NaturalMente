import 'dart:math' as math;

import 'package:flutter/material.dart';

// Dibujos de «¿Cómo me siento?»: una cara por emoción y un icono por
// situación. Las caras se pintan con el mismo borde blanco de pegatina que
// el resto de la app.

const idsSitiosEmocion = {
  'alegria',
  'tristeza',
  'enfado',
  'miedo',
  'verguenza',
  'nervios',
};

/// Colores (cara, borde) de cada emoción.
(Color, Color) _colores(String id) => switch (id) {
  'alegria' => (const Color(0xFFFFE066), const Color(0xFFF59E0B)),
  'tristeza' => (const Color(0xFF93C5FD), const Color(0xFF2563EB)),
  'enfado' => (const Color(0xFFFCA5A5), const Color(0xFFDC2626)),
  'miedo' => (const Color(0xFFD8B4FE), const Color(0xFF7C3AED)),
  'verguenza' => (const Color(0xFFFBCFE8), const Color(0xFFDB2777)),
  _ => (const Color(0xFFFDBA74), const Color(0xFFEA580C)),
};

Color colorSitioEmocion(String id) => _colores(id).$1.withValues(alpha: .35);
Color bordeSitioEmocion(String id) => _colores(id).$2;

String? subtituloSitioEmocion(String id) => switch (id) {
  'alegria' => 'Ganas de reír',
  'tristeza' => 'Ganas de llorar',
  'enfado' => 'Aprieto los puños',
  'miedo' => 'Me encojo',
  'verguenza' => 'Se me pone la cara roja',
  'nervios' => 'Me tiemblan las manos',
  _ => null,
};

class DibujoEmocion extends StatelessWidget {
  const DibujoEmocion({required this.id, this.tamano = 48, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(painter: _PintorCara(id)),
  );
}

class _PintorCara extends CustomPainter {
  const _PintorCara(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 100;
    canvas.save();
    canvas.scale(s);
    final (cara, borde) = _colores(id);
    const centro = Offset(50, 50);
    canvas.drawCircle(centro, 44, Paint()..color = Colors.white);
    canvas.drawCircle(
      centro,
      40,
      Paint()
        ..shader = RadialGradient(
          colors: [Color.lerp(cara, Colors.white, .35)!, cara],
          center: const Alignment(-.3, -.4),
        ).createShader(Rect.fromCircle(center: centro, radius: 40)),
    );
    canvas.drawCircle(centro, 40, _trazo(borde, 3));
    final tinta = _trazo(const Color(0xFF1F2937), 4);
    final ojo = Paint()..color = const Color(0xFF1F2937);
    void ojos({double y = 42, double r = 4.5}) {
      canvas.drawCircle(Offset(36, y), r, ojo);
      canvas.drawCircle(Offset(64, y), r, ojo);
      final brillo = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(37.5, y - 1.5), r * .35, brillo);
      canvas.drawCircle(Offset(65.5, y - 1.5), r * .35, brillo);
    }

    switch (id) {
      case 'alegria':
        ojos();
        canvas.drawArc(
          const Rect.fromLTWH(30, 44, 40, 26),
          .2,
          math.pi - .4,
          false,
          tinta,
        );
        _mejillas(canvas, const Color(0x66F97316));
      case 'tristeza':
        ojos(y: 44);
        canvas.drawArc(
          const Rect.fromLTWH(34, 62, 32, 18),
          math.pi + .3,
          math.pi - .6,
          false,
          tinta,
        );
        canvas.drawLine(const Offset(28, 33), const Offset(40, 30), tinta);
        canvas.drawLine(const Offset(72, 33), const Offset(60, 30), tinta);
        final lagrima = Path()
          ..moveTo(36, 50)
          ..quadraticBezierTo(30, 60, 36, 63)
          ..quadraticBezierTo(42, 60, 36, 50)
          ..close();
        canvas.drawPath(lagrima, Paint()..color = const Color(0xFF3B82F6));
      case 'enfado':
        ojos(y: 45);
        canvas.drawLine(const Offset(27, 32), const Offset(43, 39), tinta);
        canvas.drawLine(const Offset(73, 32), const Offset(57, 39), tinta);
        canvas.drawArc(
          const Rect.fromLTWH(36, 62, 28, 16),
          math.pi + .2,
          math.pi - .4,
          false,
          tinta,
        );
      case 'miedo':
        ojos(r: 6);
        canvas.drawLine(const Offset(28, 30), const Offset(40, 26), tinta);
        canvas.drawLine(const Offset(72, 30), const Offset(60, 26), tinta);
        canvas.drawOval(
          const Rect.fromLTWH(41, 58, 18, 22),
          Paint()..color = const Color(0xFF1F2937),
        );
        _gota(canvas, const Offset(80, 30));
      case 'verguenza':
        final mirada = _trazo(const Color(0xFF1F2937), 3.5);
        canvas.drawArc(
          const Rect.fromLTWH(30, 40, 12, 8),
          0,
          math.pi,
          false,
          mirada,
        );
        canvas.drawArc(
          const Rect.fromLTWH(58, 40, 12, 8),
          0,
          math.pi,
          false,
          mirada,
        );
        canvas.drawArc(
          const Rect.fromLTWH(42, 60, 16, 10),
          .3,
          math.pi - .6,
          false,
          tinta,
        );
        _mejillas(canvas, const Color(0x99F43F5E), grande: true);
      default:
        ojos();
        final zigzag = Path()..moveTo(32, 68);
        for (var i = 1; i <= 6; i++) {
          zigzag.lineTo(32 + i * 6, i.isOdd ? 63 : 68);
        }
        canvas.drawPath(zigzag, tinta);
        _gota(canvas, const Offset(22, 32));
        _gota(canvas, const Offset(80, 34));
    }
    canvas.restore();
  }

  void _mejillas(Canvas canvas, Color color, {bool grande = false}) {
    final r = grande ? 9.0 : 6.0;
    canvas.drawCircle(const Offset(27, 56), r, Paint()..color = color);
    canvas.drawCircle(const Offset(73, 56), r, Paint()..color = color);
  }

  void _gota(Canvas canvas, Offset punta) {
    final gota = Path()
      ..moveTo(punta.dx, punta.dy)
      ..quadraticBezierTo(punta.dx - 6, punta.dy + 10, punta.dx, punta.dy + 12)
      ..quadraticBezierTo(punta.dx + 6, punta.dy + 10, punta.dx, punta.dy)
      ..close();
    canvas.drawPath(gota, Paint()..color = const Color(0xFF60A5FA));
    canvas.drawPath(gota, _trazo(Colors.white, 1.5));
  }

  @override
  bool shouldRepaint(_PintorCara oldDelegate) => id != oldDelegate.id;
}

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Icono de cada situación, con su color.
const situacionesEmocion = <String, (IconData, Color)>{
  'cumpleanos': (Icons.cake_rounded, Color(0xFFEC4899)),
  'perro-perdido': (Icons.pets_rounded, Color(0xFF2563EB)),
  'columpio': (Icons.front_hand_rounded, Color(0xFFDC2626)),
  'tormenta': (Icons.thunderstorm_rounded, Color(0xFF7C3AED)),
  'libros-suelo': (Icons.menu_book_rounded, Color(0xFFDB2777)),
  'funcion-cole': (Icons.theater_comedy_rounded, Color(0xFFEA580C)),
  'amiga-se-va': (Icons.directions_bus_rounded, Color(0xFF2563EB)),
  'gana-partido': (Icons.emoji_events_rounded, Color(0xFFF59E0B)),
  'dibujo-roto': (Icons.draw_rounded, Color(0xFFDC2626)),
  'equipo-solo': (Icons.sports_soccer_rounded, Color(0xFF2563EB)),
  'examen': (Icons.edit_note_rounded, Color(0xFFEA580C)),
  'leer-en-voz-alta': (Icons.record_voice_over_rounded, Color(0xFFDB2777)),
  'balon-quitado': (Icons.sports_basketball_rounded, Color(0xFFDC2626)),
  'ruidos-noche': (Icons.nightlight_round, Color(0xFF7C3AED)),
};
