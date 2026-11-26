import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/pelicula.dart';
import 'package:naturalmente/reglas/pelicula.dart';

void main() {
  late Pelicula pelicula;

  setUpAll(() {
    final catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    pelicula = catalogo.actividades
        .firstWhere((a) => a.id == 'pelicula')
        .pelicula!;
  });

  NivelPelicula nivel(String id) =>
      pelicula.niveles.firstWhere((n) => n.id == id);

  test('cada nivel tiene tres rollos y su tira crece con la dificultad', () {
    expect(pelicula.niveles.map((n) => n.rollos.length), [3, 3, 3]);
    expect(pelicula.niveles.map((n) => n.rollos.first.fotogramas.length), [
      3,
      5,
      6,
    ]);
    expect(nivel('facil').rollos.first.fotogramas.map((f) => f.id), [
      'semilla',
      'brote',
      'planta',
    ]);
    // En Difícil la tira es una rueda y hay cartas que no van.
    for (final rollo in nivel('dificil').rollos) {
      expect(rollo.rueda, isTrue);
      expect(rollo.bandeja.length, greaterThan(rollo.fotogramas.length));
      expect(
        rollo.fotogramas.map((f) => f.id),
        containsAll(['semilla', 'germina', 'flor', 'fruto']),
      );
    }
  });

  test('la carta buena no cae siempre en el mismo sitio de la bandeja', () {
    for (final n in pelicula.niveles) {
      final total = n.rollos.first.fotogramas.length;
      for (var i = 0; i < total; i++) {
        final sitios = {
          for (final rollo in n.rollos)
            rollo.bandeja.indexWhere((c) => c.id == rollo.fotogramas[i].id),
        };
        expect(sitios.length, greaterThan(1), reason: '${n.id}: fotograma $i');
      }
    }
  });

  test('en Difícil el polen y las semillas viajan de formas distintas', () {
    final polen = {
      for (final rollo in nivel('dificil').rollos) rollo.fotogramas[3].id,
    };
    final viaje = {
      for (final rollo in nivel('dificil').rollos) rollo.fotogramas.last.id,
    };
    expect(polen, {'polen-abeja', 'polen-viento'});
    expect(viaje, {'semilla-animal', 'semilla-viento'});
  });

  test('poner otra carta explica cuándo va y a la segunda da la pista', () {
    final partida = PartidaPelicula(nivel: nivel('medio'));
    final rollo = partida.rolloActual!;
    final flor = rollo.carta('flor')!;
    expect(partida.poner('flor'), JugadaPelicula.fallo);
    expect(partida.resultado!.frase, flor.aviso);
    expect(partida.fallada, 'flor');
    expect(partida.poner('flor'), JugadaPelicula.fallo);
    expect(
      partida.resultado!.frase,
      '${flor.aviso} ${rollo.fotogramas.first.pista}',
    );
    expect(partida.puestas, isEmpty);

    expect(partida.poner('semilla'), JugadaPelicula.acierto);
    expect(partida.resultado!.frase, rollo.fotogramas.first.como);
    expect(partida.hueco, 1);
    expect(partida.poner('semilla'), JugadaPelicula.nada);
    expect(partida.poner('no-existe'), JugadaPelicula.nada);
  });

  test('al llenar la tira se proyecta y se pasa de rollo', () {
    final partida = PartidaPelicula(nivel: nivel('dificil'));
    for (final rollo in partida.nivel.rollos) {
      expect(partida.rolloActual, same(rollo));
      for (final fotograma in rollo.fotogramas) {
        expect(partida.proyectando, isFalse);
        expect(partida.poner(fotograma.id), JugadaPelicula.acierto);
      }
      expect(partida.proyectando, isTrue);
      expect(partida.hueco, isNull);
      expect(partida.resultado!.frase, contains(rollo.bien));
      // Mientras se proyecta no se pueden poner cartas.
      expect(partida.poner(rollo.bandeja.first.id), JugadaPelicula.nada);
      partida.siguiente();
    }
    expect(partida.completa, isTrue);
    expect(partida.progreso, 1);
    expect(partida.resultado!.frase, endsWith(partida.nivel.despedida));
  });

  test('rechaza un rollo con un fotograma sin carta', () {
    final mapa = {
      'niveles': [
        for (final id in ['facil', 'medio', 'dificil'])
          {
            'id': id,
            'nombre': 'N',
            'curso': '1º-2º',
            'intro': 'I.',
            'curiosidad': 'C.',
            'despedida': 'D.',
            'rollos': [
              {
                'id': 'r',
                'planta': 'judia',
                'titulo': 'T',
                'bien': 'B.',
                'fotogramas': [
                  {'id': 'semilla', 'como': 'C.', 'pista': 'P.'},
                  {'id': 'brote', 'como': 'C.', 'pista': 'P.'},
                  {'id': 'planta', 'como': 'C.', 'pista': 'P.'},
                ],
                'bandeja': [
                  {
                    'id': 'semilla',
                    'nombre': 'S',
                    'fase': 'semilla',
                    'aviso': 'A.',
                  },
                  {
                    'id': 'brote',
                    'nombre': 'B',
                    'fase': 'brote',
                    'aviso': 'A.',
                  },
                ],
              },
            ],
          },
      ],
    };
    expect(() => Pelicula.desdeMapa(mapa), throwsArgumentError);
  });
}
