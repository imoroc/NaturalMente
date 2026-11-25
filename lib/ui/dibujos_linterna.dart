import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/modelo/linterna.dart';

// Dibujos de «Linterna y microscopio»: las escenas que se exploran a oscuras
// y la oscuridad con el círculo de luz. Todas las escenas se dibujan sobre
// 300 × 400 puntos; las zonas del catálogo usan esas mismas medidas
// (x = puntos / 300, y = puntos / 400, r = puntos / 300).

/// Escenas que sabe dibujar [EscenaLinternaPintor].
const dibujosLinterna = {
  'nino',
  'cara',
  'esqueleto',
  'por-dentro',
  'celula-animal',
  'celula-vegetal',
  'organizacion',
};

const _ancho = 300.0;
const _alto = _ancho * aspectoEscenaLinterna;

const _piel = Color(0xFFF2C29B);
const _pielOscura = Color(0xFFD9A07A);
const _camiseta = Color(0xFF3B82F6);
const _pantalon = Color(0xFF1E3A8A);
const _pelo = Color(0xFF5B3A1E);
const _hueso = Color(0xFFE6F1FF);
const _fondoRayos = Color(0xFF0B2545);
const _siluetaRayos = Color(0xFF1D4E89);

Paint _relleno(Color color) => Paint()..color = color;

Paint _trazo(Color color, double ancho) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = ancho
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Dibuja una escena entera, iluminada.
class EscenaLinternaPintor extends CustomPainter {
  const EscenaLinternaPintor(this.dibujo);

  final String dibujo;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _ancho, size.height / _alto);
    switch (dibujo) {
      case 'nino':
        _cuarto(canvas);
        _nino(canvas);
      case 'cara':
        _cuarto(canvas);
        _cara(canvas);
      case 'esqueleto':
        _rayos(canvas);
        _esqueleto(canvas, 1);
      case 'por-dentro':
        _rayos(canvas);
        _esqueleto(canvas, .4);
        _organos(canvas);
      case 'celula-animal':
        _portaobjetos(canvas);
        _celulaAnimal(canvas);
      case 'celula-vegetal':
        _portaobjetos(canvas);
        _celulaVegetal(canvas);
      case 'organizacion':
        _portaobjetos(canvas);
        _organizacion(canvas);
    }
    canvas.restore();
  }

  void _cuarto(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _ancho, _alto),
      _relleno(const Color(0xFFFFF7E6)),
    );
    // Papel pintado de rayas suaves y suelo de madera.
    for (var x = 20.0; x < _ancho; x += 40) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 14, 386),
        _relleno(const Color(0xFFFCEFD6)),
      );
    }
    canvas.drawRect(
      const Rect.fromLTWH(0, 386, _ancho, 14),
      _relleno(const Color(0xFFD6B48A)),
    );
  }

  void _nino(Canvas canvas) {
    final piel = _relleno(_piel);
    // Piernas y pies.
    for (final x in [118.0, 154.0]) {
      canvas.drawRRect(
        RRect.fromLTRBR(x, 240, x + 28, 364, const Radius.circular(12)),
        piel,
      );
    }
    for (final x in [122.0, 178.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 371), width: 42, height: 18),
        piel,
      );
    }
    canvas.drawRRect(
      RRect.fromLTRBR(108, 230, 192, 284, const Radius.circular(10)),
      _relleno(_pantalon),
    );
    // Brazos y manos.
    final brazo = _trazo(_piel, 24);
    canvas.drawLine(const Offset(110, 140), const Offset(66, 236), brazo);
    canvas.drawLine(const Offset(190, 140), const Offset(234, 236), brazo);
    canvas.drawCircle(const Offset(60, 249), 15, piel);
    canvas.drawCircle(const Offset(240, 249), 15, piel);
    final manga = _trazo(_camiseta, 28);
    canvas.drawLine(const Offset(112, 138), const Offset(98, 168), manga);
    canvas.drawLine(const Offset(188, 138), const Offset(202, 168), manga);
    // Cuello y tronco.
    canvas.drawRect(const Rect.fromLTRB(138, 100, 162, 130), piel);
    canvas.drawRRect(
      RRect.fromLTRBR(104, 122, 196, 246, const Radius.circular(22)),
      _relleno(_camiseta),
    );
    canvas.drawCircle(
      const Offset(150, 182),
      14,
      _relleno(const Color(0xFFFACC15)),
    );
    // Cabeza.
    canvas.drawCircle(const Offset(110, 72), 9, piel);
    canvas.drawCircle(const Offset(190, 72), 9, piel);
    canvas.drawCircle(const Offset(150, 70), 40, piel);
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(150, 64), radius: 41),
      math.pi,
      math.pi,
      true,
      _relleno(_pelo),
    );
    final oscuro = _relleno(const Color(0xFF3F2A1C));
    canvas.drawCircle(const Offset(136, 74), 4.5, oscuro);
    canvas.drawCircle(const Offset(164, 74), 4.5, oscuro);
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(150, 86), width: 24, height: 14),
      .2 * math.pi,
      .6 * math.pi,
      false,
      _trazo(const Color(0xFF9A3412), 3),
    );
  }

  void _cara(Canvas canvas) {
    final piel = _relleno(_piel);
    // Cuello y camiseta.
    canvas.drawRect(const Rect.fromLTRB(108, 320, 192, 400), piel);
    canvas.drawRRect(
      RRect.fromLTRBR(30, 368, 270, 430, const Radius.circular(40)),
      _relleno(_camiseta),
    );
    // Pelo de detrás, orejas y cara.
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(150, 170), width: 244, height: 236),
      math.pi,
      math.pi,
      true,
      _relleno(_pelo),
    );
    for (final x in [30.0, 270.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 205), width: 40, height: 64),
        piel,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 205), width: 18, height: 36),
        _relleno(_pielOscura),
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(150, 200), width: 224, height: 280),
      piel,
    );
    // Flequillo.
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(150, 140), width: 214, height: 130),
      math.pi,
      math.pi,
      true,
      _relleno(_pelo),
    );
    // Cejas y ojos.
    final ceja = _trazo(_pelo, 6);
    canvas.drawLine(const Offset(86, 148), const Offset(122, 144), ceja);
    canvas.drawLine(const Offset(178, 144), const Offset(214, 148), ceja);
    for (final x in [105.0, 195.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 175), width: 42, height: 26),
        _relleno(Colors.white),
      );
      canvas.drawCircle(Offset(x, 175), 10, _relleno(const Color(0xFF6B4226)));
      canvas.drawCircle(Offset(x, 175), 5, _relleno(const Color(0xFF111827)));
      canvas.drawCircle(Offset(x + 3, 171), 2, _relleno(Colors.white));
    }
    // Nariz.
    final nariz = Path()
      ..moveTo(150, 196)
      ..quadraticBezierTo(136, 236, 142, 240)
      ..quadraticBezierTo(150, 246, 158, 240);
    canvas.drawPath(nariz, _trazo(_pielOscura, 4));
    // Mofletes.
    final moflete = _relleno(const Color(0x55F43F5E));
    canvas.drawCircle(const Offset(82, 238), 15, moflete);
    canvas.drawCircle(const Offset(218, 238), 15, moflete);
    // Boca.
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(150, 270), width: 74, height: 46),
      0,
      math.pi,
      true,
      _relleno(const Color(0xFFBE123C)),
    );
    canvas.drawRect(
      const Rect.fromLTRB(124, 270, 176, 277),
      _relleno(Colors.white),
    );
  }

  void _rayos(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _ancho, _alto),
      _relleno(_fondoRayos),
    );
    // Silueta del cuerpo, apenas visible en la radiografía.
    final silueta = _relleno(_siluetaRayos);
    canvas.drawCircle(const Offset(150, 70), 42, silueta);
    canvas.drawRect(const Rect.fromLTRB(136, 100, 164, 130), silueta);
    canvas.drawRRect(
      RRect.fromLTRBR(102, 120, 198, 276, const Radius.circular(24)),
      silueta,
    );
    final brazo = _trazo(_siluetaRayos, 28);
    canvas.drawLine(const Offset(110, 136), const Offset(64, 240), brazo);
    canvas.drawLine(const Offset(190, 136), const Offset(236, 240), brazo);
    for (final x in [116.0, 154.0]) {
      canvas.drawRRect(
        RRect.fromLTRBR(x, 250, x + 30, 372, const Radius.circular(14)),
        silueta,
      );
    }
  }

  void _esqueleto(Canvas canvas, double opacidad) {
    final color = _hueso.withValues(alpha: opacidad);
    final hueso = _relleno(color);
    final hueco = _relleno(_fondoRayos);
    // Cráneo y mandíbula.
    canvas.drawCircle(const Offset(150, 64), 36, hueso);
    canvas.drawRRect(
      RRect.fromLTRBR(130, 86, 170, 108, const Radius.circular(8)),
      hueso,
    );
    if (opacidad == 1) {
      for (final x in [136.0, 164.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 66), width: 16, height: 13),
          hueco,
        );
      }
      canvas.drawPath(
        Path()
          ..moveTo(150, 74)
          ..lineTo(145, 84)
          ..lineTo(155, 84)
          ..close(),
        hueco,
      );
      final diente = _trazo(_fondoRayos, 1.5);
      for (var x = 138.0; x <= 162; x += 6) {
        canvas.drawLine(Offset(x, 96), Offset(x, 104), diente);
      }
    }
    // Columna.
    for (var y = 112.0; y <= 248; y += 9) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(150, y), width: 15, height: 7),
          const Radius.circular(2),
        ),
        hueso,
      );
    }
    final fino = _trazo(color, 5);
    // Clavículas, esternón y costillas.
    canvas.drawLine(const Offset(146, 124), const Offset(110, 130), fino);
    canvas.drawLine(const Offset(154, 124), const Offset(190, 130), fino);
    canvas.drawRRect(
      RRect.fromLTRBR(146, 132, 154, 190, const Radius.circular(3)),
      hueso,
    );
    for (var i = 0; i < 6; i++) {
      final y = 140.0 + i * 12;
      canvas.drawPath(
        Path()
          ..moveTo(146, y)
          ..quadraticBezierTo(108, y - 4, 114, y + 12),
        fino,
      );
      canvas.drawPath(
        Path()
          ..moveTo(154, y)
          ..quadraticBezierTo(192, y - 4, 186, y + 12),
        fino,
      );
    }
    // Pelvis.
    canvas.drawRRect(
      RRect.fromLTRBR(114, 244, 186, 268, const Radius.circular(14)),
      hueso,
    );
    if (opacidad == 1) {
      for (final x in [132.0, 168.0]) {
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, 258), width: 16, height: 10),
          hueco,
        );
      }
    }
    // Brazos y piernas, a los dos lados.
    for (final lado in [1.0, -1.0]) {
      double x(double valor) => lado == 1 ? valor : _ancho - valor;
      canvas.drawLine(
        Offset(x(110), 132),
        Offset(x(88), 190),
        _trazo(color, 8),
      );
      canvas.drawLine(Offset(x(87), 192), Offset(x(64), 236), _trazo(color, 4));
      canvas.drawLine(Offset(x(93), 194), Offset(x(70), 238), _trazo(color, 4));
      canvas.drawCircle(Offset(x(110), 132), 8, hueso);
      canvas.drawCircle(Offset(x(88), 192), 6.5, hueso);
      for (final dedo in [-8.0, -3.0, 2.0, 7.0]) {
        canvas.drawLine(
          Offset(x(66), 240),
          Offset(x(60 + dedo), 258),
          _trazo(color, 2.5),
        );
      }
      canvas.drawLine(
        Offset(x(134), 264),
        Offset(x(131), 312),
        _trazo(color, 9),
      );
      canvas.drawCircle(Offset(x(131), 318), 7.5, hueso);
      canvas.drawLine(
        Offset(x(129), 324),
        Offset(x(127), 362),
        _trazo(color, 6),
      );
      canvas.drawLine(
        Offset(x(137), 324),
        Offset(x(135), 362),
        _trazo(color, 3),
      );
      canvas.drawLine(
        Offset(x(129), 366),
        Offset(x(112), 376),
        _trazo(color, 4),
      );
    }
  }

  void _organos(Canvas canvas) {
    // Cerebro dentro del cráneo.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(150, 62), width: 58, height: 42),
      _relleno(const Color(0xFFF9A8D4)),
    );
    final surco = _trazo(const Color(0xFFDB2777), 2);
    canvas.drawLine(const Offset(150, 43), const Offset(150, 82), surco);
    for (final y in [52.0, 62.0, 72.0]) {
      canvas.drawArc(
        Rect.fromCenter(center: Offset(136, y), width: 16, height: 8),
        math.pi,
        math.pi,
        false,
        surco,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(164, y), width: 16, height: 8),
        0,
        math.pi,
        false,
        surco,
      );
    }
    // Pulmones.
    final pulmon = _relleno(const Color(0xFF7DD3FC));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(118, 165), width: 44, height: 76),
      pulmon,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(184, 160), width: 40, height: 70),
      pulmon,
    );
    // Corazón.
    final corazon = Path()
      ..moveTo(158, 200)
      ..cubicTo(136, 186, 142, 168, 152, 172)
      ..cubicTo(156, 173, 158, 177, 158, 179)
      ..cubicTo(158, 177, 160, 173, 164, 172)
      ..cubicTo(174, 168, 180, 186, 158, 200)
      ..close();
    canvas.drawPath(corazon, _relleno(const Color(0xFFEF4444)));
  }

  void _portaobjetos(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, _ancho, _alto),
      _relleno(const Color(0xFFF1F5E9)),
    );
    final punto = _relleno(const Color(0xFFE2E8D5));
    final azar = math.Random(7);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(azar.nextDouble() * _ancho, azar.nextDouble() * _alto),
        1.5 + azar.nextDouble() * 2,
        punto,
      );
    }
  }

  void _celulaAnimal(Canvas canvas) {
    final borde = Path();
    const pasos = 72;
    for (var i = 0; i <= pasos; i++) {
      final a = i / pasos * 2 * math.pi;
      final onda = 1 + .02 * math.sin(a * 5);
      final p = Offset(
        150 + 125 * onda * math.cos(a),
        200 + 150 * onda * math.sin(a),
      );
      if (i == 0) {
        borde.moveTo(p.dx, p.dy);
      } else {
        borde.lineTo(p.dx, p.dy);
      }
    }
    borde.close();
    canvas.drawPath(borde, _relleno(const Color(0xFFFDE2C4)));
    // Gránulos y mitocondrias del citoplasma.
    final granulo = _relleno(const Color(0xFFF5C08F));
    final azar = math.Random(3);
    for (var i = 0; i < 26; i++) {
      final a = azar.nextDouble() * 2 * math.pi;
      final d = .5 + azar.nextDouble() * .35;
      canvas.drawCircle(
        Offset(150 + 125 * d * math.cos(a), 200 + 150 * d * math.sin(a)),
        2.5,
        granulo,
      );
    }
    for (final (centro, giro) in [
      (const Offset(108, 220), .6),
      (const Offset(196, 268), -.4),
      (const Offset(150, 300), .2),
    ]) {
      canvas.save();
      canvas.translate(centro.dx, centro.dy);
      canvas.rotate(giro);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 30, height: 14),
        _relleno(const Color(0xFFFB923C)),
      );
      canvas.drawLine(
        const Offset(-10, 0),
        const Offset(10, 0),
        _trazo(const Color(0xFFC2410C), 2),
      );
      canvas.restore();
    }
    canvas.drawPath(borde, _trazo(const Color(0xFFF97316), 7));
    // Núcleo.
    canvas.drawCircle(
      const Offset(165, 185),
      38,
      _relleno(const Color(0xFFC4B5FD)),
    );
    canvas.drawCircle(
      const Offset(165, 185),
      38,
      _trazo(const Color(0xFF7C3AED), 4),
    );
    canvas.drawCircle(
      const Offset(173, 177),
      12,
      _relleno(const Color(0xFF6D28D9)),
    );
  }

  void _celulaVegetal(Canvas canvas) {
    final pared = RRect.fromLTRBR(40, 60, 260, 340, const Radius.circular(18));
    canvas.drawRRect(pared, _relleno(const Color(0xFFDCFCE7)));
    canvas.drawRRect(pared, _trazo(const Color(0xFF15803D), 10));
    canvas.drawRRect(
      RRect.fromLTRBR(50, 70, 250, 330, const Radius.circular(12)),
      _trazo(const Color(0xFF4ADE80), 2),
    );
    // Vacuola.
    final vacuola = Rect.fromCenter(
      center: const Offset(135, 215),
      width: 120,
      height: 160,
    );
    canvas.drawOval(vacuola, _relleno(const Color(0xFFBAE6FD)));
    canvas.drawOval(vacuola, _trazo(const Color(0xFF0EA5E9), 3));
    // Cloroplastos.
    for (final (centro, giro) in [
      (const Offset(80, 110), .3),
      (const Offset(225, 300), -.5),
      (const Offset(70, 310), -.2),
      (const Offset(240, 170), 1.2),
    ]) {
      canvas.save();
      canvas.translate(centro.dx, centro.dy);
      canvas.rotate(giro);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 36, height: 21),
        _relleno(const Color(0xFF16A34A)),
      );
      final raya = _trazo(const Color(0xFF14532D), 2);
      for (final x in [-8.0, 0.0, 8.0]) {
        canvas.drawLine(Offset(x, -5), Offset(x, 5), raya);
      }
      canvas.restore();
    }
    // Núcleo.
    canvas.drawCircle(
      const Offset(210, 115),
      26,
      _relleno(const Color(0xFFC4B5FD)),
    );
    canvas.drawCircle(
      const Offset(210, 115),
      26,
      _trazo(const Color(0xFF7C3AED), 3.5),
    );
    canvas.drawCircle(
      const Offset(216, 110),
      8,
      _relleno(const Color(0xFF6D28D9)),
    );
  }

  void _organizacion(Canvas canvas) {
    // Cuerpo con el aparato digestivo.
    const cuerpo = Color(0xFFFDE7D3);
    final contorno = _trazo(const Color(0xFFE2B48C), 3);
    final silueta = _relleno(cuerpo);
    for (final x in [50.0, 86.0]) {
      final pierna = RRect.fromLTRBR(
        x,
        262,
        x + 24,
        382,
        const Radius.circular(10),
      );
      canvas.drawRRect(pierna, silueta);
      canvas.drawRRect(pierna, contorno);
    }
    final brazo = _trazo(cuerpo, 18);
    canvas.drawLine(const Offset(44, 116), const Offset(22, 236), brazo);
    canvas.drawLine(const Offset(116, 116), const Offset(138, 236), brazo);
    final tronco = RRect.fromLTRBR(
      42,
      100,
      118,
      276,
      const Radius.circular(26),
    );
    canvas.drawRRect(tronco, silueta);
    canvas.drawRRect(tronco, contorno);
    canvas.drawCircle(const Offset(80, 70), 28, silueta);
    canvas.drawCircle(const Offset(80, 70), 28, contorno);
    final tubo = _trazo(const Color(0xFFF472B6), 8);
    canvas.drawLine(const Offset(80, 94), const Offset(84, 150), tubo);
    // Intestino grueso y delgado.
    canvas.drawRRect(
      RRect.fromLTRBR(52, 200, 108, 258, const Radius.circular(14)),
      _trazo(const Color(0xFFDB2777), 9),
    );
    final delgado = Path()..moveTo(66, 212);
    for (var i = 0; i < 4; i++) {
      final y = 212.0 + i * 10;
      delgado.quadraticBezierTo(
        i.isEven ? 100 : 60,
        y + 5,
        i.isEven ? 66 : 94,
        y + 10,
      );
    }
    canvas.drawPath(delgado, _trazo(const Color(0xFFF9A8D4), 6));
    // Estómago.
    final estomago = Path()
      ..moveTo(80, 152)
      ..cubicTo(74, 178, 104, 188, 116, 170)
      ..cubicTo(122, 158, 112, 146, 102, 152)
      ..cubicTo(96, 158, 90, 160, 86, 150)
      ..close();
    canvas.drawPath(estomago, _relleno(const Color(0xFFEC4899)));
    // Lupas: tejido y célula.
    final linea = _trazo(const Color(0xFF94A3B8), 2.5);
    canvas.drawLine(const Offset(114, 162), const Offset(166, 146), linea);
    canvas.drawLine(const Offset(225, 198), const Offset(225, 244), linea);
    canvas.drawPath(
      Path()
        ..moveTo(218, 236)
        ..lineTo(225, 246)
        ..lineTo(232, 236),
      linea,
    );
    const centroTejido = Offset(225, 135);
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: centroTejido, radius: 62)),
    );
    canvas.drawCircle(centroTejido, 62, _relleno(const Color(0xFFF9A8D4)));
    final celdilla = _relleno(const Color(0xFFFCE7F3));
    final nucleo = _relleno(const Color(0xFFA855F7));
    for (var fila = -4; fila <= 4; fila++) {
      for (var col = -4; col <= 4; col++) {
        final c =
            centroTejido +
            Offset(col * 22.0 + (fila.isOdd ? 11 : 0), fila * 19.0);
        canvas.drawCircle(c, 9.5, celdilla);
        canvas.drawCircle(c, 3.2, nucleo);
      }
    }
    canvas.restore();
    canvas.drawCircle(centroTejido, 62, _trazo(const Color(0xFF64748B), 4));
    const centroCelula = Offset(225, 300);
    canvas.drawCircle(centroCelula, 55, _relleno(const Color(0xFFFFFBFE)));
    canvas.drawCircle(centroCelula, 36, _relleno(const Color(0xFFFCE7F3)));
    canvas.drawCircle(centroCelula, 36, _trazo(const Color(0xFFDB2777), 4));
    canvas.drawCircle(
      centroCelula + const Offset(4, -2),
      13,
      _relleno(const Color(0xFFA855F7)),
    );
    canvas.drawCircle(centroCelula, 55, _trazo(const Color(0xFF64748B), 4));
  }

  @override
  bool shouldRepaint(EscenaLinternaPintor oldDelegate) =>
      oldDelegate.dibujo != dibujo;
}

/// La oscuridad sobre la escena, con el círculo de luz y lo ya encontrado.
class OscuridadLinternaPintor extends CustomPainter {
  const OscuridadLinternaPintor({
    required this.herramienta,
    required this.luz,
    required this.radio,
    required this.encendidas,
  });

  final String herramienta;

  /// Centro de la luz, de 0 a 1.
  final Offset luz;

  /// Radio de la luz en proporción al ancho.
  final double radio;

  /// Zonas de lo encontrado, que se quedan encendidas.
  final List<ZonaLinterna> encendidas;

  Color get _oscuridad => switch (herramienta) {
    'rayos' => const Color(0xF2020817),
    'microscopio' => const Color(0xF0111111),
    _ => const Color(0xEB0F172A),
  };

  Color get _aro => switch (herramienta) {
    'rayos' => const Color(0xFF22D3EE),
    'microscopio' => const Color(0xFF94A3B8),
    _ => const Color(0xFFFDE68A),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(rect, Paint()..color = _oscuridad);
    void agujero(Offset centro, double r) {
      canvas.drawCircle(
        centro,
        r,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..shader = RadialGradient(
            colors: const [Colors.black, Colors.black, Colors.transparent],
            stops: const [0, .72, 1],
          ).createShader(Rect.fromCircle(center: centro, radius: r)),
      );
    }

    for (final zona in encendidas) {
      agujero(
        Offset(zona.x * size.width, zona.y * size.height),
        zona.r * size.width * 1.35,
      );
    }
    final centro = Offset(luz.dx * size.width, luz.dy * size.height);
    final r = radio * size.width;
    agujero(centro, r);
    canvas.restore();
    // El aro de la herramienta.
    if (herramienta == 'microscopio') {
      canvas.drawCircle(
        centro,
        r * .98,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = _aro,
      );
      final cruz = Paint()
        ..strokeWidth = 1.2
        ..color = _aro.withValues(alpha: .6);
      canvas.drawLine(
        centro - Offset(r * .25, 0),
        centro + Offset(r * .25, 0),
        cruz,
      );
      canvas.drawLine(
        centro - Offset(0, r * .25),
        centro + Offset(0, r * .25),
        cruz,
      );
    } else {
      canvas.drawCircle(
        centro,
        r * .95,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = _aro.withValues(alpha: .7),
      );
    }
  }

  @override
  bool shouldRepaint(OscuridadLinternaPintor oldDelegate) =>
      oldDelegate.luz != luz ||
      oldDelegate.radio != radio ||
      oldDelegate.herramienta != herramienta ||
      oldDelegate.encendidas.length != encendidas.length;
}

/// Icono de cada herramienta.
IconData iconoHerramienta(String herramienta) => switch (herramienta) {
  'rayos' => Icons.medical_information_rounded,
  'microscopio' => Icons.biotech_rounded,
  _ => Icons.flashlight_on_rounded,
};

/// Miniatura de una escena, para el selector de nivel y los cromos.
class MiniaturaLinterna extends StatelessWidget {
  const MiniaturaLinterna({required this.dibujo, this.alto = 48, super.key});

  final String dibujo;
  final double alto;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(alto * .18),
    child: SizedBox(
      width: alto / aspectoEscenaLinterna,
      height: alto,
      child: CustomPaint(painter: EscenaLinternaPintor(dibujo)),
    ),
  );
}
