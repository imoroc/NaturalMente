import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/ui/dibujo_savia.dart';

void main() {
  const retos = [
    'absorcion-raiz',
    'captura-luz-sol',
    'reparto-planta',
    'subida-xilema',
    'clorofila-sol',
    'reparto-floema',
    'ascenso-tallo',
    'entrada-co2-hoja',
    'estomas-aire',
  ];

  testWidgets('la planta se dibuja en cada reto de la savia', (tester) async {
    for (final id in retos) {
      for (final (acertado, oculta) in [
        (false, false),
        (true, false),
        (false, true),
        (true, true),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: DibujoViajeSavia(
                    retoId: id,
                    acertado: acertado,
                    ocultarPista: oculta,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('dibujo-viaje-savia')), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  test('cada reto apunta a la raíz, al tallo o a la hoja', () {
    expect(DibujoViajeSavia.parteDe('absorcion-raiz'), 'raiz');
    for (final id in [
      'subida-xilema',
      'ascenso-tallo',
      'reparto-floema',
      'reparto-planta',
    ]) {
      expect(DibujoViajeSavia.parteDe(id), 'tallo');
    }
    for (final id in [
      'captura-luz-sol',
      'clorofila-sol',
      'entrada-co2-hoja',
      'estomas-aire',
    ]) {
      expect(DibujoViajeSavia.parteDe(id), 'hoja');
    }
  });
}
