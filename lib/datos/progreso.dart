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

  bool retoHecho(Actividad actividad, Reto reto) =>
      hecho(_reto(actividad, reto));

  bool actividadHecha(Actividad actividad) {
    if (actividad.tipo == 'lugar') {
      if (actividad.nivelesLugar.any((n) => nivelLugarHecho(actividad, n.id))) {
        return true;
      }
      return actividad.retos.every((reto) => retoHecho(actividad, reto));
    }
    return hecho(actividad.id);
  }

  bool medallaConseguida(Iterable<Actividad> actividades) {
    final necesarias = actividades.where((actividad) => actividad.medalla);
    return necesarias.isNotEmpty && necesarias.every(actividadHecha);
  }

  Future<void> marcarReto(Actividad actividad, Reto reto) async {
    await _marcar(_reto(actividad, reto));
    await desbloquearFicha(reto.id);
  }

  Future<void> marcarActividad(Actividad actividad) async {
    await _marcar(actividad.id);
    if (actividad.id == 'germinacion') {
      await desbloquearFicha('semilla');
    } else if (actividad.id == 'vida') {
      await desbloquearFicha('una-vida');
    }
  }

  bool fichaDesbloqueada(String fichaId) {
    if (hecho('ficha/$fichaId')) return true;
    if (hecho('hogar/$fichaId') || hecho('piezas/$fichaId')) return true;
    if (fichaId == 'insectos' && hecho('hogar/dificil/completo')) {
      return true;
    }
    if (fichaId == 'sentidos' && hecho('piezas/dificil/completo')) {
      return true;
    }
    if (fichaId == 'semilla' &&
        (hecho('germinacion') ||
            hecho('germinacion/facil/completo') ||
            hecho('germinacion/medio/completo') ||
            hecho('germinacion/dificil/completo'))) {
      return true;
    }
    if (fichaId == 'huerto' &&
        (hecho('germinacion/medio/completo') ||
            hecho('germinacion/dificil/completo'))) {
      return true;
    }
    if (fichaId == 'una-vida' &&
        (hecho('vida') ||
            hecho('vida/facil/completo') ||
            hecho('vida/medio/completo') ||
            hecho('vida/dificil/completo'))) {
      return true;
    }
    if (fichaId == 'celula' && hecho('vida/dificil/completo')) {
      return true;
    }
    if (const {'raiz', 'tallo', 'hoja'}.contains(fichaId) &&
        (hecho('herbario/facil/completo') ||
            hecho('herbario/medio/completo') ||
            hecho('herbario/dificil/completo'))) {
      return true;
    }
    if (fichaId == 'flor' &&
        (hecho('herbario/medio/completo') ||
            hecho('herbario/dificil/completo'))) {
      return true;
    }
    if (fichaId == 'fruto' && hecho('herbario/dificil/completo')) {
      return true;
    }
    return false;
  }

  static String pistaDesbloqueoFicha(String fichaId) {
    return switch (fichaId) {
      'camello' ||
      'delfin' ||
      'pinguino' ||
      'oso' =>
        'Se consigue en «Cada uno a su hogar» desde el nivel Fácil (1º-2º).',
      'rana' ||
      'tucan' =>
        'Se consigue en «Cada uno a su hogar» a partir del nivel Medio (3º-4º).',
      'insectos' =>
        'Se consigue en «Cada uno a su hogar» en el nivel Difícil (5º-6º).',
      'semilla' =>
        'Se consigue en «Laboratorio de germinación» desde el nivel Fácil (1º-2º).',
      'huerto' =>
        'Se consigue en «Laboratorio de germinación» a partir del nivel Medio (3º-4º).',
      'raiz' ||
      'tallo' ||
      'hoja' =>
        'Se consigue en «Herbario desmontable» desde el nivel Fácil (1º-2º).',
      'flor' =>
        'Se consigue en «Herbario desmontable» a partir del nivel Medio (3º-4º).',
      'fruto' =>
        'Se consigue en «Herbario desmontable» en el nivel Difícil (5º-6º).',
      'corazon' ||
      'pulmones' ||
      'estomago' =>
        'Se consigue en «Cada pieza en su sitio» desde el nivel Fácil (1º-2º).',
      'cerebro' ||
      'esqueleto' =>
        'Se consigue en «Cada pieza en su sitio» a partir del nivel Medio (3º-4º).',
      'sentidos' =>
        'Se consigue en «Cada pieza en su sitio» en el nivel Difícil (5º-6º).',
      'una-vida' =>
        'Se consigue en «Así empieza una vida» desde el nivel Fácil (1º-2º).',
      'celula' =>
        'Se consigue en «Así empieza una vida» en el nivel Difícil (5º-6º).',
      _ => 'Sigue explorando las misiones con Natu para conseguir este cromo.',
    };
  }

  Future<void> desbloquearFicha(String fichaId) => _marcar('ficha/$fichaId');

  bool nivelLugarHecho(Actividad actividad, String nivel) {
    if (nivel == 'facil' &&
        actividad.retos.isNotEmpty &&
        actividad.retos.every((reto) => retoHecho(actividad, reto))) {
      return true;
    }
    return hecho('${actividad.id}/$nivel/completo');
  }

  Future<void> marcarNivelLugar(Actividad actividad, String nivel) async {
    await _marcar('${actividad.id}/$nivel/completo');
    final retosNivel =
        actividad.nivelesLugar
            .where((n) => n.id == nivel)
            .firstOrNull
            ?.retos ??
        const <Reto>[];
    for (final reto in retosNivel) {
      await desbloquearFicha(reto.id);
    }
    if (nivel == 'facil') {
      for (final reto in actividad.retos) {
        await marcarReto(actividad, reto);
      }
    }
    if (actividad.id == 'hogar' && nivel == 'dificil') {
      await desbloquearFicha('insectos');
    }
    if (actividad.id == 'piezas' && nivel == 'dificil') {
      await desbloquearFicha('sentidos');
    }
    if (actividad.id == 'germinacion') {
      await desbloquearFicha('semilla');
      if (nivel == 'medio' || nivel == 'dificil') {
        await desbloquearFicha('huerto');
      }
    }
    if (actividad.id == 'vida') {
      await desbloquearFicha('una-vida');
      if (nivel == 'dificil') {
        await desbloquearFicha('celula');
      }
    }
  }

  bool nivelHerbarioHecho(Actividad actividad, String nivel) =>
      hecho('${actividad.id}/$nivel/completo');

  Future<void> marcarNivelHerbario(Actividad actividad, String nivel) async {
    final niveles = actividad.herbario?.niveles;
    final datosNivel = niveles?.where((n) => n.id == nivel).firstOrNull;
    if (datosNivel == null) {
      throw ArgumentError('Ese nivel no existe en ${actividad.id}.');
    }
    await _marcar('${actividad.id}/$nivel/completo');
    for (final parteId in datosNivel.partes) {
      if (parteId == 'fruto' && nivel != 'dificil') continue;
      await desbloquearFicha(parteId);
    }
    await marcarActividad(actividad);
  }

  int nivelesSuperadosDe(Actividad actividad) {
    if (actividad.tipo == 'herbario') {
      final niveles = actividad.herbario?.niveles ?? const [];
      return niveles.where((n) => nivelHerbarioHecho(actividad, n.id)).length;
    }
    if (actividad.nivelesLugar.isNotEmpty) {
      final superados = actividad.nivelesLugar
          .where((n) => nivelLugarHecho(actividad, n.id))
          .length;
      if (superados > 0) return superados;
      return actividadHecha(actividad) ? 1 : 0;
    }
    return actividadHecha(actividad) ? 1 : 0;
  }

  int maxNivelesDe(Actividad actividad) {
    if (actividad.tipo == 'herbario') {
      return actividad.herbario?.niveles.length ?? 1;
    }
    if (actividad.nivelesLugar.isNotEmpty) {
      return actividad.nivelesLugar.length;
    }
    return 1;
  }

  int totalNivelesSuperados(Iterable<Actividad> actividades) =>
      actividades.fold(0, (suma, a) => suma + nivelesSuperadosDe(a));

  int totalMaxNiveles(Iterable<Actividad> actividades) =>
      actividades.fold(0, (suma, a) => suma + maxNivelesDe(a));

  Future<void> _marcar(String id) async {
    if (!_hechos.add(id)) return;
    try {
      final guardado = await _prefs.setStringList(_clave, _hechos.toList());
      if (!guardado) throw StateError('No se ha podido guardar el progreso.');
    } catch (_) {
      _hechos.remove(id);
      rethrow;
    }
    notifyListeners();
  }

  String _reto(Actividad actividad, Reto reto) => '${actividad.id}/${reto.id}';
}
