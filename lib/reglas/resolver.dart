import 'package:naturalmente/modelo/actividad.dart';

class Resultado {
  const Resultado({
    required this.acierto,
    required this.frase,
    required this.estado,
  });

  final bool acierto;
  final String frase;
  final String estado;
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
    return Resultado(acierto: false, frase: '$frase ${reto.pista}', estado: eleccion);
  }
  return Resultado(acierto: acierto, frase: frase, estado: eleccion);
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
  return Resultado(acierto: estado == 'brote', frase: frase, estado: estado);
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
    return Resultado(
      acierto: false,
      frase: actividad.frases['incompleto']!,
      estado: 'incompleto',
    );
  }
  for (var i = 0; i < respuesta.length; i++) {
    if (orden[i] != respuesta[i]) {
      return Resultado(
        acierto: false,
        frase: actividad.frases['mal$i']!,
        estado: 'mal',
      );
    }
  }
  return Resultado(acierto: true, frase: actividad.frases['bien']!, estado: 'bien');
}
