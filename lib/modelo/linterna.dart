// Datos de «Linterna y microscopio». Cada escena es un dibujo a oscuras
// (el cuerpo, el esqueleto, una célula…) y una lista fija de cosas que hay que
// encontrar con la luz. La lista no cambia de orden; lo que cambia es dónde
// está cada cosa en el dibujo.

/// Proporción alto/ancho de todas las escenas.
const aspectoEscenaLinterna = 4 / 3;

/// Herramientas con las que se mira la escena.
const herramientasLinterna = {'linterna', 'rayos', 'microscopio'};

/// Un círculo del dibujo donde está el objetivo. `x` e `y` van de 0 a 1 sobre
/// el ancho y el alto de la escena; `r` es el radio en proporción al ancho.
class ZonaLinterna {
  const ZonaLinterna({required this.x, required this.y, required this.r});

  final double x;
  final double y;
  final double r;

  /// Distancia al centro en unidades del radio: menos de 1 es dentro.
  double distancia(double px, double py) {
    final dx = px - x;
    final dy = (py - y) * aspectoEscenaLinterna;
    return (dx * dx + dy * dy) / (r * r);
  }

  factory ZonaLinterna.desdeMapa(Map<String, dynamic> mapa) {
    return ZonaLinterna(
      x: (mapa['x'] as num).toDouble(),
      y: (mapa['y'] as num).toDouble(),
      r: (mapa['r'] as num).toDouble(),
    );
  }
}

class ObjetivoLinterna {
  const ObjetivoLinterna({
    required this.id,
    required this.nombre,
    required this.como,
    required this.aviso,
    required this.pista,
    required this.zonas,
  });

  final String id;
  final String nombre;

  /// Lo que dice Natu al encontrarlo.
  final String como;

  /// Lo que dice Natu si se toca cuando se buscaba otra cosa.
  final String aviso;

  /// Ayuda para encontrarlo, a partir del segundo intento.
  final String pista;

  final List<ZonaLinterna> zonas;

  factory ObjetivoLinterna.desdeMapa(Map<String, dynamic> mapa) {
    return ObjetivoLinterna(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      como: mapa['como'] as String? ?? '',
      aviso: mapa['aviso'] as String? ?? '',
      pista: mapa['pista'] as String? ?? '',
      zonas: (mapa['zonas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(ZonaLinterna.desdeMapa)
          .toList(),
    );
  }
}

class EscenaLinterna {
  const EscenaLinterna({
    required this.id,
    required this.dibujo,
    required this.bien,
    required this.objetivos,
  });

  final String id;

  /// Dibujo de la escena, en `lib/ui/dibujos_linterna.dart`.
  final String dibujo;

  /// Lo que dice Natu cuando se enciende la luz al final de la escena.
  final String bien;

  final List<ObjetivoLinterna> objetivos;

  factory EscenaLinterna.desdeMapa(Map<String, dynamic> mapa) {
    return EscenaLinterna(
      id: mapa['id'] as String,
      dibujo: mapa['dibujo'] as String? ?? '',
      bien: mapa['bien'] as String? ?? '',
      objetivos: (mapa['objetivos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(ObjetivoLinterna.desdeMapa)
          .toList(),
    );
  }
}

class NivelLinterna {
  const NivelLinterna({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    required this.herramienta,
    required this.luz,
    required this.escenas,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;

  /// linterna, rayos o microscopio.
  final String herramienta;

  /// Radio del círculo de luz, en proporción al ancho de la escena.
  final double luz;

  final List<EscenaLinterna> escenas;

  factory NivelLinterna.desdeMapa(Map<String, dynamic> mapa) {
    return NivelLinterna(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      herramienta: mapa['herramienta'] as String? ?? '',
      luz: (mapa['luz'] as num? ?? .2).toDouble(),
      escenas: (mapa['escenas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(EscenaLinterna.desdeMapa)
          .toList(),
    );
  }
}

class Linterna {
  Linterna({required this.niveles}) {
    _comprobar();
  }

  final List<NivelLinterna> niveles;

  factory Linterna.desdeMapa(Map<String, dynamic> mapa) {
    return Linterna(
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelLinterna.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('La linterna necesita Fácil, Medio y Difícil.');
    }
    bool frase(String texto) => texto.isNotEmpty && texto.endsWith('.');
    for (final nivel in niveles) {
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          !herramientasLinterna.contains(nivel.herramienta) ||
          nivel.luz <= 0 ||
          nivel.escenas.isEmpty) {
        throw ArgumentError(
          'El nivel ${nivel.id} de la linterna está incompleto.',
        );
      }
      for (final escena in nivel.escenas) {
        final ids = escena.objetivos.map((o) => o.id).toList();
        if (escena.dibujo.isEmpty ||
            escena.bien.isEmpty ||
            ids.length < 2 ||
            ids.toSet().length != ids.length) {
          throw ArgumentError('La escena ${escena.id} está incompleta.');
        }
        for (final objetivo in escena.objetivos) {
          if (objetivo.nombre.isEmpty ||
              !frase(objetivo.como) ||
              !frase(objetivo.aviso) ||
              !frase(objetivo.pista) ||
              objetivo.zonas.isEmpty ||
              objetivo.zonas.any(
                (z) => z.r <= 0 || z.x < 0 || z.x > 1 || z.y < 0 || z.y > 1,
              )) {
            throw ArgumentError(
              'El objetivo ${objetivo.id} de ${escena.id} está incompleto.',
            );
          }
        }
      }
    }
  }
}
