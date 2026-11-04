import 'package:naturalmente/modelo/actividad.dart';

// Datos de «Cuida la reserva». Fácil es una escena del bosque y el río donde
// se recoge la basura; Medio, separar residuos en contenedores; Difícil,
// especies amenazadas: qué las pone en peligro y qué las ayuda.

class ObjetoEscena {
  const ObjetoEscena({
    required this.id,
    required this.nombre,
    required this.basura,
    required this.frase,
    required this.x,
    required this.y,
  });

  final String id;
  final String nombre;

  /// Si hay que recogerlo. Lo que no es basura forma parte de la reserva.
  final bool basura;

  /// Lo que dice Natu al tocarlo.
  final String frase;

  /// Posición en la escena, de 0 a 1.
  final double x;
  final double y;

  factory ObjetoEscena.desdeMapa(Map<String, dynamic> mapa) {
    return ObjetoEscena(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      basura: mapa['basura'] as bool? ?? false,
      frase: mapa['frase'] as String? ?? '',
      x: (mapa['x'] as num? ?? 0).toDouble(),
      y: (mapa['y'] as num? ?? 0).toDouble(),
    );
  }
}

class Residuo {
  const Residuo({
    required this.id,
    required this.nombre,
    required this.contenedor,
    required this.bien,
    required this.mal,
  });

  final String id;
  final String nombre;
  final String contenedor;
  final String bien;
  final String mal;

  factory Residuo.desdeMapa(Map<String, dynamic> mapa) {
    return Residuo(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      contenedor: mapa['contenedor'] as String? ?? '',
      bien: mapa['bien'] as String? ?? '',
      mal: mapa['mal'] as String? ?? '',
    );
  }
}

class Especie {
  const Especie({
    required this.id,
    required this.nombre,
    required this.dibujo,
    required this.presentacion,
    required this.amenaza,
    required this.ayuda,
  });

  final String id;
  final String nombre;
  final String dibujo;
  final String presentacion;
  final PreguntaExtra amenaza;
  final PreguntaExtra ayuda;

  factory Especie.desdeMapa(Map<String, dynamic> mapa) {
    return Especie(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      dibujo: mapa['dibujo'] as String? ?? '',
      presentacion: mapa['presentacion'] as String? ?? '',
      amenaza: PreguntaExtra.desdeMapa(mapa['amenaza'] as Map<String, dynamic>),
      ayuda: PreguntaExtra.desdeMapa(mapa['ayuda'] as Map<String, dynamic>),
    );
  }
}

class NivelRescate {
  const NivelRescate({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    required this.intro,
    required this.curiosidad,
    required this.despedida,
    this.objetos = const [],
    this.contenedores = const [],
    this.residuos = const [],
    this.especies = const [],
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final String despedida;
  final List<ObjetoEscena> objetos;
  final List<Opcion> contenedores;
  final List<Residuo> residuos;
  final List<Especie> especies;

  bool get esEscena => objetos.isNotEmpty;
  bool get esContenedores => residuos.isNotEmpty;
  bool get esEspecies => especies.isNotEmpty;

  factory NivelRescate.desdeMapa(Map<String, dynamic> mapa) {
    List<T> lista<T>(String clave, T Function(Map<String, dynamic>) crear) =>
        (mapa[clave] as List? ?? [])
            .cast<Map<String, dynamic>>()
            .map(crear)
            .toList();
    return NivelRescate(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String? ?? '',
      curso: mapa['curso'] as String? ?? '',
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      despedida: mapa['despedida'] as String? ?? '',
      objetos: lista('objetos', ObjetoEscena.desdeMapa),
      contenedores: lista('contenedores', Opcion.desdeMapa),
      residuos: lista('residuos', Residuo.desdeMapa),
      especies: lista('especies', Especie.desdeMapa),
    );
  }
}

class Rescate {
  Rescate({required this.niveles}) {
    _comprobar();
  }

  final List<NivelRescate> niveles;

  factory Rescate.desdeMapa(Map<String, dynamic> mapa) {
    return Rescate(
      niveles: (mapa['niveles'] as List)
          .cast<Map<String, dynamic>>()
          .map(NivelRescate.desdeMapa)
          .toList(),
    );
  }

  void _comprobar() {
    if (niveles.map((n) => n.id).join(',') != 'facil,medio,dificil') {
      throw ArgumentError('Cuida la reserva necesita Fácil, Medio y Difícil.');
    }
    for (final nivel in niveles) {
      final modos = [
        nivel.esEscena,
        nivel.esContenedores,
        nivel.esEspecies,
      ].where((m) => m).length;
      if (nivel.nombre.isEmpty ||
          nivel.curso.isEmpty ||
          nivel.intro.isEmpty ||
          nivel.curiosidad.isEmpty ||
          nivel.despedida.isEmpty ||
          modos != 1) {
        throw ArgumentError(
          'El nivel ${nivel.id} de la reserva está incompleto.',
        );
      }
      if (nivel.esEscena &&
          (!nivel.objetos.any((o) => o.basura) ||
              nivel.objetos.any(
                (o) =>
                    o.frase.isEmpty || o.x < 0 || o.x > 1 || o.y < 0 || o.y > 1,
              ))) {
        throw ArgumentError('La escena de ${nivel.id} está incompleta.');
      }
      if (nivel.esContenedores) {
        final ids = {for (final c in nivel.contenedores) c.id};
        if (nivel.residuos.any(
          (r) => !ids.contains(r.contenedor) || r.bien.isEmpty || r.mal.isEmpty,
        )) {
          throw ArgumentError('Los residuos de ${nivel.id} están incompletos.');
        }
      }
      for (final especie in nivel.especies) {
        for (final pregunta in [especie.amenaza, especie.ayuda]) {
          final ids = {for (final o in pregunta.opciones) o.id};
          if (!ids.contains(pregunta.respuesta) ||
              !ids.every((id) => (pregunta.frases[id] ?? '').isNotEmpty)) {
            throw ArgumentError('Falta una frase de ${especie.id}.');
          }
        }
      }
    }
  }
}
