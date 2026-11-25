import 'package:flutter/foundation.dart';

/// Plantillas que el profesor puede usar sin programar.
enum PlantillaAula {
  opcionMultiple('opcion_multiple', 'Test de opción múltiple'),
  verdaderoFalso('verdadero_falso', 'Verdadero o falso');

  const PlantillaAula(this.id, this.nombre);
  final String id;
  final String nombre;

  static PlantillaAula? desdeId(String? id) =>
      values.where((p) => p.id == id).firstOrNull;
}

/// Imagen de una pregunta, una respuesta o el fondo.
///
/// Las de la galería vienen dentro de la app y no gastan datos. Las subidas
/// por el profesor se descargan una vez y se guardan en caché.
@immutable
sealed class ImagenAula {
  const ImagenAula();

  static ImagenAula? desdeJson(Object? json) {
    if (json is! Map) return null;
    final galeria = json['galeria'];
    if (galeria is String && galeriaAula.containsKey(galeria)) {
      return ImagenGaleria(galeria);
    }
    final url = json['url'];
    if (url is String && url.startsWith('https://')) return ImagenSubida(url);
    return null;
  }

  Map<String, dynamic> toJson();
}

class ImagenGaleria extends ImagenAula {
  const ImagenGaleria(this.id);
  final String id;
  String get asset => galeriaAula[id]!.$1;
  @override
  Map<String, dynamic> toJson() => {'galeria': id};
  @override
  bool operator ==(Object other) => other is ImagenGaleria && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class ImagenSubida extends ImagenAula {
  const ImagenSubida(this.url);
  final String url;
  @override
  Map<String, dynamic> toJson() => {'url': url};
  @override
  bool operator ==(Object other) => other is ImagenSubida && other.url == url;
  @override
  int get hashCode => url.hashCode;
}

/// Fondos e ilustraciones que ya trae la app: id → (asset, nombre).
const galeriaAula = <String, (String, String)>{
  'paisaje-reserva': ('assets/mundos/paisaje-reserva.webp', 'Paisaje de animales'),
  'paisaje-invernadero': ('assets/mundos/paisaje-invernadero.webp', 'Paisaje de plantas'),
  'paisaje-cuerpo': ('assets/mundos/paisaje-cuerpo.webp', 'Paisaje del cuerpo'),
  'hogar': ('assets/mundos/hogar.webp', '¿Dónde vive?'),
  'dieta': ('assets/mundos/dieta.webp', '¿Qué come?'),
  'grupos': ('assets/mundos/grupos.webp', 'Grupos de animales'),
  'nacimiento': ('assets/mundos/nacimiento.webp', 'Cómo nacen'),
  'ecosistemas': ('assets/mundos/ecosistemas.webp', 'Ecosistemas'),
  'plantas': ('assets/mundos/plantas.webp', 'Plantas'),
  'polinizacion': ('assets/mundos/polinizacion.webp', 'Polinización'),
  'estaciones': ('assets/mundos/estaciones.webp', 'Estaciones'),
  'huerta': ('assets/mundos/huerta.webp', 'Huerta'),
  'germinacion': ('assets/mundos/germinacion.webp', 'Germinación'),
  'herbario': ('assets/mundos/herbario.webp', 'Herbario'),
  'sentidos': ('assets/mundos/sentidos.webp', 'Los sentidos'),
  'digestion': ('assets/mundos/digestion.webp', 'Digestión'),
  'respiracion': ('assets/mundos/respiracion.webp', 'Respiración'),
  'organos': ('assets/mundos/organos.webp', 'Órganos'),
  'plato': ('assets/mundos/plato.webp', 'Alimentación'),
  'emociones': ('assets/mundos/emociones.webp', 'Emociones'),
};

@immutable
class OpcionAula {
  const OpcionAula({required this.texto, this.imagen});
  final String texto;
  final ImagenAula? imagen;

  Map<String, dynamic> toJson() => {
    'texto': texto,
    if (imagen != null) 'imagen': imagen!.toJson(),
  };
}

@immutable
class PreguntaAula {
  const PreguntaAula({
    required this.enunciado,
    required this.opciones,
    required this.correcta,
    this.imagen,
    this.explicacion = '',
    this.pista = '',
  });

  final String enunciado;
  final ImagenAula? imagen;
  final List<OpcionAula> opciones;
  final int correcta;

  /// Se enseña al acertar, antes de pasar a la siguiente.
  final String explicacion;

  /// Se enseña tras un fallo, sin dar la respuesta.
  final String pista;
}

/// Un juego del profesor tal como lo guarda la base de datos.
@immutable
class JuegoAula {
  const JuegoAula({
    required this.id,
    required this.titulo,
    required this.plantilla,
    required this.version,
    required this.cursos,
    required this.preguntas,
    this.fondo,
    this.mostrarNatu = true,
    this.intro = '',
  });

  /// Lee una fila de la tabla `juegos`. Devuelve `null` si el contenido no
  /// sirve, para que un juego mal guardado no rompa Aula. El panel lee también
  /// borradores a medias con [validar] a `false`.
  static JuegoAula? desdeFila(
    Map<String, dynamic> fila, {
    bool validar = true,
  }) {
    try {
      final plantilla = PlantillaAula.desdeId(fila['plantilla'] as String?);
      if (plantilla == null) return null;
      final contenido = fila['contenido'] as Map<String, dynamic>;
      final tema = (fila['tema'] as Map<String, dynamic>?) ?? const {};
      final juego = JuegoAula(
        id: fila['id'] as String,
        titulo: (fila['titulo'] as String).trim(),
        plantilla: plantilla,
        version: fila['version'] as int,
        cursos: [for (final c in fila['cursos'] as List<dynamic>) c as int]
          ..sort(),
        preguntas: [
          for (final p in contenido['preguntas'] as List<dynamic>)
            _pregunta(plantilla, p as Map<String, dynamic>),
        ],
        intro: (contenido['intro'] as String?)?.trim() ?? '',
        fondo: ImagenAula.desdeJson(tema['fondo']),
        mostrarNatu: tema['natu'] as bool? ?? true,
      );
      return !validar || juego.errores().isEmpty ? juego : null;
    } catch (_) {
      return null;
    }
  }

  static PreguntaAula _pregunta(
    PlantillaAula plantilla,
    Map<String, dynamic> json,
  ) {
    final enunciado = (json['enunciado'] as String).trim();
    final imagen = ImagenAula.desdeJson(json['imagen']);
    final explicacion = (json['explicacion'] as String?)?.trim() ?? '';
    final pista = (json['pista'] as String?)?.trim() ?? '';
    switch (plantilla) {
      case PlantillaAula.verdaderoFalso:
        return PreguntaAula(
          enunciado: enunciado,
          imagen: imagen,
          opciones: const [
            OpcionAula(texto: 'Verdadero'),
            OpcionAula(texto: 'Falso'),
          ],
          correcta: json['correcta'] as bool ? 0 : 1,
          explicacion: explicacion,
          pista: pista,
        );
      case PlantillaAula.opcionMultiple:
        return PreguntaAula(
          enunciado: enunciado,
          imagen: imagen,
          opciones: [
            for (final o in json['opciones'] as List<dynamic>)
              OpcionAula(
                texto: ((o as Map<String, dynamic>)['texto'] as String).trim(),
                imagen: ImagenAula.desdeJson(o['imagen']),
              ),
          ],
          correcta: json['correcta'] as int,
          explicacion: explicacion,
          pista: pista,
        );
    }
  }

  JuegoAula copiar({
    String? id,
    String? titulo,
    PlantillaAula? plantilla,
    int? version,
    List<int>? cursos,
    List<PreguntaAula>? preguntas,
    ImagenAula? Function()? fondo,
    bool? mostrarNatu,
    String? intro,
  }) => JuegoAula(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    plantilla: plantilla ?? this.plantilla,
    version: version ?? this.version,
    cursos: cursos ?? this.cursos,
    preguntas: preguntas ?? this.preguntas,
    fondo: fondo != null ? fondo() : this.fondo,
    mostrarNatu: mostrarNatu ?? this.mostrarNatu,
    intro: intro ?? this.intro,
  );

  final String id;
  final String titulo;
  final PlantillaAula plantilla;
  final int version;
  final List<int> cursos;
  final List<PreguntaAula> preguntas;
  final ImagenAula? fondo;
  final bool mostrarNatu;
  final String intro;

  static const maxPreguntas = 30;
  static const minOpciones = 2;
  static const maxOpciones = 4;

  /// Problemas que impiden publicarlo, explicados para el profesor.
  List<String> errores() {
    final lista = <String>[];
    if (titulo.isEmpty) lista.add('Ponle un título al juego.');
    if (titulo.length > 120) lista.add('El título es demasiado largo.');
    if (cursos.isEmpty) lista.add('Elige al menos un curso.');
    if (cursos.any((c) => c < 1 || c > 6)) {
      lista.add('Los cursos van de 1º a 6º.');
    }
    if (preguntas.isEmpty) lista.add('Añade al menos una pregunta.');
    if (preguntas.length > maxPreguntas) {
      lista.add('Como mucho $maxPreguntas preguntas por juego.');
    }
    for (var i = 0; i < preguntas.length; i++) {
      final p = preguntas[i];
      final n = i + 1;
      if (p.enunciado.isEmpty && p.imagen == null) {
        lista.add('La pregunta $n no tiene texto ni imagen.');
      }
      if (p.opciones.length < minOpciones || p.opciones.length > maxOpciones) {
        lista.add('La pregunta $n necesita entre 2 y 4 respuestas.');
      }
      if (p.opciones.any((o) => o.texto.isEmpty && o.imagen == null)) {
        lista.add('Hay una respuesta vacía en la pregunta $n.');
      }
      if (p.correcta < 0 || p.correcta >= p.opciones.length) {
        lista.add('Marca la respuesta correcta de la pregunta $n.');
      }
      final textos = p.opciones
          .where((o) => o.imagen == null)
          .map((o) => o.texto.toLowerCase());
      if (textos.toSet().length != textos.length) {
        lista.add('La pregunta $n tiene respuestas repetidas.');
      }
    }
    return lista;
  }

  /// El contenido tal como se guarda en la columna `contenido`.
  Map<String, dynamic> contenidoJson() => {
    if (intro.isNotEmpty) 'intro': intro,
    'preguntas': [
      for (final p in preguntas)
        {
          'enunciado': p.enunciado,
          if (p.imagen != null) 'imagen': p.imagen!.toJson(),
          if (plantilla == PlantillaAula.verdaderoFalso)
            'correcta': p.correcta == 0
          else ...{
            'opciones': [for (final o in p.opciones) o.toJson()],
            'correcta': p.correcta,
          },
          if (p.explicacion.isNotEmpty) 'explicacion': p.explicacion,
          if (p.pista.isNotEmpty) 'pista': p.pista,
        },
    ],
  };

  Map<String, dynamic> temaJson() => {
    if (fondo != null) 'fondo': fondo!.toJson(),
    'natu': mostrarNatu,
  };

  /// Fila completa, también para la caché local de Aula.
  Map<String, dynamic> toFila() => {
    'id': id,
    'titulo': titulo,
    'plantilla': plantilla.id,
    'version': version,
    'cursos': cursos,
    'contenido': contenidoJson(),
    'tema': temaJson(),
  };
}
