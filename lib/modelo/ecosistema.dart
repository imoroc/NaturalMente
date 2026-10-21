class ElementoEcosistema {
  const ElementoEcosistema({
    required this.id,
    required this.nombre,
    required this.instruccion,
    required this.explicacion,
    required this.observacion,
    required this.pista,
  });
  final String id, nombre, instruccion, explicacion, observacion, pista;
  factory ElementoEcosistema.desdeMapa(Map<String, dynamic> m) =>
      ElementoEcosistema(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        instruccion: m['instruccion'] as String,
        explicacion: m['explicacion'] as String,
        observacion: m['observacion'] as String,
        pista: m['pista'] as String,
      );
}

class OpcionEcosistema {
  const OpcionEcosistema({
    required this.id,
    required this.nombre,
    required this.frase,
  });
  final String id, nombre, frase;
  factory OpcionEcosistema.desdeMapa(Map<String, dynamic> m) =>
      OpcionEcosistema(
        id: m['id'] as String,
        nombre: m['nombre'] as String,
        frase: m['frase'] as String,
      );
}

class RetoEcosistema {
  const RetoEcosistema({
    required this.id,
    required this.pregunta,
    required this.respuesta,
    required this.pista,
    required this.opciones,
  });
  final String id, pregunta, respuesta, pista;
  final List<OpcionEcosistema> opciones;
  factory RetoEcosistema.desdeMapa(Map<String, dynamic> m) => RetoEcosistema(
    id: m['id'] as String,
    pregunta: m['pregunta'] as String,
    respuesta: m['respuesta'] as String,
    pista: m['pista'] as String,
    opciones: (m['opciones'] as List)
        .map((o) => OpcionEcosistema.desdeMapa(o as Map<String, dynamic>))
        .toList(),
  );
}

class NivelEcosistema {
  const NivelEcosistema({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.retos,
  });
  final String id, nombre, curso, resumen;
  final List<RetoEcosistema> retos;
  factory NivelEcosistema.desdeMapa(Map<String, dynamic> m) => NivelEcosistema(
    id: m['id'] as String,
    nombre: m['nombre'] as String,
    curso: m['curso'] as String,
    resumen: m['resumen'] as String,
    retos: (m['retos'] as List)
        .map((r) => RetoEcosistema.desdeMapa(r as Map<String, dynamic>))
        .toList(),
  );
}

class Ecosistema {
  Ecosistema({required this.elementos, required this.niveles}) {
    final ids = elementos.map((e) => e.id).toSet();
    if (ids.length != elementos.length ||
        !ids.containsAll(['hierba', 'conejo', 'zorro']) ||
        ids.length != 3 ||
        niveles.map((n) => n.id).toSet().length != 3 ||
        !niveles.map((n) => n.id).toSet().containsAll([
          'facil',
          'medio',
          'dificil',
        ])) {
      throw ArgumentError(
        'El ecosistema necesita tres elementos y tres niveles únicos.',
      );
    }
    for (final nivel in niveles) {
      if (nivel.retos.length !=
          (nivel.id == 'facil'
              ? 0
              : nivel.id == 'medio'
              ? 2
              : 4)) {
        throw ArgumentError('El nivel ${nivel.id} tiene retos incompletos.');
      }
      for (final reto in nivel.retos) {
        final opciones = reto.opciones.map((o) => o.id).toSet();
        if (opciones.length != reto.opciones.length ||
            opciones.length < 2 ||
            !opciones.contains(reto.respuesta) ||
            reto.pista.isEmpty ||
            reto.opciones.any((o) => o.frase.isEmpty)) {
          throw ArgumentError(
            'El reto ${reto.id} tiene respuestas incompletas.',
          );
        }
      }
    }
  }
  final List<ElementoEcosistema> elementos;
  final List<NivelEcosistema> niveles;
  factory Ecosistema.desdeMapa(Map<String, dynamic> m) => Ecosistema(
    elementos: (m['elementos'] as List)
        .map((e) => ElementoEcosistema.desdeMapa(e as Map<String, dynamic>))
        .toList(),
    niveles: (m['niveles'] as List)
        .map((n) => NivelEcosistema.desdeMapa(n as Map<String, dynamic>))
        .toList(),
  );
}
