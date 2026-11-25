import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/carrera.dart';
import 'package:naturalmente/reglas/carrera.dart';

void main() {
  late Carrera carrera;

  setUpAll(() {
    final catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    carrera = catalogo.actividades
        .firstWhere((a) => a.id == 'carrera')
        .carrera!;
  });

  NivelCarrera nivel(String id) =>
      carrera.niveles.firstWhere((n) => n.id == id);

  void colocarBien(PartidaCarrera partida) {
    for (final corredor in partida.rondaActual!.corredores) {
      partida.colocar(corredor.id, corredor.tramo);
    }
  }

  test('cada nivel tiene sus tramos fijos y un corredor por tramo', () {
    expect(nivel('facil').tramos.map((t) => t.id), ['vuela', 'anda', 'nada']);
    expect(nivel('medio').tramos.map((t) => t.id), [
      'vuela',
      'trepa',
      'salta',
      'repta',
      'nada',
    ]);
    expect(
      nivel('dificil').tramos.map((t) => t.id),
      nivel('medio').tramos.map((t) => t.id),
    );
    for (final n in carrera.niveles) {
      expect(n.rondas, hasLength(3));
      for (final ronda in n.rondas) {
        expect(
          ronda.corredores.map((c) => c.tramo).toSet(),
          n.tramos.map((t) => t.id).toSet(),
        );
      }
    }
    expect(
      nivel('dificil').rondas
          .expand((r) => r.corredores)
          .every((c) => c.parte.isNotEmpty && c.lupa != null),
      isTrue,
    );
  });

  test('colocar no evalúa y «¡Ya!» solo sale con todos en la pista', () {
    final partida = PartidaCarrera(nivel: nivel('facil'));
    final primero = partida.rondaActual!.corredores.first;
    partida.colocar(primero.id, primero.tramo);
    expect(partida.resultado, isNull);
    expect(partida.listo, isFalse);
    partida.salir();
    expect(partida.resultado, isNull);
    expect(partida.salidas, 0);
  });

  test('un tramo ocupado intercambia corredores', () {
    final partida = PartidaCarrera(nivel: nivel('facil'));
    final [a, b, _] = partida.rondaActual!.corredores;
    partida.colocar(a.id, 'vuela');
    partida.colocar(b.id, 'anda');
    partida.colocar(a.id, 'anda');
    expect(partida.tramoDe(a.id), 'anda');
    expect(partida.tramoDe(b.id), 'vuela');
    partida.tocarTramo('anda');
    expect(partida.tramoDe(a.id), isNull);
    partida.seleccionar(a.id);
    partida.tocarTramo('nada');
    expect(partida.tramoDe(a.id), 'nada');
    expect(partida.seleccionado, isNull);
  });

  test('el primer corredor fuera de su tramo se atasca y explica por qué', () {
    final n = nivel('facil');
    final partida = PartidaCarrera(nivel: n);
    final ronda = partida.rondaActual!;
    final volador = ronda.corredores.firstWhere((c) => c.tramo == 'vuela');
    final andador = ronda.corredores.firstWhere((c) => c.tramo == 'anda');
    final nadador = ronda.corredores.firstWhere((c) => c.tramo == 'nada');
    partida.colocar(volador.id, 'vuela');
    partida.colocar(andador.id, 'nada');
    partida.colocar(nadador.id, 'anda');

    partida.salir();
    final cielo = n.tramos.firstWhere((t) => t.id == 'anda');
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.resultado!.frase, '${cielo.reto} ${nadador.como}');
    expect(partida.atascado, nadador.id);
    expect(partida.llegada, 1);
    // Solo vuelve a la salida el que se atasca.
    expect(partida.tramoDe(nadador.id), isNull);
    expect(partida.tramoDe(andador.id), 'nada');
    expect(partida.completa, isFalse);

    // A la segunda, la frase añade la pista.
    partida.colocar(nadador.id, 'anda');
    partida.salir();
    expect(partida.resultado!.frase, endsWith(nadador.pista));
    expect(partida.resultado!.gesto, 'pista');
  });

  test('tres relevos completos terminan el nivel con la despedida', () {
    for (final n in carrera.niveles) {
      final partida = PartidaCarrera(nivel: n);
      for (final ronda in n.rondas) {
        colocarBien(partida);
        partida.salir();
        expect(partida.resultado!.acierto, isTrue);
        expect(partida.descubierto, isTrue);
        expect(partida.resultado!.frase, startsWith(ronda.bien));
        // Mientras se celebra no se puede mover a nadie.
        partida.quitar(ronda.corredores.first.id);
        expect(partida.tramoDe(ronda.corredores.first.id), isNotNull);
        partida.siguiente();
      }
      expect(partida.completa, isTrue);
      expect(partida.progreso, 1);
      expect(partida.resultado!.frase, endsWith(n.despedida));
    }
  });
}
