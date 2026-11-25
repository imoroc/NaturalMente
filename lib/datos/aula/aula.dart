import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:naturalmente/datos/aula/llave.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

enum EstadoAula { sinCargar, cargando, listo, sinConexion }

enum ResultadoCanje { recuperado, noCoincide, bloqueado, sinConexion, lleno }

/// Juegos del profesor por curso, con caché para jugar sin conexión, y la
/// cola de resultados que se envían cuando hay red.
class Aula extends ChangeNotifier {
  Aula({
    required this.repositorio,
    required this.perfiles,
    required this.prefs,
    this.precargarImagen,
    Random? azar,
  }) : _azar = azar ?? Random.secure();

  /// Descarga una foto del profe para tenerla sin conexión.
  final Future<void> Function(String url)? precargarImagen;

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
      unawaited(_precargar(nuevos));
    } catch (_) {
      _estados[curso] = EstadoAula.sinConexion;
    }
    notifyListeners();
    unawaited(enviarPendientes());
  }

  /// Deja guardadas en el dispositivo las fotos de los juegos, para que se
  /// vean aunque luego se juegue sin conexión. Si falla, se cargan al jugar.
  Future<void> _precargar(List<JuegoAula> juegos) async {
    final precargar = precargarImagen;
    if (precargar == null) return;
    final urls = <String>{
      for (final j in juegos) ...[
        if (j.fondo case ImagenSubida(:final url)) url,
        for (final p in j.preguntas) ...[
          if (p.imagen case ImagenSubida(:final url)) url,
          for (final o in p.opciones)
            if (o.imagen case ImagenSubida(:final url)) url,
        ],
      ],
    };
    for (final url in urls) {
      try {
        await precargar(url);
      } catch (_) {}
    }
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
  Future<bool> guardarResultado(
    String perfilId,
    ResultadoAula resultado,
  ) async {
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
    if (progreso.trajeEquipado != 'ninguno' ||
        progreso.poseEquipada != 'hola') {
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

  // --- Llave mágica y progreso en varios dispositivos -----------------------

  static const _claveBaseSemillas = 'sync/base-semillas';
  static const _claveGanadas = 'sync/ganadas';
  static const _claveGastadas = 'sync/gastadas';
  static const _claveUltimo = 'sync/ultimo';

  /// Crea la llave del perfil (y su copia en la nube) y sube su progreso.
  Future<PerfilNube?> crearLlave(String perfilId) async {
    final repo = repositorio;
    final perfil = perfiles.lista.where((p) => p.id == perfilId).firstOrNull;
    if (repo == null || perfil == null) return null;
    try {
      final nube = await _asegurarPerfilNube(repo, perfil);
      await sincronizar(perfilId);
      return nube;
    } catch (_) {
      return null;
    }
  }

  /// Llave nueva para el perfil: los demás dispositivos lo pierden.
  Future<PerfilNube?> cambiarLlave(String perfilId) async {
    final repo = repositorio;
    final actual = perfilNube(perfilId);
    if (repo == null || actual == null) return null;
    try {
      final llave = await repo.cambiarLlave(actual.id);
      final nuevo = PerfilNube(id: actual.id, llave: llave);
      await perfiles
          .preferenciasDe(perfilId)
          .setString(_claveNube, jsonEncode(nuevo.toJson()));
      notifyListeners();
      return nuevo;
    } catch (_) {
      return null;
    }
  }

  /// Busca el perfil del mote y la llave, lo trae a este dispositivo con su
  /// progreso y lo deja jugando.
  Future<ResultadoCanje> canjearLlave(
    String animal,
    String adjetivo,
    Llave llave,
  ) async {
    final repo = repositorio;
    if (repo == null) return ResultadoCanje.sinConexion;
    final PerfilCanjeado? encontrado;
    try {
      encontrado = await repo.canjearLlave(animal, adjetivo, llave.texto);
    } on LlaveBloqueada {
      return ResultadoCanje.bloqueado;
    } catch (_) {
      return ResultadoCanje.sinConexion;
    }
    if (encontrado == null) return ResultadoCanje.noCoincide;

    // Si ya estaba en este dispositivo, solo se cambia a él.
    final yaEsta = perfiles.lista
        .where((p) => perfilNube(p.id)?.id == encontrado!.id)
        .firstOrNull;
    if (yaEsta != null) {
      await sincronizar(yaEsta.id);
      await perfiles.elegir(yaEsta.id);
      return ResultadoCanje.recuperado;
    }
    if (perfiles.lleno) return ResultadoCanje.lleno;
    final local = await perfiles.crearDesdeNube(
      encontrado.perfil,
      curso: encontrado.curso,
    );
    if (local == null) return ResultadoCanje.sinConexion;
    await perfiles
        .preferenciasDe(local.id)
        .setString(
          _claveNube,
          jsonEncode(
            PerfilNube(id: encontrado.id, llave: llave.texto).toJson(),
          ),
        );
    await sincronizar(local.id);
    await perfiles.elegir(local.id);
    return ResultadoCanje.recuperado;
  }

  /// Junta el progreso de este dispositivo con el de la nube.
  ///
  /// Las semillas se cuentan por dispositivo: lo ganado o gastado aquí desde
  /// la última vez se suma a sus totales, que solo crecen. Si falla, se
  /// reintenta otro día sin contar nada dos veces.
  Future<bool> sincronizar(String perfilId) async {
    final repo = repositorio;
    final nube = perfilNube(perfilId);
    if (repo == null || nube == null) return false;
    final prefsPerfil = perfiles.preferenciasDe(perfilId);
    final progreso = perfiles.progresoDe(perfilId);

    final saldo = progreso.semillas;
    final diferencia = saldo - (prefsPerfil.getInt(_claveBaseSemillas) ?? 0);
    final ganadas =
        (prefsPerfil.getInt(_claveGanadas) ?? 0) +
        (diferencia > 0 ? diferencia : 0);
    final gastadas =
        (prefsPerfil.getInt(_claveGastadas) ?? 0) +
        (diferencia < 0 ? -diferencia : 0);
    final equipados = progreso.trajesEquipados.toList()..sort();
    final ultimo = _leerUltimo(prefsPerfil);
    final local = <String, dynamic>{
      'hechos': progreso.hechos.toList(),
      'ganadas': ganadas,
      'gastadas': gastadas,
      'mejorCombo': progreso.mejorCombo,
      'racha': {
        'dias': prefsPerfil.getInt('racha/dias') ?? 0,
        'ultima': prefsPerfil.getString('racha/ultima-fecha'),
      },
      // Solo se mandan si han cambiado aquí: así no se pisa lo elegido en
      // otro dispositivo.
      if (!listEquals(equipados, ultimo['equipados'])) 'equipados': equipados,
      if (progreso.poseEquipada != ultimo['pose'])
        'pose': progreso.poseEquipada,
      if (progreso.curso != null && progreso.curso != ultimo['curso'])
        'curso': '${progreso.curso}',
    };

    final Map<String, dynamic> respuesta;
    try {
      respuesta = await repo.sincronizar(nube.id, local);
    } catch (_) {
      return false;
    }

    final racha = respuesta['racha'] as Map?;
    final equipadosNube = [
      for (final e in (respuesta['equipados'] as List?) ?? const [])
        e as String,
    ]..sort();
    final aplicado = await progreso.aplicarSincronizacion(
      hechosNube: {
        for (final h in (respuesta['hechos'] as List?) ?? const []) h as String,
      },
      semillasNube: (respuesta['semillas'] as num).toInt(),
      semillasEnviadas: saldo,
      mejorComboNube: (respuesta['mejorCombo'] as num?)?.toInt() ?? 0,
      rachaDias: (racha?['dias'] as num?)?.toInt(),
      rachaUltima: racha?['ultima'] as String?,
      equipados: equipadosNube,
      pose: respuesta['pose'] as String?,
      curso: (respuesta['curso'] as num?)?.toInt(),
    );
    if (!aplicado) return false;
    try {
      await prefsPerfil.setInt(
        _claveBaseSemillas,
        (respuesta['semillas'] as num).toInt(),
      );
      await prefsPerfil.setInt(_claveGanadas, ganadas);
      await prefsPerfil.setInt(_claveGastadas, gastadas);
      await prefsPerfil.setString(
        _claveUltimo,
        jsonEncode({
          'equipados': equipadosNube,
          'pose': respuesta['pose'],
          'curso': respuesta['curso'],
        }),
      );
    } catch (_) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Map<String, dynamic> _leerUltimo(SharedPreferences prefsPerfil) {
    try {
      final texto = prefsPerfil.getString(_claveUltimo);
      if (texto == null) return const {};
      final datos = jsonDecode(texto) as Map<String, dynamic>;
      return {
        ...datos,
        'equipados': [
          for (final e in (datos['equipados'] as List?) ?? const [])
            e as String,
        ],
      };
    } catch (_) {
      return const {};
    }
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
