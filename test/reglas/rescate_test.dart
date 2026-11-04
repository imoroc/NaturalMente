import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/rescate.dart';
import 'package:naturalmente/reglas/rescate.dart';

void main() {
  late Rescate rescate;

  setUpAll(() {
    final catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    rescate = catalogo.actividades
        .firstWhere((a) => a.id == 'cuida-reserva')
        .rescate!;
  });

  NivelRescate nivel(String id) =>
      rescate.niveles.firstWhere((n) => n.id == id);

  test('Fácil: se recoge la basura y los seres vivos se quedan', () {
    final partida = PartidaRescate(nivel: nivel('facil'));
    partida.tocar('rana');
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.recogido('rana'), isFalse);
    expect(partida.resultado!.frase.toLowerCase(), isNot(contains('error')));

    for (final objeto in partida.nivel.objetos.where((o) => o.basura)) {
      expect(partida.completa, isFalse);
      partida.tocar(objeto.id);
      expect(partida.resultado!.acierto, isTrue);
    }
    expect(partida.completa, isTrue);
    expect(partida.progreso, 1);
    expect(partida.resultado!.frase, contains(partida.nivel.despedida));
    expect(partida.nivel.objetos.where((o) => !o.basura), isNotEmpty);
  });

  test('Medio: cada residuo va a su contenedor y el brik va al amarillo', () {
    final partida = PartidaRescate(nivel: nivel('medio'));
    final brik = partida.nivel.residuos.firstWhere((r) => r.id == 'brik');
    expect(brik.contenedor, 'amarillo');

    final primero = partida.residuoActual!;
    final otro = partida.nivel.contenedores
        .firstWhere((c) => c.id != primero.contenedor)
        .id;
    partida.tirar(otro);
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.residuoActual, primero);
    partida.tirar(otro);
    expect(partida.resultado!.gesto, 'pista');

    for (var i = 0; i < partida.nivel.residuos.length; i++) {
      partida.tirar(partida.residuoActual!.contenedor);
    }
    expect(partida.completa, isTrue);
    expect(partida.resultado!.frase, contains(partida.nivel.despedida));
  });

  test('Difícil: primero qué amenaza a la especie y después qué la ayuda', () {
    final partida = PartidaRescate(nivel: nivel('dificil'));
    final lince = partida.especieActual!;
    final malaAmenaza = lince.amenaza.opciones
        .firstWhere((o) => o.id != lince.amenaza.respuesta)
        .id;
    partida.responder(malaAmenaza);
    expect(partida.resultado!.acierto, isFalse);
    expect(partida.preguntaAyuda, isFalse);
    expect(
      () => partida.responder(lince.ayuda.respuesta),
      throwsArgumentError,
      reason: 'Antes hay que responder qué la amenaza',
    );

    partida.responder(lince.amenaza.respuesta);
    expect(partida.preguntaAyuda, isTrue);
    expect(partida.completa, isFalse);
    partida.responder(lince.ayuda.respuesta);
    expect(partida.especiesAyudadas, 1);

    while (partida.especieActual != null) {
      final especie = partida.especieActual!;
      partida.responder(especie.amenaza.respuesta);
      partida.responder(especie.ayuda.respuesta);
    }
    expect(partida.completa, isTrue);
    expect(partida.progreso, 1);
  });

  test('sin los tres niveles no se carga', () {
    expect(() => Rescate(niveles: [nivel('facil')]), throwsArgumentError);
  });
}
