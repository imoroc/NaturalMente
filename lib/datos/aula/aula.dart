import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

enum EstadoAula { sinCargar, cargando, listo, sinConexion }

/// Juegos del profesor por curso, con caché para jugar sin conexión, y la
/// cola de resultados que se envían cuando hay red.
class Aula extends ChangeNotifier {
  Aula({
    required this.repositorio,
    required this.perfiles,
    required this.prefs,
    Random? azar,
  }) : _azar = azar ?? Random.secure();

  /// `null` si la app se compiló sin conexión a la nube.
  final RepositorioAula? repositorio;
  final Perfiles perfiles;
  final SharedPreferences prefs;
  final Random _azar;

  final Map<int, List<JuegoAula>> _juegos = {};
  final Map<int, EstadoAula> _estados = {};
  Future<void>? _envio;

  static const _clavePendientes = 'aula/pendientes';
  static const _claveNube = 'aula/nube';
  static String _claveCache(int curso) => 'aula/cache/$curso';

  bool get disponible => repositorio != null;

  EstadoAula estado(int curso) => _estados[curso] ?? EstadoAula.sinCargar;

  /// Juegos guardados del curso: los últimos que se descargaron.
  List<JuegoAula> juegos(int curso) =>
      _juegos.putIfAbsent(curso, () => _leerCache(curso));

  List<JuegoAula> _leerCache(int curso) {
    try {
      final texto = prefs.getString(_claveCache(curso));
      if (texto == null) return const [];
      return [
        for (final fila in jsonDecode(texto) as List<dynamic>)
          ?JuegoAula.desdeFila(fila as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Descarga los juegos del curso. Sin red se quedan los de la caché.
  Future<void> refrescar(int curso) async {
    final repo = repositorio;
    if (repo == null || estado(curso) == EstadoAula.cargando) return;
    _estados[curso] = EstadoAula.cargando;
    notifyListeners();
    try {
      final nuevos = await repo.juegosDeCurso(curso);
      _juegos[curso] = nuevos;
      _estados[curso] = EstadoAula.listo;
      try {
        await prefs.setString(
          _claveCache(curso),
          jsonEncode([for (final j in nuevos) j.toFila()]),
        );
      } catch (_) {
        // Sin caché solo se pierde poder jugar sin conexión la próxima vez.
      }
    } catch (_) {
      _estados[curso] = EstadoAula.sinConexion;
    }
    notifyListeners();
    unawaited(enviarPendientes());
  }

  /// Identificador único de una partida, para que reenviarla no la duplique.
  String nuevoIdPartida() {
    final aleatorio = List.generate(
      12,
      (_) => _azar.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    return '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}-$aleatorio';
  }

  List<ResultadoAula> pendientes(String perfilId) {
    try {
      final texto = perfiles
          .preferenciasDe(perfilId)
          .getString(_clavePendientes);
      if (texto == null) return const [];
      return [
        for (final r in jsonDecode(texto) as List<dynamic>)
          ResultadoAula.desdeJson(r as Map<String, dynamic>),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<bool> _escribirPendientes(
    String perfilId,
    List<ResultadoAula> lista,
  ) async {
    try {
      return await perfiles
          .preferenciasDe(perfilId)
          .setString(
            _clavePendientes,
            jsonEncode([for (final r in lista) r.toJson()]),
          );
    } catch (_) {
      return false;
    }
  }

  /// Guarda el resultado en el dispositivo y lo deja en la cola de envío.
  /// Devuelve si quedó guardado; el envío se intenta después, sin esperar.
  Future<bool> guardarResultado(String perfilId, ResultadoAula resultado) async {
    final lista = pendientes(perfilId);
    if (lista.any((r) => r.idLocal == resultado.idLocal)) return true;
    final ok = await _escribirPendientes(perfilId, [...lista, resultado]);
    if (ok) {
      notifyListeners();
      unawaited(enviarPendientes());
    }
    return ok;
  }

  PerfilNube? perfilNube(String perfilId) {
    try {
      final texto = perfiles.preferenciasDe(perfilId).getString(_claveNube);
      return texto == null ? null : PerfilNube.desdeJson(jsonDecode(texto));
    } catch (_) {
      return null;
    }
  }

  /// Crea el perfil en la nube la primera vez y, si ya existe, le pone al
  /// día el color, el curso y la ropa de Natu para el ranking.
  Future<PerfilNube> _asegurarPerfilNube(
    RepositorioAula repo,
    Perfil perfil,
  ) async {
    final progreso = perfiles.progresoDe(perfil.id);
    final existente = perfilNube(perfil.id);
    if (existente != null) {
      await repo.actualizarPerfil(
        existente.id,
        perfil,
        curso: progreso.curso,
        traje: progreso.trajeEquipado,
        pose: progreso.poseEquipada,
      );
      return existente;
    }
    final nuevo = await repo.crearPerfil(perfil, curso: progreso.curso);
    final guardado = await perfiles
        .preferenciasDe(perfil.id)
        .setString(_claveNube, jsonEncode(nuevo.toJson()));
    if (!guardado) {
      throw StateError('No se pudo guardar el perfil de la nube.');
    }
    if (progreso.trajeEquipado != 'ninguno' || progreso.poseEquipada != 'hola') {
      await repo.actualizarPerfil(
        nuevo.id,
        perfil,
        curso: progreso.curso,
        traje: progreso.trajeEquipado,
        pose: progreso.poseEquipada,
      );
    }
    notifyListeners();
    return nuevo;
  }

  /// Borra de la nube el perfil y sus resultados antes de borrarlo del
  /// dispositivo. Devuelve `false` si no se pudo (por ejemplo, sin conexión).
  Future<bool> borrarPerfilNube(String perfilId) async {
    final nube = perfilNube(perfilId);
    if (nube == null) return true;
    final repo = repositorio;
    if (repo == null) return false;
    try {
      await repo.borrarPerfil(nube.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Envía lo pendiente de todos los perfiles. Si falla, lo deja para luego.
  Future<void> enviarPendientes() {
    final repo = repositorio;
    if (repo == null) return Future.value();
    return _envio ??= _enviar(repo).whenComplete(() => _envio = null);
  }

  Future<void> _enviar(RepositorioAula repo) async {
    for (final perfil in perfiles.lista) {
      var lista = pendientes(perfil.id);
      if (lista.isEmpty) continue;
      try {
        final nube = await _asegurarPerfilNube(repo, perfil);
        while (lista.isNotEmpty) {
          await repo.enviarResultado(nube.id, lista.first);
          lista = lista.sublist(1);
          if (!await _escribirPendientes(perfil.id, lista)) break;
        }
      } catch (_) {
        // Sin conexión: se reintentará al volver a abrir Aula.
      }
    }
    notifyListeners();
  }

  /// `null` si no se ha podido consultar (sin conexión).
  Future<bool?> rankingActivo() async {
    final repo = repositorio;
    if (repo == null) return false;
    try {
      return await repo.rankingActivo();
    } catch (_) {
      return null;
    }
  }

  Future<List<FilaRanking>> ranking(int curso, {required bool semana}) async {
    final repo = repositorio;
    if (repo == null) return const [];
    // Primero lo pendiente, para que el ranking incluya la última partida.
    await enviarPendientes();
    return repo.ranking(curso, semana: semana);
  }
}

class AulaScope extends InheritedNotifier<Aula> {
  const AulaScope({required Aula aula, required super.child, super.key})
    : super(notifier: aula);

  static Aula? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AulaScope>()?.notifier;
}
