import 'package:naturalmente/modelo/actividad.dart';

// Datos de «¿Huevo o barriga?». En Fácil se separan animales según cómo
// nacen; en Medio y Difícil se ordenan ciclos de vida con su pregunta.

class CicloVida {
  const CicloVida({
    required this.id,
    required this.nombre,
    required this.intro,
    required this.pista,
    required this.curiosidad,
    required this.pasos,
    required this.respuesta,
    required this.frases,
    required this.pregunta,
  });

  final String id;
  final String nombre;
  final String intro;
  final String pista;
  final String curiosidad;
  final List<Opcion> pasos;
  final List<String> respuesta;
  final Map<String, String> frases;
  final PreguntaExtra pregunta;

  Opcion paso(String id) => pasos.firstWhere((paso) => paso.id == id);

  factory CicloVida.desdeMapa(Map<String, dynamic> mapa) {
    return CicloVida(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      intro: mapa['intro'] as String? ?? '',
      pista: mapa['pista'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      pasos: (mapa['pasos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Opcion.desdeMapa)
          .toList(),
      respuesta: (mapa['respuesta'] as List? ?? []).cast<String>(),
      frases: Map<String, String>.from(mapa['frases'] as Map? ?? const {}),
      pregunta: PreguntaExtra.desdeMapa(
        mapa['pregunta'] as Map<String, dynamic>,
      ),
    );
  }
}

class NivelNacimiento {
  const NivelNacimiento({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    this.animales = const [],
    this.ciclos = const [],
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final List<String> animales;
  final List<CicloVida> ciclos;

  bool get ordenaCiclos => ciclos.isNotEmpty;

  factory NivelNacimiento.desdeMapa(Map<String, dynamic> mapa) {
    return NivelNacimiento(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      curso: mapa['curso'] as String,
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      animales: (mapa['animales'] as List? ?? []).cast<String>(),
      ciclos: (mapa['ciclos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CicloVida.desdeMapa)
          .toList(),
    );
  }
}

class Nacimiento {
  Nacimiento({
    required this.nidos,
    required this.animales,
    required this.niveles,
  }) {
    _comprobar();
  }

  final List<Opcion> nidos;
  final List<Reto> animales;
  final List<NivelNacimiento> niveles;

  Reto animal(String id) => animales.firstWhere((animal) => animal.id == id);

  Opcion nido(String id) => nidos.firstWhere((nido) => nido.id == id);

  factory Nacimiento.desdeMapa(Map<String, dynamic> mapa) {
    return Nacimiento(
      nidos: (mapa['nidos'] as List)
          .cast<Map<String, dynamic>>()
          .map(Opcion.desdeMapa)
          .toList(),
      animales: (mapa['animales'] as List)
          .cast<Map<String, dynamic>>()
          .map(Reto.desdeMapa)
          .toList(),
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelNacimiento.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    const destinos = {'huevo', 'barriga'};
    final idsNidos = nidos.map((nido) => nido.id).toSet();
    if (idsNidos.length != nidos.length ||
        !idsNidos.containsAll(destinos) ||
        idsNidos.length != destinos.length ||
        nidos.any((nido) => nido.nombre.isEmpty)) {
      throw ArgumentError(
        '¿Huevo o barriga? necesita los nidos huevo y barriga.',
      );
    }
    final idsAnimales = animales.map((animal) => animal.id).toSet();
    if (idsAnimales.length != animales.length) {
      throw ArgumentError('Hay animales repetidos en ¿Huevo o barriga?.');
    }
    for (final animal in animales) {
      if (animal.nombre.isEmpty ||
          animal.pregunta.isEmpty ||
          animal.pista.isEmpty ||
          animal.curiosidad.isEmpty ||
          !destinos.contains(animal.respuesta) ||
          !destinos.every((id) => animal.frases[id]?.isNotEmpty == true)) {
        throw ArgumentError('El animal ${animal.id} está incompleto.');
      }
    }
    const esperados = ['facil', 'medio', 'dificil'];
    if (niveles.map((nivel) => nivel.id).toList().join(',') !=
        esperados.join(',')) {
      throw ArgumentError('¿Huevo o barriga? necesita Fácil, Medio y Difícil.');
    }
    for (final nivel in niveles) {
      if (nivel.nombre.isEmpty || nivel.curso.isEmpty || nivel.intro.isEmpty) {
        throw ArgumentError('Al nivel ${nivel.id} le faltan textos.');
      }
      if (nivel.id == 'facil') {
        _comprobarClasificacion(nivel, idsAnimales);
      } else {
        _comprobarCiclos(nivel);
      }
    }
  }

  void _comprobarClasificacion(NivelNacimiento nivel, Set<String> idsAnimales) {
    final referencias = nivel.animales.toSet();
    if (nivel.ciclos.isNotEmpty ||
        referencias.length != nivel.animales.length ||
        referencias.length < 4 ||
        !idsAnimales.containsAll(referencias)) {
      throw ArgumentError('El nivel ${nivel.id} tiene animales inválidos.');
    }
    final respuestas = referencias.map((id) => animal(id).respuesta).toSet();
    if (respuestas.length != 2) {
      throw ArgumentError(
        'El nivel ${nivel.id} necesita animales de huevo y de barriga.',
      );
    }
  }

  void _comprobarCiclos(NivelNacimiento nivel) {
    if (nivel.animales.isNotEmpty || nivel.ciclos.isEmpty) {
      throw ArgumentError('El nivel ${nivel.id} necesita ciclos de vida.');
    }
    final idsCiclos = nivel.ciclos.map((ciclo) => ciclo.id).toSet();
    if (idsCiclos.length != nivel.ciclos.length) {
      throw ArgumentError('El nivel ${nivel.id} repite un ciclo.');
    }
    for (final ciclo in nivel.ciclos) {
      final pasos = ciclo.pasos.map((paso) => paso.id).toSet();
      if (ciclo.nombre.isEmpty ||
          ciclo.intro.isEmpty ||
          ciclo.pista.isEmpty ||
          ciclo.curiosidad.isEmpty ||
          pasos.length < 3 ||
          pasos.length != ciclo.pasos.length ||
          ciclo.pasos.any((paso) => paso.nombre.isEmpty) ||
          ciclo.respuesta.length != pasos.length ||
          ciclo.respuesta.toSet().length != pasos.length ||
          !pasos.containsAll(ciclo.respuesta)) {
        throw ArgumentError('El ciclo ${ciclo.id} está incompleto.');
      }
      for (final clave in [
        'incompleto',
        'bien',
        for (var i = 0; i < ciclo.respuesta.length - 1; i++) 'mal$i',
      ]) {
        if (ciclo.frases[clave]?.isNotEmpty != true) {
          throw ArgumentError('Al ciclo ${ciclo.id} le falta la frase $clave.');
        }
      }
      ciclo.pregunta.comprobar(ciclo.id);
    }
  }
}
