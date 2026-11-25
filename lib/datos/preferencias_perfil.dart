import 'package:shared_preferences/shared_preferences.dart';

/// Vista de [SharedPreferences] que guarda cada clave con un prefijo.
///
/// Así cada perfil de niño tiene su propio progreso sin que [Progreso] sepa
/// que existen otros perfiles: lee y escribe las mismas claves de siempre.
class PreferenciasConPrefijo implements SharedPreferences {
  PreferenciasConPrefijo(this._base, this.prefijo)
    : assert(
        prefijo.isNotEmpty,
        'El perfil principal usa las claves sin prefijo',
      );

  final SharedPreferences _base;
  final String prefijo;

  String _clave(String key) => '$prefijo$key';

  @override
  Set<String> getKeys() => {
    for (final clave in _base.getKeys())
      if (clave.startsWith(prefijo)) clave.substring(prefijo.length),
  };

  @override
  Object? get(String key) => _base.get(_clave(key));
  @override
  bool? getBool(String key) => _base.getBool(_clave(key));
  @override
  int? getInt(String key) => _base.getInt(_clave(key));
  @override
  double? getDouble(String key) => _base.getDouble(_clave(key));
  @override
  String? getString(String key) => _base.getString(_clave(key));
  @override
  List<String>? getStringList(String key) => _base.getStringList(_clave(key));
  @override
  bool containsKey(String key) => _base.containsKey(_clave(key));

  @override
  Future<bool> setBool(String key, bool value) =>
      _base.setBool(_clave(key), value);
  @override
  Future<bool> setInt(String key, int value) =>
      _base.setInt(_clave(key), value);
  @override
  Future<bool> setDouble(String key, double value) =>
      _base.setDouble(_clave(key), value);
  @override
  Future<bool> setString(String key, String value) =>
      _base.setString(_clave(key), value);
  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _base.setStringList(_clave(key), value);
  @override
  Future<bool> remove(String key) => _base.remove(_clave(key));

  /// Borra solo las claves de este perfil.
  @override
  Future<bool> clear() async {
    var todo = true;
    for (final clave in getKeys()) {
      todo = await remove(clave) && todo;
    }
    return todo;
  }

  @override
  @Deprecated('Sin efecto, como en SharedPreferences.')
  Future<bool> commit() async => true;

  @override
  Future<void> reload() => _base.reload();
}
