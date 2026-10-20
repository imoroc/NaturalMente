import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/planta.dart';
import 'package:naturalmente/ui/escena_ecosistema.dart';
import 'package:naturalmente/ui/texto.dart';

// Componentes visuales de la app: medallas circulares/redondeadas para que
// los stickers luzcan integrados sin bordes cuadrados, más paisajes vectoriales.

class DibujoMascota extends StatelessWidget {
  const DibujoMascota({this.gesto = 'hola', this.tamano = 56, super.key});

  final String gesto;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final nombre = switch (gesto) {
      'feliz' => 'brote_feliz',
      'pista' => 'brote_pista',
      'pensando' => 'brote_pensando',
      _ => 'brote_hola',
    };
    final colorBorde = switch (gesto) {
      'feliz' => const Color(0xFF2ECC71),
      'pista' => const Color(0xFFFF9F1C),
      'pensando' => const Color(0xFFFFB703),
      _ => const Color(0xFF2ECC71),
    };
    return Container(
      width: tamano,
      height: tamano,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: colorBorde, width: 3),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withValues(alpha: 0.28),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/imagenes/$nombre.png',
          cacheWidth: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const _BroteRespaldo(),
        ),
      ),
    );
  }
}

class Criatura extends StatelessWidget {
  const Criatura({required this.id, super.key});

  final String id;

  static const _organosCuerpo = {
    'corazon',
    'pulmones',
    'estomago',
    'cerebro',
    'esqueleto',
    'intestinos',
  };

  @override
  Widget build(BuildContext context) {
    if (_organosCuerpo.contains(id)) {
      return Container(
        width: 88,
        height: 88,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFD0C9B8),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(child: IconoOrgano(id: id, size: 68)),
      );
    }

    final respaldo = switch (id) {
      'delfin' => const _Delfin(),
      'pinguino' => const _Pinguino(),
      'oso' => const _Oso(),
      'rana' => const _Rana(),
      'tucan' => const _Tucan(),
      'pulpo' => const _Pulpo(),
      _ => const _Camello(),
    };
    const conImagen = {
      'camello',
      'delfin',
      'pinguino',
      'oso',
      'rana',
      'tucan',
    };
    return Container(
      width: 88,
      height: 88,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD0C9B8),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: conImagen.contains(id)
            ? Image.asset(
                'assets/imagenes/$id.png',
                cacheWidth: 240,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Center(child: respaldo),
              )
            : Center(child: respaldo),
      ),
    );
  }
}

class IconoSitio extends StatelessWidget {
  const IconoSitio({required this.id, super.key});

  final String id;

  static const _zonasCuerpo = {'cabeza', 'pecho', 'barriga', 'extremidades'};

  @override
  Widget build(BuildContext context) {
    if (_zonasCuerpo.contains(id)) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: _colorDestaqueZona(id).withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: CustomPaint(
          painter: _PintorZonaCuerpo(zona: id),
        ),
      );
    }

    final datos = switch (id) {
      'desierto' => (Icons.wb_sunny_rounded, const Color(0xFFD97706)),
      'mar' => (Icons.waves_rounded, const Color(0xFF0284C7)),
      'polo' => (Icons.ac_unit_rounded, const Color(0xFF0369A1)),
      'bosque' => (Icons.park_rounded, const Color(0xFF15803D)),
      'selva' => (Icons.forest_rounded, const Color(0xFF059669)),
      'rio' => (Icons.water_rounded, const Color(0xFF0891B2)),
      _ => (Icons.explore_rounded, const Color(0xFF15803D)),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        shape: BoxShape.circle,
      ),
      child: Icon(datos.$1, color: datos.$2, size: 24),
    );
  }

  static Color _colorDestaqueZona(String id) => switch (id) {
    'cabeza' => const Color(0xFF8B5CF6),
    'pecho' => const Color(0xFFE11D48),
    'barriga' => const Color(0xFFD97706),
    'extremidades' => const Color(0xFF0284C7),
    _ => const Color(0xFF15803D),
  };
}

class _PintorZonaCuerpo extends CustomPainter {
  const _PintorZonaCuerpo({required this.zona});

  final String zona;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final pBase = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;
    final pBorde = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final colorZona = IconoSitio._colorDestaqueZona(zona);
    final pActivo = Paint()
      ..color = colorZona
      ..style = PaintingStyle.fill;
    final pHalo = Paint()
      ..color = colorZona.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final esCabeza = zona == 'cabeza';
    final esPecho = zona == 'pecho';
    final esBarriga = zona == 'barriga';
    final esExtremidades = zona == 'extremidades';

    // Brazos y piernas (extremidades)
    final brazoIzq = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.34, h * 0.28, w * 0.12, h * 0.34),
      const Radius.circular(6),
    );
    final brazoDer = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + w * 0.22, h * 0.28, w * 0.12, h * 0.34),
      const Radius.circular(6),
    );
    final piernaIzq = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.18, h * 0.62, w * 0.14, h * 0.33),
      const Radius.circular(6),
    );
    final piernaDer = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx + w * 0.04, h * 0.62, w * 0.14, h * 0.33),
      const Radius.circular(6),
    );

    if (esExtremidades) {
      for (final r in [brazoIzq, brazoDer, piernaIzq, piernaDer]) {
        canvas.drawRRect(r.inflate(2.2), pHalo);
      }
    }
    for (final r in [brazoIzq, brazoDer, piernaIzq, piernaDer]) {
      canvas.drawRRect(r, esExtremidades ? pActivo : pBase);
      canvas.drawRRect(r, pBorde);
    }

    // Tronco completo (pecho + barriga)
    final tronco = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.20, h * 0.27, w * 0.40, h * 0.37),
      const Radius.circular(8),
    );
    canvas.drawRRect(tronco, pBase);

    // Zona Pecho (mitad superior del tronco)
    final rectPecho = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - w * 0.20, h * 0.27, w * 0.40, h * 0.19),
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    );
    if (esPecho) {
      canvas.drawRRect(rectPecho.inflate(2.5), pHalo);
      canvas.drawRRect(rectPecho, pActivo);
      // Costillas sutiles
      final pCostilla = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx - 3.5, h * 0.36), width: 6, height: 7),
        0.5,
        2.2,
        false,
        pCostilla,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx + 3.5, h * 0.36), width: 6, height: 7),
        0.4,
        2.2,
        false,
        pCostilla,
      );
    }

    // Zona Barriga (mitad inferior del tronco)
    final rectBarriga = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - w * 0.20, h * 0.45, w * 0.40, h * 0.19),
      bottomLeft: const Radius.circular(8),
      bottomRight: const Radius.circular(8),
    );
    if (esBarriga) {
      canvas.drawRRect(rectBarriga.inflate(2.5), pHalo);
      canvas.drawRRect(rectBarriga, pActivo);
      canvas.drawCircle(
        Offset(cx, h * 0.55),
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    canvas.drawRRect(tronco, pBorde);

    // Cabeza
    final centroCabeza = Offset(cx, h * 0.15);
    final radioCabeza = w * 0.14;
    if (esCabeza) {
      canvas.drawCircle(centroCabeza, radioCabeza + 3, pHalo);
    }
    canvas.drawCircle(centroCabeza, radioCabeza, esCabeza ? pActivo : pBase);
    canvas.drawCircle(centroCabeza, radioCabeza, pBorde);
  }

  @override
  bool shouldRepaint(covariant _PintorZonaCuerpo oldDelegate) =>
      oldDelegate.zona != zona;
}

class DibujoSemilla extends StatelessWidget {
  const DibujoSemilla({
    required this.estado,
    this.agua,
    this.luz,
    this.suelo,
    this.temperatura,
    this.etapaGerminacion = 4,
    this.compacto = false,
    super.key,
  });

  final String estado;
  final String? agua;
  final String? luz;
  final String? suelo;
  final String? temperatura;
  final int etapaGerminacion;
  final bool compacto;

  (String, IconData, Color, Color) _infoEstado() {
    final etiquetaFase = switch (etapaGerminacion) {
      1 => 'Día 1 · Semilla en la maceta',
      2 => 'Día 3 · Asoma la primera raíz (radícula)',
      3 => 'Día 5 · Sube el talluelo a la superficie',
      _ => 'Día 7 · Planta crecida con hojas',
    };
    return switch (estado) {
      'brote' => (
        switch (etapaGerminacion) {
          1 => 'Día 1 · La semilla se hincha con el agua',
          2 => 'Día 3 · Asoma la raíz blanca hacia abajo',
          3 => 'Día 5 · Sube el tallo buscando la luz',
          _ => 'Día 7 · ¡Planta fuerte en tierra de jardín!',
        },
        Icons.eco_rounded,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
      ),
      'broteAlgodon' => (
        'Día 7 · ¡Germinó en el algodón húmedo!',
        Icons.cloud_done_rounded,
        const Color(0xFF0369A1),
        const Color(0xFFE0F2FE),
      ),
      'ahogada' => (
        '$etiquetaFase · Demasiada agua (sin aire)',
        Icons.water_drop_rounded,
        const Color(0xFF0369A1),
        const Color(0xFFE0F2FE),
      ),
      'sinAgarre' => (
        '$etiquetaFase · Entre piedras se escapa el agua',
        Icons.grain_rounded,
        const Color(0xFF57534E),
        const Color(0xFFF5F5F4),
      ),
      'sedienta' => (
        'Día 3 · La arena deja escapar el agua de la raíz',
        Icons.hourglass_bottom_rounded,
        const Color(0xFFB45309),
        const Color(0xFFFEF3C7),
      ),
      'seca' => (
        '$etiquetaFase · Falta darle un riego suave hoy',
        Icons.opacity_rounded,
        const Color(0xFF9A3412),
        const Color(0xFFFFEDD5),
      ),
      'palida' => (
        etapaGerminacion >= 4
            ? 'Día 7 · Creció alta pero amarilla sin sol'
            : 'Día 5 · Tallo pálido por tener la cortina cerrada',
        Icons.wb_twilight_rounded,
        const Color(0xFFA16207),
        const Color(0xFFFEF9C3),
      ),
      'helada' => (
        '$etiquetaFase · A 4 °C el frío frena la planta',
        Icons.ac_unit_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
      ),
      'achicharrada' => (
        '$etiquetaFase · Demasiado calor evapora el agua',
        Icons.wb_sunny_rounded,
        const Color(0xFFC2410C),
        const Color(0xFFFFEDD5),
      ),
      _ => (
        etiquetaFase,
        Icons.biotech_rounded,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
      ),
    };
  }

  String? _medidorAgua() {
    return switch (agua) {
      'poca' => 'Sin regar',
      'justa' => 'Riego suave',
      'mucha' => 'Demasiada agua',
      _ => null,
    };
  }

  String? _medidorTemp() {
    return switch (temperatura) {
      'fria' => '4 °C',
      'templada' => '20 °C',
      'calor' => '42 °C',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (compacto) {
      return SizedBox(
        width: 96,
        height: 96,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF86EFAC), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CustomPaint(
              painter: _PintorTerrarioSemilla(
                estado: estado,
                agua: agua ?? 'justa',
                luz: luz ?? 'justa',
                suelo: suelo ?? 'huerto',
                temperatura: temperatura ?? 'templada',
                etapaGerminacion: etapaGerminacion,
              ),
            ),
          ),
        ),
      );
    }

    final (etiqueta, icono, colorTexto, colorFondo) = _infoEstado();
    final textoAgua = _medidorAgua();
    final textoTemp = _medidorTemp();
    final colorBorde = switch (estado) {
      'brote' || 'broteAlgodon' => const Color(0xFF22C55E),
      'ahogada' || 'helada' => const Color(0xFF38BDF8),
      'palida' || 'sedienta' => const Color(0xFFFBBF24),
      'seca' || 'achicharrada' => const Color(0xFFFB923C),
      'sinAgarre' => const Color(0xFFA8A29E),
      _ => const Color(0xFF86EFAC),
    };

    return Container(
      height: 162,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorBorde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withValues(alpha: 0.28),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _PintorTerrarioSemilla(
                estado: estado,
                agua: agua,
                luz: luz,
                suelo: suelo,
                temperatura: temperatura,
                etapaGerminacion: etapaGerminacion,
              ),
            ),
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorFondo.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: colorTexto.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icono, size: 15, color: colorTexto),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Texto(
                              etiqueta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: colorTexto,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (textoAgua != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF38BDF8)),
                      ),
                      child: Texto(
                        textoAgua,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                  ],
                  if (textoTemp != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA).withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF2DD4BF)),
                      ),
                      child: Texto(
                        textoTemp,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PintorTerrarioSemilla extends CustomPainter {
  const _PintorTerrarioSemilla({
    required this.estado,
    this.agua,
    this.luz,
    this.suelo,
    this.temperatura,
    this.etapaGerminacion = 4,
  });

  final String estado;
  final String? agua;
  final String? luz;
  final String? suelo;
  final String? temperatura;
  final int etapaGerminacion;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sueloY = h * 0.58;

    final luzEfectiva = switch (estado) {
      'palida' => 'poca',
      'achicharrada' => luz == 'excesiva' ? 'excesiva' : (luz ?? 'justa'),
      'brote' || 'broteAlgodon' => luz ?? 'justa',
      _ => luz ?? 'justa',
    };
    final aguaEfectiva = switch (estado) {
      'ahogada' => 'mucha',
      'seca' => 'poca',
      'brote' || 'broteAlgodon' => 'justa',
      _ => agua,
    };
    final sueloEfectivo = switch (estado) {
      'sinAgarre' => 'piedras',
      'sedienta' => 'arena',
      'broteAlgodon' => 'algodon',
      _ => suelo ?? 'huerto',
    };
    final tempEfectiva = switch (estado) {
      'helada' => 'fria',
      'achicharrada' =>
        temperatura == 'calor' ? 'calor' : (temperatura ?? 'templada'),
      _ => temperatura,
    };

    // 1. Cielo / fondo del invernadero según la luz y temperatura
    final coloresCielo = switch ((luzEfectiva, tempEfectiva)) {
      ('poca', _) => [const Color(0xFF1E293B), const Color(0xFF334155)],
      (_, 'fria') => [const Color(0xFFBAE6FD), const Color(0xFFE0F2FE)],
      ('excesiva', _) || (_, 'calor') => [
        const Color(0xFFFED7AA),
        const Color(0xFFFEF3C7),
      ],
      _ => [const Color(0xFFDCFCE7), const Color(0xFFF0FDF4)],
    };

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, sueloY + 4),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: coloresCielo,
        ).createShader(Rect.fromLTWH(0, 0, w, sueloY + 4)),
    );

    // Estructura sutil de cristal de invernadero
    final pCristal = Paint()
      ..color = Colors.white.withValues(
        alpha: luzEfectiva == 'poca' ? 0.08 : 0.45,
      )
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.22, 0), Offset(w * 0.22, sueloY), pCristal);
    canvas.drawLine(Offset(w * 0.78, 0), Offset(w * 0.78, sueloY), pCristal);

    // 2. Efecto de iluminación arriba a la derecha
    final solCentro = Offset(w * 0.84, h * 0.24);
    if (luzEfectiva == 'poca') {
      canvas.drawCircle(
        solCentro,
        14,
        Paint()..color = const Color(0xFF64748B).withValues(alpha: 0.45),
      );
      canvas.drawCircle(
        solCentro.translate(4, -3),
        12,
        Paint()..color = const Color(0xFF1E293B),
      );
    } else if (luzEfectiva == 'excesiva' || tempEfectiva == 'calor') {
      canvas.drawCircle(
        solCentro,
        28,
        Paint()..color = const Color(0xFFF97316).withValues(alpha: 0.24),
      );
      canvas.drawCircle(
        solCentro,
        16,
        Paint()..color = const Color(0xFFEA580C),
      );
    } else {
      final haz = Path()
        ..moveTo(solCentro.dx - 12, solCentro.dy)
        ..lineTo(solCentro.dx + 12, solCentro.dy)
        ..lineTo(w * 0.62, sueloY)
        ..lineTo(w * 0.36, sueloY)
        ..close();
      canvas.drawPath(
        haz,
        Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.22),
      );
      canvas.drawCircle(
        solCentro,
        20,
        Paint()..color = const Color(0xFFFACC15).withValues(alpha: 0.28),
      );
      canvas.drawCircle(
        solCentro,
        12,
        Paint()..color = const Color(0xFFEAB308),
      );
    }

    // 3. Corte transversal del sustrato (algodón, tierra de jardín, arena o piedras)
    final colorSueloTop = switch (sueloEfectivo) {
      'piedras' => const Color(0xFF78716C),
      'arena' => const Color(0xFFEAB308),
      'algodon' =>
        aguaEfectiva == 'poca'
            ? const Color(0xFFF8FAFC)
            : const Color(0xFFE0F2FE),
      _ =>
        aguaEfectiva == 'poca'
            ? const Color(0xFF8C6239)
            : const Color(0xFF5C3A21),
    };
    final colorSueloFondo = switch (sueloEfectivo) {
      'piedras' => const Color(0xFF57534E),
      'arena' => const Color(0xFFCA8A04),
      'algodon' =>
        aguaEfectiva == 'poca'
            ? const Color(0xFFE2E8F0)
            : const Color(0xFFBAE6FD),
      _ =>
        aguaEfectiva == 'poca'
            ? const Color(0xFF6B4423)
            : const Color(0xFF3E2723),
    };

    canvas.drawRect(
      Rect.fromLTWH(0, sueloY, w, h - sueloY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorSueloTop, colorSueloFondo],
        ).createShader(Rect.fromLTWH(0, sueloY, w, h - sueloY)),
    );

    // Texturas del sustrato elegido
    if (sueloEfectivo == 'algodon') {
      final pCopo = Paint()..color = Colors.white.withValues(alpha: 0.92);
      final pBordeCopo = Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (final (cxCopo, cyCopo, rCopo) in [
        (0.15, 0.66, 22.0),
        (0.28, 0.63, 24.0),
        (0.42, 0.65, 25.0),
        (0.58, 0.64, 25.0),
        (0.72, 0.63, 24.0),
        (0.85, 0.66, 22.0),
        (0.22, 0.80, 26.0),
        (0.40, 0.82, 28.0),
        (0.60, 0.82, 28.0),
        (0.78, 0.80, 26.0),
      ]) {
        final centro = Offset(w * cxCopo, h * cyCopo);
        canvas.drawCircle(centro, rCopo, pCopo);
        canvas.drawCircle(centro, rCopo, pBordeCopo);
      }
    } else if (sueloEfectivo == 'piedras') {
      final pPiedra = Paint()..color = const Color(0xFFA8A29E);
      final pPiedraOsc = Paint()..color = const Color(0xFF44403C);
      for (final (rx, ry, rw, rh) in [
        (0.14, 0.68, 28.0, 18.0),
        (0.28, 0.78, 34.0, 20.0),
        (0.45, 0.84, 30.0, 18.0),
        (0.64, 0.72, 32.0, 19.0),
        (0.80, 0.80, 28.0, 17.0),
        (0.36, 0.66, 22.0, 15.0),
        (0.60, 0.85, 26.0, 16.0),
      ]) {
        final rect = Rect.fromCenter(
          center: Offset(w * rx, h * ry),
          width: rw,
          height: rh,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          pPiedraOsc,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(1.5),
            const Radius.circular(7),
          ),
          pPiedra,
        );
      }
    } else if (sueloEfectivo == 'arena') {
      final pGrano = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: 0.65);
      for (var i = 0; i < 24; i++) {
        final gx = w * (0.08 + (i * 0.038) % 0.84);
        final gy = sueloY + 8 + ((i * 17) % (h - sueloY - 14));
        canvas.drawCircle(Offset(gx, gy), 1.8, pGrano);
      }
      if (aguaEfectiva == 'justa' || estado == 'sedienta') {
        final pFuga = Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.75);
        for (final dx in [0.42, 0.50, 0.58]) {
          canvas.drawCircle(Offset(w * dx, h * 0.90), 3.0, pFuga);
        }
      }
    } else {
      final pHumus = Paint()
        ..color = const Color(0xFF27170E).withValues(alpha: 0.45);
      for (final (hx, hy, r) in [
        (0.18, 0.70, 3.0),
        (0.32, 0.82, 2.5),
        (0.68, 0.74, 3.2),
        (0.76, 0.86, 2.4),
        (0.24, 0.88, 2.8),
        (0.84, 0.68, 2.6),
      ]) {
        canvas.drawCircle(Offset(w * hx, h * hy), r, pHumus);
      }
    }

    // Grietas si falta agua en tierra
    if (sueloEfectivo != 'algodon' &&
        (aguaEfectiva == 'poca' ||
            estado == 'seca' ||
            estado == 'achicharrada')) {
      final pGrieta = Paint()
        ..color = const Color(0xFF27170E).withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final grieta1 = Path()
        ..moveTo(w * 0.25, sueloY)
        ..lineTo(w * 0.22, sueloY + 14)
        ..lineTo(w * 0.27, sueloY + 26);
      final grieta2 = Path()
        ..moveTo(w * 0.74, sueloY)
        ..lineTo(w * 0.77, sueloY + 15)
        ..lineTo(w * 0.72, sueloY + 28);
      canvas.drawPath(grieta1, pGrieta);
      canvas.drawPath(grieta2, pGrieta);
    }

    // 4. Efecto de agua (chorritos o encharcamiento)
    if (aguaEfectiva == 'mucha' || estado == 'ahogada') {
      canvas.drawRect(
        Rect.fromLTWH(0, sueloY - 12, w, h - sueloY + 12),
        Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.42),
      );
      final pBurbuja = Paint()
        ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(w * 0.44, sueloY + 10), 3.5, pBurbuja);
      canvas.drawCircle(Offset(w * 0.56, sueloY + 4), 2.5, pBurbuja);
    } else if (aguaEfectiva == 'justa') {
      final pGota = Paint()..color = const Color(0xFF0EA5E9);
      for (final (gx, gy) in [
        (0.45, sueloY - 16),
        (0.50, sueloY - 10),
        (0.55, sueloY - 18),
      ]) {
        canvas.drawCircle(Offset(w * gx, gy), 2.6, pGota);
      }
    }

    // Escarcha si la temperatura es helada
    if (tempEfectiva == 'fria' || estado == 'helada') {
      canvas.drawRect(
        Rect.fromLTWH(0, sueloY - 3, w, 6),
        Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.85),
      );
    }

    // 5. La semilla o la planta en la etapa alcanzada (1, 2, 3 o 4)
    final cx = w * 0.5;
    final semillaY = sueloY + (h - sueloY) * 0.36;

    if (etapaGerminacion >= 4 && (estado == 'palida' || luzEfectiva == 'poca')) {
      _pintarPlantulaPalida(canvas, cx, sueloY, semillaY);
    } else if (etapaGerminacion >= 2) {
      _pintarPlantulaPorEtapa(canvas, cx, sueloY, semillaY, h);
    } else if (estado == 'brote' || estado == 'broteAlgodon') {
      _pintarPlantulaPorEtapa(canvas, cx, sueloY, semillaY, h);
    } else {
      _pintarSemilla(canvas, cx, semillaY, estado);
    }
  }

  void _pintarSemilla(Canvas canvas, double cx, double cy, String estadoActual) {
    final pSombra = Paint()..color = Colors.black.withValues(alpha: 0.22);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 9), width: 28, height: 10),
      pSombra,
    );

    final colorSemilla = switch (estadoActual) {
      'ahogada' => const Color(0xFF64748B),
      'helada' => const Color(0xFF93C5FD),
      'achicharrada' => const Color(0xFF7C2D12),
      _ => const Color(0xFFD97706),
    };
    final rectSemilla = Rect.fromCenter(
      center: Offset(cx, cy),
      width: 26,
      height: 17,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectSemilla, const Radius.circular(10)),
      Paint()..color = colorSemilla,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectSemilla, const Radius.circular(10)),
      Paint()
        ..color = const Color(0xFF78350F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 8, height: 3.5),
      Paint()..color = const Color(0xFFFEF3C7),
    );
  }

  void _pintarPlantulaPalida(
    Canvas canvas,
    double cx,
    double sueloY,
    double semillaY,
  ) {
    final pRaiz = Paint()
      ..color = const Color(0xFFD6D3D1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, semillaY), Offset(cx - 8, semillaY + 16), pRaiz);
    canvas.drawLine(Offset(cx, semillaY), Offset(cx + 6, semillaY + 14), pRaiz);

    final pTallo = Paint()
      ..color = const Color(0xFFFDE047)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tallo = Path()
      ..moveTo(cx, semillaY)
      ..quadraticBezierTo(cx - 16, sueloY - 22, cx + 18, sueloY - 44);
    canvas.drawPath(tallo, pTallo);

    final pHoja = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 22, sueloY - 44),
        width: 16,
        height: 9,
      ),
      pHoja,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 8, sueloY - 46),
        width: 14,
        height: 8,
      ),
      pHoja,
    );
  }

  void _pintarPlantulaPorEtapa(
    Canvas canvas,
    double cx,
    double sueloY,
    double semillaY,
    double h,
  ) {
    if (etapaGerminacion == 1) {
      final rectHinchada = Rect.fromCenter(
        center: Offset(cx, semillaY),
        width: 32,
        height: 21,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectHinchada, const Radius.circular(12)),
        Paint()..color = const Color(0xFFEAB308),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rectHinchada, const Radius.circular(12)),
        Paint()
          ..color = const Color(0xFF854D0E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
      final pGrietaSemilla = Paint()
        ..color = const Color(0xFFFEF9C3)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + 5, semillaY - 2),
        Offset(cx + 13, semillaY + 4),
        pGrietaSemilla,
      );
      return;
    }

    if (etapaGerminacion == 2) {
      _pintarSemilla(canvas, cx, semillaY, estado);
      final colorRaiz = (estado == 'seca' || estado == 'sedienta')
          ? const Color(0xFFFDE68A)
          : const Color(0xFFF5F5F4);
      final pRadicula = Paint()
        ..color = colorRaiz
        ..strokeWidth = 4.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final radicula = Path()
        ..moveTo(cx + 8, semillaY + 4)
        ..quadraticBezierTo(cx + 12, semillaY + 14, cx + 2, h - 8);
      canvas.drawPath(radicula, pRadicula);
      return;
    }

    final pRaiz = Paint()
      ..color = const Color(0xFF78350F).withValues(alpha: 0.75)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final pRaizSec = Paint()
      ..color = const Color(0xFF92400E).withValues(alpha: 0.65)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final raizPrincipal = Path()
      ..moveTo(cx, sueloY + 4)
      ..quadraticBezierTo(cx + 3, semillaY + 8, cx - 2, h - 8);
    canvas.drawPath(raizPrincipal, pRaiz);

    for (final (ox, oy, dx, dy) in [
      (cx, sueloY + 14, cx - 22, sueloY + 26),
      (cx + 1, sueloY + 20, cx + 24, sueloY + 32),
      (cx - 1, sueloY + 30, cx - 18, h - 10),
      (cx + 1, sueloY + 34, cx + 19, h - 12),
    ]) {
      canvas.drawLine(Offset(ox, oy), Offset(dx, dy), pRaizSec);
    }

    if (etapaGerminacion == 3) {
      final esPalida = estado == 'palida' || luz == 'poca';
      final pTalluelo = Paint()
        ..color = esPalida ? const Color(0xFFFACC15) : const Color(0xFF4ADE80)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final arco = Path()
        ..moveTo(cx, sueloY + 6)
        ..quadraticBezierTo(cx - 10, sueloY - 26, cx + 8, sueloY - 18);
      canvas.drawPath(arco, pTalluelo);

      final pCotiledon = Paint()
        ..color = esPalida ? const Color(0xFFFDE047) : const Color(0xFF84CC16);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + 11, sueloY - 18),
          width: 16,
          height: 11,
        ),
        pCotiledon,
      );
      return;
    }

    final topeTalloY = sueloY - 50;
    final pTallo = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 5.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tallo = Path()
      ..moveTo(cx, sueloY + 6)
      ..quadraticBezierTo(cx - 3, sueloY - 22, cx, topeTalloY);
    canvas.drawPath(tallo, pTallo);

    // Cotiledones abiertos junto a la base del tallo
    final pCotiledon = Paint()..color = const Color(0xFF65A30D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 9, sueloY - 12),
        width: 12,
        height: 7,
      ),
      pCotiledon,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + 9, sueloY - 12),
        width: 12,
        height: 7,
      ),
      pCotiledon,
    );

    // Dos hojas verdes grandes fabricando alimento con la luz
    _pintarHoja(
      canvas,
      origen: Offset(cx - 2, topeTalloY + 8),
      punta: Offset(cx - 34, topeTalloY - 8),
      controlSup: Offset(cx - 18, topeTalloY - 18),
      controlInf: Offset(cx - 20, topeTalloY + 14),
    );
    _pintarHoja(
      canvas,
      origen: Offset(cx + 2, topeTalloY + 6),
      punta: Offset(cx + 34, topeTalloY - 10),
      controlSup: Offset(cx + 18, topeTalloY - 20),
      controlInf: Offset(cx + 20, topeTalloY + 12),
    );
  }

  void _pintarHoja(
    Canvas canvas, {
    required Offset origen,
    required Offset punta,
    required Offset controlSup,
    required Offset controlInf,
  }) {
    final hoja = Path()
      ..moveTo(origen.dx, origen.dy)
      ..quadraticBezierTo(controlSup.dx, controlSup.dy, punta.dx, punta.dy)
      ..quadraticBezierTo(controlInf.dx, controlInf.dy, origen.dx, origen.dy)
      ..close();
    canvas.drawPath(hoja, Paint()..color = const Color(0xFF22C55E));
    canvas.drawPath(
      hoja,
      Paint()
        ..color = const Color(0xFF15803D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    canvas.drawLine(
      origen,
      Offset((origen.dx + punta.dx) * 0.5, (origen.dy + punta.dy) * 0.5),
      Paint()
        ..color = const Color(0xFFBBF7D0)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorTerrarioSemilla oldDelegate) {
    return oldDelegate.estado != estado ||
        oldDelegate.agua != agua ||
        oldDelegate.luz != luz ||
        oldDelegate.suelo != suelo ||
        oldDelegate.temperatura != temperatura ||
        oldDelegate.etapaGerminacion != etapaGerminacion;
  }
}

class _BroteRespaldo extends StatelessWidget {
  const _BroteRespaldo();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF2ECC71),
      child: Center(child: Icon(Icons.eco, color: Colors.white)),
    );
  }
}

class _Camello extends StatelessWidget {
  const _Camello();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 72,
      height: 48,
      child: Stack(
        children: [
          Positioned(left: 8, bottom: 4, child: _Ovalo(width: 48, height: 22, color: Color(0xFFC4843C))),
          Positioned(left: 20, bottom: 18, child: _Ovalo(width: 18, height: 14, color: Color(0xFFA86B2C))),
          Positioned(left: 48, bottom: 18, child: _Ovalo(width: 10, height: 18, color: Color(0xFFC4843C))),
        ],
      ),
    );
  }
}

class _Delfin extends StatelessWidget {
  const _Delfin();

  @override
  Widget build(BuildContext context) {
    return const _Ovalo(width: 60, height: 20, color: Color(0xFF4F7C8A));
  }
}

class _Pinguino extends StatelessWidget {
  const _Pinguino();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 32,
      height: 50,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _Ovalo(width: 28, height: 44, color: Color(0xFF1E2A32)),
          Positioned(bottom: 6, child: _Ovalo(width: 14, height: 26, color: Color(0xFFF4F7FB))),
        ],
      ),
    );
  }
}

class _Oso extends StatelessWidget {
  const _Oso();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 64,
      height: 44,
      child: Stack(
        children: [
          Positioned(left: 6, bottom: 0, child: _Ovalo(width: 44, height: 26, color: Color(0xFF7A4E2D))),
          Positioned(left: 40, bottom: 16, child: _Ovalo(width: 18, height: 18, color: Color(0xFF7A4E2D))),
        ],
      ),
    );
  }
}

class _Rana extends StatelessWidget {
  const _Rana();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 66,
      height: 54,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 2,
            child: _Ovalo(width: 58, height: 14, color: Color(0xFF16A34A)),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: _Ovalo(width: 18, height: 16, color: Color(0xFF22C55E)),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: _Ovalo(width: 18, height: 16, color: Color(0xFF22C55E)),
          ),
          Positioned(
            bottom: 8,
            child: _Ovalo(width: 38, height: 28, color: Color(0xFF4ADE80)),
          ),
          Positioned(
            bottom: 10,
            child: _Ovalo(width: 24, height: 16, color: Color(0xFFFEF08A)),
          ),
          Positioned(
            left: 17,
            top: 8,
            child: _Ovalo(width: 13, height: 13, color: Color(0xFF22C55E)),
          ),
          Positioned(
            right: 17,
            top: 8,
            child: _Ovalo(width: 13, height: 13, color: Color(0xFF22C55E)),
          ),
          Positioned(
            left: 20,
            top: 10,
            child: _Ovalo(width: 7, height: 7, color: Color(0xFF1E293B)),
          ),
          Positioned(
            right: 20,
            top: 10,
            child: _Ovalo(width: 7, height: 7, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}

class _Tucan extends StatelessWidget {
  const _Tucan();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 68,
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 6,
            bottom: 4,
            child: _Ovalo(width: 20, height: 12, color: Color(0xFF334155)),
          ),
          Positioned(
            left: 12,
            bottom: 6,
            child: _Ovalo(width: 28, height: 42, color: Color(0xFF1E293B)),
          ),
          Positioned(
            left: 22,
            top: 14,
            child: _Ovalo(width: 16, height: 18, color: Color(0xFFFACC15)),
          ),
          Positioned(
            left: 34,
            top: 12,
            child: _Ovalo(width: 28, height: 15, color: Color(0xFFF97316)),
          ),
          Positioned(
            left: 54,
            top: 14,
            child: _Ovalo(width: 8, height: 11, color: Color(0xFF0F172A)),
          ),
          Positioned(
            left: 24,
            top: 14,
            child: _Ovalo(width: 8, height: 8, color: Color(0xFF38BDF8)),
          ),
          Positioned(
            left: 26,
            top: 16,
            child: _Ovalo(width: 4, height: 4, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}

class _Pulpo extends StatelessWidget {
  const _Pulpo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 62,
      child: CustomPaint(painter: _PulpoPainter()),
    );
  }
}

class _PulpoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final pTentaculo = Paint()
      ..color = const Color(0xFFC026D3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.4
      ..strokeCap = StrokeCap.round;
    final pVentosa = Paint()..color = const Color(0xFFF5D0FE);

    // 8 tentáculos curvados hacia los lados y abajo
    final tentaculos = [
      (Offset(cx - 10, h * 0.50), Offset(w * 0.10, h * 0.62), Offset(w * 0.08, h * 0.80)),
      (Offset(cx - 7, h * 0.54), Offset(w * 0.22, h * 0.78), Offset(w * 0.18, h * 0.92)),
      (Offset(cx - 3, h * 0.56), Offset(w * 0.36, h * 0.84), Offset(w * 0.34, h * 0.95)),
      (Offset(cx - 1, h * 0.56), Offset(w * 0.46, h * 0.82), Offset(w * 0.45, h * 0.94)),
      (Offset(cx + 1, h * 0.56), Offset(w * 0.54, h * 0.82), Offset(w * 0.55, h * 0.94)),
      (Offset(cx + 3, h * 0.56), Offset(w * 0.64, h * 0.84), Offset(w * 0.66, h * 0.95)),
      (Offset(cx + 7, h * 0.54), Offset(w * 0.78, h * 0.78), Offset(w * 0.82, h * 0.92)),
      (Offset(cx + 10, h * 0.50), Offset(w * 0.90, h * 0.62), Offset(w * 0.92, h * 0.80)),
    ];

    for (final t in tentaculos) {
      final path = Path()
        ..moveTo(t.$1.dx, t.$1.dy)
        ..quadraticBezierTo(t.$2.dx, t.$2.dy, t.$3.dx, t.$3.dy);
      canvas.drawPath(path, pTentaculo);
      canvas.drawCircle(
        Offset((t.$2.dx + t.$3.dx) / 2, (t.$2.dy + t.$3.dy) / 2),
        1.7,
        pVentosa,
      );
    }

    // Cabeza / manto bulboso del pulpo
    final manto = Rect.fromCenter(
      center: Offset(cx, h * 0.34),
      width: w * 0.52,
      height: h * 0.46,
    );
    canvas.drawOval(
      manto,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE879F9), Color(0xFFA21CAF)],
        ).createShader(manto),
    );
    canvas.drawOval(
      manto,
      Paint()
        ..color = const Color(0xFF701A75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Ojos expresivos
    for (final dx in [-6.5, 6.5]) {
      canvas.drawCircle(
        Offset(cx + dx, h * 0.38),
        4.2,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(cx + dx, h * 0.38),
        2.1,
        Paint()..color = const Color(0xFF1E1B4B),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _lienzoCuerpo = Size(400, 440);

const _recortesOrgano = <String, Rect>{
  'cerebro': Rect.fromLTWH(142, 16, 116, 76),
  'pulmones': Rect.fromLTWH(124, 126, 152, 118),
  'corazon': Rect.fromLTWH(166, 148, 76, 86),
  'estomago': Rect.fromLTWH(148, 218, 104, 56),
  'intestinos': Rect.fromLTWH(144, 258, 112, 58),
  'esqueleto': Rect.fromLTWH(76, 124, 248, 294),
};

class IconoOrgano extends StatelessWidget {
  const IconoOrgano({required this.id, this.size = 56, super.key});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _OrganoPainter(id: id)),
    );
  }
}

class _OrganoPainter extends CustomPainter {
  const _OrganoPainter({required this.id});

  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    final recorte = _recortesOrgano[id] ?? const Rect.fromLTWH(120, 120, 160, 160);
    final escala = math.min(
      size.width / recorte.width,
      size.height / recorte.height,
    );
    final dx = (size.width - recorte.width * escala) / 2 - recorte.left * escala;
    final dy =
        (size.height - recorte.height * escala) / 2 - recorte.top * escala;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(escala, escala);
    _pintarOrganoEnCuerpo(canvas, id, silueta: false, modoIcono: true);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrganoPainter oldDelegate) =>
      oldDelegate.id != id;
}

const _zonasCuerpoRects = <String, Rect>{
  'cabeza': Rect.fromLTWH(26, 8, 348, 106),
  'pecho': Rect.fromLTWH(26, 118, 348, 100),
  'barriga': Rect.fromLTWH(26, 222, 348, 90),
  'extremidades': Rect.fromLTWH(26, 316, 348, 114),
};

const _organosPorZona = <String, List<String>>{
  'cabeza': ['cerebro'],
  'pecho': ['corazon', 'pulmones'],
  'barriga': ['estomago', 'intestinos'],
  'extremidades': ['esqueleto'],
};

class CuerpoHerbario extends StatefulWidget {
  const CuerpoHerbario({
    required this.organosNivel,
    required this.colocados,
    required this.organoActual,
    required this.zonaDestacada,
    required this.aciertoZona,
    this.opciones = const [],
    this.onColocarEnZona,
    this.bloqueado = false,
    super.key,
  });

  final List<String> organosNivel;
  final Set<String> colocados;
  final String organoActual;
  final String? zonaDestacada;
  final bool aciertoZona;
  final List<Opcion> opciones;
  final void Function(String zonaId, {String? organoArrastrado})?
      onColocarEnZona;
  final bool bloqueado;

  @override
  State<CuerpoHerbario> createState() => _CuerpoHerbarioState();
}

class _CuerpoHerbarioState extends State<CuerpoHerbario> {
  String? _zonaHover;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final escala = math.min(
          size.width / _lienzoCuerpo.width,
          size.height / _lienzoCuerpo.height,
        );
        final dx = (size.width - _lienzoCuerpo.width * escala) / 2;
        final dy = (size.height - _lienzoCuerpo.height * escala) / 2;

        Rect escalar(Rect base) => Rect.fromLTWH(
          dx + base.left * escala,
          dy + base.top * escala,
          base.width * escala,
          base.height * escala,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CuerpoHerbarioPainter(
                  organosNivel: widget.organosNivel,
                  colocados: widget.colocados,
                  organoActual: widget.organoActual,
                  zonaDestacada: _zonaHover ?? widget.zonaDestacada,
                  aciertoZona: _zonaHover != null || widget.aciertoZona,
                ),
              ),
            ),
            for (var i = 0; i < widget.opciones.length; i++)
              _construirZonaInteractiva(
                opcion: widget.opciones[i],
                rect: escalar(
                  _zonasCuerpoRects[widget.opciones[i].id] ??
                      Rect.fromLTWH(40, 20.0 + i * 95, 320, 84),
                ),
                esIzquierda: i.isEven,
              ),
          ],
        );
      },
    );
  }

  Widget _construirZonaInteractiva({
    required Opcion opcion,
    required Rect rect,
    required bool esIzquierda,
  }) {
    final organosZona = (_organosPorZona[opcion.id] ?? const <String>[])
        .where((id) => widget.organosNivel.contains(id))
        .toList();
    final colocadosEnZona = organosZona
        .where((id) => widget.colocados.contains(id))
        .length;
    final zonaCompleta =
        organosZona.isNotEmpty && colocadosEnZona == organosZona.length;
    final destacada = widget.zonaDestacada == opcion.id;

    return Positioned.fromRect(
      rect: rect,
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) {
          if (widget.bloqueado) return false;
          if (_zonaHover != opcion.id) {
            setState(() => _zonaHover = opcion.id);
          }
          return true;
        },
        onLeave: (_) {
          if (_zonaHover == opcion.id) {
            setState(() => _zonaHover = null);
          }
        },
        onAcceptWithDetails: (details) {
          setState(() => _zonaHover = null);
          widget.onColocarEnZona?.call(
            opcion.id,
            organoArrastrado: details.data,
          );
        },
        builder: (context, candidatos, _) {
          final encima = candidatos.isNotEmpty || _zonaHover == opcion.id;
          final colorBorde = encima
              ? const Color(0xFF0284C7)
              : (zonaCompleta
                    ? const Color(0xFF16A34A)
                    : (destacada
                          ? (widget.aciertoZona
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFF59E0B))
                          : const Color(0xFF94A3B8)));
          final colorFondoEtiqueta = encima
              ? const Color(0xFFE0F2FE)
              : (zonaCompleta
                    ? const Color(0xFFDCFCE7)
                    : (destacada
                          ? (widget.aciertoZona
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7))
                          : Colors.white.withValues(alpha: 0.92)));

          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('sitio-${opcion.id}'),
              borderRadius: BorderRadius.circular(18),
              onTap: widget.bloqueado
                  ? null
                  : () => widget.onColocarEnZona?.call(opcion.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: encima
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: encima
                        ? const Color(0xFF0284C7)
                        : (destacada
                              ? colorBorde.withValues(alpha: 0.75)
                              : Colors.transparent),
                    width: encima ? 2.5 : 1.8,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Align(
                  alignment: esIzquierda
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: AnimatedScale(
                    scale: encima ? 1.07 : 1.0,
                    duration: const Duration(milliseconds: 140),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 132),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorFondoEtiqueta,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: colorBorde, width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            zonaCompleta
                                ? Icons.check_circle_rounded
                                : (encima
                                      ? Icons.add_circle_rounded
                                      : Icons.place_rounded),
                            size: 15,
                            color: zonaCompleta
                                ? const Color(0xFF15803D)
                                : const Color(0xFF0369A1),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Texto(
                                  opcion.nombre,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                if (organosZona.isNotEmpty)
                                  Texto(
                                    zonaCompleta
                                        ? '¡Completa!'
                                        : '$colocadosEnZona/${organosZona.length} colocados',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: zonaCompleta
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFF475569),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

class _CuerpoHerbarioPainter extends CustomPainter {
  const _CuerpoHerbarioPainter({
    required this.organosNivel,
    required this.colocados,
    required this.organoActual,
    required this.zonaDestacada,
    required this.aciertoZona,
  });

  final List<String> organosNivel;
  final Set<String> colocados;
  final String organoActual;
  final String? zonaDestacada;
  final bool aciertoZona;

  @override
  void paint(Canvas canvas, Size size) {
    final escala = math.min(
      size.width / _lienzoCuerpo.width,
      size.height / _lienzoCuerpo.height,
    );
    final dx = (size.width - _lienzoCuerpo.width * escala) / 2;
    final dy = (size.height - _lienzoCuerpo.height * escala) / 2;

    _pintarFondoLaboratorio(canvas, size);

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(escala, escala);

    _pintarSiluetaHumanaBase(canvas, zonaDestacada, aciertoZona);

    // Orden de capas anatómicas (del fondo al frente)
    const ordenCapas = [
      'esqueleto',
      'pulmones',
      'intestinos',
      'estomago',
      'corazon',
      'cerebro',
    ];

    for (final id in ordenCapas) {
      if (!organosNivel.contains(id)) continue;
      if (colocados.contains(id)) continue;
      _pintarHuecoOrgano(canvas, id, destacado: id == organoActual);
    }

    for (final id in ordenCapas) {
      if (!organosNivel.contains(id)) continue;
      if (!colocados.contains(id)) continue;
      _pintarOrganoEnCuerpo(canvas, id, silueta: false, modoIcono: false);
    }

    canvas.restore();
  }

  void _pintarFondoLaboratorio(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDFBF6), Color(0xFFF2ECE1)],
        ).createShader(rect),
    );

    // Cuadrícula científica sutil tipo atlas anatómico
    final pGrid = Paint()
      ..color = const Color(0xFFE2D9C5).withValues(alpha: 0.45)
      ..strokeWidth = 1;
    const paso = 28.0;
    for (var x = paso; x < size.width; x += paso) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), pGrid);
    }
    for (var y = paso; y < size.height; y += paso) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), pGrid);
    }
  }

  void _pintarSiluetaHumanaBase(
    Canvas canvas,
    String? zonaActiva,
    bool acierto,
  ) {
    // Sombra en el suelo
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(200, 424), width: 156, height: 18),
      Paint()..color = const Color(0xFFD5CCB8).withValues(alpha: 0.55),
    );

    // Brazos y manos
    final brazoIzq = Path()
      ..moveTo(138, 128)
      ..cubicTo(110, 134, 94, 168, 86, 218)
      ..cubicTo(82, 240, 88, 254, 98, 256)
      ..cubicTo(108, 258, 114, 244, 120, 216)
      ..cubicTo(126, 188, 134, 166, 142, 154)
      ..close();
    final brazoDer = Path()
      ..moveTo(262, 128)
      ..cubicTo(290, 134, 306, 168, 314, 218)
      ..cubicTo(318, 240, 312, 254, 302, 256)
      ..cubicTo(292, 258, 286, 244, 280, 216)
      ..cubicTo(274, 188, 266, 166, 258, 154)
      ..close();

    // Piernas
    final piernaIzq = Path()
      ..moveTo(154, 294)
      ..lineTo(148, 404)
      ..quadraticBezierTo(148, 418, 164, 418)
      ..quadraticBezierTo(180, 418, 182, 404)
      ..lineTo(190, 304)
      ..close();
    final piernaDer = Path()
      ..moveTo(246, 294)
      ..lineTo(252, 404)
      ..quadraticBezierTo(252, 418, 236, 418)
      ..quadraticBezierTo(220, 418, 218, 404)
      ..lineTo(210, 304)
      ..close();

    final colorPiel = [const Color(0xFFFDE5C6), const Color(0xFFF5C59A)];
    const bordePiel = Color(0xFFA36E49);

    for (final p in [brazoIzq, brazoDer, piernaIzq, piernaDer]) {
      _rellenarCuerpo(canvas, p, colorPiel, borde: bordePiel, sombra: false);
    }

    // Tronco y cuello
    final tronco = Path()
      ..moveTo(182, 102)
      ..lineTo(218, 102)
      ..lineTo(222, 120)
      ..cubicTo(254, 122, 268, 138, 266, 174)
      ..lineTo(258, 284)
      ..cubicTo(256, 304, 236, 314, 200, 314)
      ..cubicTo(164, 314, 144, 304, 142, 284)
      ..lineTo(134, 174)
      ..cubicTo(132, 138, 146, 122, 178, 120)
      ..close();
    _rellenarCuerpo(canvas, tronco, colorPiel, borde: bordePiel);

    // Ventana anatómica interior (pecho + barriga) estilo lámina de herbario
    final cavidadTorso = RRect.fromRectAndRadius(
      const Rect.fromLTWH(144, 128, 112, 176),
      const Radius.circular(36),
    );
    canvas.drawRRect(
      cavidadTorso,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF7F0), Color(0xFFFCE8D8)],
        ).createShader(cavidadTorso.outerRect),
    );
    canvas.drawRRect(
      cavidadTorso,
      _lineaCuerpo(const Color(0xFFD9A784), 2.0),
    );

    // Línea divisoria del diafragma (separa Pecho y Barriga visualmente)
    final diafragma = Path()
      ..moveTo(148, 224)
      ..quadraticBezierTo(200, 212, 252, 224);
    canvas.drawPath(
      diafragma,
      _lineaCuerpo(const Color(0xFFD9A784).withValues(alpha: 0.7), 1.8),
    );

    // Cabeza y orejas
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(146, 68), width: 16, height: 22),
      Paint()..color = const Color(0xFFF5C59A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(254, 68), width: 16, height: 22),
      Paint()..color = const Color(0xFFF5C59A),
    );
    final cabeza = Path()
      ..addOval(Rect.fromCenter(center: const Offset(200, 62), width: 104, height: 102));
    _rellenarCuerpo(canvas, cabeza, colorPiel, borde: bordePiel);

    // Ventana craneal superior para el cerebro
    final cavidadCraneal = Path()
      ..addOval(Rect.fromCenter(center: const Offset(200, 46), width: 84, height: 52));
    canvas.drawPath(
      cavidadCraneal,
      Paint()..color = const Color(0xFFFFF7F0).withValues(alpha: 0.9),
    );
    canvas.drawPath(
      cavidadCraneal,
      _lineaCuerpo(const Color(0xFFD9A784), 1.6),
    );

    // Líneas guía punteadas hacia las etiquetas anatómicas laterales
    final pGuia = _lineaCuerpo(const Color(0xFF94A3B8).withValues(alpha: 0.45), 1.4);
    canvas.drawLine(const Offset(96, 58), const Offset(148, 58), pGuia);
    canvas.drawLine(const Offset(256, 170), const Offset(306, 170), pGuia);
    canvas.drawLine(const Offset(96, 266), const Offset(144, 266), pGuia);
    canvas.drawLine(const Offset(250, 362), const Offset(306, 362), pGuia);

    // Resaltado de zona cuando el usuario interactúa o arrastra un órgano encima
    if (zonaActiva != null) {
      final colorHalo = acierto
          ? const Color(0xFF22C55E)
          : const Color(0xFF38BDF8);
      final pHalo = Paint()
        ..color = colorHalo.withValues(alpha: 0.24)
        ..style = PaintingStyle.fill;
      final pBordeHalo = _lineaCuerpo(colorHalo, 3.2);
      switch (zonaActiva) {
        case 'cabeza':
          final r = Rect.fromCenter(center: const Offset(200, 62), width: 114, height: 110);
          canvas.drawOval(r, pHalo);
          canvas.drawOval(r, pBordeHalo);
        case 'pecho':
          final r = RRect.fromRectAndRadius(
            const Rect.fromLTWH(138, 124, 124, 98),
            const Radius.circular(26),
          );
          canvas.drawRRect(r, pHalo);
          canvas.drawRRect(r, pBordeHalo);
        case 'barriga':
          final r = RRect.fromRectAndRadius(
            const Rect.fromLTWH(138, 222, 124, 88),
            const Radius.circular(26),
          );
          canvas.drawRRect(r, pHalo);
          canvas.drawRRect(r, pBordeHalo);
        case 'extremidades':
          for (final p in [brazoIzq, brazoDer, piernaIzq, piernaDer]) {
            canvas.drawPath(p, pHalo);
            canvas.drawPath(p, pBordeHalo);
          }
      }
    }
  }

  void _pintarHuecoOrgano(Canvas canvas, String id, {required bool destacado}) {
    final recorte = _recortesOrgano[id] ?? const Rect.fromLTWH(140, 140, 120, 100);
    final colorSilueta = destacado
        ? const Color(0xFF0284C7).withValues(alpha: 0.38)
        : const Color(0xFFB5A992).withValues(alpha: 0.26);
    canvas.saveLayer(
      recorte.inflate(16),
      Paint()..colorFilter = ColorFilter.mode(colorSilueta, BlendMode.srcIn),
    );
    _pintarOrganoEnCuerpo(canvas, id, silueta: true, modoIcono: false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CuerpoHerbarioPainter oldDelegate) =>
      oldDelegate.organoActual != organoActual ||
      oldDelegate.zonaDestacada != zonaDestacada ||
      oldDelegate.aciertoZona != aciertoZona ||
      oldDelegate.colocados.length != colocados.length ||
      oldDelegate.organosNivel.length != organosNivel.length;
}

void _pintarOrganoEnCuerpo(
  Canvas canvas,
  String id, {
  required bool silueta,
  required bool modoIcono,
}) {
  switch (id) {
    case 'cerebro':
      _pintarCerebroVector(canvas, silueta: silueta);
    case 'pulmones':
      _pintarPulmonesVector(canvas, silueta: silueta);
    case 'corazon':
      _pintarCorazonVector(canvas, silueta: silueta);
    case 'estomago':
      _pintarEstomagoVector(canvas, silueta: silueta);
    case 'intestinos':
      _pintarIntestinosVector(canvas, silueta: silueta);
    case 'esqueleto':
      _pintarEsqueletoVector(canvas, silueta: silueta, modoIcono: modoIcono);
  }
}

void _pintarCerebroVector(Canvas canvas, {required bool silueta}) {
  // Hemisferio izquierdo y derecho con lóbulos detallados
  final izq = Path()
    ..moveTo(199, 26)
    ..cubicTo(182, 18, 158, 24, 154, 42)
    ..cubicTo(148, 48, 150, 66, 164, 72)
    ..cubicTo(172, 80, 190, 80, 199, 72)
    ..close();
  final der = Path()
    ..moveTo(201, 26)
    ..cubicTo(218, 18, 242, 24, 246, 42)
    ..cubicTo(252, 48, 250, 66, 236, 72)
    ..cubicTo(228, 80, 210, 80, 201, 72)
    ..close();

  _rellenarCuerpo(
    canvas,
    izq,
    const [Color(0xFFF9A8D4), Color(0xFFEC4899)],
    borde: const Color(0xFF831843),
    sombra: !silueta,
  );
  _rellenarCuerpo(
    canvas,
    der,
    const [Color(0xFFF472B6), Color(0xFFDB2777)],
    borde: const Color(0xFF831843),
    sombra: !silueta,
  );

  if (!silueta) {
    final surco = _lineaCuerpo(const Color(0xFF831843), 2.4);
    for (final d in [
      (const Offset(164, 44), const Offset(188, 38)),
      (const Offset(162, 58), const Offset(190, 56)),
      (const Offset(236, 44), const Offset(212, 38)),
      (const Offset(238, 58), const Offset(210, 56)),
    ]) {
      final p = Path()
        ..moveTo(d.$1.dx, d.$1.dy)
        ..quadraticBezierTo(
          (d.$1.dx + d.$2.dx) / 2,
          d.$1.dy - 7,
          d.$2.dx,
          d.$2.dy,
        );
      canvas.drawPath(p, surco);
    }
  }
}

void _pintarPulmonesVector(Canvas canvas, {required bool silueta}) {
  // Tráquea y bronquios
  final traquea = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(194, 128, 12, 34),
        const Radius.circular(6),
      ),
    );
  _rellenarCuerpo(
    canvas,
    traquea,
    const [Color(0xFFE0F2FE), Color(0xFF7DD3FC)],
    borde: const Color(0xFF0369A1),
    sombra: false,
  );

  // Pulmón derecho e izquierdo con forma anatómica esponjosa
  final pulmonIzq = Path()
    ..moveTo(190, 146)
    ..cubicTo(164, 138, 144, 158, 142, 194)
    ..cubicTo(140, 220, 154, 232, 176, 226)
    ..cubicTo(190, 222, 194, 206, 194, 182)
    ..close();
  final pulmonDer = Path()
    ..moveTo(210, 146)
    ..cubicTo(236, 138, 256, 158, 258, 194)
    ..cubicTo(260, 220, 246, 232, 224, 226)
    ..cubicTo(210, 222, 206, 206, 206, 182)
    ..close();

  for (final p in [pulmonIzq, pulmonDer]) {
    _rellenarCuerpo(
      canvas,
      p,
      const [Color(0xFFFBCFE8), Color(0xFFF472B6), Color(0xFFDB2777)],
      borde: const Color(0xFF831843),
      sombra: !silueta,
    );
  }

  if (!silueta) {
    final bronquio = _lineaCuerpo(const Color(0xFFFDF2F8), 2.2);
    final arbolIzq = Path()
      ..moveTo(194, 162)
      ..quadraticBezierTo(174, 172, 162, 194)
      ..moveTo(176, 176)
      ..lineTo(164, 172);
    final arbolDer = Path()
      ..moveTo(206, 162)
      ..quadraticBezierTo(226, 172, 238, 194)
      ..moveTo(224, 176)
      ..lineTo(236, 172);
    canvas.drawPath(arbolIzq, bronquio);
    canvas.drawPath(arbolDer, bronquio);
  }
}

void _pintarCorazonVector(Canvas canvas, {required bool silueta}) {
  // Grandes vasos superiores (aorta y vena cava)
  final vena = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(194, 156, 9, 18),
        const Radius.circular(4),
      ),
    );
  final aorta = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(205, 153, 10, 20),
        const Radius.circular(5),
      ),
    );
  _rellenarCuerpo(
    canvas,
    vena,
    const [Color(0xFF60A5FA), Color(0xFF2563EB)],
    borde: const Color(0xFF1E3A8A),
    sombra: false,
  );
  _rellenarCuerpo(
    canvas,
    aorta,
    const [Color(0xFFFB7185), Color(0xFFE11D48)],
    borde: const Color(0xFF881337),
    sombra: false,
  );

  // Corazón situado en el centro del pecho (ligeramente orientado a la izquierda)
  final corazon = Path()
    ..moveTo(206, 218)
    ..cubicTo(178, 204, 176, 176, 192, 170)
    ..cubicTo(200, 168, 205, 174, 206, 178)
    ..cubicTo(208, 174, 214, 168, 222, 170)
    ..cubicTo(236, 176, 234, 204, 206, 218)
    ..close();
  _rellenarCuerpo(
    canvas,
    corazon,
    const [Color(0xFFFB7185), Color(0xFFE11D48), Color(0xFF9F1239)],
    borde: const Color(0xFF4C0519),
    sombra: !silueta,
  );

  if (!silueta) {
    final latido = Path()
      ..moveTo(192, 192)
      ..lineTo(199, 192)
      ..lineTo(203, 183)
      ..lineTo(208, 201)
      ..lineTo(212, 192)
      ..lineTo(220, 192);
    canvas.drawPath(latido, _lineaCuerpo(Colors.white, 2.2));
  }
}

void _pintarEstomagoVector(Canvas canvas, {required bool silueta}) {
  // Estómago en forma de J situado en la parte superior del abdomen
  final estomago = Path()
    ..moveTo(196, 224)
    ..lineTo(206, 224)
    ..cubicTo(228, 228, 238, 246, 228, 262)
    ..cubicTo(216, 272, 184, 272, 170, 260)
    ..cubicTo(162, 252, 166, 240, 176, 242)
    ..cubicTo(184, 244, 188, 252, 198, 250)
    ..cubicTo(206, 248, 204, 234, 196, 230)
    ..close();

  _rellenarCuerpo(
    canvas,
    estomago,
    const [Color(0xFFFDBA74), Color(0xFFFB923C), Color(0xFFEA580C)],
    borde: const Color(0xFF7C2D12),
    sombra: !silueta,
  );

  if (!silueta) {
    final pliegue = Path()
      ..moveTo(212, 236)
      ..quadraticBezierTo(220, 250, 202, 262);
    canvas.drawPath(
      pliegue,
      _lineaCuerpo(const Color(0xFFFFEDD5).withValues(alpha: 0.85), 2.2),
    );
  }
}

void _pintarIntestinosVector(Canvas canvas, {required bool silueta}) {
  // Marco exterior del intestino grueso e interior plegado del intestino delgado en el abdomen
  final marcoGrueso = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(156, 266, 88, 38),
        const Radius.circular(14),
      ),
    );
  _rellenarCuerpo(
    canvas,
    marcoGrueso,
    const [Color(0xFFFDA4AF), Color(0xFFF43F5E)],
    borde: const Color(0xFF881337),
    sombra: !silueta,
  );

  final interiorDelgado = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(168, 274, 64, 24),
        const Radius.circular(9),
      ),
    );
  _rellenarCuerpo(
    canvas,
    interiorDelgado,
    const [Color(0xFFFED7AA), Color(0xFFFB923C)],
    borde: const Color(0xFF9A3412),
    sombra: false,
  );

  if (!silueta) {
    final pliegues = Path()
      ..moveTo(174, 282)
      ..quadraticBezierTo(186, 276, 198, 282)
      ..quadraticBezierTo(210, 288, 224, 281)
      ..moveTo(175, 291)
      ..quadraticBezierTo(190, 297, 204, 290)
      ..quadraticBezierTo(214, 285, 225, 292);
    canvas.drawPath(pliegues, _lineaCuerpo(const Color(0xFF9A3412), 2.0));
  }
}

void _pintarEsqueletoVector(
  Canvas canvas, {
  required bool silueta,
  required bool modoIcono,
}) {
  const coloresHueso = [Color(0xFFFFFFFF), Color(0xFFE2E8F0)];
  const bordeHueso = Color(0xFF475569);

  void huesoLargo(Offset a, Offset b, double grosor) {
    final p = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy);
    canvas.drawPath(p, _lineaCuerpo(bordeHueso, grosor + 4));
    canvas.drawPath(p, _lineaCuerpo(const Color(0xFFF8FAFC), grosor));
    for (final extremo in [a, b]) {
      canvas.drawCircle(extremo, grosor * 0.68, Paint()..color = bordeHueso);
      canvas.drawCircle(
        extremo,
        grosor * 0.48,
        Paint()..color = const Color(0xFFF8FAFC),
      );
    }
  }

  if (modoIcono) {
    // En el icono de pieza destacamos columna + costillas + hueso largo claramente visibles
    final columna = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(192, 146, 16, 140),
          const Radius.circular(8),
        ),
      );
    _rellenarCuerpo(canvas, columna, coloresHueso, borde: bordeHueso);
    for (final y in [166.0, 192.0, 218.0]) {
      final costilla = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(200, y), width: 92, height: 14),
            const Radius.circular(8),
          ),
        );
      _rellenarCuerpo(canvas, costilla, coloresHueso, borde: bordeHueso);
    }
    huesoLargo(const Offset(146, 336), const Offset(254, 336), 14);
    return;
  }

  // En la figura humana: huesos de brazos y piernas + pelvis
  huesoLargo(const Offset(128, 148), const Offset(98, 240), 9);
  huesoLargo(const Offset(272, 148), const Offset(302, 240), 9);
  huesoLargo(const Offset(168, 314), const Offset(164, 400), 11);
  huesoLargo(const Offset(232, 314), const Offset(236, 400), 11);
}

void _rellenarCuerpo(
  Canvas canvas,
  Path path,
  List<Color> colores, {
  required Color borde,
  bool sombra = true,
}) {
  final bounds = path.getBounds();
  if (sombra) {
    canvas.save();
    canvas.translate(0, 3);
    canvas.drawPath(path, Paint()..color = const Color(0x22000000));
    canvas.restore();
  }
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colores,
      ).createShader(bounds.isEmpty ? const Rect.fromLTWH(0, 0, 10, 10) : bounds),
  );
  canvas.drawPath(
    path,
    Paint()
      ..color = borde
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round,
  );
}

Paint _lineaCuerpo(Color color, double ancho) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = ancho
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

class DibujoPasoVida extends StatelessWidget {
  const DibujoPasoVida({required this.id, this.tamano = 48, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde) = switch (id) {
      'celulas' || 'division' => (
        const Color(0xFFEDE9FE),
        const Color(0xFF8B5CF6),
      ),
      'tejidos' || 'embrion' => (
        const Color(0xFFE0E7FF),
        const Color(0xFF6366F1),
      ),
      'utero' || 'embarazo' || 'feto' => (
        const Color(0xFFFCE7F3),
        const Color(0xFFEC4899),
      ),
      'nace' || 'bebe' => (const Color(0xFFFEF3C7), const Color(0xFFF59E0B)),
      'infancia' => (const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
      'adolescencia' => (const Color(0xFFFEF9C3), const Color(0xFFCA8A04)),
      'adultez' || 'cuidados' || 'organismo' => (
        const Color(0xFFDCFCE7),
        const Color(0xFF10B981),
      ),
      _ => (const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
    };
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(tamano * 0.28),
        border: Border.all(color: borde.withValues(alpha: 0.65), width: 2.0),
      ),
      padding: EdgeInsets.all(tamano * 0.08),
      child: CustomPaint(painter: _PintorPasoVida(id: id, variante: 1)),
    );
  }
}

class EscenaVidaInteractiva extends StatefulWidget {
  const EscenaVidaInteractiva({
    required this.etapaActiva,
    required this.onSeleccionarEtapa,
    this.nivelId = 'facil',
    super.key,
  });

  final String etapaActiva;
  final ValueChanged<String> onSeleccionarEtapa;
  final String nivelId;

  @override
  State<EscenaVidaInteractiva> createState() => _EscenaVidaInteractivaState();
}

class _EscenaVidaInteractivaState extends State<EscenaVidaInteractiva> {
  int _subModo = 0;

  @override
  void didUpdateWidget(covariant EscenaVidaInteractiva oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.etapaActiva != widget.etapaActiva ||
        oldWidget.nivelId != widget.nivelId) {
      _subModo = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pestanas = switch (widget.nivelId) {
      'medio' => const [
        ('celulas', Icons.biotech_rounded),
        ('embrion', Icons.monitor_heart_rounded),
        ('feto', Icons.pregnant_woman_rounded),
        ('nace', Icons.child_care_rounded),
        ('bebe', Icons.child_friendly_rounded),
      ],
      'dificil' => const [
        ('celulas', Icons.biotech_rounded),
        ('division', Icons.grid_view_rounded),
        ('tejidos', Icons.hub_rounded),
        ('utero', Icons.favorite_rounded),
        ('nace', Icons.child_care_rounded),
        ('organismo', Icons.accessibility_new_rounded),
      ],
      _ => const [
        ('celulas', Icons.biotech_rounded),
        ('utero', Icons.favorite_rounded),
        ('nace', Icons.child_care_rounded),
        ('cuidados', Icons.family_restroom_rounded),
      ],
    };

    final (titulo, subBotones, nota) = _datosEtapa(
      widget.nivelId,
      widget.etapaActiva,
      _subModo,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDFBF7), Color(0xFFF0F9FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(
              () => _subModo = (_subModo + 1) % subBotones.length,
            ),
            child: Container(
              width: 68,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
              ),
              padding: const EdgeInsets.all(4),
              child: CustomPaint(
                painter: _PintorPasoVida(
                  id: widget.etapaActiva,
                  variante: _subModo,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Texto(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0369A1),
                        ),
                      ),
                    ),
                    for (final (etapaId, icono) in pestanas)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(7),
                          onTap: () => widget.onSeleccionarEtapa(etapaId),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: widget.etapaActiva == etapaId
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Icon(
                              icono,
                              size: 12.5,
                              color: widget.etapaActiva == etapaId
                                  ? Colors.white
                                  : const Color(0xFF0369A1),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Texto(
                  nota,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    height: 1.16,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  children: [
                    for (var i = 0; i < subBotones.length; i++)
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => setState(() => _subModo = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _subModo == i
                                ? const Color(0xFF0284C7)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF38BDF8),
                            ),
                          ),
                          child: Texto(
                            subBotones[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _subModo == i
                                  ? Colors.white
                                  : const Color(0xFF0369A1),
                            ),
                          ),
                        ),
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

  (String, List<String>, String) _datosEtapa(
    String nivelId,
    String etapa,
    int sub,
  ) {
    if (nivelId == 'medio') {
      return switch (etapa) {
        'celulas' => (
          '1. Fecundación: 2 células se unen en 1',
          ['2 células', 'Fusión', '1ª célula'],
          switch (sub) {
            0 => 'Todo empieza cuando dos células reproductoras muy pequeñas se encuentran.',
            1 => 'Las dos células se unen y juntan sus instrucciones para iniciar una nueva vida.',
            _ => 'De esa unión nace una única primera célula, más pequeña que la punta de un alfiler.',
          },
        ),
        'embrion' => (
          '2. Primeros meses (1-2): el embrión',
          ['Semana 4', 'Mes 2 · Latido', 'Esbozos'],
          switch (sub) {
            0 => 'En el primer mes el embrión se instala protegido en el interior del útero materno.',
            1 => 'Hacia el segundo mes mide como una habichuela y su diminuto corazón ya empieza a latir.',
            _ => 'Empiezan a distinguirse la cabeza, los ojos y unos pequeños brotes de brazos y piernas.',
          },
        ),
        'feto' => (
          '3. En el útero (Meses 3-9): el feto',
          ['Mes 4 · Cordón', 'Mes 6 · Oye voces', 'Mes 9 · Listo'],
          switch (sub) {
            0 => 'A partir del tercer mes se llama feto y recibe alimento y oxígeno por el cordón umbilical.',
            1 => 'Flota calentito en el líquido amniótico, mueve manos y pies y oye la voz desde dentro.',
            _ => 'Al noveno mes mide unos 50 cm, sus órganos están listos y se coloca para nacer.',
          },
        ),
        'nace' => (
          '4. El nacimiento: primera respiración',
          ['Pulmones y aire', 'El ombligo', 'Bienvenida'],
          switch (sub) {
            0 => 'Al salir del útero, el recién nacido llena sus pulmones de aire por primera vez.',
            1 => 'Ya no necesita el cordón umbilical: al cortarlo queda la cicatriz de nuestro ombligo.',
            _ => 'Al nacer aún no tiene dientes visibles y necesita el calor y el contacto de su familia.',
          },
        ),
        _ => (
          '5. Bebé y primera infancia',
          ['Lactancia', 'Dientes de leche', 'Primeros pasos'],
          switch (sub) {
            0 => 'Durante los primeros meses se alimenta solo de leche y duerme muchas horas para crecer.',
            1 => 'Hacia los 6 meses asoman los primeros dientes de leche para probar purés y trocitos.',
            _ => 'Sus huesos y músculos cobran fuerza para gatear, caminar, hablar y jugar en la infancia.',
          },
        ),
      };
    }

    if (nivelId == 'dificil') {
      return switch (etapa) {
        'celulas' => (
          '1. Fecundación: 2 células forman 1 cigoto',
          ['2 gametos', 'Se fusionan', '1 cigoto nuevo'],
          switch (sub) {
            0 => 'Dos células reproductoras diminutas se encuentran para dar comienzo a una nueva vida.',
            1 => 'Ambas células se unen para siempre combinando la información genética del nuevo ser.',
            _ => 'Resultado: las 2 células se convierten en 1 sola célula nueva llamada cigoto.',
          },
        ),
        'division' => (
          '2. Multiplicación: el cigoto hace copias',
          ['1 → 2 copias', '2 → 4 copias', 'Mórula (8+)'],
          switch (sub) {
            0 => '¡La unión no se deshace! Ese cigoto único se duplica y crea 2 células completas iguales.',
            1 => 'Cada célula vuelve a copiarse: de 2 pasamos a 4 células unidas como un equipo.',
            _ => 'Al seguir multiplicándose (8, 16, 32...) forman una esfera de células llamada mórula.',
          },
        ),
        'tejidos' => (
          '3. Diferenciación: tejidos y órganos',
          ['Tejidos', '1º Latido', 'Embrión'],
          switch (sub) {
            0 => 'Las copias celulares se especializan y se agrupan formando tejidos (muscular, nervioso, óseo).',
            1 => 'Los tejidos se unen para construir los primeros órganos: ¡el corazón embrionario empieza a latir!',
            _ => 'El embrión ya tiene esbozos de cerebro, columna vertebral, ojos y extremidades.',
          },
        ),
        'utero' => (
          '4. Etapa fetal y placenta',
          ['Placenta y cordón', 'Órganos maduros', 'Mes 9'],
          switch (sub) {
            0 => 'A través de la placenta y el cordón umbilical el feto recibe oxígeno y nutrientes.',
            1 => 'Sus aparatos digestivo, respiratorio y nervioso maduran dentro del líquido amniótico.',
            _ => 'Al noveno mes el feto mide unos 50 cm y se coloca cabeza abajo para nacer.',
          },
        ),
        'nace' => (
          '5. Nacimiento y adaptación al aire',
          ['Alvéolos pulmonares', 'Ombligo', 'Termorregulación'],
          switch (sub) {
            0 => 'Con el primer llanto los pulmones se expanden y captan oxígeno directamente del aire.',
            1 => 'La circulación cambia al cortar el cordón umbilical, que deja la cicatriz del ombligo.',
            _ => 'Fuera del útero el recién nacido necesita calor, leche y protección.',
          },
        ),
        _ => (
          '6. Crecimiento: infancia, adolescencia y madurez',
          ['Infancia', 'Adolescencia', 'Madurez'],
          switch (sub) {
            0 => 'Tras nacer, durante la infancia aprendemos a hablar, caminar y nuestros huesos y músculos crecen.',
            1 => 'En la adolescencia el cuerpo experimenta un gran estirón y sigue madurando.',
            _ => 'Al llegar a la etapa adulta o madurez el cuerpo alcanza su desarrollo completo.',
          },
        ),
      };
    }

    return switch (etapa) {
      'celulas' => (
        'El comienzo: 2 células forman la primera',
        ['2 células', '1ª célula', 'Muchas copias'],
        switch (sub) {
          0 => 'Dos células diminutas se unen y forman la primera célula con toda la información.',
          1 => 'Esa primera célula no se separa: empieza a hacer copias de sí misma.',
          _ => 'Las células se multiplican (2, 4, 8, 16...) para empezar a formar el cuerpo del bebé.',
        },
      ),
      'utero' => (
        'En el útero: 9 meses creciendo dentro',
        ['Mes 2 · Latido', 'Mes 5 · Cordón', 'Mes 9 · Listo'],
        switch (sub) {
          0 => 'A los 2 meses mide como una habichuela y su diminuto corazón ya late.',
          1 => 'Por el cordón umbilical recibe oxígeno y alimento dentro del líquido amniótico.',
          _ => 'A los 9 meses ya tiene todos sus órganos listos y se coloca para nacer.',
        },
      ),
      'nace' => (
        'El nacimiento: primera respiración',
        ['1ª Respiración', 'El ombligo'],
        switch (sub) {
          0 => 'Al salir al exterior, sus pulmones se llenan de aire por primera vez.',
          _ => 'El cordón umbilical ya no hace falta: al cortarlo deja la cicatriz del ombligo.',
        },
      ),
      _ => (
        'Cuidados y cariño en familia',
        ['Leche y abrigo', 'Primeros pasos', 'Crecer sano'],
        switch (sub) {
          0 => 'El recién nacido necesita leche, abrigo, sueño tranquilo y mucho cariño.',
          1 => 'Con la ayuda de su familia aprende poco a poco a caminar, hablar y jugar.',
          _ => 'Gracias a los cuidados diarios crece fuerte y sano durante toda la infancia.',
        },
      ),
    };
  }
}

class _PintorPasoVida extends CustomPainter {
  const _PintorPasoVida({required this.id, required this.variante});

  final String id;
  final int variante;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final cy = h * 0.5;

    switch (id) {
      case 'celulas':
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(w, h) * 0.46,
          Paint()..color = const Color(0xFFEDE9FE),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(w, h) * 0.46,
          _lineaCuerpo(const Color(0xFF7C3AED), 2.0),
        );
        if (variante == 0) {
          final c1 = Offset(cx - w * 0.16, cy);
          final c2 = Offset(cx + w * 0.16, cy);
          final r = math.min(w, h) * 0.20;
          canvas.drawCircle(c1, r, Paint()..color = const Color(0xFFC084FC));
          canvas.drawCircle(c2, r, Paint()..color = const Color(0xFF38BDF8));
          canvas.drawCircle(c1, r * 0.4, Paint()..color = const Color(0xFF581C87));
          canvas.drawCircle(c2, r * 0.4, Paint()..color = const Color(0xFF0369A1));
          // Signo '+' de unión en el centro
          canvas.drawLine(
            Offset(cx - 4, cy),
            Offset(cx + 4, cy),
            _lineaCuerpo(const Color(0xFF4C1D95), 2.2),
          );
          canvas.drawLine(
            Offset(cx, cy - 4),
            Offset(cx, cy + 4),
            _lineaCuerpo(const Color(0xFF4C1D95), 2.2),
          );
        } else {
          // Dos células pequeñas arriba fusionándose en 1 cigoto grande abajo
          final rPeq = math.min(w, h) * 0.11;
          final c1 = Offset(cx - w * 0.14, cy - h * 0.20);
          final c2 = Offset(cx + w * 0.14, cy - h * 0.20);
          canvas.drawCircle(c1, rPeq, Paint()..color = const Color(0xFFC084FC));
          canvas.drawCircle(c2, rPeq, Paint()..color = const Color(0xFF38BDF8));
          final rCigoto = math.min(w, h) * 0.24;
          final cCigoto = Offset(cx, cy + h * 0.10);
          canvas.drawLine(c1, cCigoto, _lineaCuerpo(const Color(0xFF7C3AED), 1.5));
          canvas.drawLine(c2, cCigoto, _lineaCuerpo(const Color(0xFF0284C7), 1.5));
          canvas.drawCircle(cCigoto, rCigoto, Paint()..color = const Color(0xFFA855F7));
          canvas.drawCircle(cCigoto, rCigoto, _lineaCuerpo(const Color(0xFF581C87), 1.8));
          canvas.drawCircle(cCigoto, rCigoto * 0.42, Paint()..color = const Color(0xFFFDE047));
        }

      case 'division':
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(w, h) * 0.46,
          Paint()..color = const Color(0xFFEDE9FE),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(w, h) * 0.46,
          _lineaCuerpo(const Color(0xFF7C3AED), 2.0),
        );
        // Mostramos cómo 1 cigoto a la izquierda se multiplica en un racimo unido de copias a la derecha
        final cOrigen = Offset(cx - w * 0.22, cy);
        final rOrigen = math.min(w, h) * 0.13;
        canvas.drawCircle(cOrigen, rOrigen, Paint()..color = const Color(0xFFA855F7));
        canvas.drawCircle(cOrigen, rOrigen * 0.4, Paint()..color = const Color(0xFFFDE047));
        // Flecha de multiplicación ->
        canvas.drawLine(
          Offset(cx - w * 0.06, cy),
          Offset(cx + w * 0.04, cy),
          _lineaCuerpo(const Color(0xFF4C1D95), 2.0),
        );
        final centroRacimo = Offset(cx + w * 0.18, cy);
        final offsets = switch (variante) {
          0 => [Offset(0, -h * 0.11), Offset(0, h * 0.11)],
          1 => [
            Offset(-w * 0.08, -h * 0.10),
            Offset(w * 0.08, -h * 0.10),
            Offset(-w * 0.08, h * 0.10),
            Offset(w * 0.08, h * 0.10),
          ],
          _ => [
            Offset(-w * 0.09, -h * 0.11),
            Offset(w * 0.09, -h * 0.11),
            Offset(-w * 0.11, 0),
            Offset(w * 0.11, 0),
            Offset(-w * 0.09, h * 0.11),
            Offset(w * 0.09, h * 0.11),
            Offset.zero,
          ],
        };
        final r = variante == 0
            ? math.min(w, h) * 0.13
            : (variante == 1 ? math.min(w, h) * 0.11 : math.min(w, h) * 0.095);
        for (final off in offsets) {
          final c = centroRacimo + off;
          canvas.drawCircle(c, r, Paint()..color = const Color(0xFF9333EA));
          canvas.drawCircle(c, r, _lineaCuerpo(const Color(0xFF581C87), 1.2));
          canvas.drawCircle(c, r * 0.36, Paint()..color = const Color(0xFFFDE047));
        }

      case 'embrion':
        // Saco embrionario temprano con embrión en forma de C (habichuela) y latido cardíaco brillante
        final rectSaco = Rect.fromCenter(
          center: Offset(cx, cy),
          width: w * 0.84,
          height: h * 0.82,
        );
        canvas.drawOval(rectSaco, Paint()..color = const Color(0xFFE0E7FF));
        canvas.drawOval(
          rectSaco.deflate(5),
          Paint()..color = const Color(0xFFDBEAFE),
        );
        canvas.drawOval(rectSaco, _lineaCuerpo(const Color(0xFF4F46E5), 2.0));
        // Cuerpo curvado como habichuela
        final pEmbrion = Paint()
          ..color = const Color(0xFFFDA4AF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.min(w, h) * (variante == 0 ? 0.18 : 0.22)
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx + w * 0.04, cy), width: w * 0.36, height: h * 0.42),
          1.4,
          3.5,
          false,
          pEmbrion,
        );
        // Cabeza embrionaria y ojo en formación
        canvas.drawCircle(
          Offset(cx, cy - h * 0.15),
          math.min(w, h) * 0.13,
          Paint()..color = const Color(0xFFFDA4AF),
        );
        if (variante >= 1) {
          // Latido del corazón embrionario con ondas
          final cCorazon = Offset(cx - w * 0.08, cy + h * 0.02);
          canvas.drawCircle(
            cCorazon,
            math.min(w, h) * 0.13,
            Paint()..color = const Color(0xFFF43F5E).withValues(alpha: 0.3),
          );
          canvas.drawCircle(
            cCorazon,
            math.min(w, h) * 0.075,
            Paint()..color = const Color(0xFFE11D48),
          );
        }

      case 'tejidos':
        // Red de células formando tejido + pequeño corazón embrionario en el centro
        final rFondo = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: w * 0.86, height: h * 0.80),
          const Radius.circular(10),
        );
        canvas.drawRRect(rFondo, Paint()..color = const Color(0xFFE0E7FF));
        canvas.drawRRect(rFondo, _lineaCuerpo(const Color(0xFF4F46E5), 1.8));
        for (var fila = -1; fila <= 1; fila++) {
          for (var col = -1; col <= 1; col++) {
            final c = Offset(cx + col * w * 0.22, cy + fila * h * 0.20);
            canvas.drawOval(
              Rect.fromCenter(center: c, width: w * 0.20, height: h * 0.16),
              Paint()..color = const Color(0xFF818CF8).withValues(alpha: 0.55),
            );
            canvas.drawCircle(c, 2.0, Paint()..color = const Color(0xFF312E81));
          }
        }
        // Corazón embrionario latiendo en el centro
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(w, h) * 0.18,
          Paint()..color = const Color(0xFFE11D48),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(w, h) * 0.08,
          Paint()..color = const Color(0xFFFDE047),
        );

      case 'utero':
      case 'embarazo':
      case 'feto':
        final rectUtero = Rect.fromCenter(
          center: Offset(cx, cy),
          width: w * 0.84,
          height: h * 0.82,
        );
        canvas.drawOval(rectUtero, Paint()..color = const Color(0xFFFCE7F3));
        canvas.drawOval(
          rectUtero.deflate(4),
          Paint()..color = const Color(0xFFBAE6FD).withValues(alpha: 0.45),
        );
        canvas.drawOval(rectUtero, _lineaCuerpo(const Color(0xFFBE185D), 2.2));
        // Placenta en la pared superior derecha del útero
        canvas.drawArc(
          rectUtero.deflate(3),
          -1.1,
          0.9,
          false,
          _lineaCuerpo(const Color(0xFFDB2777), 4.2),
        );
        final cordon = Path()
          ..moveTo(cx + w * 0.04, cy + h * 0.06)
          ..quadraticBezierTo(
            cx + w * 0.24,
            cy - h * 0.06,
            cx + w * 0.26,
            cy - h * 0.24,
          );
        canvas.drawPath(cordon, _lineaCuerpo(const Color(0xFFE11D48), 2.4));

        final escalaBebe = variante == 0 ? 0.68 : (variante == 1 ? 0.86 : 1.0);
        final pBebe = Paint()..color = const Color(0xFFFDBA74);
        canvas.drawCircle(
          Offset(cx - w * 0.10 * escalaBebe, cy - h * 0.08 * escalaBebe),
          w * 0.13 * escalaBebe,
          pBebe,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + w * 0.05 * escalaBebe, cy + h * 0.08 * escalaBebe),
            width: w * 0.26 * escalaBebe,
            height: h * 0.22 * escalaBebe,
          ),
          pBebe,
        );
        canvas.drawCircle(
          Offset(cx, cy + h * 0.04),
          3.2,
          Paint()..color = const Color(0xFFE11D48),
        );

      case 'nace':
        final cuerpoManta = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, cy + h * 0.14),
            width: w * 0.58,
            height: h * 0.48,
          ),
          Radius.circular(w * 0.26),
        );
        canvas.drawRRect(cuerpoManta, Paint()..color = const Color(0xFF60A5FA));
        canvas.drawRRect(cuerpoManta, _lineaCuerpo(const Color(0xFF1E3A8A), 1.8));
        final cara = Offset(cx, cy - h * 0.14);
        canvas.drawCircle(cara, w * 0.19, Paint()..color = const Color(0xFFFED7AA));
        canvas.drawCircle(cara, w * 0.19, _lineaCuerpo(const Color(0xFF9A3412), 1.6));
        if (variante == 0) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cx + w * 0.24, cara.dy), width: 12, height: 12),
            -1.2,
            2.4,
            false,
            _lineaCuerpo(const Color(0xFF0284C7), 2.0),
          );
        } else {
          canvas.drawCircle(
            Offset(cx, cy + h * 0.16),
            4.5,
            Paint()..color = const Color(0xFFFDE047),
          );
          canvas.drawCircle(
            Offset(cx, cy + h * 0.16),
            2.2,
            Paint()..color = const Color(0xFF9A3412),
          );
        }

      case 'bebe':
        // Bebé sentado/gateando con biberón o sonajero
        final cabeza = Offset(cx, cy - h * 0.16);
        canvas.drawCircle(cabeza, w * 0.18, Paint()..color = const Color(0xFFFED7AA));
        canvas.drawCircle(cabeza, w * 0.18, _lineaCuerpo(const Color(0xFF9A3412), 1.6));
        // Rizo superior de bebé
        canvas.drawArc(
          Rect.fromCenter(center: Offset(cx, cabeza.dy - w * 0.16), width: 10, height: 8),
          0,
          3.14,
          false,
          _lineaCuerpo(const Color(0xFF78350F), 2.0),
        );
        final pelele = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + h * 0.16), width: w * 0.44, height: h * 0.36),
          const Radius.circular(10),
        );
        canvas.drawRRect(pelele, Paint()..color = const Color(0xFFFBBF24));
        canvas.drawRRect(pelele, _lineaCuerpo(const Color(0xFFB45309), 1.6));
        // Sonajero / diente de leche destacado
        canvas.drawCircle(
          Offset(cx + w * 0.26, cy + h * 0.04),
          w * 0.09,
          Paint()..color = const Color(0xFF38BDF8),
        );

      case 'infancia':
        // Niño/a en crecimiento con mochila escolar / balón
        final cabeza = Offset(cx, cy - h * 0.22);
        canvas.drawCircle(cabeza, w * 0.15, Paint()..color = const Color(0xFFFED7AA));
        canvas.drawCircle(cabeza, w * 0.15, _lineaCuerpo(const Color(0xFF9A3412), 1.5));
        final camiseta = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + h * 0.08), width: w * 0.36, height: h * 0.34),
          const Radius.circular(8),
        );
        canvas.drawRRect(camiseta, Paint()..color = const Color(0xFF0284C7));
        // Piernas más largas
        canvas.drawLine(
          Offset(cx - w * 0.08, cy + h * 0.24),
          Offset(cx - w * 0.10, cy + h * 0.42),
          _lineaCuerpo(const Color(0xFF1E3A8A), 4.0),
        );
        canvas.drawLine(
          Offset(cx + w * 0.08, cy + h * 0.24),
          Offset(cx + w * 0.10, cy + h * 0.42),
          _lineaCuerpo(const Color(0xFF1E3A8A), 4.0),
        );

      case 'adolescencia':
        // Joven alto en pleno estirón con regla de estatura al lado
        canvas.drawLine(
          Offset(cx - w * 0.30, cy - h * 0.38),
          Offset(cx - w * 0.30, cy + h * 0.40),
          _lineaCuerpo(const Color(0xFFCA8A04), 2.2),
        );
        for (final dy in [-0.32, -0.12, 0.08, 0.28]) {
          canvas.drawLine(
            Offset(cx - w * 0.30, cy + h * dy),
            Offset(cx - w * 0.20, cy + h * dy),
            _lineaCuerpo(const Color(0xFFCA8A04), 1.8),
          );
        }
        final cabeza = Offset(cx + w * 0.06, cy - h * 0.26);
        canvas.drawCircle(cabeza, w * 0.14, Paint()..color = const Color(0xFFFED7AA));
        final torso = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + w * 0.06, cy + h * 0.04),
            width: w * 0.34,
            height: h * 0.38,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(torso, Paint()..color = const Color(0xFFEAB308));
        canvas.drawLine(
          Offset(cx, cy + h * 0.22),
          Offset(cx - w * 0.02, cy + h * 0.42),
          _lineaCuerpo(const Color(0xFF713F12), 4.2),
        );
        canvas.drawLine(
          Offset(cx + w * 0.12, cy + h * 0.22),
          Offset(cx + w * 0.14, cy + h * 0.42),
          _lineaCuerpo(const Color(0xFF713F12), 4.2),
        );

      case 'adultez':
        // Adulto y persona mayor juntos
        for (final (dx, colorRopa, colorPelo) in [
          (-w * 0.16, const Color(0xFF059669), const Color(0xFF451A03)),
          (w * 0.16, const Color(0xFF0D9488), const Color(0xFFCBD5E1)),
        ]) {
          final x = cx + dx;
          canvas.drawCircle(
            Offset(x, cy - h * 0.22),
            w * 0.13,
            Paint()..color = const Color(0xFFFED7AA),
          );
          canvas.drawArc(
            Rect.fromCenter(center: Offset(x, cy - h * 0.24), width: w * 0.26, height: w * 0.22),
            3.14,
            3.14,
            true,
            Paint()..color = colorPelo,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, cy + h * 0.10), width: w * 0.26, height: h * 0.40),
              const Radius.circular(7),
            ),
            Paint()..color = colorRopa,
          );
        }

      case 'organismo':
      case 'cuidados':
      default:
        final alturas = [0.22, 0.34, 0.46];
        final xs = [cx - w * 0.24, cx, cx + w * 0.24];
        for (var i = 0; i < 3; i++) {
          final activo = i <= variante;
          final color = activo
              ? const Color(0xFF059669)
              : const Color(0xFF94A3B8);
          final hCuerpo = h * alturas[i];
          final x = xs[i];
          final base = cy + h * 0.36;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x - w * 0.08, base - hCuerpo, w * 0.16, hCuerpo),
              const Radius.circular(6),
            ),
            Paint()..color = color,
          );
          canvas.drawCircle(
            Offset(x, base - hCuerpo - w * 0.08),
            w * 0.075,
            Paint()..color = color,
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant _PintorPasoVida oldDelegate) =>
      oldDelegate.id != id || oldDelegate.variante != variante;
}

class _Ovalo extends StatelessWidget {
  const _Ovalo({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
    );
  }
}

class IlustracionFicha extends StatelessWidget {
  const IlustracionFicha({super.key, required this.id, this.alto = 68});

  final String id;
  final double alto;

  static const _criaturasConPng = {
    'camello',
    'delfin',
    'pinguino',
    'oso',
    'rana',
    'tucan',
    'pulpo',
    'corazon',
    'pulmones',
    'estomago',
    'cerebro',
    'esqueleto',
    'intestinos',
  };

  @override
  Widget build(BuildContext context) {
    if (id == 'claro-bosque') {
      return SizedBox(
        width: alto * 1.3, height: alto,
        child: const DibujoEcosistema(),
      );
    }
    if (_criaturasConPng.contains(id)) {
      return SizedBox(
        width: alto,
        height: alto,
        child: FittedBox(fit: BoxFit.contain, child: Criatura(id: id)),
      );
    }
    if (id == 'semilla') {
      return SizedBox(
        width: alto,
        height: alto,
        child: const FittedBox(
          fit: BoxFit.contain,
          child: DibujoSemilla(estado: 'brote', compacto: true),
        ),
      );
    }
    if (const {'raiz', 'tallo', 'hoja', 'flor', 'fruto'}.contains(id)) {
      return IconoParte(id: id, size: alto);
    }
    if (id == 'celula' || id == 'una-vida' || id == 'etapas-vida') {
      final pasoId = switch (id) {
        'celula' => 'celulas',
        'una-vida' => 'utero',
        _ => 'bebe',
      };
      return DibujoPasoVida(id: pasoId, tamano: alto);
    }
    final (icono, color, fondo) = switch (id) {
      'huerto' => (
        Icons.grass_rounded,
        const Color(0xFF8B5A2B),
        const Color(0xFFF3E8D2),
      ),
      'fotosintesis' => (
        Icons.wb_sunny_rounded,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
      _ => (
        Icons.auto_awesome_rounded,
        const Color(0xFF2F6B4F),
        const Color(0xFFE5F2EB),
      ),
    };
    return Container(
      width: alto,
      height: alto,
      decoration: BoxDecoration(
        color: fondo,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35), width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(icono, size: alto * 0.54, color: color),
    );
  }
}

