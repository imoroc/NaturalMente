// Datos de «La planta a oscuras». Es un experimento: se monta la maceta (o se
// predice qué le pasará), pasan los días y se mira cómo ha crecido. Las
// opciones de cada nivel están siempre en el mismo sitio; lo que cambia en
// cada reto es cuál de ellas toca.

/// Sitios donde puede estar la maceta. Cada uno da una planta distinta.
const montajesOscuras = {
  'ventana',
  'armario',
  'caja-izquierda',
  'caja-arriba',
  'caja-derecha',
};

/// Cómo sale la planta en cada sitio después de unos días.
const crecimientoOscuras = {
  'ventana': 'sana',
  'armario': 'palida',
  'caja-izquierda': 'izquierda',
  'caja-arriba': 'sana',
  'caja-derecha': 'derecha',
};

/// Lo que se puede predecir en Difícil.
const prediccionesOscuras = {'sana', 'palida', 'doblada'};

/// Tipos de reto.
const tiposRetoOscuras = {'montar', 'predecir', 'fabricar'};

class OpcionOscuras {
  const OpcionOscuras({required this.id, required this.nombre});

  /// En `montar` es un sitio de [montajesOscuras]; en `predecir`, una de
  /// [prediccionesOscuras].
  final String id;
  final String nombre;

  factory OpcionOscuras.desdeMapa(Map<String, dynamic> mapa) {
    return OpcionOscuras(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
    );
  }
}

/// Una de las cosas que se pueden meter en la hoja en el reto `fabricar`.
class IngredienteOscuras {
  const IngredienteOscuras({
    required this.id,
    required this.nombre,
    required this.entra,
    required this.aviso,
  });

  final String id;
  final String nombre;

  /// Si la hoja lo necesita para fabricar su alimento.
  final bool entra;

  /// Lo que dice Natu si se mete sin necesitarlo o falta.
  final String aviso;

  factory IngredienteOscuras.desdeMapa(Map<String, dynamic> mapa) {
    return IngredienteOscuras(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      entra: mapa['entra'] as bool? ?? false,
      aviso: mapa['aviso'] as String? ?? '',
    );
  }
}

class RetoOscuras {
  const RetoOscuras({
    required this.id,
    required this.tipo,
    required this.pregunta,
    required this.pista,
    required this.respuesta,
    required this.montaje,
    required this.meta,
    required this.frases,
    required this.ingredientes,
    required this.como,
  });

  final String id;

  /// montar, predecir o fabricar.
  final String tipo;

  final String pregunta;
  final String pista;

  /// La opción buena en `montar` y `predecir`.
  final String respuesta;

  /// En `predecir`, dónde está la maceta.
  final String montaje;

  /// En la caja, hacia dónde tiene que crecer la planta: izquierda, arriba o
  /// derecha. Se dibuja una mariposa allí.
  final String meta;

  /// Lo que dice Natu después de los días, según la opción elegida.
  final Map<String, String> frases;

  /// En `fabricar`, lo que se puede meter en la hoja, en su sitio fijo.
  final List<IngredienteOscuras> ingredientes;

  /// En `fabricar`, lo que dice Natu cuando la hoja fabrica el alimento.
  final String como;

  /// Dónde está la maceta cuando pasan los días con la opción [elegida].
  String? montajeCon(String? elegida) => switch (tipo) {
    'montar' => elegida,
    'predecir' => montaje,
    _ => null,
  };

  factory RetoOscuras.desdeMapa(Map<String, dynamic> mapa) {
    return RetoOscuras(
      id: mapa['id'] as String,
      tipo: mapa['tipo'] as String? ?? '',
      pregunta: mapa['pregunta'] as String? ?? '',
      pista: mapa['pista'] as String? ?? '',
      respuesta: mapa['respuesta'] as String? ?? '',
      montaje: mapa['montaje'] as String? ?? '',
      meta: mapa['meta'] as String? ?? '',
      frases: {
        for (final entrada
            in (mapa['frases'] as Map<String, dynamic>? ?? {}).entries)
          entrada.key: entrada.value as String,
      },
      ingredientes: (mapa['ingredientes'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(IngredienteOscuras.desdeMapa)
          .toList(),
      como: mapa['como'] as String? ?? '',
    );
  }
}

class NivelOscuras {
  const NivelOscuras({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    required this.opciones,
    required this.retos,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;

  /// Las opciones de los retos `montar` o `predecir`, siempre en este orden.
  final List<OpcionOscuras> opciones;

  final List<RetoOscuras> retos;

  factory NivelOscuras.desdeMapa(Map<String, dynamic> mapa) {
    return NivelOscuras(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      opciones: (mapa['opciones'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(OpcionOscuras.desdeMapa)
          .toList(),
      retos: (mapa['retos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(RetoOscuras.desdeMapa)
          .toList(),
    );
  }
}

class Oscuras {
  Oscuras({required this.niveles}) {
    _comprobar();
  }

  final List<NivelOscuras> niveles;

  factory Oscuras.desdeMapa(Map<String, dynamic> mapa) {
    return Oscuras(
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelOscuras.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError(
        'La planta a oscuras necesita Fácil, Medio y Difícil.',
      );
    }
    bool frase(String texto) => texto.isNotEmpty && texto.endsWith('.');
    for (final nivel in niveles) {
      final opciones = nivel.opciones.map((o) => o.id).toList();
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          nivel.retos.isEmpty ||
          opciones.length < 2 ||
          opciones.toSet().length != opciones.length ||
          nivel.opciones.any((o) => o.nombre.isEmpty)) {
        throw ArgumentError(
          'El nivel ${nivel.id} de la planta a oscuras está incompleto.',
        );
      }
      for (final reto in nivel.retos) {
        void falla() =>
            throw ArgumentError('El reto ${reto.id} está incompleto.');
        if (!tiposRetoOscuras.contains(reto.tipo) ||
            reto.pregunta.isEmpty ||
            !frase(reto.pista)) {
          falla();
        }
        switch (reto.tipo) {
          case 'montar':
            if (!opciones.every(montajesOscuras.contains) ||
                !opciones.contains(reto.respuesta) ||
                !opciones.every((o) => frase(reto.frases[o] ?? ''))) {
              falla();
            }
          case 'predecir':
            final real = crecimientoOscuras[reto.montaje];
            if (real == null ||
                !opciones.every(prediccionesOscuras.contains) ||
                !opciones.contains(reto.respuesta) ||
                (real == 'sana' || real == 'palida' ? real : 'doblada') !=
                    reto.respuesta ||
                !opciones.every((o) => frase(reto.frases[o] ?? ''))) {
              falla();
            }
          case 'fabricar':
            final ids = reto.ingredientes.map((i) => i.id).toList();
            if (ids.length < 3 ||
                ids.toSet().length != ids.length ||
                !reto.ingredientes.any((i) => i.entra) ||
                !reto.ingredientes.any((i) => !i.entra) ||
                reto.ingredientes.any(
                  (i) => i.nombre.isEmpty || !frase(i.aviso),
                ) ||
                !frase(reto.como)) {
              falla();
            }
        }
      }
    }
  }
}
