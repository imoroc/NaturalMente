// Datos de «Carrera de relevos». Cada ronda es un relevo: una pista con
// tramos fijos (cielo, cuesta, piedras, túnel, agua…) y un corredor para cada
// tramo. En Difícil el corredor se presenta como una parte del cuerpo vista
// con la lupa y al terminar el relevo se descubre de qué animal era.

/// Un tramo de la pista. Su orden en el nivel es fijo.
class TramoCarrera {
  const TramoCarrera({
    required this.id,
    required this.nombre,
    required this.reto,
  });

  /// Movimiento que pide el tramo: vuela, anda, nada, trepa, salta o repta.
  final String id;
  final String nombre;

  /// Frase que dice qué hay que hacer en el tramo. Termina en punto.
  final String reto;

  factory TramoCarrera.desdeMapa(Map<String, dynamic> mapa) {
    return TramoCarrera(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      reto: mapa['reto'] as String? ?? '',
    );
  }
}

/// Zona del dibujo que enseña la lupa, de 0 a 1, y cuánto se amplía.
class LupaCorredor {
  const LupaCorredor({required this.x, required this.y, required this.zoom});

  final double x;
  final double y;
  final double zoom;

  factory LupaCorredor.desdeMapa(Map<String, dynamic> mapa) {
    return LupaCorredor(
      x: (mapa['x'] as num? ?? .5).toDouble(),
      y: (mapa['y'] as num? ?? .5).toDouble(),
      zoom: (mapa['zoom'] as num? ?? 2).toDouble(),
    );
  }
}

class CorredorCarrera {
  const CorredorCarrera({
    required this.id,
    required this.nombre,
    required this.dibujo,
    required this.tramo,
    required this.como,
    required this.pista,
    this.parte = '',
    this.lupa,
  });

  final String id;
  final String nombre;
  final String dibujo;

  /// Tramo donde mejor se mueve.
  final String tramo;

  /// Cómo se mueve, dicho por el propio corredor.
  final String como;
  final String pista;

  /// Solo en Difícil: la parte del cuerpo que se ve antes de descubrirlo.
  final String parte;
  final LupaCorredor? lupa;

  factory CorredorCarrera.desdeMapa(Map<String, dynamic> mapa) {
    return CorredorCarrera(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      dibujo: mapa['dibujo'] as String? ?? '',
      tramo: mapa['tramo'] as String? ?? '',
      como: mapa['como'] as String? ?? '',
      pista: mapa['pista'] as String? ?? '',
      parte: mapa['parte'] as String? ?? '',
      lupa: mapa['lupa'] == null
          ? null
          : LupaCorredor.desdeMapa(mapa['lupa'] as Map<String, dynamic>),
    );
  }
}

class RondaCarrera {
  const RondaCarrera({
    required this.id,
    required this.bien,
    required this.corredores,
  });

  final String id;

  /// Lo que dice Natu cuando el relevo llega a la meta.
  final String bien;
  final List<CorredorCarrera> corredores;

  factory RondaCarrera.desdeMapa(Map<String, dynamic> mapa) {
    return RondaCarrera(
      id: mapa['id'] as String,
      bien: mapa['bien'] as String? ?? '',
      corredores: (mapa['corredores'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CorredorCarrera.desdeMapa)
          .toList(),
    );
  }
}

class NivelCarrera {
  const NivelCarrera({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    required this.tramos,
    required this.rondas,
    this.lupa = false,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;
  final List<TramoCarrera> tramos;
  final List<RondaCarrera> rondas;

  /// Si los corredores se presentan como partes del cuerpo vistas con lupa.
  final bool lupa;

  factory NivelCarrera.desdeMapa(Map<String, dynamic> mapa) {
    return NivelCarrera(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      lupa: mapa['lupa'] as bool? ?? false,
      tramos: (mapa['tramos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(TramoCarrera.desdeMapa)
          .toList(),
      rondas: (mapa['rondas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(RondaCarrera.desdeMapa)
          .toList(),
    );
  }
}

class Carrera {
  Carrera({required this.niveles}) {
    _comprobar();
  }

  final List<NivelCarrera> niveles;

  factory Carrera.desdeMapa(Map<String, dynamic> mapa) {
    return Carrera(
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelCarrera.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('La carrera necesita Fácil, Medio y Difícil.');
    }
    for (final nivel in niveles) {
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          nivel.tramos.length < 2 ||
          nivel.rondas.isEmpty) {
        throw ArgumentError(
          'El nivel ${nivel.id} de la carrera está incompleto.',
        );
      }
      final tramos = nivel.tramos.map((t) => t.id).toList();
      if (tramos.toSet().length != tramos.length ||
          nivel.tramos.any((t) => t.nombre.isEmpty || !t.reto.endsWith('.'))) {
        throw ArgumentError('Los tramos de ${nivel.id} están incompletos.');
      }
      for (final ronda in nivel.rondas) {
        // Un corredor para cada tramo: así el relevo siempre tiene solución.
        final destinos = ronda.corredores.map((c) => c.tramo).toList()..sort();
        if (ronda.bien.isEmpty ||
            destinos.join(',') != ([...tramos]..sort()).join(',')) {
          throw ArgumentError(
            'La ronda ${ronda.id} necesita un corredor para cada tramo.',
          );
        }
        if (ronda.corredores.map((c) => c.id).toSet().length !=
            ronda.corredores.length) {
          throw ArgumentError('La ronda ${ronda.id} repite corredor.');
        }
        for (final corredor in ronda.corredores) {
          if (corredor.nombre.isEmpty ||
              corredor.dibujo.isEmpty ||
              corredor.como.isEmpty ||
              corredor.pista.isEmpty ||
              (nivel.lupa &&
                  (corredor.parte.isEmpty || corredor.lupa == null))) {
            throw ArgumentError(
              'El corredor ${corredor.id} de ${ronda.id} está incompleto.',
            );
          }
        }
      }
    }
  }
}
