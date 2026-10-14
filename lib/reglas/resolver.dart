import 'package:naturalmente/modelo/actividad.dart';

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
