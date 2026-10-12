class Opcion {
  const Opcion({required this.id, required this.nombre});

  final String id;
  final String nombre;

  factory Opcion.desdeMapa(Map<String, dynamic> mapa) {
    return Opcion(id: mapa['id'] as String, nombre: mapa['nombre'] as String);
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
  });

  final String id;
  final String nombre;
  final String pregunta;
  final String respuesta;
  final String pista;
  final Map<String, String> frases;

  factory Reto.desdeMapa(Map<String, dynamic> mapa) {
    return Reto(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      pregunta: mapa['pregunta'] as String,
      respuesta: mapa['respuesta'] as String,
      pista: mapa['pista'] as String,
      frases: _frases(mapa['frases']),
    );
  }
}

class Control {
  const Control({required this.id, required this.nombre, required this.opciones});

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

  bool get tieneFrases {
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
      quien: mapa['quien'] as String? ?? 'Dice',
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
    );
    actividad._comprobar();
    return actividad;
  }

  void _comprobar() {
    if (curso.isEmpty) {
      throw ArgumentError('La actividad $id no tiene curso.');
    }
    if (tipo != 'lugar' && tipo != 'controles' && tipo != 'orden') {
      throw ArgumentError('La actividad $id tiene un tipo desconocido: $tipo.');
    }
    if (!tieneFrases) {
      throw ArgumentError('La actividad $id no tiene frases.');
    }
    if (tipo == 'lugar') {
      final ids = opciones.map((opcion) => opcion.id).toSet();
      for (final reto in retos) {
        if (!ids.contains(reto.respuesta)) {
          throw ArgumentError('El reto ${reto.id} apunta a un sitio que no existe.');
        }
        for (final id in ids) {
          if (!reto.frases.containsKey(id)) {
            throw ArgumentError('Al reto ${reto.id} le falta la frase de $id.');
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
    }
  }
}

List<Opcion> _opciones(Object? valor) {
  if (valor is! List) return const [];
  return valor.cast<Map<String, dynamic>>().map(Opcion.desdeMapa).toList();
}

Map<String, String> _frases(Object? valor) {
  if (valor is! Map) return const {};
  return valor.map((clave, frase) => MapEntry(clave as String, frase as String));
}
