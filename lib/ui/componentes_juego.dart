import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos_natu.dart';

/// Tarjeta táctil de estilo táctil/3D uniforme para actividades y opciones.
class TarjetaJuego extends StatelessWidget {
  const TarjetaJuego({
    required this.child,
    this.fondo = Colors.white,
    this.borde = const Color(0xFFD6CFC0),
    this.sombra,
    this.radio = 18.0,
    this.destacada = false,
    this.claveAccion,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color fondo;
  final Color borde;
  final Color? sombra;
  final double radio;
  final bool destacada;
  final Key? claveAccion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorSombra = sombra ?? borde.withValues(alpha: 0.45);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(
          color: borde,
          width: destacada ? 3.0 : 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorSombra,
            offset: Offset(0, destacada ? 5 : 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radio),
        child: InkWell(
          key: claveAccion,
          borderRadius: BorderRadius.circular(radio),
          onTap: onTap == null
              ? null
              : () {
                  context.sonidoToque();
                  onTap!();
                },
          child: child,
        ),
      ),
    );
  }
}

/// Insignia dinámica al estilo Duolingo para la cabecera de cada juego:
/// sincroniza con la racha global de `Progreso`, lanza partículas de fuego
/// al subir el combo y evoluciona de color según el nivel de racha.
class InsigniaPrecisionAppBar extends StatelessWidget {
  const InsigniaPrecisionAppBar({
    this.comboActual,
    this.combo,
    required this.semillasSesion,
    super.key,
  });

  final int? comboActual;
  final int? combo;
  final int semillasSesion;

  int get _comboLocal => comboActual ?? combo ?? 0;

  String _etiquetaHito(int c) {
    if (c >= 5) return '¡IMPARABLE!';
    if (c >= 3) return '¡EN LLAMAS!';
    if (c == 2) return '¡RACHA!';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final progreso = Alcance.maybeOf(context)?.progreso;
    if (progreso != null) {
      return ListenableBuilder(
        listenable: progreso,
        builder: (context, _) => _construirContenido(
          context,
          progreso.comboActual,
        ),
      );
    }
    return _construirContenido(context, _comboLocal);
  }

  Widget _construirContenido(BuildContext context, int c) {
    final supernova = c >= 5;
    final enFuego = c >= 3;
    final activo = c > 0;
    final hito = _etiquetaHito(c);

    final gradienteCombo = !activo
        ? const [Color(0xFFF1F5F9), Color(0xFFE2E8F0)]
        : supernova
            ? const [Color(0xFFFFE4E6), Color(0xFFFDE68A), Color(0xFFFFEDD5)]
            : enFuego
                ? const [Color(0xFFFFEDD5), Color(0xFFFED7AA)]
                : const [Color(0xFFFEF9C3), Color(0xFFFEF08A)];

    final colorBorde = !activo
        ? const Color(0xFFCBD5E1)
        : supernova
            ? const Color(0xFFE11D48)
            : enFuego
                ? const Color(0xFFEA580C)
                : const Color(0xFFD97706);

    final colorTexto = !activo
        ? const Color(0xFF64748B)
        : supernova
            ? const Color(0xFF9F1239)
            : enFuego
                ? const Color(0xFF9A3412)
                : const Color(0xFF92400E);

    final mostrarHito =
        hito.isNotEmpty && MediaQuery.sizeOf(context).width >= 380;

    return MediaQuery.withNoTextScaling(
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              key: ValueKey<String>('combo-anim-$c'),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 620),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
                final pulso = activo
                    ? 1.0 + math.sin(t * math.pi) * (supernova ? 0.28 : 0.20)
                    : 1.0;
                final giro = activo && c >= 2
                    ? math.sin(t * math.pi * 2) * 0.06 * (1.0 - t)
                    : 0.0;
                return CustomPaint(
                  foregroundPainter: activo
                      ? _PintorExplosionRacha(
                          progreso: t,
                          intensidad: supernova ? 2 : (enFuego ? 1 : 0),
                        )
                      : null,
                  child: Transform.rotate(
                    angle: giro,
                    child: Transform.scale(scale: pulso, child: child),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradienteCombo,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colorBorde, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: colorBorde.withValues(alpha: activo ? 0.38 : 0.15),
                      offset: const Offset(0, 3),
                      blurRadius: enFuego ? 8 : 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconoLlamaRacha(
                      tamano: 19,
                      activa: activo,
                      intensa: enFuego,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'x$c',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: colorTexto,
                      ),
                    ),
                    if (mostrarHito) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: supernova
                              ? const Color(0xFFE11D48)
                              : (enFuego
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFFD97706)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.tr(hito),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (semillasSesion > 0) ...[
              const SizedBox(width: 6),
              TweenAnimationBuilder<double>(
                key: ValueKey<String>('semillas-$semillasSesion'),
                tween: Tween<double>(begin: 1.24, end: 1.0),
                duration: const Duration(milliseconds: 420),
                curve: Curves.elasticOut,
                builder: (context, escala, child) =>
                    Transform.scale(scale: escala, child: child),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF059669),
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33059669),
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconoSemilla(tamano: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+$semillasSesion',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PintorExplosionRacha extends CustomPainter {
  const _PintorExplosionRacha({
    required this.progreso,
    required this.intensidad,
  });

  final double progreso;
  final int intensidad;

  @override
  void paint(Canvas canvas, Size size) {
    if (progreso <= 0.0 || progreso >= 1.0) return;
    final opacidad = (1.0 - progreso).clamp(0.0, 1.0);
    final centro = Offset(size.width * 0.28, size.height * 0.5);
    final numChispas = intensidad >= 2 ? 10 : (intensidad == 1 ? 8 : 6);
    final radioMax = (size.height * 0.85) * (0.4 + progreso * 0.9);

    // Onda expansiva luminosa estilo Duolingo
    final ondaPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 * opacidad
      ..color = (intensidad >= 2
              ? const Color(0xFFF43F5E)
              : const Color(0xFFF97316))
          .withValues(alpha: opacidad * 0.55);
    canvas.drawCircle(centro, radioMax * 0.78, ondaPaint);

    for (var i = 0; i < numChispas; i++) {
      final angulo = (i * 2 * math.pi / numChispas) - math.pi / 4;
      final dist = radioMax * (0.35 + 0.65 * progreso);
      final pos = Offset(
        centro.dx + math.cos(angulo) * dist,
        centro.dy + math.sin(angulo) * dist - progreso * 6,
      );
      final colorChispa = i.isEven
          ? const Color(0xFFFACC15)
          : (intensidad >= 2
                ? const Color(0xFFFB7185)
                : const Color(0xFFEA580C));
      final p = Paint()..color = colorChispa.withValues(alpha: opacidad);
      canvas.drawCircle(pos, (3.2 - progreso * 2.0).clamp(0.8, 3.2), p);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorExplosionRacha oldDelegate) =>
      oldDelegate.progreso != progreso || oldDelegate.intensidad != intensidad;
}

/// Panel animado al estilo Duolingo para celebrar la racha de días jugando.
class CelebracionRachaDiariaDuolingo extends StatelessWidget {
  const CelebracionRachaDiariaDuolingo({
    required this.rachaDias,
    this.completadoHoy = true,
    this.compacto = false,
    super.key,
  });

  final int rachaDias;
  final bool completadoHoy;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    const diasSemana = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final diasEncendidos = rachaDias.clamp(0, 7);

    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('racha-diaria-$rachaDias-$completadoHoy'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutBack,
      builder: (context, t, _) {
        final tSeguro = t.clamp(0.0, 1.0);
        final escalaLlama = 0.78 + 0.22 * t;
        return Container(
          padding: EdgeInsets.all(compacto ? 12 : 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF7ED), Color(0xFFFEF3C7), Color(0xFFFFEDD5)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF97316), width: 2.6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x38EA580C),
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    foregroundPainter: _PintorExplosionRacha(
                      progreso: (tSeguro * 1.15).clamp(0.0, 0.99),
                      intensidad: rachaDias >= 3 ? 2 : 1,
                    ),
                    child: Transform.scale(
                      scale: escalaLlama,
                      child: Container(
                        width: compacto ? 54 : 68,
                        height: compacto ? 54 : 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFFEF08A),
                              Color(0xFFFED7AA),
                              Color(0x00FED7AA),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFFB923C),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: IconoLlamaRacha(
                          tamano: compacto ? 34 : 44,
                          activa: rachaDias > 0 || completadoHoy,
                          intensa: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$rachaDias',
                              style: TextStyle(
                                fontSize: compacto ? 28 : 34,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFEA580C),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                rachaDias == 1
                                    ? context.tr('día de racha')
                                    : context.tr('días de racha'),
                                style: TextStyle(
                                  fontSize: compacto ? 15 : 17,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF9A3412),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          completadoHoy
                              ? context.tr(
                                  '¡Llama encendida hoy! Vuelve mañana para que siga creciendo.',
                                )
                              : context.tr(
                                  '¡Completa los 3 retos de hoy para encender tu llama diaria!',
                                ),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7C2D12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFED7AA),
                    width: 1.8,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var i = 0; i < diasSemana.length; i++)
                      _CapsulaDiaRacha(
                        etiqueta: diasSemana[i],
                        encendido: i < diasEncendidos,
                        esHoy:
                            completadoHoy &&
                            i == math.max(0, diasEncendidos - 1),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CapsulaDiaRacha extends StatelessWidget {
  const _CapsulaDiaRacha({
    required this.etiqueta,
    required this.encendido,
    required this.esHoy,
  });

  final String etiqueta;
  final bool encendido;
  final bool esHoy;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: encendido
                ? const Color(0xFF9A3412)
                : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: encendido
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                  )
                : null,
            color: encendido ? null : const Color(0xFFF1F5F9),
            border: Border.all(
              color: esHoy
                  ? const Color(0xFFFACC15)
                  : (encendido
                        ? const Color(0xFFC2410C)
                        : const Color(0xFFCBD5E1)),
              width: esHoy ? 2.4 : 1.6,
            ),
          ),
          alignment: Alignment.center,
          child: encendido
              ? const Icon(
                  Icons.local_fire_department_rounded,
                  size: 15,
                  color: Color(0xFFFEF08A),
                )
              : const Icon(
                  Icons.circle,
                  size: 6,
                  color: Color(0xFFCBD5E1),
                ),
        ),
      ],
    );
  }
}

/// Tarjeta dopamínica de resumen de precisión al terminar un nivel (estilo Duolingo).
class ResumenPrecisionFinal extends StatelessWidget {
  const ResumenPrecisionFinal({
    this.aciertosALaPrimera,
    this.totalPasos,
    this.sinPistas,
    required this.mejorComboSesion,
    required this.semillasGanadas,
    super.key,
  });

  final int? aciertosALaPrimera;
  final int? totalPasos;
  final bool? sinPistas;
  final int mejorComboSesion;
  final int semillasGanadas;

  @override
  Widget build(BuildContext context) {
    final int porcentaje;
    if (aciertosALaPrimera != null && totalPasos != null) {
      final total = totalPasos! <= 0 ? 1 : totalPasos!;
      porcentaje = ((aciertosALaPrimera! / total) * 100).round().clamp(0, 100);
    } else {
      porcentaje = (sinPistas ?? true) ? 100 : 85;
    }
    final perfecto = porcentaje == 100;
    final tituloHito = perfecto
        ? '¡PERFECCIÓN CIENTÍFICA!'
        : (porcentaje >= 75 ? '¡GRAN PUNTERÍA!' : '¡BUENA EXPLORACIÓN!');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: perfecto
              ? const [Color(0xFFFEF9C3), Color(0xFFFFEDD5)]
              : const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: perfecto
              ? const Color(0xFFF59E0B)
              : const Color(0xFF22C55E),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (perfecto
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF22C55E))
                .withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: perfecto
                  ? const Color(0xFFD97706)
                  : const Color(0xFF15803D),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.tr(tituloHito),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _PildoraEstadisticaDuolingo(
                icono: const Icon(
                  Icons.gps_fixed_rounded,
                  size: 18,
                  color: Color(0xFF15803D),
                ),
                etiqueta: context.tr('Precisión'),
                valor: '$porcentaje %',
                colorBorde: const Color(0xFF22C55E),
                colorTexto: const Color(0xFF14532D),
              ),
              _PildoraEstadisticaDuolingo(
                icono: IconoLlamaRacha(
                  tamano: 18,
                  activa: true,
                  intensa: mejorComboSesion >= 3,
                ),
                etiqueta: context.tr('Mejor racha'),
                valor: 'x${math.max(1, mejorComboSesion)}',
                colorBorde: const Color(0xFFEA580C),
                colorTexto: const Color(0xFF9A3412),
              ),
              _PildoraEstadisticaDuolingo(
                icono: const IconoSemilla(tamano: 18),
                etiqueta: context.tr('Semillas'),
                valor: '+$semillasGanadas',
                colorBorde: const Color(0xFFD97706),
                colorTexto: const Color(0xFF78350F),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PildoraEstadisticaDuolingo extends StatelessWidget {
  const _PildoraEstadisticaDuolingo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.colorBorde,
    required this.colorTexto,
  });

  final Widget icono;
  final String etiqueta;
  final String valor;
  final Color colorBorde;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorBorde, width: 2),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withValues(alpha: 0.18),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icono,
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  etiqueta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: colorTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
