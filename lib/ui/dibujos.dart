import 'package:flutter/material.dart';

// Dibujos nuestros, hechos con formas. No salen de ningún libro.

class Escena extends StatelessWidget {
  const Escena({required this.child, required this.cielo, required this.suelo, super.key});

  final Widget child;
  final Color cielo;
  final Color suelo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(flex: 3, child: ColoredBox(color: cielo)),
                Expanded(child: ColoredBox(color: suelo)),
              ],
            ),
            Align(alignment: const Alignment(0, 0.15), child: child),
          ],
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
    final child = switch (id) {
      'delfin' => const _Delfin(),
      'pinguino' => const _Pinguino(),
      'oso' => const _Oso(),
      'pulmones' => const _DosFormas(color: Color(0xFFE38B8B)),
      'estomago' => const _Bolsa(),
      'corazon' => const _Corazon(),
      _ => const _Camello(),
    };
    return SizedBox(width: 120, height: 84, child: Center(child: child));
  }
}

class DibujoAnimal extends StatelessWidget {
  const DibujoAnimal({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    switch (id) {
      case 'delfin':
        return const Escena(
          cielo: Color(0xFFB9DFF5),
          suelo: Color(0xFF2E6B93),
          child: _Delfin(),
        );
      case 'pinguino':
        return const Escena(
          cielo: Color(0xFFD7E7F2),
          suelo: Color(0xFFF4F7FB),
          child: _Pinguino(),
        );
      case 'oso':
        return const Escena(
          cielo: Color(0xFFC9E4C4),
          suelo: Color(0xFF6B4A2B),
          child: _Oso(),
        );
      default:
        return const Escena(
          cielo: Color(0xFFF3D7A1),
          suelo: Color(0xFFE0B15A),
          child: _Camello(),
        );
    }
  }
}

class DibujoSemilla extends StatelessWidget {
  const DibujoSemilla({required this.estado, super.key});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final altura = switch (estado) {
      'brote' => 78.0,
      'palida' => 58.0,
      'ahogada' => 26.0,
      _ => 14.0,
    };
    final color = switch (estado) {
      'brote' => const Color(0xFF2F7D32),
      'palida' => const Color(0xFFD2C07A),
      'ahogada' => const Color(0xFF6E8F62),
      _ => const Color(0xFF8D6A43),
    };
    final agua = estado == 'ahogada';
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 150,
        alignment: Alignment.bottomCenter,
        color: agua ? const Color(0xFF8EC8E8) : const Color(0xFFE7F4EA),
        child: Container(
          width: 12,
          height: altura,
          margin: const EdgeInsets.only(bottom: 28),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class DibujoPieza extends StatelessWidget {
  const DibujoPieza({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final child = switch (id) {
      'pulmones' => const _DosFormas(color: Color(0xFFE38B8B)),
      'estomago' => const _Bolsa(),
      _ => const _Corazon(),
    };
    return Escena(
      cielo: const Color(0xFFE7F4F8),
      suelo: const Color(0xFFF6E7D8),
      child: child,
    );
  }
}

class _Camello extends StatelessWidget {
  const _Camello();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 120,
      height: 70,
      child: Stack(
        children: [
          Positioned(left: 18, bottom: 8, child: _Ovalo(width: 78, height: 36, color: Color(0xFFC4843C))),
          Positioned(left: 36, bottom: 28, child: _Ovalo(width: 28, height: 22, color: Color(0xFFA86B2C))),
          Positioned(left: 78, bottom: 30, child: _Ovalo(width: 16, height: 28, color: Color(0xFFC4843C))),
          Positioned(left: 86, bottom: 50, child: _Ovalo(width: 18, height: 14, color: Color(0xFFC4843C))),
        ],
      ),
    );
  }
}

class _Delfin extends StatelessWidget {
  const _Delfin();

  @override
  Widget build(BuildContext context) {
    return const _Ovalo(width: 96, height: 28, color: Color(0xFF4F7C8A));
  }
}

class _Pinguino extends StatelessWidget {
  const _Pinguino();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 40,
      height: 70,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _Ovalo(width: 36, height: 58, color: Color(0xFF1E2A32)),
          Positioned(bottom: 10, child: _Ovalo(width: 18, height: 36, color: Color(0xFFF4F7FB))),
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
      width: 90,
      height: 60,
      child: Stack(
        children: [
          Positioned(left: 10, bottom: 0, child: _Ovalo(width: 64, height: 36, color: Color(0xFF7A4E2D))),
          Positioned(left: 58, bottom: 22, child: _Ovalo(width: 26, height: 26, color: Color(0xFF7A4E2D))),
        ],
      ),
    );
  }
}

class _Corazon extends StatelessWidget {
  const _Corazon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.favorite, color: Color(0xFFC0392B), size: 72);
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
        _Ovalo(width: 36, height: 56, color: color),
        const SizedBox(width: 8),
        _Ovalo(width: 36, height: 56, color: color),
      ],
    );
  }
}

class _Bolsa extends StatelessWidget {
  const _Bolsa();

  @override
  Widget build(BuildContext context) {
    return const _Ovalo(width: 54, height: 64, color: Color(0xFFE0A36A));
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
