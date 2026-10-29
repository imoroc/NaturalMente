import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tarjetas de «¿Vivo o no vivo?».
const idsVivo = <String>{
  'vivo-gato',
  'vivo-piedra',
  'vivo-arbol',
  'vivo-agua',
  'vivo-nube',
  'vivo-mariquita',
  'vivo-semilla',
  'vivo-seta',
  'vivo-fuego',
  'vivo-robot',
  'vivo-musgo',
  'vivo-cristal',
  'vivo-coral',
  'vivo-helecho',
  'vivo-champinon',
  'vivo-levadura',
  'vivo-bacteria',
  'vivo-paramecio',
};

/// Grupos donde se sueltan las tarjetas.
const idsSitiosVivo = <String>{
  'vivo',
  'no-vivo',
  'reino-animal',
  'reino-plantas',
  'reino-hongos',
  'reino-diminutos',
};

/// Cromos del juego, cada uno con el dibujo que lo representa.
const cromosVivo = <String, String>{
  'ser-vivo': 'vivo-mariquita',
  'funciones-vitales': 'vivo-semilla',
  'reinos': 'vivo-champinon',
};

class DibujoVivo extends StatelessWidget {
  const DibujoVivo({required this.id, this.tamano = 64, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    // Cada grupo se dibuja con un ejemplo claro de lo que guarda.
    final dibujo = switch (id) {
      'vivo' => 'vivo-arbol',
      'no-vivo' => 'vivo-piedra',
      'reino-animal' => 'vivo-gato',
      'reino-plantas' => 'vivo-helecho',
      'reino-hongos' => 'vivo-champinon',
      'reino-diminutos' => 'vivo-paramecio',
      final otro => cromosVivo[otro] ?? otro,
    };
    return SizedBox(
      key: ValueKey('dibujo-vivo-$id'),
      width: tamano,
      height: tamano,
      child: CustomPaint(painter: _PintorVivo(dibujo)),
    );
  }
}

String? subtituloSitioVivo(String id) => switch (id) {
  'vivo' => 'Nace, se alimenta y crece',
  'no-vivo' => 'No nace ni se alimenta',
  'reino-animal' => 'Comen otros seres vivos y se desplazan',
  'reino-plantas' => 'Fabrican su alimento con la luz',
  'reino-hongos' => 'Setas, mohos y levaduras',
  'reino-diminutos' => 'Solo se ven al microscopio',
  _ => null,
};

Color colorSitioVivo(String id) => switch (id) {
  'vivo' => const Color(0xFFDCFCE7),
  'no-vivo' => const Color(0xFFF1F5F9),
  'reino-animal' => const Color(0xFFFFEDD5),
  'reino-plantas' => const Color(0xFFECFCCB),
  'reino-hongos' => const Color(0xFFFEF3C7),
  'reino-diminutos' => const Color(0xFFE0F2FE),
  _ => const Color(0xFFF6F1E6),
};

Color bordeSitioVivo(String id) => switch (id) {
  'vivo' => const Color(0xFF4ADE80),
  'no-vivo' => const Color(0xFF94A3B8),
  'reino-animal' => const Color(0xFFFB923C),
  'reino-plantas' => const Color(0xFF84CC16),
  'reino-hongos' => const Color(0xFFD97706),
  'reino-diminutos' => const Color(0xFF38BDF8),
  _ => const Color(0xFFD6CFC0),
};

class _PintorVivo extends CustomPainter {
  _PintorVivo(this.id);

  final String id;

  static const _tinta = Color(0xFF1E293B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Paint trazo([double grosor = .035]) => Paint()
      ..color = _tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * grosor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final borde = trazo();
    Paint relleno(int color) => Paint()..color = Color(color);

    void forma(Path path, int color, {double grosor = .035}) {
      canvas.drawPath(path, relleno(color));
      canvas.drawPath(path, trazo(grosor));
    }

    void circulo(double x, double y, double r, int color, {bool linea = true}) {
      canvas.drawCircle(Offset(w * x, h * y), w * r, relleno(color));
      if (linea) canvas.drawCircle(Offset(w * x, h * y), w * r, borde);
    }

    void linea(double x1, double y1, double x2, double y2, [Paint? p]) => canvas
        .drawLine(Offset(w * x1, h * y1), Offset(w * x2, h * y2), p ?? borde);

    switch (id) {
      case 'vivo-gato':
        // Cuerpo, cola enroscada y cabeza con orejas.
        canvas.drawPath(
          Path()
            ..moveTo(w * .70, h * .76)
            ..quadraticBezierTo(w * .96, h * .72, w * .86, h * .46),
          trazo(.06),
        );
        forma(
          Path()..addOval(Rect.fromLTWH(w * .22, h * .50, w * .52, h * .36)),
          0xFFF59E0B,
        );
        forma(
          Path()
            ..moveTo(w * .20, h * .30)
            ..lineTo(w * .26, h * .10)
            ..lineTo(w * .38, h * .24)
            ..lineTo(w * .50, h * .10)
            ..lineTo(w * .56, h * .30)
            ..quadraticBezierTo(w * .62, h * .56, w * .38, h * .58)
            ..quadraticBezierTo(w * .14, h * .56, w * .20, h * .30)
            ..close(),
          0xFFFBBF24,
        );
        circulo(.30, .36, .035, 0xFF1E293B, linea: false);
        circulo(.46, .36, .035, 0xFF1E293B, linea: false);
        circulo(.38, .45, .025, 0xFFF472B6, linea: false);
      case 'vivo-piedra':
        forma(
          Path()
            ..moveTo(w * .12, h * .78)
            ..quadraticBezierTo(w * .10, h * .46, w * .36, h * .34)
            ..quadraticBezierTo(w * .62, h * .24, w * .82, h * .44)
            ..quadraticBezierTo(w * .96, h * .66, w * .86, h * .80)
            ..close(),
          0xFF94A3B8,
        );
        linea(.40, .50, .52, .58);
        circulo(.66, .52, .03, 0xFF64748B, linea: false);
      case 'vivo-arbol':
        forma(
          Path()..addRect(Rect.fromLTWH(w * .43, h * .52, w * .14, h * .38)),
          0xFF92400E,
        );
        circulo(.50, .36, .26, 0xFF22C55E);
        circulo(.38, .28, .06, 0xFF86EFAC, linea: false);
      case 'vivo-agua':
        forma(
          Path()
            ..moveTo(w * .50, h * .08)
            ..quadraticBezierTo(w * .86, h * .52, w * .74, h * .74)
            ..quadraticBezierTo(w * .50, h * .98, w * .26, h * .74)
            ..quadraticBezierTo(w * .14, h * .52, w * .50, h * .08)
            ..close(),
          0xFF38BDF8,
        );
        circulo(.40, .62, .05, 0xFFE0F2FE, linea: false);
      case 'vivo-nube':
        final nube = Path()
          ..addOval(Rect.fromLTWH(w * .10, h * .40, w * .36, h * .30))
          ..addOval(Rect.fromLTWH(w * .28, h * .24, w * .40, h * .40))
          ..addOval(Rect.fromLTWH(w * .52, h * .38, w * .36, h * .32));
        canvas.drawPath(nube, borde..strokeWidth = w * .07);
        canvas.drawPath(nube, relleno(0xFFE2E8F0));
      case 'vivo-mariquita':
        forma(
          Path()..addOval(Rect.fromLTWH(w * .20, h * .30, w * .60, h * .56)),
          0xFFEF4444,
        );
        linea(.50, .32, .50, .86);
        circulo(.50, .26, .13, 0xFF1E293B);
        for (final (x, y) in const [
          (.35, .48),
          (.65, .48),
          (.36, .70),
          (.64, .70),
        ]) {
          circulo(x, y, .055, 0xFF1E293B, linea: false);
        }
        circulo(.45, .23, .025, 0xFFFFFFFF, linea: false);
        circulo(.55, .23, .025, 0xFFFFFFFF, linea: false);
      case 'vivo-semilla':
        forma(
          Path()..addOval(Rect.fromLTWH(w * .22, h * .46, w * .56, h * .40)),
          0xFFB45309,
        );
        canvas.drawPath(
          Path()
            ..moveTo(w * .50, h * .48)
            ..quadraticBezierTo(w * .46, h * .32, w * .52, h * .20),
          borde,
        );
        forma(
          Path()
            ..moveTo(w * .52, h * .22)
            ..quadraticBezierTo(w * .74, h * .06, w * .82, h * .22)
            ..quadraticBezierTo(w * .66, h * .32, w * .52, h * .22)
            ..close(),
          0xFF4ADE80,
        );
      case 'vivo-seta' || 'vivo-champinon':
        final champinon = id == 'vivo-champinon';
        forma(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * .38, h * .44, w * .24, h * .42),
              Radius.circular(w * .08),
            ),
          ),
          0xFFFEF3C7,
        );
        forma(
          Path()
            ..moveTo(w * .12, h * .50)
            ..quadraticBezierTo(w * .14, h * .12, w * .50, h * .12)
            ..quadraticBezierTo(w * .86, h * .12, w * .88, h * .50)
            ..close(),
          champinon ? 0xFFF5F5F4 : 0xFFDC2626,
        );
        if (!champinon) {
          circulo(.34, .32, .05, 0xFFFFFFFF, linea: false);
          circulo(.60, .24, .045, 0xFFFFFFFF, linea: false);
          circulo(.70, .40, .04, 0xFFFFFFFF, linea: false);
        }
      case 'vivo-fuego':
        forma(
          Path()
            ..moveTo(w * .50, h * .08)
            ..quadraticBezierTo(w * .86, h * .44, w * .76, h * .70)
            ..quadraticBezierTo(w * .66, h * .92, w * .50, h * .90)
            ..quadraticBezierTo(w * .30, h * .92, w * .24, h * .70)
            ..quadraticBezierTo(w * .18, h * .48, w * .36, h * .32)
            ..quadraticBezierTo(w * .40, h * .48, w * .46, h * .46)
            ..quadraticBezierTo(w * .40, h * .26, w * .50, h * .08)
            ..close(),
          0xFFF97316,
        );
        canvas.drawPath(
          Path()
            ..moveTo(w * .50, h * .52)
            ..quadraticBezierTo(w * .66, h * .70, w * .58, h * .82)
            ..quadraticBezierTo(w * .50, h * .88, w * .42, h * .82)
            ..quadraticBezierTo(w * .36, h * .68, w * .50, h * .52)
            ..close(),
          relleno(0xFFFDE047),
        );
      case 'vivo-robot':
        linea(.50, .16, .50, .26);
        circulo(.50, .13, .04, 0xFFEF4444);
        forma(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * .26, h * .26, w * .48, h * .30),
              Radius.circular(w * .08),
            ),
          ),
          0xFF94A3B8,
        );
        circulo(.40, .40, .05, 0xFF38BDF8);
        circulo(.60, .40, .05, 0xFF38BDF8);
        forma(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * .30, h * .58, w * .40, h * .30),
              Radius.circular(w * .06),
            ),
          ),
          0xFF64748B,
        );
        // Las pilas, a la vista.
        forma(
          Path()..addRect(Rect.fromLTWH(w * .42, h * .66, w * .16, h * .10)),
          0xFFFACC15,
        );
      case 'vivo-musgo':
        forma(
          Path()
            ..moveTo(w * .10, h * .84)
            ..quadraticBezierTo(w * .12, h * .50, w * .50, h * .48)
            ..quadraticBezierTo(w * .88, h * .50, w * .90, h * .84)
            ..close(),
          0xFF94A3B8,
        );
        for (var i = 0; i < 7; i++) {
          circulo(.18 + i * .107, i.isEven ? .46 : .50, .09, 0xFF16A34A);
        }
      case 'vivo-cristal':
        for (final (x, y, lado, color) in const [
          (.16, .44, .34, 0xFFF8FAFC),
          (.46, .26, .38, 0xFFE0F2FE),
          (.34, .58, .28, 0xFFF1F5F9),
        ]) {
          forma(
            Path()..addRect(Rect.fromLTWH(w * x, h * y, w * lado, h * lado)),
            color,
          );
        }
        linea(
          .52,
          .32,
          .60,
          .40,
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..strokeWidth = w * .03,
        );
      case 'vivo-coral':
        final ramas = Path()
          ..moveTo(w * .50, h * .90)
          ..lineTo(w * .50, h * .40)
          ..moveTo(w * .50, h * .64)
          ..quadraticBezierTo(w * .26, h * .58, w * .24, h * .30)
          ..moveTo(w * .50, h * .58)
          ..quadraticBezierTo(w * .76, h * .54, w * .76, h * .24)
          ..moveTo(w * .50, h * .40)
          ..lineTo(w * .44, h * .16);
        canvas.drawPath(ramas, trazo(.16));
        canvas.drawPath(
          ramas,
          Paint()
            ..color = const Color(0xFFFB7185)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * .10
            ..strokeCap = StrokeCap.round,
        );
        for (final (x, y) in const [(.24, .30), (.76, .24), (.44, .16)]) {
          circulo(x, y, .04, 0xFFFFF1F2, linea: false);
        }
      case 'vivo-helecho':
        canvas.drawPath(
          Path()
            ..moveTo(w * .50, h * .92)
            ..quadraticBezierTo(w * .46, h * .44, w * .62, h * .10),
          borde,
        );
        for (var i = 0; i < 6; i++) {
          final t = i / 6;
          final y = .82 - t * .66;
          final x = .48 + t * .10;
          final largo = .26 - t * .14;
          for (final lado in const [-1, 1]) {
            forma(
              Path()
                ..moveTo(w * x, h * y)
                ..quadraticBezierTo(
                  w * (x + lado * largo * .6),
                  h * (y - .10),
                  w * (x + lado * largo),
                  h * (y - .02),
                )
                ..quadraticBezierTo(
                  w * (x + lado * largo * .5),
                  h * (y + .04),
                  w * x,
                  h * y,
                )
                ..close(),
              0xFF22C55E,
              grosor: .022,
            );
          }
        }
      case 'vivo-levadura':
        // Una barra de pan y las burbujas que la hacen subir.
        forma(
          Path()
            ..moveTo(w * .10, h * .80)
            ..quadraticBezierTo(w * .10, h * .40, w * .50, h * .40)
            ..quadraticBezierTo(w * .90, h * .40, w * .90, h * .80)
            ..close(),
          0xFFF59E0B,
        );
        for (final x in const [.34, .50, .66]) {
          linea(x - .04, .52, x + .04, .62);
        }
        for (final (x, y, r) in const [
          (.30, .22, .07),
          (.52, .14, .05),
          (.70, .26, .06),
        ]) {
          circulo(x, y, r, 0xFFFEF9C3);
        }
      case 'vivo-bacteria':
        for (var i = 0; i < 3; i++) {
          final y = .42 + i * .07;
          canvas.drawPath(
            Path()
              ..moveTo(w * .74, h * y)
              ..quadraticBezierTo(
                w * .86,
                h * (y - .06),
                w * .94,
                h * (y + .04),
              ),
            trazo(.02),
          );
        }
        forma(
          Path()..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(w * .20, h * .34, w * .56, h * .30),
              Radius.circular(w * .15),
            ),
          ),
          0xFFA78BFA,
        );
        circulo(.40, .48, .05, 0xFF7C3AED, linea: false);
        circulo(.56, .46, .035, 0xFFDDD6FE, linea: false);
      case 'vivo-paramecio':
        // Pelitos alrededor: con ellos nada.
        final centro = Offset(w * .50, h * .50);
        for (var i = 0; i < 18; i++) {
          final a = i / 18 * 2 * math.pi;
          final dentro = Offset(math.cos(a) * w * .34, math.sin(a) * h * .22);
          final fuera = Offset(math.cos(a) * w * .43, math.sin(a) * h * .30);
          canvas.drawLine(centro + dentro, centro + fuera, trazo(.018));
        }
        forma(
          Path()
            ..moveTo(w * .14, h * .50)
            ..quadraticBezierTo(w * .30, h * .24, w * .62, h * .28)
            ..quadraticBezierTo(w * .90, h * .32, w * .86, h * .52)
            ..quadraticBezierTo(w * .80, h * .74, w * .48, h * .72)
            ..quadraticBezierTo(w * .18, h * .72, w * .14, h * .50)
            ..close(),
          0xFF7DD3FC,
        );
        circulo(.44, .48, .07, 0xFF0369A1, linea: false);
        circulo(.66, .52, .035, 0xFFE0F2FE, linea: false);
      default:
        circulo(.50, .50, .30, 0xFFE2E8F0);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorVivo oldDelegate) => oldDelegate.id != id;
}
