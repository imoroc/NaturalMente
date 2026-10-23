import 'dart:math' as math;

import 'package:flutter/material.dart';

// Dibujos de «El viaje de la comida». El cuerpo se pinta sobre un lienzo de
// 300×400; las paradas por las que ya ha pasado la comida se iluminan y el
// resto queda en tono suave, sin adelantar cuál es la siguiente.

const _lienzo = Size(300, 400);

/// Zonas que se pueden tocar, en el orden en que se comprueban.
const _zonas = <String, Rect>{
  'boca': Rect.fromLTWH(116, 74, 68, 34),
  'esofago': Rect.fromLTWH(136, 108, 28, 124),
  'corazon': Rect.fromLTWH(160, 184, 48, 46),
  'pulmones': Rect.fromLTWH(74, 144, 152, 92),
  'estomago': Rect.fromLTWH(120, 234, 104, 66),
  'barriga': Rect.fromLTWH(68, 234, 164, 150),
  'intestino-delgado': Rect.fromLTWH(108, 320, 92, 48),
  'intestino-grueso': Rect.fromLTWH(78, 300, 148, 92),
  'intestino': Rect.fromLTWH(78, 300, 148, 92),
};

/// Dónde se dibuja el bocado en cada parada (o en el plato si no ha salido).
const _posiciones = <String, Offset>{
  'plato': Offset(254, 40),
  'boca': Offset(150, 92),
  'esofago': Offset(150, 176),
  'estomago': Offset(178, 264),
  'barriga': Offset(178, 264),
  'intestino': Offset(152, 342),
  'intestino-delgado': Offset(152, 342),
  'intestino-grueso': Offset(212, 340),
};

/// Zona del cuerpo que hay en [local] entre las [activas], o null.
String? zonaDigestiva(Offset local, Size tamano, Iterable<String> activas) {
  final escala = math.min(
    tamano.width / _lienzo.width,
    tamano.height / _lienzo.height,
  );
  final dx = (tamano.width - _lienzo.width * escala) / 2;
  final dy = (tamano.height - _lienzo.height * escala) / 2;
  final punto = Offset((local.dx - dx) / escala, (local.dy - dy) / escala);
  for (final entrada in _zonas.entries) {
    if (activas.contains(entrada.key) && entrada.value.contains(punto)) {
      return entrada.key;
    }
  }
  return null;
}

class DiagramaDigestivo extends StatelessWidget {
  const DiagramaDigestivo({
    required this.activas,
    required this.alcanzadas,
    required this.posicion,
    required this.estadoBocado,
    required this.onElegir,
    this.resaltado,
    this.fallo = false,
    this.etiqueta = '',
    super.key,
  });

  final List<String> activas;
  final Set<String> alcanzadas;
  final String? posicion;
  final String estadoBocado;
  final String? resaltado;
  final bool fallo;
  final String etiqueta;
  final ValueChanged<String> onElegir;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _lienzo.width / _lienzo.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tamano = constraints.biggest;
          void elegirEn(Offset local) {
            final zona = zonaDigestiva(local, tamano, activas);
            if (zona != null) onElegir(zona);
          }

          return DragTarget<String>(
            onWillAcceptWithDetails: (detalles) => detalles.data == 'bocado',
            onAcceptWithDetails: (detalles) {
              final caja = context.findRenderObject() as RenderBox?;
              if (caja != null) elegirEn(caja.globalToLocal(detalles.offset));
            },
            builder: (context, candidatos, _) => GestureDetector(
              onTapUp: (detalles) => elegirEn(detalles.localPosition),
              child: Semantics(
                label: etiqueta,
                image: true,
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(end: _posiciones[posicion ?? 'plato']),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOut,
                  builder: (context, bocado, _) => CustomPaint(
                    size: tamano,
                    painter: _PintorDigestivo(
                      alcanzadas: alcanzadas,
                      bocado: bocado,
                      estadoBocado: estadoBocado,
                      enPlato: posicion == null,
                      resaltado: resaltado,
                      fallo: fallo,
                      arrastrando: candidatos.isNotEmpty,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PintorDigestivo extends CustomPainter {
  const _PintorDigestivo({
    required this.alcanzadas,
    required this.bocado,
    required this.estadoBocado,
    required this.enPlato,
    required this.resaltado,
    required this.fallo,
    required this.arrastrando,
  });

  final Set<String> alcanzadas;
  final Offset bocado;
  final String estadoBocado;
  final bool enPlato;
  final String? resaltado;
  final bool fallo;
  final bool arrastrando;

  bool _encendido(String organo) => switch (organo) {
    'boca' => alcanzadas.contains('boca'),
    'esofago' =>
      alcanzadas.contains('esofago') || alcanzadas.contains('barriga'),
    'estomago' =>
      alcanzadas.contains('estomago') || alcanzadas.contains('barriga'),
    'delgado' =>
      alcanzadas.contains('intestino') ||
          alcanzadas.contains('intestino-delgado') ||
          alcanzadas.contains('barriga'),
    'grueso' =>
      alcanzadas.contains('intestino') ||
          alcanzadas.contains('intestino-grueso') ||
          alcanzadas.contains('barriga'),
    _ => true,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final escala = math.min(
      size.width / _lienzo.width,
      size.height / _lienzo.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - _lienzo.width * escala) / 2,
      (size.height - _lienzo.height * escala) / 2,
    );
    canvas.scale(escala);
    _silueta(canvas);
    _pulmones(canvas);
    _esofago(canvas, encendido: _encendido('esofago'));
    _corazon(canvas);
    _estomago(canvas, encendido: _encendido('estomago'));
    _intestinoGrueso(canvas, encendido: _encendido('grueso'));
    _intestinoDelgado(canvas, encendido: _encendido('delgado'));
    _boca(canvas, encendida: _encendido('boca'));
    final zona = resaltado == null ? null : _zonas[resaltado];
    if (zona != null) {
      final color = fallo ? const Color(0xFFFF9F1C) : const Color(0xFF22C55E);
      final marco = RRect.fromRectAndRadius(
        zona.inflate(3),
        const Radius.circular(14),
      );
      canvas.drawRRect(marco, Paint()..color = color.withValues(alpha: .18));
      canvas.drawRRect(marco, _trazo(color, 3));
    }
    if (enPlato) _plato(canvas);
    pintarBocado(canvas, bocado, estadoBocado, arrastrando ? 16 : 13);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorDigestivo old) =>
      old.bocado != bocado ||
      old.estadoBocado != estadoBocado ||
      old.resaltado != resaltado ||
      old.fallo != fallo ||
      old.enPlato != enPlato ||
      old.arrastrando != arrastrando ||
      old.alcanzadas.length != alcanzadas.length;
}

Paint _relleno(Color color) => Paint()..color = color;

Paint _trazo(Color color, double grosor) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

Paint _degradado(Rect zona, List<Color> colores) => Paint()
  ..shader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: colores,
  ).createShader(zona);

/// Las paradas aún sin recorrer se ven suaves, como en una lámina.
List<Color> _tono(List<Color> colores, bool encendido) => encendido
    ? colores
    : [for (final c in colores) Color.lerp(c, const Color(0xFFF5EDE3), .62)!];

Color _bordeTono(Color color, bool encendido) =>
    encendido ? color : Color.lerp(color, const Color(0xFFD6C6B4), .7)!;

void _silueta(Canvas canvas) {
  const piel = [Color(0xFFFDE5C6), Color(0xFFF5C59A)];
  const borde = Color(0xFFA36E49);
  final tronco = Path()
    ..moveTo(130, 126)
    ..lineTo(170, 126)
    ..cubicTo(232, 130, 256, 148, 254, 186)
    ..lineTo(246, 356)
    ..cubicTo(244, 384, 214, 394, 150, 394)
    ..cubicTo(86, 394, 56, 384, 54, 356)
    ..lineTo(46, 186)
    ..cubicTo(44, 148, 68, 130, 130, 126)
    ..close();
  canvas.drawPath(tronco, _degradado(tronco.getBounds(), piel));
  canvas.drawPath(tronco, _trazo(borde, 2.6));
  canvas.drawRect(
    const Rect.fromLTWH(132, 104, 36, 28),
    _relleno(const Color(0xFFF8D3AE)),
  );
  final ventana = RRect.fromRectAndRadius(
    const Rect.fromLTWH(64, 140, 172, 244),
    const Radius.circular(36),
  );
  canvas.drawRRect(
    ventana,
    _degradado(ventana.outerRect, const [Color(0xFFFFF7F0), Color(0xFFFCE8D8)]),
  );
  canvas.drawRRect(ventana, _trazo(const Color(0xFFD9A784), 2));
  final diafragma = Path()
    ..moveTo(68, 240)
    ..quadraticBezierTo(150, 222, 232, 240);
  canvas.drawPath(
    diafragma,
    _trazo(const Color(0xFFD9A784).withValues(alpha: .7), 1.8),
  );
  // Cabeza con orejas y cara.
  for (final x in const [94.0, 206.0]) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, 66), width: 16, height: 24),
      _relleno(const Color(0xFFF5C59A)),
    );
  }
  final cabeza = Rect.fromCenter(
    center: const Offset(150, 64),
    width: 112,
    height: 108,
  );
  canvas.drawOval(cabeza, _degradado(cabeza, piel));
  canvas.drawOval(cabeza, _trazo(borde, 2.6));
  // Pelo: cubre la parte de arriba de la cabeza, recortado a su contorno.
  final pelo = Path()
    ..moveTo(80, 0)
    ..lineTo(220, 0)
    ..lineTo(220, 54)
    ..cubicTo(186, 32, 114, 32, 80, 54)
    ..close();
  canvas.save();
  canvas.clipPath(Path()..addOval(cabeza.deflate(1.3)));
  canvas.drawPath(pelo, _relleno(const Color(0xFF7C4A2D)));
  canvas.restore();
  for (final x in const [128.0, 172.0]) {
    canvas.drawCircle(Offset(x, 60), 5, _relleno(const Color(0xFF1E293B)));
    canvas.drawCircle(Offset(x + 1.5, 58.5), 1.6, _relleno(Colors.white));
  }
  for (final x in const [118.0, 182.0]) {
    canvas.drawCircle(Offset(x, 78), 7, _relleno(const Color(0x33F43F5E)));
  }
}

void _boca(Canvas canvas, {required bool encendida}) {
  final labios = Rect.fromCenter(
    center: const Offset(150, 92),
    width: 46,
    height: 22,
  );
  canvas.drawOval(
    labios,
    _relleno(encendida ? const Color(0xFFF43F5E) : const Color(0xFFE88A97)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(150, 93), width: 36, height: 13),
    _relleno(const Color(0xFF7F1D1D)),
  );
  // Dientes de arriba y lengua.
  for (var i = 0; i < 4; i++) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(138 + i * 6.2, 87, 5.4, 5),
        const Radius.circular(1.5),
      ),
      _relleno(Colors.white),
    );
  }
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(150, 97), width: 18, height: 6),
    _relleno(const Color(0xFFFB7185)),
  );
}

void _pulmones(Canvas canvas) {
  const colores = [Color(0xFFFBCFE8), Color(0xFFF472B6), Color(0xFFDB2777)];
  for (final lado in const [-1.0, 1.0]) {
    double x(double v) => 150 + lado * (150 - v);
    final pulmon = Path()
      ..moveTo(x(140), 152)
      ..cubicTo(x(110), 140, x(82), 166, x(80), 200)
      ..cubicTo(x(78), 226, x(96), 236, x(120), 230)
      ..cubicTo(x(136), 226, x(140), 210, x(140), 186)
      ..close();
    canvas.drawPath(pulmon, _degradado(pulmon.getBounds(), colores));
    canvas.drawPath(pulmon, _trazo(const Color(0xFF831843), 2.2));
    final bronquio = Path()
      ..moveTo(x(138), 162)
      ..quadraticBezierTo(x(118), 176, x(104), 200);
    canvas.drawPath(bronquio, _trazo(const Color(0xFFFDF2F8), 2));
  }
}

void _corazon(Canvas canvas) {
  final corazon = Path()
    ..moveTo(184, 228)
    ..cubicTo(162, 216, 160, 192, 174, 188)
    ..cubicTo(180, 186, 184, 190, 184, 194)
    ..cubicTo(186, 190, 192, 186, 198, 188)
    ..cubicTo(210, 194, 208, 216, 184, 228)
    ..close();
  canvas.drawPath(
    corazon,
    _degradado(corazon.getBounds(), const [
      Color(0xFFFB7185),
      Color(0xFFE11D48),
      Color(0xFF9F1239),
    ]),
  );
  canvas.drawPath(corazon, _trazo(const Color(0xFF4C0519), 2));
  final latido = Path()
    ..moveTo(172, 206)
    ..lineTo(178, 206)
    ..lineTo(181, 199)
    ..lineTo(186, 213)
    ..lineTo(190, 206)
    ..lineTo(196, 206);
  canvas.drawPath(latido, _trazo(Colors.white, 1.8));
}

void _esofago(Canvas canvas, {required bool encendido}) {
  final tubo = Path()
    ..moveTo(150, 100)
    ..lineTo(150, 226)
    ..quadraticBezierTo(150, 238, 160, 242);
  canvas.drawPath(
    tubo,
    _trazo(_bordeTono(const Color(0xFF9F1239), encendido), 15),
  );
  canvas.drawPath(
    tubo,
    _trazo(encendido ? const Color(0xFFFDA4AF) : const Color(0xFFF6D9D6), 11),
  );
  if (encendido) {
    for (final y in const [130.0, 160.0, 190.0]) {
      canvas.drawLine(
        Offset(146, y),
        Offset(154, y + 4),
        _trazo(const Color(0xFFFFE4E6), 1.6),
      );
    }
  }
}

void _estomago(Canvas canvas, {required bool encendido}) {
  final estomago = Path()
    ..moveTo(154, 238)
    ..cubicTo(198, 226, 226, 250, 212, 278)
    ..cubicTo(200, 298, 148, 298, 132, 282)
    ..cubicTo(122, 270, 132, 258, 144, 262)
    ..cubicTo(156, 268, 174, 270, 180, 260)
    ..cubicTo(186, 250, 170, 244, 154, 246)
    ..close();
  canvas.drawPath(
    estomago,
    _degradado(
      estomago.getBounds(),
      _tono(const [
        Color(0xFFFDBA74),
        Color(0xFFFB923C),
        Color(0xFFEA580C),
      ], encendido),
    ),
  );
  canvas.drawPath(
    estomago,
    _trazo(_bordeTono(const Color(0xFF7C2D12), encendido), 2.4),
  );
  // Salida hacia el intestino delgado.
  final salida = Path()
    ..moveTo(134, 284)
    ..quadraticBezierTo(116, 298, 120, 330);
  canvas.drawPath(
    salida,
    _trazo(_bordeTono(const Color(0xFF9A3412), encendido), 10),
  );
  canvas.drawPath(
    salida,
    _trazo(encendido ? const Color(0xFFFED7AA) : const Color(0xFFF7E6D6), 7),
  );
}

void _intestinoGrueso(Canvas canvas, {required bool encendido}) {
  final marco = Path()
    ..moveTo(92, 372)
    ..lineTo(92, 322)
    ..quadraticBezierTo(92, 308, 106, 308)
    ..lineTo(198, 308)
    ..quadraticBezierTo(212, 308, 212, 322)
    ..lineTo(212, 358)
    ..quadraticBezierTo(212, 372, 198, 374)
    ..lineTo(162, 376)
    ..quadraticBezierTo(150, 378, 150, 390);
  canvas.drawPath(
    marco,
    _trazo(_bordeTono(const Color(0xFF881337), encendido), 22),
  );
  canvas.drawPath(
    marco,
    _trazo(encendido ? const Color(0xFFFDA4AF) : const Color(0xFFF6DADB), 17),
  );
  if (encendido) {
    for (final punto in const [
      Offset(92, 340),
      Offset(130, 308),
      Offset(176, 308),
      Offset(212, 340),
    ]) {
      canvas.drawCircle(punto, 2.2, _relleno(const Color(0xFFFB7185)));
    }
  }
}

void _intestinoDelgado(Canvas canvas, {required bool encendido}) {
  final pliegues = Path()
    ..moveTo(120, 330)
    ..cubicTo(140, 320, 170, 340, 190, 330)
    ..cubicTo(198, 336, 196, 344, 186, 346)
    ..cubicTo(166, 350, 140, 336, 122, 346)
    ..cubicTo(112, 352, 116, 362, 126, 362)
    ..cubicTo(150, 364, 170, 354, 190, 362);
  canvas.drawPath(
    pliegues,
    _trazo(_bordeTono(const Color(0xFF9A3412), encendido), 11),
  );
  canvas.drawPath(
    pliegues,
    _trazo(encendido ? const Color(0xFFFED7AA) : const Color(0xFFF7E6D6), 8),
  );
}

void _plato(Canvas canvas) {
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(254, 54), width: 50, height: 14),
    _relleno(Colors.white),
  );
  canvas.drawOval(
    Rect.fromCenter(center: const Offset(254, 54), width: 50, height: 14),
    _trazo(const Color(0xFF94A3B8), 1.6),
  );
}

/// Pinta el bocado según cómo va: entero, en trozos, en bola, en papilla,
/// convertido en nutrientes o en restos.
void pintarBocado(Canvas canvas, Offset c, String estado, double r) {
  switch (estado) {
    case 'entero':
      canvas.drawCircle(c, r, _relleno(const Color(0xFFEF4444)));
      final mordisco = Path()
        ..moveTo(c.dx + r * .1, c.dy - r)
        ..lineTo(c.dx + r, c.dy - r * .1)
        ..lineTo(c.dx + r, c.dy - r)
        ..close();
      canvas.drawPath(mordisco, _relleno(const Color(0xFFFEF3C7)));
      canvas.drawCircle(c, r, _trazo(const Color(0xFF991B1B), 1.6));
      canvas.drawLine(
        c + Offset(0, -r),
        c + Offset(-r * .2, -r * 1.4),
        _trazo(const Color(0xFF78350F), 2),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: c + Offset(r * .35, -r * 1.25),
          width: r * .8,
          height: r * .4,
        ),
        _relleno(const Color(0xFF22C55E)),
      );
    case 'trozos':
      for (final d in [
        Offset(-r * .5, 0),
        Offset(r * .45, -r * .3),
        Offset(r * .2, r * .5),
      ]) {
        canvas.drawCircle(c + d, r * .45, _relleno(const Color(0xFFFEF3C7)));
        canvas.drawCircle(c + d, r * .45, _trazo(const Color(0xFFEF4444), 1.6));
      }
    case 'bola':
      canvas.drawCircle(c, r * .8, _relleno(const Color(0xFFFCD9A8)));
      canvas.drawCircle(c, r * .8, _trazo(const Color(0xFFB45309), 1.6));
      canvas.drawCircle(
        c + Offset(-r * .25, -r * .25),
        r * .2,
        _relleno(Colors.white70),
      );
    case 'papilla':
      final mancha = Path()
        ..moveTo(c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx - r, c.dy - r * .9, c.dx, c.dy - r * .7)
        ..quadraticBezierTo(
          c.dx + r * 1.1,
          c.dy - r * .8,
          c.dx + r,
          c.dy + r * .1,
        )
        ..quadraticBezierTo(
          c.dx + r * .7,
          c.dy + r * .9,
          c.dx - r * .1,
          c.dy + r * .7,
        )
        ..quadraticBezierTo(c.dx - r * 1.1, c.dy + r * .8, c.dx - r, c.dy)
        ..close();
      canvas.drawPath(mancha, _relleno(const Color(0xFFFDE68A)));
      canvas.drawPath(mancha, _trazo(const Color(0xFFCA8A04), 1.6));
    case 'nutrientes':
      const colores = [
        Color(0xFFFACC15),
        Color(0xFF22C55E),
        Color(0xFFEF4444),
        Color(0xFF3B82F6),
        Color(0xFFF97316),
      ];
      for (var i = 0; i < colores.length; i++) {
        final angulo = i * 2 * math.pi / colores.length;
        canvas.drawCircle(
          c + Offset(math.cos(angulo), math.sin(angulo)) * r * .7,
          r * .32,
          _relleno(colores[i]),
        );
      }
    default:
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 1.6, height: r * 1.1),
        _relleno(const Color(0xFF92400E)),
      );
  }
}

class DibujoBocado extends StatelessWidget {
  const DibujoBocado({required this.estado, this.tamano = 40, super.key});

  final String estado;
  final double tamano;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamano,
    child: CustomPaint(painter: _PintorBocado(estado)),
  );
}

class _PintorBocado extends CustomPainter {
  const _PintorBocado(this.estado);

  final String estado;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) * .3;
    pintarBocado(
      canvas,
      size.center(Offset.zero) + Offset(0, r * .2),
      estado,
      r,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorBocado old) => old.estado != estado;
}

/// Icono de una parada o de un despiste, recortado del mismo dibujo.
class IconoParada extends StatelessWidget {
  const IconoParada({
    required this.id,
    this.tamano = 48,
    this.sinFondo = false,
    super.key,
  });

  final bool sinFondo;

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: sinFondo ? const Color(0x00000000) : const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(tamano * .28),
        border: sinFondo
            ? null
            : Border.all(color: const Color(0xFFF5C59A), width: 2),
      ),
      padding: sinFondo ? EdgeInsets.zero : EdgeInsets.all(tamano * .08),
      child: CustomPaint(painter: _PintorIconoParada(id)),
    );
  }
}

class _PintorIconoParada extends CustomPainter {
  const _PintorIconoParada(this.id);

  final String id;

  static const _recortes = <String, Rect>{
    'boca': Rect.fromLTWH(118, 74, 64, 36),
    'esofago': Rect.fromLTWH(112, 96, 76, 150),
    'pulmones': Rect.fromLTWH(74, 138, 152, 100),
    'corazon': Rect.fromLTWH(154, 180, 60, 54),
    'estomago': Rect.fromLTWH(118, 226, 104, 76),
    'barriga': Rect.fromLTWH(78, 226, 148, 168),
    'intestino': Rect.fromLTWH(76, 296, 152, 98),
    'intestino-delgado': Rect.fromLTWH(104, 314, 100, 56),
    'intestino-grueso': Rect.fromLTWH(76, 296, 152, 98),
    'aparato': Rect.fromLTWH(60, 70, 180, 324),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final recorte = _recortes[id] ?? _recortes['aparato']!;
    final escala = math.min(
      size.width / recorte.width,
      size.height / recorte.height,
    );
    canvas.save();
    canvas.translate(
      (size.width - recorte.width * escala) / 2 - recorte.left * escala,
      (size.height - recorte.height * escala) / 2 - recorte.top * escala,
    );
    canvas.scale(escala);
    switch (id) {
      case 'boca':
        _boca(canvas, encendida: true);
      case 'esofago':
        _esofago(canvas, encendido: true);
      case 'pulmones':
        _pulmones(canvas);
      case 'corazon':
        _corazon(canvas);
      case 'estomago':
        _estomago(canvas, encendido: true);
      case 'intestino-delgado':
        _intestinoDelgado(canvas, encendido: true);
      case 'intestino-grueso':
        _intestinoGrueso(canvas, encendido: true);
      case 'intestino':
        _intestinoGrueso(canvas, encendido: true);
        _intestinoDelgado(canvas, encendido: true);
      case 'barriga':
        _estomago(canvas, encendido: true);
        _intestinoGrueso(canvas, encendido: true);
        _intestinoDelgado(canvas, encendido: true);
      default:
        _esofago(canvas, encendido: true);
        _estomago(canvas, encendido: true);
        _intestinoGrueso(canvas, encendido: true);
        _intestinoDelgado(canvas, encendido: true);
        _boca(canvas, encendida: true);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorIconoParada old) => old.id != id;
}
