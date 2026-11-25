import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/zona.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'soporte_cierre.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final idioma in ['es', 'en']) {
    testWidgets('los tres mundos se abren sin desplazar ($idioma)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'idioma': idioma});
      await tester.binding.setSurfaceSize(const Size(360, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.view.resetPadding);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
      await _hasta(tester, find.byKey(const Key('zona-reserva')));

      for (final id in ['reserva', 'invernadero', 'cuerpo']) {
        final tarjeta = find.byKey(Key('zona-$id'));
        final rect = tester.getRect(tarjeta);
        expect(rect.top, greaterThanOrEqualTo(24));
        expect(rect.bottom, lessThanOrEqualTo(676));
        expect(tarjeta.hitTestable(), findsOneWidget);
        await tester.tap(tarjeta);
        await _esperar(tester);
        expect(tester.widget<ZonaPage>(find.byType(ZonaPage)).zona.id, id);
        await _atras(tester);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('la tarjeta se hunde y vuelve al cancelar el toque', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
    final tarjeta = find.byKey(const Key('zona-reserva'));
    await _hasta(tester, tarjeta);
    final titulo = find.text('Animales');
    final reposo = tester.getTopLeft(titulo);

    final gesto = await tester.startGesture(tester.getCenter(tarjeta));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(titulo).dy, reposo.dy + 4);
    await gesto.cancel();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(titulo), reposo);
    expect(find.byType(ZonaPage), findsNothing);
  });

  testWidgets('se puede recorrer el inicio con texto grande', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 590));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.platformDispatcher.textScaleFactorTestValue = 2;

    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
    await _hasta(tester, find.byKey(const Key('zona-reserva')));
    for (final id in [
      'zona-cuerpo',
      'abrir-expedicion-diaria',
      'tarjeta-album-principal',
      'abrir-armario-natu',
      'selector-idioma',
    ]) {
      final acceso = find.byKey(Key(id));
      await tester.ensureVisible(acceso);
      await tester.pump();
      expect(acceso.hitTestable(), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('el reto de hoy y el armario muestran el progreso guardado', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
    final mundo = find.byKey(const Key('zona-cuerpo'));
    await _hasta(tester, mundo);
    final progreso = Alcance.of(tester.element(mundo)).progreso;
    expect(find.text('Completado por hoy'), findsNothing);
    expect(find.byTooltip('Racha: 0 días'), findsOneWidget);
    await _tocar(tester, const Key('abrir-racha-inicio'));
    expect(find.byKey(const Key('dificultad-reto-facil')), findsOneWidget);
    await _atras(tester);

    await tester.runAsync(() => progreso.completarExpedicionDiaria());
    await tester.pump();
    expect(find.text('Completado por hoy'), findsOneWidget);
    expect(find.byTooltip('Racha: 1 día'), findsOneWidget);
    await _tocar(tester, const Key('abrir-expedicion-diaria'));
    expect(find.byKey(const Key('expedicion-completada')), findsOneWidget);
    expect(find.byKey(const Key('dificultad-reto-facil')), findsNothing);
    await _atras(tester);

    await _tocar(tester, const Key('abrir-armario-natu'));
    expect(find.byKey(const Key('cerrar-armario-natu')), findsOneWidget);
    await _atras(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el botón del curso cambia el mismo curso que los ajustes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
    final mundo = find.byKey(const Key('zona-cuerpo'));
    await _hasta(tester, mundo);
    final progreso = Alcance.of(tester.element(mundo)).progreso;
    final boton = find.byKey(const Key('abrir-curso-inicio'));
    expect(find.byTooltip('Elige tu curso'), findsOneWidget);
    expect(
      find.descendant(of: boton, matching: find.text('?')),
      findsOneWidget,
    );

    await _tocar(tester, const Key('abrir-curso-inicio'));
    expect(find.byKey(const Key('hoja-curso')), findsOneWidget);
    await _tocar(tester, const Key('curso-3'));
    await tester.pumpAndSettle();
    expect(progreso.curso, 3);
    expect(find.byKey(const Key('hoja-curso')), findsNothing);
    expect(
      find.descendant(of: boton, matching: find.text('3º')),
      findsOneWidget,
    );

    await _tocar(tester, const Key('selector-idioma'));
    final enAjustes = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byKey(const Key('curso-3')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(enAjustes.properties.selected, isTrue);
    await _tocar(tester, const Key('curso-5'));
    await tester.pumpAndSettle();
    expect(progreso.curso, 5);
    await _tocar(tester, const Key('cerrar-ajustes'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: boton, matching: find.text('5º')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('se puede fallar, seguir y no quedarse atascado', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
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
    await _tocar(tester, const Key('tarjeta-album-principal'));
    expect(find.textContaining('Cromos conseguidos: 1 de '), findsOneWidget);
    await _atras(tester);

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

    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
    await _hasta(tester, find.byKey(const Key('zona-reserva')));

    await _tocar(tester, const Key('tarjeta-album-principal'));
    expect(find.byKey(const Key('album-reserva')), findsOneWidget);
    expect(find.byKey(const Key('album-invernadero')), findsOneWidget);
    expect(find.byKey(const Key('album-cuerpo')), findsOneWidget);
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
  await seguirExplorando(tester);
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
  // El recorrido espera la confirmación y su transición, sin asumir que
  // la siguiente pregunta aparece debajo de un check todavía abierto.
  if (find.byType(AnimacionAcierto).evaluate().isNotEmpty) {
    await tester.pumpAndSettle();
  }
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
