import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> tocar(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key), skipOffstage: false);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Árbol, arbusto o hierba explica, da pista y avanza', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp());
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('zona-invernadero')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tocar(tester, 'zona-invernadero');
    expect(find.text('Árbol, arbusto o hierba'), findsOneWidget);
    await tocar(tester, 'juego-plantas');
    expect(find.text('Cromo: Encina'), findsOneWidget);

    await tocar(tester, 'nivel-facil');
    expect(
      find.byKey(const Key('sitio-arbusto'), skipOffstage: false),
      findsNothing,
    );
    await tocar(tester, 'sitio-hierba');
    expect(find.textContaining('leñoso'), findsOneWidget);
    await tocar(tester, 'sitio-hierba');
    expect(find.textContaining('Fíjate en su tronco'), findsOneWidget);
    await tocar(tester, 'sitio-arbol');
    expect(find.text('Siguiente', skipOffstage: false), findsOneWidget);

    await tocar(tester, 'cambiar-nivel');
    await tocar(tester, 'nivel-dificil');
    expect(
      find.byKey(const Key('sitio-arbusto'), skipOffstage: false),
      findsOneWidget,
    );
    await tocar(tester, 'sitio-arbol');
    expect(
      find.byKey(const Key('pregunta-adaptacion-encina'), skipOffstage: false),
      findsOneWidget,
    );
    await tocar(tester, 'adaptacion-encina-cultivada');
    expect(find.textContaining('bellotas'), findsWidgets);
    await tocar(tester, 'adaptacion-encina-silvestre');
    expect(find.text('Siguiente', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
