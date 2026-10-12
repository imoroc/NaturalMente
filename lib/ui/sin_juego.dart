import 'package:flutter/material.dart';
import 'package:naturalmente/modelo/zona.dart';

class SinJuegoPage extends StatelessWidget {
  const SinJuegoPage({required this.zona, super.key});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(zona.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Este sitio todavía no tiene juego.',
        ),
      ),
    );
  }
}
