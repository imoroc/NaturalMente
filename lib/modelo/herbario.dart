import 'package:naturalmente/modelo/actividad.dart';

class PreguntaFuncion {
  const PreguntaFuncion({
    required this.enunciado,
    required this.opciones,
    required this.respuesta,
    required this.frases,
  });

  final String enunciado;
  final List<Opcion> opciones;
  final String respuesta;
  final Map<String, String> frases;

  factory PreguntaFuncion.desdeMapa(Map<String, dynamic> mapa) {
    return PreguntaFuncion(
      enunciado: mapa['enunciado'] as String,
      opciones: (mapa['opciones'] as List)
          .cast<Map<String, dynamic>>()
          .map(Opcion.desdeMapa)
          .toList(),
      respuesta: mapa['respuesta'] as String,
      frases: Map<String, String>.from(mapa['frases'] as Map),
    );
  }
}

class PartePlanta {
  const PartePlanta({
    required this.reto,
    required this.funcion,
    required this.curiosidad,
    required this.pregunta,
  });

  final Reto reto;
  final String funcion;
  final String curiosidad;
  final PreguntaFuncion pregunta;

  String get id => reto.id;
  String get nombre => reto.nombre;

  factory PartePlanta.desdeMapa(Map<String, dynamic> mapa) {
    return PartePlanta(
      reto: Reto.desdeMapa(mapa['reto'] as Map<String, dynamic>),
      funcion: mapa['funcion'] as String,
      curiosidad: mapa['curiosidad'] as String,
      pregunta: PreguntaFuncion.desdeMapa(
        mapa['preguntaFuncion'] as Map<String, dynamic>,
      ),
    );
  }
}

class NivelHerbario {
  const NivelHerbario({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.partes,
    required this.preguntaFunciones,
  });

  final String id;
  final String nombre;
  final String curso;
  final List<String> partes;
  final bool preguntaFunciones;

  factory NivelHerbario.desdeMapa(Map<String, dynamic> mapa) {
    return NivelHerbario(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      curso: mapa['curso'] as String,
      partes: (mapa['partes'] as List).cast<String>(),
      preguntaFunciones: mapa['preguntaFunciones'] as bool,
    );
  }
}

class Herbario {
  Herbario({required this.partes, required this.niveles}) {
    _comprobar();
  }

  final List<PartePlanta> partes;
  final List<NivelHerbario> niveles;

  PartePlanta parte(String id) => partes.firstWhere((parte) => parte.id == id);

  factory Herbario.desdeMapa(Map<String, dynamic> mapa) {
    return Herbario(
      partes: (mapa['partes'] as List)
          .cast<Map<String, dynamic>>()
          .map(PartePlanta.desdeMapa)
          .toList(),
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelHerbario.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    const destinos = {'raiz', 'tallo', 'hoja', 'flor', 'fruto'};
    final ids = partes.map((parte) => parte.id).toSet();
    if (ids.length != partes.length ||
        ids.length != destinos.length ||
        !ids.containsAll(destinos)) {
      throw ArgumentError('El herbario necesita las cinco partes sin repetir.');
    }
    for (final parte in partes) {
      final reto = parte.reto;
      if (reto.nombre.isEmpty ||
          reto.pregunta.isEmpty ||
          reto.pista.isEmpty ||
          reto.respuesta != parte.id ||
          !destinos.every((id) => reto.frases[id]?.isNotEmpty == true) ||
          parte.funcion.isEmpty ||
          parte.curiosidad.isEmpty) {
        throw ArgumentError('La parte ${parte.id} está incompleta.');
      }
      final pregunta = parte.pregunta;
      final opciones = pregunta.opciones.map((opcion) => opcion.id).toSet();
      if (pregunta.enunciado.isEmpty ||
          opciones.length != 3 ||
          opciones.length != pregunta.opciones.length ||
          pregunta.opciones.any((opcion) => opcion.nombre.isEmpty) ||
          !opciones.contains(pregunta.respuesta) ||
          !opciones.every((id) => pregunta.frases[id]?.isNotEmpty == true)) {
        throw ArgumentError('La pregunta de ${parte.id} está incompleta.');
      }
    }
    const esperados = {'facil', 'medio', 'dificil'};
    final nivelesIds = niveles.map((nivel) => nivel.id).toSet();
    if (niveles.length != 3 || !nivelesIds.containsAll(esperados)) {
      throw ArgumentError('El herbario necesita Fácil, Medio y Difícil.');
    }
    for (final nivel in niveles) {
      final referencias = nivel.partes.toSet();
      final necesarias = nivel.id == 'facil'
          ? const {'raiz', 'tallo', 'hoja'}
          : destinos;
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          referencias.length != nivel.partes.length ||
          referencias.length != necesarias.length ||
          !referencias.containsAll(necesarias) ||
          nivel.preguntaFunciones != (nivel.id == 'dificil')) {
        throw ArgumentError(
          'El nivel ${nivel.id} tiene una configuración inválida.',
        );
      }
    }
  }
}
