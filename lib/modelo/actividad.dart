import 'package:naturalmente/modelo/digestion.dart';
import 'package:naturalmente/modelo/herbario.dart';
import 'package:naturalmente/modelo/nacimiento.dart';

class Opcion {
  const Opcion({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory Opcion.desdeMapa(Map<String, dynamic> mapa) {
    return Opcion(id: mapa['id'] as String, nombre: mapa['nombre'] as String);
  }
}

class PreguntaExtra {
  const PreguntaExtra({
    required this.enunciado,
    required this.opciones,
    required this.respuesta,
    required this.frases,
  });

  final String enunciado;
  final List<Opcion> opciones;
  final String respuesta;
  final Map<String, String> frases;

  factory PreguntaExtra.desdeMapa(Map<String, dynamic> mapa) {
    final pregunta = PreguntaExtra(
      enunciado: mapa['enunciado'] as String? ?? '',
      opciones: _opciones(mapa['opciones']),
      respuesta: mapa['respuesta'] as String? ?? '',
      frases: _frases(mapa['frases']),
    );
    pregunta.comprobar();
    return pregunta;
  }

  void comprobar([String contexto = '']) {
    if (enunciado.isEmpty) {
      throw ArgumentError('La pregunta extra $contexto no tiene enunciado.');
    }
    if (opciones.length < 2) {
      throw ArgumentError('La pregunta extra $contexto necesita opciones.');
    }
    final ids = opciones.map((o) => o.id).toSet();
    if (!ids.contains(respuesta)) {
      throw ArgumentError(
        'La pregunta extra $contexto tiene una respuesta inválida.',
      );
    }
    for (final id in ids) {
      if ((frases[id] ?? '').isEmpty) {
        throw ArgumentError(
          'A la pregunta extra $contexto le falta la frase de $id.',
        );
      }
    }
  }
}

class Reto {
  const Reto({
    required this.id,
    required this.nombre,
    required this.pregunta,
    required this.respuesta,
    required this.pista,
    required this.frases,
    this.curiosidad = '',
    this.adaptacion,
  });

  final String id;
  final String nombre;
  final String pregunta;
  final String respuesta;
  final String pista;
  final Map<String, String> frases;
  final String curiosidad;
  final PreguntaExtra? adaptacion;

  factory Reto.desdeMapa(Map<String, dynamic> mapa) {
    return Reto(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      pregunta: mapa['pregunta'] as String,
      respuesta: mapa['respuesta'] as String,
      pista: mapa['pista'] as String,
      frases: _frases(mapa['frases']),
      curiosidad: mapa['curiosidad'] as String? ?? '',
      adaptacion: mapa['adaptacion'] == null
          ? null
          : PreguntaExtra.desdeMapa(
              mapa['adaptacion'] as Map<String, dynamic>,
            ),
    );
  }
}

class NivelLugar {
  const NivelLugar({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.resumen,
    this.intro = '',
    this.curiosidad = '',
    this.opciones = const [],
    this.retos = const [],
    this.controles = const [],
    this.pasos = const [],
    this.respuesta = const [],
    this.frases = const {},
    this.preguntaAdaptacion = false,
    this.preguntaFinal,
  });

  final String id;
  final String nombre;
  final String curso;
  final String resumen;
  final String intro;
  final String curiosidad;
  final List<Opcion> opciones;
  final List<Reto> retos;
  final List<Control> controles;
  final List<Opcion> pasos;
  final List<String> respuesta;
  final Map<String, String> frases;
  final bool preguntaAdaptacion;
  final PreguntaExtra? preguntaFinal;

  factory NivelLugar.desdeMapa(Map<String, dynamic> mapa) {
    return NivelLugar(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      curso: mapa['curso'] as String,
      resumen: mapa['resumen'] as String? ?? '',
      intro: mapa['intro'] as String? ?? '',
      curiosidad: mapa['curiosidad'] as String? ?? '',
      opciones: _opciones(mapa['opciones']),
      retos: (mapa['retos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Reto.desdeMapa)
          .toList(),
      controles: (mapa['controles'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Control.desdeMapa)
          .toList(),
      pasos: _opciones(mapa['pasos']),
      respuesta: (mapa['respuesta'] as List? ?? []).cast<String>(),
      frases: _frases(mapa['frases']),
      preguntaAdaptacion: mapa['preguntaAdaptacion'] as bool? ?? false,
      preguntaFinal: mapa['preguntaFinal'] == null
          ? null
          : PreguntaExtra.desdeMapa(
              mapa['preguntaFinal'] as Map<String, dynamic>,
            ),
    );
  }
}

class Control {
  const Control({
    required this.id,
    required this.nombre,
    required this.opciones,
  });

  final String id;
  final String nombre;
  final List<Opcion> opciones;

  factory Control.desdeMapa(Map<String, dynamic> mapa) {
    return Control(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      opciones: _opciones(mapa['opciones']),
    );
  }
}

class Actividad {
  const Actividad({
    required this.id,
    required this.zona,
    required this.tipo,
    required this.titulo,
    required this.curso,
    required this.medalla,
    required this.quien,
    required this.intro,
    required this.opciones,
    required this.retos,
    required this.controles,
    required this.frases,
    required this.pasos,
    required this.respuesta,
    required this.boton,
    required this.sujeto,
    this.nivelesLugar = const [],
    this.herbario,
    this.nacimiento,
    this.viaje,
  });

  final String id;
  final String zona;
  final String tipo;
  final String titulo;
  final String curso;
  final bool medalla;
  final String quien;
  final String intro;
  final List<Opcion> opciones;
  final List<Reto> retos;
  final List<Control> controles;
  final Map<String, String> frases;
  final List<Opcion> pasos;
  final List<String> respuesta;
  final String boton;
  final String sujeto;
  final List<NivelLugar> nivelesLugar;
  final Herbario? herbario;
  final Nacimiento? nacimiento;
  final Viaje? viaje;

  bool get tieneFrases {
    if (tipo == 'herbario') return herbario != null;
    if (tipo == 'nacimiento') return nacimiento != null;
    if (tipo == 'viaje') return viaje != null;
    if (tipo == 'lugar') {
      return retos.isNotEmpty && retos.every((reto) => reto.frases.isNotEmpty);
    }
    return frases.isNotEmpty;
  }

  factory Actividad.desdeMapa(Map<String, dynamic> mapa) {
    final tipo = mapa['tipo'] as String;
    final actividad = Actividad(
      id: mapa['id'] as String,
      zona: mapa['zona'] as String,
      tipo: tipo,
      titulo: mapa['titulo'] as String,
      curso: mapa['curso'] as String,
      medalla: mapa['medalla'] as bool? ?? false,
      quien: mapa['quien'] as String? ?? 'Natu dice',
      intro: mapa['intro'] as String? ?? '',
      opciones: _opciones(mapa['opciones']),
      retos: (mapa['retos'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Reto.desdeMapa)
          .toList(),
      controles: (mapa['controles'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(Control.desdeMapa)
          .toList(),
      frases: _frases(mapa['frases']),
      pasos: _opciones(mapa['pasos']),
      respuesta: (mapa['respuesta'] as List? ?? []).cast<String>(),
      boton: mapa['boton'] as String? ?? 'Comprobar',
      sujeto: mapa['sujeto'] as String? ?? '',
      nivelesLugar: (mapa['niveles'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .map(NivelLugar.desdeMapa)
          .toList(),
      herbario: mapa['herbario'] == null
          ? null
          : Herbario.desdeMapa(mapa['herbario'] as Map<String, dynamic>),
      nacimiento: mapa['nacimiento'] == null
          ? null
          : Nacimiento.desdeMapa(mapa['nacimiento'] as Map<String, dynamic>),
      viaje: mapa['viaje'] == null
          ? null
          : Viaje.desdeMapa(mapa['viaje'] as Map<String, dynamic>),
    );
    actividad._comprobar();
    return actividad;
  }

  void _comprobar() {
    if (curso.isEmpty) {
      throw ArgumentError('La actividad $id no tiene curso.');
    }
    if (!const [
      'lugar',
      'controles',
      'orden',
      'herbario',
      'nacimiento',
      'viaje',
    ].contains(tipo)) {
      throw ArgumentError('La actividad $id tiene un tipo desconocido: $tipo.');
    }
    if (!tieneFrases) {
      throw ArgumentError('La actividad $id no tiene frases.');
    }
    if (tipo == 'lugar') {
      _comprobarRetosLugar(opciones, retos);
      for (final nivel in nivelesLugar) {
        if (nivel.opciones.isEmpty || nivel.retos.isEmpty) {
          throw ArgumentError('El nivel ${nivel.id} de $id está incompleto.');
        }
        _comprobarRetosLugar(nivel.opciones, nivel.retos);
        if (nivel.preguntaAdaptacion) {
          for (final reto in nivel.retos) {
            if (reto.adaptacion == null) {
              throw ArgumentError(
                'Al reto ${reto.id} del nivel ${nivel.id} le falta la pregunta de adaptación.',
              );
            }
          }
        }
      }
    }
    if (tipo == 'controles') {
      for (final estado in const [
        'falta',
        'ahogada',
        'seca',
        'sinAgarre',
        'sedienta',
        'palida',
        'brote',
      ]) {
        if (!frases.containsKey(estado)) {
          throw ArgumentError('A $id le falta la frase de $estado.');
        }
      }
    }
    if (tipo == 'orden') {
      if (!frases.containsKey('incompleto') || !frases.containsKey('bien')) {
        throw ArgumentError('A $id le faltan frases del orden.');
      }
      for (var i = 0; i < respuesta.length - 1; i++) {
        if (!frases.containsKey('mal$i')) {
          throw ArgumentError('A $id le falta la frase mal$i.');
        }
      }
      for (final nivel in nivelesLugar) {
        if (nivel.pasos.isNotEmpty || nivel.respuesta.isNotEmpty) {
          if (nivel.pasos.length != nivel.respuesta.length) {
            throw ArgumentError(
              'El nivel ${nivel.id} de $id tiene distinto número de pasos y respuesta.',
            );
          }
          final frasesNivel = {...frases, ...nivel.frases};
          if (!frasesNivel.containsKey('incompleto') ||
              !frasesNivel.containsKey('bien')) {
            throw ArgumentError(
              'Al nivel ${nivel.id} de $id le faltan frases del orden.',
            );
          }
          for (var i = 0; i < nivel.respuesta.length - 1; i++) {
            if (!frasesNivel.containsKey('mal$i')) {
              throw ArgumentError(
                'Al nivel ${nivel.id} de $id le falta la frase mal$i.',
              );
            }
          }
        }
      }
    }
  }

  void _comprobarRetosLugar(List<Opcion> sitios, List<Reto> listaRetos) {
    final ids = sitios.map((opcion) => opcion.id).toSet();
    for (final reto in listaRetos) {
      if (!ids.contains(reto.respuesta)) {
        throw ArgumentError(
          'El reto ${reto.id} apunta a un sitio que no existe.',
        );
      }
      for (final id in ids) {
        if (!reto.frases.containsKey(id)) {
          throw ArgumentError('Al reto ${reto.id} le falta la frase de $id.');
        }
      }
    }
  }
}

List<Opcion> _opciones(Object? valor) {
  if (valor is! List) return const [];
  return valor.cast<Map<String, dynamic>>().map(Opcion.desdeMapa).toList();
}

Map<String, String> _frases(Object? valor) {
  if (valor is! Map) return const {};
  return valor.map(
    (clave, frase) => MapEntry(clave as String, frase as String),
  );
}
