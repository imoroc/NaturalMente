import 'package:flutter/foundation.dart';

/// Cómo se guardan los retos de un juego. Los juegos nuevos son libres:
/// cada reto puede ser de un tipo distinto. Los antiguos eran de un solo tipo.
enum PlantillaAula {
  opcionMultiple('opcion_multiple', 'Test de opción múltiple'),
  verdaderoFalso('verdadero_falso', 'Verdadero o falso'),
  libre('libre', 'Juego');

  const PlantillaAula(this.id, this.nombre);
  final String id;
  final String nombre;

  /// Tipo de los retos guardados sin `tipo`.
  TipoReto get tipoPorDefecto => switch (this) {
    PlantillaAula.verdaderoFalso => TipoReto.verdaderoFalso,
    _ => TipoReto.opcionMultiple,
  };

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
    final escena = json['escena'];
    if (escena is String && escenasAula.containsKey(escena)) {
      return ImagenEscena(escena);
    }
    final galeria = json['galeria'];
    if (galeria is String && galeriaAula.containsKey(galeria)) {
      return ImagenGaleria(galeria);
    }
    final url = json['url'];
    if (url is String && _direccionValida(url)) return ImagenSubida(url);
    return null;
  }

  /// Solo https, salvo el Supabase local de desarrollo (ordenador o emulador).
  static bool _direccionValida(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasAuthority) return false;
    if (uri.scheme == 'https') return true;
    return uri.scheme == 'http' &&
        const {'127.0.0.1', 'localhost', '10.0.2.2'}.contains(uri.host);
  }

  Map<String, dynamic> toJson();
}

/// Escena dibujada con código: se adapta a cualquier pantalla y no gasta datos.
class ImagenEscena extends ImagenAula {
  const ImagenEscena(this.id);
  final String id;
  @override
  Map<String, dynamic> toJson() => {'escena': id};
  @override
  bool operator ==(Object other) => other is ImagenEscena && other.id == id;
  @override
  int get hashCode => id.hashCode;
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

/// Fondos dibujados con código para los juegos de Aula. No ocupan espacio,
/// no gastan datos y se adaptan a cualquier tamaño y proporción de pantalla.
/// id → nombre que ve el profe.
const escenasAula = <String, String>{
  'pradera': 'Pradera',
  'bosque': 'Bosque',
  'selva': 'Selva',
  'fondo-marino': 'Fondo del mar',
  'playa': 'Playa',
  'desierto': 'Desierto',
  'polar': 'Polo',
  'montana': 'Montaña y lago',
  'otono': 'Otoño',
  'granja': 'Granja',
  'jardin': 'Jardín',
  'noche': 'Noche en el campo',
};

/// Fondos e ilustraciones que ya trae la app: id → (asset, nombre).
const galeriaAula = <String, (String, String)>{
  'paisaje-reserva': (
    'assets/mundos/paisaje-reserva.webp',
    'Paisaje de animales',
  ),
  'paisaje-invernadero': (
    'assets/mundos/paisaje-invernadero.webp',
    'Paisaje de plantas',
  ),
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

/// Una respuesta, un elemento, un paso o una carta: texto, imagen o ambos.
@immutable
class OpcionAula {
  const OpcionAula({required this.texto, this.imagen});

  static OpcionAula desdeJson(Object? json) {
    if (json is String) return OpcionAula(texto: json.trim());
    final mapa = json as Map<String, dynamic>;
    return OpcionAula(
      texto: (mapa['texto'] as String? ?? '').trim(),
      imagen: ImagenAula.desdeJson(mapa['imagen']),
    );
  }

  final String texto;
  final ImagenAula? imagen;

  bool get vacia => texto.isEmpty && imagen == null;

  Map<String, dynamic> toJson() => {
    'texto': texto,
    if (imagen != null) 'imagen': imagen!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is OpcionAula && other.texto == texto && other.imagen == imagen;
  @override
  int get hashCode => Object.hash(texto, imagen);
}

/// Los tipos de reto que el profesor puede encadenar en un juego.
enum TipoReto {
  opcionMultiple(
    'opcion_multiple',
    'Elegir la respuesta',
    'Una pregunta con 2 a 4 respuestas, con texto o con imágenes.',
  ),
  verdaderoFalso(
    'verdadero_falso',
    'Verdadero o falso',
    'Una frase y el niño decide si es verdad o mentira.',
  ),
  clasificar(
    'clasificar',
    'Clasificar en grupos',
    'Cada cosa a su grupo: vertebrados e invertebrados, frutas y verduras...',
  ),
  ordenar(
    'ordenar',
    'Ordenar',
    'Poner pasos o cosas en orden: el ciclo de la rana, de menor a mayor...',
  ),
  parejas(
    'parejas',
    'Unir parejas',
    'Unir cada cosa con su pareja: animal y lo que come, órgano y su función...',
  ),
  huecos(
    'huecos',
    'Completar la frase',
    'Una frase con huecos y unas palabras para rellenarlos.',
  ),
  buscar(
    'buscar',
    'Tocar en la imagen',
    'Una foto o dibujo y el niño toca el sitio correcto: el corazón, la raíz...',
  ),
  numero(
    'numero',
    'Adivinar el número',
    'La respuesta es un número: patas de una araña, huesos de la mano...',
  ),
  palabra(
    'palabra',
    'Formar la palabra',
    'Letras desordenadas para escribir la respuesta.',
  ),
  lectura(
    'lectura',
    'Tarjeta para leer',
    'Un texto o una imagen para aprender algo antes de las preguntas.',
  );

  const TipoReto(this.id, this.nombre, this.descripcion);
  final String id;
  final String nombre;
  final String descripcion;

  static TipoReto? desdeId(String? id) =>
      values.where((t) => t.id == id).firstOrNull;
}

/// Un paso de un juego de Aula.
@immutable
sealed class RetoAula {
  const RetoAula({
    required this.enunciado,
    this.imagen,
    this.pista = '',
    this.explicacion = '',
  });

  /// Lee un reto. Sin `tipo`, el de la plantilla (juegos anteriores).
  static RetoAula desdeJson(Map<String, dynamic> json, TipoReto porDefecto) {
    final tipo = TipoReto.desdeId(json['tipo'] as String?) ?? porDefecto;
    final enunciado = (json['enunciado'] as String? ?? '').trim();
    final imagen = ImagenAula.desdeJson(json['imagen']);
    final pista = (json['pista'] as String? ?? '').trim();
    final explicacion = (json['explicacion'] as String? ?? '').trim();
    List<OpcionAula> lista(String clave) => [
      for (final o in (json[clave] as List<dynamic>? ?? const []))
        OpcionAula.desdeJson(o),
    ];
    return switch (tipo) {
      TipoReto.verdaderoFalso => PreguntaAula(
        tipo: tipo,
        enunciado: enunciado,
        imagen: imagen,
        opciones: const [
          OpcionAula(texto: 'Verdadero'),
          OpcionAula(texto: 'Falso'),
        ],
        correcta: switch (json['correcta']) {
          true => 0,
          false => 1,
          _ => -1,
        },
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.opcionMultiple => PreguntaAula(
        enunciado: enunciado,
        imagen: imagen,
        opciones: lista('opciones'),
        correcta: json['correcta'] as int? ?? -1,
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.clasificar => ClasificarAula(
        enunciado: enunciado,
        imagen: imagen,
        grupos: lista('grupos'),
        elementos: [
          for (final e in (json['elementos'] as List<dynamic>? ?? const []))
            ElementoGrupo(
              OpcionAula.desdeJson(e),
              (e as Map<String, dynamic>)['grupo'] as int? ?? -1,
            ),
        ],
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.ordenar => OrdenarAula(
        enunciado: enunciado,
        imagen: imagen,
        pasos: lista('pasos'),
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.parejas => ParejasAula(
        enunciado: enunciado,
        imagen: imagen,
        parejas: [
          for (final p in (json['parejas'] as List<dynamic>? ?? const []))
            (
              OpcionAula.desdeJson((p as Map<String, dynamic>)['a']),
              OpcionAula.desdeJson(p['b']),
            ),
        ],
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.huecos => HuecosAula(
        enunciado: enunciado,
        imagen: imagen,
        frase: (json['frase'] as String? ?? '').trim(),
        distractores: [
          for (final d in (json['distractores'] as List<dynamic>? ?? const []))
            (d as String).trim(),
        ],
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.buscar => BuscarAula(
        enunciado: enunciado,
        imagen: imagen,
        zonas: [
          for (final z in (json['zonas'] as List<dynamic>? ?? const []))
            ZonaAula.desdeJson(z as Map<String, dynamic>),
        ],
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.numero => NumeroAula(
        enunciado: enunciado,
        imagen: imagen,
        respuesta: json['respuesta'] as int?,
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.palabra => PalabraAula(
        enunciado: enunciado,
        imagen: imagen,
        respuesta: (json['respuesta'] as String? ?? '').trim(),
        pista: pista,
        explicacion: explicacion,
      ),
      TipoReto.lectura => LecturaAula(
        enunciado: enunciado,
        imagen: imagen,
        texto: (json['texto'] as String? ?? '').trim(),
      ),
    };
  }

  TipoReto get tipo;
  final String enunciado;
  final ImagenAula? imagen;

  /// Se enseña tras un fallo, sin dar la respuesta.
  final String pista;

  /// Se enseña al acertar, antes de pasar al siguiente reto.
  final String explicacion;

  /// Las tarjetas para leer no se puntúan.
  bool get evaluable => true;

  /// Problemas que impiden publicarlo; [n] es su número en el juego.
  List<String> errores(int n);

  /// Todas las imágenes del reto (para precargarlas o limpiarlas).
  Iterable<ImagenAula> get imagenes => [?imagen];

  Map<String, dynamic> camposJson();

  Map<String, dynamic> toJson({bool conTipo = true}) => {
    if (conTipo) 'tipo': tipo.id,
    if (enunciado.isNotEmpty) 'enunciado': enunciado,
    if (imagen != null) 'imagen': imagen!.toJson(),
    ...camposJson(),
    if (pista.isNotEmpty) 'pista': pista,
    if (explicacion.isNotEmpty) 'explicacion': explicacion,
  };

  static Iterable<ImagenAula> _de(Iterable<OpcionAula> opciones) => [
    for (final o in opciones) ?o.imagen,
  ];

  static List<String> _repetidas(int n, Iterable<OpcionAula> opciones, String que) {
    final textos = [
      for (final o in opciones)
        if (o.imagen == null && o.texto.isNotEmpty) o.texto.toLowerCase(),
    ];
    return textos.toSet().length == textos.length
        ? const []
        : ['La pregunta $n tiene $que repetidas.'];
  }
}

/// Elegir la respuesta (2 a 4) o verdadero o falso.
class PreguntaAula extends RetoAula {
  const PreguntaAula({
    required super.enunciado,
    required this.opciones,
    required this.correcta,
    this.tipo = TipoReto.opcionMultiple,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  final TipoReto tipo;
  final List<OpcionAula> opciones;
  final int correcta;

  @override
  List<String> errores(int n) => [
    if (enunciado.isEmpty && imagen == null)
      'La pregunta $n no tiene texto ni imagen.',
    if (opciones.length < 2 || opciones.length > 4)
      'La pregunta $n necesita entre 2 y 4 respuestas.',
    ...RetoAula._repetidas(n, opciones, 'respuestas'),
    if (opciones.any((o) => o.vacia)) 'Hay una respuesta vacía en la pregunta $n.',
    if (correcta < 0 || correcta >= opciones.length)
      tipo == TipoReto.verdaderoFalso
          ? 'Elige si la frase $n es verdadera o falsa.'
          : 'Marca la respuesta correcta de la pregunta $n.',
  ];

  @override
  Iterable<ImagenAula> get imagenes => [...super.imagenes, ...RetoAula._de(opciones)];

  @override
  Map<String, dynamic> camposJson() => tipo == TipoReto.verdaderoFalso
      ? {'correcta': correcta == 0}
      : {
          'opciones': [for (final o in opciones) o.toJson()],
          'correcta': correcta,
        };

  @override
  Map<String, dynamic> toJson({bool conTipo = true}) => {
    if (conTipo) 'tipo': tipo.id,
    // Los juegos antiguos guardaban siempre el enunciado.
    'enunciado': enunciado,
    if (imagen != null) 'imagen': imagen!.toJson(),
    ...camposJson(),
    if (pista.isNotEmpty) 'pista': pista,
    if (explicacion.isNotEmpty) 'explicacion': explicacion,
  };
}

@immutable
class ElementoGrupo {
  const ElementoGrupo(this.elemento, this.grupo);
  final OpcionAula elemento;
  final int grupo;
}

/// Colocar cada elemento en su grupo.
class ClasificarAula extends RetoAula {
  const ClasificarAula({
    required super.enunciado,
    required this.grupos,
    required this.elementos,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.clasificar;
  final List<OpcionAula> grupos;
  final List<ElementoGrupo> elementos;

  @override
  List<String> errores(int n) => [
    if (grupos.length < 2 || grupos.length > 4)
      'La pregunta $n necesita entre 2 y 4 grupos.',
    if (grupos.any((g) => g.vacia)) 'Hay un grupo sin nombre en la pregunta $n.',
    ...RetoAula._repetidas(n, grupos, 'grupos'),
    if (elementos.length < 2 || elementos.length > 12)
      'La pregunta $n necesita entre 2 y 12 cosas para clasificar.',
    if (elementos.any((e) => e.elemento.vacia))
      'Hay algo vacío para clasificar en la pregunta $n.',
    if (elementos.any((e) => e.grupo < 0 || e.grupo >= grupos.length))
      'Elige el grupo de cada cosa en la pregunta $n.',
  ];

  @override
  Iterable<ImagenAula> get imagenes => [
    ...super.imagenes,
    ...RetoAula._de(grupos),
    ...RetoAula._de(elementos.map((e) => e.elemento)),
  ];

  @override
  Map<String, dynamic> camposJson() => {
    'grupos': [for (final g in grupos) g.toJson()],
    'elementos': [
      for (final e in elementos) {...e.elemento.toJson(), 'grupo': e.grupo},
    ],
  };
}

/// Poner los pasos en orden. Se guardan en el orden correcto.
class OrdenarAula extends RetoAula {
  const OrdenarAula({
    required super.enunciado,
    required this.pasos,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.ordenar;
  final List<OpcionAula> pasos;

  @override
  List<String> errores(int n) => [
    if (pasos.length < 3 || pasos.length > 8)
      'La pregunta $n necesita entre 3 y 8 pasos.',
    if (pasos.any((p) => p.vacia)) 'Hay un paso vacío en la pregunta $n.',
    ...RetoAula._repetidas(n, pasos, 'pasos'),
  ];

  @override
  Iterable<ImagenAula> get imagenes => [...super.imagenes, ...RetoAula._de(pasos)];

  @override
  Map<String, dynamic> camposJson() => {
    'pasos': [for (final p in pasos) p.toJson()],
  };
}

/// Unir cada cosa de la izquierda con su pareja.
class ParejasAula extends RetoAula {
  const ParejasAula({
    required super.enunciado,
    required this.parejas,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.parejas;
  final List<(OpcionAula, OpcionAula)> parejas;

  @override
  List<String> errores(int n) => [
    if (parejas.length < 2 || parejas.length > 8)
      'La pregunta $n necesita entre 2 y 8 parejas.',
    if (parejas.any((p) => p.$1.vacia || p.$2.vacia))
      'Hay una pareja a medias en la pregunta $n.',
    ...RetoAula._repetidas(n, parejas.map((p) => p.$1), 'cosas'),
    ...RetoAula._repetidas(n, parejas.map((p) => p.$2), 'parejas'),
  ];

  @override
  Iterable<ImagenAula> get imagenes => [
    ...super.imagenes,
    ...RetoAula._de(parejas.map((p) => p.$1)),
    ...RetoAula._de(parejas.map((p) => p.$2)),
  ];

  @override
  Map<String, dynamic> camposJson() => {
    'parejas': [
      for (final (a, b) in parejas) {'a': a.toJson(), 'b': b.toJson()},
    ],
  };
}

/// Una frase con huecos entre corchetes: «El [corazón] bombea la [sangre]».
class HuecosAula extends RetoAula {
  const HuecosAula({
    required super.enunciado,
    required this.frase,
    this.distractores = const [],
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.huecos;
  final String frase;
  final List<String> distractores;

  static final _hueco = RegExp(r'\[([^\[\]]+)\]');

  /// Trozos de la frase: texto normal o la palabra de un hueco.
  List<({String texto, bool hueco})> get partes {
    final resultado = <({String texto, bool hueco})>[];
    var desde = 0;
    for (final m in _hueco.allMatches(frase)) {
      if (m.start > desde) {
        resultado.add((texto: frase.substring(desde, m.start), hueco: false));
      }
      resultado.add((texto: m.group(1)!.trim(), hueco: true));
      desde = m.end;
    }
    if (desde < frase.length) {
      resultado.add((texto: frase.substring(desde), hueco: false));
    }
    return resultado;
  }

  List<String> get respuestas => [
    for (final p in partes)
      if (p.hueco) p.texto,
  ];

  @override
  List<String> errores(int n) => [
    if (respuestas.isEmpty)
      'Pon entre corchetes las palabras que faltan en la pregunta $n, por ejemplo: El [corazón] bombea la sangre.',
    if (respuestas.length > 6) 'Como mucho 6 huecos en la pregunta $n.',
    if (respuestas.any((r) => r.isEmpty)) 'Hay un hueco vacío en la pregunta $n.',
    if (distractores.any((d) => d.isEmpty))
      'Hay una palabra de más vacía en la pregunta $n.',
    if (distractores.length > 6) 'Como mucho 6 palabras de más en la pregunta $n.',
  ];

  @override
  Map<String, dynamic> camposJson() => {
    'frase': frase,
    if (distractores.isNotEmpty) 'distractores': distractores,
  };
}

/// Un sitio de una imagen, en proporción a su ancho y su alto (0 a 1).
@immutable
class ZonaAula {
  const ZonaAula(this.x, this.y, this.radio);

  static ZonaAula desdeJson(Map<String, dynamic> json) => ZonaAula(
    (json['x'] as num).toDouble(),
    (json['y'] as num).toDouble(),
    (json['r'] as num?)?.toDouble() ?? 0.1,
  );

  final double x, y, radio;

  bool contiene(double px, double py) {
    final dx = px - x, dy = (py - y) * 0.75;
    return dx * dx + dy * dy <= radio * radio;
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'r': radio};
}

/// Tocar el sitio correcto de una imagen (en un marco de 4:3).
class BuscarAula extends RetoAula {
  const BuscarAula({
    required super.enunciado,
    required this.zonas,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.buscar;
  final List<ZonaAula> zonas;

  @override
  List<String> errores(int n) => [
    if (imagen == null) 'Elige o sube una imagen para la pregunta $n.',
    if (enunciado.isEmpty) 'Escribe qué hay que buscar en la pregunta $n.',
    if (zonas.isEmpty || zonas.length > 5)
      'Marca en la imagen de 1 a 5 sitios correctos en la pregunta $n.',
    if (zonas.any((z) => z.x < 0 || z.x > 1 || z.y < 0 || z.y > 1))
      'Hay un sitio fuera de la imagen en la pregunta $n.',
  ];

  @override
  Map<String, dynamic> camposJson() => {
    'zonas': [for (final z in zonas) z.toJson()],
  };
}

/// La respuesta es un número.
class NumeroAula extends RetoAula {
  const NumeroAula({
    required super.enunciado,
    required this.respuesta,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.numero;
  final int? respuesta;

  @override
  List<String> errores(int n) => [
    if (enunciado.isEmpty && imagen == null)
      'La pregunta $n no tiene texto ni imagen.',
    if (respuesta == null || respuesta! < 0 || respuesta! > 9999)
      'Escribe la respuesta de la pregunta $n (un número de 0 a 9999).',
  ];

  @override
  Map<String, dynamic> camposJson() => {'respuesta': respuesta};
}

/// Formar una palabra con letras desordenadas.
class PalabraAula extends RetoAula {
  const PalabraAula({
    required super.enunciado,
    required this.respuesta,
    super.imagen,
    super.pista,
    super.explicacion,
  });

  @override
  TipoReto get tipo => TipoReto.palabra;
  final String respuesta;

  /// Letras de la respuesta en mayúsculas (los espacios no cuentan).
  List<String> get letras => [
    for (final r in respuesta.toUpperCase().runes)
      if (String.fromCharCode(r).trim().isNotEmpty) String.fromCharCode(r),
  ];

  @override
  List<String> errores(int n) => [
    if (enunciado.isEmpty && imagen == null)
      'La pregunta $n no tiene texto ni imagen.',
    if (letras.length < 2 || letras.length > 12)
      'La palabra de la pregunta $n debe tener entre 2 y 12 letras.',
  ];

  @override
  Map<String, dynamic> camposJson() => {'respuesta': respuesta};
}

/// Una tarjeta para leer: no se puntúa.
class LecturaAula extends RetoAula {
  const LecturaAula({required super.enunciado, required this.texto, super.imagen});

  @override
  TipoReto get tipo => TipoReto.lectura;
  final String texto;

  @override
  bool get evaluable => false;

  @override
  List<String> errores(int n) => [
    if (texto.isEmpty && imagen == null && enunciado.isEmpty)
      'La tarjeta $n está vacía.',
  ];

  @override
  Map<String, dynamic> camposJson() => {'texto': texto};
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
            RetoAula.desdeJson(p as Map<String, dynamic>, plantilla.tipoPorDefecto),
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

  JuegoAula copiar({
    String? id,
    String? titulo,
    PlantillaAula? plantilla,
    int? version,
    List<int>? cursos,
    List<RetoAula>? preguntas,
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

  /// Los retos del juego, en orden. Pueden ser de tipos distintos.
  final List<RetoAula> preguntas;
  final ImagenAula? fondo;
  final bool mostrarNatu;
  final String intro;

  static const maxPreguntas = 30;
  static const minOpciones = 2;
  static const maxOpciones = 4;

  /// Retos que se puntúan (las tarjetas para leer no).
  List<RetoAula> get evaluables => [
    for (final p in preguntas)
      if (p.evaluable) p,
  ];

  Iterable<ImagenAula> get imagenes => [
    ?fondo,
    for (final p in preguntas) ...p.imagenes,
  ];

  /// Problemas que impiden publicarlo, explicados para el profesor.
  List<String> errores() => [
    if (titulo.isEmpty) 'Ponle un título al juego.',
    if (titulo.length > 120) 'El título es demasiado largo.',
    if (cursos.isEmpty) 'Elige al menos un curso.',
    if (cursos.any((c) => c < 1 || c > 6)) 'Los cursos van de 1º a 6º.',
    if (preguntas.isEmpty)
      'Añade al menos una pregunta.'
    else if (evaluables.isEmpty)
      'Añade al menos una pregunta: las tarjetas para leer no cuentan.',
    if (preguntas.length > maxPreguntas)
      'Como mucho $maxPreguntas preguntas por juego.',
    for (var i = 0; i < preguntas.length; i++) ...preguntas[i].errores(i + 1),
  ];

  /// El contenido tal como se guarda en la columna `contenido`.
  Map<String, dynamic> contenidoJson() => {
    if (intro.isNotEmpty) 'intro': intro,
    'preguntas': [
      for (final p in preguntas)
        // En las plantillas antiguas el tipo se deduce de la plantilla.
        p.toJson(conTipo: p.tipo != plantilla.tipoPorDefecto || plantilla == PlantillaAula.libre),
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
