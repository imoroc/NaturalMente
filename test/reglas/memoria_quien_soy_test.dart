import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/reglas/adivinanza.dart';
import 'package:naturalmente/reglas/memoria.dart';

void main() {
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  final memoria = catalogo.actividades
      .firstWhere((a) => a.id == 'memoria-plantas')
      .memoria!;
  final adivinanza = catalogo.actividades
      .firstWhere((a) => a.id == 'quien-soy')
      .adivinanza!;

  test('Memoria: dos cartas que no van juntas se tapan al tocar otra', () {
    final nivel = memoria.niveles.first;
    final partida = PartidaMemoria(nivel: nivel);
    final [p1, p2, ...] = nivel.parejas;

    expect(
      partida.tocar('${p1.id}-a'),
      isFalse,
      reason: 'una carta sola no se evalúa',
    );
    expect(partida.tocar('${p2.id}-b'), isTrue);
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.visible('${p1.id}-a'), isTrue);

    partida.tocar('${p1.id}-b');
    expect(partida.visible('${p1.id}-a'), isFalse);
    expect(partida.visible('${p1.id}-b'), isTrue);
    expect(partida.tocar('${p1.id}-a'), isTrue);
    expect(partida.resultado!.acierto, isTrue);
    expect(partida.encontrada(p1.id), isTrue);
  });

  test('Memoria: al encontrar todas las parejas el nivel se completa', () {
    for (final nivel in memoria.niveles) {
      final partida = PartidaMemoria(nivel: nivel);
      for (final pareja in nivel.parejas) {
        partida.tocar('${pareja.id}-a');
        partida.tocar('${pareja.id}-b');
      }
      expect(partida.completa, isTrue);
      expect(partida.resultado!.frase, contains(nivel.despedida));
    }
    expect(memoria.niveles.map((n) => n.cartas.length), [6, 10, 12]);
  });

  test('¿Quién soy?: un fallo descarta el animal y muestra otra pista', () {
    final nivel = adivinanza.niveles.first;
    final partida = PartidaAdivinanza(adivinanza: adivinanza, nivel: nivel);
    final ronda = partida.ronda!;
    final otro = ronda.opciones.firstWhere((id) => id != ronda.respuesta);

    expect(partida.pistasVistas, 1);
    partida.adivinar(otro);
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.descartado(otro), isTrue);
    expect(partida.pistasVistas, 2);
    expect(
      partida.resultado!.frase,
      contains(adivinanza.animal(otro).conArticulo),
    );

    partida.otraPista();
    expect(partida.pistasVistas, 3);
    expect(partida.quedanPistas, isFalse);

    partida.adivinar(ronda.respuesta);
    expect(partida.resultado!.acierto, isTrue);
    expect(partida.pistasUltimoAcierto, 3);
    expect(partida.indiceRonda, 1);
    expect(partida.pistasVistas, 1);
  });

  test('¿Quién soy?: más opciones y pistas en cada nivel', () {
    expect(adivinanza.niveles.map((n) => n.rondas.first.opciones.length), [
      3,
      4,
      6,
    ]);
    for (final nivel in adivinanza.niveles) {
      final partida = PartidaAdivinanza(adivinanza: adivinanza, nivel: nivel);
      for (final ronda in nivel.rondas) {
        partida.adivinar(ronda.respuesta);
      }
      expect(partida.completa, isTrue);
      expect(partida.resultado!.frase, contains(nivel.despedida));
    }
  });
}
