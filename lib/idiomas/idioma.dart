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
    final textos = jsonDecode(await rootBundle.loadString('content/en.json'))
        as Map<String, dynamic>;
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
    // Los títulos del álbum usan las mismas traducciones en mayúsculas.
    if (texto == texto.toUpperCase()) {
      for (final entrada in traducciones.entries) {
        if (entrada.key.toUpperCase() == texto) {
          return entrada.value.toUpperCase();
        }
      }
    }
    for (final plantilla in _plantillas) {
      final coincidencia = plantilla.$1.firstMatch(texto);
      if (coincidencia != null) {
        return plantilla.$2.replaceAllMapped(RegExp(r'\{(\d+)\}'), (m) {
          return _traducir(coincidencia.group(int.parse(m[1]!) + 1)!);
        });
      }
    }
    // Composiciones de etiquetas, listas y mensajes de respuesta con pista.
    for (final separador in [' · ', '\n', ', ', '. ']) {
      if (texto.contains(separador)) {
        final partes = texto.split(separador);
        final traducidas = partes.map(_traducir).toList();
        if (List.generate(partes.length, (i) => partes[i] != traducidas[i])
            .any((cambio) => cambio)) {
          return traducidas.join(separador);
        }
      }
    }
    return texto;
  }

  late final List<(RegExp, String)> _plantillas = [
    for (final entrada in traducciones.entries)
      if (entrada.key.contains(RegExp(r'\{\d+\}')))
        (
          RegExp('^${entrada.key.split(RegExp(r'\{\d+\}')).map(RegExp.escape).join('(.*?)')}\$'),
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
  String traducir(String texto) => IdiomaScope.of(this)?.traducir(texto) ?? texto;
}
