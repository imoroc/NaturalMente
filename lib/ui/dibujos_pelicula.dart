import 'dart:math' as math;

import 'package:flutter/material.dart';

// Dibujos de «La película de la planta». Cada fotograma es una planta en un
// momento de su vida. Todo se pinta sobre un lienzo de 100 × 100: el cielo
// arriba y la tierra a partir de y = 72.

const _suelo = 72.0;

const _cielo = Color(0xFFE0F2FE);
const _cieloBajo = Color(0xFFF0FDF4);
const _tierra = Color(0xFF8B5A2B);
const _tierraOscura = Color(0xFF6B4423);
const _verde = Color(0xFF22A05A);
const _verdeOscuro = Color(0xFF157043);
const _tronco = Color(0xFF7C4A21);
const _raiz = Color(0xFFF5F0E1);

/// Un fotograma: la planta [planta] en el momento [fase].
class DibujoPelicula extends StatelessWidget {
  const DibujoPelicula({
    required this.planta,
    required this.fase,
    this.tamano = 64,
    super.key,
  });

  final String planta;
  final String fase;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(
      painter: PintorPelicula(planta: planta, fase: fase),
    ),
  );
}

class PintorPelicula extends CustomPainter {
  const PintorPelicula({required this.planta, required this.fase});

  final String planta;
  final String fase;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 100, 100));
    final primerPlano = const {
      'abeja',
      'viento-polen',
      'viento-semillas',
      'pajaro',
      'ardilla',
    }.contains(fase);
    _fondo(canvas, conSuelo: !primerPlano || fase == 'ardilla');
    switch (fase) {
      case 'semilla':
        _semilla(canvas, planta, const Offset(50, 84), 2.2);
      case 'germina':
        _germina(canvas, planta);
      case 'brote':
        _brote(canvas, planta);
      case 'planta':
        _planta(canvas, planta, 'planta');
      case 'flor':
        _planta(canvas, planta, 'flor');
      case 'fruto':
        _planta(canvas, planta, 'fruto');
      case 'abeja':
        _primerPlanoFlor(canvas, planta);
        _abeja(canvas, const Offset(70, 30));
        _polen(canvas, const [Offset(58, 40), Offset(62, 36), Offset(55, 35)]);
      case 'viento-polen':
        _primerPlanoFlor(canvas, planta);
        _viento(canvas);
        _polen(canvas, const [
          Offset(70, 30),
          Offset(78, 24),
          Offset(84, 36),
          Offset(90, 28),
          Offset(74, 42),
        ]);
      case 'viento-semillas':
        _viento(canvas);
        _semillasVolando(canvas, planta);
      case 'pajaro':
        _pajaro(canvas, planta);
      case 'ardilla':
        _ardilla(canvas, planta);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorPelicula old) =>
      old.planta != planta || old.fase != fase;
}

Paint _relleno(Color color) => Paint()..color = color;

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round;

void _fondo(Canvas canvas, {required bool conSuelo}) {
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 100, 100),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_cielo, _cieloBajo],
      ).createShader(const Rect.fromLTWH(0, 0, 100, 100)),
  );
  if (!conSuelo) return;
  canvas.drawRect(const Rect.fromLTWH(0, _suelo, 100, 28), _relleno(_tierra));
  final grano = _relleno(_tierraOscura);
  for (final p in const [
    Offset(12, 80),
    Offset(30, 92),
    Offset(70, 86),
    Offset(88, 95),
    Offset(20, 97),
    Offset(80, 77),
  ]) {
    canvas.drawCircle(p, 1.4, grano);
  }
  canvas.drawLine(
    const Offset(0, _suelo),
    const Offset(100, _suelo),
    _trazo(const Color(0xFF65A30D), 2),
  );
}

// --- Semillas ---

void _semilla(Canvas canvas, String planta, Offset c, double escala) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.scale(escala);
  switch (planta) {
    case 'judia':
      final judia = Path()
        ..moveTo(-6, 0)
        ..cubicTo(-6, -5, 0, -5, 1, -2)
        ..cubicTo(2, -5, 7, -4, 6, 0)
        ..cubicTo(6, 4, -6, 5, -6, 0);
      canvas.drawPath(judia, _relleno(const Color(0xFFF5EBDD)));
      canvas.drawPath(judia, _trazo(const Color(0xFFB89B72), .8));
    case 'girasol':
      final pipa = Path()
        ..moveTo(0, -6)
        ..quadraticBezierTo(4, -1, 0, 6)
        ..quadraticBezierTo(-4, -1, 0, -6);
      canvas.drawPath(pipa, _relleno(const Color(0xFF1F2937)));
      canvas.drawLine(
        const Offset(0, -5),
        const Offset(0, 5),
        _trazo(const Color(0xFFE5E7EB), .9),
      );
    case 'tomatera':
      canvas.drawOval(
        const Rect.fromLTWH(-3.5, -2.5, 7, 5),
        _relleno(const Color(0xFFFDE68A)),
      );
    case 'cerezo':
      canvas.drawOval(
        const Rect.fromLTWH(-4, -5, 8, 10),
        _relleno(const Color(0xFFE7D3B0)),
      );
      canvas.drawLine(
        const Offset(0, -5),
        const Offset(0, 5),
        _trazo(const Color(0xFFC2A577), .7),
      );
    case 'diente-leon':
      canvas.drawOval(
        const Rect.fromLTWH(-1.5, -3, 3, 6),
        _relleno(const Color(0xFF92400E)),
      );
    case 'avellano':
      _avellana(canvas, Offset.zero, 6);
  }
  canvas.restore();
}

void _avellana(Canvas canvas, Offset c, double r) {
  final cuerpo = Path()
    ..moveTo(c.dx, c.dy - r)
    ..cubicTo(c.dx + r, c.dy - r, c.dx + r, c.dy + r, c.dx, c.dy + r)
    ..cubicTo(c.dx - r, c.dy + r, c.dx - r, c.dy - r, c.dx, c.dy - r);
  canvas.drawPath(cuerpo, _relleno(const Color(0xFFA16207)));
  canvas.drawArc(
    Rect.fromCircle(center: c.translate(0, r * .35), radius: r * .75),
    .3,
    2.5,
    false,
    _trazo(const Color(0xFF713F12), r * .18),
  );
  canvas.drawCircle(
    c.translate(-r * .3, -r * .35),
    r * .2,
    _relleno(const Color(0x55FFFFFF)),
  );
}

void _germina(Canvas canvas, String planta) {
  final raiz = Path()
    ..moveTo(50, 86)
    ..cubicTo(48, 90, 52, 94, 49, 99);
  canvas.drawPath(raiz, _trazo(_raiz, 2));
  canvas.drawLine(
    const Offset(49.5, 93),
    const Offset(45, 96),
    _trazo(_raiz, 1),
  );
  canvas.drawLine(
    const Offset(50.5, 95),
    const Offset(55, 98),
    _trazo(_raiz, 1),
  );
  _semilla(canvas, planta, const Offset(50, 82), 1.8);
  // Un gancho verde que empieza a asomar.
  final gancho = Path()
    ..moveTo(51, 79)
    ..quadraticBezierTo(52, 75, 55, 76);
  canvas.drawPath(gancho, _trazo(const Color(0xFF84CC16), 1.6));
  _gotas(canvas);
}

void _gotas(Canvas canvas) {
  final agua = _relleno(const Color(0xFF60A5FA));
  for (final p in const [Offset(30, 60), Offset(70, 56), Offset(62, 64)]) {
    final gota = Path()
      ..moveTo(p.dx, p.dy - 4)
      ..quadraticBezierTo(p.dx + 3, p.dy, p.dx, p.dy + 2)
      ..quadraticBezierTo(p.dx - 3, p.dy, p.dx, p.dy - 4);
    canvas.drawPath(gota, agua);
  }
}

void _brote(Canvas canvas, String planta) {
  final raiz = Path()
    ..moveTo(50, _suelo + 2)
    ..cubicTo(48, 84, 53, 90, 50, 98);
  canvas.drawPath(raiz, _trazo(_raiz, 1.6));
  canvas.drawLine(
    const Offset(50, 86),
    const Offset(44, 92),
    _trazo(_raiz, .9),
  );
  final alto = esArbol(planta) ? 50.0 : 46.0;
  canvas.drawLine(
    const Offset(50, _suelo + 1),
    Offset(50, alto),
    _trazo(const Color(0xFF65A30D), 2.4),
  );
  _hoja(canvas, Offset(50, alto + 2), -.5, 11, const Color(0xFF84CC16));
  _hoja(
    canvas,
    Offset(50, alto + 2),
    math.pi + .5,
    11,
    const Color(0xFF84CC16),
  );
}

bool esArbol(String planta) => planta == 'cerezo' || planta == 'avellano';

/// Una hoja que sale de [base] con el ángulo [angulo] (0 apunta a la derecha).
void _hoja(
  Canvas canvas,
  Offset base,
  double angulo,
  double largo,
  Color color,
) {
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angulo);
  final hoja = Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(largo * .5, -largo * .42, largo, 0)
    ..quadraticBezierTo(largo * .5, largo * .42, 0, 0);
  canvas.drawPath(hoja, _relleno(color));
  canvas.drawLine(
    Offset.zero,
    Offset(largo * .85, 0),
    _trazo(Color.lerp(color, Colors.black, .25)!, .6),
  );
  canvas.restore();
}

// --- Plantas enteras ---

void _planta(Canvas canvas, String planta, String fase) {
  switch (planta) {
    case 'judia':
      _judia(canvas, fase);
    case 'girasol':
      _girasol(canvas, fase);
    case 'tomatera':
      _tomatera(canvas, fase);
    case 'cerezo':
      _arbol(canvas, fase, cerezo: true);
    case 'avellano':
      _arbol(canvas, fase, cerezo: false);
    case 'diente-leon':
      _dienteLeon(canvas, fase);
  }
}

void _tallo(Canvas canvas, List<Offset> puntos, double grosor) {
  final tallo = Path()..moveTo(puntos.first.dx, puntos.first.dy);
  for (var i = 1; i < puntos.length; i++) {
    tallo.lineTo(puntos[i].dx, puntos[i].dy);
  }
  canvas.drawPath(tallo, _trazo(_verdeOscuro, grosor));
}

void _judia(Canvas canvas, String fase) {
  // Un tutor de caña y la judía enrollada.
  canvas.drawLine(
    const Offset(56, _suelo + 2),
    const Offset(56, 8),
    _trazo(const Color(0xFFD6B680), 2),
  );
  final tallo = Path()..moveTo(52, _suelo);
  for (var y = _suelo; y > 12; y -= 10) {
    tallo.quadraticBezierTo(62, y - 3, 54, y - 6);
    tallo.quadraticBezierTo(48, y - 8, 54, y - 10);
  }
  canvas.drawPath(tallo, _trazo(_verdeOscuro, 1.8));
  const hojas = [
    (Offset(54, 62), math.pi + .4),
    (Offset(56, 52), -.4),
    (Offset(54, 42), math.pi + .3),
    (Offset(56, 32), -.3),
    (Offset(54, 22), math.pi + .5),
  ];
  for (final (p, a) in hojas) {
    _hoja(canvas, p, a, 15, _verde);
  }
  if (fase == 'flor') {
    for (final p in const [Offset(62, 47), Offset(47, 37), Offset(62, 27)]) {
      _florecilla(canvas, p, Colors.white, 3.2);
    }
  } else if (fase == 'fruto') {
    for (final p in const [Offset(62, 44), Offset(46, 34), Offset(62, 24)]) {
      _vaina(canvas, p);
    }
  }
}

void _vaina(Canvas canvas, Offset p) {
  final vaina = Path()
    ..moveTo(p.dx, p.dy)
    ..quadraticBezierTo(p.dx + 4, p.dy + 8, p.dx + 1, p.dy + 17)
    ..quadraticBezierTo(p.dx - 2, p.dy + 9, p.dx, p.dy);
  canvas.drawPath(vaina, _relleno(const Color(0xFF65A30D)));
  canvas.drawPath(vaina, _trazo(const Color(0xFF3F6212), .6));
  for (var i = 0; i < 3; i++) {
    canvas.drawCircle(
      Offset(p.dx + 1.5, p.dy + 4 + i * 4.2),
      1.2,
      _relleno(const Color(0xFFA3E635)),
    );
  }
}

void _florecilla(Canvas canvas, Offset c, Color color, double r) {
  for (var i = 0; i < 5; i++) {
    final a = i * 2 * math.pi / 5;
    canvas.drawCircle(
      c + Offset(math.cos(a), math.sin(a)) * r * .7,
      r * .6,
      _relleno(color),
    );
  }
  canvas.drawCircle(c, r * .45, _relleno(const Color(0xFFFACC15)));
}

void _girasol(Canvas canvas, String fase) {
  _tallo(canvas, const [Offset(50, _suelo), Offset(50, 26)], 3.4);
  for (final (p, a) in const [
    (Offset(50, 60), math.pi + .5),
    (Offset(50, 54), -.5),
    (Offset(50, 44), math.pi + .4),
    (Offset(50, 38), -.4),
  ]) {
    _hoja(canvas, p, a, 18, _verde);
  }
  const centro = Offset(50, 20);
  switch (fase) {
    case 'planta':
      canvas.drawCircle(centro, 5, _relleno(const Color(0xFF4D7C0F)));
      for (var i = 0; i < 6; i++) {
        _hoja(canvas, centro, -math.pi / 2 + (i - 2.5) * .45, 7, _verde);
      }
    case 'flor':
      _cabezaGirasol(canvas, centro, 15, petalos: true, madura: false);
    case 'fruto':
      _cabezaGirasol(canvas, centro, 15, petalos: false, madura: true);
  }
}

void _cabezaGirasol(
  Canvas canvas,
  Offset c,
  double r, {
  required bool petalos,
  required bool madura,
}) {
  if (petalos) {
    for (var i = 0; i < 16; i++) {
      final a = i * 2 * math.pi / 16;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromLTWH(r * .45, -r * .17, r * .7, r * .34),
        _relleno(const Color(0xFFFACC15)),
      );
      canvas.restore();
    }
  } else {
    for (var i = 0; i < 12; i++) {
      final a = i * 2 * math.pi / 12;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(a);
      canvas.drawOval(
        Rect.fromLTWH(r * .45, -r * .12, r * .35, r * .24),
        _relleno(const Color(0xFFCA8A04)),
      );
      canvas.restore();
    }
  }
  canvas.drawCircle(
    c,
    r * .55,
    _relleno(madura ? const Color(0xFF3F2A14) : const Color(0xFF78350F)),
  );
  if (madura) {
    final pipa = _relleno(const Color(0xFFE7E5E4));
    for (var i = 0; i < 14; i++) {
      final a = i * 2.4;
      final d = r * .1 + (i / 14) * r * .38;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * d, .8, pipa);
    }
  }
}

void _tomatera(Canvas canvas, String fase) {
  _tallo(canvas, const [
    Offset(50, _suelo),
    Offset(49, 50),
    Offset(51, 30),
    Offset(50, 16),
  ], 2.6);
  _tallo(canvas, const [Offset(49, 52), Offset(34, 40)], 1.6);
  _tallo(canvas, const [Offset(51, 40), Offset(66, 30)], 1.6);
  for (final (p, a, l) in const [
    (Offset(49, 62), math.pi + .5, 14.0),
    (Offset(50, 58), -.6, 14.0),
    (Offset(34, 40), math.pi + .7, 11.0),
    (Offset(66, 30), -.7, 11.0),
    (Offset(51, 26), math.pi + .4, 11.0),
    (Offset(50, 18), -.6, 9.0),
  ]) {
    _hoja(canvas, p, a, l, const Color(0xFF2F9E58));
  }
  if (fase == 'flor') {
    for (final p in const [Offset(38, 46), Offset(62, 36), Offset(54, 22)]) {
      _florecilla(canvas, p, const Color(0xFFFDE047), 3);
    }
  } else if (fase == 'fruto') {
    for (final p in const [Offset(38, 48), Offset(63, 38), Offset(55, 24)]) {
      _tomate(canvas, p, 5.5);
    }
  }
}

void _tomate(Canvas canvas, Offset c, double r) {
  canvas.drawCircle(c, r, _relleno(const Color(0xFFDC2626)));
  canvas.drawCircle(
    c.translate(-r * .35, -r * .35),
    r * .25,
    _relleno(const Color(0x66FFFFFF)),
  );
  for (var i = 0; i < 5; i++) {
    _hoja(
      canvas,
      c.translate(0, -r * .85),
      -math.pi / 2 + (i - 2) * .7,
      r * .7,
      const Color(0xFF15803D),
    );
  }
}

void _arbol(Canvas canvas, String fase, {required bool cerezo}) {
  final tronco = Path()
    ..moveTo(46, _suelo + 1)
    ..lineTo(47, 44)
    ..lineTo(40, 34)
    ..lineTo(43, 33)
    ..lineTo(50, 40)
    ..lineTo(58, 31)
    ..lineTo(60, 33)
    ..lineTo(53, 44)
    ..lineTo(54, _suelo + 1)
    ..close();
  canvas.drawPath(tronco, _relleno(_tronco));
  final copa = cerezo ? const Color(0xFF2F9E58) : const Color(0xFF4D9A3A);
  final copaOscura = Color.lerp(copa, Colors.black, .2)!;
  if (!(fase == 'flor' && !cerezo)) {
    for (final (c, r) in const [
      (Offset(36, 30), 13.0),
      (Offset(64, 30), 13.0),
      (Offset(50, 20), 15.0),
      (Offset(50, 34), 12.0),
    ]) {
      canvas.drawCircle(c, r, _relleno(copaOscura));
      canvas.drawCircle(c.translate(-1.5, -1.5), r - 2, _relleno(copa));
    }
  } else {
    // El avellano florece en invierno, sin hojas: se ven las ramas.
    for (final (a, b) in const [
      (Offset(42, 34), Offset(28, 22)),
      (Offset(58, 32), Offset(74, 20)),
      (Offset(50, 40), Offset(50, 12)),
      (Offset(50, 24), Offset(38, 14)),
      (Offset(50, 22), Offset(62, 12)),
    ]) {
      canvas.drawLine(a, b, _trazo(_tronco, 2));
    }
  }
  switch (fase) {
    case 'planta':
      break;
    case 'flor':
      if (cerezo) {
        for (final p in const [
          Offset(30, 26),
          Offset(40, 18),
          Offset(52, 12),
          Offset(62, 22),
          Offset(70, 30),
          Offset(46, 30),
          Offset(58, 36),
          Offset(36, 36),
        ]) {
          _florecilla(canvas, p, const Color(0xFFFBCFE8), 3.4);
        }
      } else {
        for (final p in const [
          Offset(30, 23),
          Offset(38, 15),
          Offset(50, 14),
          Offset(62, 13),
          Offset(72, 21),
          Offset(44, 28),
        ]) {
          _amento(canvas, p);
        }
      }
    case 'fruto':
      if (cerezo) {
        for (final p in const [
          Offset(32, 34),
          Offset(44, 24),
          Offset(58, 20),
          Offset(66, 34),
          Offset(50, 38),
        ]) {
          _cerezas(canvas, p);
        }
      } else {
        for (final p in const [
          Offset(34, 32),
          Offset(48, 22),
          Offset(62, 28),
          Offset(54, 38),
        ]) {
          _avellana(canvas, p, 3.6);
        }
      }
  }
}

void _amento(Canvas canvas, Offset p) {
  final amento = _trazo(const Color(0xFFEAB308), 2.6);
  final cola = Path()
    ..moveTo(p.dx, p.dy)
    ..quadraticBezierTo(p.dx + 2, p.dy + 5, p.dx, p.dy + 10);
  canvas.drawPath(cola, amento);
}

void _cerezas(Canvas canvas, Offset p) {
  final rabo = _trazo(const Color(0xFF15803D), .9);
  canvas.drawLine(p.translate(0, -6), p.translate(-3, 0), rabo);
  canvas.drawLine(p.translate(0, -6), p.translate(3, 1), rabo);
  for (final c in [p.translate(-3, 1), p.translate(3, 2)]) {
    canvas.drawCircle(c, 2.8, _relleno(const Color(0xFFB91C1C)));
    canvas.drawCircle(
      c.translate(-.8, -.8),
      .8,
      _relleno(const Color(0x88FFFFFF)),
    );
  }
}

void _dienteLeon(Canvas canvas, String fase) {
  for (var i = 0; i < 6; i++) {
    final a = math.pi + .25 + i * (math.pi - .5) / 5;
    _hojaDentada(canvas, const Offset(50, _suelo), a);
  }
  if (fase == 'planta') return;
  _tallo(canvas, const [Offset(50, _suelo), Offset(51, 30)], 1.6);
  const cabeza = Offset(51, 26);
  if (fase == 'flor') {
    for (var i = 0; i < 20; i++) {
      final a = i * 2 * math.pi / 20;
      canvas.drawLine(
        cabeza,
        cabeza + Offset(math.cos(a), math.sin(a)) * 9,
        _trazo(const Color(0xFFFACC15), 2.2),
      );
    }
    canvas.drawCircle(cabeza, 3.5, _relleno(const Color(0xFFEAB308)));
  } else {
    _bolaVilanos(canvas, cabeza, 15);
  }
}

void _hojaDentada(Canvas canvas, Offset base, double angulo) {
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angulo);
  final hoja = Path()..moveTo(0, 0);
  for (var i = 1; i <= 4; i++) {
    hoja.lineTo(i * 5.0 - 2, -3.5);
    hoja.lineTo(i * 5.0, -1.5);
  }
  hoja.lineTo(22, 0);
  for (var i = 4; i >= 1; i--) {
    hoja.lineTo(i * 5.0, 1.5);
    hoja.lineTo(i * 5.0 - 2, 3.5);
  }
  hoja.close();
  canvas.drawPath(hoja, _relleno(_verde));
  canvas.restore();
}

void _bolaVilanos(Canvas canvas, Offset c, double r) {
  canvas.drawCircle(c, r, _relleno(const Color(0xCCFFFFFF)));
  canvas.drawCircle(c, r, _trazo(const Color(0xFFCBD5E1), .6));
  final pelo = _trazo(const Color(0xFF94A3B8), .6);
  for (var i = 0; i < 26; i++) {
    final a = i * 2 * math.pi / 26;
    final punta = c + Offset(math.cos(a), math.sin(a)) * r;
    canvas.drawLine(c, punta, _trazo(const Color(0xFFB6C2D1), .4));
    canvas.drawCircle(punta, 1.3, pelo);
  }
  canvas.drawCircle(c, 1.6, _relleno(const Color(0xFF92400E)));
}

// --- Primeros planos de Difícil ---

void _primerPlanoFlor(Canvas canvas, String planta) {
  const c = Offset(40, 52);
  switch (planta) {
    case 'cerezo':
      _tallo(canvas, const [
        Offset(0, 80),
        Offset(30, 62),
        Offset(40, 52),
      ], 2.4);
      for (var i = 0; i < 5; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / 5;
        canvas.drawCircle(
          c + Offset(math.cos(a), math.sin(a)) * 11,
          9,
          _relleno(const Color(0xFFFBCFE8)),
        );
      }
      for (var i = 0; i < 9; i++) {
        final a = i * 2 * math.pi / 9;
        final punta = c + Offset(math.cos(a), math.sin(a)) * 7;
        canvas.drawLine(c, punta, _trazo(const Color(0xFFEC4899), .8));
        canvas.drawCircle(punta, 1.2, _relleno(const Color(0xFFFACC15)));
      }
    case 'diente-leon':
      _tallo(canvas, const [Offset(40, 100), Offset(40, 52)], 2.6);
      for (var i = 0; i < 28; i++) {
        final a = i * 2 * math.pi / 28;
        canvas.drawLine(
          c,
          c + Offset(math.cos(a), math.sin(a)) * 20,
          _trazo(const Color(0xFFFACC15), 3.4),
        );
      }
      canvas.drawCircle(c, 7, _relleno(const Color(0xFFEAB308)));
    case 'avellano':
      canvas.drawLine(
        const Offset(0, 22),
        const Offset(100, 14),
        _trazo(_tronco, 3),
      );
      for (final x in const [20.0, 40.0, 60.0]) {
        final y = 22 - x * .08;
        final amento = Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x + 5, y + 18, x + 1, y + 36);
        canvas.drawPath(amento, _trazo(const Color(0xFFEAB308), 6));
        for (var k = 0; k < 6; k++) {
          canvas.drawCircle(
            Offset(x + 2 + (k.isEven ? -1.5 : 1.5), y + 5 + k * 5.5),
            1.2,
            _relleno(const Color(0xFFA16207)),
          );
        }
      }
    default:
      _cabezaGirasol(canvas, c, 20, petalos: true, madura: false);
  }
}

void _abeja(Canvas canvas, Offset c) {
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(-2, -7), width: 9, height: 7),
    _relleno(const Color(0xCCE0F2FE)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(4, -7), width: 9, height: 7),
    _relleno(const Color(0xCCE0F2FE)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: c, width: 18, height: 12),
    _relleno(const Color(0xFFFACC15)),
  );
  for (final x in const [-2.5, 2.5]) {
    canvas.drawLine(
      c.translate(x, -5.5),
      c.translate(x, 5.5),
      _trazo(const Color(0xFF1F2937), 2.4),
    );
  }
  canvas.drawCircle(c.translate(-9, -1), 4, _relleno(const Color(0xFF1F2937)));
  canvas.drawCircle(c.translate(-10, -2), 1, _relleno(Colors.white));
  // Las patas cargadas de polen.
  canvas.drawCircle(c.translate(-2, 7), 1.8, _relleno(const Color(0xFFF59E0B)));
  canvas.drawCircle(c.translate(3, 7), 1.8, _relleno(const Color(0xFFF59E0B)));
}

void _polen(Canvas canvas, List<Offset> puntos) {
  for (final p in puntos) {
    canvas.drawCircle(p, 1.6, _relleno(const Color(0xFFF59E0B)));
  }
}

void _viento(Canvas canvas) {
  final aire = _trazo(const Color(0xFF7DD3FC), 1.8);
  for (final y in const [18.0, 34.0, 50.0]) {
    final linea = Path()
      ..moveTo(4, y)
      ..quadraticBezierTo(30, y - 6, 52, y)
      ..quadraticBezierTo(62, y + 3, 64, y - 3)
      ..quadraticBezierTo(64, y - 8, 58, y - 6);
    canvas.drawPath(linea, aire);
  }
}

void _semillasVolando(Canvas canvas, String planta) {
  if (planta == 'diente-leon') {
    _tallo(canvas, const [Offset(18, 100), Offset(20, 66)], 1.6);
    _bolaVilanos(canvas, const Offset(20, 62), 8);
    for (final p in const [
      Offset(46, 40),
      Offset(62, 28),
      Offset(78, 46),
      Offset(88, 22),
      Offset(70, 62),
    ]) {
      _vilanoSuelto(canvas, p);
    }
    return;
  }
  // Los frutos pesados no vuelan: se ven caer cerca.
  for (final p in const [Offset(56, 66), Offset(72, 78), Offset(86, 70)]) {
    if (planta == 'avellano') {
      _avellana(canvas, p, 4.5);
    } else if (planta == 'cerezo') {
      _cerezas(canvas, p);
    } else {
      _semilla(canvas, planta, p, 1);
    }
  }
}

void _vilanoSuelto(Canvas canvas, Offset p) {
  canvas.drawLine(p, p.translate(0, 9), _trazo(const Color(0xFF94A3B8), .7));
  for (var i = 0; i < 9; i++) {
    final a = -math.pi + i * math.pi / 8;
    canvas.drawLine(
      p,
      p + Offset(math.cos(a), math.sin(a)) * 6,
      _trazo(const Color(0xFF94A3B8), .7),
    );
  }
  canvas.drawOval(
    Rect.fromCenter(center: p.translate(0, 9), width: 1.4, height: 3),
    _relleno(const Color(0xFF92400E)),
  );
}

void _pajaro(Canvas canvas, String planta) {
  const c = Offset(50, 50);
  final cuerpo = _relleno(const Color(0xFF2563EB));
  canvas.drawOval(Rect.fromCenter(center: c, width: 34, height: 22), cuerpo);
  canvas.drawCircle(c.translate(15, -10), 9, cuerpo);
  final ala = Path()
    ..moveTo(c.dx - 6, c.dy - 4)
    ..quadraticBezierTo(c.dx - 20, c.dy - 26, c.dx + 6, c.dy - 10)
    ..close();
  canvas.drawPath(ala, _relleno(const Color(0xFF1D4ED8)));
  final cola = Path()
    ..moveTo(c.dx - 16, c.dy)
    ..lineTo(c.dx - 30, c.dy - 6)
    ..lineTo(c.dx - 28, c.dy + 6)
    ..close();
  canvas.drawPath(cola, cuerpo);
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(2, 4), width: 22, height: 10),
    _relleno(const Color(0xFFFDE68A)),
  );
  canvas.drawCircle(c.translate(18, -12), 2, _relleno(Colors.white));
  canvas.drawCircle(c.translate(18.5, -12), 1, _relleno(Colors.black));
  final pico = Path()
    ..moveTo(c.dx + 23, c.dy - 12)
    ..lineTo(c.dx + 32, c.dy - 9)
    ..lineTo(c.dx + 23, c.dy - 7)
    ..close();
  canvas.drawPath(pico, _relleno(const Color(0xFFF59E0B)));
  final boca = c.translate(34, -7);
  if (planta == 'cerezo') {
    canvas.drawCircle(boca, 4, _relleno(const Color(0xFFB91C1C)));
  } else {
    _semilla(canvas, planta, boca, .8);
  }
  // Las patas.
  canvas.drawLine(
    c.translate(-2, 10),
    c.translate(-4, 22),
    _trazo(const Color(0xFFF59E0B), 1.4),
  );
  canvas.drawLine(
    c.translate(5, 10),
    c.translate(6, 22),
    _trazo(const Color(0xFFF59E0B), 1.4),
  );
  // Una semilla que cae lejos.
  canvas.drawLine(
    const Offset(76, 72),
    const Offset(80, 82),
    _trazo(const Color(0x667C4A21), 1),
  );
  _semilla(canvas, planta, const Offset(82, 88), .9);
}

void _ardilla(Canvas canvas, String planta) {
  const c = Offset(44, 58);
  final pelo = _relleno(const Color(0xFFC2410C));
  // La cola grande y rizada.
  final cola = Path()
    ..moveTo(c.dx - 6, c.dy + 8)
    ..cubicTo(c.dx - 36, c.dy, c.dx - 30, c.dy - 40, c.dx - 8, c.dy - 30)
    ..cubicTo(c.dx - 20, c.dy - 20, c.dx - 18, c.dy - 2, c.dx, c.dy + 4)
    ..close();
  canvas.drawPath(cola, _relleno(const Color(0xFFEA580C)));
  canvas.drawOval(Rect.fromCenter(center: c, width: 22, height: 26), pelo);
  canvas.drawCircle(c.translate(10, -14), 9, pelo);
  final oreja = Path()
    ..moveTo(c.dx + 6, c.dy - 21)
    ..lineTo(c.dx + 8, c.dy - 29)
    ..lineTo(c.dx + 12, c.dy - 21)
    ..close();
  canvas.drawPath(oreja, pelo);
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(2, 4), width: 12, height: 16),
    _relleno(const Color(0xFFFED7AA)),
  );
  canvas.drawCircle(c.translate(13, -16), 1.6, _relleno(Colors.black));
  canvas.drawCircle(
    c.translate(18, -12),
    1.2,
    _relleno(const Color(0xFF431407)),
  );
  // El agujero en la tierra con la avellana dentro.
  canvas.drawOval(
    const Rect.fromLTWH(58, 74, 26, 9),
    _relleno(const Color(0xFF4A2F18)),
  );
  if (planta == 'avellano') {
    _avellana(canvas, const Offset(70, 76), 4.5);
  } else {
    _semilla(canvas, planta, const Offset(70, 77), 1);
  }
  // Las patas delanteras empujando la tierra.
  canvas.drawLine(
    c.translate(8, 6),
    c.translate(20, 14),
    _trazo(const Color(0xFFC2410C), 3),
  );
}

/// Fotograma de cada cromo de «La película de la planta».
const cromosPelicula = {
  'semilla-brote-planta': ('girasol', 'brote'),
  'ciclo-de-la-planta': ('tomatera', 'fruto'),
  'de-semilla-a-semilla': ('diente-leon', 'viento-semillas'),
};

/// Miniatura de un cromo de «La película de la planta».
class MiniaturaPelicula extends StatelessWidget {
  const MiniaturaPelicula({required this.cromo, this.alto = 64, super.key});

  final String cromo;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final (planta, fase) = cromosPelicula[cromo]!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(alto * .14),
      child: DibujoPelicula(planta: planta, fase: fase, tamano: alto),
    );
  }
}
