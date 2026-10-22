import 'dart:math';

import 'package:naturalmente/modelo/actividad.dart';

class BarajadorOpciones {
  static final Random _azar = Random();
  // La posición de la última respuesta correcta se recuerda por tipo de
  // pregunta (lo que va antes del primer guion de la clave). Así la pregunta
  // extra no depende de dónde cayó el sitio correcto y no se repite seguida.
  static final Map<String, int> _ultimasPosCorrectas = {};
  static final Map<String, String> _ultimasFirmas = {};

  static void reiniciarMemoria() {
    _ultimasPosCorrectas.clear();
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
    final grupo = clave.split('-').first;
    final ultimaPos = _ultimasPosCorrectas[grupo];
    final ultimaFirma = _ultimasFirmas[clave];
    List<T> mejor = List<T>.from(opciones)..shuffle(generador);

    for (var intento = 0; intento < 32; intento++) {
      final candidata = List<T>.from(opciones)..shuffle(generador);
      final pos = candidata.indexWhere((o) => idDe(o) == respuestaCorrecta);
      final firma = candidata.map(idDe).join(',');
      final cambiaPosicion = ultimaPos == null || pos != ultimaPos;
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
      _ultimasPosCorrectas[grupo] = posElegida;
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

String respuestaOptimaControl(String controlId) => switch (controlId) {
  'agua' => 'justa',
  'luz' => 'justa',
  'suelo' => 'huerto',
  'temperatura' => 'templada',
  _ => 'justa',
};

class ResultadoPasoGerminacion {
  const ResultadoPasoGerminacion({
    required this.etapaAlcanzada,
    required this.avanzaEtapa,
    required this.experimentoCompletado,
    required this.estado,
    required this.frase,
    required this.gesto,
  });

  final int etapaAlcanzada;
  final bool avanzaEtapa;
  final bool experimentoCompletado;
  final String estado;
  final String frase;
  final String gesto;
}

ResultadoPasoGerminacion resolverPasoGerminacion({
  required Actividad actividad,
  required Map<String, String> valores,
  required int etapaActual,
  NivelLugar? nivel,
}) {
  final controlesActivos = nivel?.controles.isNotEmpty == true
      ? nivel!.controles
      : actividad.controles;
  final pideTemperatura = controlesActivos.any((c) => c.id == 'temperatura');
  final suelo = valores['suelo'];
  final agua = valores['agua'];
  final luz = valores['luz'] ?? 'justa';
  final temperatura = valores['temperatura'] ?? 'templada';

  if (suelo == null || agua == null || (pideTemperatura && valores['temperatura'] == null)) {
    final fraseFalta = nivel?.frases['falta'] ?? actividad.frases['falta'] ?? '';
    return ResultadoPasoGerminacion(
      etapaAlcanzada: etapaActual,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'falta',
      frase: fraseFalta,
      gesto: 'hola',
    );
  }

  // Comprobación de problemas inmediatos en la fase actual
  if (suelo == 'piedras') {
    return ResultadoPasoGerminacion(
      etapaAlcanzada: etapaActual,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'sinAgarre',
      frase: switch (etapaActual) {
        1 => 'Día 1: Entre las piedras duras el agua se escapa al fondo y la semilla no tiene una base húmeda para hincharse. Pon algodón o tierra de jardín.',
        2 => 'Día 3: La primera raíz choca contra las piedras secas y no puede sujetarse. Cambia la base a algodón o tierra de jardín.',
        _ => 'Día 5: Sobre las piedras las raíces se secan y el tallo no puede sostenerse. Elige tierra de jardín o algodón.',
      },
      gesto: 'pista',
    );
  }

  if (pideTemperatura && temperatura == 'fria') {
    return ResultadoPasoGerminacion(
      etapaAlcanzada: etapaActual,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'helada',
      frase: switch (etapaActual) {
        1 => 'Día 1: A 4 °C hace frío como en una nevera y la plantita sigue dormida dentro de la semilla. Pon el termostato a 20 °C.',
        2 => 'Día 3: Con el frío de 4 °C la raíz blanca detiene su crecimiento. Pon el termostato en 20 °C.',
        _ => 'Día 5: A 4 °C hace demasiado frío para que el tallo abra sus hojas. Ajusta el termostato a 20 °C.',
      },
      gesto: 'pista',
    );
  }

  if ((pideTemperatura && temperatura == 'calor') || luz == 'excesiva') {
    return ResultadoPasoGerminacion(
      etapaAlcanzada: etapaActual,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'achicharrada',
      frase: luz == 'excesiva'
          ? 'El sol abrasador calienta demasiado la maceta, evapora el agua y seca el brote. Elige «Sol de ventana».'
          : 'A 42 °C hace tanto calor que se evapora toda la humedad de la maceta. Baja el termostato a 20 °C.',
      gesto: 'pista',
    );
  }

  if (agua == 'mucha') {
    return ResultadoPasoGerminacion(
      etapaAlcanzada: etapaActual,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'ahogada',
      frase: switch (etapaActual) {
        1 => 'Día 1: Con demasiada agua el bote se inunda y la semilla se queda sin aire para respirar. Elige «Riego suave».',
        2 => 'Día 3: Hay un charco en el bote y la primera raíz se queda sin oxígeno. Cambia el riego a «Riego suave».',
        _ => 'Día 5: Con tanta agua acumulada las raíces no pueden respirar y el tallo se dobla. Elige «Riego suave».',
      },
      gesto: 'pista',
    );
  }

  if (agua == 'poca') {
    return ResultadoPasoGerminacion(
      etapaAlcanzada: etapaActual,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'seca',
      frase: switch (etapaActual) {
        1 => 'Día 1: La maceta está seca; sin agua la piel de la semilla sigue dura y no puede despertar. ¡Elige «Riego suave»!',
        2 => 'Día 3: Al sacar la raíz la planta se bebió el agua del primer día. ¡Elige «Riego suave» para darle agua hoy!',
        _ => 'Día 5: El tallo ha crecido y se ha bebido el agua anterior. ¡Dale otro «Riego suave» para que abra sus hojas!',
      },
      gesto: 'pista',
    );
  }

  // En Día 1 -> Día 3: incluso la arena húmeda permite que la semilla se hinche y asome la primera raíz
  if (etapaActual == 1) {
    final fraseDia3 = switch (suelo) {
      'arena' => '¡Día 3! Con el primer riego la semilla se ha hinchado y asoma su primera raíz. Pero fíjate: en la arena el agua se escapa hacia abajo muy rápido.',
      'algodon' => '¡Día 3! El algodón húmedo ablandó la semilla y ya sale la primera raíz hacia abajo. Como ha bebido el agua para crecer, vuelve a elegir «Riego suave» hoy.',
      _ => '¡Día 3! La semilla ha bebido agua en la tierra, se ha hinchado y ya asoma la raíz blanca. ¡Vuelve a darle un «Riego suave» hoy para que suba el tallo!',
    };
    return ResultadoPasoGerminacion(
      etapaAlcanzada: 2,
      avanzaEtapa: true,
      experimentoCompletado: false,
      estado: 'brote',
      frase: fraseDia3,
      gesto: 'feliz',
    );
  }

  // En Día 3 -> Día 5: la arena ya no retiene el agua ni tiene nutrientes para levantar el tallo
  if (suelo == 'arena') {
    return ResultadoPasoGerminacion(
      etapaAlcanzada: 2,
      avanzaEtapa: false,
      experimentoCompletado: false,
      estado: 'sedienta',
      frase: nivel?.frases['sedienta'] ??
          actividad.frases['sedienta'] ??
          'En la arena la semilla logró sacar la raíz en el Día 3, pero el agua se escurre tan rápido que el tallo no puede subir. Cambia la base a tierra de jardín o algodón.',
      gesto: 'pista',
    );
  }

  if (etapaActual == 2) {
    final fraseDia5 = luz == 'poca'
        ? '¡Día 5! El tallo ya asoma hacia arriba, aunque sube amarillento porque la cortina está cerrada. ¡Vuelve a darle «Riego suave» y abre la ventana al sol!'
        : '¡Día 5! La raíz sujetó la planta y el tallo ya sube buscando el sol de la ventana. ¡Dale un último «Riego suave» para que abra sus hojas en el Día 7!';
    return ResultadoPasoGerminacion(
      etapaAlcanzada: 3,
      avanzaEtapa: true,
      experimentoCompletado: false,
      estado: luz == 'poca' ? 'palida' : 'brote',
      frase: fraseDia5,
      gesto: 'feliz',
    );
  }

  // Día 5 -> Día 7 (o ajustes directos en el Día 7): 3 desenlaces reales que llegan hasta la fase 4
  if (luz == 'poca') {
    final frasePalida = nivel?.frases['palida'] ??
        actividad.frases['palida'] ??
        '¡Llegó al Día 7! Con agua y las reservas de la semilla creció alta a oscuras, pero sus hojas son amarillas sin sol.';
    return ResultadoPasoGerminacion(
      etapaAlcanzada: 4,
      avanzaEtapa: etapaActual < 4,
      experimentoCompletado: etapaActual >= 4,
      estado: 'palida',
      frase: frasePalida,
      gesto: 'pista',
    );
  }

  if (suelo == 'algodon') {
    final fraseAlgodon = nivel?.frases['broteAlgodon'] ??
        actividad.frases['broteAlgodon'] ??
        '¡Germinó muy bien en algodón húmedo! Con agua y sol ha sacado raíz, tallo y hojas verdes.';
    return ResultadoPasoGerminacion(
      etapaAlcanzada: 4,
      avanzaEtapa: true,
      experimentoCompletado: true,
      estado: 'broteAlgodon',
      frase: fraseAlgodon,
      gesto: 'feliz',
    );
  }

  final fraseBrote = nivel?.frases['brote'] ??
      actividad.frases['brote'] ??
      '¡Crecimiento completo en tierra de jardín! Tu planta ha superado las 4 etapas sana, verde y fuerte.';
  return ResultadoPasoGerminacion(
    etapaAlcanzada: 4,
    avanzaEtapa: true,
    experimentoCompletado: true,
    estado: 'brote',
    frase: fraseBrote,
    gesto: 'feliz',
  );
}

Resultado resolverControles({
  required Actividad actividad,
  required Map<String, String> valores,
  NivelLugar? nivel,
}) {
  final controlesActivos = nivel?.controles.isNotEmpty == true
      ? nivel!.controles
      : actividad.controles;
  final faltanControles = controlesActivos.any(
    (control) => !valores.containsKey(control.id),
  );
  final pideTemperatura = controlesActivos.any((c) => c.id == 'temperatura');
  final estado = faltanControles
      ? 'falta'
      : _estadoSemilla(
          agua: valores['agua'],
          luz: valores['luz'],
          suelo: valores['suelo'],
          temperatura: valores['temperatura'],
          pideTemperatura: pideTemperatura,
        );
  final frase =
      nivel?.frases[estado] ??
      actividad.frases[estado] ??
      nivel?.frases['brote'] ??
      actividad.frases['brote'];
  if (frase == null) {
    throw ArgumentError('A ${actividad.id} le falta la frase de $estado.');
  }
  final acierto = estado == 'brote' || estado == 'broteAlgodon';
  final gesto = switch (estado) {
    'brote' || 'broteAlgodon' => 'feliz',
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

String _estadoSemilla({
  required String? agua,
  required String? luz,
  required String? suelo,
  String? temperatura,
  bool pideTemperatura = false,
}) {
  if (agua == null || luz == null || suelo == null) return 'falta';
  if (pideTemperatura && temperatura == null) return 'falta';
  if (agua == 'mucha') return 'ahogada';
  if (agua == 'poca') return 'seca';
  if (suelo == 'piedras') return 'sinAgarre';
  if (suelo == 'arena') return 'sedienta';
  if (pideTemperatura && temperatura == 'fria') return 'helada';
  if ((pideTemperatura && temperatura == 'calor') || luz == 'excesiva') {
    return 'achicharrada';
  }
  if (luz == 'poca') return 'palida';
  if (suelo == 'algodon') return 'broteAlgodon';
  return 'brote';
}

Resultado resolverOrden({
  required Actividad actividad,
  required List<String> orden,
  NivelLugar? nivel,
}) {
  final respuesta = nivel?.respuesta.isNotEmpty == true
      ? nivel!.respuesta
      : actividad.respuesta;
  final frases = {
    ...actividad.frases,
    if (nivel != null) ...nivel.frases,
  };
  final mismoContenido = orden.length == respuesta.length &&
      orden.toSet().length == respuesta.length &&
      orden.toSet().containsAll(respuesta);
  if (!mismoContenido) {
    final frase = frases['incompleto'];
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
      final frase = frases['mal$i'];
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
  final fraseBien = frases['bien'];
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
