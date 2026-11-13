import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/texto.dart';

/// Alimentos de «Un plato que cuida».
const idsPlato = <String>{
  'plato-manzana',
  'plato-bollo',
  'plato-yogur',
  'plato-chuches',
  'plato-bocadillo',
  'plato-refresco',
  'plato-brocoli',
  'plato-lentejas',
  'plato-arroz',
  'plato-tomate',
  'plato-pescado',
  'plato-pan',
  'plato-cereales',
  'plato-galletitas',
  'plato-patatas',
  'plato-yogur-etiqueta',
  'plato-lentejas-bote',
};

/// Sitios donde se colocan los alimentos.
const idsSitiosPlato = <String>{
  'cada-dia',
  'de-vez-en-cuando',
  'mitad-verdura',
  'cuarto-proteina',
  'cuarto-cereal',
  'etiqueta-azucar',
  'etiqueta-sal',
  'etiqueta-grasa',
  'etiqueta-equilibrada',
};

/// Cromos del juego, cada uno con el dibujo que lo representa.
const cromosPlato = <String, String>{
  'merienda': 'plato-manzana',
  'plato-equilibrado': 'plato-brocoli',
  'etiqueta': 'plato-cereales',
};

class DibujoPlato extends StatelessWidget {
  const DibujoPlato({required this.id, this.tamano = 64, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    // Cada sitio se dibuja con un ejemplo claro de lo que guarda.
    final dibujo = switch (id) {
      'cada-dia' => 'plato-manzana',
      'de-vez-en-cuando' => 'plato-bollo',
      'mitad-verdura' => 'plato-brocoli',
      'cuarto-proteina' => 'plato-pescado',
      'cuarto-cereal' => 'plato-pan',
      final otro => cromosPlato[otro] ?? otro,
    };
    return SizedBox(
      key: ValueKey('dibujo-plato-$id'),
      width: tamano,
      height: tamano,
      child: CustomPaint(painter: _PintorPlato(dibujo)),
    );
  }
}

String? subtituloSitioPlato(String id) => switch (id) {
  'cada-dia' => 'Fruta, lácteos y pan',
  'de-vez-en-cuando' => 'Mucho azúcar o grasa',
  'mitad-verdura' => 'La mitad del plato',
  'cuarto-proteina' => 'Un cuarto: legumbres, huevo, pescado',
  'cuarto-cereal' => 'Un cuarto: pan, arroz, pasta',
  'etiqueta-azucar' => 'Más de 15 g en 100 g',
  'etiqueta-sal' => 'Más de 1,5 g en 100 g',
  'etiqueta-grasa' => 'Más de 20 g en 100 g',
  'etiqueta-equilibrada' => 'Todo por debajo del límite',
  _ => null,
};

Color colorSitioPlato(String id) => switch (id) {
  'cada-dia' || 'etiqueta-equilibrada' => const Color(0xFFDCFCE7),
  'de-vez-en-cuando' => const Color(0xFFFFEDD5),
  'mitad-verdura' => const Color(0xFFECFCCB),
  'cuarto-proteina' => const Color(0xFFFFE4E6),
  'cuarto-cereal' => const Color(0xFFFEF3C7),
  'etiqueta-azucar' => const Color(0xFFFCE7F3),
  'etiqueta-sal' => const Color(0xFFE0F2FE),
  'etiqueta-grasa' => const Color(0xFFFEF9C3),
  _ => const Color(0xFFF6F1E6),
};

Color bordeSitioPlato(String id) => switch (id) {
  'cada-dia' || 'etiqueta-equilibrada' => const Color(0xFF4ADE80),
  'de-vez-en-cuando' => const Color(0xFFFB923C),
  'mitad-verdura' => const Color(0xFF84CC16),
  'cuarto-proteina' => const Color(0xFFFB7185),
  'cuarto-cereal' => const Color(0xFFF59E0B),
  'etiqueta-azucar' => const Color(0xFFF472B6),
  'etiqueta-sal' => const Color(0xFF38BDF8),
  'etiqueta-grasa' => const Color(0xFFEAB308),
  _ => const Color(0xFFD6CFC0),
};

/// Bandeja que se va llenando: «Mi merienda» en Fácil y «Mi plato» en Medio.
/// En Difícil no se muestra, porque allí se leen etiquetas.
class BandejaPlato extends StatelessWidget {
  const BandejaPlato({
    required this.nivel,
    required this.retos,
    required this.resueltos,
    super.key,
  });

  final String nivel;
  final List<Reto> retos;
  final Set<String> resueltos;

  @override
  Widget build(BuildContext context) {
    if (nivel == 'dificil') return const SizedBox.shrink();
    final medio = nivel == 'medio';
    final colocados = [
      for (final r in retos)
        if (resueltos.contains(r.id) && (medio || r.respuesta == 'cada-dia')) r,
    ];
    return Container(
      key: const Key('bandeja-plato'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: context.coloresNaturales.superficie(Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.coloresNaturales.borde(const Color(0xFFD6CFC0)),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _PintorBandeja(
                medio: medio,
                llenos: {for (final r in colocados) r.respuesta},
                cuantos: colocados.length,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Texto(
                  medio ? 'Mi plato' : 'Mi merienda',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: context.coloresNaturales.contenido(
                      Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final r in colocados)
                      DibujoPlato(
                        key: ValueKey('bandeja-plato-${r.id}'),
                        id: r.id,
                        tamano: 28,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PintorBandeja extends CustomPainter {
  _PintorBandeja({
    required this.medio,
    required this.llenos,
    required this.cuantos,
  });

  final bool medio;
  final Set<String> llenos;
  final int cuantos;

  static const _tinta = Color(0xFF1E293B);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * .46;
    final trazo = Paint()
      ..color = _tinta
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .03;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawCircle(c, r, trazo);
    final dentro = Rect.fromCircle(center: c, radius: r * .82);
    if (medio) {
      // La mitad izquierda para verduras y frutas; los dos cuartos de la
      // derecha para proteínas (arriba) y cereales (abajo).
      void sector(String id, double inicio, double barrido, int color) {
        final lleno = llenos.contains(id);
        canvas.drawArc(
          dentro,
          inicio,
          barrido,
          true,
          Paint()..color = lleno ? Color(color) : const Color(0xFFF1F5F9),
        );
      }

      sector('mitad-verdura', math.pi / 2, math.pi, 0xFF86EFAC);
      sector('cuarto-proteina', -math.pi / 2, math.pi / 2, 0xFFFDA4AF);
      sector('cuarto-cereal', 0, math.pi / 2, 0xFFFCD34D);
      final fino = Paint()
        ..color = _tinta
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * .02;
      canvas.drawCircle(c, r * .82, fino);
      canvas.drawLine(
        Offset(c.dx, c.dy - r * .82),
        Offset(c.dx, c.dy + r * .82),
        fino,
      );
      canvas.drawLine(c, Offset(c.dx + r * .82, c.dy), fino);
    } else {
      // Bandeja de merienda: un hueco por cada alimento de cada día.
      canvas.drawCircle(c, r * .82, Paint()..color = const Color(0xFFFEF3C7));
      for (var i = 0; i < 3; i++) {
        final a = -math.pi / 2 + i * 2 * math.pi / 3;
        final p = c + Offset(math.cos(a), math.sin(a)) * r * .42;
        canvas.drawCircle(
          p,
          r * .24,
          Paint()
            ..color = i < cuantos
                ? const Color(0xFF86EFAC)
                : const Color(0xFFFFFBEB),
        );
        canvas.drawCircle(
          p,
          r * .24,
          Paint()
            ..color = const Color(0xFFD6CFC0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * .015,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorBandeja old) =>
      old.medio != medio || old.cuantos != cuantos || old.llenos != llenos;
}

class _PintorPlato extends CustomPainter {
  _PintorPlato(this.id);

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

    void caja(
      double x,
      double y,
      double ancho,
      double alto,
      int color, {
      double radio = .04,
    }) {
      forma(
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * x, h * y, w * ancho, h * alto),
            Radius.circular(w * radio),
          ),
        ),
        color,
      );
    }

    // Etiqueta blanca con tres rayas y una marca de color: la que importa.
    void etiqueta(double x, double y, int marca, {int fila = 0}) {
      caja(x, y, .30, .26, 0xFFFFFFFF, radio: .02);
      for (var i = 0; i < 3; i++) {
        final yy = y + .06 + i * .07;
        linea(x + .05, yy, x + .25, yy, trazo(.02));
        if (i == fila) {
          canvas.drawRect(
            Rect.fromLTWH(w * (x + .18), h * (yy - .025), w * .08, h * .05),
            relleno(marca),
          );
        }
      }
    }

    void bolsa(int color, int franja) {
      forma(
        Path()
          ..moveTo(w * .22, h * .16)
          ..lineTo(w * .78, h * .16)
          ..lineTo(w * .74, h * .50)
          ..lineTo(w * .80, h * .88)
          ..lineTo(w * .20, h * .88)
          ..lineTo(w * .26, h * .50)
          ..close(),
        color,
      );
      for (var i = 0; i < 5; i++) {
        final x = .26 + i * .12;
        linea(x, .16, x, .22, trazo(.02));
      }
      canvas.drawRect(
        Rect.fromLTWH(w * .26, h * .36, w * .48, h * .12),
        relleno(franja),
      );
    }

    switch (id) {
      case 'plato-manzana':
        forma(
          Path()
            ..moveTo(w * .50, h * .30)
            ..cubicTo(w * .20, h * .16, w * .06, h * .52, w * .30, h * .82)
            ..cubicTo(w * .40, h * .92, w * .46, h * .86, w * .50, h * .84)
            ..cubicTo(w * .54, h * .86, w * .60, h * .92, w * .70, h * .82)
            ..cubicTo(w * .94, h * .52, w * .80, h * .16, w * .50, h * .30)
            ..close(),
          0xFFEF4444,
        );
        linea(.50, .30, .54, .14, trazo(.04));
        forma(
          Path()
            ..moveTo(w * .54, h * .20)
            ..quadraticBezierTo(w * .70, h * .06, w * .80, h * .16)
            ..quadraticBezierTo(w * .68, h * .28, w * .54, h * .20)
            ..close(),
          0xFF4ADE80,
        );
        circulo(.34, .44, .05, 0xFFFECACA, linea: false);
      case 'plato-bollo':
        // Bollo con glaseado y virutas de colores.
        forma(
          Path()..addOval(Rect.fromLTWH(w * .12, h * .36, w * .76, h * .44)),
          0xFFD97706,
        );
        forma(
          Path()
            ..moveTo(w * .16, h * .52)
            ..quadraticBezierTo(w * .20, h * .30, w * .50, h * .30)
            ..quadraticBezierTo(w * .80, h * .30, w * .84, h * .52)
            ..quadraticBezierTo(w * .70, h * .62, w * .58, h * .54)
            ..quadraticBezierTo(w * .46, h * .64, w * .34, h * .56)
            ..quadraticBezierTo(w * .24, h * .62, w * .16, h * .52)
            ..close(),
          0xFFF9A8D4,
        );
        for (final (x, y, c) in const [
          (.32, .40, 0xFF38BDF8),
          (.46, .36, 0xFFFACC15),
          (.60, .42, 0xFF4ADE80),
          (.70, .38, 0xFF38BDF8),
        ]) {
          linea(x, y, x + .05, y + .02, trazo(.035)..color = Color(c));
        }
      case 'plato-yogur' || 'plato-yogur-etiqueta':
        forma(
          Path()
            ..moveTo(w * .24, h * .26)
            ..lineTo(w * .76, h * .26)
            ..lineTo(w * .68, h * .88)
            ..lineTo(w * .32, h * .88)
            ..close(),
          0xFFFFFFFF,
        );
        caja(.18, .16, .64, .12, 0xFFE0F2FE, radio: .02);
        if (id == 'plato-yogur-etiqueta') {
          etiqueta(.35, .46, 0xFF22C55E);
        } else {
          circulo(.50, .58, .12, 0xFFBAE6FD);
        }
      case 'plato-chuches':
        for (final (x, y, c) in const [
          (.30, .36, 0xFFF472B6),
          (.62, .30, 0xFFFACC15),
          (.44, .62, 0xFF4ADE80),
          (.72, .62, 0xFFA78BFA),
        ]) {
          // Caramelo con su envoltorio retorcido a los lados.
          forma(
            Path()
              ..moveTo(w * (x - .19), h * (y - .07))
              ..lineTo(w * (x - .10), h * y)
              ..lineTo(w * (x - .19), h * (y + .07))
              ..close(),
            c,
            grosor: .025,
          );
          forma(
            Path()
              ..moveTo(w * (x + .19), h * (y - .07))
              ..lineTo(w * (x + .10), h * y)
              ..lineTo(w * (x + .19), h * (y + .07))
              ..close(),
            c,
            grosor: .025,
          );
          circulo(x, y, .10, c);
        }
      case 'plato-bocadillo':
        forma(
          Path()
            ..moveTo(w * .10, h * .62)
            ..quadraticBezierTo(w * .10, h * .30, w * .50, h * .30)
            ..quadraticBezierTo(w * .90, h * .30, w * .90, h * .62)
            ..close(),
          0xFFF59E0B,
        );
        caja(.12, .60, .76, .08, 0xFF4ADE80, radio: .03);
        caja(.12, .66, .76, .08, 0xFFF87171, radio: .03);
        caja(.10, .72, .80, .14, 0xFFF59E0B);
        circulo(.36, .42, .025, 0xFFFDE68A, linea: false);
        circulo(.58, .38, .025, 0xFFFDE68A, linea: false);
      case 'plato-refresco':
        caja(.30, .16, .40, .72, 0xFFDC2626, radio: .06);
        caja(.30, .40, .40, .20, 0xFFFFFFFF, radio: .0);
        linea(.38, .10, .44, .16, trazo(.03));
        circulo(.36, .70, .03, 0xFFFECACA, linea: false);
        circulo(.44, .78, .02, 0xFFFECACA, linea: false);
      case 'plato-brocoli':
        forma(
          Path()
            ..moveTo(w * .42, h * .50)
            ..lineTo(w * .38, h * .88)
            ..lineTo(w * .62, h * .88)
            ..lineTo(w * .58, h * .50)
            ..close(),
          0xFF86EFAC,
        );
        circulo(.32, .42, .16, 0xFF16A34A);
        circulo(.68, .42, .16, 0xFF16A34A);
        circulo(.50, .28, .18, 0xFF22C55E);
        circulo(.44, .24, .04, 0xFF86EFAC, linea: false);
      case 'plato-lentejas' || 'plato-lentejas-bote':
        if (id == 'plato-lentejas-bote') {
          caja(.22, .20, .56, .68, 0xFFFEF3C7, radio: .08);
          caja(.18, .12, .64, .12, 0xFF92400E, radio: .03);
          etiqueta(.35, .54, 0xFF22C55E, fila: 1);
          for (final (x, y) in const [(.32, .34), (.46, .40), (.60, .32)]) {
            circulo(x, y, .045, 0xFFB45309, linea: false);
          }
        } else {
          forma(
            Path()
              ..moveTo(w * .10, h * .48)
              ..quadraticBezierTo(w * .14, h * .86, w * .50, h * .86)
              ..quadraticBezierTo(w * .86, h * .86, w * .90, h * .48)
              ..close(),
            0xFFFFFFFF,
          );
          forma(
            Path()..addOval(Rect.fromLTWH(w * .14, h * .40, w * .72, h * .16)),
            0xFFB45309,
          );
          for (final (x, y) in const [(.30, .47), (.46, .45), (.62, .48)]) {
            circulo(x, y, .03, 0xFF78350F, linea: false);
          }
          circulo(.70, .44, .04, 0xFFF97316, linea: false);
        }
      case 'plato-arroz':
        forma(
          Path()
            ..moveTo(w * .10, h * .50)
            ..quadraticBezierTo(w * .14, h * .88, w * .50, h * .88)
            ..quadraticBezierTo(w * .86, h * .88, w * .90, h * .50)
            ..close(),
          0xFF7DD3FC,
        );
        forma(
          Path()
            ..moveTo(w * .14, h * .50)
            ..quadraticBezierTo(w * .50, h * .14, w * .86, h * .50)
            ..close(),
          0xFFFFFFFF,
        );
        for (final (x, y) in const [(.36, .40), (.50, .32), (.62, .42)]) {
          linea(x, y, x + .04, y - .02, trazo(.02));
        }
      case 'plato-tomate':
        circulo(.50, .56, .32, 0xFFEF4444);
        forma(
          Path()
            ..moveTo(w * .50, h * .26)
            ..lineTo(w * .34, h * .20)
            ..lineTo(w * .44, h * .30)
            ..lineTo(w * .50, h * .18)
            ..lineTo(w * .56, h * .30)
            ..lineTo(w * .66, h * .20)
            ..close(),
          0xFF22C55E,
          grosor: .025,
        );
        circulo(.38, .48, .05, 0xFFFECACA, linea: false);
      case 'plato-pescado':
        forma(
          Path()
            ..moveTo(w * .14, h * .52)
            ..quadraticBezierTo(w * .40, h * .22, w * .70, h * .44)
            ..lineTo(w * .90, h * .30)
            ..lineTo(w * .86, h * .52)
            ..lineTo(w * .90, h * .74)
            ..lineTo(w * .70, h * .60)
            ..quadraticBezierTo(w * .40, h * .82, w * .14, h * .52)
            ..close(),
          0xFF38BDF8,
        );
        circulo(.28, .48, .035, 0xFF1E293B, linea: false);
        linea(.40, .40, .40, .64, trazo(.02));
      case 'plato-pan':
        forma(
          Path()
            ..moveTo(w * .08, h * .62)
            ..quadraticBezierTo(w * .14, h * .30, w * .50, h * .30)
            ..quadraticBezierTo(w * .86, h * .30, w * .92, h * .62)
            ..quadraticBezierTo(w * .50, h * .78, w * .08, h * .62)
            ..close(),
          0xFFD97706,
        );
        for (final x in const [.34, .50, .66]) {
          linea(x - .04, .48, x + .04, .38, trazo(.025));
        }
      case 'plato-cereales':
        caja(.24, .12, .52, .78, 0xFFFBBF24);
        circulo(.50, .40, .14, 0xFFFFFFFF);
        for (final (x, y) in const [(.46, .38), (.54, .42)]) {
          circulo(x, y, .035, 0xFFD97706, linea: false);
        }
        etiqueta(.35, .58, 0xFFF472B6);
      case 'plato-galletitas':
        bolsa(0xFF38BDF8, 0xFFFFFFFF);
        for (final (x, y) in const [(.38, .62), (.56, .66), (.48, .76)]) {
          caja(x - .06, y - .04, .12, .08, 0xFFFDE68A, radio: .02);
        }
        for (final (x, y) in const [(.36, .42), (.48, .40), (.62, .43)]) {
          circulo(x, y, .015, 0xFF1E293B, linea: false);
        }
      case 'plato-patatas':
        bolsa(0xFFF97316, 0xFFFDE047);
        for (final (x, y) in const [(.38, .64), (.56, .62), (.48, .76)]) {
          forma(
            Path()..addOval(
              Rect.fromCenter(
                center: Offset(w * x, h * y),
                width: w * .16,
                height: h * .10,
              ),
            ),
            0xFFFDE68A,
            grosor: .02,
          );
        }
      case 'etiqueta-azucar':
        // Terrón de azúcar.
        forma(
          Path()
            ..moveTo(w * .22, h * .40)
            ..lineTo(w * .50, h * .26)
            ..lineTo(w * .78, h * .40)
            ..lineTo(w * .78, h * .70)
            ..lineTo(w * .50, h * .84)
            ..lineTo(w * .22, h * .70)
            ..close(),
          0xFFFFFFFF,
        );
        linea(.22, .40, .50, .54);
        linea(.50, .54, .78, .40);
        linea(.50, .54, .50, .84);
      case 'etiqueta-sal':
        // Salero.
        forma(
          Path()
            ..moveTo(w * .30, h * .36)
            ..quadraticBezierTo(w * .50, h * .16, w * .70, h * .36)
            ..lineTo(w * .74, h * .86)
            ..lineTo(w * .26, h * .86)
            ..close(),
          0xFFF1F5F9,
        );
        for (final (x, y) in const [(.44, .28), (.50, .26), (.56, .28)]) {
          circulo(x, y, .015, 0xFF1E293B, linea: false);
        }
        caja(.26, .56, .48, .10, 0xFF38BDF8, radio: .0);
      case 'etiqueta-grasa':
        // Gota de aceite.
        forma(
          Path()
            ..moveTo(w * .50, h * .12)
            ..quadraticBezierTo(w * .86, h * .52, w * .74, h * .74)
            ..quadraticBezierTo(w * .50, h * .98, w * .26, h * .74)
            ..quadraticBezierTo(w * .14, h * .52, w * .50, h * .12)
            ..close(),
          0xFFFACC15,
        );
        circulo(.40, .62, .05, 0xFFFEF9C3, linea: false);
      case 'etiqueta-equilibrada':
        caja(.20, .18, .60, .66, 0xFFFFFFFF, radio: .04);
        for (var i = 0; i < 3; i++) {
          final y = .32 + i * .14;
          linea(.30, y, .56, y, trazo(.025));
        }
        circulo(.68, .72, .16, 0xFF22C55E);
        canvas.drawPath(
          Path()
            ..moveTo(w * .60, h * .72)
            ..lineTo(w * .66, h * .78)
            ..lineTo(w * .76, h * .66),
          trazo(.04)..color = const Color(0xFFFFFFFF),
        );
      default:
        circulo(.50, .50, .30, 0xFFE2E8F0);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPlato oldDelegate) =>
      oldDelegate.id != id;
}
