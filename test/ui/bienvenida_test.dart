import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(
    () => SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
      'musica': false,
    }),
  );

  test('el curso recomienda el nivel de su ciclo', () {
    expect(Progreso.nivelParaCurso(null), isNull);
    expect(Progreso.nivelParaCurso(1), 'facil');
    expect(Progreso.nivelParaCurso(2), 'facil');
    expect(Progreso.nivelParaCurso(3), 'medio');
    expect(Progreso.nivelParaCurso(4), 'medio');
    expect(Progreso.nivelParaCurso(5), 'dificil');
    expect(Progreso.nivelParaCurso(6), 'dificil');
    expect(Progreso.nivelParaCurso(7), isNull);
  });

  testWidgets('la primera vez Natu da la bienvenida y se elige el curso', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NaturalmenteApp());
    await _hasta(tester, find.byKey(const Key('bienvenida')));
    expect(find.text('¡Hola! Soy Natu'), findsOneWidget);

    await _tocar(tester, const Key('bienvenida-siguiente'));
    expect(find.text('Gana cromos y semillas'), findsOneWidget);
    await _tocar(tester, const Key('bienvenida-siguiente'));
    expect(find.text('¿En qué curso estás?'), findsOneWidget);

    // Sin curso no se puede empezar, pero sí saltar.
    final empezar = tester.widget<ButtonStyleButton>(
      find.byKey(const Key('bienvenida-siguiente')),
    );
    expect(empezar.onPressed, isNull);

    await _tocar(tester, const Key('bienvenida-curso-4'));
    expect(
      find.text('Te recomendaremos el nivel Medio. Puedes jugar todos.'),
      findsOneWidget,
    );
    await _tocar(tester, const Key('bienvenida-siguiente'));
    await _hasta(tester, find.byKey(const Key('zona-reserva')));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('perfil/curso'), 4);
    expect(prefs.getBool('perfil/bienvenida-vista'), isTrue);

    // El nivel Medio aparece recomendado, y los demás siguen abiertos.
    await _tocar(tester, const Key('zona-reserva'));
    await _tocar(tester, const Key('juego-hogar'));
    expect(find.byKey(const Key('recomendado-medio')), findsOneWidget);
    expect(find.byKey(const Key('recomendado-facil')), findsNothing);
    expect(find.byKey(const Key('nivel-facil')), findsOneWidget);
    expect(find.byKey(const Key('nivel-dificil')), findsOneWidget);
  });

  testWidgets('saltar la bienvenida entra al mapa sin curso y no vuelve', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NaturalmenteApp());
    await _hasta(tester, find.byKey(const Key('bienvenida')));
    await _tocar(tester, const Key('bienvenida-saltar'));
    await _hasta(tester, find.byKey(const Key('zona-reserva')));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('perfil/curso'), isNull);
    expect(prefs.getBool('perfil/bienvenida-vista'), isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(NaturalmenteApp(key: UniqueKey()));
    await _hasta(tester, find.byKey(const Key('zona-reserva')));
    expect(find.byKey(const Key('bienvenida')), findsNothing);
  });

  testWidgets('el curso se cambia desde Ajustes de Natu', (tester) async {
    SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
      'musica': false,
      'perfil/bienvenida-vista': true,
      'perfil/curso': 1,
    });
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NaturalmenteApp());
    await _hasta(tester, find.byKey(const Key('zona-reserva')));
    await _tocar(tester, const Key('selector-idioma'));
    expect(
      find.text('Te recomendaremos el nivel Fácil. Puedes jugar todos.'),
      findsOneWidget,
    );

    await _tocar(tester, const Key('curso-6'));
    expect(
      find.text('Te recomendaremos el nivel Difícil. Puedes jugar todos.'),
      findsOneWidget,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('perfil/curso'), 6);
  });
}

Future<void> _tocar(WidgetTester tester, Key key) async {
  final finder = find.byKey(key, skipOffstage: false);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<void> _hasta(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('No apareció $finder.');
}
