import 'package:naturalmente/modelo/actividad.dart';

// Datos de «El viaje de la comida»: un bocado recorre el aparato digestivo
// parada a parada. Los despistes son órganos por los que la comida no pasa.

/// Paradas que el dibujo del cuerpo sabe pintar y localizar.
const paradasDigestivas = {
  'boca',
  'esofago',
  'estomago',
  'barriga',
  'intestino',
  'intestino-delgado',
  'intestino-grueso',
};

class Despiste {
  const Despiste({required this.id, required this.nombre, required this.frase});

  final String id;
  final String nombre;
  final String frase;

  factory Despiste.desdeMapa(Map<String, dynamic> mapa) {
    return Despiste(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      frase: mapa['frase'] as String? ?? '',
    );
  }
}

class Parada {
  const Parada({
    required this.id,
    required this.nombre,
    required this.llegada,
    required this.salto,
    required this.pista,
    this.pregunta,
  });

  final String id;
  final String nombre;
  final String llegada;
  final String salto;
  final String pista;
  final PreguntaExtra? pregunta;

  factory Parada.desdeMapa(Map<String, dynamic> mapa) {
    return Parada(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      llegada: mapa['llegada'] as String? ?? '',
      salto: mapa['salto'] as String? ?? '',
      pista: mapa['pista'] as String? ?? '',
      pregunta: mapa['pregunta'] == null
          ? null
          : PreguntaExtra.desdeMapa(mapa['pregunta'] as Map<String, dynamic>),
    );
  }
}

class NivelViaje {
  const NivelViaje({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.masticar,
    required this.sinMasticar,
    required this.atras,
    required this.paradas,
    required this.despistes,
    this.preguntaFinal,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final bool masticar;
  final String sinMasticar;
  final String atras;
  final List<Parada> paradas;
  final List<String> despistes;
  final PreguntaExtra? preguntaFinal;

  List<String> get ruta => [for (final parada in paradas) parada.id];

  bool get preguntaPorParada => paradas.any((p) => p.pregunta != null);

  Parada parada(String id) => paradas.firstWhere((p) => p.id == id);

  factory NivelViaje.desdeMapa(Map<String, dynamic> mapa) {
    return NivelViaje(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      masticar: mapa['masticar'] as bool? ?? false,
      sinMasticar: mapa['sinMasticar'] as String? ?? '',
      atras: mapa['atras'] as String? ?? '',
      paradas: (mapa['paradas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Parada.desdeMapa)
          .toList(),
      despistes: (mapa['despistes'] as List? ?? []).cast<String>(),
      preguntaFinal: mapa['preguntaFinal'] == null
          ? null
          : PreguntaExtra.desdeMapa(
              mapa['preguntaFinal'] as Map<String, dynamic>,
            ),
    );
  }
}

class Viaje {
  Viaje({required this.despistes, required this.niveles}) {
    _comprobar();
  }

  final List<Despiste> despistes;
  final List<NivelViaje> niveles;

  Despiste despiste(String id) => despistes.firstWhere((d) => d.id == id);

  factory Viaje.desdeMapa(Map<String, dynamic> mapa) {
    return Viaje(
      despistes: (mapa['despistes'] as List)
          .cast<Map<String, dynamic>>()
          .map(Despiste.desdeMapa)
          .toList(),
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelViaje.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    final idsDespistes = despistes.map((d) => d.id).toSet();
    if (idsDespistes.length != despistes.length ||
        idsDespistes.any(paradasDigestivas.contains) ||
        despistes.any((d) => d.nombre.isEmpty || d.frase.isEmpty)) {
      throw ArgumentError('Los despistes del viaje están incompletos.');
    }
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('El viaje necesita Fácil, Medio y Difícil.');
    }
    for (final nivel in niveles) {
      final ruta = nivel.ruta;
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.atras.isEmpty ||
          ruta.length < 2 ||
          ruta.first != 'boca' ||
          ruta.toSet().length != ruta.length ||
          !ruta.every(paradasDigestivas.contains)) {
        throw ArgumentError('El nivel ${nivel.id} tiene una ruta inválida.');
      }
      if (nivel.masticar && nivel.sinMasticar.isEmpty) {
        throw ArgumentError(
          'Al nivel ${nivel.id} le falta la frase de masticar.',
        );
      }
      if (nivel.despistes.isEmpty ||
          !nivel.despistes.every(idsDespistes.contains)) {
        throw ArgumentError('El nivel ${nivel.id} tiene despistes inválidos.');
      }
      for (var i = 0; i < nivel.paradas.length; i++) {
        final parada = nivel.paradas[i];
        final ultima = i == nivel.paradas.length - 1;
        if (parada.nombre.isEmpty ||
            parada.llegada.isEmpty ||
            parada.pista.isEmpty ||
            (!ultima && parada.salto.isEmpty)) {
          throw ArgumentError(
            'La parada ${parada.id} de ${nivel.id} está incompleta.',
          );
        }
      }
      // Difícil pregunta en cada parada; Medio, una sola vez al final.
      final todasConPregunta = nivel.paradas.every((p) => p.pregunta != null);
      if (nivel.id == 'dificil' && !todasConPregunta) {
        throw ArgumentError('En Difícil cada parada necesita su pregunta.');
      }
      if (nivel.id == 'medio' && nivel.preguntaFinal == null) {
        throw ArgumentError('Medio necesita una pregunta final.');
      }
    }
  }
}
