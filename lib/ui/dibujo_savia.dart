import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

/// La planta de «El viaje de la savia».
///
/// Enseña en qué punto de la planta estamos (la raíz, el tallo o la hoja) y
/// con flechas qué viaja por ahí: agua que entra, agua que sube, luz, aire o
/// alimento. Cambia con cada reto, como la semilla del laboratorio de
/// germinación. No lleva texto: solo dibujo.
class DibujoViajeSavia extends StatelessWidget {
  const DibujoViajeSavia({
    required this.retoId,
    this.acertado = false,
    this.ocultarPista = false,
    this.alto = 128,
    super.key,
  });

  final String retoId;

  /// Si es true, la planta sale sin marca ni flechas hasta que el niño acierta
  /// (cuando la pregunta es justo «¿en qué parte ocurre?»).
  final bool ocultarPista;

  /// Cuando el niño ya ha acertado, la marca se pone verde.
  final bool acertado;
  final double alto;

  /// Parte de la planta donde pasa lo que se pregunta.
  static String parteDe(String retoId) => switch (retoId) {
    'absorcion-raiz' => 'raiz',
    'subida-xilema' ||
    'ascenso-tallo' ||
    'reparto-floema' ||
    'reparto-planta' => 'tallo',
    _ => 'hoja',
  };

  /// Qué es lo que viaja: agua que entra, agua que sube, luz, aire o alimento.
  static String viajeDe(String retoId) => switch (retoId) {
    'absorcion-raiz' => 'entra',
    'subida-xilema' || 'ascenso-tallo' => 'sube',
    'captura-luz-sol' || 'clorofila-sol' => 'luz',
    'entrada-co2-hoja' || 'estomas-aire' => 'aire',
    _ => 'alimento',
  };

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(retoId),
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      builder: (context, avance, _) {
        return Container(
          key: const Key('dibujo-viaje-savia'),
          height: alto,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.coloresNaturales.borde(const Color(0xFFBAE6FD)),
              width: 2,
            ),
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: _PintorSavia(
              colores: context.coloresNaturales,
              parte: parteDe(retoId),
              viaje: viajeDe(retoId),
              acertado: acertado,
              ocultarPista: ocultarPista,
              avance: avance,
            ),
          ),
        );
      },
    );
  }
}

class _PintorSavia extends CustomPainter {
  final ColoresNaturales colores;
  const _PintorSavia({
    required this.colores,
    required this.parte,
    required this.viaje,
    required this.acertado,
    required this.ocultarPista,
    required this.avance,
  });

  final String parte;
  final String viaje;
  final bool acertado;
  final bool ocultarPista;
  final double avance;

  static const _azul = Color(0xFF0284C7);
  static const _amarillo = Color(0xFFF59E0B);
  static const _dorado = Color(0xFFD97706);
  static const _gris = Color(0xFF64748B);
  static const _verde = Color(0xFF16A34A);

  void _flecha(
    Canvas canvas,
    Offset desde,
    Offset hasta,
    Color color,
    double grosor,
  ) {
    final fin = Offset.lerp(desde, hasta, avance)!;
    final pincel = Paint()
      ..color = color
      ..strokeWidth = grosor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(desde, fin, pincel);
    if (avance < 0.2) return;
    final dir = hasta - desde;
    final angulo = math.atan2(dir.dy, dir.dx);
    final largo = grosor * 3.4;
    for (final giro in [0.5, -0.5]) {
      canvas.drawLine(
        fin,
        fin - Offset(math.cos(angulo + giro), math.sin(angulo + giro)) * largo,
        pincel,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final suelo = h * 0.64;
    final copa = h * 0.30;

    // Cielo y tierra.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, suelo),
      Paint()..color = colores.superficie(const Color(0xFFE0F2FE)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, suelo, w, h - suelo),
      Paint()..color = colores.superficie(const Color(0xFFD6B98C)),
    );

    // Sol.
    final sol = Offset(w * 0.14, h * 0.2);
    canvas.drawCircle(sol, h * 0.09, Paint()..color = const Color(0xFFFACC15));
    final rayo = Paint()
      ..color = const Color(0xFFFACC15)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(sol + dir * (h * 0.12), sol + dir * (h * 0.16), rayo);
    }

    // Marca de «estamos aquí» detrás de la planta.
    final resaltado = switch (parte) {
      'raiz' => Rect.fromCenter(
        center: Offset(cx, suelo + (h - suelo) * 0.5),
        width: w * 0.36,
        height: (h - suelo) * 0.92,
      ),
      'tallo' => Rect.fromCenter(
        center: Offset(cx, (suelo + copa) / 2),
        width: w * 0.16,
        height: suelo - copa,
      ),
      _ => Rect.fromCenter(
        center: Offset(cx, copa),
        width: w * 0.46,
        height: h * 0.34,
      ),
    };
    final mostrarMarca = !ocultarPista || acertado;
    final colorMarca = acertado ? _verde : _amarillo;
    final marco = RRect.fromRectAndRadius(resaltado, const Radius.circular(14));
    if (mostrarMarca) {
      canvas.drawRRect(
        marco,
        Paint()..color = colorMarca.withValues(alpha: 0.22 * avance),
      );
      canvas.drawRRect(
        marco,
        Paint()
          ..color = colorMarca.withValues(alpha: avance)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Raíces.
    final raiz = Paint()
      ..color = const Color(0xFF92400E)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.035;
    final base = Offset(cx, suelo);
    canvas.drawLine(base, Offset(cx, h * 0.93), raiz);
    canvas.drawLine(
      Offset(cx, suelo + h * 0.06),
      Offset(cx - w * 0.11, h * 0.88),
      raiz,
    );
    canvas.drawLine(
      Offset(cx, suelo + h * 0.06),
      Offset(cx + w * 0.11, h * 0.88),
      raiz,
    );

    // Tallo.
    canvas.drawLine(
      base,
      Offset(cx, copa),
      Paint()
        ..color = const Color(0xFF16A34A)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = h * 0.07,
    );

    // Hojas.
    void hoja(Offset centro, double giro, double escala) {
      canvas.save();
      canvas.translate(centro.dx, centro.dy);
      canvas.rotate(giro);
      final r = Rect.fromCenter(
        center: Offset.zero,
        width: w * 0.2 * escala,
        height: h * 0.15 * escala,
      );
      canvas.drawOval(r, Paint()..color = const Color(0xFF22C55E));
      canvas.drawOval(
        r,
        Paint()
          ..color = const Color(0xFF166534)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.restore();
    }

    hoja(Offset(cx - w * 0.13, copa + h * 0.10), -0.5, 1);
    hoja(Offset(cx + w * 0.13, copa + h * 0.02), 0.5, 1);
    hoja(Offset(cx, copa - h * 0.06), math.pi / 2, 0.8);

    // Lo que viaja en este reto.
    if (ocultarPista) {
      // Sin flechas: la pregunta es dónde ocurre.
    } else if (viaje == 'entra') {
      _flecha(
        canvas,
        Offset(cx - w * 0.30, suelo + h * 0.22),
        Offset(cx - w * 0.10, suelo + h * 0.12),
        _azul,
        3.2,
      );
      _flecha(
        canvas,
        Offset(cx + w * 0.30, suelo + h * 0.22),
        Offset(cx + w * 0.10, suelo + h * 0.12),
        _azul,
        3.2,
      );
    } else if (viaje == 'sube') {
      _flecha(
        canvas,
        Offset(cx + w * 0.07, suelo - h * 0.02),
        Offset(cx + w * 0.07, copa + h * 0.04),
        _azul,
        3.2,
      );
    } else if (viaje == 'luz') {
      _flecha(
        canvas,
        Offset(w * 0.26, h * 0.26),
        Offset(cx - w * 0.17, copa + h * 0.06),
        _amarillo,
        3.2,
      );
      _flecha(
        canvas,
        Offset(w * 0.26, h * 0.12),
        Offset(cx - w * 0.08, copa - h * 0.07),
        _amarillo,
        3.2,
      );
    } else if (viaje == 'aire') {
      _flecha(
        canvas,
        Offset(w * 0.88, h * 0.14),
        Offset(cx + w * 0.19, copa),
        _gris,
        3,
      );
      _flecha(
        canvas,
        Offset(cx + w * 0.19, copa + h * 0.10),
        Offset(w * 0.88, h * 0.34),
        _verde,
        3,
      );
    } else {
      _flecha(
        canvas,
        Offset(cx - w * 0.07, copa + h * 0.06),
        Offset(cx - w * 0.07, suelo - h * 0.02),
        _dorado,
        3.2,
      );
      _flecha(
        canvas,
        Offset(cx - w * 0.07, suelo + h * 0.02),
        Offset(cx - w * 0.07, h * 0.90),
        _dorado,
        3.2,
      );
    }

    // Chincheta de «estamos aquí».
    if (!mostrarMarca) return;
    final pin = switch (parte) {
      'raiz' => Offset(cx + w * 0.22, suelo + (h - suelo) * 0.45),
      'tallo' => Offset(cx + w * 0.18, (suelo + copa) / 2),
      _ => Offset(cx + w * 0.30, copa - h * 0.05),
    };
    final radio = h * 0.065;
    canvas.drawCircle(
      pin,
      radio,
      Paint()..color = acertado ? _verde : const Color(0xFFEF4444),
    );
    canvas.drawCircle(
      pin,
      radio,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    if (acertado) {
      final visto = Path()
        ..moveTo(pin.dx - h * 0.03, pin.dy)
        ..lineTo(pin.dx - h * 0.008, pin.dy + h * 0.025)
        ..lineTo(pin.dx + h * 0.035, pin.dy - h * 0.025);
      canvas.drawPath(
        visto,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawCircle(pin, h * 0.022, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorSavia oldDelegate) =>
      oldDelegate.colores != colores ||
      oldDelegate.parte != parte ||
      oldDelegate.viaje != viaje ||
      oldDelegate.acertado != acertado ||
      oldDelegate.ocultarPista != ocultarPista ||
      oldDelegate.avance != avance;
}
