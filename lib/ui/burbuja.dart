import 'package:flutter/material.dart';

class Burbuja extends StatelessWidget {
  const Burbuja({required this.quien, required this.frase, super.key});

  final String quien;
  final String frase;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(quien, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(frase),
        ],
      ),
    );
  }
}
