import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/ui/perfiles/quien_juega.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> abrirApp(WidgetTester tester, {String idioma = 'es'}) async {
    SharedPreferences.setMockInitialValues({
      'idioma': idioma,
      'sonido': false,
      'vibracion': false,
      'economia/semillas': 25,
    });
    await tester.binding.setSurfaceSize(const Size(400, 860));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false));
    final cabecera = find.byKey(const Key('abrir-quien-juega'));
    for (var i = 0; i < 30 && cabecera.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(cabecera, findsOneWidget);
  }

  int semillasEnPantalla(WidgetTester tester) => Alcance.of(
    tester.element(find.byKey(const Key('zona-reserva'))),
  ).progreso.semillas;

  for (final idioma in ['es', 'en']) {
    testWidgets('crear un jugador nuevo y volver al anterior ($idioma)', (
      tester,
    ) async {
      await abrirApp(tester, idioma: idioma);
      expect(semillasEnPantalla(tester), 25);
      expect(find.byKey(const Key('mote-inicio')), findsNothing);

      await tester.tap(find.byKey(const Key('abrir-quien-juega')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hoja-quien-juega')), findsOneWidget);
      await tester.tap(find.byKey(const Key('nuevo-perfil')));
      await tester.pumpAndSettle();
      expect(find.byType(EditorPerfilPage), findsOneWidget);

      final mote = tester.widget<Text>(find.byKey(const Key('mote-perfil')));
      await tester.tap(find.byKey(const Key('otro-mote')));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('mote-perfil'))).data,
        isNot(mote.data),
      );
      await tester.tap(find.byKey(const Key('color-morado')));
      await tester.tap(find.byKey(const Key('curso-nuevo-4')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('guardar-perfil')));
      await tester.tap(find.byKey(const Key('guardar-perfil')));
      await tester.pumpAndSettle();

      // Ya juega el nuevo, que empieza sin semillas y con su curso.
      expect(find.byType(EditorPerfilPage), findsNothing);
      expect(semillasEnPantalla(tester), 0);
      expect(find.byKey(const Key('mote-inicio')), findsOneWidget);
      expect(find.text('4º'), findsOneWidget);

      await tester.tap(find.byKey(const Key('abrir-quien-juega')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('perfil-principal')));
      await tester.pumpAndSettle();
      expect(semillasEnPantalla(tester), 25);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('borrar un jugador pide confirmación', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.byKey(const Key('abrir-quien-juega')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nuevo-perfil')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('guardar-perfil')));
    await tester.tap(find.byKey(const Key('guardar-perfil')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('abrir-quien-juega')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editar-perfil')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('borrar-perfil')));
    await tester.tap(find.byKey(const Key('borrar-perfil')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancelar-borrar-perfil')));
    await tester.pumpAndSettle();
    expect(find.byType(EditorPerfilPage), findsOneWidget);

    await tester.tap(find.byKey(const Key('borrar-perfil')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmar-borrar-perfil')));
    await tester.pumpAndSettle();
    expect(find.byType(EditorPerfilPage), findsNothing);
    expect(semillasEnPantalla(tester), 25);
    expect(find.byKey(const Key('mote-inicio')), findsNothing);
  });

  testWidgets('el perfil principal no se puede borrar', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.byKey(const Key('abrir-quien-juega')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editar-perfil')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('borrar-perfil')), findsNothing);
  });
}
