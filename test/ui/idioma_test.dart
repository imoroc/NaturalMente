import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('cambia toda la app y conserva la partida y los cromos', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _abrir(tester);
    expect(find.text('La reserva'), findsOneWidget);
    final selector = find.byKey(const Key('selector-idioma'));
    expect(selector, findsOneWidget);
    expect(
      tester.getBottomLeft(selector).dy,
      lessThan(tester.getTopLeft(find.text('MUNDOS PARA EXPLORAR')).dy),
    );
    await _tocar(tester, 'selector-idioma');
    expect(find.text('Efectos de sonido'), findsOneWidget);
    await _tocar(tester, 'ajuste-sonido');
    await _idioma(tester, 'en');
    expect(find.text('The reserve'), findsOneWidget);
    expect(find.text('WORLDS TO EXPLORE'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('en'),
    );

    await _tocar(tester, 'zona-reserva');
    expect(find.text('MISSIONS IN THIS AREA'), findsOneWidget);
    expect(find.byKey(const Key('selector-idioma')), findsNothing);
    await _tocar(tester, 'juego-hogar');
    expect(find.text('Easy'), findsOneWidget);
    await _tocar(tester, 'nivel-facil');
    await _tocar(tester, 'sitio-polo');
    expect(find.textContaining('Polar ice is too cold'), findsOneWidget);
    await _tocar(tester, 'sitio-polo');
    expect(find.textContaining('Think of a dry place'), findsOneWidget);
    await _tocar(tester, 'sitio-desierto');
    expect(find.text('Next', skipOffstage: false), findsOneWidget);
    await _idiomaEnPartida(tester, 'es');
    expect(find.text('Siguiente', skipOffstage: false), findsOneWidget);
    await _tocar(tester, 'curiosidad-camello');
    expect(find.text('CUADERNO DE NATU'), findsOneWidget);
    await _tocar(tester, 'cerrar-curiosidad');
    await _idiomaEnPartida(tester, 'en');
    await _tocar(tester, 'curiosidad-camello');
    expect(find.text("NATU'S NOTEBOOK"), findsOneWidget);
    expect(find.textContaining('fat'), findsOneWidget);
    await _tocar(tester, 'cerrar-curiosidad');
    await _atras(tester);
    await _atras(tester);
    await _tocar(tester, 'tarjeta-album-principal');
    expect(find.text("Natu's sticker album"), findsOneWidget);
    expect(find.byKey(const Key('selector-idioma')), findsNothing);
    expect(find.textContaining('All ('), findsOneWidget);
    expect(find.text('Camel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inglés al reabrir, germinación, cuerpo y herbario', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'idioma': 'en'});
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _abrir(tester);
    expect(find.text('The greenhouse'), findsOneWidget);
    await _tocar(tester, 'zona-invernadero');
    await _tocar(tester, 'juego-germinacion');
    await _tocar(tester, 'nivel-facil');
    await _tocar(tester, 'avanzar');
    expect(find.textContaining('Still to prepare:'), findsOneWidget);
    await _tocar(tester, 'control-suelo-algodon');
    await _tocar(tester, 'control-agua-justa');
    await _tocar(tester, 'control-luz-justa');
    await _tocar(tester, 'avanzar');
    expect(find.textContaining('Day 3'), findsWidgets);
    await _idiomaEnPartida(tester, 'es');
    expect(find.textContaining('Día 3'), findsWidgets);
    await _idiomaEnPartida(tester, 'en');
    expect(find.textContaining('Day 3'), findsWidgets);
    await _atras(tester);
    await _tocar(tester, 'juego-herbario');
    await _tocar(tester, 'nivel-facil');
    expect(find.text('Root', skipOffstage: false), findsWidgets);
    await _tocar(tester, 'pieza-raiz');
    expect(find.text('Selected: Root. Tap its place.'), findsOneWidget);
    await _idiomaEnPartida(tester, 'es');
    expect(find.text('Seleccionada: Raíz. Toca su sitio.'), findsOneWidget);
    await _idiomaEnPartida(tester, 'en');
    await _tocar(tester, 'destino-raiz');
    expect(find.textContaining('The root takes water'), findsWidgets);
    await _atras(tester);
    await _atras(tester);
    await _tocar(tester, 'zona-cuerpo');
    await _tocar(tester, 'juego-piezas');
    await _tocar(tester, 'nivel-facil');
    expect(find.text('Head', skipOffstage: false), findsWidgets);
    await _atras(tester);
    await _tocar(tester, 'juego-vida');
    await _tocar(tester, 'nivel-facil');
    await _tocar(tester, 'comprobar');
    expect(
      find.text('Include all four steps, each exactly once.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _abrir(WidgetTester tester) async {
  await tester.pumpWidget(const NaturalmenteApp());
  for (var i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byKey(const Key('zona-reserva')).evaluate().isNotEmpty) return;
  }
  fail('No apareció el mapa.');
}

Future<void> _tocar(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key), skipOffstage: key == 'selector-idioma');
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _idioma(WidgetTester tester, String codigo) async {
  await _tocar(tester, 'selector-idioma');
  await _tocar(tester, 'idioma-$codigo');
}

Future<void> _atras(WidgetTester tester) async {
  tester.state<NavigatorState>(find.byType(Navigator)).pop();
  await tester.pumpAndSettle();
}

Future<void> _idiomaEnPartida(WidgetTester tester, String codigo) async {
  expect(find.byKey(const Key('selector-idioma')), findsNothing);
  final context = tester.element(find.byType(Scaffold).last);
  await IdiomaScope.of(context)!.elegir(codigo);
  await tester.pumpAndSettle();
}
