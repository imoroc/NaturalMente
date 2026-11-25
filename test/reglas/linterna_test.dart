import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/linterna.dart';
import 'package:naturalmente/reglas/linterna.dart';
import 'package:naturalmente/ui/dibujos_linterna.dart';

void main() {
  late Linterna linterna;

  setUpAll(() {
    final catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    linterna = catalogo.actividades
        .firstWhere((a) => a.id == 'linterna')
        .linterna!;
  });

  NivelLinterna nivel(String id) =>
      linterna.niveles.firstWhere((n) => n.id == id);

  void tocarZona(PartidaLinterna partida, ObjetivoLinterna objetivo) {
    final zona = objetivo.zonas.first;
    partida.tocar(zona.x, zona.y);
  }

  test('cada nivel usa su herramienta y sus escenas están dibujadas', () {
    expect(linterna.niveles.map((n) => n.herramienta), [
      'linterna',
      'rayos',
      'microscopio',
    ]);
    for (final n in linterna.niveles) {
      expect(n.escenas, hasLength(3));
      for (final escena in n.escenas) {
        expect(dibujosLinterna, contains(escena.dibujo));
      }
    }
    expect(nivel('facil').escenas.first.objetivos.map((o) => o.id), [
      'cabeza',
      'tronco',
      'brazos',
      'piernas',
    ]);
    expect(nivel('dificil').escenas.last.objetivos.map((o) => o.id), [
      'celula',
      'tejido',
      'organo',
      'aparato',
    ]);
  });

  test('el centro de cada zona es de su objetivo y de ningún otro', () {
    for (final n in linterna.niveles) {
      for (final escena in n.escenas) {
        final partida = PartidaLinterna(
          nivel: NivelLinterna(
            id: n.id,
            nombre: n.nombre,
            curso: n.curso,
            resumen: n.resumen,
            intro: n.intro,
            curiosidad: n.curiosidad,
            despedida: n.despedida,
            herramienta: n.herramienta,
            luz: n.luz,
            escenas: [escena],
          ),
        );
        for (final objetivo in escena.objetivos) {
          for (final zona in objetivo.zonas) {
            expect(
              partida.queHay(zona.x, zona.y)?.id,
              objetivo.id,
              reason: '${escena.id}: ${objetivo.id}',
            );
          }
        }
      }
    }
  });

  test('lo que se busca no está siempre en el mismo sitio del dibujo', () {
    for (final n in linterna.niveles) {
      final primeros = {
        for (final escena in n.escenas)
          for (final objetivo in escena.objetivos)
            '${objetivo.zonas.first.x},${objetivo.zonas.first.y}',
      };
      expect(primeros.length, greaterThan(3));
    }
  });

  test('tocar donde no hay nada no cuenta como intento', () {
    final partida = PartidaLinterna(nivel: nivel('facil'));
    expect(partida.tocar(.02, .02), ToqueLinterna.nada);
    expect(partida.resultado, isNull);
    expect(partida.buscado!.id, 'cabeza');
  });

  test('tocar otra cosa explica qué es y a la segunda da la pista', () {
    final partida = PartidaLinterna(nivel: nivel('facil'));
    final [cabeza, tronco, ...] = partida.escenaActual!.objetivos;
    tocarZona(partida, tronco);
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.resultado!.frase, tronco.aviso);
    expect(partida.tocado, tronco.id);
    tocarZona(partida, tronco);
    expect(partida.resultado!.frase, '${tronco.aviso} ${cabeza.pista}');
    expect(partida.encontrado(tronco.id), isFalse);

    tocarZona(partida, cabeza);
    expect(partida.resultado!.acierto, isTrue);
    expect(partida.resultado!.frase, cabeza.como);
    expect(partida.buscado!.id, tronco.id);
    expect(
      partida.tocar(cabeza.zonas.first.x, cabeza.zonas.first.y),
      ToqueLinterna.repetido,
    );
  });

  test('al encontrar todo se enciende la luz y se pasa de escena', () {
    final partida = PartidaLinterna(nivel: nivel('medio'));
    for (final escena in partida.nivel.escenas) {
      expect(partida.escenaActual, same(escena));
      for (final objetivo in escena.objetivos) {
        expect(partida.iluminada, isFalse);
        tocarZona(partida, objetivo);
      }
      expect(partida.iluminada, isTrue);
      expect(partida.buscado, isNull);
      expect(partida.resultado!.frase, contains(escena.bien));
      // Con la luz encendida no se puede seguir tocando.
      expect(partida.tocar(.5, .5), ToqueLinterna.nada);
      partida.siguiente();
    }
    expect(partida.completa, isTrue);
    expect(partida.progreso, 1);
    expect(partida.resultado!.frase, endsWith(partida.nivel.despedida));
  });
}
