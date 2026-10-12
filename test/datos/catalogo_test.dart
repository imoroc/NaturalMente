import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/resolver.dart';

void main() {
  late Catalogo catalogo;

  setUpAll(() {
    catalogo = Catalogo.desdeTexto(File('content/catalog.json').readAsStringSync());
  });

  test('cada actividad tiene tipo, curso y frases', () {
    expect(catalogo.actividades, isNotEmpty);
    for (final actividad in catalogo.actividades) {
      expect(actividad.tipo, isNotEmpty);
      expect(actividad.curso, isNotEmpty);
      expect(actividad.tieneFrases, isTrue);
    }
  });

  test('un animal nuevo del catálogo se resuelve sin una pantalla nueva', () {
    const reto = Reto(
      id: 'lince',
      nombre: 'El lince',
      pregunta: '¿Dónde vive?',
      respuesta: 'bosque',
      pista: 'Entre árboles.',
      frases: {
        'bosque': 'Sí, el bosque.',
        'desierto': 'Aquí no hay sombra.',
      },
    );
    final mal = resolverLugar(reto: reto, eleccion: 'desierto', intento: 2);
    expect(mal.acierto, isFalse);
    expect(mal.frase, contains('Entre árboles'));
    expect(mal.frase.toLowerCase(), isNot(contains('error')));
  });

  test('el camello en el polo habla de frío y a la segunda da la pista', () {
    final hogar = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final camello = hogar.retos.first;
    final primera = resolverLugar(reto: camello, eleccion: 'polo', intento: 1);
    final segunda = resolverLugar(reto: camello, eleccion: 'polo', intento: 2);
    expect(primera.frase, contains('frío'));
    expect(primera.frase, isNot(contains('poca agua')));
    expect(segunda.frase, contains('poca agua'));
    expect(primera.acierto, isFalse);
  });

  test('la judía brota solo con agua justa, luz y tierra de huerto', () {
    final juego = catalogo.actividades.firstWhere((a) => a.id == 'germinacion');
    expect(
      resolverControles(actividad: juego, valores: {'agua': 'mucha', 'luz': 'justa', 'suelo': 'huerto'}).estado,
      'ahogada',
    );
    expect(
      resolverControles(actividad: juego, valores: {'agua': 'justa', 'luz': 'poca', 'suelo': 'huerto'}).estado,
      'palida',
    );
    final brote = resolverControles(
      actividad: juego,
      valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'huerto'},
    );
    expect(brote.acierto, isTrue);
    expect(brote.estado, 'brote');
  });

  test('la vida no suelta el orden si faltan pasos', () {
    final vida = catalogo.actividades.firstWhere((a) => a.id == 'vida');
    final aMedias = resolverOrden(actividad: vida, orden: const ['nace']);
    expect(aMedias.acierto, isFalse);
    expect(aMedias.frase, contains('cuatro pasos'));
    expect(aMedias.frase, isNot(contains('crece')));
    final bien = resolverOrden(
      actividad: vida,
      orden: const ['celulas', 'utero', 'nace', 'cuidados'],
    );
    expect(bien.acierto, isTrue);
  });
}
