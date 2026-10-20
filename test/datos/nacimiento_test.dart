import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/nacimiento.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> contenido() =>
      jsonDecode(File('content/catalog.json').readAsStringSync())
          as Map<String, dynamic>;

  late Actividad actividad;

  setUp(() {
    final catalogo = Catalogo.desdeTexto(jsonEncode(contenido()));
    actividad = catalogo.actividades.firstWhere((a) => a.id == 'nacimiento');
  });

  test('se carga en La reserva con tres niveles y sin medalla', () {
    final nacimiento = actividad.nacimiento!;
    expect(actividad.zona, 'reserva');
    expect(actividad.medalla, isFalse);
    expect(nacimiento.nidos.map((n) => n.id), ['huevo', 'barriga']);
    final facil = nacimiento.niveles[0];
    expect(facil.ordenaCiclos, isFalse);
    expect(facil.animales.length, 6);
    expect(
      facil.animales.map((id) => nacimiento.animal(id).respuesta).toSet(),
      {'huevo', 'barriga'},
    );
    expect(nacimiento.niveles[1].ciclos.map((c) => c.pasos.length), [4, 4]);
    expect(nacimiento.niveles[2].ciclos.map((c) => c.pasos.length), [5, 4]);
  });

  test('rechaza nidos, animales, niveles y ciclos mal formados', () {
    for (final defecto in [
      'nido',
      'respuesta',
      'frase',
      'referencia',
      'nivel',
      'pasos',
      'fraseCiclo',
      'pregunta',
    ]) {
      final mapa = contenido();
      final datos = (mapa['actividades'] as List).firstWhere(
        (a) => a['id'] == 'nacimiento',
      )['nacimiento'];
      switch (defecto) {
        case 'nido':
          datos['nidos'][1]['id'] = 'nido';
        case 'respuesta':
          datos['animales'][0]['respuesta'] = 'semilla';
        case 'frase':
          datos['animales'][0]['frases'].remove('barriga');
        case 'referencia':
          datos['niveles'][0]['animales'][0] = 'unicornio';
        case 'nivel':
          datos['niveles'][2]['id'] = 'medio';
        case 'pasos':
          datos['niveles'][1]['ciclos'][0]['respuesta'].removeLast();
        case 'fraseCiclo':
          datos['niveles'][2]['ciclos'][0]['frases'].remove('mal3');
        case 'pregunta':
          datos['niveles'][1]['ciclos'][1]['pregunta']['respuesta'] = 'otra';
      }
      expect(
        () => Catalogo.desdeTexto(jsonEncode(mapa)),
        throwsArgumentError,
        reason: defecto,
      );
    }
  });

  test('Fácil explica, da pista a la segunda y no deja repetir animal', () {
    final nacimiento = actividad.nacimiento!;
    final partida = PartidaClasificar(
      nacimiento: nacimiento,
      nivel: nacimiento.niveles[0],
    );
    partida.seleccionar('delfin');
    partida.colocar('delfin', 'huevo');
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.resultado!.frase, contains('no es un pez'));
    expect(partida.resultado!.gesto, 'pensando');
    expect(partida.seleccionado, 'delfin');
    expect(partida.falloColocacion, isTrue);
    partida.colocar('delfin', 'huevo');
    expect(partida.resultado!.gesto, 'pista');
    expect(partida.resultado!.frase, contains('respira aire'));
    partida.colocar('delfin', 'barriga');
    expect(partida.resultado!.acierto, isTrue);
    expect(partida.colocados, {'delfin': 'barriga'});
    expect(partida.seleccionado, isNull);
    partida.colocar('delfin', 'huevo');
    expect(partida.colocados, {'delfin': 'barriga'});
    for (final id in partida.nivel.animales) {
      partida.colocar(id, nacimiento.animal(id).respuesta);
    }
    expect(partida.completa, isTrue);
    expect(partida.progreso, 1);
    expect(partida.enNido('huevo'), ['pinguino', 'rana', 'tucan']);
  });

  test('un ciclo pide todos los pasos y señala el primero que no encaja', () {
    final nivel = actividad.nacimiento!.niveles[1];
    final partida = PartidaCiclos(nivel: nivel);
    expect(partida.ciclo.id, 'rana');
    partida.anadir('renacuajo');
    partida.comprobar();
    expect(partida.resultado!.estado, 'incompleto');
    expect(partida.primerFallo, isNull);

    partida.anadir('huevos-rana');
    partida.anadir('ranita');
    partida.anadir('rana');
    partida.comprobar();
    expect(partida.resultado!.estado, 'mal0');
    expect(partida.primerFallo, 0);
    expect(partida.resultado!.frase, isNot(contains('cola')));

    partida.comprobar();
    expect(partida.resultado!.gesto, 'pista');
    expect(partida.resultado!.frase, contains('Fíjate en la cola'));

    // Mover un paso a un hueco ocupado los intercambia.
    partida.colocarEn('huevos-rana', 0);
    expect(partida.orden, ['huevos-rana', 'renacuajo', 'ranita', 'rana']);
    expect(partida.resultado, isNull);
    partida.comprobar();
    expect(partida.cicloOrdenado, isTrue);
    expect(partida.resultado!.frase, contains('metamorfosis'));

    // Ya no se puede deshacer el ciclo resuelto.
    partida.quitar(0);
    expect(partida.orden.first, 'huevos-rana');
    expect(partida.cicloTerminado, isFalse);
    expect(partida.progreso, .25);

    partida.responder('arbol');
    expect(partida.preguntaAcertada, isFalse);
    expect(partida.resultado!.gesto, 'pista');
    partida.responder('agua');
    expect(partida.cicloTerminado, isTrue);
    expect(partida.hayOtroCiclo, isTrue);
    expect(partida.completa, isFalse);

    partida.siguiente();
    expect(partida.ciclo.id, 'mariposa');
    expect(partida.colocados, 0);
    expect(partida.resultado, isNull);
    for (final paso in partida.ciclo.respuesta) {
      partida.anadir(paso);
    }
    partida.comprobar();
    partida.responder(partida.ciclo.pregunta.respuesta);
    expect(partida.completa, isTrue);
    expect(partida.progreso, 1);
  });

  test('Difícil ordena cinco fases de la rana con frases propias', () {
    final ciclo = actividad.nacimiento!.niveles[2].ciclos.first;
    final partida = PartidaCiclos(nivel: actividad.nacimiento!.niveles[2]);
    for (final paso in [
      'huevos-rana',
      'renacuajo',
      'patas',
      'rana',
      'ranita',
    ]) {
      partida.anadir(paso);
    }
    partida.comprobar();
    expect(partida.primerFallo, 3);
    expect(partida.resultado!.frase, ciclo.frases['mal3']);
  });

  test('ningún texto del juego usa palabras prohibidas', () {
    final texto = jsonEncode(
      (contenido()['actividades'] as List).firstWhere(
        (a) => a['id'] == 'nacimiento',
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

  test('guardar un nivel conserva el resto del progreso', () async {
    SharedPreferences.setMockInitialValues({
      'hechos': ['hogar/camello', 'herbario/facil/completo'],
    });
    final progreso = await Progreso.abrir();
    expect(progreso.nivelesSuperadosDe(actividad), 0);
    expect(progreso.maxNivelesDe(actividad), 3);
    await progreso.marcarNivelNacimiento(actividad, 'medio');
    final reabierto = await Progreso.abrir();
    expect(reabierto.hecho('hogar/camello'), isTrue);
    expect(reabierto.hecho('herbario/facil/completo'), isTrue);
    expect(reabierto.nivelNacimientoHecho(actividad, 'medio'), isTrue);
    expect(reabierto.nivelNacimientoHecho(actividad, 'facil'), isFalse);
    expect(reabierto.actividadHecha(actividad), isTrue);
    expect(reabierto.nivelesSuperadosDe(actividad), 1);
    expect(reabierto.fichaDesbloqueada('huevo'), isTrue);
    expect(reabierto.fichaDesbloqueada('renacuajo'), isTrue);
    expect(reabierto.fichaDesbloqueada('mariposa'), isFalse);
    await expectLater(
      reabierto.marcarNivelNacimiento(actividad, 'inventado'),
      throwsArgumentError,
    );
  });
}
