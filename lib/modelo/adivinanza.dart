// Datos de «¿Quién soy?»: un animal da pistas de una en una y hay que
// adivinarlo entre varios con las menos pistas posibles.

class AnimalAdivinanza {
  const AnimalAdivinanza({
    required this.id,
    required this.nombre,
    required this.conArticulo,
    required this.dibujo,
  });

  final String id;
  final String nombre;

  /// El nombre con su artículo, para frases como «No soy el conejo».
  final String conArticulo;
  final String dibujo;

  factory AnimalAdivinanza.desdeMapa(Map<String, dynamic> mapa) {
    return AnimalAdivinanza(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      conArticulo: mapa['conArticulo'] as String? ?? '',
      dibujo: mapa['dibujo'] as String? ?? '',
    );
  }
}

class RondaAdivinanza {
  const RondaAdivinanza({
    required this.id,
    required this.respuesta,
    required this.pistas,
    required this.opciones,
    required this.frase,
  });

  final String id;
  final String respuesta;
  final List<String> pistas;
  final List<String> opciones;

  /// Lo que explica Natu al acertar.
  final String frase;

  factory RondaAdivinanza.desdeMapa(Map<String, dynamic> mapa) {
    return RondaAdivinanza(
      id: mapa['id'] as String,
      respuesta: mapa['respuesta'] as String? ?? '',
      pistas: (mapa['pistas'] as List? ?? []).cast<String>(),
      opciones: (mapa['candidatos'] as List? ?? []).cast<String>(),
      frase: mapa['frase'] as String? ?? '',
    );
  }
}

class NivelAdivinanza {
  const NivelAdivinanza({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    required this.rondas,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;
  final List<RondaAdivinanza> rondas;

  factory NivelAdivinanza.desdeMapa(Map<String, dynamic> mapa) {
    return NivelAdivinanza(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      rondas: (mapa['rondas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(RondaAdivinanza.desdeMapa)
          .toList(),
    );
  }
}

class Adivinanza {
  Adivinanza({required this.animales, required this.niveles}) {
    _comprobar();
  }

  final List<AnimalAdivinanza> animales;
  final List<NivelAdivinanza> niveles;

  AnimalAdivinanza animal(String id) => animales.firstWhere((a) => a.id == id);

  factory Adivinanza.desdeMapa(Map<String, dynamic> mapa) {
    return Adivinanza(
      animales: (mapa['animales'] as List)
          .cast<Map<String, dynamic>>()
          .map(AnimalAdivinanza.desdeMapa)
          .toList(),
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelAdivinanza.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('¿Quién soy? necesita Fácil, Medio y Difícil.');
    }
    final ids = {for (final a in animales) a.id};
    for (final nivel in niveles) {
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          nivel.rondas.isEmpty) {
        throw ArgumentError(
          'El nivel ${nivel.id} de ¿Quién soy? está incompleto.',
        );
      }
      for (final ronda in nivel.rondas) {
        if (ronda.pistas.length < 2 ||
            ronda.frase.isEmpty ||
            !ronda.opciones.contains(ronda.respuesta) ||
            ronda.opciones.toSet().length != ronda.opciones.length ||
            !ronda.opciones.every(ids.contains)) {
          throw ArgumentError('La ronda ${ronda.id} está incompleta.');
        }
      }
    }
  }
}
