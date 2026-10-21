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

  Future<void> abrirJuego(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp());
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('zona-cuerpo')).evaluate().isNotEmpty) break;
    }
    await tocar(tester, 'zona-cuerpo');
    expect(find.text('Los cinco sentidos'), findsWidgets);
    await tocar(tester, 'juego-sentidos');
  }

  testWidgets('Fácil une órganos y sentidos sin usar el atlas del cuerpo', (
    tester,
  ) async {
    await abrirJuego(tester);
    expect(find.text('Cromo: Los cinco sentidos'), findsOneWidget);
    await tocar(tester, 'nivel-facil');
    for (final sentido in ['vista', 'oido', 'olfato', 'gusto', 'tacto']) {
      expect(
        find.byKey(Key('sitio-$sentido'), skipOffstage: false),
        findsOneWidget,
      );
    }
    await tocar(tester, 'sitio-oido');
    expect(find.textContaining('¿Para qué sirven los ojos?'), findsOneWidget);
    await tocar(tester, 'sitio-tacto');
    expect(find.textContaining('Ciérralos un momento'), findsOneWidget);
    await tocar(tester, 'sitio-vista');
    expect(find.text('Siguiente', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Difícil pregunta por el cerebro y los actos reflejos', (
    tester,
  ) async {
    await abrirJuego(tester);
    await tocar(tester, 'nivel-dificil');
    await tocar(tester, 'sitio-olfato');
    expect(
      find.byKey(
        const Key('pregunta-adaptacion-incendio'),
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    await tocar(tester, 'adaptacion-incendio-sangre');
    expect(find.textContaining('viajan por los nervios'), findsOneWidget);
    await tocar(tester, 'adaptacion-incendio-nervios');
    expect(find.text('Siguiente', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
