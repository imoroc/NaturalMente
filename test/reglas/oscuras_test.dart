import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/oscuras.dart';
import 'package:naturalmente/reglas/oscuras.dart';

void main() {
  late Oscuras oscuras;

  setUpAll(() {
    final catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    oscuras = catalogo.actividades
        .firstWhere((a) => a.id == 'oscuras')
        .oscuras!;
  });

  NivelOscuras nivel(String id) =>
      oscuras.niveles.firstWhere((n) => n.id == id);

  test('cada nivel tiene su experimento', () {
    expect(nivel('facil').opciones.map((o) => o.id), ['ventana', 'armario']);
    expect(nivel('medio').opciones.map((o) => o.id), [
      'caja-izquierda',
      'caja-arriba',
      'caja-derecha',
    ]);
    expect(nivel('dificil').retos.map((r) => r.tipo), [
      'predecir',
      'predecir',
      'predecir',
      'fabricar',
    ]);
  });

  test('la respuesta no está siempre en el mismo sitio', () {
    for (final n in oscuras.niveles) {
      final sitios = {
        for (final reto in n.retos)
          if (reto.tipo != 'fabricar')
            n.opciones.indexWhere((o) => o.id == reto.respuesta),
      };
      expect(sitios.length, greaterThan(1), reason: n.id);
    }
  });

  test('elegir no se evalúa y sin elegir no pasan los días', () {
    final partida = PartidaOscuras(nivel: nivel('facil'));
    expect(partida.listo, isFalse);
    expect(partida.probar(), isNull);
    partida.elegir('armario');
    expect(partida.resultado, isNull);
    expect(partida.crecimiento, isNull);
    expect(partida.montajeVisible, 'armario');
  });

  test('si no era el sitio, la planta se queda como ha crecido y a la segunda hay pista', () {
    final partida = PartidaOscuras(nivel: nivel('facil'));
    final reto = partida.retoActual!;
    partida.elegir('armario');
    expect(partida.probar(), isFalse);
    expect(partida.crecimiento, 'palida');
    expect(partida.resultado!.frase, reto.frases['armario']);
    expect(partida.probar(), isFalse);
    expect(partida.resultado!.frase, '${reto.frases['armario']} ${reto.pista}');

    partida.elegir('ventana');
    expect(partida.crecimiento, isNull);
    expect(partida.probar(), isTrue);
    expect(partida.crecimiento, 'sana');
    expect(partida.resuelto, isTrue);
    partida.elegir('armario');
    expect(partida.elegida, 'ventana');
  });

  test('en la caja la planta se dobla hacia el agujero', () {
    final partida = PartidaOscuras(nivel: nivel('medio'));
    partida.elegir('caja-izquierda');
    partida.probar();
    expect(partida.crecimiento, 'izquierda');
    partida.elegir('caja-derecha');
    expect(partida.probar(), isTrue);
    expect(partida.crecimiento, 'derecha');
  });

  test('en Difícil se predice y la maceta ya está puesta', () {
    final partida = PartidaOscuras(nivel: nivel('dificil'));
    expect(partida.montajeVisible, 'armario');
    partida.elegir('sana');
    expect(partida.probar(), isFalse);
    // Pasan los días igual: se ve lo que de verdad pasa.
    expect(partida.crecimiento, 'palida');
  });

  test('la hoja solo fabrica con luz, agua y dióxido de carbono', () {
    final partida = PartidaOscuras(nivel: nivel('dificil'));
    for (final reto in partida.nivel.retos.take(3)) {
      partida.elegir(reto.respuesta);
      expect(partida.probar(), isTrue);
      partida.siguiente();
    }
    final reto = partida.retoActual!;
    expect(reto.tipo, 'fabricar');
    expect(partida.listo, isFalse);
    partida.alternar('luz');
    partida.alternar('agua');
    partida.alternar('tierra');
    expect(partida.probar(), isFalse);
    expect(
      partida.resultado!.frase,
      reto.ingredientes.firstWhere((i) => i.id == 'tierra').aviso,
    );
    partida.alternar('tierra');
    expect(partida.probar(), isFalse);
    expect(
      partida.resultado!.frase,
      '${reto.ingredientes.firstWhere((i) => i.id == 'aire').aviso} ${reto.pista}',
    );
    partida.alternar('aire');
    expect(partida.probar(), isTrue);
    expect(partida.fabricado, isTrue);
    expect(partida.completa, isTrue);
    expect(partida.resultado!.frase, startsWith(reto.como));
    expect(partida.resultado!.frase, endsWith(partida.nivel.despedida));
  });

  test('rechaza una predicción que no cuadra con el montaje', () {
    Map<String, dynamic> nivelMapa(String id) => {
      'id': id,
      'nombre': 'N',
      'curso': '5º-6º',
      'intro': 'I.',
      'curiosidad': 'C.',
      'despedida': 'D.',
      'opciones': [
        {'id': 'sana', 'nombre': 'S'},
        {'id': 'palida', 'nombre': 'P'},
      ],
      'retos': [
        {
          'id': 'r',
          'tipo': 'predecir',
          'pregunta': '¿?',
          'pista': 'P.',
          'montaje': 'armario',
          'respuesta': 'sana',
          'frases': {'sana': 'S.', 'palida': 'P.'},
        },
      ],
    };
    expect(
      () => Oscuras.desdeMapa({
        'niveles': [
          for (final id in ['facil', 'medio', 'dificil']) nivelMapa(id),
        ],
      }),
      throwsArgumentError,
    );
  });
}
