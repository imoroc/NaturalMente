import 'dart:math' as math;

import 'package:flutter/material.dart';

// Ilustraciones de «¿Huevo o barriga?»: los dos destinos de Fácil y cada fase
// de los ciclos de la rana y la mariposa. Se pintan sobre un lienzo de 100×100.

class DibujoNacimiento extends StatelessWidget {
  const DibujoNacimiento({required this.id, this.tamano = 56, super.key});

  final String id;
  final double tamano;

  static const ids = {
    'huevo',
    'barriga',
    'huevos-rana',
    'renacuajo',
    'patas',
    'ranita',
    'rana',
    'huevo-mariposa',
    'oruga',
    'crisalida',
    'mariposa',
  };

  @override
  Widget build(BuildContext context) {
    final (fondo, borde) = coloresNacimiento(id);
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano * .28),
        border: Border.all(color: borde.withValues(alpha: .65), width: 2),
      ),
      padding: EdgeInsets.all(tamano * .07),
      child: CustomPaint(painter: _PintorNacimiento(id)),
    );
  }
}

(Color, Color) coloresNacimiento(String id) => switch (id) {
  'huevo' => (const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
  'barriga' => (const Color(0xFFFCE7F3), const Color(0xFFEC4899)),
  'huevos-rana' ||
  'renacuajo' ||
  'patas' => (const Color(0xFFE0F2FE), const Color(0xFF0EA5E9)),
  'ranita' || 'rana' => (const Color(0xFFDCFCE7), const Color(0xFF22C55E)),
  'huevo-mariposa' ||
  'oruga' => (const Color(0xFFECFCCB), const Color(0xFF65A30D)),
  'crisalida' => (const Color(0xFFF5F5F4), const Color(0xFFA8A29E)),
  'mariposa' => (const Color(0xFFFFEDD5), const Color(0xFFF97316)),
  _ => (const Color(0xFFF1F5F9), const Color(0xFF94A3B8)),
};

class _PintorNacimiento extends CustomPainter {
  const _PintorNacimiento(this.id);

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final lado = math.min(size.width, size.height);
    canvas.translate((size.width - lado) / 2, (size.height - lado) / 2);
    canvas.scale(lado / 100);
    switch (id) {
      case 'huevo':
        _nido(canvas);
      case 'barriga':
        _barriga(canvas);
      case 'huevos-rana':
        _puesta(canvas);
      case 'renacuajo':
        _renacuajo(canvas, patas: false);
      case 'patas':
        _renacuajo(canvas, patas: true);
      case 'ranita':
        _rana(canvas, cola: true);
      case 'rana':
        _rana(canvas, cola: false);
      case 'huevo-mariposa':
        _hojaConHuevos(canvas);
      case 'oruga':
        _oruga(canvas);
      case 'crisalida':
        _crisalida(canvas);
      case 'mariposa':
        _mariposa(canvas);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorNacimiento oldDelegate) =>
      oldDelegate.id != id;
}

Paint _relleno(Color color) => Paint()..color = color;

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

void _ovalo(
  Canvas canvas,
  Offset centro,
  double ancho,
  double alto,
  Paint pintura, {
  double giro = 0,
}) {
  canvas.save();
  canvas.translate(centro.dx, centro.dy);
  canvas.rotate(giro);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: ancho, height: alto),
    pintura,
  );
  canvas.restore();
}

void _ojo(Canvas canvas, Offset centro, double radio) {
  canvas.drawCircle(centro, radio, _relleno(Colors.white));
  canvas.drawCircle(
    centro + Offset(radio * .2, radio * .1),
    radio * .52,
    _relleno(const Color(0xFF1E293B)),
  );
  canvas.drawCircle(
    centro + Offset(radio * .38, -radio * .12),
    radio * .18,
    _relleno(Colors.white),
  );
}

void _nido(Canvas canvas) {
  const paja = Color(0xFFB45309);
  const pajaOscura = Color(0xFF78350F);
  // Fondo del nido.
  final cuenco = Path()
    ..moveTo(10, 58)
    ..quadraticBezierTo(50, 104, 90, 58)
    ..close();
  canvas.drawPath(cuenco, _relleno(const Color(0xFF92400E)));
  // Huevo entero.
  _ovalo(
    canvas,
    const Offset(37, 52),
    25,
    32,
    _relleno(const Color(0xFFFFFBEB)),
  );
  _ovalo(
    canvas,
    const Offset(37, 52),
    25,
    32,
    _trazo(const Color(0xFFD6A65A), 2),
  );
  _ovalo(canvas, const Offset(32, 44), 6, 9, _relleno(const Color(0x66FFFFFF)));
  // Huevo abierto con el polluelo asomando.
  _ovalo(
    canvas,
    const Offset(63, 56),
    26,
    28,
    _relleno(const Color(0xFFFFFBEB)),
  );
  canvas.drawCircle(
    const Offset(63, 36),
    11,
    _relleno(const Color(0xFFFDE047)),
  );
  canvas.drawCircle(
    const Offset(63, 36),
    11,
    _trazo(const Color(0xFFEAB308), 1.6),
  );
  _ojo(canvas, const Offset(59, 34), 2.6);
  _ojo(canvas, const Offset(67, 34), 2.6);
  final pico = Path()
    ..moveTo(60, 39)
    ..lineTo(66, 39)
    ..lineTo(63, 44)
    ..close();
  canvas.drawPath(pico, _relleno(const Color(0xFFF97316)));
  final cascara = Path()
    ..moveTo(50, 50)
    ..lineTo(55, 45)
    ..lineTo(59, 50)
    ..lineTo(63, 44)
    ..lineTo(67, 50)
    ..lineTo(71, 45)
    ..lineTo(76, 50);
  canvas.drawPath(
    Path.from(cascara)
      ..lineTo(76, 64)
      ..lineTo(50, 64)
      ..close(),
    _relleno(const Color(0xFFFFFBEB)),
  );
  canvas.drawPath(cascara, _trazo(const Color(0xFFD6A65A), 2));
  // Borde delantero de ramitas.
  _ovalo(canvas, const Offset(50, 66), 86, 22, _relleno(paja));
  for (var i = 0; i < 7; i++) {
    final x = 14.0 + i * 12;
    canvas.drawLine(
      Offset(x, 60 + (i.isEven ? 0 : 3)),
      Offset(x + 12, 72 - (i.isEven ? 2 : 0)),
      _trazo(pajaOscura, 2),
    );
  }
  _ovalo(canvas, const Offset(50, 66), 86, 22, _trazo(pajaOscura, 2));
}

void _barriga(Canvas canvas) {
  const rosa = Color(0xFFDB2777);
  // Vientre de la madre con la cría acurrucada dentro.
  canvas.drawCircle(
    const Offset(50, 54),
    38,
    _relleno(const Color(0xFFFBCFE8)),
  );
  canvas.drawCircle(const Offset(50, 54), 38, _trazo(rosa, 3));
  canvas.drawCircle(
    const Offset(50, 56),
    27,
    _relleno(const Color(0xFFFDF2F8)),
  );
  // Cordón que une a la cría con su madre.
  final cordon = Path()
    ..moveTo(58, 62)
    ..quadraticBezierTo(72, 70, 74, 52);
  canvas.drawPath(cordon, _trazo(const Color(0xFFF472B6), 3));
  // Cuerpo y cabeza de la cría.
  _ovalo(
    canvas,
    const Offset(54, 62),
    28,
    20,
    _relleno(const Color(0xFFFED7AA)),
    giro: -.5,
  );
  canvas.drawCircle(
    const Offset(42, 47),
    11,
    _relleno(const Color(0xFFFED7AA)),
  );
  canvas.drawCircle(
    const Offset(42, 47),
    11,
    _trazo(const Color(0xFFF59E0B), 1.5),
  );
  final ojoCerrado = Path()
    ..moveTo(37, 46)
    ..quadraticBezierTo(40, 49, 43, 46);
  canvas.drawPath(ojoCerrado, _trazo(const Color(0xFF7C2D12), 1.6));
  canvas.drawCircle(
    const Offset(38, 51),
    2.3,
    _relleno(const Color(0xFFFDA4AF)),
  );
  // Corazón: la madre la cuida mientras crece.
  final corazon = Path()
    ..moveTo(78, 30)
    ..cubicTo(70, 22, 74, 14, 78, 19)
    ..cubicTo(82, 14, 86, 22, 78, 30)
    ..close();
  canvas.drawPath(corazon, _relleno(const Color(0xFFF43F5E)));
}

void _agua(Canvas canvas) {
  for (final (x, y, r) in const [
    (18.0, 22.0, 3.0),
    (84.0, 30.0, 2.4),
    (80.0, 80.0, 3.2),
  ]) {
    canvas.drawCircle(Offset(x, y), r, _trazo(const Color(0xFF7DD3FC), 1.4));
  }
}

void _puesta(Canvas canvas) {
  _agua(canvas);
  const centros = [
    Offset(36, 34),
    Offset(54, 30),
    Offset(70, 40),
    Offset(28, 52),
    Offset(46, 50),
    Offset(64, 58),
    Offset(38, 70),
    Offset(56, 74),
    Offset(22, 70),
  ];
  for (final c in centros) {
    canvas.drawCircle(c, 10, _relleno(const Color(0x99BFDBFE)));
    canvas.drawCircle(c, 10, _trazo(const Color(0xFF60A5FA), 1.4));
  }
  for (final c in centros) {
    canvas.drawCircle(c, 3.6, _relleno(const Color(0xFF1E293B)));
    canvas.drawCircle(c + const Offset(-1, -1), 1, _relleno(Colors.white));
  }
}

void _renacuajo(Canvas canvas, {required bool patas}) {
  _agua(canvas);
  const piel = Color(0xFF4D7C0F);
  final colaLarga = !patas;
  final finCola = colaLarga ? 94.0 : 84.0;
  final cola = Path()
    ..moveTo(52, 42)
    ..quadraticBezierTo(70, 32, finCola, 44)
    ..quadraticBezierTo(72, 50, finCola - 4, 60)
    ..quadraticBezierTo(70, 62, 52, 58)
    ..close();
  canvas.drawPath(cola, _relleno(const Color(0xFF84CC16)));
  canvas.drawPath(cola, _trazo(piel, 1.6));
  if (patas) {
    // Primero salen las patas traseras y después las delanteras.
    final trasera = Path()
      ..moveTo(52, 60)
      ..lineTo(58, 72)
      ..lineTo(66, 74);
    canvas.drawPath(trasera, _trazo(piel, 4));
    final otraTrasera = Path()
      ..moveTo(46, 62)
      ..lineTo(48, 76)
      ..lineTo(56, 80);
    canvas.drawPath(otraTrasera, _trazo(piel, 4));
    final delantera = Path()
      ..moveTo(30, 60)
      ..lineTo(26, 70)
      ..lineTo(21, 72);
    canvas.drawPath(delantera, _trazo(piel, 3));
  }
  _ovalo(
    canvas,
    const Offset(38, 50),
    38,
    30,
    _relleno(const Color(0xFF65A30D)),
  );
  _ovalo(canvas, const Offset(38, 50), 38, 30, _trazo(piel, 1.8));
  _ovalo(
    canvas,
    const Offset(36, 56),
    20,
    10,
    _relleno(const Color(0x55FEF08A)),
  );
  _ojo(canvas, const Offset(28, 44), 4.4);
  final boca = Path()
    ..moveTo(20, 54)
    ..quadraticBezierTo(23, 57, 26, 55);
  canvas.drawPath(boca, _trazo(const Color(0xFF365314), 1.5));
}

void _rana(Canvas canvas, {required bool cola}) {
  const piel = Color(0xFF16A34A);
  const borde = Color(0xFF166534);
  final escala = cola ? .8 : 1.0;
  canvas.save();
  canvas.translate(50, 56);
  canvas.scale(escala);
  canvas.translate(-50, -56);
  if (cola) {
    // Resto de la cola que el cuerpo todavía está reabsorbiendo.
    final resto = Path()
      ..moveTo(66, 56)
      ..quadraticBezierTo(92, 50, 106, 60)
      ..quadraticBezierTo(90, 74, 68, 72)
      ..close();
    canvas.drawPath(resto, _relleno(const Color(0xFF84CC16)));
    canvas.drawPath(resto, _trazo(borde, 1.4));
  }
  // Patas traseras dobladas.
  _ovalo(canvas, const Offset(24, 72), 30, 16, _relleno(piel), giro: .35);
  _ovalo(canvas, const Offset(76, 72), 30, 16, _relleno(piel), giro: -.35);
  _ovalo(
    canvas,
    const Offset(14, 80),
    16,
    7,
    _relleno(const Color(0xFF22C55E)),
  );
  _ovalo(
    canvas,
    const Offset(86, 80),
    16,
    7,
    _relleno(const Color(0xFF22C55E)),
  );
  // Cuerpo y barriga.
  _ovalo(
    canvas,
    const Offset(50, 60),
    58,
    40,
    _relleno(const Color(0xFF4ADE80)),
  );
  _ovalo(canvas, const Offset(50, 60), 58, 40, _trazo(borde, 2));
  _ovalo(
    canvas,
    const Offset(50, 67),
    34,
    20,
    _relleno(const Color(0xFFFEF08A)),
  );
  // Patas delanteras.
  _ovalo(canvas, const Offset(38, 80), 12, 7, _relleno(piel));
  _ovalo(canvas, const Offset(62, 80), 12, 7, _relleno(piel));
  // Ojos saltones.
  for (final x in const [36.0, 64.0]) {
    canvas.drawCircle(Offset(x, 40), 10, _relleno(const Color(0xFF4ADE80)));
    canvas.drawCircle(Offset(x, 40), 10, _trazo(borde, 1.8));
    _ojo(canvas, Offset(x, 40), 6);
  }
  final boca = Path()
    ..moveTo(38, 56)
    ..quadraticBezierTo(50, 64, 62, 56);
  canvas.drawPath(boca, _trazo(borde, 2));
  if (!cola) {
    for (final (x, y) in const [(30.0, 54.0), (70.0, 52.0), (66.0, 62.0)]) {
      canvas.drawCircle(Offset(x, y), 2.6, _relleno(const Color(0xFF15803D)));
    }
  }
  canvas.restore();
}

void _hoja(Canvas canvas) {
  final hoja = Path()
    ..moveTo(10, 84)
    ..quadraticBezierTo(14, 22, 90, 14)
    ..quadraticBezierTo(84, 80, 10, 84)
    ..close();
  canvas.drawPath(hoja, _relleno(const Color(0xFF86EFAC)));
  canvas.drawPath(hoja, _trazo(const Color(0xFF16A34A), 2));
  canvas.drawLine(
    const Offset(12, 82),
    const Offset(84, 20),
    _trazo(const Color(0xFF16A34A), 1.8),
  );
  for (final (x, y) in const [(30.0, 66.0), (46.0, 52.0), (62.0, 38.0)]) {
    canvas.drawLine(
      Offset(x, y),
      Offset(x + 2, y - 16),
      _trazo(const Color(0xFF22C55E), 1.2),
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x + 16, y + 2),
      _trazo(const Color(0xFF22C55E), 1.2),
    );
  }
}

void _hojaConHuevos(Canvas canvas) {
  _hoja(canvas);
  for (final c in const [
    Offset(46, 44),
    Offset(56, 50),
    Offset(44, 56),
    Offset(55, 62),
  ]) {
    _ovalo(canvas, c, 8, 10, _relleno(const Color(0xFFFEF3C7)));
    _ovalo(canvas, c, 8, 10, _trazo(const Color(0xFFCA8A04), 1.4));
    canvas.drawCircle(c + const Offset(-1.4, -2), 1.2, _relleno(Colors.white));
  }
}

void _oruga(Canvas canvas) {
  // Hoja mordisqueada sobre la que avanza.
  final hoja = Path()
    ..moveTo(4, 92)
    ..lineTo(4, 78)
    ..quadraticBezierTo(50, 68, 96, 78)
    ..lineTo(96, 92)
    ..close();
  canvas.drawPath(hoja, _relleno(const Color(0xFF86EFAC)));
  for (final x in const [22.0, 34.0]) {
    canvas.drawCircle(Offset(x, 76), 5, _relleno(const Color(0xFFECFCCB)));
  }
  for (var i = 0; i < 6; i++) {
    final x = 16.0 + i * 11;
    final y = 58 - 7 * math.sin(i * .9);
    canvas.drawLine(
      Offset(x, y + 8),
      Offset(x, y + 14),
      _trazo(const Color(0xFF365314), 2.2),
    );
    canvas.drawCircle(
      Offset(x, y),
      10,
      _relleno(i.isEven ? const Color(0xFF84CC16) : const Color(0xFF65A30D)),
    );
    canvas.drawCircle(Offset(x, y), 10, _trazo(const Color(0xFF3F6212), 1.4));
    canvas.drawCircle(
      Offset(x - 2, y - 4),
      1.8,
      _relleno(const Color(0xFFFDE047)),
    );
  }
  const cabeza = Offset(84, 46);
  canvas.drawLine(
    cabeza + const Offset(-4, -9),
    const Offset(76, 26),
    _trazo(const Color(0xFF3F6212), 2),
  );
  canvas.drawLine(
    cabeza + const Offset(4, -9),
    const Offset(92, 26),
    _trazo(const Color(0xFF3F6212), 2),
  );
  canvas.drawCircle(
    const Offset(76, 26),
    2.4,
    _relleno(const Color(0xFF3F6212)),
  );
  canvas.drawCircle(
    const Offset(92, 26),
    2.4,
    _relleno(const Color(0xFF3F6212)),
  );
  canvas.drawCircle(cabeza, 12, _relleno(const Color(0xFF4D7C0F)));
  canvas.drawCircle(cabeza, 12, _trazo(const Color(0xFF365314), 1.6));
  _ojo(canvas, cabeza + const Offset(3, -2), 3.4);
  final sonrisa = Path()
    ..moveTo(80, 51)
    ..quadraticBezierTo(85, 55, 90, 50);
  canvas.drawPath(sonrisa, _trazo(const Color(0xFF1A2E05), 1.6));
}

void _crisalida(Canvas canvas) {
  // Rama y el hilo de seda del que cuelga.
  canvas.drawLine(
    const Offset(8, 12),
    const Offset(92, 12),
    _trazo(const Color(0xFF92400E), 5),
  );
  canvas.drawLine(
    const Offset(70, 12),
    const Offset(80, 4),
    _trazo(const Color(0xFF92400E), 3),
  );
  canvas.drawLine(
    const Offset(50, 14),
    const Offset(50, 22),
    _trazo(const Color(0xFFA8A29E), 1.6),
  );
  final capullo = Path()
    ..moveTo(50, 22)
    ..cubicTo(72, 30, 68, 74, 50, 92)
    ..cubicTo(32, 74, 28, 30, 50, 22)
    ..close();
  canvas.drawPath(
    capullo,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBEF264), Color(0xFF4D7C0F)],
      ).createShader(const Rect.fromLTWH(30, 22, 40, 70)),
  );
  canvas.drawPath(capullo, _trazo(const Color(0xFF3F6212), 2));
  for (final y in const [44.0, 58.0, 72.0]) {
    final ancho = 16 - (y - 44) * .18;
    final segmento = Path()
      ..moveTo(50 - ancho, y)
      ..quadraticBezierTo(50, y + 4, 50 + ancho, y);
    canvas.drawPath(segmento, _trazo(const Color(0xFF365314), 1.2));
  }
  for (final x in const [42.0, 47.0, 53.0, 58.0]) {
    canvas.drawCircle(Offset(x, 36), 1.6, _relleno(const Color(0xFFFACC15)));
  }
}

void _mariposa(Canvas canvas) {
  const naranja = Color(0xFFF97316);
  const negro = Color(0xFF1E293B);
  // Alas de arriba y de abajo, a cada lado del cuerpo.
  for (final lado in const [-1.0, 1.0]) {
    _ovalo(
      canvas,
      Offset(50 + lado * 21, 36),
      40,
      32,
      _relleno(naranja),
      giro: lado * -.5,
    );
    _ovalo(
      canvas,
      Offset(50 + lado * 21, 36),
      40,
      32,
      _trazo(negro, 2.4),
      giro: lado * -.5,
    );
    _ovalo(
      canvas,
      Offset(50 + lado * 17, 64),
      26,
      24,
      _relleno(const Color(0xFFFB923C)),
      giro: lado * .5,
    );
    _ovalo(
      canvas,
      Offset(50 + lado * 17, 64),
      26,
      24,
      _trazo(negro, 2.4),
      giro: lado * .5,
    );
    canvas.drawCircle(
      Offset(50 + lado * 25, 32),
      5,
      _relleno(const Color(0xFFFEF3C7)),
    );
    canvas.drawCircle(Offset(50 + lado * 34, 26), 2.6, _relleno(Colors.white));
    canvas.drawCircle(
      Offset(50 + lado * 19, 66),
      3.4,
      _relleno(const Color(0xFFFEF3C7)),
    );
  }
  // Cuerpo con tres partes y antenas.
  _ovalo(canvas, const Offset(50, 54), 8, 42, _relleno(negro));
  canvas.drawCircle(const Offset(50, 30), 5.4, _relleno(negro));
  for (final lado in const [-1.0, 1.0]) {
    final antena = Path()
      ..moveTo(50 + lado * 2, 26)
      ..quadraticBezierTo(50 + lado * 6, 12, 50 + lado * 14, 8);
    canvas.drawPath(antena, _trazo(negro, 1.8));
    canvas.drawCircle(Offset(50 + lado * 14, 8), 2.6, _relleno(negro));
  }
}
