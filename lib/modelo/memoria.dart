// Datos de «Memoria de las plantas»: parejas de cartas. Una carta lleva un
// dibujo (una parte o una planta) y su pareja dice qué hace o qué es.

class CartaMemoria {
  const CartaMemoria({required this.texto, this.dibujo = '', this.icono = ''});

  final String texto;

  /// Id de un dibujo de la app (parte de la planta, planta o juego nuevo).
  final String dibujo;

  /// Nombre de un icono, para las cartas que no tienen dibujo.
  final String icono;

  factory CartaMemoria.desdeMapa(Map<String, dynamic> mapa) {
    return CartaMemoria(
      texto: mapa['texto'] as String? ?? '',
      dibujo: mapa['dibujo'] as String? ?? '',
      icono: mapa['icono'] as String? ?? '',
    );
  }
}

class ParejaMemoria {
  const ParejaMemoria({
    required this.id,
    required this.a,
    required this.b,
    required this.frase,
  });

  final String id;
  final CartaMemoria a;
  final CartaMemoria b;

  /// Lo que explica Natu al encontrar la pareja.
  final String frase;

  factory ParejaMemoria.desdeMapa(Map<String, dynamic> mapa) {
    return ParejaMemoria(
      id: mapa['id'] as String,
      a: CartaMemoria.desdeMapa(mapa['a'] as Map<String, dynamic>),
      b: CartaMemoria.desdeMapa(mapa['b'] as Map<String, dynamic>),
      frase: mapa['frase'] as String? ?? '',
    );
  }
}

class NivelMemoria {
  const NivelMemoria({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    required this.parejas,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;
  final List<ParejaMemoria> parejas;

  /// Ids de las cartas: cada pareja da «id-a» e «id-b».
  List<String> get cartas => [
    for (final p in parejas) ...['${p.id}-a', '${p.id}-b'],
  ];

  ParejaMemoria pareja(String cartaId) =>
      parejas.firstWhere((p) => cartaId.startsWith('${p.id}-'));

  CartaMemoria carta(String cartaId) {
    final pareja = this.pareja(cartaId);
    return cartaId.endsWith('-a') ? pareja.a : pareja.b;
  }

  factory NivelMemoria.desdeMapa(Map<String, dynamic> mapa) {
    return NivelMemoria(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      parejas: (mapa['parejas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(ParejaMemoria.desdeMapa)
          .toList(),
    );
  }
}

class Memoria {
  Memoria({required this.niveles}) {
    _comprobar();
  }

  final List<NivelMemoria> niveles;

  factory Memoria.desdeMapa(Map<String, dynamic> mapa) {
    return Memoria(
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelMemoria.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('La memoria necesita Fácil, Medio y Difícil.');
    }
    for (final nivel in niveles) {
      final ids = nivel.parejas.map((p) => p.id).toSet();
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          nivel.parejas.length < 2 ||
          ids.length != nivel.parejas.length ||
          nivel.parejas.any(
            (p) => p.frase.isEmpty || p.a.texto.isEmpty || p.b.texto.isEmpty,
          )) {
        throw ArgumentError(
          'El nivel ${nivel.id} de la memoria está incompleto.',
        );
      }
    }
  }
}
