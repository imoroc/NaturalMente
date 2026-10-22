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
    if (fichaId == 'pulpo' && hecho('hogar/dificil/completo')) {
      return true;
    }
    if (fichaId == 'intestinos' && hecho('piezas/dificil/completo')) {
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
    if (fichaId == 'fotosintesis' && hecho('germinacion/dificil/completo')) {
      return true;
    }
    if (fichaId == 'una-vida' &&
        (hecho('vida') ||
            hecho('vida/facil/completo') ||
            hecho('vida/medio/completo') ||
            hecho('vida/dificil/completo'))) {
      return true;
    }
    if (fichaId == 'etapas-vida' &&
        (hecho('vida/medio/completo') || hecho('vida/dificil/completo'))) {
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
    // En los juegos con un cromo por nivel, superar un nivel más alto
    // también da los cromos de los anteriores.
    for (final MapEntry(key: juego, value: niveles)
        in _nivelesConCromo.entries) {
      for (var i = 0; i < niveles.length; i++) {
        if (fichasDeNivel(juego, niveles[i]).contains(fichaId) &&
            niveles.skip(i).any((n) => hecho('$juego/$n/completo'))) {
          return true;
        }
      }
    }
    return false;
  }

  static const _nivelesConCromo = {
    'nacimiento': ['facil', 'medio', 'dificil'],
    'digestion': ['facil', 'medio', 'dificil'],
    'sentidos': ['facil', 'medio', 'dificil'],
  };

  static List<String> fichasDeNivel(String actividadId, String nivelId) {
    return switch ((actividadId, nivelId)) {
      ('ecosistemas', _) => const ['claro-bosque'],
      ('hogar', 'facil') => const ['camello', 'delfin', 'pinguino', 'oso'],
      ('hogar', 'medio') => const ['rana', 'tucan'],
      ('hogar', 'dificil') => const ['pulpo'],
      ('germinacion', 'facil') => const ['semilla'],
      ('germinacion', 'medio') => const ['huerto'],
      ('germinacion', 'dificil') => const ['fotosintesis'],
      ('herbario', 'facil') => const ['raiz', 'tallo', 'hoja'],
      ('herbario', 'medio') => const ['flor'],
      ('herbario', 'dificil') => const ['fruto'],
      ('piezas', 'facil') => const ['corazon', 'cerebro', 'estomago'],
      ('piezas', 'medio') => const ['pulmones', 'esqueleto'],
      ('piezas', 'dificil') => const ['intestinos'],
      ('vida', 'facil') => const ['una-vida'],
      ('vida', 'medio') => const ['etapas-vida'],
      ('vida', 'dificil') => const ['celula'],
      ('nacimiento', 'facil') => const ['huevo'],
      ('nacimiento', 'medio') => const ['renacuajo'],
      ('nacimiento', 'dificil') => const ['mariposa'],
      ('digestion', 'facil') => const ['dientes'],
      ('digestion', 'medio') => const ['aparato-digestivo'],
      ('digestion', 'dificil') => const ['nutrientes'],
      ('plantas', 'facil') => const ['encina'],
      ('plantas', 'medio') => const ['romero'],
      ('plantas', 'dificil') => const ['trigo'],
      ('sentidos', 'facil') => const ['sentidos'],
      ('sentidos', 'medio') => const ['avisos'],
      ('sentidos', 'dificil') => const ['reflejo'],
      _ => const <String>[],
    };
  }

  static String pistaDesbloqueoFicha(String fichaId) {
    return switch (fichaId) {
      'claro-bosque' =>
        'Se consigue en «Monta el ecosistema» al superar cualquier nivel.',
      'camello' ||
      'delfin' ||
      'pinguino' ||
      'oso' =>
        'Se consigue en «Cada uno a su hogar» desde el nivel Fácil (1º-2º).',
      'rana' ||
      'tucan' =>
        'Se consigue en «Cada uno a su hogar» a partir del nivel Medio (3º-4º).',
      'pulpo' =>
        'Se consigue en «Cada uno a su hogar» en el nivel Difícil (5º-6º).',
      'semilla' =>
        'Se consigue en «Laboratorio de germinación» desde el nivel Fácil (1º-2º).',
      'huerto' =>
        'Se consigue en «Laboratorio de germinación» a partir del nivel Medio (3º-4º).',
      'fotosintesis' =>
        'Se consigue en «Laboratorio de germinación» en el nivel Difícil (5º-6º).',
      'raiz' ||
      'tallo' ||
      'hoja' =>
        'Se consigue en «Herbario desmontable» desde el nivel Fácil (1º-2º).',
      'flor' =>
        'Se consigue en «Herbario desmontable» a partir del nivel Medio (3º-4º).',
      'fruto' =>
        'Se consigue en «Herbario desmontable» en el nivel Difícil (5º-6º).',
      'corazon' ||
      'cerebro' ||
      'estomago' =>
        'Se consigue en «Cada pieza en su sitio» desde el nivel Fácil (1º-2º).',
      'pulmones' ||
      'esqueleto' =>
        'Se consigue en «Cada pieza en su sitio» a partir del nivel Medio (3º-4º).',
      'intestinos' =>
        'Se consigue en «Cada pieza en su sitio» en el nivel Difícil (5º-6º).',
      'una-vida' =>
        'Se consigue en «Así empieza una vida» desde el nivel Fácil (1º-2º).',
      'etapas-vida' =>
        'Se consigue en «Así empieza una vida» a partir del nivel Medio (3º-4º).',
      'celula' =>
        'Se consigue en «Así empieza una vida» en el nivel Difícil (5º-6º).',
      'huevo' =>
        'Se consigue en «¿Huevo o barriga?» desde el nivel Fácil (1º-2º).',
      'renacuajo' =>
        'Se consigue en «¿Huevo o barriga?» a partir del nivel Medio (3º-4º).',
      'mariposa' =>
        'Se consigue en «¿Huevo o barriga?» en el nivel Difícil (5º-6º).',
      'dientes' =>
        'Se consigue en «El viaje de la comida» desde el nivel Fácil (1º-2º).',
      'aparato-digestivo' =>
        'Se consigue en «El viaje de la comida» a partir del nivel Medio (3º-4º).',
      'nutrientes' =>
        'Se consigue en «El viaje de la comida» en el nivel Difícil (5º-6º).',
      'encina' =>
        'Se consigue en «Árbol, arbusto o hierba» desde el nivel Fácil (1º-2º).',
      'romero' =>
        'Se consigue en «Árbol, arbusto o hierba» a partir del nivel Medio (3º-4º).',
      'trigo' =>
        'Se consigue en «Árbol, arbusto o hierba» en el nivel Difícil (5º-6º).',
      'sentidos' =>
        'Se consigue en «Los cinco sentidos» desde el nivel Fácil (1º-2º).',
      'avisos' =>
        'Se consigue en «Los cinco sentidos» a partir del nivel Medio (3º-4º).',
      'reflejo' =>
        'Se consigue en «Los cinco sentidos» en el nivel Difícil (5º-6º).',
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
    // Los juegos de «lugar» con un cromo propio por nivel (no por reto).
    for (final fichaId in fichasDeNivel(actividad.id, nivel)) {
      await desbloquearFicha(fichaId);
    }
    if (actividad.id == 'germinacion') {
      await desbloquearFicha('semilla');
      if (nivel == 'medio' || nivel == 'dificil') {
        await desbloquearFicha('huerto');
      }
      if (nivel == 'dificil') {
        await desbloquearFicha('fotosintesis');
      }
    }
    if (actividad.id == 'vida') {
      await desbloquearFicha('una-vida');
      if (nivel == 'medio' || nivel == 'dificil') {
        await desbloquearFicha('etapas-vida');
      }
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

  String? get ultimoNivelEcosistema =>
      _prefs.getString('ecosistemas/ultimo-nivel');

  Future<bool> recordarNivelEcosistema(String nivel) async {
    if (!const ['facil', 'medio', 'dificil'].contains(nivel)) {
      return false;
    }
    try {
      return await _prefs.setString('ecosistemas/ultimo-nivel', nivel);
    } catch (_) {
      return false;
    }
  }

  bool nivelEcosistemaHecho(Actividad actividad, String nivel) =>
      hecho('${actividad.id}/$nivel/completo');

  Future<void> marcarNivelEcosistema(Actividad actividad, String nivel) async {
    if (actividad.ecosistema?.niveles.any((n) => n.id == nivel) != true) {
      throw ArgumentError('Ese nivel no existe en ${actividad.id}.');
    }
    await _marcar('${actividad.id}/$nivel/completo');
    await desbloquearFicha('claro-bosque');
    await _marcar(actividad.id);
  }

  /// Niveles de los juegos con modelo propio y un cromo por nivel.
  List<String> _nivelesJuego(Actividad actividad) => switch (actividad.tipo) {
    'nacimiento' => [
      for (final n in actividad.nacimiento?.niveles ?? const []) n.id,
    ],
    'viaje' => [for (final n in actividad.viaje?.niveles ?? const []) n.id],
    _ => const [],
  };

  bool nivelJuegoHecho(Actividad actividad, String nivel) =>
      hecho('${actividad.id}/$nivel/completo');

  bool nivelNacimientoHecho(Actividad actividad, String nivel) =>
      nivelJuegoHecho(actividad, nivel);

  Future<void> marcarNivelNacimiento(Actividad actividad, String nivel) =>
      marcarNivelJuego(actividad, nivel);

  Future<void> marcarNivelJuego(Actividad actividad, String nivel) async {
    final niveles = _nivelesJuego(actividad);
    final indice = niveles.indexOf(nivel);
    if (indice < 0) {
      throw ArgumentError('Ese nivel no existe en ${actividad.id}.');
    }
    await _marcar('${actividad.id}/$nivel/completo');
    // Cada nivel trae su cromo y los de los niveles anteriores.
    for (final anterior in niveles.take(indice + 1)) {
      for (final fichaId in fichasDeNivel(actividad.id, anterior)) {
        await desbloquearFicha(fichaId);
      }
    }
    await marcarActividad(actividad);

  }

  int nivelesSuperadosDe(Actividad actividad) {
    if (actividad.ecosistema != null) {
      return actividad.ecosistema!.niveles
          .where((n) => nivelEcosistemaHecho(actividad, n.id))
          .length;
    }
    if (actividad.tipo == 'herbario') {
      final niveles = actividad.herbario?.niveles ?? const [];
      return niveles.where((n) => nivelHerbarioHecho(actividad, n.id)).length;
    }
    if (actividad.tipo == 'nacimiento' || actividad.tipo == 'viaje') {
      return _nivelesJuego(
        actividad,
      ).where((n) => nivelJuegoHecho(actividad, n)).length;
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
    if (actividad.ecosistema != null) {
      return actividad.ecosistema!.niveles.length;
    }
    if (actividad.tipo == 'herbario') {
      return actividad.herbario?.niveles.length ?? 1;
    }
    if (actividad.tipo == 'nacimiento' || actividad.tipo == 'viaje') {
      final niveles = _nivelesJuego(actividad);
      return niveles.isEmpty ? 1 : niveles.length;
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
