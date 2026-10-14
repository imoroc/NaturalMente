import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final respaldo = switch (id) {
      'delfin' => const _Delfin(),
      'pinguino' => const _Pinguino(),
      'oso' => const _Oso(),
      'rana' => const _Rana(),
      'tucan' => const _Tucan(),
      'insectos' => const _Insectos(),
      'pulmones' => const _DosFormas(color: Color(0xFFE38B8B)),
      'estomago' => const _Bolsa(),
      'corazon' => const _Corazon(),
      'cerebro' => const _Cerebro(),
      'esqueleto' => const _Esqueleto(),
      'sentidos' => const _Sentidos(),
      _ => const _Camello(),
    };
    const conImagen = {
      'camello',
      'delfin',
      'pinguino',
      'oso',
      'rana',
      'tucan',
      'insectos',
      'corazon',
      'pulmones',
      'estomago',
      'cerebro',
      'esqueleto',
      'sentidos',
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

  @override
  Widget build(BuildContext context) {
    final datos = switch (id) {
      'desierto' => (Icons.wb_sunny_rounded, const Color(0xFFD97706)),
      'mar' => (Icons.waves_rounded, const Color(0xFF0284C7)),
      'polo' => (Icons.ac_unit_rounded, const Color(0xFF0369A1)),
      'bosque' => (Icons.park_rounded, const Color(0xFF15803D)),
      'selva' => (Icons.forest_rounded, const Color(0xFF059669)),
      'rio' => (Icons.water_rounded, const Color(0xFF0891B2)),
      'cabeza' => (Icons.psychology_rounded, const Color(0xFF7C3AED)),
      'pecho' => (Icons.favorite_rounded, const Color(0xFFE11D48)),
      'barriga' => (Icons.restaurant_rounded, const Color(0xFFD97706)),
      'extremidades' => (Icons.directions_run_rounded, const Color(0xFF0284C7)),
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
}

class DibujoSemilla extends StatelessWidget {
  const DibujoSemilla({required this.estado, super.key});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final archivo = switch (estado) {
      'brote' => 'semilla_brote',
      'palida' => 'semilla_palida',
      'ahogada' => 'semilla_ahogada',
      _ => 'semilla_seca',
    };
    final altura = switch (estado) {
      'brote' => 64.0,
      'palida' => 48.0,
      'ahogada' => 22.0,
      _ => 12.0,
    };
    final color = switch (estado) {
      'brote' => const Color(0xFF2F7D32),
      'palida' => const Color(0xFFD2C07A),
      'ahogada' => const Color(0xFF6E8F62),
      _ => const Color(0xFF8D6A43),
    };
    final colorBorde = switch (estado) {
      'brote' => const Color(0xFF2ECC71),
      'ahogada' => const Color(0xFF38BDF8),
      'palida' => const Color(0xFFFBBF24),
      _ => const Color(0xFFD6CFC0),
    };
    return Container(
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withValues(alpha: 0.35),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Image.asset(
          'assets/imagenes/$archivo.png',
          cacheWidth: 300,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 12,
              height: altura,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
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

class _Corazon extends StatelessWidget {
  const _Corazon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.favorite, color: Color(0xFFC0392B), size: 48);
  }
}

class _Cerebro extends StatelessWidget {
  const _Cerebro();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.psychology_rounded,
      color: Color(0xFF9333EA),
      size: 50,
    );
  }
}

class _Esqueleto extends StatelessWidget {
  const _Esqueleto();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.accessibility_new_rounded,
      color: Color(0xFF0284C7),
      size: 50,
    );
  }
}

class _Insectos extends StatelessWidget {
  const _Insectos();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 68,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            top: 4,
            child: _Ovalo(width: 18, height: 22, color: Color(0xFFBAE6FD)),
          ),
          Positioned(
            right: 16,
            top: 4,
            child: _Ovalo(width: 18, height: 22, color: Color(0xFFBAE6FD)),
          ),
          Positioned(
            bottom: 8,
            child: _Ovalo(width: 48, height: 28, color: Color(0xFFFACC15)),
          ),
          Positioned(
            left: 22,
            bottom: 8,
            child: _Ovalo(width: 8, height: 28, color: Color(0xFF1E293B)),
          ),
          Positioned(
            left: 36,
            bottom: 8,
            child: _Ovalo(width: 8, height: 28, color: Color(0xFF1E293B)),
          ),
          Positioned(
            right: 12,
            bottom: 16,
            child: _Ovalo(width: 6, height: 6, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}

class _Sentidos extends StatelessWidget {
  const _Sentidos();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.visibility_rounded,
      color: Color(0xFF2563EB),
      size: 48,
    );
  }
}

class _DosFormas extends StatelessWidget {
  const _DosFormas({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Ovalo(width: 22, height: 38, color: color),
        const SizedBox(width: 6),
        _Ovalo(width: 22, height: 38, color: color),
      ],
    );
  }
}

class _Bolsa extends StatelessWidget {
  const _Bolsa();

  @override
  Widget build(BuildContext context) {
    return const _Ovalo(width: 38, height: 44, color: Color(0xFFE0A36A));
  }
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
    'insectos',
    'corazon',
    'pulmones',
    'estomago',
    'cerebro',
    'esqueleto',
    'sentidos',
  };

  @override
  Widget build(BuildContext context) {
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
          child: DibujoSemilla(estado: 'brote'),
        ),
      );
    }
    final (icono, color, fondo) = switch (id) {
      'insectos' => (
        Icons.emoji_nature_rounded,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
      'huerto' => (
        Icons.grass_rounded,
        const Color(0xFF8B5A2B),
        const Color(0xFFF3E8D2),
      ),
      'raiz' => (
        Icons.account_tree_rounded,
        const Color(0xFF8B5A2B),
        const Color(0xFFF3E8D2),
      ),
      'tallo' => (
        Icons.nature_rounded,
        const Color(0xFF2E7D32),
        const Color(0xFFE5F4E3),
      ),
      'hoja' => (
        Icons.eco_rounded,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
      ),
      'flor' => (
        Icons.local_florist_rounded,
        const Color(0xFFDB2777),
        const Color(0xFFFCE7F3),
      ),
      'fruto' => (
        Icons.apple_rounded,
        const Color(0xFFDC2626),
        const Color(0xFFFEE2E2),
      ),
      'sentidos' => (
        Icons.visibility_rounded,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
      ),
      'una-vida' => (
        Icons.child_care_rounded,
        const Color(0xFFE11D48),
        const Color(0xFFFFE4E6),
      ),
      'celula' => (
        Icons.blur_circular_rounded,
        const Color(0xFF7C3AED),
        const Color(0xFFEDE9FE),
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

