import 'dart:math' as math;

import 'package:flutter/material.dart';

// Dibujos de «La planta a oscuras». La escena se pinta sobre un lienzo de
// 100 × 75. El cuarto tiene la ventana a la izquierda y el armario a la
// derecha; la caja tiene tres sitios posibles para el agujero.

/// Proporción alto/ancho de la escena.
const aspectoEscenaOscuras = .75;

const _pared = Color(0xFFFDF6E3);
const _suelo = Color(0xFFD6B98C);
const _madera = Color(0xFF8B5A2B);
const _maderaOscura = Color(0xFF5B3A1E);
const _carton = Color(0xFFD4A373);
const _cartonOscuro = Color(0xFF8C6239);
const _luz = Color(0xFFFDE047);
const _barro = Color(0xFFC2410C);

/// La escena del experimento. [crecimiento] es `null` mientras no han pasado
/// los días; [t] va de 0 a 1 y es lo que ha crecido la planta.
class PintorOscuras extends CustomPainter {
  const PintorOscuras({
    required this.escenario,
    required this.montaje,
    required this.crecimiento,
    required this.t,
    this.meta = '',
  });

  /// cuarto o caja.
  final String escenario;

  /// Dónde está la maceta, o `null` si aún no se ha elegido.
  final String? montaje;

  final String? crecimiento;
  final double t;
  final String meta;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 75);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 100, 75));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 75), _relleno(_pared));
    canvas.drawRect(const Rect.fromLTWH(0, 66, 100, 9), _relleno(_suelo));
    if (escenario == 'caja') {
      _caja(canvas);
    } else {
      _cuarto(canvas);
    }
    canvas.restore();
  }

  void _cuarto(Canvas canvas) {
    // La ventana con el sol.
    const ventana = Rect.fromLTWH(5, 6, 34, 36);
    canvas.drawRect(ventana, _relleno(const Color(0xFFBAE6FD)));
    canvas.drawCircle(const Offset(15, 15), 6, _relleno(_luz));
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        const Offset(15, 15) + Offset(math.cos(a), math.sin(a)) * 8,
        const Offset(15, 15) + Offset(math.cos(a), math.sin(a)) * 10.5,
        _trazo(_luz, 1.2),
      );
    }
    canvas.drawRect(ventana, _trazo(Colors.white, 2.4));
    canvas.drawLine(
      Offset(ventana.center.dx, ventana.top),
      Offset(ventana.center.dx, ventana.bottom),
      _trazo(Colors.white, 1.6),
    );
    canvas.drawLine(
      Offset(ventana.left, ventana.center.dy),
      Offset(ventana.right, ventana.center.dy),
      _trazo(Colors.white, 1.6),
    );
    // El alféizar.
    canvas.drawRect(const Rect.fromLTWH(2, 42, 40, 3), _relleno(_madera));
    // Luz que entra por la ventana.
    final rayo = Path()
      ..moveTo(39, 8)
      ..lineTo(60, 66)
      ..lineTo(36, 66)
      ..lineTo(39, 42)
      ..close();
    canvas.drawPath(rayo, _relleno(const Color(0x33FDE047)));

    // El armario, abierto y oscuro por dentro.
    const armario = Rect.fromLTWH(62, 4, 34, 62);
    canvas.drawRect(armario, _relleno(_maderaOscura));
    canvas.drawRect(armario.deflate(3), _relleno(const Color(0xFF111827)));
    canvas.drawRect(
      Rect.fromLTWH(armario.left + 3, 36, armario.width - 6, 2),
      _relleno(_maderaOscura),
    );
    // Las puertas, entornadas.
    final puerta = Path()
      ..moveTo(armario.left, armario.top)
      ..lineTo(armario.left - 6, armario.top + 4)
      ..lineTo(armario.left - 6, armario.bottom - 4)
      ..lineTo(armario.left, armario.bottom)
      ..close();
    canvas.drawPath(puerta, _relleno(_madera));

    final base = switch (montaje) {
      'ventana' => const Offset(22, 42),
      'armario' => const Offset(79, 63),
      _ => const Offset(50, 70),
    };
    final punta = switch (montaje) {
      'ventana' => const Offset(22, 12),
      'armario' => const Offset(79, 40),
      _ => const Offset(50, 46),
    };
    _maceta(canvas, base, punta, montaje == null);
  }

  void _caja(Canvas canvas) {
    // Una lámpara de sol fuera, que ilumina por donde haya agujero.
    const caja = Rect.fromLTWH(26, 16, 48, 52);
    canvas.drawRect(caja, _relleno(_cartonOscuro));
    canvas.drawRect(caja.deflate(3), _relleno(const Color(0xFF3B2A1A)));
    canvas.drawRect(caja, _trazo(_carton, 3));
    final agujero = switch (montaje) {
      'caja-izquierda' => const Offset(27.5, 28),
      'caja-arriba' => const Offset(50, 17.5),
      'caja-derecha' => const Offset(72.5, 28),
      _ => null,
    };
    if (agujero != null) {
      final rayo = switch (montaje) {
        'caja-izquierda' =>
          Path()
            ..moveTo(28, 23)
            ..lineTo(56, 52)
            ..lineTo(48, 64)
            ..lineTo(28, 33)
            ..close(),
        'caja-arriba' =>
          Path()
            ..moveTo(45, 18)
            ..lineTo(55, 18)
            ..lineTo(60, 64)
            ..lineTo(40, 64)
            ..close(),
        _ =>
          Path()
            ..moveTo(72, 23)
            ..lineTo(44, 52)
            ..lineTo(52, 64)
            ..lineTo(72, 33)
            ..close(),
      };
      canvas.drawPath(rayo, _relleno(const Color(0x44FDE047)));
      canvas.drawCircle(agujero, 4.2, _relleno(_luz));
      canvas.drawCircle(agujero, 4.2, _trazo(_cartonOscuro, 1));
    }
    final lugarMeta = switch (meta) {
      'izquierda' => const Offset(11, 26),
      'arriba' => const Offset(50, 7),
      'derecha' => const Offset(89, 26),
      _ => null,
    };
    if (lugarMeta != null) _mariposa(canvas, lugarMeta);

    const base = Offset(50, 65);
    final punta = switch (montaje) {
      'caja-izquierda' => const Offset(32, 30),
      'caja-derecha' => const Offset(68, 30),
      'caja-arriba' => const Offset(50, 22),
      _ => const Offset(50, 42),
    };
    _maceta(canvas, base, punta, montaje == null);
  }

  void _maceta(Canvas canvas, Offset base, Offset punta, bool sinSitio) {
    final estado = crecimiento;
    final crecido = estado == null ? .25 : .25 + .75 * t;
    final palida = estado == 'palida' && t > .2;
    final fin = Offset.lerp(base, punta, crecido)!;
    // El tallo se dobla poco a poco: el punto de control queda debajo del
    // final, como si la punta se fuese girando hacia la luz.
    final control = Offset(base.dx, (base.dy + fin.dy) / 2);
    Offset punto(double s) {
      final u = 1 - s;
      return base * (u * u) + control * (2 * u * s) + fin * (s * s);
    }

    final verde = palida
        ? Color.lerp(const Color(0xFF22A05A), const Color(0xFFE8E27A), t)!
        : const Color(0xFF22A05A);
    final grosor = palida ? 1.3 : 2.2;
    final tallo = Path()..moveTo(base.dx, base.dy);
    tallo.quadraticBezierTo(control.dx, control.dy, fin.dx, fin.dy);
    canvas.drawPath(
      tallo,
      _trazo(Color.lerp(verde, Colors.black, .1)!, grosor),
    );
    final pares = 1 + (crecido * 4).floor();
    final largo = palida ? 5.0 : 8.0;
    for (var i = 1; i <= pares; i++) {
      final s = i / (pares + .5);
      final p = punto(s);
      final siguiente = punto(math.min(1, s + .02));
      final rumbo = math.atan2(siguiente.dy - p.dy, siguiente.dx - p.dx);
      _hoja(canvas, p, rumbo - 1.1, largo * (1.1 - s * .4), verde);
      _hoja(canvas, p, rumbo + 1.1, largo * (1.1 - s * .4), verde);
    }
    _hoja(canvas, fin, -math.pi / 2 - .5, largo * .7, verde);
    _hoja(canvas, fin, -math.pi / 2 + .5, largo * .7, verde);

    // La maceta, delante del tallo.
    final maceta = Path()
      ..moveTo(base.dx - 7, base.dy - 2)
      ..lineTo(base.dx + 7, base.dy - 2)
      ..lineTo(base.dx + 5, base.dy + 8)
      ..lineTo(base.dx - 5, base.dy + 8)
      ..close();
    canvas.drawPath(maceta, _relleno(_barro));
    canvas.drawRect(
      Rect.fromLTWH(base.dx - 8, base.dy - 3.5, 16, 3),
      _relleno(const Color(0xFFEA580C)),
    );
    if (sinSitio) {
      canvas.drawCircle(
        base.translate(13, -10),
        5,
        _relleno(const Color(0xFFF59E0B)),
      );
      final tp = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, base.translate(13 - tp.width / 2, -10 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(PintorOscuras old) =>
      old.escenario != escenario ||
      old.montaje != montaje ||
      old.crecimiento != crecimiento ||
      old.t != t ||
      old.meta != meta;
}

/// Una planta pequeña tal como sale en cada predicción: sana, pálida o
/// doblada.
class PintorPrediccion extends CustomPainter {
  const PintorPrediccion(this.estado);

  final String estado;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    const base = Offset(20, 32);
    final punta = switch (estado) {
      'doblada' => const Offset(8, 8),
      'palida' => const Offset(20, 2),
      _ => const Offset(20, 8),
    };
    final palida = estado == 'palida';
    final verde = palida ? const Color(0xFFD9D46A) : const Color(0xFF22A05A);
    final control = Offset(base.dx, (base.dy + punta.dy) / 2);
    final tallo = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(control.dx, control.dy, punta.dx, punta.dy);
    canvas.drawPath(tallo, _trazo(verde, palida ? 1.2 : 2));
    Offset punto(double s) {
      final u = 1 - s;
      return base * (u * u) + control * (2 * u * s) + punta * (s * s);
    }

    for (final s in const [.35, .7]) {
      final p = punto(s);
      _hoja(canvas, p, -math.pi / 2 - 1.1, palida ? 4 : 7, verde);
      _hoja(canvas, p, -math.pi / 2 + 1.1, palida ? 4 : 7, verde);
    }
    if (estado == 'doblada') {
      canvas.drawCircle(const Offset(4, 4), 3.5, _relleno(_luz));
    }
    final maceta = Path()
      ..moveTo(base.dx - 6, base.dy - 1)
      ..lineTo(base.dx + 6, base.dy - 1)
      ..lineTo(base.dx + 4.5, base.dy + 7)
      ..lineTo(base.dx - 4.5, base.dy + 7)
      ..close();
    canvas.drawPath(maceta, _relleno(_barro));
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorPrediccion old) => old.estado != estado;
}

/// La hoja vista de cerca, como una fábrica. Si [encendida], brilla.
class PintorHojaFabrica extends CustomPainter {
  const PintorHojaFabrica({required this.encendida});

  final bool encendida;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 60);
    // El rabillo (peciolo) sale por la izquierda y la punta queda a la
    // derecha, un poco levantada, como una hoja de judía vista de cerca.
    const base = Offset(14, 32);
    const punta = Offset(95, 26);
    canvas.drawPath(
      Path()
        ..moveTo(1, 38)
        ..quadraticBezierTo(8, 35, base.dx, base.dy),
      _trazo(const Color(0xFF3F7D2C), 2.6),
    );
    final hoja = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(18, 12, 46, 3, 70, 8)
      ..cubicTo(84, 11, 91, 19, punta.dx, punta.dy)
      ..cubicTo(90, 36, 78, 48, 60, 52)
      ..cubicTo(40, 56, 20, 50, base.dx, base.dy)
      ..close();
    final clara = encendida ? const Color(0xFF6EE7A0) : const Color(0xFF4CC46E);
    final oscura = encendida
        ? const Color(0xFF22A05A)
        : const Color(0xFF1F8A4C);
    canvas.drawPath(
      hoja,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [clara, oscura],
        ).createShader(const Rect.fromLTWH(0, 4, 100, 52)),
    );
    if (encendida) {
      canvas.drawPath(
        hoja,
        Paint()
          ..color = const Color(0x55FDE047)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    // El nervio central se curva con la hoja y se estrecha hacia la punta.
    Offset central(double t) {
      const c = Offset(56, 26);
      final u = 1 - t;
      return base * (u * u) + c * (2 * u * t) + punta * (t * t);
    }

    final nervioCentral = Path()..moveTo(base.dx, base.dy);
    for (var i = 1; i <= 20; i++) {
      final p = central(i / 20 * .96);
      nervioCentral.lineTo(p.dx, p.dy);
    }
    final colorNervio = encendida
        ? const Color(0xFFD9F99D)
        : const Color(0xFFBBF7D0);
    canvas.drawPath(nervioCentral, _trazo(colorNervio, 1.6));
    // Los nervios secundarios salen alternos y se curvan hacia la punta.
    final nervio = _trazo(colorNervio.withValues(alpha: .85), .8);
    for (var i = 0; i < 6; i++) {
      final t = .14 + i * .13;
      final arranque = central(t);
      final largo = 18 * (1 - t * .65);
      for (final lado in const [-1.0, 1.0]) {
        final desfase = lado < 0 ? 0.0 : .05;
        final o = central(t + desfase);
        final fin = o + Offset(largo * .85, lado * largo * .6);
        final control = o + Offset(largo * .3, lado * largo * .42);
        canvas.drawPath(
          Path()
            ..moveTo(o.dx, o.dy)
            ..quadraticBezierTo(control.dx, control.dy, fin.dx, fin.dy),
          nervio,
        );
      }
      if (arranque.dx > 90) break;
    }
    // Un brillo suave arriba y el borde un poco más oscuro.
    canvas.drawPath(
      Path()
        ..moveTo(24, 20)
        ..quadraticBezierTo(42, 9, 62, 10),
      _trazo(Colors.white.withValues(alpha: .35), 2.2),
    );
    canvas.drawPath(hoja, _trazo(Color.lerp(oscura, Colors.black, .3)!, 1.1));
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorHojaFabrica old) => old.encendida != encendida;
}

Paint _relleno(Color color) => Paint()..color = color;

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round;

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
    ..quadraticBezierTo(largo * .5, -largo * .4, largo, 0)
    ..quadraticBezierTo(largo * .5, largo * .4, 0, 0);
  canvas.drawPath(hoja, _relleno(color));
  canvas.restore();
}

void _mariposa(Canvas canvas, Offset c) {
  final ala = _relleno(const Color(0xFFF472B6));
  final alaBaja = _relleno(const Color(0xFFC084FC));
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(-3.2, -2), width: 6, height: 5),
    ala,
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(3.2, -2), width: 6, height: 5),
    ala,
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(-2.4, 2), width: 4, height: 3.6),
    alaBaja,
  );
  canvas.drawOval(
    Rect.fromCenter(center: c.translate(2.4, 2), width: 4, height: 3.6),
    alaBaja,
  );
  canvas.drawLine(
    c.translate(0, -3),
    c.translate(0, 3.5),
    _trazo(const Color(0xFF1F2937), 1.2),
  );
}

/// Dibujo de cada cromo de «La planta a oscuras».
const cromosOscuras = {
  'planta-y-luz': ('cuarto', 'ventana', 'sana'),
  'crece-hacia-la-luz': ('caja', 'caja-derecha', 'derecha'),
  'hoja-fabrica': ('hoja', '', ''),
};

/// Miniatura de un cromo de «La planta a oscuras».
class MiniaturaOscuras extends StatelessWidget {
  const MiniaturaOscuras({required this.cromo, this.alto = 64, super.key});

  final String cromo;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final (escenario, montaje, crecimiento) = cromosOscuras[cromo]!;
    final pintor = escenario == 'hoja'
        ? const PintorHojaFabrica(encendida: true) as CustomPainter
        : PintorOscuras(
            escenario: escenario,
            montaje: montaje,
            crecimiento: crecimiento,
            t: 1,
          );
    final ancho = escenario == 'hoja' ? alto / .6 : alto / aspectoEscenaOscuras;
    return ClipRRect(
      borderRadius: BorderRadius.circular(alto * .12),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: CustomPaint(painter: pintor),
      ),
    );
  }
}
