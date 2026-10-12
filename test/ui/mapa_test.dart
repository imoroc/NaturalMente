import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('se puede fallar, seguir y no quedarse atascado', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NaturalmenteApp());
    await _hasta(tester, find.byKey(const Key('zona-reserva')));

    await tester.tap(find.byKey(const Key('zona-reserva')));
    await _esperar(tester);
    await tester.tap(find.byKey(const Key('juego-hogar')));
    await _esperar(tester);

    await tester.tap(find.byKey(const Key('sitio-polo')));
    await _esperar(tester);
    expect(find.textContaining('frío'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sitio-polo')));
    await _esperar(tester);
    expect(find.textContaining('poca agua'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sitio-desierto')));
    await _esperar(tester);
    expect(find.text('Siguiente'), findsOneWidget);

    await _atras(tester);
    await _atras(tester);

    final invernadero = find.byKey(const Key('zona-invernadero'), skipOffstage: false);
    await tester.ensureVisible(invernadero);
    await tester.tap(invernadero);
    await _esperar(tester);
    await tester.tap(find.byKey(const Key('juego-germinacion')));
    await _esperar(tester);
    await tester.tap(find.byKey(const Key('avanzar')));
    await _esperar(tester);
    expect(find.textContaining('Falta elegir'), findsOneWidget);
    expect(find.byKey(const Key('avanzar')), findsOneWidget);

    await _atras(tester);
    await _atras(tester);

    final cuerpo = find.byKey(const Key('zona-cuerpo'), skipOffstage: false);
    await tester.ensureVisible(cuerpo);
    await tester.tap(cuerpo);
    await _esperar(tester);
    final vida = find.byKey(const Key('juego-vida'), skipOffstage: false);
    await tester.ensureVisible(vida);
    await tester.tap(vida);
    await _esperar(tester);

    await tester.tap(find.byKey(const Key('paso-nace')));
    await _esperar(tester);
    await tester.tap(find.byKey(const Key('paso-celulas')));
    await _esperar(tester);
    await tester.tap(find.byKey(const Key('hueco-0')));
    await _esperar(tester);
    expect(find.textContaining('1. Se unen dos células'), findsOneWidget);

    await tester.tap(find.byKey(const Key('comprobar')));
    await _esperar(tester);
    expect(find.textContaining('cada uno una sola vez'), findsOneWidget);
    expect(find.byKey(const Key('comprobar')), findsOneWidget);
  });
}

Future<void> _esperar(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _hasta(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('No apareció el mapa.');
}

Future<void> _atras(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator)).pop();
  await _esperar(tester);
}
