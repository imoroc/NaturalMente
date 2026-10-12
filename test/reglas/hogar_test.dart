import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/reglas/hogar.dart';

void main() {
  test('el polo da frío y a la segunda añade la pista', () {
    final primera = fraseDelCamello(lugar: 'polo', intento: 1);
    final segunda = fraseDelCamello(lugar: 'polo', intento: 2);

    expect(primera, contains('frío'));
    expect(primera, isNot(contains('poca agua')));
    expect(segunda, contains('poca agua'));
    expect(lugarDelCamello('polo'), isFalse);

    for (final frase in [primera, segunda]) {
      final enMinusculas = frase.toLowerCase();
      expect(enMinusculas, isNot(contains('error')));
      expect(enMinusculas, isNot(contains('incorrecto')));
      expect(enMinusculas, isNot(contains('has fallado')));
      expect(enMinusculas, isNot(contains('mal hecho')));
    }
  });

  test('el desierto es el sitio del camello', () {
    expect(lugarDelCamello('desierto'), isTrue);
    expect(
      fraseDelCamello(lugar: 'desierto', intento: 2),
      contains('desierto'),
    );
  });
}
