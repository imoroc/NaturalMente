import 'package:naturalmente/modelo/herbario.dart';
import 'package:naturalmente/reglas/resolver.dart';

Resultado resolverFuncion({
  required PartePlanta parte,
  required String eleccion,
}) {
  final pregunta = parte.pregunta;
  final frase = pregunta.frases[eleccion];
  if (frase == null) {
    throw ArgumentError('Esa opción no existe en la pregunta de ${parte.id}.');
  }
  return Resultado(
    acierto: eleccion == pregunta.respuesta,
    frase: frase,
    estado: eleccion,
    gesto: eleccion == pregunta.respuesta ? 'feliz' : 'pensando',
  );
}

// Estado de una partida; no depende de widgets ni del almacenamiento.
class PartidaHerbario {
  PartidaHerbario({required this.herbario, required this.nivel});

  final Herbario herbario;
  final NivelHerbario nivel;
  final Set<String> _colocadas = {};
  final Set<String> _funciones = {};
  final Map<String, int> _intentos = {};
  String? seleccionada;
  Resultado? resultado;
  String? ultimoDestino;
  bool falloColocacion = false;

  Set<String> get colocadas => Set.unmodifiable(_colocadas);
  int get funcionesAcertadas => _funciones.length;
  double get progreso =>
      (_colocadas.length + (nivel.preguntaFunciones ? _funciones.length : 0)) /
      (nivel.partes.length * (nivel.preguntaFunciones ? 2 : 1));
  bool get colocacionTerminada => nivel.partes.every(_colocadas.contains);
  bool get completa =>
      colocacionTerminada &&
      (!nivel.preguntaFunciones || nivel.partes.every(_funciones.contains));

  String? get preguntaActual {
    if (!colocacionTerminada || !nivel.preguntaFunciones || completa) {
      return null;
    }
    return nivel.partes.firstWhere((id) => !_funciones.contains(id));
  }

  bool puedeConsultar(String id) =>
      _colocadas.contains(id) &&
      (!nivel.preguntaFunciones || _funciones.contains(id));

  void seleccionar(String id) {
    if (!nivel.partes.contains(id) || _colocadas.contains(id)) return;
    seleccionada = id;
    resultado = null;
    ultimoDestino = null;
    falloColocacion = false;
  }

  void colocar(String pieza, String destino) {
    if (!nivel.partes.contains(pieza) ||
        !nivel.partes.contains(destino) ||
        _colocadas.contains(pieza)) {
      return;
    }
    final intento = (_intentos[pieza] ?? 0) + 1;
    ultimoDestino = destino;
    resultado = resolverLugar(
      reto: herbario.parte(pieza).reto,
      eleccion: destino,
      intento: intento,
    );
    falloColocacion = !resultado!.acierto;
    if (resultado!.acierto) {
      _colocadas.add(pieza);
      seleccionada = null;
      if (nivel.preguntaFunciones) {
        // No adelantar la función que se preguntará después.
        resultado = const Resultado(
          acierto: true,
          frase:
              'La pieza está en su sitio. Al terminar veremos para qué sirve.',
          estado: 'colocada',
          gesto: 'feliz',
        );
      }
    } else {
      _intentos[pieza] = intento;
      seleccionada = pieza;
    }
  }

  void responder(String eleccion) {
    final id = preguntaActual;
    if (id == null) return;
    ultimoDestino = null;
    falloColocacion = false;
    resultado = resolverFuncion(parte: herbario.parte(id), eleccion: eleccion);
    if (resultado!.acierto) _funciones.add(id);
  }
}
