import 'dart:math' as math;

import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

/// Aula en memoria: juegos publicados, perfiles y resultados recibidos.
class RepositorioAulaFalso implements RepositorioAula {
  RepositorioAulaFalso({List<JuegoAula>? juegos})
    : juegos = juegos ?? [juegoDePrueba()],
      recibidos = {},
      perfilesCreados = [],
      perfilesBorrados = [],
      nube = {},
      progresoNube = {},
      semillasNube = {},
      _intentos = [0],
      dispositivo = 'dispositivo-a';

  /// Otro dispositivo que habla con la misma nube en memoria.
  RepositorioAulaFalso.otroDispositivo(
    RepositorioAulaFalso base,
    this.dispositivo,
  ) : juegos = base.juegos,
      recibidos = base.recibidos,
      perfilesCreados = base.perfilesCreados,
      perfilesBorrados = base.perfilesBorrados,
      nube = base.nube,
      progresoNube = base.progresoNube,
      semillasNube = base.semillasNube,
      _intentos = base._intentos;

  final List<JuegoAula> juegos;
  final Map<String, Map<String, ResultadoAula>> recibidos;
  final List<String> perfilesCreados;
  final List<String> perfilesBorrados;
  bool sinConexion = false;
  bool rankingEncendido = true;
  List<FilaRanking> filasRanking = const [];

  void _red() {
    if (sinConexion) throw StateError('Sin conexión');
  }

  @override
  Future<List<JuegoAula>> juegosDeCurso(int curso) async {
    _red();
    return [
      for (final j in juegos)
        if (j.cursos.contains(curso)) j,
    ];
  }

  @override
  Future<PerfilNube> crearPerfil(Perfil perfil, {int? curso}) async {
    _red();
    final id = 'nube-${perfilesCreados.length + 1}';
    perfilesCreados.add(id);
    nube[id] = (perfil, 'zorro-pino-nube-07', curso);
    return PerfilNube(id: id, llave: 'zorro-pino-nube-07');
  }

  @override
  Future<void> actualizarPerfil(
    String perfilNube,
    Perfil perfil, {
    int? curso,
    required String traje,
    required String pose,
  }) async => _red();

  /// Perfiles de la nube: id → (perfil, llave, curso).
  final Map<String, (Perfil, String, int?)> nube;

  /// Progreso fusionado por perfil, como lo guarda `sincronizar_progreso`.
  final Map<String, Map<String, dynamic>> progresoNube;

  /// Semillas por perfil y dispositivo: (ganadas, gastadas).
  final Map<String, Map<String, (int, int)>> semillasNube;

  /// Qué dispositivo llama: sus semillas se cuentan aparte.
  final String dispositivo;
  final List<int> _intentos;

  @override
  Future<PerfilCanjeado?> canjearLlave(
    String animal,
    String adjetivo,
    String llave,
  ) async {
    _red();
    if (_intentos[0] >= 5) throw const LlaveBloqueada();
    for (final MapEntry(key: id, value: (perfil, clave, curso))
        in nube.entries) {
      if (perfil.animal == animal &&
          perfil.adjetivo == adjetivo &&
          clave == llave) {
        return PerfilCanjeado(id: id, perfil: perfil, curso: curso);
      }
    }
    _intentos[0]++;
    return null;
  }

  @override
  Future<String> cambiarLlave(String perfilNube) async {
    _red();
    final (perfil, _, curso) = nube[perfilNube]!;
    const nueva = 'sol-luna-gota-42';
    nube[perfilNube] = (perfil, nueva, curso);
    return nueva;
  }

  @override
  Future<Map<String, dynamic>> sincronizar(
    String perfilNube,
    Map<String, dynamic> local,
  ) async {
    _red();
    final g = progresoNube.putIfAbsent(
      perfilNube,
      () => {'hechos': <String>{}, 'mejorCombo': 0, 'equipados': <String>[]},
    );
    (g['hechos'] as Set<String>).addAll(
      (local['hechos'] as List? ?? const []).cast<String>(),
    );
    final combo = local['mejorCombo'] as int? ?? 0;
    if (combo > (g['mejorCombo'] as int)) g['mejorCombo'] = combo;
    final racha = local['racha'] as Map?;
    final ultima = racha?['ultima'] as String?;
    final guardada = g['racha'] as Map?;
    if (ultima != null &&
        (guardada == null ||
            ultima.compareTo(guardada['ultima'] as String) >= 0)) {
      g['racha'] = {'dias': racha!['dias'], 'ultima': ultima};
    }
    if (local.containsKey('equipados')) g['equipados'] = local['equipados'];
    if (local.containsKey('pose')) g['pose'] = local['pose'];
    if (local.containsKey('curso')) {
      final (perfil, llave, _) = nube[perfilNube]!;
      nube[perfilNube] = (perfil, llave, int.parse(local['curso'] as String));
    }
    final porDispositivo = semillasNube.putIfAbsent(perfilNube, () => {});
    final (ganadasAntes, gastadasAntes) = porDispositivo[dispositivo] ?? (0, 0);
    porDispositivo[dispositivo] = (
      math.max(ganadasAntes, local['ganadas'] as int? ?? 0),
      math.max(gastadasAntes, local['gastadas'] as int? ?? 0),
    );
    return {
      'hechos': (g['hechos'] as Set<String>).toList(),
      'semillas': porDispositivo.values.fold<int>(0, (t, s) => t + s.$1 - s.$2),
      'mejorCombo': g['mejorCombo'],
      'racha': g['racha'] ?? {'dias': 0, 'ultima': null},
      'equipados': g['equipados'],
      'pose': g['pose'],
      'curso': nube[perfilNube]!.$3,
    };
  }

  @override
  Future<void> borrarPerfil(String perfilNube) async {
    _red();
    perfilesBorrados.add(perfilNube);
    recibidos.remove(perfilNube);
  }

  @override
  Future<void> enviarResultado(
    String perfilNube,
    ResultadoAula resultado,
  ) async {
    _red();
    (recibidos[perfilNube] ??= {})[resultado.idLocal] = resultado;
  }

  int get totalRecibidos =>
      recibidos.values.fold(0, (total, porPerfil) => total + porPerfil.length);

  @override
  Future<bool> rankingActivo() async {
    _red();
    return rankingEncendido;
  }

  @override
  Future<List<FilaRanking>> ranking(int curso, {required bool semana}) async {
    _red();
    return filasRanking;
  }
}

/// Test de tres preguntas para 3º: la primera con pista y explicación.
JuegoAula juegoDePrueba({
  String id = 'juego-1',
  String titulo = 'Animales vertebrados',
  List<int> cursos = const [3],
  int version = 1,
  PlantillaAula plantilla = PlantillaAula.opcionMultiple,
}) => JuegoAula.desdeFila({
  'id': id,
  'titulo': titulo,
  'plantilla': plantilla.id,
  'version': version,
  'cursos': cursos,
  'contenido': plantilla == PlantillaAula.verdaderoFalso
      ? {
          'preguntas': [
            {'enunciado': 'La ballena es un mamífero.', 'correcta': true},
            {'enunciado': 'Las plantas comen carne.', 'correcta': false},
          ],
        }
      : {
          'intro': '¡Vamos a repasar los vertebrados!',
          'preguntas': [
            {
              'enunciado': '¿Cuál de estos animales es un mamífero?',
              'opciones': [
                {'texto': 'Delfín'},
                {'texto': 'Tiburón'},
                {'texto': 'Pulpo'},
              ],
              'correcta': 0,
              'pista': 'Piensa en cuál respira por pulmones.',
              'explicacion': 'El delfín respira aire y amamanta a sus crías.',
            },
            {
              'enunciado': '¿Qué animal tiene plumas?',
              'opciones': [
                {'texto': 'Gato'},
                {'texto': 'Gorrión'},
              ],
              'correcta': 1,
            },
            {
              'enunciado': '¿Cuál es un reptil?',
              'opciones': [
                {'texto': 'Lagarto'},
                {'texto': 'Rana'},
                {'texto': 'Trucha'},
                {'texto': 'Murciélago'},
              ],
              'correcta': 0,
            },
          ],
        },
  'tema': {
    'fondo': {'galeria': 'paisaje-reserva'},
    'natu': true,
  },
})!;
