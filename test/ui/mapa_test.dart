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

    await _tocar(tester, const Key('zona-reserva'));
    await _tocar(tester, const Key('juego-hogar'));
    await _tocar(tester, const Key('nivel-facil'));

    await _tocar(tester, const Key('sitio-polo'));
    expect(find.textContaining('frío'), findsOneWidget);

    await _tocar(tester, const Key('sitio-polo'));
    expect(find.textContaining('poca agua'), findsOneWidget);

    await _tocar(tester, const Key('sitio-desierto'));
    expect(find.text('Siguiente', skipOffstage: false), findsNothing);
    expect(find.textContaining('Reto 2 de '), findsOneWidget);

    await _atras(tester);
    await _atras(tester);
    expect(find.text('1/40', skipOffstage: false), findsNWidgets(2));

    await _tocar(tester, const Key('zona-invernadero'));
    await _tocar(tester, const Key('juego-germinacion'));
    await _tocar(tester, const Key('nivel-facil'));
    await _tocar(tester, const Key('avanzar'));
    expect(find.textContaining('Falta preparar'), findsOneWidget);
    expect(find.byKey(const Key('avanzar'), skipOffstage: false), findsOneWidget);

    // Día 1 -> Día 3 (sale la primera raíz)
    await _tocar(tester, const Key('control-suelo-algodon'));
    await _tocar(tester, const Key('control-agua-justa'));
    await _tocar(tester, const Key('control-luz-justa'));
    await _tocar(tester, const Key('avanzar'));
    expect(find.textContaining('Día 3'), findsWidgets);

    // Día 3 -> Día 5 (la planta bebió agua; volvemos a regar para que suba el tallo)
    await _tocar(tester, const Key('control-agua-justa'));
    await _tocar(tester, const Key('avanzar'));
    expect(find.textContaining('Día 5'), findsWidgets);

    // Día 5 -> Día 7 (último riego para abrir las hojas verdes)
    await _tocar(tester, const Key('control-agua-justa'));
    await _tocar(tester, const Key('avanzar'));
    expect(find.byKey(const Key('curiosidad-germinacion'), skipOffstage: false), findsOneWidget);
    expect(find.byKey(const Key('etapa-germinacion-1'), skipOffstage: false), findsOneWidget);
    await _tocar(tester, const Key('etapa-germinacion-1'));
    expect(find.byKey(const Key('volver-controles'), skipOffstage: false), findsOneWidget);

    await _atras(tester);
    await _atras(tester);

    await _tocar(tester, const Key('zona-cuerpo'));
    await _tocar(tester, const Key('juego-vida'));
    await _tocar(tester, const Key('nivel-facil'));

    await _tocar(tester, const Key('paso-nace'));
    await _tocar(tester, const Key('paso-celulas'));
    await _tocar(tester, const Key('hueco-0'));
    expect(find.textContaining('1. Se unen dos células'), findsOneWidget);

    await _tocar(tester, const Key('comprobar'));
    expect(find.textContaining('cada uno una sola vez'), findsOneWidget);
    expect(find.byKey(const Key('comprobar'), skipOffstage: false), findsOneWidget);

    await _tocar(tester, const Key('paso-utero'));
    await _tocar(tester, const Key('paso-nace'));
    await _tocar(tester, const Key('paso-cuidados'));
    await _tocar(tester, const Key('comprobar'));

    expect(find.byKey(const Key('comprobar'), skipOffstage: false), findsNothing);
    expect(find.byKey(const Key('volver-orden'), skipOffstage: false), findsOneWidget);
    expect(find.byKey(const Key('otra-vez-orden'), skipOffstage: false), findsOneWidget);

    await _tocar(tester, const Key('curiosidad-vida'));
    expect(find.text('CUADERNO DE NATU'), findsOneWidget);
    expect(find.textContaining('ombligo'), findsOneWidget);
    await _tocar(tester, const Key('cerrar-curiosidad'));
  });

  testWidgets('la dificultad se elige antes de empezar y se puede cambiar de nivel', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NaturalmenteApp());
    await _hasta(tester, find.byKey(const Key('zona-reserva')));

    await _tocar(tester, const Key('tarjeta-album-principal'));
    expect(find.textContaining('Todos ('), findsOneWidget);
    await _atras(tester);

    await _tocar(tester, const Key('zona-reserva'));
    await _tocar(tester, const Key('juego-hogar'));

    expect(find.byKey(const Key('nivel-facil')), findsOneWidget);
    expect(find.byKey(const Key('nivel-medio')), findsOneWidget);
    expect(find.byKey(const Key('nivel-dificil')), findsOneWidget);
    expect(find.byKey(const Key('sitio-desierto')), findsNothing);

    await _tocar(tester, const Key('nivel-facil'));

    await _tocar(tester, const Key('sitio-desierto'));
    expect(find.text('Siguiente', skipOffstage: false), findsNothing);
    expect(find.textContaining('Reto 2 de '), findsOneWidget);

    await _tocar(tester, const Key('cambiar-nivel'));
    expect(find.byKey(const Key('nivel-medio')), findsOneWidget);

    await _tocar(tester, const Key('nivel-medio'));
    expect(find.byKey(const Key('sitio-selva'), skipOffstage: false), findsOneWidget);
    expect(find.byKey(const Key('sitio-rio'), skipOffstage: false), findsOneWidget);

    await _tocar(tester, const Key('sitio-desierto'));
    expect(
      find.byKey(const Key('pregunta-adaptacion-camello'), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byKey(const Key('curiosidad-camello'), skipOffstage: false), findsOneWidget);
    await _tocar(tester, const Key('curiosidad-camello'));
    expect(find.text('CUADERNO DE NATU'), findsOneWidget);
    expect(find.textContaining('grasa'), findsOneWidget);
    await _tocar(tester, const Key('cerrar-curiosidad'));

    await _tocar(tester, const Key('adaptacion-camello-joroba'));
    expect(find.text('Siguiente', skipOffstage: false), findsNothing);
    expect(find.textContaining('Reto 2 de '), findsOneWidget);
  });
}

Future<void> _tocar(WidgetTester tester, Key key) async {
  final finder = find.byKey(key, skipOffstage: false);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _esperar(tester);
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
