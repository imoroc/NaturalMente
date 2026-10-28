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
    if (!_nivelesConCromo.containsKey(actividad.id)) {
      await desbloquearFicha(reto.id);
    }
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
    'plantas': ['facil', 'medio', 'dificil'],
    'porte-planta': ['facil', 'medio', 'dificil'],
    'sentidos': ['facil', 'medio', 'dificil'],
    'habitos': ['facil', 'medio', 'dificil'],
    'dieta': ['facil', 'medio', 'dificil'],
    'grupos': ['facil', 'medio', 'dificil'],
    'polinizacion': ['facil', 'medio', 'dificil'],
    'estaciones': ['facil', 'medio', 'dificil'],
    'huerta': ['facil', 'medio', 'dificil'],
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

      ('habitos', 'facil') => const ['higiene'],
      ('habitos', 'medio') => const ['descanso'],
      ('habitos', 'dificil') => const ['cuidar-sentidos'],




      ('plantas' || 'porte-planta', 'facil') => const ['encina'],
      ('plantas' || 'porte-planta', 'medio') => const ['romero'],
      ('plantas' || 'porte-planta', 'dificil') => const ['trigo'],

      ('sentidos', 'facil') => const ['sentidos'],
      ('sentidos', 'medio') => const ['avisos'],
      ('sentidos', 'dificil') => const ['reflejo'],
      ('dieta', 'facil') => const ['herbivoro'],
      ('dieta', 'medio') => const ['pico-garra'],
      ('dieta', 'dificil') => const ['branquias'],
      ('grupos', 'facil') => const ['vertebrado'],
      ('grupos', 'medio') => const ['anfibio'],
      ('grupos', 'dificil') => const ['artropodo'],
      ('polinizacion', 'facil') => const ['abeja-polen'],
      ('polinizacion', 'medio') => const ['semilla-viajera'],
      ('polinizacion', 'dificil') => const ['helecho-espora'],
      ('estaciones', 'facil') => const ['hoja-caduca'],
      ('estaciones', 'medio') => const ['formas-hoja'],
      ('estaciones', 'dificil') => const ['bosque-clima'],
      ('huerta', 'facil') => const ['huerta-organos'],
      ('huerta', 'medio') => const ['partes-comestibles'],
      ('huerta', 'dificil') => const ['recursos-plantas'],
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
      'higiene' =>
        'Se consigue en «¿Me cuida o no?» desde el nivel Fácil (1º-2º).',
      'descanso' =>
        'Se consigue en «¿Me cuida o no?» a partir del nivel Medio (3º-4º).',
      'cuidar-sentidos' =>
        'Se consigue en «¿Me cuida o no?» en el nivel Difícil (5º-6º).',
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
      'herbivoro' =>
        'Se consigue en «Picos, dientes y huellas» desde el nivel Fácil (1º-2º).',
      'pico-garra' =>
        'Se consigue en «Picos, dientes y huellas» a partir del nivel Medio (3º-4º).',
      'branquias' =>
        'Se consigue en «Picos, dientes y huellas» en el nivel Difícil (5º-6º).',
      'vertebrado' =>
        'Se consigue en «¿Huesos o caparazón?» desde el nivel Fácil (1º-2º).',
      'anfibio' =>
        'Se consigue en «¿Huesos o caparazón?» a partir del nivel Medio (3º-4º).',
      'artropodo' =>
        'Se consigue en «¿Huesos o caparazón?» en el nivel Difícil (5º-6º).',
      'abeja-polen' =>
        'Se consigue en «Polen y semillas viajeras» desde el nivel Fácil (1º-2º).',
      'semilla-viajera' =>
        'Se consigue en «Polen y semillas viajeras» a partir del nivel Medio (3º-4º).',
      'helecho-espora' =>
        'Se consigue en «Polen y semillas viajeras» en el nivel Difícil (5º-6º).',
      'hoja-caduca' =>
        'Se consigue en «Los árboles y las estaciones» desde el nivel Fácil (1º-2º).',
      'formas-hoja' =>
        'Se consigue en «Los árboles y las estaciones» a partir del nivel Medio (3º-4º).',
      'bosque-clima' =>
        'Se consigue en «Los árboles y las estaciones» en el nivel Difícil (5º-6º).',
      'huerta-organos' =>
        'Se consigue en «Del huerto a la mesa» desde el nivel Fácil (1º-2º).',
      'partes-comestibles' =>
        'Se consigue en «Del huerto a la mesa» a partir del nivel Medio (3º-4º).',
      'recursos-plantas' =>
        'Se consigue en «Del huerto a la mesa» en el nivel Difícil (5º-6º).',
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
    if (!_nivelesConCromo.containsKey(actividad.id)) {
      final retosNivel =
          actividad.nivelesLugar
              .where((n) => n.id == nivel)
              .firstOrNull
              ?.retos ??
          const <Reto>[];
      for (final reto in retosNivel) {
        await desbloquearFicha(reto.id);
      }
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

  // --- Economía educativa: Semillas de Sabiduría y Racha de Precisión ---

  static const _claveSemillas = 'economia/semillas';
  static const _claveComboActual = 'economia/combo-actual';
  static const _claveMejorCombo = 'economia/mejor-combo';
  static const _claveTrajeEquipado = 'natu/traje-equipado';
  static const _claveTrajesEquipados = 'natu/trajes-equipados';
  static const _claveRachaDias = 'racha/dias';
  static const _claveUltimaFechaRacha = 'racha/ultima-fecha';

  static const trajesDisponibles = <String>[
    'ninguno',
    'explorador',
    'botanico',
    'doctor',
    'marino',
    'nocturno',
    'guardian',
    'apicultor',
    'polar',
    'aviador',
    'lupas',
    'brujula',
    'herbarioro',
    'maestro_reserva',
    'maestro_invernadero',
    'maestro_cuerpo',
    'racha_fuego',
    'leyenda_natu',
  ];

  static const trajesPorLogro = <String>{
    'maestro_reserva',
    'maestro_invernadero',
    'maestro_cuerpo',
    'racha_fuego',
    'leyenda_natu',
  };

  int get semillas => _prefs.getInt(_claveSemillas) ?? 0;

  int get comboActual => _prefs.getInt(_claveComboActual) ?? 0;

  int get mejorCombo => _prefs.getInt(_claveMejorCombo) ?? 0;

  Future<int> sumarSemillas(int cantidad) async {
    if (cantidad <= 0) return 0;
    final nuevoTotal = semillas + cantidad;
    try {
      await _prefs.setInt(_claveSemillas, nuevoTotal);
    } catch (_) {
      return 0;
    }
    notifyListeners();
    return cantidad;
  }

  Future<void> romperComboPrecision() async {
    try {
      await _prefs.setInt(_claveComboActual, 0);
    } catch (_) {
      return;
    }
    notifyListeners();
  }

  Future<int> registrarAciertoPrecision({
    required bool aLaPrimera,
    int? comboActual,
  }) async {
    final comboEfectivo =
        comboActual ?? (aLaPrimera ? (this.comboActual + 1) : 1);
    final ganadas = aLaPrimera
        ? (comboEfectivo >= 3 ? 3 : (comboEfectivo == 2 ? 2 : 1))
        : 1;
    final nuevoTotal = semillas + ganadas;
    try {
      await _prefs.setInt(_claveSemillas, nuevoTotal);
      await _prefs.setInt(_claveComboActual, comboEfectivo);
      if (comboEfectivo > mejorCombo) {
        await _prefs.setInt(_claveMejorCombo, comboEfectivo);
      }
    } catch (_) {
      return 0;
    }
    notifyListeners();
    return ganadas;
  }

  // --- Logros de Maestría por Zona y Juego Completo ---

  bool zonaDominada(Iterable<Actividad> actividadesZona) {
    final lista = actividadesZona.toList();
    if (lista.isEmpty) return false;
    return totalNivelesSuperados(lista) >= totalMaxNiveles(lista);
  }

  bool logroTrajeCumplido(
    String trajeId,
    Iterable<Actividad> todasActividades,
  ) {
    if (hecho('traje/$trajeId')) return true;
    final lista = todasActividades.toList();
    if (lista.isEmpty) return false;
    return switch (trajeId) {
      'maestro_reserva' => zonaDominada(
        lista.where((a) => a.zona == 'reserva'),
      ),
      'maestro_invernadero' => zonaDominada(
        lista.where((a) => a.zona == 'invernadero'),
      ),
      'maestro_cuerpo' => zonaDominada(
        lista.where((a) => a.zona == 'cuerpo'),
      ),
      'racha_fuego' => rachaDias >= 3 || mejorCombo >= 8,
      'leyenda_natu' => zonaDominada(lista),
      _ => false,
    };
  }

  Future<List<String>> sincronizarLogrosTrajes(
    Iterable<Actividad> todasActividades,
  ) async {
    final nuevos = <String>[];
    for (final id in trajesPorLogro) {
      if (!hecho('traje/$id') && logroTrajeCumplido(id, todasActividades)) {
        await _marcar('traje/$id');
        nuevos.add(id);
      }
    }
    return nuevos;
  }

  // --- Armario Científico de Natu (Multi-ranura compatible) ---

  static String slotDeTraje(String trajeId) => switch (trajeId) {
    'explorador' ||
    'botanico' ||
    'nocturno' ||
    'apicultor' ||
    'polar' ||
    'maestro_reserva' ||
    'maestro_invernadero' =>
      'cabeza',
    'doctor' || 'marino' || 'aviador' || 'lupas' || 'maestro_cuerpo' => 'ojos',
    'guardian' ||
    'brujula' ||
    'herbarioro' ||
    'racha_fuego' ||
    'leyenda_natu' =>
      'insignia',
    _ => 'ninguno',
  };

  Set<String> get trajesEquipados {
    final lista = _prefs.getStringList(_claveTrajesEquipados);
    if (lista != null && lista.isNotEmpty) {
      final validos = lista
          .where((id) => id != 'ninguno' && trajeDesbloqueado(id))
          .toSet();
      if (validos.isNotEmpty) return validos;
    }
    final individual = _prefs.getString(_claveTrajeEquipado) ?? 'ninguno';
    if (individual != 'ninguno' && trajeDesbloqueado(individual)) {
      return {individual};
    }
    return const <String>{};
  }

  bool trajeEstaEquipado(String trajeId) {
    if (trajeId == 'ninguno') return trajesEquipados.isEmpty;
    return trajesEquipados.contains(trajeId);
  }

  String get trajeEquipado {
    final activos = trajesEquipados;
    if (activos.isEmpty) return 'ninguno';
    if (activos.length == 1) return activos.first;
    return activos.join(',');
  }

  bool trajeDesbloqueado(String trajeId) =>
      trajeId == 'ninguno' || hecho('traje/$trajeId');

  Set<String> get trajesDesbloqueados => {
    'ninguno',
    for (final id in trajesDisponibles)
      if (hecho('traje/$id')) id,
  };

  Future<bool> desbloquearTraje(String trajeId, int coste) async {
    if (!trajesDisponibles.contains(trajeId)) return false;
    if (trajeDesbloqueado(trajeId)) {
      return equiparTraje(trajeId);
    }
    if (coste < 0 || semillas < coste) return false;
    final resto = semillas - coste;
    try {
      final okSemillas = await _prefs.setInt(_claveSemillas, resto);
      if (!okSemillas) return false;
      await _marcar('traje/$trajeId');
      await _guardarTrajeEnSlot(trajeId, alternarSiYaEsta: false);
    } catch (_) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> equiparTraje(String trajeId) async {
    if (!trajeDesbloqueado(trajeId)) return false;
    try {
      final ok = await _guardarTrajeEnSlot(trajeId, alternarSiYaEsta: false);
      if (!ok) return false;
    } catch (_) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> alternarTraje(String trajeId) async {
    if (!trajeDesbloqueado(trajeId)) return false;
    try {
      final ok = await _guardarTrajeEnSlot(trajeId, alternarSiYaEsta: true);
      if (!ok) return false;
    } catch (_) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> _guardarTrajeEnSlot(
    String trajeId, {
    required bool alternarSiYaEsta,
  }) async {
    if (trajeId == 'ninguno') {
      await _prefs.setStringList(_claveTrajesEquipados, const <String>[]);
      return _prefs.setString(_claveTrajeEquipado, 'ninguno');
    }
    final actuales = trajesEquipados.toList();
    final slotNuevo = slotDeTraje(trajeId);
    if (alternarSiYaEsta && actuales.contains(trajeId)) {
      actuales.remove(trajeId);
    } else {
      actuales.removeWhere((id) => slotDeTraje(id) == slotNuevo);
      actuales.add(trajeId);
    }
    await _prefs.setStringList(_claveTrajesEquipados, actuales);
    final principal = actuales.isEmpty ? 'ninguno' : actuales.last;
    return _prefs.setString(_claveTrajeEquipado, principal);
  }

  static const _clavePoseEquipada = 'natu/pose-equipada';

  static const posesDisponibles = <String>[
    'hola',
    'feliz',
    'pensando',
    'estudio',
    'pista',
  ];

  bool get tienePosePersonalizada {
    final pose = _prefs.getString(_clavePoseEquipada);
    return pose != null && posesDisponibles.contains(pose);
  }

  String get poseEquipada {
    final pose = _prefs.getString(_clavePoseEquipada);
    if (pose != null && posesDisponibles.contains(pose)) {
      return pose;
    }
    return 'hola';
  }

  Future<bool> equiparPose(String pose) async {
    if (!posesDisponibles.contains(pose)) return false;
    try {
      final ok = await _prefs.setString(_clavePoseEquipada, pose);
      if (!ok) return false;
    } catch (_) {
      return false;
    }
    notifyListeners();
    return true;
  }

  // --- Racha Diaria y Expedición del Día ---

  static String formatearFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String? get ultimaFechaRacha => _prefs.getString(_claveUltimaFechaRacha);

  int rachaActiva([DateTime? referencia]) {
    final guardada = _prefs.getInt(_claveRachaDias) ?? 0;
    if (guardada <= 0) return 0;
    final ultima = ultimaFechaRacha;
    if (ultima == null) return 0;
    final ref = referencia ?? DateTime.now();
    final hoy = formatearFecha(ref);
    final ayer = formatearFecha(DateTime(ref.year, ref.month, ref.day - 1));
    if (ultima == hoy || ultima == ayer) {
      return guardada;
    }
    return 0;
  }

  int get rachaDias => rachaActiva();

  bool expedicionHoyHecha([DateTime? referencia]) {
    final hoy = formatearFecha(referencia ?? DateTime.now());
    if (hecho('expedicion/$hoy')) return true;
    final ultima = ultimaFechaRacha;
    if (ultima == null) return false;
    return ultima == hoy;
  }

  String dificultadExpedicionHoy([DateTime? referencia]) {
    final hoy = formatearFecha(referencia ?? DateTime.now());
    return _prefs.getString('expedicion/dificultad/$hoy') ?? 'facil';
  }

  int aciertosExpedicionHoy([DateTime? referencia]) {
    final hoy = formatearFecha(referencia ?? DateTime.now());
    return _prefs.getInt('expedicion/aciertos/$hoy') ?? 3;
  }

  int mejorComboExpedicionHoy([DateTime? referencia]) {
    final hoy = formatearFecha(referencia ?? DateTime.now());
    return _prefs.getInt('expedicion/combo/$hoy') ?? mejorCombo;
  }

  int semillasExpedicionHoy([DateTime? referencia]) {
    final hoy = formatearFecha(referencia ?? DateTime.now());
    return _prefs.getInt('expedicion/semillas/$hoy') ?? 10;
  }

  Future<int> completarExpedicionDiaria({
    DateTime? fecha,
    int semillasRecompensa = 10,
    String? dificultad,
    int? aciertosALaPrimera,
    int? mejorComboSesion,
    int? semillasTotalesSesion,
  }) async {
    final ref = fecha ?? DateTime.now();
    final hoy = formatearFecha(ref);
    final ayer = formatearFecha(DateTime(ref.year, ref.month, ref.day - 1));
    final ultima = ultimaFechaRacha;
    final rachaPrevia = _prefs.getInt(_claveRachaDias) ?? 0;

    int nuevaRacha;
    int premio;
    if (ultima == hoy && rachaPrevia > 0) {
      nuevaRacha = rachaPrevia;
      // Repetir el reto diario el mismo día no entrega semillas extra.
      premio = 0;
    } else if (ultima == ayer && rachaPrevia > 0) {
      nuevaRacha = rachaPrevia + 1;
      premio = semillasRecompensa;
    } else {
      nuevaRacha = 1;
      premio = semillasRecompensa;
    }

    try {
      await _prefs.setInt(_claveRachaDias, nuevaRacha);
      await _prefs.setString(_claveUltimaFechaRacha, hoy);
      if (premio > 0) {
        await _prefs.setInt(_claveSemillas, semillas + premio);
      }
      if (dificultad != null) {
        await _prefs.setString('expedicion/dificultad/$hoy', dificultad);
      }
      if (aciertosALaPrimera != null) {
        await _prefs.setInt('expedicion/aciertos/$hoy', aciertosALaPrimera);
      }
      if (mejorComboSesion != null) {
        await _prefs.setInt('expedicion/combo/$hoy', mejorComboSesion);
      }
      if (semillasTotalesSesion != null) {
        await _prefs.setInt(
          'expedicion/semillas/$hoy',
          semillasTotalesSesion + premio,
        );
      }
      await _marcar('expedicion/$hoy');
    } catch (_) {
      return rachaPrevia;
    }
    notifyListeners();
    return nuevaRacha;
  }

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
