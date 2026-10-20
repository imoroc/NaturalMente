import 'package:naturalmente/modelo/nacimiento.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Comprueba un ciclo de vida. La primera vez explica el primer paso que no
/// encaja; a partir de la segunda añade la pista del ciclo.
Resultado resolverCiclo({
  required CicloVida ciclo,
  required List<String?> orden,
  required int intento,
}) {
  final colocados = orden.whereType<String>().toList();
  final completo =
      orden.length == ciclo.respuesta.length &&
      colocados.length == ciclo.respuesta.length &&
      colocados.toSet().length == colocados.length &&
      colocados.toSet().containsAll(ciclo.respuesta);
  if (!completo) {
    return Resultado(
      acierto: false,
      frase: ciclo.frases['incompleto']!,
      estado: 'incompleto',
      gesto: 'pensando',
    );
  }
  for (var i = 0; i < ciclo.respuesta.length; i++) {
    if (orden[i] != ciclo.respuesta[i]) {
      final frase = ciclo.frases['mal$i']!;
      return Resultado(
        acierto: false,
        frase: intento >= 2 ? '$frase ${ciclo.pista}' : frase,
        estado: 'mal$i',
        gesto: intento >= 2 ? 'pista' : 'pensando',
      );
    }
  }
  return Resultado(
    acierto: true,
    frase: ciclo.frases['bien']!,
    estado: 'bien',
    gesto: 'feliz',
  );
}

/// Fácil: llevar cada animal al huevo o a la barriga de su madre.
class PartidaClasificar {
  PartidaClasificar({required this.nacimiento, required this.nivel});

  final Nacimiento nacimiento;
  final NivelNacimiento nivel;
  final Map<String, String> _colocados = {};
  final Map<String, int> _intentos = {};
  String? seleccionado;
  Resultado? resultado;
  String? ultimoNido;
  bool falloColocacion = false;

  Map<String, String> get colocados => Map.unmodifiable(_colocados);
  double get progreso => _colocados.length / nivel.animales.length;
  bool get completa => nivel.animales.every(_colocados.containsKey);

  List<String> enNido(String nido) => [
    for (final id in nivel.animales)
      if (_colocados[id] == nido) id,
  ];

  void seleccionar(String id) {
    if (!nivel.animales.contains(id) || _colocados.containsKey(id)) return;
    seleccionado = id;
    resultado = null;
    ultimoNido = null;
    falloColocacion = false;
  }

  void colocar(String animal, String nido) {
    if (!nivel.animales.contains(animal) ||
        _colocados.containsKey(animal) ||
        !nacimiento.nidos.any((n) => n.id == nido)) {
      return;
    }
    final intento = (_intentos[animal] ?? 0) + 1;
    ultimoNido = nido;
    resultado = resolverLugar(
      reto: nacimiento.animal(animal),
      eleccion: nido,
      intento: intento,
    );
    falloColocacion = !resultado!.acierto;
    if (resultado!.acierto) {
      _colocados[animal] = nido;
      seleccionado = null;
    } else {
      _intentos[animal] = intento;
      seleccionado = animal;
    }
  }
}

/// Medio y Difícil: ordenar cada ciclo de vida y responder su pregunta.
class PartidaCiclos {
  PartidaCiclos({required this.nivel})
    : _orden = List<String?>.filled(nivel.ciclos.first.pasos.length, null);

  final NivelNacimiento nivel;
  var _indice = 0;
  List<String?> _orden;
  var _intentos = 0;
  Resultado? resultado;
  int? primerFallo;
  bool cicloOrdenado = false;
  bool preguntaAcertada = false;
  String? preguntaElegida;

  int get indice => _indice;
  CicloVida get ciclo => nivel.ciclos[_indice];
  List<String?> get orden => List.unmodifiable(_orden);
  int get colocados => _orden.whereType<String>().length;
  bool get cicloTerminado => cicloOrdenado && preguntaAcertada;
  bool get hayOtroCiclo => _indice < nivel.ciclos.length - 1;
  bool get completa => cicloTerminado && !hayOtroCiclo;

  double get progreso {
    // Cada ciclo pesa lo mismo: la mitad al ordenarlo, la otra al responder.
    final hechoCiclo = cicloOrdenado
        ? (preguntaAcertada ? 1.0 : .5)
        : .5 * colocados / _orden.length;
    return (_indice + hechoCiclo) / nivel.ciclos.length;
  }

  bool estaColocado(String paso) => _orden.contains(paso);

  /// Pone el paso en el primer hueco libre.
  void anadir(String paso) {
    final libre = _orden.indexOf(null);
    if (libre >= 0) colocarEn(paso, libre);
  }

  /// Pone el paso en un hueco concreto; si estaba en otro, lo mueve.
  void colocarEn(String paso, int hueco) {
    if (cicloOrdenado ||
        hueco < 0 ||
        hueco >= _orden.length ||
        !ciclo.pasos.any((p) => p.id == paso)) {
      return;
    }
    final anterior = _orden.indexOf(paso);
    if (anterior >= 0) _orden[anterior] = _orden[hueco];
    _orden[hueco] = paso;
    _limpiarAviso();
  }

  void quitar(int hueco) {
    if (cicloOrdenado || hueco < 0 || hueco >= _orden.length) return;
    _orden[hueco] = null;
    _limpiarAviso();
  }

  void comprobar() {
    if (cicloOrdenado) return;
    final completo = !_orden.contains(null);
    if (completo) _intentos += 1;
    resultado = resolverCiclo(ciclo: ciclo, orden: _orden, intento: _intentos);
    final estado = resultado!.estado;
    primerFallo = estado.startsWith('mal')
        ? int.parse(estado.substring(3))
        : null;
    cicloOrdenado = resultado!.acierto;
  }

  void responder(String eleccion) {
    if (!cicloOrdenado || preguntaAcertada) return;
    preguntaElegida = eleccion;
    resultado = resolverPreguntaExtra(
      pregunta: ciclo.pregunta,
      eleccion: eleccion,
    );
    preguntaAcertada = resultado!.acierto;
  }

  void siguiente() {
    if (!cicloTerminado || !hayOtroCiclo) return;
    _indice += 1;
    _orden = List<String?>.filled(ciclo.pasos.length, null);
    _intentos = 0;
    resultado = null;
    primerFallo = null;
    cicloOrdenado = false;
    preguntaAcertada = false;
    preguntaElegida = null;
  }

  void _limpiarAviso() {
    resultado = null;
    primerFallo = null;
  }
}
