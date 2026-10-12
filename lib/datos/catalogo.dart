import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/modelo/zona.dart';

class Catalogo {
  const Catalogo({
    required this.zonas,
    required this.fichas,
    required this.actividades,
  });

  final List<Zona> zonas;
  final List<Ficha> fichas;
  final List<Actividad> actividades;

  List<Ficha> fichasDe(String zona) {
    return fichas.where((ficha) => ficha.zona == zona).toList();
  }

  List<Actividad> actividadesDe(String zona) {
    return actividades.where((actividad) => actividad.zona == zona).toList();
  }

  static Future<Catalogo> cargar() async {
    final texto = await rootBundle.loadString('content/catalog.json');
    return desdeTexto(texto);
  }

  static Catalogo desdeTexto(String texto) {
    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    return Catalogo(
      zonas: (mapa['zonas'] as List)
          .cast<Map<String, dynamic>>()
          .map(Zona.desdeMapa)
          .toList(),
      fichas: (mapa['fichas'] as List)
          .cast<Map<String, dynamic>>()
          .map(Ficha.desdeMapa)
          .toList(),
      actividades: (mapa['actividades'] as List)
          .cast<Map<String, dynamic>>()
          .map(Actividad.desdeMapa)
          .toList(),
    );
  }
}
