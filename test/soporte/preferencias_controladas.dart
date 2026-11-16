import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento con escrituras lentas o fallidas sin ocultar su resultado.
class PreferenciasControladas extends Fake implements SharedPreferences {
  final valores = <String, Object>{};
  bool fallar = false;
  String? falloEnClave;
  Completer<void>? bloqueo;

  Future<bool> _escribir(String clave, Object valor) async {
    await bloqueo?.future;
    if (fallar || clave == falloEnClave) return false;
    valores[clave] = valor;
    return true;
  }

  @override
  int? getInt(String key) => valores[key] as int?;
  @override
  String? getString(String key) => valores[key] as String?;
  @override
  bool? getBool(String key) => valores[key] as bool?;
  @override
  List<String>? getStringList(String key) => valores[key] as List<String>?;
  @override
  Future<bool> setInt(String key, int value) => _escribir(key, value);
  @override
  Future<bool> setString(String key, String value) => _escribir(key, value);
  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _escribir(key, List<String>.of(value));
}
