import 'package:naturalmente/idiomas/idioma.dart';

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:naturalmente/ui/estilos_juego.dart';

// Una sola ilustración: las piezas y sus huecos comparten trazos y escala.
const _lienzo = Size(400, 440);
const _zonas = <String, Rect>{
  'raiz': Rect.fromLTWH(108, 320, 184, 108),
  'tallo': Rect.fromLTWH(174, 196, 68, 116),
  'hoja': Rect.fromLTWH(40, 120, 130, 122),
  'flor': Rect.fromLTWH(170, 16, 108, 108),
  'fruto': Rect.fromLTWH(260, 124, 96, 94),
};
const _recortes = <String, Rect>{
  'raiz': Rect.fromLTWH(108, 314, 184, 114),
  'tallo': Rect.fromLTWH(175, 90, 135, 234),
  'hoja': Rect.fromLTWH(40, 120, 170, 125),
  'flor': Rect.fromLTWH(170, 16, 108, 108),
  'fruto': Rect.fromLTWH(260, 124, 96, 94),
};

class PlantaHerbario extends StatelessWidget {
  const PlantaHerbario({
    required this.nombres,
    required this.colocadas,
    required this.seleccionada,
    required this.onColocar,
    required this.onConsultar,
    this.ultimoDestino,
    this.falloColocacion = false,
    this.consultables = const {},
    super.key,
  });

  final Map<String, String> nombres;
  final Set<String> colocadas;
  final String? seleccionada;
  final String? ultimoDestino;
  final bool falloColocacion;
  final Set<String> consultables;
  final void Function(String pieza, String destino) onColocar;
  final ValueChanged<String> onConsultar;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final escala = constraints.maxWidth / _lienzo.width;
      return Container(
        height: _lienzo.height * escala,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD5DFCB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C344E41),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _PlantaPainter(
                    partes: nombres.keys.toSet(),
                    colocadas: colocadas,
                  ),
                ),
              ),
            ),
            for (final entrada in nombres.entries)
              Positioned.fromRect(
                rect: Rect.fromLTWH(
                  _zonas[entrada.key]!.left * escala,
                  _zonas[entrada.key]!.top * escala,
                  _zonas[entrada.key]!.width * escala,
                  _zonas[entrada.key]!.height * escala,
                ),
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (datos) =>
                      nombres.containsKey(datos.data) &&
                      !colocadas.contains(datos.data),
                  onAcceptWithDetails: (datos) =>
                      onColocar(datos.data, entrada.key),
                  builder: (context, candidatos, rechazados) {
                    final colocada = colocadas.contains(entrada.key);
                    final consultable = consultables.contains(entrada.key);
                    final fallo =
                        ultimoDestino == entrada.key && falloColocacion;
                    final encima = candidatos.isNotEmpty;
                    final disponible = seleccionada != null && !colocada;
                    final color = fallo
                        ? EstilosJuego.fallo
                        : EstilosJuego.acierto;
                    final estado = colocada
                        ? (fallo ? 'Colocada. Prueba otro sitio' : 'Colocada')
                        : fallo
                        ? 'Prueba otro sitio'
                        : encima
                        ? 'Suelta aquí'
                        : disponible
                        ? 'Disponible para colocar'
                        : 'Elige una pieza';
                    return Semantics(
                      label:
                          '${context.traducir('Zona ${entrada.value}')}. ${context.traducir(estado)}${consultable ? context.traducir('. Abrir ficha') : ""}',
                      button: true,
                      child: Tooltip(
                        message: context.traducir(
                          consultable
                              ? 'Consultar ${entrada.value.toLowerCase()}'
                              : estado,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            key: Key('destino-${entrada.key}'),
                            borderRadius: BorderRadius.circular(20),
                            focusColor: const Color(0x443C8550),
                            hoverColor: const Color(0x153C8550),
                            onTap: () {
                              final pieza = seleccionada;
                              if (pieza != null) {
                                onColocar(pieza, entrada.key);
                              } else if (colocada) {
                                onConsultar(entrada.key);
                              }
                            },
                            child: Stack(
                              children: [
                                if (encima || fallo)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: CustomPaint(
                                        painter: _ResaltePartePainter(
                                          entrada.key,
                                          color,
                                        ),
                                      ),
                                    ),
                                  ),
                                // La marca queda junto a la pieza, sin taparla.
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: ExcludeSemantics(
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colocada || fallo || encima
                                            ? Colors.white
                                            : Colors.white.withValues(
                                                alpha: .7,
                                              ),
                                        border: Border.all(
                                          color: colocada || fallo || encima
                                              ? color
                                              : disponible
                                              ? const Color(0xFF6B8964)
                                              : const Color(0xFFB0BDA3),
                                        ),
                                      ),
                                      child: Icon(
                                        fallo
                                            ? Icons.replay_rounded
                                            : colocada
                                            ? Icons.check_rounded
                                            : encima
                                            ? Icons.arrow_downward_rounded
                                            : Icons.add_rounded,
                                        size: 16,
                                        color: colocada || fallo || encima
                                            ? color
                                            : const Color(0xFF6B8964),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}

class IconoParte extends StatelessWidget {
  const IconoParte({required this.id, this.size = 40, super.key});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _PartePainter(id)),
  );
}

class _PartePainter extends CustomPainter {
  const _PartePainter(this.id);
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final recorte = _recortes[id]!;
    final escala = math.min(
      (size.width - 4) / recorte.width,
      (size.height - 4) / recorte.height,
    );
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(escala);
    canvas.translate(-recorte.center.dx, -recorte.center.dy);
    _pintarParte(canvas, id);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PartePainter oldDelegate) => id != oldDelegate.id;
}

Paint _linea(Color color, double grosor) => Paint()
  ..color = color
  ..strokeWidth = grosor
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..style = PaintingStyle.stroke;

void _rellenar(
  Canvas canvas,
  Path forma,
  List<Color> colores, {
  Color borde = const Color(0xFF37603A),
  bool sombra = true,
}) {
  if (sombra) canvas.drawShadow(forma, const Color(0x303A4828), 2, false);
  canvas.drawPath(
    forma,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colores,
      ).createShader(forma.getBounds()),
  );
  canvas.drawPath(forma, _linea(borde, 1.2));
}

Path _tallo() => Path()
  ..moveTo(196, 320)
  ..cubicTo(196, 280, 202, 254, 202, 225)
  ..cubicTo(203, 177, 194, 133, 207, 96)
  ..quadraticBezierTo(210, 90, 213, 94)
  ..cubicTo(204, 140, 213, 177, 212, 225)
  ..cubicTo(211, 261, 207, 293, 207, 320)
  ..close();

Path _ramaFruto() => Path()
  ..moveTo(207, 165)
  ..cubicTo(239, 134, 264, 122, 288, 128)
  ..quadraticBezierTo(303, 130, 304, 144);

Path _pedunculo() => Path()
  ..moveTo(208, 107)
  ..quadraticBezierTo(222, 100, 224, 83);

Path _peciolo() => Path()
  ..moveTo(207, 227)
  ..quadraticBezierTo(173, 213, 130, 191);

Path _hoja() => Path()
  ..moveTo(0, 0)
  ..cubicTo(-15, -5, -30, 0, -43, -14)
  ..lineTo(-39, -19)
  ..quadraticBezierTo(-58, -20, -65, -36)
  ..lineTo(-61, -38)
  ..quadraticBezierTo(-81, -45, -91, -62)
  ..quadraticBezierTo(-65, -68, -48, -54)
  ..lineTo(-47, -59)
  ..quadraticBezierTo(-28, -50, -22, -34)
  ..lineTo(-18, -38)
  ..cubicTo(-7, -29, -9, -12, 0, 0)
  ..close();

void _pintarHojas(Canvas canvas, {bool silueta = false}) {
  canvas.drawPath(_peciolo(), _linea(const Color(0xFF628342), 4));
  // Folíolos que nacen del mismo pecíolo, con tamaños y giros naturales.
  for (final hoja in const [
    (Offset(174, 211), .12, 1.0),
    (Offset(150, 201), -.80, .92),
    (Offset(137, 194), .86, .65),
  ]) {
    canvas.save();
    canvas.translate(hoja.$1.dx, hoja.$1.dy);
    canvas.rotate(hoja.$2);
    canvas.scale(hoja.$3);
    final forma = _hoja();
    if (silueta) {
      canvas.drawPath(forma, Paint()..color = Colors.white);
    } else {
      _rellenar(canvas, forma, const [
        Color(0xFF9ABA54),
        Color(0xFF528B43),
        Color(0xFF2D6540),
      ]);
      final nervio = Path()
        ..moveTo(-2, -2)
        ..quadraticBezierTo(-42, -35, -87, -60);
      canvas.drawPath(nervio, _linea(const Color(0xFFCCE19A), 1.7));
      for (var i = 1; i <= 4; i++) {
        final x = -i * 15.0;
        final y = x * .69;
        canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(x - 1, y - 9, x - 4, y - 15)
            ..moveTo(x, y)
            ..quadraticBezierTo(x - 8, y + 3, x - 17, y + 1),
          _linea(const Color(0xFFB4D37E), .9),
        );
      }
    }
    canvas.restore();
  }
}

Path _petalo() => Path()
  ..moveTo(-9, 5)
  ..quadraticBezierTo(-17, -11, -6, -26)
  ..quadraticBezierTo(-2, -31, 0, -43)
  ..quadraticBezierTo(5, -30, 11, -24)
  ..quadraticBezierTo(17, -9, 8, 5)
  ..close();

void _pintarFlor(Canvas canvas, {bool silueta = false}) {
  canvas.save();
  canvas.translate(224, 68);
  for (var i = 0; i < 5; i++) {
    canvas.save();
    canvas.rotate(i * math.pi * 2 / 5 + .12);
    if (silueta) {
      canvas.drawPath(_petalo(), Paint()..color = Colors.white);
    } else {
      _rellenar(canvas, _petalo(), const [
        Color(0xFFFFE893),
        Color(0xFFE9B62F),
      ], borde: const Color(0xFFC39126));
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(-1, -12, 0, -30),
        _linea(const Color(0xFFF8D55E), 1.2),
      );
    }
    canvas.restore();
  }
  canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFFB88222));
  canvas.drawCircle(
    const Offset(-1, -2),
    7.5,
    Paint()..color = const Color(0xFFE6AC2B),
  );
  if (!silueta) {
    for (var i = 0; i < 9; i++) {
      final angulo = i * 2.4;
      canvas.drawCircle(
        Offset(math.cos(angulo) * 5, math.sin(angulo) * 5),
        1.2,
        Paint()..color = const Color(0xFF8F6621),
      );
    }
  }
  canvas.restore();
}

Path _fruto() => Path()
  ..moveTo(302, 141)
  ..cubicTo(321, 130, 345, 144, 344, 166)
  ..cubicTo(345, 190, 327, 207, 306, 207)
  ..cubicTo(283, 208, 267, 191, 268, 169)
  ..cubicTo(266, 148, 283, 132, 302, 141)
  ..close();

Path _caliz() => Path()
  ..moveTo(302, 143)
  ..lineTo(283, 138)
  ..quadraticBezierTo(294, 134, 300, 137)
  ..lineTo(299, 128)
  ..lineTo(306, 136)
  ..lineTo(322, 130)
  ..lineTo(312, 142)
  ..lineTo(326, 151)
  ..quadraticBezierTo(312, 150, 306, 146)
  ..lineTo(298, 156)
  ..close();

void _pintarFruto(Canvas canvas, {bool silueta = false}) {
  if (silueta) {
    canvas.drawPath(_fruto(), Paint()..color = Colors.white);
    canvas.drawPath(_caliz(), Paint()..color = Colors.white);
    return;
  }
  _rellenar(canvas, _fruto(), const [
    Color(0xFFEF9A55),
    Color(0xFFE25B3D),
    Color(0xFFB93730),
  ], borde: const Color(0xFFAB4433));
  canvas.drawPath(
    Path()
      ..moveTo(285, 154)
      ..quadraticBezierTo(277, 164, 280, 175),
    _linea(const Color(0xFFFFC298), 3),
  );
  canvas.drawPath(
    Path()
      ..moveTo(323, 159)
      ..quadraticBezierTo(337, 177, 320, 195),
    _linea(const Color(0xFFC34833), 1.4),
  );
  _rellenar(canvas, _caliz(), const [
    Color(0xFF89A44A),
    Color(0xFF416B36),
  ], sombra: false);
}

// Raíces de grosor decreciente y ramificaciones secundarias.
const _ramasRaiz = <List<Offset>>[
  [Offset(201, 318), Offset(193, 351), Offset(202, 386), Offset(192, 422)],
  [Offset(198, 334), Offset(170, 342), Offset(146, 362), Offset(123, 384)],
  [Offset(196, 350), Offset(172, 364), Offset(170, 390), Offset(153, 410)],
  [Offset(202, 339), Offset(226, 345), Offset(238, 363), Offset(273, 378)],
  [Offset(201, 364), Offset(219, 377), Offset(224, 401), Offset(239, 418)],
  [Offset(155, 355), Offset(148, 369), Offset(147, 388), Offset(134, 400)],
  [Offset(236, 362), Offset(250, 372), Offset(250, 388), Offset(269, 401)],
  [Offset(179, 360), Offset(164, 362), Offset(144, 366), Offset(114, 372)],
];

Path _curvaRaiz(List<Offset> puntos) => Path()
  ..moveTo(puntos[0].dx, puntos[0].dy)
  ..cubicTo(
    puntos[1].dx,
    puntos[1].dy,
    puntos[2].dx,
    puntos[2].dy,
    puntos[3].dx,
    puntos[3].dy,
  );

void _pintarRaiz(Canvas canvas, {bool silueta = false}) {
  for (var i = 0; i < _ramasRaiz.length; i++) {
    final curva = _curvaRaiz(_ramasRaiz[i]);
    final metrica = curva.computeMetrics().first;
    final grosor = i == 0
        ? 8.0
        : i < 5
        ? 5.0
        : 2.8;
    // Segmentos solapados afinan cada raíz desde el cuello hasta la punta.
    for (var j = 0; j < 16; j++) {
      canvas.drawPath(
        metrica.extractPath(
          metrica.length * j / 16,
          math.min(metrica.length, metrica.length * (j + 1.2) / 16),
        ),
        _linea(
          silueta ? Colors.white : const Color(0xFF967047),
          grosor * (1 - j / 19),
        ),
      );
    }
    if (!silueta) {
      for (final t in [.45, .68, .85]) {
        final punto = metrica.getTangentForOffset(metrica.length * t)!;
        final lado = i.isEven ? 1.0 : -1.0;
        canvas.drawPath(
          Path()
            ..moveTo(punto.position.dx, punto.position.dy)
            ..quadraticBezierTo(
              punto.position.dx + 7 * lado,
              punto.position.dy + 3,
              punto.position.dx + 10 * lado,
              punto.position.dy + 9,
            ),
          _linea(const Color(0xFFAA875A), .8),
        );
      }
    }
  }
}

void _pintarParte(Canvas canvas, String id, {bool silueta = false}) {
  switch (id) {
    case 'raiz':
      _pintarRaiz(canvas, silueta: silueta);
    case 'tallo':
      if (silueta) {
        canvas.drawPath(_tallo(), Paint()..color = Colors.white);
      } else {
        _rellenar(canvas, _tallo(), const [
          Color(0xFF94AD58),
          Color(0xFF527D40),
        ], sombra: false);
        canvas.drawPath(
          Path()
            ..moveTo(201, 309)
            ..cubicTo(201, 259, 210, 206, 205, 163)
            ..quadraticBezierTo(202, 126, 210, 100),
          _linea(const Color(0xFFB0C47C), 2),
        );
      }
      for (final rama in [_ramaFruto(), _pedunculo()]) {
        canvas.drawPath(
          rama,
          _linea(silueta ? Colors.white : const Color(0xFF648644), 4),
        );
      }
    case 'hoja':
      _pintarHojas(canvas, silueta: silueta);
    case 'flor':
      _pintarFlor(canvas, silueta: silueta);
    case 'fruto':
      _pintarFruto(canvas, silueta: silueta);
  }
}

class _ResaltePartePainter extends CustomPainter {
  const _ResaltePartePainter(this.id, this.color);
  final String id;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final zona = _zonas[id]!;
    canvas.save();
    canvas.scale(size.width / zona.width, size.height / zona.height);
    canvas.translate(-zona.left, -zona.top);
    canvas.saveLayer(
      _recortes[id]!.inflate(8),
      Paint()
        ..colorFilter = ColorFilter.mode(
          color.withValues(alpha: .5),
          BlendMode.srcIn,
        ),
    );
    _pintarParte(canvas, id, silueta: true);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ResaltePartePainter oldDelegate) =>
      id != oldDelegate.id || color != oldDelegate.color;
}

class _PlantaPainter extends CustomPainter {
  const _PlantaPainter({required this.partes, required this.colocadas});
  final Set<String> partes;
  final Set<String> colocadas;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _lienzo.width, size.height / _lienzo.height);
    const fondo = Rect.fromLTWH(0, 0, 400, 440);
    canvas.drawRect(
      fondo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FBF1), Color(0xFFE9F0DC)],
        ).createShader(fondo),
    );
    canvas.drawOval(
      const Rect.fromLTWH(35, 16, 335, 310),
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: .8), const Color(0x00FFFFFF)],
        ).createShader(const Rect.fromLTWH(35, 16, 335, 310)),
    );
    final suelo = Path()
      ..moveTo(0, 320)
      ..cubicTo(80, 311, 122, 325, 200, 319)
      ..cubicTo(280, 312, 326, 323, 400, 317)
      ..lineTo(400, 440)
      ..lineTo(0, 440)
      ..close();
    canvas.drawPath(
      suelo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE6D8BC), Color(0xFFD8C39F)],
        ).createShader(const Rect.fromLTWH(0, 315, 400, 125)),
    );
    // Grano de papel y tierra determinista: no cambia al colocar piezas.
    final azar = math.Random(23);
    for (var i = 0; i < 260; i++) {
      final x = azar.nextDouble() * 400;
      final y = azar.nextDouble() * 440;
      canvas.drawCircle(
        Offset(x, y),
        y > 327 ? .6 + azar.nextDouble() * 1.1 : .5,
        Paint()
          ..color = y > 327 ? const Color(0x25755B35) : const Color(0x0871854F),
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(0, 320)
        ..cubicTo(80, 311, 122, 325, 200, 319)
        ..cubicTo(280, 312, 326, 323, 400, 317),
      _linea(const Color(0xFFB9B385), 2),
    );
    for (final id in ['raiz', 'tallo', 'hoja', 'flor', 'fruto']) {
      // En Fácil, flor y fruto sirven de referencia; se montan tres partes.
      if (colocadas.contains(id) || !partes.contains(id)) {
        _pintarParte(canvas, id);
      } else {
        // El hueco tiene exactamente la silueta de la pieza que encaja en él.
        canvas.saveLayer(
          _recortes[id]!.inflate(8),
          Paint()
            ..colorFilter = ColorFilter.mode(
              id == 'raiz' ? const Color(0x508C744F) : const Color(0x456F875B),
              BlendMode.srcIn,
            ),
        );
        _pintarParte(canvas, id, silueta: true);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlantaPainter oldDelegate) =>
      !setEquals(partes, oldDelegate.partes) ||
      !setEquals(colocadas, oldDelegate.colocadas);
}
