import 'dart:math' as math;

import 'package:flutter/widgets.dart';

export 'package:naturalmente/modelo/aula/juego_aula.dart' show escenasAula;

/// Una escena a pantalla completa (o en miniatura en el editor).
class EscenaAula extends StatelessWidget {
  const EscenaAula(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: PintorEscena(id), size: Size.infinite),
  );
}

class PintorEscena extends CustomPainter {
  const PintorEscena(this.id);
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final d = _Dibujo(canvas, size);
    switch (id) {
      case 'pradera':
        d.pradera();
      case 'bosque':
        d.bosque();
      case 'selva':
        d.selva();
      case 'fondo-marino':
        d.fondoMarino();
      case 'playa':
        d.playa();
      case 'desierto':
        d.desierto();
      case 'polar':
        d.polar();
      case 'montana':
        d.montana();
      case 'otono':
        d.otono();
      case 'granja':
        d.granja();
      case 'jardin':
        d.jardin();
      case 'noche':
        d.noche();
      default:
        d.pradera();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PintorEscena oldDelegate) =>
      oldDelegate.id != id;
}

/// Utilidades de dibujo. Todo se mide en proporción al tamaño, para que la
/// escena se vea bien en un móvil vertical, una tablet o el panel web.
class _Dibujo {
  _Dibujo(this.c, this.s)
    : w = s.width,
      h = s.height,
      // La unidad sigue al lado corto: los elementos no se deforman.
      u = math.min(s.width, s.height) / 100;

  final Canvas c;
  final Size s;
  final double w, h, u;

  Paint _p(Color color) => Paint()..color = color;

  void cielo(List<Color> colores, {List<double>? paradas}) {
    c.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colores,
          stops: paradas,
        ).createShader(Offset.zero & s),
    );
  }

  void sol(Offset centro, double r, Color color, {bool rayos = true}) {
    c.drawCircle(
      centro,
      r * 1.9,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.45), color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: centro, radius: r * 1.9)),
    );
    if (rayos) {
      final rayo = Paint()
        ..color = color.withValues(alpha: 0.7)
        ..strokeWidth = r * 0.16
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6;
        c.drawLine(
          centro + Offset(math.cos(a), math.sin(a)) * r * 1.25,
          centro + Offset(math.cos(a), math.sin(a)) * r * 1.6,
          rayo,
        );
      }
    }
    c.drawCircle(centro, r, _p(color));
  }

  void nube(
    Offset centro,
    double ancho, {
    Color color = const Color(0xFFFFFFFF),
  }) {
    final p = _p(color.withValues(alpha: 0.95));
    final r = ancho / 4;
    c.drawCircle(centro + Offset(-r * 1.1, r * 0.2), r * 0.8, p);
    c.drawCircle(centro + Offset(0, -r * 0.2), r * 1.05, p);
    c.drawCircle(centro + Offset(r * 1.15, r * 0.15), r * 0.85, p);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: centro + Offset(0, r * 0.45),
          width: ancho * 0.95,
          height: r * 1.1,
        ),
        Radius.circular(r),
      ),
      p,
    );
  }

  /// Colina suave que cubre desde [altura] (proporción de la altura) hasta abajo.
  void colina(
    double altura,
    double amplitud,
    Color color, {
    double fase = 0,
    double ondas = 1.2,
  }) {
    final base = h * altura;
    final path = Path()..moveTo(0, h);
    const pasos = 40;
    for (var i = 0; i <= pasos; i++) {
      final x = w * i / pasos;
      final y =
          base - math.sin((i / pasos) * math.pi * ondas + fase) * amplitud * u;
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, h)
      ..close();
    c.drawPath(path, _p(color));
  }

  void pino(double x, double base, double alto, Color color) {
    final ancho = alto * 0.55;
    c.drawRect(
      Rect.fromLTWH(
        x - alto * 0.05,
        base - alto * 0.15,
        alto * 0.1,
        alto * 0.15,
      ),
      _p(const Color(0xFF6D4C2F)),
    );
    for (var i = 0; i < 3; i++) {
      final arriba = base - alto * (0.15 + i * 0.25) - alto * 0.35;
      final abajo = base - alto * (0.1 + i * 0.25);
      final a = ancho * (1 - i * 0.22);
      c.drawPath(
        Path()
          ..moveTo(x, arriba)
          ..lineTo(x - a / 2, abajo)
          ..lineTo(x + a / 2, abajo)
          ..close(),
        _p(color),
      );
    }
  }

  void arbol(
    double x,
    double base,
    double alto,
    Color copa, {
    Color tronco = const Color(0xFF7A5230),
  }) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x - alto * 0.06,
          base - alto * 0.5,
          alto * 0.12,
          alto * 0.5,
        ),
        Radius.circular(alto * 0.04),
      ),
      _p(tronco),
    );
    final p = _p(copa);
    final r = alto * 0.26;
    c.drawCircle(Offset(x, base - alto * 0.72), r, p);
    c.drawCircle(Offset(x - r * 0.8, base - alto * 0.58), r * 0.8, p);
    c.drawCircle(Offset(x + r * 0.8, base - alto * 0.58), r * 0.8, p);
    c.drawCircle(
      Offset(x - r * 0.35, base - alto * 0.8),
      r * 0.35,
      _p(const Color(0xFFFFFFFF).withValues(alpha: 0.18)),
    );
  }

  void flor(
    Offset centro,
    double r,
    Color petalo, {
    Color corazon = const Color(0xFFFFD43B),
  }) {
    c.drawLine(
      centro,
      centro + Offset(0, r * 3),
      Paint()
        ..color = const Color(0xFF3F8F3A)
        ..strokeWidth = r * 0.35,
    );
    final p = _p(petalo);
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      c.drawCircle(centro + Offset(math.cos(a), math.sin(a)) * r, r * 0.75, p);
    }
    c.drawCircle(centro, r * 0.6, _p(corazon));
  }

  void mariposa(Offset centro, double r, Color color) {
    final p = _p(color);
    c.drawOval(
      Rect.fromCenter(
        center: centro + Offset(-r * 0.7, -r * 0.4),
        width: r * 1.4,
        height: r * 1.1,
      ),
      p,
    );
    c.drawOval(
      Rect.fromCenter(
        center: centro + Offset(r * 0.7, -r * 0.4),
        width: r * 1.4,
        height: r * 1.1,
      ),
      p,
    );
    c.drawOval(
      Rect.fromCenter(
        center: centro + Offset(-r * 0.5, r * 0.45),
        width: r,
        height: r * 0.8,
      ),
      p,
    );
    c.drawOval(
      Rect.fromCenter(
        center: centro + Offset(r * 0.5, r * 0.45),
        width: r,
        height: r * 0.8,
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: centro, width: r * 0.3, height: r * 1.6),
        Radius.circular(r),
      ),
      _p(const Color(0xFF3B2314)),
    );
  }

  void estrellas(int cantidad, double hasta, {int semilla = 7}) {
    final azar = math.Random(semilla);
    for (var i = 0; i < cantidad; i++) {
      final p = Offset(azar.nextDouble() * w, azar.nextDouble() * h * hasta);
      final r = (0.3 + azar.nextDouble() * 0.6) * u;
      c.drawCircle(
        p,
        r,
        _p(
          const Color(0xFFFFFFFF)
              .withValues(alpha: 0.5 + azar.nextDouble() * 0.5),
        ),
      );
    }
  }

  void olas(
    double altura,
    Color color, {
    double amplitud = 1.6,
    int crestas = 8,
    double fase = 0,
  }) {
    final base = h * altura;
    final path = Path()..moveTo(0, h);
    const pasos = 80;
    for (var i = 0; i <= pasos; i++) {
      final x = w * i / pasos;
      final y =
          base +
          math.sin(i / pasos * math.pi * 2 * crestas + fase) * amplitud * u;
      path.lineTo(x, y);
    }
    path
      ..lineTo(w, h)
      ..close();
    c.drawPath(path, _p(color));
  }

  void pez(Offset centro, double r, Color color, {bool derecha = true}) {
    final dir = derecha ? 1.0 : -1.0;
    final p = _p(color);
    c.drawOval(
      Rect.fromCenter(center: centro, width: r * 2.2, height: r * 1.3),
      p,
    );
    c.drawPath(
      Path()
        ..moveTo(centro.dx - dir * r * 0.9, centro.dy)
        ..lineTo(centro.dx - dir * r * 1.7, centro.dy - r * 0.7)
        ..lineTo(centro.dx - dir * r * 1.7, centro.dy + r * 0.7)
        ..close(),
      p,
    );
    c.drawCircle(
      centro + Offset(dir * r * 0.55, -r * 0.15),
      r * 0.18,
      _p(const Color(0xFF1F2937)),
    );
  }

  // --- Escenas ---------------------------------------------------------------

  void pradera() {
    cielo(const [Color(0xFF7CC8F5), Color(0xFFCDEBFB)]);
    sol(Offset(w * 0.82, h * 0.14), 9 * u, const Color(0xFFFFD43B));
    nube(Offset(w * 0.22, h * 0.14), 26 * u);
    nube(Offset(w * 0.55, h * 0.24), 18 * u);
    colina(0.58, 6, const Color(0xFF9ED36A), fase: 0.6);
    colina(0.68, 5, const Color(0xFF7CC152), fase: 2.1, ondas: 1.6);
    arbol(w * 0.18, h * 0.7, 26 * u, const Color(0xFF4E9F3D));
    arbol(w * 0.86, h * 0.72, 20 * u, const Color(0xFF5DB04A));
    colina(0.82, 3, const Color(0xFF5FAE45), fase: 1);
    final colores = [
      const Color(0xFFFF6B9A),
      const Color(0xFFFFFFFF),
      const Color(0xFFB57BFF),
      const Color(0xFFFF9F40),
    ];
    final azar = math.Random(3);
    for (var i = 0; i < 14; i++) {
      flor(
        Offset(azar.nextDouble() * w, h * (0.86 + azar.nextDouble() * 0.1)),
        1.6 * u,
        colores[i % colores.length],
      );
    }
  }

  void bosque() {
    cielo(const [Color(0xFFA7E1D8), Color(0xFFE6F7EE)]);
    sol(
      Offset(w * 0.2, h * 0.13),
      7 * u,
      const Color(0xFFFFE9A8),
      rayos: false,
    );
    colina(0.5, 5, const Color(0xFFB7DDB0), fase: 1);
    final capas = [
      (0.6, const Color(0xFF8CC58A), 22.0),
      (0.75, const Color(0xFF5E9F5C), 30.0),
      (0.95, const Color(0xFF2F6B3A), 40.0),
    ];
    for (final (base, color, alto) in capas) {
      final n = (w / (alto * u * 0.45)).ceil() + 1;
      for (var i = 0; i < n; i++) {
        final x = (i + (base * 10 % 1)) * w / (n - 1);
        pino(x, h * base, alto * u * (0.85 + (i % 3) * 0.1), color);
      }
    }
    // Setas en primer plano.
    for (final x in [0.15, 0.7, 0.86]) {
      final base = Offset(w * x, h * 0.97);
      c.drawRect(
        Rect.fromCenter(
          center: base + Offset(0, -2 * u),
          width: 1.6 * u,
          height: 4 * u,
        ),
        _p(const Color(0xFFFFF4E0)),
      );
      c.drawArc(
        Rect.fromCenter(
          center: base + Offset(0, -4 * u),
          width: 7 * u,
          height: 6 * u,
        ),
        math.pi,
        math.pi,
        true,
        _p(const Color(0xFFE5484D)),
      );
      c.drawCircle(
        base + Offset(-1.2 * u, -5.6 * u),
        0.6 * u,
        _p(const Color(0xFFFFFFFF)),
      );
      c.drawCircle(
        base + Offset(1.3 * u, -5 * u),
        0.5 * u,
        _p(const Color(0xFFFFFFFF)),
      );
    }
  }

  void selva() {
    cielo(const [Color(0xFF3FA66B), Color(0xFF9FE0A4)]);
    final azar = math.Random(11);
    // Rayos de luz entre las copas.
    for (var i = 0; i < 4; i++) {
      final x = w * (0.15 + i * 0.25);
      c.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 6 * u, 0)
          ..lineTo(x + 22 * u, h)
          ..lineTo(x + 10 * u, h)
          ..close(),
        _p(const Color(0xFFFFFFFF).withValues(alpha: 0.12)),
      );
    }
    // Lianas.
    final liana = Paint()
      ..color = const Color(0xFF2E7D4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * u;
    for (var i = 0; i < 5; i++) {
      final x = w * (0.1 + i * 0.2);
      final largo = h * (0.3 + azar.nextDouble() * 0.3);
      c.drawPath(
        Path()
          ..moveTo(x, 0)
          ..quadraticBezierTo(x + 6 * u, largo / 2, x, largo),
        liana,
      );
      c.drawOval(
        Rect.fromCenter(
          center: Offset(x, largo),
          width: 4 * u,
          height: 2.4 * u,
        ),
        _p(const Color(0xFF3B9B5E)),
      );
    }
    // Hojas grandes en los bordes.
    void hoja(Offset base, double largo, double angulo, Color color) {
      c.save();
      c.translate(base.dx, base.dy);
      c.rotate(angulo);
      c.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(largo * 0.5, -largo * 0.35, largo, 0)
          ..quadraticBezierTo(largo * 0.5, largo * 0.35, 0, 0),
        _p(color),
      );
      c.drawLine(
        Offset.zero,
        Offset(largo, 0),
        Paint()
          ..color = const Color(0x33FFFFFF)
          ..strokeWidth = 0.5 * u,
      );
      c.restore();
    }

    for (var i = 0; i < 9; i++) {
      final izquierda = i.isEven;
      hoja(
        Offset(izquierda ? 0 : w, h * (0.35 + i * 0.08)),
        (24 + azar.nextDouble() * 16) * u,
        izquierda
            ? -0.3 + azar.nextDouble() * 0.6
            : math.pi + 0.3 - azar.nextDouble() * 0.6,
        i % 3 == 0 ? const Color(0xFF1F6B3F) : const Color(0xFF2E8B57),
      );
    }
    colina(0.9, 2, const Color(0xFF1E5E38));
    for (final (x, color) in [
      (0.3, const Color(0xFFFF6B6B)),
      (0.62, const Color(0xFFFFB020)),
      (0.8, const Color(0xFFE056FD)),
    ]) {
      flor(Offset(w * x, h * 0.88), 2 * u, color);
    }
  }

  void fondoMarino() {
    cielo(const [Color(0xFF4FC3F7), Color(0xFF0B5E8E)]);
    for (var i = 0; i < 5; i++) {
      final x = w * (i * 0.22);
      c.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + 8 * u, 0)
          ..lineTo(x + 26 * u, h * 0.8)
          ..lineTo(x + 14 * u, h * 0.8)
          ..close(),
        _p(const Color(0xFFFFFFFF).withValues(alpha: 0.08)),
      );
    }
    final azar = math.Random(5);
    for (var i = 0; i < 18; i++) {
      final p = Offset(azar.nextDouble() * w, azar.nextDouble() * h * 0.8);
      c.drawCircle(
        p,
        (0.6 + azar.nextDouble()) * u,
        Paint()
          ..color = const Color(0x88FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.3 * u,
      );
    }
    pez(Offset(w * 0.25, h * 0.35), 4 * u, const Color(0xFFFF9F40));
    pez(
      Offset(w * 0.7, h * 0.5),
      3 * u,
      const Color(0xFFFFD43B),
      derecha: false,
    );
    pez(Offset(w * 0.55, h * 0.22), 2.5 * u, const Color(0xFFFF6B9A));
    colina(0.86, 3, const Color(0xFFF2D59B), fase: 0.5, ondas: 2);
    final alga = Paint()
      ..color = const Color(0xFF2E9E6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 * u
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final x = w * (0.05 + i * 0.15);
      final alto = (14 + azar.nextDouble() * 12) * u;
      c.drawPath(
        Path()
          ..moveTo(x, h * 0.9)
          ..cubicTo(
            x - 4 * u,
            h * 0.9 - alto / 3,
            x + 4 * u,
            h * 0.9 - alto * 2 / 3,
            x,
            h * 0.9 - alto,
          ),
        alga,
      );
    }
    for (final (x, color) in [
      (0.35, const Color(0xFFFF7A90)),
      (0.8, const Color(0xFFB57BFF)),
    ]) {
      final base = Offset(w * x, h * 0.9);
      final coral = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * u
        ..strokeCap = StrokeCap.round;
      c.drawLine(base, base + Offset(0, -8 * u), coral);
      c.drawLine(
        base + Offset(0, -4 * u),
        base + Offset(-3 * u, -8 * u),
        coral,
      );
      c.drawLine(base + Offset(0, -5 * u), base + Offset(3 * u, -9 * u), coral);
    }
  }

  void playa() {
    cielo(const [Color(0xFF5EC8F2), Color(0xFFBDEBFF)]);
    sol(Offset(w * 0.78, h * 0.15), 8 * u, const Color(0xFFFFD43B));
    nube(Offset(w * 0.25, h * 0.16), 20 * u);
    c.drawRect(
      Rect.fromLTWH(0, h * 0.48, w, h * 0.3),
      _p(const Color(0xFF2FA7D8)),
    );
    olas(0.5, const Color(0xFF47B8E3), crestas: 10, amplitud: 0.8);
    olas(0.6, const Color(0xFF6CCBEB), crestas: 7, amplitud: 1, fase: 1);
    colina(0.74, 2, const Color(0xFFF7DFA4), fase: 2, ondas: 1);
    // Palmera.
    final tronco = Paint()
      ..color = const Color(0xFF9C6B3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6 * u
      ..strokeCap = StrokeCap.round;
    final base = Offset(w * 0.14, h * 0.9);
    final copa = Offset(w * 0.2, h * 0.48);
    c.drawPath(
      Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
          base.dx + 2 * u,
          (base.dy + copa.dy) / 2,
          copa.dx,
          copa.dy,
        ),
      tronco,
    );
    final hoja = Paint()
      ..color = const Color(0xFF3FA34D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * u
      ..strokeCap = StrokeCap.round;
    for (final a in [-2.6, -1.9, -1.2, -0.5, 0.2]) {
      final fin = copa + Offset(math.cos(a), math.sin(a) + 0.6) * 14 * u;
      c.drawPath(
        Path()
          ..moveTo(copa.dx, copa.dy)
          ..quadraticBezierTo(
            copa.dx + math.cos(a) * 9 * u,
            copa.dy + math.sin(a) * 9 * u - 3 * u,
            fin.dx,
            fin.dy,
          ),
        hoja,
      );
    }
    c.drawCircle(
      copa + Offset(-1 * u, 2 * u),
      1.6 * u,
      _p(const Color(0xFF7A5230)),
    );
    // Sombrilla y pelota.
    final palo = Offset(w * 0.75, h * 0.92);
    c.drawLine(
      palo,
      palo + Offset(0, -16 * u),
      Paint()
        ..color = const Color(0xFF6B7280)
        ..strokeWidth = 0.8 * u,
    );
    final arco = Rect.fromCenter(
      center: palo + Offset(0, -16 * u),
      width: 22 * u,
      height: 12 * u,
    );
    for (var i = 0; i < 4; i++) {
      c.drawArc(
        arco,
        math.pi + i * math.pi / 4,
        math.pi / 4,
        true,
        _p(i.isEven ? const Color(0xFFFF5A5F) : const Color(0xFFFFFFFF)),
      );
    }
    c.drawCircle(Offset(w * 0.55, h * 0.9), 3 * u, _p(const Color(0xFFFFD43B)));
    c.drawArc(
      Rect.fromCircle(center: Offset(w * 0.55, h * 0.9), radius: 3 * u),
      -1,
      2,
      true,
      _p(const Color(0xFF3B82F6)),
    );
  }

  void desierto() {
    cielo(const [Color(0xFFFF9A5A), Color(0xFFFFE1A8)]);
    sol(
      Offset(w * 0.5, h * 0.3),
      12 * u,
      const Color(0xFFFFF1B8),
      rayos: false,
    );
    colina(0.55, 4, const Color(0xFFE8A85F), fase: 0.3, ondas: 1.3);
    colina(0.68, 5, const Color(0xFFF2C27E), fase: 2.4, ondas: 1.1);
    colina(0.84, 3, const Color(0xFFF8D79B), fase: 1, ondas: 1.5);
    void cactus(double x, double base, double alto) {
      final p = _p(const Color(0xFF3E9A55));
      final a = alto * 0.2;
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - a / 2, base - alto, a, alto),
          Radius.circular(a / 2),
        ),
        p,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - a * 2, base - alto * 0.75, a * 0.8, alto * 0.35),
          Radius.circular(a / 2),
        ),
        p,
      );
      c.drawRect(
        Rect.fromLTWH(x - a * 2, base - alto * 0.45, a * 1.6, a * 0.7),
        p,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + a * 1.2, base - alto * 0.85, a * 0.8, alto * 0.4),
          Radius.circular(a / 2),
        ),
        p,
      );
      c.drawRect(
        Rect.fromLTWH(x + a * 0.4, base - alto * 0.5, a * 1.6, a * 0.7),
        p,
      );
      c.drawCircle(
        Offset(x, base - alto),
        a * 0.35,
        _p(const Color(0xFFFF6B9A)),
      );
    }

    cactus(w * 0.2, h * 0.9, 26 * u);
    cactus(w * 0.82, h * 0.8, 16 * u);
  }

  void polar() {
    cielo(const [Color(0xFF8FD3F4), Color(0xFFE8F7FF)]);
    // Aurora suave.
    for (var i = 0; i < 3; i++) {
      final path = Path()..moveTo(0, h * (0.12 + i * 0.05));
      for (var x = 0.0; x <= w; x += w / 20) {
        path.lineTo(
          x,
          h * (0.12 + i * 0.05) + math.sin(x / w * math.pi * 2 + i) * 4 * u,
        );
      }
      c.drawPath(
        path,
        Paint()
          ..color = [
            const Color(0x5532E0A0),
            const Color(0x4498F5E1),
            const Color(0x33B57BFF),
          ][i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4 * u,
      );
    }
    void iceberg(double x, double base, double ancho, double alto) {
      c.drawPath(
        Path()
          ..moveTo(x - ancho / 2, base)
          ..lineTo(x - ancho * 0.2, base - alto)
          ..lineTo(x + ancho * 0.1, base - alto * 0.7)
          ..lineTo(x + ancho * 0.25, base - alto * 0.9)
          ..lineTo(x + ancho / 2, base)
          ..close(),
        _p(const Color(0xFFFFFFFF)),
      );
      c.drawPath(
        Path()
          ..moveTo(x + ancho * 0.1, base - alto * 0.7)
          ..lineTo(x + ancho * 0.25, base - alto * 0.9)
          ..lineTo(x + ancho / 2, base)
          ..lineTo(x + ancho * 0.05, base)
          ..close(),
        _p(const Color(0xFFCDE8F6)),
      );
    }

    c.drawRect(
      Rect.fromLTWH(0, h * 0.6, w, h * 0.4),
      _p(const Color(0xFF4AA3D8)),
    );
    iceberg(w * 0.25, h * 0.62, 30 * u, 22 * u);
    iceberg(w * 0.78, h * 0.62, 22 * u, 14 * u);
    colina(0.78, 3, const Color(0xFFF4FBFF), fase: 1.5, ondas: 1.4);
    final azar = math.Random(9);
    for (var i = 0; i < 30; i++) {
      c.drawCircle(
        Offset(azar.nextDouble() * w, azar.nextDouble() * h),
        (0.4 + azar.nextDouble() * 0.6) * u,
        _p(const Color(0xDDFFFFFF)),
      );
    }
  }

  void montana() {
    cielo(const [Color(0xFF6EC1F0), Color(0xFFDDF2FF)]);
    nube(Offset(w * 0.75, h * 0.12), 22 * u);
    void monte(double x, double ancho, double alto, Color color) {
      final base = h * 0.62;
      final cima = Offset(x, base - alto);
      c.drawPath(
        Path()
          ..moveTo(x - ancho / 2, base)
          ..lineTo(cima.dx, cima.dy)
          ..lineTo(x + ancho / 2, base)
          ..close(),
        _p(color),
      );
      final nieve = alto * 0.28;
      c.drawPath(
        Path()
          ..moveTo(cima.dx, cima.dy)
          ..lineTo(cima.dx - ancho / 2 * nieve / alto, cima.dy + nieve)
          ..lineTo(cima.dx - ancho * 0.05, cima.dy + nieve * 0.75)
          ..lineTo(cima.dx + ancho * 0.03, cima.dy + nieve)
          ..lineTo(cima.dx + ancho / 2 * nieve / alto, cima.dy + nieve)
          ..close(),
        _p(const Color(0xFFFFFFFF)),
      );
    }

    monte(w * 0.25, w * 0.8, h * 0.42, const Color(0xFF7C8DB5));
    monte(w * 0.7, w * 0.9, h * 0.5, const Color(0xFF5F719E));
    c.drawRect(
      Rect.fromLTWH(0, h * 0.62, w, h * 0.2),
      _p(const Color(0xFF4FB3E0)),
    );
    // Reflejo en el lago.
    for (var i = 0; i < 6; i++) {
      c.drawLine(
        Offset(w * (0.1 + i * 0.15), h * (0.66 + (i % 3) * 0.04)),
        Offset(w * (0.18 + i * 0.15), h * (0.66 + (i % 3) * 0.04)),
        Paint()
          ..color = const Color(0x66FFFFFF)
          ..strokeWidth = 0.6 * u,
      );
    }
    colina(0.84, 3, const Color(0xFF6BBF59), fase: 0.8);
    for (final x in [0.08, 0.2, 0.88]) {
      pino(w * x, h * 0.98, 22 * u, const Color(0xFF2F6B3A));
    }
  }

  void otono() {
    cielo(const [Color(0xFFFFC98B), Color(0xFFFFF0D9)]);
    sol(
      Offset(w * 0.18, h * 0.16),
      8 * u,
      const Color(0xFFFFE08A),
      rayos: false,
    );
    colina(0.62, 5, const Color(0xFFE4B36A), fase: 0.4);
    arbol(w * 0.3, h * 0.72, 32 * u, const Color(0xFFE8743B));
    arbol(w * 0.72, h * 0.74, 28 * u, const Color(0xFFD94B2B));
    arbol(w * 0.92, h * 0.7, 22 * u, const Color(0xFFF2A93B));
    colina(0.8, 3, const Color(0xFFC98B45), fase: 2);
    final azar = math.Random(21);
    final colores = [
      const Color(0xFFE8743B),
      const Color(0xFFF2A93B),
      const Color(0xFFD94B2B),
    ];
    for (var i = 0; i < 22; i++) {
      final p = Offset(azar.nextDouble() * w, azar.nextDouble() * h);
      c.save();
      c.translate(p.dx, p.dy);
      c.rotate(azar.nextDouble() * math.pi);
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 2.6 * u, height: 1.4 * u),
        _p(colores[i % 3]),
      );
      c.restore();
    }
  }

  void granja() {
    cielo(const [Color(0xFF8AD0F6), Color(0xFFE3F5FF)]);
    sol(Offset(w * 0.85, h * 0.13), 7 * u, const Color(0xFFFFD43B));
    nube(Offset(w * 0.3, h * 0.13), 22 * u);
    colina(0.6, 5, const Color(0xFFA7D86E), fase: 1.4);
    // Granero.
    final x = w * 0.62, base = h * 0.7, ancho = 26 * u, alto = 18 * u;
    c.drawRect(
      Rect.fromLTWH(x - ancho / 2, base - alto, ancho, alto),
      _p(const Color(0xFFD9483B)),
    );
    c.drawPath(
      Path()
        ..moveTo(x - ancho * 0.6, base - alto)
        ..lineTo(x, base - alto * 1.6)
        ..lineTo(x + ancho * 0.6, base - alto)
        ..close(),
      _p(const Color(0xFF8E2C24)),
    );
    final blanco = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * u;
    final puerta = Rect.fromLTWH(
      x - ancho * 0.2,
      base - alto * 0.6,
      ancho * 0.4,
      alto * 0.6,
    );
    c.drawRect(puerta, _p(const Color(0xFF9C3329)));
    c.drawRect(puerta, blanco);
    c.drawLine(puerta.topLeft, puerta.bottomRight, blanco);
    c.drawLine(puerta.topRight, puerta.bottomLeft, blanco);
    arbol(w * 0.2, h * 0.72, 26 * u, const Color(0xFF4E9F3D));
    colina(0.8, 2, const Color(0xFF8BC85A), fase: 0.2, ondas: 0.8);
    // Valla.
    final valla = _p(const Color(0xFFF5E6C8));
    for (var i = 0.0; i < w; i += 5 * u) {
      c.drawRect(Rect.fromLTWH(i, h * 0.82, 1.4 * u, 7 * u), valla);
    }
    c.drawRect(Rect.fromLTWH(0, h * 0.84, w, u), valla);
    c.drawRect(Rect.fromLTWH(0, h * 0.87, w, u), valla);
  }

  void jardin() {
    cielo(const [Color(0xFFFFC2E0), Color(0xFFFFF4FA)]);
    nube(Offset(w * 0.72, h * 0.14), 20 * u, color: const Color(0xFFFFFFFF));
    colina(0.66, 3, const Color(0xFF8FD27A), fase: 0.9);
    final azar = math.Random(13);
    final colores = [
      const Color(0xFFFF6B9A),
      const Color(0xFFFFB020),
      const Color(0xFFB57BFF),
      const Color(0xFFFF5A5F),
      const Color(0xFF4FC3F7),
    ];
    for (var fila = 0; fila < 3; fila++) {
      final y = h * (0.7 + fila * 0.1);
      final r = (1.8 + fila * 0.6) * u;
      for (
        var x = r * 2 + azar.nextDouble() * r * 3;
        x < w;
        x += r * 5 + azar.nextDouble() * r * 2
      ) {
        flor(Offset(x, y), r, colores[azar.nextInt(colores.length)]);
      }
    }
    mariposa(Offset(w * 0.3, h * 0.35), 3 * u, const Color(0xFFFF9F40));
    mariposa(Offset(w * 0.68, h * 0.45), 2.4 * u, const Color(0xFF7C5CFF));
    mariposa(Offset(w * 0.5, h * 0.22), 2 * u, const Color(0xFF4FC3F7));
  }

  void noche() {
    cielo(const [Color(0xFF1B2559), Color(0xFF4B3F8F)]);
    estrellas(70, 0.65);
    final luna = Offset(w * 0.78, h * 0.16);
    c.drawCircle(luna, 12 * u, _p(const Color(0x22FFF6D5)));
    c.drawCircle(luna, 7 * u, _p(const Color(0xFFFFF1B8)));
    c.drawCircle(
      luna + Offset(2.6 * u, -1.4 * u),
      6 * u,
      _p(const Color(0xFF243068)),
    );
    colina(0.66, 6, const Color(0xFF2E3A73), fase: 0.6);
    for (final x in [0.1, 0.22, 0.85]) {
      pino(w * x, h * 0.78, 24 * u, const Color(0xFF1C2A55));
    }
    colina(0.82, 3, const Color(0xFF1F2A5A), fase: 2);
    final azar = math.Random(17);
    for (var i = 0; i < 16; i++) {
      final p = Offset(
        azar.nextDouble() * w,
        h * (0.55 + azar.nextDouble() * 0.4),
      );
      c.drawCircle(p, 1.8 * u, _p(const Color(0x33FFF59D)));
      c.drawCircle(p, 0.6 * u, _p(const Color(0xFFFFF59D)));
    }
  }
}
