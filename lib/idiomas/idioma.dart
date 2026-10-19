import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencia local independiente del progreso y de las reglas de juego.
class Idioma extends ChangeNotifier {
  Idioma(this._preferencias, this.traducciones)
    : _codigo = _preferencias.getString('idioma') == 'en' ? 'en' : 'es';

  final SharedPreferences _preferencias;
  final Map<String, String> traducciones;
  String _codigo;
  String get codigo => _codigo;
  Locale get locale => Locale(_codigo);

  static Future<Idioma> abrir() async {
    final preferencias = await SharedPreferences.getInstance();
    final datos = await rootBundle.load('content/en.json');
    final textos = jsonDecode(
      utf8.decode(
        datos.buffer.asUint8List(datos.offsetInBytes, datos.lengthInBytes),
      ),
    ) as Map<String, dynamic>;
    return Idioma(preferencias, textos.cast<String, String>());
  }

  Future<bool> elegir(String codigo) async {
    if (!const ['es', 'en'].contains(codigo)) return false;
    if (codigo == _codigo) return true;
    if (!await _preferencias.setString('idioma', codigo)) return false;
    _codigo = codigo;
    notifyListeners();
    return true;
  }

  String traducir(String texto) {
    if (_codigo == 'es' || texto.isEmpty) return texto;
    return _traducir(texto);
  }

  String _traducir(String texto) {
    final exacta = traducciones[texto];
    if (exacta != null) return exacta;
    final sinMayusculas = _minusculas[texto.toLowerCase()];
    if (sinMayusculas != null) {
      return texto == texto.toUpperCase()
          ? sinMayusculas.toUpperCase()
          : texto == texto.toLowerCase()
          ? sinMayusculas.toLowerCase()
          : sinMayusculas;
    }
    for (final plantilla in _plantillas) {
      final coincidencia = plantilla.$1.firstMatch(texto);
      if (coincidencia != null) {
        return plantilla.$2.replaceAllMapped(RegExp(r'\{(\d+)\}'), (m) {
          return _traducir(coincidencia.group(int.parse(m[1]!) + 1)!);
        });
      }
    }
    // Una respuesta y su pista siguen siendo dos textos del catálogo.
    for (final entrada in traducciones.entries) {
      if (texto.startsWith('${entrada.key} ') && entrada.key.endsWith('.')) {
        return '${entrada.value} ${_traducir(texto.substring(entrada.key.length + 1))}';
      }
    }
    final numerada = RegExp(r'^(\d+)\. (.+)$').firstMatch(texto);
    if (numerada != null) {
      return '${numerada[1]}. ${_traducir(numerada[2]!)}';
    }
    // Composiciones de etiquetas y listas.
    for (final separador in [' · ', '\n', ', ']) {
      if (texto.contains(separador)) {
        final partes = texto.split(separador);
        final traducidas = partes.map(_traducir).toList();
        if (List.generate(
          partes.length,
          (i) => partes[i] != traducidas[i],
        ).any((cambio) => cambio)) {
          return traducidas.join(separador);
        }
      }
    }
    return texto;
  }

  late final Map<String, String> _minusculas = {
    for (final entrada in traducciones.entries)
      entrada.key.toLowerCase(): entrada.value,
  };

  // Las frases más concretas se prueban antes que sus prefijos con parámetros.
  late final List<MapEntry<String, String>> _entradasPlantilla =
      traducciones.entries
          .where((e) => e.key.contains(RegExp(r'\{\d+\}')))
          .toList()
        ..sort(
          (a, b) => b.key
              .replaceAll(RegExp(r'\{\d+\}'), '')
              .length
              .compareTo(a.key.replaceAll(RegExp(r'\{\d+\}'), '').length),
        );

  late final List<(RegExp, String)> _plantillas = [
    for (final entrada in _entradasPlantilla)
      if (entrada.key.contains(RegExp(r'\{\d+\}')))
        (
          RegExp(
            '^${entrada.key.split(RegExp(r'\{\d+\}')).map(RegExp.escape).join('(.*?)')}\$',
          ),
          entrada.value,
        ),
  ];
}

class IdiomaScope extends InheritedNotifier<Idioma> {
  const IdiomaScope({required Idioma idioma, required super.child, super.key})
    : super(notifier: idioma);

  static Idioma? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IdiomaScope>()?.notifier;
}

extension TraduccionContext on BuildContext {
  String traducir(String texto) =>
      IdiomaScope.of(this)?.traducir(texto) ?? texto;
}
