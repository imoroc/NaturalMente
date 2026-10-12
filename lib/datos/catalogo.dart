import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:naturalmente/modelo/zona.dart';

class Catalogo {
  const Catalogo(this.zonas);

  final List<Zona> zonas;

  static Future<Catalogo> cargar() async {
    final texto = await rootBundle.loadString('content/catalog.json');
    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    final zonas = (mapa['zonas'] as List)
        .cast<Map<String, dynamic>>()
        .map(Zona.desdeMapa)
        .toList();
    return Catalogo(zonas);
  }
}
