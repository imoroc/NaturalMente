import 'package:naturalmente/modelo/digestion.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Veces que hay que masticar en la boca antes de poder tragar.
const mordiscosNecesarios = 3;

/// Estado de una partida de «El viaje de la comida», sin widgets.
///
/// El bocado empieza fuera del cuerpo, en el plato. Cada movimiento lo lleva
/// a una parada: si es la siguiente de la ruta avanza; si no, el propio
/// bocado explica qué pasa y a la segunda añade la pista de la parada.
class PartidaViaje {
  PartidaViaje({required this.viaje, required this.nivel});

  final Viaje viaje;
  final NivelViaje nivel;
  var _siguiente = 0;
  var _mordiscos = 0;
  final Map<int, int> _intentos = {};
  final Set<String> _respondidas = {};
  bool _finalAcertada = false;
  Resultado? resultado;
  String? ultimoDestino;
  bool falloDestino = false;
  String? eleccionPregunta;

  /// Parada donde está el bocado, o null si sigue en el plato.
  String? get posicion => _siguiente == 0 ? null : nivel.ruta[_siguiente - 1];
  int get paradasAlcanzadas => _siguiente;
  int get mordiscos => _mordiscos;
  Set<String> get alcanzadas => nivel.ruta.take(_siguiente).toSet();

  bool get faltaMasticar =>
      nivel.masticar && posicion == 'boca' && _mordiscos < mordiscosNecesarios;

  /// Parada cuya pregunta hay que responder antes de seguir (solo Difícil).
  String? get preguntaPendiente {
    if (faltaMasticar) return null;
    final aqui = posicion;
    if (aqui == null || _respondidas.contains(aqui)) return null;
    return nivel.parada(aqui).pregunta == null ? null : aqui;
  }

  bool get recorridoTerminado =>
      _siguiente == nivel.ruta.length && preguntaPendiente == null;

  bool get mostrarPreguntaFinal =>
      recorridoTerminado && nivel.preguntaFinal != null && !_finalAcertada;

  bool get completa =>
      recorridoTerminado && (nivel.preguntaFinal == null || _finalAcertada);

  /// Cómo va el bocado: entero, masticado, en papilla o ya aprovechado.
  String get estadoBocado {
    final aqui = posicion;
    if (aqui == null) return 'entero';
    return switch (aqui) {
      'boca' =>
        !nivel.masticar || _mordiscos >= mordiscosNecesarios
            ? 'bola'
            : (_mordiscos == 0 ? 'entero' : 'trozos'),
      'esofago' => 'bola',
      'estomago' || 'barriga' => 'papilla',
      'intestino-grueso' => 'restos',
      _ => 'nutrientes',
    };
  }

  double get progreso {
    final pasos = nivel.ruta.length + (nivel.preguntaFinal == null ? 0 : 1);
    final hechos =
        _siguiente -
        (preguntaPendiente == null ? 0 : .5) +
        (_finalAcertada ? 1 : 0);
    return hechos / pasos;
  }

  void masticar() {
    if (!faltaMasticar) return;
    _mordiscos += 1;
    ultimoDestino = null;
    falloDestino = false;
    resultado = Resultado(
      acierto: _mordiscos == mordiscosNecesarios,
      frase: _mordiscos == mordiscosNecesarios
          ? '¡Ñam, ñam! Ya soy una bola blandita y me pueden tragar. ¿Adónde voy ahora?'
          : '¡Ñam! Mordisco $_mordiscos de $mordiscosNecesarios. Sigue masticando.',
      estado: 'masticar',
      gesto: _mordiscos == mordiscosNecesarios ? 'feliz' : 'hola',
    );
  }

  void mover(String destino) {
    if (completa || recorridoTerminado) return;
    final pendiente = preguntaPendiente;
    if (pendiente != null) {
      ultimoDestino = null;
      falloDestino = false;
      resultado = const Resultado(
        acierto: false,
        frase: 'Antes de seguir, responde qué pasa en esta parada.',
        estado: 'pregunta',
        gesto: 'hola',
      );
      return;
    }
    ultimoDestino = destino;
    if (faltaMasticar) {
      falloDestino = true;
      resultado = Resultado(
        acierto: false,
        frase: nivel.sinMasticar,
        estado: 'sinMasticar',
        gesto: 'pista',
      );
      return;
    }
    final esperado = nivel.ruta[_siguiente];
    if (destino == esperado) {
      _siguiente += 1;
      falloDestino = false;
      final parada = nivel.parada(destino);
      resultado = Resultado(
        acierto: true,
        frase: parada.llegada,
        estado: destino,
        gesto: 'feliz',
      );
      return;
    }
    final intento = (_intentos[_siguiente] ?? 0) + 1;
    _intentos[_siguiente] = intento;
    falloDestino = true;
    final indice = nivel.ruta.indexOf(destino);
    final String frase;
    if (indice < 0) {
      frase = nivel.despistes.contains(destino)
          ? viaje.despiste(destino).frase
          : nivel.atras;
    } else if (indice > _siguiente) {
      frase = nivel.paradas[_siguiente].salto;
    } else {
      frase = nivel.atras;
    }
    final pista = nivel.paradas[_siguiente].pista;
    resultado = Resultado(
      acierto: false,
      frase: intento >= 2 ? '$frase $pista' : frase,
      estado: destino,
      gesto: intento >= 2 ? 'pista' : 'pensando',
    );
  }

  void responder(String eleccion) {
    final pendiente = preguntaPendiente;
    if (pendiente == null) return;
    eleccionPregunta = eleccion;
    ultimoDestino = null;
    falloDestino = false;
    resultado = resolverPreguntaExtra(
      pregunta: nivel.parada(pendiente).pregunta!,
      eleccion: eleccion,
    );
    if (resultado!.acierto) {
      _respondidas.add(pendiente);
      eleccionPregunta = null;
    }
  }

  void responderFinal(String eleccion) {
    final pregunta = nivel.preguntaFinal;
    if (!mostrarPreguntaFinal || pregunta == null) return;
    eleccionPregunta = eleccion;
    resultado = resolverPreguntaExtra(pregunta: pregunta, eleccion: eleccion);
    _finalAcertada = resultado!.acierto;
  }
}
