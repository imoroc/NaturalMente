import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

/// Aula en memoria: juegos publicados, perfiles y resultados recibidos.
class RepositorioAulaFalso implements RepositorioAula {
  RepositorioAulaFalso({List<JuegoAula>? juegos})
    : juegos = juegos ?? [juegoDePrueba()];

  final List<JuegoAula> juegos;
  final Map<String, Map<String, ResultadoAula>> recibidos = {};
  final List<String> perfilesCreados = [];
  final List<String> perfilesBorrados = [];
  bool sinConexion = false;
  bool rankingEncendido = true;
  List<FilaRanking> filasRanking = const [];

  void _red() {
    if (sinConexion) throw StateError('Sin conexión');
  }

  @override
  Future<List<JuegoAula>> juegosDeCurso(int curso) async {
    _red();
    return [for (final j in juegos) if (j.cursos.contains(curso)) j];
  }

  @override
  Future<PerfilNube> crearPerfil(Perfil perfil, {int? curso}) async {
    _red();
    final id = 'nube-${perfilesCreados.length + 1}';
    perfilesCreados.add(id);
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

  @override
  Future<void> borrarPerfil(String perfilNube) async {
    _red();
    perfilesBorrados.add(perfilNube);
    recibidos.remove(perfilNube);
  }

  @override
  Future<void> enviarResultado(String perfilNube, ResultadoAula resultado) async {
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
