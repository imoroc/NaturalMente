import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/modelo/carrera.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/tema.dart';

// Dibujos de «Carrera de relevos»: los corredores, la lupa de Difícil y el
// fondo de cada tramo de la pista.

/// Animales que ya están dibujados para el santuario y no en los juegos nuevos.
const _delSantuario = {'serpiente', 'pinguino', 'delfin'};

class DibujoCorredor extends StatelessWidget {
  const DibujoCorredor({required this.id, this.tamano = 64, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    if (_delSantuario.contains(id)) {
      return SizedBox(
        width: tamano,
        height: tamano,
        child: FittedBox(
          fit: BoxFit.contain,
          child: SpriteEspecieSantuario(id: id, tamano: tamano),
        ),
      );
    }
    return DibujoNuevoJuego(id: id, tamano: tamano);
  }
}

/// Un trozo del dibujo ampliado dentro de un círculo, como si se mirara con
/// la lupa. Solo deja ver la parte del cuerpo que importa.
class LupaParte extends StatelessWidget {
  const LupaParte({
    required this.dibujo,
    required this.lupa,
    this.tamano = 72,
    super.key,
  });

  final String dibujo;
  final LupaCorredor lupa;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final grande = tamano * lupa.zoom;
    final colores = context.coloresNaturales;
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colores.superficie(const Color(0xFFF8FAFC)),
        border: Border.all(
          color: colores.borde(const Color(0xFF475569)),
          width: 3.5,
        ),
      ),
      child: ClipOval(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: tamano / 2 - lupa.x * grande,
              top: tamano / 2 - lupa.y * grande,
              width: grande,
              height: grande,
              child: DibujoCorredor(id: dibujo, tamano: grande),
            ),
            // Brillo del cristal.
            Positioned(
              left: tamano * .16,
              top: tamano * .12,
              child: Container(
                width: tamano * .26,
                height: tamano * .12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(tamano),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paisaje del tramo: cielo, prado, agua, cuesta, piedras o túnel.
class FondoTramo extends StatelessWidget {
  const FondoTramo({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PintorTramo(id, oscuro: context.coloresNaturales.oscuro),
    );
  }
}

/// Icono pequeño del movimiento que pide el tramo.
IconData iconoTramo(String id) => switch (id) {
  'vuela' => Icons.cloud_rounded,
  'anda' => Icons.grass_rounded,
  'nada' => Icons.waves_rounded,
  'trepa' => Icons.terrain_rounded,
  'salta' => Icons.water_drop_rounded,
  'repta' => Icons.circle_outlined,
  _ => Icons.flag_rounded,
};

class _PintorTramo extends CustomPainter {
  const _PintorTramo(this.id, {required this.oscuro});

  final String id;
  final bool oscuro;

  Color _c(int valor) {
    final color = Color(valor);
    return oscuro ? Color.lerp(color, const Color(0xFF0F172A), .55)! : color;
  }

  Paint _p(int valor) => Paint()
    ..color = _c(valor)
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    switch (id) {
      case 'vuela':
        canvas.drawRect(
          rect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_c(0xFF93C5FD), _c(0xFFE0F2FE)],
            ).createShader(rect),
        );
        for (final (x, y, r) in [(.18, .4, .11), (.5, .62, .08)]) {
          final nube = _p(0xFFFFFFFF);
          canvas.drawCircle(Offset(w * x, h * y), h * r * 1.6, nube);
          canvas.drawCircle(
            Offset(w * x + h * r * 1.5, h * y + 3),
            h * r * 1.2,
            nube,
          );
          canvas.drawCircle(
            Offset(w * x - h * r * 1.4, h * y + 4),
            h * r,
            nube,
          );
        }
      case 'anda':
        canvas.drawRect(rect, _p(0xFFD9F99D));
        canvas.drawRect(Rect.fromLTWH(0, h * .7, w, h * .3), _p(0xFFA3E635));
        final hierba = Paint()
          ..color = _c(0xFF4D7C0F)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        for (var x = 10.0; x < w; x += 26) {
          final base = Offset(x, h * .78);
          canvas.drawLine(base, base.translate(-3, -9), hierba);
          canvas.drawLine(base, base.translate(3, -11), hierba);
        }
      case 'nada':
        canvas.drawRect(rect, _p(0xFF7DD3FC));
        final ola = Paint()
          ..color = _c(0xFFE0F2FE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round;
        for (final y in [.3, .62]) {
          final camino = Path()..moveTo(0, h * y);
          for (var x = 0.0; x < w; x += 24) {
            camino.quadraticBezierTo(x + 6, h * y - 5, x + 12, h * y);
            camino.quadraticBezierTo(x + 18, h * y + 5, x + 24, h * y);
          }
          canvas.drawPath(camino, ola);
        }
      case 'trepa':
        canvas.drawRect(rect, _p(0xFFF5F5F4));
        final roca = Path()
          ..moveTo(0, h)
          ..lineTo(w * .55, h * .1)
          ..lineTo(w * .7, h * .25)
          ..lineTo(w, 0)
          ..lineTo(w, h)
          ..close();
        canvas.drawPath(roca, _p(0xFFA8A29E));
        final grieta = Paint()
          ..color = _c(0xFF78716C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(w * .45, h * .6),
          Offset(w * .55, h * .85),
          grieta,
        );
        canvas.drawLine(
          Offset(w * .78, h * .35),
          Offset(w * .72, h * .6),
          grieta,
        );
      case 'salta':
        canvas.drawRect(rect, _p(0xFFFEF3C7));
        for (final (x, ancho) in [(.12, .16), (.42, .18), (.7, .12)]) {
          canvas.drawOval(
            Rect.fromLTWH(w * x, h * .58, w * ancho, h * .26),
            _p(0xFF93C5FD),
          );
        }
        for (final x in [.32, .62, .86]) {
          canvas.drawOval(
            Rect.fromLTWH(w * x, h * .52, h * .28, h * .2),
            _p(0xFF94A3B8),
          );
        }
      case 'repta':
        canvas.drawRect(rect, _p(0xFFD6B48A));
        final tunel = Path()
          ..moveTo(0, h)
          ..lineTo(0, h * .55)
          ..quadraticBezierTo(w * .5, h * .25, w, h * .55)
          ..lineTo(w, h)
          ..close();
        canvas.drawPath(tunel, _p(0xFF7C4A1E));
        final piedras = _p(0xFFB08968);
        for (var x = 14.0; x < w; x += 38) {
          canvas.drawCircle(Offset(x, h * .2 + (x % 3) * 3), 3.5, piedras);
        }
      default:
        canvas.drawRect(rect, _p(0xFFF1F5F9));
    }
    // Línea de meta del tramo.
    final meta = Paint()
      ..color = _c(0xFFFFFFFF).withValues(alpha: .8)
      ..strokeWidth = 3;
    for (var y = 0.0; y < h; y += 10) {
      canvas.drawLine(
        Offset(w - 2, y),
        Offset(w - 2, math.min(h, y + 5)),
        meta,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorTramo old) => old.id != id || old.oscuro != oscuro;
}
