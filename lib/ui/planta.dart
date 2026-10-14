import 'package:flutter/material.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/estilos_juego.dart';

// Las coordenadas pertenecen al dibujo, las respuestas viven en las reglas.
const _centros = <String, Offset>{
  'raiz': Offset(.50, .85),
  'tallo': Offset(.50, .58),
  'hoja': Offset(.22, .43),
  'flor': Offset(.50, .15),
  'fruto': Offset(.78, .32),
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        const alto = 360.0;
        return SizedBox(
          height: alto,
          child: Stack(
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(painter: _PlantaPainter(colocadas)),
                ),
              ),
              for (final entrada in nombres.entries)
                Positioned(
                  left: _centros[entrada.key]!.dx * ancho - 28,
                  top: _centros[entrada.key]!.dy * alto - 28,
                  width: 56,
                  height: 56,
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
                      final color = fallo
                          ? EstilosJuego.fallo
                          : colocada || encima
                          ? EstilosJuego.acierto
                          : seleccionada != null
                          ? Theme.of(context).colorScheme.primary
                          : EstilosJuego.borde;
                      final estado = colocada
                          ? (fallo ? 'Colocada. Prueba otro sitio' : 'Colocada')
                          : fallo
                          ? 'Prueba otro sitio'
                          : encima
                          ? 'Suelta aquí'
                          : seleccionada != null
                          ? 'Disponible para colocar'
                          : 'Elige una pieza';
                      return Semantics(
                        label:
                            'Zona ${entrada.value}. $estado${consultable ? ". Abrir ficha" : ""}',
                        button: true,
                        child: Tooltip(
                          message: consultable
                              ? 'Consultar ${entrada.value.toLowerCase()}'
                              : estado,
                          child: TarjetaJuego(
                            radio: 22,
                            fondo: colocada
                                ? const Color(0xFFE5F4EA).withValues(alpha: .8)
                                : Colors.white.withValues(alpha: .6),
                            borde: color,
                            destacada: encima || fallo,
                            claveAccion: Key('destino-${entrada.key}'),
                            onTap: () {
                              final pieza = seleccionada;
                              if (pieza != null) {
                                onColocar(pieza, entrada.key);
                              } else if (colocada) {
                                onConsultar(entrada.key);
                              }
                            },
                            child: Center(
                              child: ExcludeSemantics(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (colocada)
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF1F8A4C),
                                        size: 24,
                                      )
                                    else if (fallo)
                                      const Icon(
                                        Icons.replay_rounded,
                                        color: Color(0xFF9A5200),
                                        size: 24,
                                      )
                                    else if (encima)
                                      const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 24,
                                      )
                                    else
                                      const Icon(
                                        Icons.add,
                                        size: 24,
                                        color: Color(0xFF344E41),
                                      ),
                                    if (colocada && fallo)
                                      const Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(
                                          Icons.replay_rounded,
                                          size: 18,
                                          color: Color(0xFF9A5200),
                                        ),
                                      ),
                                  ],
                                ),
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
    canvas.save();
    canvas.scale(size.width / 40, size.height / 40);
    _pintarParte(canvas, id);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PartePainter oldDelegate) => id != oldDelegate.id;
}

void _pintarParte(Canvas canvas, String id) {
  final verde = Paint()..color = const Color(0xFF3D8048);
  final linea = Paint()
    ..color = const Color(0xFF715037)
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;
  switch (id) {
    case 'raiz':
      canvas.drawLine(const Offset(20, 4), const Offset(20, 35), linea);
      for (final y in [14.0, 22.0, 30.0]) {
        canvas.drawLine(Offset(20, y), Offset(8, y + 6), linea);
        canvas.drawLine(Offset(20, y), Offset(32, y + 6), linea);
      }
    case 'tallo':
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(16, 3, 8, 34),
          const Radius.circular(4),
        ),
        verde,
      );
    case 'hoja':
      final hoja = Path()
        ..moveTo(5, 34)
        ..quadraticBezierTo(0, 4, 35, 5)
        ..quadraticBezierTo(38, 34, 5, 34);
      canvas.drawPath(hoja, verde);
      canvas.drawLine(
        const Offset(7, 32),
        const Offset(30, 10),
        linea..color = const Color(0xFF23522D),
      );
    case 'flor':
      final petalo = Paint()..color = const Color(0xFFCB6688);
      for (final centro in const [
        Offset(20, 8),
        Offset(31, 16),
        Offset(27, 29),
        Offset(13, 29),
        Offset(9, 16),
      ]) {
        canvas.drawCircle(centro, 8, petalo);
      }
      canvas.drawCircle(
        const Offset(20, 20),
        7,
        Paint()..color = const Color(0xFFF0BF47),
      );
    case 'fruto':
      canvas.drawCircle(
        const Offset(20, 24),
        14,
        Paint()..color = const Color(0xFFD7693C),
      );
      canvas.drawLine(
        const Offset(20, 11),
        const Offset(20, 3),
        linea..color = const Color(0xFF3D8048),
      );
      canvas.drawOval(const Rect.fromLTWH(20, 2, 12, 6), verde);
  }
}

class _PlantaPainter extends CustomPainter {
  const _PlantaPainter(this.colocadas);

  final Set<String> colocadas;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
    );
    final fondo = Paint()..color = const Color(0xFFE9F3E2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      fondo,
    );
    final suelo = size.height * .73;
    canvas.drawRect(
      Rect.fromLTWH(0, suelo, size.width, size.height - suelo),
      Paint()..color = const Color(0xFFE4D0AD),
    );
    final tallo = Paint()
      ..color = const Color(0xFF689362)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final x = size.width * .5;
    canvas.drawLine(Offset(x, suelo), Offset(x, size.height * .15), tallo);
    canvas.drawLine(
      Offset(x, size.height * .47),
      Offset(size.width * .22, size.height * .43),
      tallo,
    );
    canvas.drawLine(
      Offset(x, size.height * .38),
      Offset(size.width * .78, size.height * .32),
      tallo,
    );
    // Las partes aún pendientes aparecen como siluetas del mismo dibujo.
    for (final entrada in _centros.entries) {
      final centro = Offset(
        entrada.value.dx * size.width,
        entrada.value.dy * size.height,
      );
      canvas.saveLayer(
        Rect.fromCenter(center: centro, width: 90, height: 90),
        Paint()
          ..color = Colors.white.withValues(
            alpha: colocadas.contains(entrada.key) ? 1 : .3,
          ),
      );
      canvas.translate(centro.dx - 40, centro.dy - 40);
      canvas.scale(2);
      _pintarParte(canvas, entrada.key);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlantaPainter oldDelegate) =>
      colocadas.length != oldDelegate.colocadas.length ||
      !colocadas.containsAll(oldDelegate.colocadas);
}
