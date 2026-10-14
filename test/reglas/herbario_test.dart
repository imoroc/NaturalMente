import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/herbario.dart';
import 'package:naturalmente/reglas/herbario.dart';

void main() {
  late Herbario herbario;

  setUp(() {
    herbario = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    ).actividades.firstWhere((a) => a.id == 'herbario').herbario!;
  });

  PartidaHerbario partida(String nivel) => PartidaHerbario(
    herbario: herbario,
    nivel: herbario.niveles.firstWhere((n) => n.id == nivel),
  );

  test('un fallo conserva la pieza y el segundo añade su pista', () {
    final juego = partida('facil');
    juego.colocar('raiz', 'hoja');
    expect(juego.colocadas, isEmpty);
    expect(juego.seleccionada, 'raiz');
    expect(juego.resultado!.acierto, isFalse);
    expect(juego.ultimoDestino, 'hoja');
    expect(juego.falloColocacion, isTrue);
    expect(
      juego.resultado!.frase,
      isNot(contains(herbario.parte('raiz').reto.pista)),
    );
    juego.colocar('raiz', 'tallo');
    expect(juego.resultado!.frase, contains(herbario.parte('raiz').reto.pista));
    expect(juego.ultimoDestino, 'tallo');
    juego.colocar('raiz', 'raiz');
    expect(juego.colocadas, {'raiz'});
    expect(juego.seleccionada, isNull);
    expect(juego.puedeConsultar('raiz'), isTrue);
    expect(juego.falloColocacion, isFalse);
  });

  test(
    'seleccionar otra pieza limpia el fallo y una acción inválida lo conserva',
    () {
      final juego = partida('facil');
      juego.colocar('raiz', 'hoja');
      juego.colocar('raiz', 'inexistente');
      expect(juego.ultimoDestino, 'hoja');
      juego.seleccionar('tallo');
      expect(juego.ultimoDestino, isNull);
      expect(juego.falloColocacion, isFalse);
      expect(juego.resultado, isNull);
    },
  );

  test('ignora piezas repetidas y elementos ajenos al nivel', () {
    final juego = partida('facil');
    juego.colocar('flor', 'flor');
    juego.colocar('raiz', 'inexistente');
    expect(juego.colocadas, isEmpty);
    juego.colocar('raiz', 'raiz');
    juego.colocar('raiz', 'hoja');
    juego.seleccionar('raiz');
    expect(juego.colocadas, {'raiz'});
    expect(juego.seleccionada, isNull);
    expect(juego.resultado!.acierto, isTrue);
    expect(juego.completa, isFalse);
    expect(juego.progreso, 1 / 3);
  });

  test('Fácil termina con tres partes y Medio requiere las cinco', () {
    for (final nivel in ['facil', 'medio']) {
      final juego = partida(nivel);
      for (final id in juego.nivel.partes.take(juego.nivel.partes.length - 1)) {
        juego.colocar(id, id);
      }
      expect(juego.completa, isFalse);
      final ultima = juego.nivel.partes.last;
      juego.colocar(ultima, ultima);
      expect(juego.completa, isTrue);
      expect(juego.preguntaActual, isNull);
    }
  });

  test('Difícil no termina ni muestra fichas al colocar los rótulos', () {
    final juego = partida('dificil');
    juego.responder('agua');
    expect(juego.funcionesAcertadas, 0);
    for (final id in juego.nivel.partes) {
      juego.colocar(id, id);
      expect(juego.puedeConsultar(id), isFalse);
      expect(
        juego.resultado!.frase,
        isNot(contains(herbario.parte(id).funcion)),
      );
    }
    expect(juego.colocacionTerminada, isTrue);
    expect(juego.completa, isFalse);
    expect(juego.progreso, .5);
    final primera = herbario.parte(juego.preguntaActual!);
    final incorrecta = primera.pregunta.opciones.firstWhere(
      (o) => o.id != primera.pregunta.respuesta,
    );
    juego.responder(incorrecta.id);
    expect(juego.progreso, .5);
    expect(juego.resultado!.acierto, isFalse);
    expect(juego.funcionesAcertadas, 0);
    expect(juego.preguntaActual, primera.id);
    for (final id in juego.nivel.partes) {
      expect(juego.preguntaActual, id);
      juego.responder(herbario.parte(id).pregunta.respuesta);
      expect(juego.puedeConsultar(id), isTrue);
    }
    expect(juego.completa, isTrue);
    expect(juego.funcionesAcertadas, 5);
    expect(juego.progreso, 1);
  });

  test('una partida nueva no conserva las piezas de la anterior', () {
    final anterior = partida('facil');
    anterior.colocar('raiz', 'raiz');
    final nueva = partida('facil');
    expect(nueva.colocadas, isEmpty);
    expect(nueva.resultado, isNull);
    expect(nueva.ultimoDestino, isNull);
    expect(nueva.falloColocacion, isFalse);
    expect(nueva.progreso, 0);
    expect(nueva.completa, isFalse);
  });
}
