import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Una misma fuente vectorial para escena, bandeja y cuaderno.
class DibujoEcosistema extends StatelessWidget {
  const DibujoEcosistema({
    this.elemento,
    this.colocados = const {'hierba', 'conejo', 'zorro'},
    super.key,
  });
  final String? elemento;
  final Set<String> colocados;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _ClaroPainter(elemento, colocados),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _ClaroPainter extends CustomPainter {
  const _ClaroPainter(this.elemento, this.colocados);
  final String? elemento;
  final Set<String> colocados;
  static const tinta = Color(0xFF354B35);
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (elemento != null) {
      final escala = math.min(size.width / 130, size.height / 130);
      canvas.translate(
        (size.width - 130 * escala) / 2,
        (size.height - 130 * escala) / 2,
      );
      canvas.scale(escala);
      _animal(canvas, elemento!);
      return;
    }
    canvas.save();
    canvas.scale(size.width / 600, size.height / 360);
    canvas.clipRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 600, 360),
        const Radius.circular(24),
      ),
    );
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 600, 360),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDAEEE0), Color(0xFFF6F1CD)],
        ).createShader(const Rect.fromLTWH(0, 0, 600, 360)),
    );
    // Luz entre los árboles: fondo quieto, sin distracciones animadas.
    _path(
      canvas,
      Path()
        ..moveTo(308, 0)
        ..lineTo(390, 0)
        ..lineTo(530, 320)
        ..lineTo(175, 320)
        ..close(),
      const Color(0x26FFFEDE),
    );
    for (final t in [
      (35.0, 95.0, 1.0),
      (125.0, 77.0, .8),
      (466.0, 60.0, .9),
      (555.0, 80.0, 1.1),
    ]) {
      canvas.save();
      canvas.translate(t.$1, t.$2);
      canvas.scale(t.$3);
      _path(
        canvas,
        Path()
          ..moveTo(-10, 185)
          ..cubicTo(-2, 105, -11, 54, -6, 0)
          ..lineTo(9, 0)
          ..cubicTo(5, 70, 13, 125, 16, 185)
          ..close(),
        const Color(0xFFABC5A3),
      );
      _oval(
        canvas,
        const Rect.fromLTWH(-52, -30, 112, 100),
        const Color(0xFFB5D3AC),
      );
      _oval(
        canvas,
        const Rect.fromLTWH(-40, -50, 85, 95),
        const Color(0xFFC4DBB7),
      );
      canvas.restore();
    }
    _path(
      canvas,
      Path()
        ..moveTo(0, 243)
        ..cubicTo(160, 200, 260, 228, 370, 218)
        ..cubicTo(465, 211, 520, 218, 600, 230)
        ..lineTo(600, 360)
        ..lineTo(0, 360)
        ..close(),
      const Color(0xFFB4C98B),
    );
    _path(
      canvas,
      Path()
        ..moveTo(0, 285)
        ..cubicTo(165, 232, 300, 265, 420, 248)
        ..cubicTo(500, 245, 560, 263, 600, 259)
        ..lineTo(600, 360)
        ..lineTo(0, 360)
        ..close(),
      const Color(0xFFD6D9A4),
    );
    _oval(
      canvas,
      const Rect.fromLTWH(88, 242, 450, 106),
      const Color(0xFFE7DEAF),
    );
    // Primer plano: troncos con ramificaciones y copas de silueta orgánica.
    for (final derecha in [false, true]) {
      canvas.save();
      if (derecha) {
        canvas.translate(600, 0);
        canvas.scale(-1, 1);
      }
      _path(
        canvas,
        Path()
          ..moveTo(0, 310)
          ..lineTo(0, 0)
          ..lineTo(65, 0)
          ..cubicTo(47, 75, 50, 116, 57, 157)
          ..lineTo(91, 126)
          ..lineTo(104, 130)
          ..lineTo(60, 184)
          ..cubicTo(56, 226, 64, 270, 79, 307)
          ..lineTo(49, 296)
          ..lineTo(29, 316)
          ..close(),
        const Color(0xFF8C7653),
      );
      _stroke(
        canvas,
        Path()
          ..moveTo(25, 30)
          ..cubicTo(13, 126, 36, 216, 32, 281),
        const Color(0xFFAD9468),
        6,
      );
      _stroke(
        canvas,
        Path()
          ..moveTo(45, 203)
          ..quadraticBezierTo(43, 247, 56, 275),
        const Color(0xFF6C6548),
        3,
      );
      _path(
        canvas,
        Path()
          ..moveTo(0, 0)
          ..lineTo(203, 0)
          ..cubicTo(201, 25, 184, 40, 154, 38)
          ..cubicTo(151, 65, 121, 75, 99, 60)
          ..cubicTo(74, 88, 45, 79, 36, 61)
          ..cubicTo(12, 74, 0, 60, 0, 52)
          ..close(),
        const Color(0xFF658C5D),
      );
      _path(
        canvas,
        Path()
          ..moveTo(0, 0)
          ..lineTo(174, 0)
          ..cubicTo(159, 26, 136, 30, 114, 20)
          ..cubicTo(91, 49, 68, 41, 55, 28)
          ..cubicTo(34, 47, 10, 34, 0, 40)
          ..close(),
        const Color(0xFF85A66D),
      );
      _fern(canvas, 34, 329, .8);
      _fern(canvas, 77, 338, .55);
      canvas.restore();
    }
    // Textura determinista y muy ligera del suelo.
    for (var i = 0; i < 23; i++) {
      final x = 65.0 + (i * 67 % 470), y = 286.0 + (i * 23 % 58);
      _stroke(
        canvas,
        Path()
          ..moveTo(x, y)
          ..lineTo(x + 5, y - 2),
        const Color(0xFFBBC58A),
        2,
      );
    }
    for (final id in ['hierba', 'conejo', 'zorro']) {
      if (!colocados.contains(id)) continue;
      final r = zonaElemento(id);
      canvas.save();
      canvas.translate(r.left * 600, r.top * 360);
      canvas.scale(r.width * 600 / 130, r.height * 360 / 130);
      _animal(canvas, id);
      canvas.restore();
    }
    // Flores pequeñas, fuera de los destinos.
    for (final p in [
      const Offset(91, 292),
      const Offset(510, 330),
      const Offset(402, 324),
    ]) {
      _stroke(
        canvas,
        Path()
          ..moveTo(p.dx, p.dy)
          ..lineTo(p.dx, p.dy - 13),
        const Color(0xFF6E8F50),
        2,
      );
      for (var i = 0; i < 5; i++) {
        final a = i * math.pi * 2 / 5;
        canvas.drawCircle(
          p + Offset(math.cos(a) * 4, math.sin(a) * 4 - 15),
          3.3,
          Paint()..color = const Color(0xFFFFFBE7),
        );
      }
      canvas.drawCircle(
        p + const Offset(0, -15),
        2.2,
        Paint()..color = const Color(0xFFE6AD49),
      );
    }
    canvas.restore();
  }

  void _animal(Canvas c, String id) {
    _oval(c, const Rect.fromLTWH(12, 111, 108, 12), const Color(0x244C6339));
    switch (id) {
      case 'hierba':
        _hierba(c);
      case 'conejo':
        _conejo(c);
      case 'zorro':
        _zorro(c);
    }
  }

  void _hierba(Canvas c) {
    for (var i = 0; i < 11; i++) {
      final x = 16.0 + i * 9, top = 35.0 + (i * 17 % 47);
      _path(
        c,
        Path()
          ..moveTo(x, 115)
          ..quadraticBezierTo(x - 13, top + 22, x - 9, top)
          ..quadraticBezierTo(x + 6, top + 19, x + 8, 113)
          ..close(),
        i.isEven ? const Color(0xFF4E8B4A) : const Color(0xFF79A64D),
      );
      _path(
        c,
        Path()
          ..moveTo(x, 115)
          ..quadraticBezierTo(x + 4, top + 5, x + 22, top - 9)
          ..quadraticBezierTo(x + 15, top + 32, x + 7, 115)
          ..close(),
        const Color(0xFF92B95A),
      );
    }
    for (var i = 0; i < 3; i++) {
      final x = 38.0 + i * 29;
      _stroke(
        c,
        Path()
          ..moveTo(x, 112)
          ..quadraticBezierTo(x + 1, 77, x - 3, 46),
        const Color(0xFF537C3B),
        2,
      );
      _oval(c, Rect.fromLTWH(x - 7, 33, 7, 18), const Color(0xFFC2B56B));
    }
  }

  void _conejo(Canvas c) {
    // Cola, cuerpo y patas traseras; la cara queda despejada.
    _oval(
      c,
      const Rect.fromLTWH(91, 75, 25, 25),
      const Color(0xFFF5F0DF),
      borde: const Color(0xFFAE9F85),
    );
    _path(
      c,
      Path()
        ..moveTo(44, 110)
        ..cubicTo(26, 88, 46, 56, 74, 59)
        ..cubicTo(100, 60, 112, 89, 100, 108)
        ..quadraticBezierTo(76, 123, 44, 110)
        ..close(),
      const Color(0xFFC9BA9C),
      borde: const Color(0xFF8C8169),
    );
    _oval(c, const Rect.fromLTWH(72, 89, 30, 25), const Color(0xFFE4D8BD));
    _oval(
      c,
      const Rect.fromLTWH(48, 103, 27, 12),
      const Color(0xFFF2E8D2),
      borde: const Color(0xFF9C8D72),
    );
    // Orejas curvas, interiores cálidos.
    _path(
      c,
      Path()
        ..moveTo(40, 54)
        ..cubicTo(16, 19, 25, 1, 35, 10)
        ..cubicTo(46, 23, 47, 35, 49, 51)
        ..close(),
      const Color(0xFFD7C8AC),
      borde: const Color(0xFF8C8169),
    );
    _path(
      c,
      Path()
        ..moveTo(52, 52)
        ..cubicTo(42, 14, 56, -1, 64, 12)
        ..cubicTo(70, 26, 65, 41, 61, 53)
        ..close(),
      const Color(0xFFD7C8AC),
      borde: const Color(0xFF8C8169),
    );
    _stroke(
      c,
      Path()
        ..moveTo(37, 40)
        ..quadraticBezierTo(25, 14, 32, 15),
      const Color(0xFFD7A99C),
      5,
    );
    _stroke(
      c,
      Path()
        ..moveTo(55, 41)
        ..quadraticBezierTo(51, 16, 59, 14),
      const Color(0xFFD7A99C),
      5,
    );
    _path(
      c,
      Path()
        ..moveTo(27, 62)
        ..cubicTo(30, 45, 60, 42, 68, 59)
        ..cubicTo(78, 80, 63, 91, 43, 87)
        ..cubicTo(24, 86, 17, 76, 27, 62)
        ..close(),
      const Color(0xFFE4D8BD),
      borde: const Color(0xFF8C8169),
    );
    _oval(c, const Rect.fromLTWH(22, 67, 25, 17), const Color(0xFFF8F1DF));
    _oval(c, const Rect.fromLTWH(23, 67, 7, 5), const Color(0xFFC58982));
    _oval(c, const Rect.fromLTWH(43, 59, 6, 8), tinta);
    _oval(c, const Rect.fromLTWH(44, 59, 2, 3), Colors.white);
    _stroke(
      c,
      Path()
        ..moveTo(28, 76)
        ..quadraticBezierTo(33, 81, 38, 76),
      const Color(0xFF8C8169),
      1.6,
    );
    for (var i = 0; i < 2; i++) {
      _stroke(
        c,
        Path()
          ..moveTo(28, 75 + i * 3)
          ..lineTo(13, 71 + i * 7),
        const Color(0xFFA99B80),
        1,
      );
    }
    _stroke(
      c,
      Path()
        ..moveTo(84, 96)
        ..quadraticBezierTo(75, 88, 73, 99),
      const Color(0xFFB2A184),
      2,
    );
  }

  void _zorro(Canvas c) {
    // Cola frondosa con punta crema y un contorno continuo.
    final cola = Path()
      ..moveTo(78, 108)
      ..cubicTo(97, 112, 123, 102, 125, 63)
      ..cubicTo(115, 66, 95, 69, 91, 83)
      ..quadraticBezierTo(85, 95, 78, 108)
      ..close();
    _path(c, cola, const Color(0xFFCB6B34), borde: const Color(0xFF91572F));
    c.save();
    c.clipPath(cola);
    _path(
      c,
      Path()
        ..moveTo(107, 53)
        ..lineTo(136, 52)
        ..lineTo(134, 91)
        ..lineTo(113, 87)
        ..lineTo(115, 78)
        ..lineTo(105, 76)
        ..close(),
      const Color(0xFFF8EACB),
    );
    c.restore();
    _path(
      c,
      Path()
        ..moveTo(40, 66)
        ..cubicTo(60, 58, 84, 66, 88, 91)
        ..lineTo(89, 111)
        ..lineTo(73, 113)
        ..lineTo(68, 96)
        ..lineTo(58, 95)
        ..lineTo(55, 113)
        ..lineTo(39, 113)
        ..quadraticBezierTo(34, 87, 40, 66)
        ..close(),
      const Color(0xFFDC8747),
      borde: const Color(0xFF91572F),
    );
    _path(
      c,
      Path()
        ..moveTo(41, 78)
        ..quadraticBezierTo(59, 79, 60, 99)
        ..lineTo(54, 108)
        ..lineTo(43, 106)
        ..close(),
      const Color(0xFFF3DFBC),
    );
    _path(
      c,
      Path()
        ..moveTo(39, 103)
        ..lineTo(55, 104)
        ..lineTo(55, 114)
        ..lineTo(40, 114)
        ..close(),
      const Color(0xFF69503B),
    );
    _path(
      c,
      Path()
        ..moveTo(73, 104)
        ..lineTo(88, 105)
        ..lineTo(89, 114)
        ..lineTo(74, 114)
        ..close(),
      const Color(0xFF69503B),
    );
    // Orejas y cara de frente, ojos atentos sin gesto amenazante.
    _path(
      c,
      Path()
        ..moveTo(22, 52)
        ..quadraticBezierTo(16, 26, 20, 16)
        ..quadraticBezierTo(38, 23, 43, 37)
        ..quadraticBezierTo(51, 34, 59, 37)
        ..quadraticBezierTo(66, 18, 79, 16)
        ..quadraticBezierTo(83, 38, 75, 55)
        ..close(),
      const Color(0xFFD5783F),
      borde: const Color(0xFF91572F),
    );
    _path(
      c,
      Path()
        ..moveTo(24, 40)
        ..lineTo(24, 25)
        ..quadraticBezierTo(34, 29, 36, 38)
        ..close(),
      const Color(0xFF87604A),
    );
    _path(
      c,
      Path()
        ..moveTo(63, 38)
        ..quadraticBezierTo(70, 25, 75, 25)
        ..lineTo(73, 42)
        ..close(),
      const Color(0xFF87604A),
    );
    _path(
      c,
      Path()
        ..moveTo(19, 49)
        ..quadraticBezierTo(46, 31, 77, 49)
        ..lineTo(82, 62)
        ..quadraticBezierTo(63, 72, 51, 84)
        ..quadraticBezierTo(32, 79, 16, 62)
        ..close(),
      const Color(0xFFEC9A55),
      borde: const Color(0xFF91572F),
    );
    _path(
      c,
      Path()
        ..moveTo(18, 55)
        ..quadraticBezierTo(34, 54, 50, 73)
        ..quadraticBezierTo(64, 54, 79, 55)
        ..lineTo(81, 62)
        ..quadraticBezierTo(62, 74, 51, 84)
        ..quadraticBezierTo(31, 79, 16, 62)
        ..close(),
      const Color(0xFFFFF0D4),
    );
    for (final x in [33.0, 64.0]) {
      _oval(c, Rect.fromLTWH(x, 51, 5, 7), tinta);
      _oval(c, Rect.fromLTWH(x + 1, 51, 1.8, 2.4), Colors.white);
    }
    _path(
      c,
      Path()
        ..moveTo(44, 73)
        ..quadraticBezierTo(51, 69, 57, 73)
        ..quadraticBezierTo(51, 81, 44, 73)
        ..close(),
      tinta,
    );
    _stroke(
      c,
      Path()
        ..moveTo(50, 79)
        ..quadraticBezierTo(55, 83, 59, 79),
      const Color(0xFF99714C),
      1.3,
    );
    _stroke(
      c,
      Path()
        ..moveTo(59, 91)
        ..quadraticBezierTo(67, 87, 71, 91),
      const Color(0xFFBD6F39),
      2,
    );
  }

  void _fern(Canvas c, double x, double y, double s) {
    c.save();
    c.translate(x, y);
    c.scale(s);
    for (var i = 0; i < 5; i++) {
      final dx = (i - 2) * 12.0;
      _path(
        c,
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(dx - 12, -25, dx, -49 + i * 3)
          ..quadraticBezierTo(dx + 14, -22, 0, 0)
          ..close(),
        i.isEven ? const Color(0xFF587C4B) : const Color(0xFF739755),
      );
    }
    c.restore();
  }

  void _path(Canvas c, Path p, Color color, {Color? borde}) {
    c.drawPath(p, Paint()..color = color);
    if (borde != null) {
      c.drawPath(
        p,
        Paint()
          ..color = borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _oval(Canvas c, Rect r, Color color, {Color? borde}) {
    c.drawOval(r, Paint()..color = color);
    if (borde != null) {
      c.drawOval(
        r,
        Paint()
          ..color = borde
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  void _stroke(Canvas c, Path p, Color color, double width) => c.drawPath(
    p,
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
  @override
  bool shouldRepaint(_ClaroPainter old) =>
      old.elemento != elemento ||
      !old.colocados.containsAll(colocados) ||
      !colocados.containsAll(old.colocados);
}

/// Geometría normalizada compartida por dibujo y destinos táctiles.
Rect zonaElemento(String id) => switch (id) {
  'hierba' => const Rect.fromLTWH(.16, .49, .25, .43),
  'conejo' => const Rect.fromLTWH(.42, .43, .24, .43),
  _ => const Rect.fromLTWH(.69, .40, .25, .45),
};
