import 'dart:math';

import 'package:naturalmente/modelo/actividad.dart';

class BarajadorOpciones {
  static final Random _azar = Random();
  static int? _ultimaPosCorrecta;
  static final Map<String, String> _ultimasFirmas = {};

  static void reiniciarMemoria() {
    _ultimaPosCorrecta = null;
    _ultimasFirmas.clear();
  }

  static List<T> barajarConRespuesta<T>({
    required String clave,
    required List<T> opciones,
    required String Function(T) idDe,
    required String respuestaCorrecta,
    Random? azar,
  }) {
    if (opciones.length <= 1) return List<T>.from(opciones);
    final generador = azar ?? _azar;
    final ultimaFirma = _ultimasFirmas[clave];
    List<T> mejor = List<T>.from(opciones)..shuffle(generador);

    for (var intento = 0; intento < 32; intento++) {
      final candidata = List<T>.from(opciones)..shuffle(generador);
      final pos = candidata.indexWhere((o) => idDe(o) == respuestaCorrecta);
      final firma = candidata.map(idDe).join(',');
      final cambiaPosicion =
          _ultimaPosCorrecta == null || pos != _ultimaPosCorrecta;
      final cambiaFirma = ultimaFirma == null || firma != ultimaFirma;
      if (cambiaPosicion && cambiaFirma) {
        mejor = candidata;
        break;
      }
      if (cambiaPosicion) {
        mejor = candidata;
      }
    }

    final posElegida = mejor.indexWhere((o) => idDe(o) == respuestaCorrecta);
    if (posElegida >= 0) {
      _ultimaPosCorrecta = posElegida;
    }
    _ultimasFirmas[clave] = mejor.map(idDe).join(',');
    return mejor;
  }

  static List<Opcion> barajarPasos({
    required String clave,
    required List<Opcion> pasos,
    required List<String> ordenCorrecto,
    Random? azar,
  }) {
    if (pasos.length <= 1) return List<Opcion>.from(pasos);
    final generador = azar ?? _azar;
    final firmaCorrecta = ordenCorrecto.join(',');
    final ultimaFirma = _ultimasFirmas[clave];
    List<Opcion> mejor = List<Opcion>.from(pasos)..shuffle(generador);

    for (var intento = 0; intento < 32; intento++) {
      final candidata = List<Opcion>.from(pasos)..shuffle(generador);
      final firma = candidata.map((p) => p.id).join(',');
      final noEstaResuelto = firma != firmaCorrecta;
      final cambiaFirma = ultimaFirma == null || firma != ultimaFirma;
      if (noEstaResuelto && cambiaFirma) {
        mejor = candidata;
        break;
      }
      if (noEstaResuelto) {
        mejor = candidata;
      }
    }

    _ultimasFirmas[clave] = mejor.map((p) => p.id).join(',');
    return mejor;
  }

  static List<String> barajarIds({
    required String clave,
    required List<String> ids,
    Random? azar,
  }) {
    if (ids.length <= 1) return List<String>.from(ids);
    final generador = azar ?? _azar;
    final firmaOriginal = ids.join(',');
    final ultimaFirma = _ultimasFirmas[clave];
    List<String> mejor = List<String>.from(ids)..shuffle(generador);

    for (var intento = 0; intento < 32; intento++) {
      final candidata = List<String>.from(ids)..shuffle(generador);
      final firma = candidata.join(',');
      final cambiaFirma = ultimaFirma == null || firma != ultimaFirma;
      if (cambiaFirma && firma != firmaOriginal) {
        mejor = candidata;
        break;
      }
      if (cambiaFirma) {
        mejor = candidata;
      }
    }

    _ultimasFirmas[clave] = mejor.join(',');
    return mejor;
  }
}

class Resultado {
  const Resultado({
    required this.acierto,
    required this.frase,
    required this.estado,
    this.gesto = 'pensando',
  });

  final bool acierto;
  final String frase;
  final String estado;
  final String gesto;
}

Resultado resolverLugar({
  required Reto reto,
  required String eleccion,
  required int intento,
}) {
  final frase = reto.frases[eleccion];
  if (frase == null) {
    throw ArgumentError('Esa opción no está en el reto ${reto.id}.');
  }
  final acierto = eleccion == reto.respuesta;
  if (!acierto && intento >= 2) {
    return Resultado(
      acierto: false,
      frase: '$frase ${reto.pista}',
      estado: eleccion,
      gesto: 'pista',
    );
  }
  return Resultado(
    acierto: acierto,
    frase: frase,
    estado: eleccion,
    gesto: acierto ? 'feliz' : 'pensando',
  );
}

Resultado resolverAdaptacion({
  required Reto reto,
  required String eleccion,
}) {
  final adaptacion = reto.adaptacion;
  if (adaptacion == null) {
    throw ArgumentError('El reto ${reto.id} no tiene pregunta de adaptación.');
  }
  return resolverPreguntaExtra(pregunta: adaptacion, eleccion: eleccion);
}

Resultado resolverPreguntaExtra({
  required PreguntaExtra pregunta,
  required String eleccion,
}) {
  final frase = pregunta.frases[eleccion];
  if (frase == null) {
    throw ArgumentError('Esa opción no existe en la pregunta extra.');
  }
  final acierto = eleccion == pregunta.respuesta;
  return Resultado(
    acierto: acierto,
    frase: frase,
    estado: eleccion,
    gesto: acierto ? 'feliz' : 'pista',
  );
}

Resultado resolverControles({
  required Actividad actividad,
  required Map<String, String> valores,
}) {
  final agua = valores['agua'];
  final luz = valores['luz'];
  final suelo = valores['suelo'];
  final estado = _estadoSemilla(agua, luz, suelo);
  final frase = actividad.frases[estado];
  if (frase == null) {
    throw ArgumentError('A ${actividad.id} le falta la frase de $estado.');
  }
  final acierto = estado == 'brote';
  final gesto = switch (estado) {
    'brote' => 'feliz',
    'falta' => 'hola',
    _ => 'pista',
  };
  return Resultado(
    acierto: acierto,
    frase: frase,
    estado: estado,
    gesto: gesto,
  );
}

String _estadoSemilla(String? agua, String? luz, String? suelo) {
  if (agua == null || luz == null || suelo == null) return 'falta';
  if (agua == 'mucha') return 'ahogada';
  if (agua == 'poca') return 'seca';
  if (suelo == 'piedras') return 'sinAgarre';
  if (suelo == 'arena') return 'sedienta';
  if (luz == 'poca') return 'palida';
  return 'brote';
}

Resultado resolverOrden({
  required Actividad actividad,
  required List<String> orden,
}) {
  final respuesta = actividad.respuesta;
  final mismoContenido = orden.length == respuesta.length &&
      orden.toSet().length == respuesta.length &&
      orden.toSet().containsAll(respuesta);
  if (!mismoContenido) {
    final frase = actividad.frases['incompleto'];
    if (frase == null) {
      throw ArgumentError('A ${actividad.id} le falta la frase incompleto.');
    }
    return Resultado(
      acierto: false,
      frase: frase,
      estado: 'incompleto',
      gesto: 'pensando',
    );
  }
  for (var i = 0; i < respuesta.length; i++) {
    if (orden[i] != respuesta[i]) {
      final frase = actividad.frases['mal$i'];
      if (frase == null) {
        throw ArgumentError('A ${actividad.id} le falta la frase mal$i.');
      }
      return Resultado(
        acierto: false,
        frase: frase,
        estado: 'mal',
        gesto: 'pista',
      );
    }
  }
  final fraseBien = actividad.frases['bien'];
  if (fraseBien == null) {
    throw ArgumentError('A ${actividad.id} le falta la frase bien.');
  }
  return Resultado(
    acierto: true,
    frase: fraseBien,
    estado: 'bien',
    gesto: 'feliz',
  );
}
