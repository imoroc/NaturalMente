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
      'pulmones' => const _DosFormas(color: Color(0xFFE38B8B)),
      'estomago' => const _Bolsa(),
      'corazon' => const _Corazon(),
      _ => const _Camello(),
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
        child: Image.asset(
          'assets/imagenes/$id.png',
          cacheWidth: 240,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Center(child: respaldo),
        ),
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
      'cabeza' => (Icons.psychology_rounded, const Color(0xFF7C3AED)),
      'pecho' => (Icons.favorite_rounded, const Color(0xFFE11D48)),
      'barriga' => (Icons.restaurant_rounded, const Color(0xFFD97706)),
      _ => (Icons.explore_rounded, const Color(0xFF15803D)),
    };
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
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

class _Corazon extends StatelessWidget {
  const _Corazon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.favorite, color: Color(0xFFC0392B), size: 48);
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
