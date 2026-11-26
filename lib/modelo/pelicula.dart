// Datos de «La película de la planta». Cada rollo es la vida de una planta
// contada en fotogramas. Los fotogramas se llenan en orden, de izquierda a
// derecha, con las cartas de la bandeja. La bandeja no se mueve: cada carta
// tiene su sitio fijo, y el sitio de la carta que toca cambia en cada rollo.

/// Plantas que sabe dibujar `lib/ui/dibujos_pelicula.dart`.
const plantasPelicula = {
  'judia',
  'girasol',
  'tomatera',
  'cerezo',
  'diente-leon',
  'avellano',
};

/// Momentos de la vida de la planta que se pueden dibujar.
const fasesPelicula = {
  'semilla',
  'germina',
  'brote',
  'planta',
  'flor',
  'fruto',
  'abeja',
  'viento-polen',
  'viento-semillas',
  'pajaro',
  'ardilla',
};

/// Una carta de la bandeja.
class CartaPelicula {
  const CartaPelicula({
    required this.id,
    required this.nombre,
    required this.fase,
    required this.aviso,
  });

  final String id;
  final String nombre;

  /// Qué momento se dibuja, de [fasesPelicula].
  final String fase;

  /// Lo que dice Natu si se pone donde no toca.
  final String aviso;

  factory CartaPelicula.desdeMapa(Map<String, dynamic> mapa) {
    return CartaPelicula(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      fase: mapa['fase'] as String? ?? '',
      aviso: mapa['aviso'] as String? ?? '',
    );
  }
}

/// Un fotograma de la tira. Su carta es la de la bandeja con el mismo id.
class FotogramaPelicula {
  const FotogramaPelicula({
    required this.id,
    required this.como,
    required this.pista,
  });

  final String id;

  /// Lo que dice Natu al poner la carta buena.
  final String como;

  /// Ayuda a partir del segundo intento.
  final String pista;

  factory FotogramaPelicula.desdeMapa(Map<String, dynamic> mapa) {
    return FotogramaPelicula(
      id: mapa['id'] as String,
      como: mapa['como'] as String? ?? '',
      pista: mapa['pista'] as String? ?? '',
    );
  }
}

class RolloPelicula {
  const RolloPelicula({
    required this.id,
    required this.planta,
    required this.titulo,
    required this.bien,
    required this.rueda,
    required this.fotogramas,
    required this.bandeja,
  });

  final String id;

  /// Qué planta sale en la película, de [plantasPelicula].
  final String planta;

  final String titulo;

  /// Lo que dice Natu cuando se proyecta la película entera.
  final String bien;

  /// Si la tira se cierra: las semillas del final vuelven al principio.
  final bool rueda;

  final List<FotogramaPelicula> fotogramas;

  /// Las cartas en su sitio fijo. Puede haber cartas que no van en la tira.
  final List<CartaPelicula> bandeja;

  CartaPelicula? carta(String id) {
    for (final carta in bandeja) {
      if (carta.id == id) return carta;
    }
    return null;
  }

  factory RolloPelicula.desdeMapa(Map<String, dynamic> mapa) {
    return RolloPelicula(
      id: mapa['id'] as String,
      planta: mapa['planta'] as String? ?? '',
      titulo: mapa['titulo'] as String? ?? '',
      bien: mapa['bien'] as String? ?? '',
      rueda: mapa['rueda'] as bool? ?? false,
      fotogramas: (mapa['fotogramas'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(FotogramaPelicula.desdeMapa)
          .toList(),
      bandeja: (mapa['bandeja'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(CartaPelicula.desdeMapa)
          .toList(),
    );
  }
}

class NivelPelicula {
  const NivelPelicula({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    required this.rollos,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;
  final List<RolloPelicula> rollos;

  factory NivelPelicula.desdeMapa(Map<String, dynamic> mapa) {
    return NivelPelicula(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      rollos: (mapa['rollos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(RolloPelicula.desdeMapa)
          .toList(),
    );
  }
}

class Pelicula {
  Pelicula({required this.niveles}) {
    _comprobar();
  }

  final List<NivelPelicula> niveles;

  factory Pelicula.desdeMapa(Map<String, dynamic> mapa) {
    return Pelicula(
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelPelicula.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('La película necesita Fácil, Medio y Difícil.');
    }
    bool frase(String texto) => texto.isNotEmpty && texto.endsWith('.');
    for (final nivel in niveles) {
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          nivel.rollos.isEmpty) {
        throw ArgumentError(
          'El nivel ${nivel.id} de la película está incompleto.',
        );
      }
      for (final rollo in nivel.rollos) {
        final cartas = rollo.bandeja.map((c) => c.id).toList();
        final tira = rollo.fotogramas.map((f) => f.id).toList();
        if (!plantasPelicula.contains(rollo.planta) ||
            rollo.titulo.isEmpty ||
            !frase(rollo.bien) ||
            tira.length < 3 ||
            tira.toSet().length != tira.length ||
            cartas.toSet().length != cartas.length ||
            !tira.every(cartas.contains)) {
          throw ArgumentError('El rollo ${rollo.id} está incompleto.');
        }
        for (final fotograma in rollo.fotogramas) {
          if (!frase(fotograma.como) || !frase(fotograma.pista)) {
            throw ArgumentError(
              'El fotograma ${fotograma.id} de ${rollo.id} está incompleto.',
            );
          }
        }
        for (final carta in rollo.bandeja) {
          if (carta.nombre.isEmpty ||
              !fasesPelicula.contains(carta.fase) ||
              !frase(carta.aviso)) {
            throw ArgumentError(
              'La carta ${carta.id} de ${rollo.id} está incompleta.',
            );
          }
        }
      }
    }
  }
}
