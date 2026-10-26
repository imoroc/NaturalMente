import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/digestion.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> contenido() =>
      jsonDecode(File('content/catalog.json').readAsStringSync())
          as Map<String, dynamic>;

  late Actividad actividad;

  setUp(() {
    final catalogo = Catalogo.desdeTexto(jsonEncode(contenido()));
    actividad = catalogo.actividades.firstWhere((a) => a.id == 'digestion');
  });

  PartidaViaje partida(String nivel) => PartidaViaje(
    viaje: actividad.viaje!,
    nivel: actividad.viaje!.niveles.firstWhere((n) => n.id == nivel),
  );

  test('se carga en Dentro de mí con tres rutas cada vez más largas', () {
    final viaje = actividad.viaje!;
    expect(actividad.zona, 'cuerpo');
    expect(actividad.medalla, isFalse);
    expect(viaje.niveles.map((n) => n.ruta), [
      ['boca', 'barriga'],
      ['boca', 'esofago', 'estomago', 'intestino'],
      ['boca', 'esofago', 'estomago', 'intestino-delgado', 'intestino-grueso'],
    ]);
    expect(viaje.niveles.map((n) => n.masticar), [true, true, true]);
    expect(viaje.niveles[0].despistes, ['pulmones']);
    expect(viaje.niveles[1].preguntaFinal, isNotNull);
    expect(viaje.niveles[2].paradas.every((p) => p.pregunta != null), isTrue);
  });

  test('rechaza rutas, despistes y preguntas mal formados', () {
    for (final defecto in [
      'primera',
      'desconocida',
      'despiste',
      'salto',
      'masticar',
      'preguntaDificil',
      'preguntaMedio',
      'nivel',
    ]) {
      final mapa = contenido();
      final datos = (mapa['actividades'] as List).firstWhere(
        (a) => a['id'] == 'digestion',
      )['viaje'];
      final niveles = datos['niveles'] as List;
      switch (defecto) {
        case 'primera':
          (niveles[1]['paradas'] as List).removeAt(0);
        case 'desconocida':
          niveles[0]['paradas'][1]['id'] = 'higado';
        case 'despiste':
          niveles[1]['despistes'].add('cerebro');
        case 'salto':
          niveles[1]['paradas'][1].remove('salto');
        case 'masticar':
          niveles[0].remove('sinMasticar');
        case 'preguntaDificil':
          niveles[2]['paradas'][3].remove('pregunta');
        case 'preguntaMedio':
          niveles[1].remove('preguntaFinal');
        case 'nivel':
          niveles[2]['id'] = 'medio';
      }
      expect(
        () => Catalogo.desdeTexto(jsonEncode(mapa)),
        throwsArgumentError,
        reason: defecto,
      );
    }
  });

  test('Fácil obliga a masticar y explica cada despiste sin castigar', () {
    final juego = partida('facil');
    expect(juego.posicion, isNull);
    expect(juego.estadoBocado, 'entero');

    juego.mover('barriga');
    expect(juego.resultado!.acierto, isFalse);
    expect(juego.resultado!.frase, contains('Todavía no me han masticado'));
    expect(juego.resultado!.gesto, 'pensando');
    juego.mover('pulmones');
    expect(juego.resultado!.frase, contains('entra el aire'));
    expect(juego.resultado!.gesto, 'pista');
    expect(juego.resultado!.frase, contains('hablas y sonríes'));

    juego.mover('boca');
    expect(juego.posicion, 'boca');
    expect(juego.faltaMasticar, isTrue);
    juego.mover('barriga');
    expect(juego.posicion, 'boca');
    expect(juego.resultado!.frase, contains('Toca «Masticar»'));

    for (var i = 0; i < mordiscosNecesarios; i++) {
      expect(juego.estadoBocado, i == 0 ? 'entero' : 'trozos');
      juego.masticar();
    }
    expect(juego.faltaMasticar, isFalse);
    expect(juego.estadoBocado, 'bola');
    juego.masticar();
    expect(juego.mordiscos, mordiscosNecesarios);

    juego.mover('boca');
    expect(juego.resultado!.frase, contains('hacia delante'));
    juego.mover('barriga');
    expect(juego.estadoBocado, 'papilla');
    expect(juego.completa, isTrue);
    expect(juego.progreso, 1);
    juego.mover('pulmones');
    expect(juego.posicion, 'barriga');
  });

  test('Medio avisa al saltar paradas y termina con su pregunta', () {
    final juego = partida('medio');
    juego.mover('boca');
    for (var i = 0; i < mordiscosNecesarios; i++) {
      juego.masticar();
    }
    juego.mover('estomago');
    expect(juego.resultado!.frase, contains('primero tengo que bajar'));
    juego.mover('corazon');
    expect(juego.resultado!.frase, contains('bombea la sangre'));
    expect(juego.resultado!.frase, contains('Busca el tubo largo'));
    juego.mover('esofago');
    juego.mover('estomago');
    juego.mover('intestino');
    expect(juego.recorridoTerminado, isTrue);
    expect(juego.mostrarPreguntaFinal, isTrue);
    expect(juego.completa, isFalse);
    expect(juego.progreso, closeTo(.8, .001));

    juego.responderFinal('aire');
    expect(juego.resultado!.acierto, isFalse);
    expect(juego.completa, isFalse);
    juego.responderFinal('energia');
    expect(juego.completa, isTrue);
    expect(juego.progreso, 1);
  });

  test('Difícil pide masticar y responder en cada parada antes de seguir', () {
    final juego = partida('dificil');
    juego.mover('boca');
    expect(juego.faltaMasticar, isTrue);
    expect(juego.preguntaPendiente, isNull);
    for (var i = 0; i < mordiscosNecesarios; i++) {
      juego.masticar();
    }
    expect(juego.faltaMasticar, isFalse);
    expect(juego.preguntaPendiente, 'boca');
    juego.mover('esofago');
    expect(juego.posicion, 'boca');
    expect(juego.resultado!.estado, 'pregunta');

    juego.responder('heces');
    expect(juego.resultado!.frase, contains('intestino grueso'));
    expect(juego.preguntaPendiente, 'boca');
    juego.responder('masticar');
    expect(juego.preguntaPendiente, isNull);

    final viaje = actividad.viaje!.niveles[2];
    for (final parada in viaje.paradas.skip(1)) {
      juego.mover(parada.id);
      expect(juego.preguntaPendiente, parada.id);
      juego.responder(parada.pregunta!.respuesta);
    }
    expect(juego.estadoBocado, 'restos');
    expect(juego.completa, isTrue);
    expect(juego.resultado!.frase, contains('Viaje completo'));
  });

  test('ningún texto del viaje usa palabras prohibidas', () {
    final texto = jsonEncode(
      (contenido()['actividades'] as List).firstWhere(
        (a) => a['id'] == 'digestion',
      ),
    ).toLowerCase();
    for (final prohibida in [
      'error',
      'incorrecto',
      'has fallado',
      'mal hecho',
    ]) {
      expect(texto, isNot(contains(prohibida)));
    }
  });

  test('guardar un nivel da su cromo y los anteriores', () async {
    SharedPreferences.setMockInitialValues({
      'hechos': ['nacimiento/facil/completo'],
    });
    final progreso = await Progreso.abrir();
    expect(progreso.maxNivelesDe(actividad), 3);
    await progreso.marcarNivelJuego(actividad, 'dificil');
    final reabierto = await Progreso.abrir();
    expect(reabierto.hecho('nacimiento/facil/completo'), isTrue);
    expect(reabierto.nivelJuegoHecho(actividad, 'dificil'), isTrue);
    expect(reabierto.nivelesSuperadosDe(actividad), 1);
    expect(reabierto.actividadHecha(actividad), isTrue);
    for (final ficha in ['dientes', 'aparato-digestivo', 'nutrientes']) {
      expect(reabierto.fichaDesbloqueada(ficha), isTrue, reason: ficha);
    }
    await expectLater(
      reabierto.marcarNivelJuego(actividad, 'inventado'),
      throwsArgumentError,
    );
  });
}
