import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naturalmente/modelo/actividad.dart';

// Lo que el niño ya ha superado. El resto de la app no sabe si está
// en memoria o en el teléfono.
class Progreso extends ChangeNotifier {
  Progreso(this._prefs, Set<String> hechos) : _hechos = hechos;

  static const _clave = 'hechos';

  final SharedPreferences _prefs;
  final Set<String> _hechos;

  static Future<Progreso> abrir() async {
    final prefs = await SharedPreferences.getInstance();
    final guardados = prefs.getStringList(_clave) ?? const <String>[];
    return Progreso(prefs, guardados.toSet());
  }

  bool hecho(String id) => _hechos.contains(id);

  bool retoHecho(Actividad actividad, Reto reto) => hecho(_reto(actividad, reto));

  bool actividadHecha(Actividad actividad) {
    if (actividad.tipo == 'lugar') {
      return actividad.retos.every((reto) => retoHecho(actividad, reto));
    }
    return hecho(actividad.id);
  }

  bool medallaConseguida(Iterable<Actividad> actividades) {
    final necesarias = actividades.where((actividad) => actividad.medalla);
    return necesarias.isNotEmpty && necesarias.every(actividadHecha);
  }

  Future<void> marcarReto(Actividad actividad, Reto reto) {
    return _marcar(_reto(actividad, reto));
  }

  Future<void> marcarActividad(Actividad actividad) {
    return _marcar(actividad.id);
  }

  Future<void> _marcar(String id) async {
    if (!_hechos.add(id)) return;
    await _prefs.setStringList(_clave, _hechos.toList());
    notifyListeners();
  }

  String _reto(Actividad actividad, Reto reto) => '${actividad.id}/${reto.id}';
}
