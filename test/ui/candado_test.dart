import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dosJugadores =
    '[{"id":"principal","animal":"oso","adjetivo":"libre","color":"naranja"},'
    '{"id":"p2","animal":"rana","adjetivo":"feliz","color":"rosa"}]';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> abrir(
    WidgetTester tester,
    Map<String, Object> valores, {
    Size tamano = const Size(420, 900),
  }) async {
    SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
      ...valores,
    });
    await tester.binding.setSurfaceSize(tamano);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const NaturalmenteApp(conBienvenida: false, usarNube: false));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('zona-reserva')).evaluate().isNotEmpty) break;
    }
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String clave) async {
    await tester.ensureVisible(find.byKey(Key(clave)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(clave)));
    await tester.pumpAndSettle();
  }

  Future<void> dibujos(WidgetTester tester, List<String> ids) async {
    for (final id in ids) {
      await tocar(tester, 'candado-dibujo-$id');
    }
  }

  testWidgets('con candado, al abrir la app hay que tocar los tres dibujos', (tester) async {
    await abrir(tester, {
      'perfiles/lista': _dosJugadores,
      'perfiles/activo': 'p2',
      'perfiles/p2/perfil/candado': 'zorro-sol-pez',
    });
    expect(find.byKey(const Key('pantalla-candado')), findsOneWidget);
    // La app de debajo no se puede tocar.
    await tester.tap(find.byKey(const Key('zona-reserva')), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pantalla-candado')), findsOneWidget);

    await dibujos(tester, ['zorro', 'pez', 'sol']);
    expect(find.text('Esos no son. Prueba otra vez.'), findsOneWidget);
    await dibujos(tester, ['zorro', 'sol', 'pez']);
    expect(find.byKey(const Key('pantalla-candado')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desde el candado se puede elegir a otro jugador', (tester) async {
    await abrir(tester, {
      'perfiles/lista': _dosJugadores,
      'perfiles/activo': 'p2',
      'perfiles/p2/perfil/candado': 'zorro-sol-pez',
    });
    await tocar(tester, 'candado-otro');
    await tocar(tester, 'candado-perfil-principal');
    expect(find.byKey(const Key('pantalla-candado')), findsNothing);
    final perfiles = PerfilesScope.of(tester.element(find.byKey(const Key('zona-reserva'))));
    expect(perfiles.activo.id, Perfiles.idPrincipal);
  });

  testWidgets('si lo olvida, un mayor lo quita resolviendo una cuenta', (tester) async {
    await abrir(tester, {
      'perfiles/lista': _dosJugadores,
      'perfiles/activo': 'p2',
      'perfiles/p2/perfil/candado': 'zorro-sol-pez',
    });
    await tocar(tester, 'candado-olvidado');
    final cuenta = tester.widget<Text>(find.byKey(const Key('candado-cuenta'))).data!;
    final partes = RegExp(r'(\d+) × (\d+)').firstMatch(cuenta)!;
    final resultado = int.parse(partes[1]!) * int.parse(partes[2]!);
    for (final cifra in '$resultado'.split('')) {
      await tocar(tester, 'candado-tecla-$cifra');
    }
    await tocar(tester, 'candado-quitar');
    expect(find.byKey(const Key('pantalla-candado')), findsNothing);
    final perfiles = PerfilesScope.of(tester.element(find.byKey(const Key('zona-reserva'))));
    expect(perfiles.candado('p2'), isNull);
  });

  testWidgets('el niño pone su candado desde Mi Natu', (tester) async {
    await abrir(tester, {});
    await tocar(tester, 'abrir-quien-juega');
    await tocar(tester, 'editar-perfil');
    await tocar(tester, 'poner-candado');
    await dibujos(tester, ['luna', 'flor', 'abeja']);
    final perfiles = PerfilesScope.of(tester.element(find.byKey(const Key('seccion-candado'))));
    expect(perfiles.candado(Perfiles.idPrincipal), ['luna', 'flor', 'abeja']);
    // Recién puesto queda abierto: no se pide ahora mismo.
    expect(find.byKey(const Key('pantalla-candado')), findsNothing);
    // Tras un rato fuera de la app, se vuelve a pedir.
    perfiles.cerrarCandados();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pantalla-candado')), findsOneWidget);
  });

  testWidgets('en una pantalla ancha el inicio usa dos columnas', (tester) async {
    await abrir(tester, {}, tamano: const Size(1440, 900));
    final mundo = tester.getRect(find.byKey(const Key('zona-reserva')));
    final aula = tester.getRect(find.byKey(const Key('abrir-aula')));
    expect(aula.left, greaterThan(mundo.right), reason: 'Aula a la derecha de los mundos');
    expect(mundo.left, lessThan(300), reason: 'sin una franja vacía enorme a la izquierda');
    expect(tester.takeException(), isNull);
  });

  testWidgets('la opción de leer en voz alta empieza apagada y se puede activar', (tester) async {
    await abrir(tester, {});
    await tocar(tester, 'selector-idioma');
    final interruptor = find.byKey(const Key('ajuste-leer-voz'));
    if (interruptor.evaluate().isEmpty) {
      await tester.scrollUntilVisible(interruptor, 120, scrollable: find.byType(Scrollable).last);
    }
    await tester.ensureVisible(interruptor);
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.descendant(of: interruptor, matching: find.byType(Switch))).value, isFalse);
    await tester.tap(interruptor);
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('voz/leer'), isTrue);
  });

  test('los trajes de Aula se ganan al completar 3 y 10 juegos', () async {
    SharedPreferences.setMockInitialValues({});
    final progreso = Progreso.leer(await SharedPreferences.getInstance());
    final catalogo = Catalogo.desdeTexto(File('content/catalog.json').readAsStringSync());
    for (var i = 0; i < 2; i++) {
      await progreso.marcarJuegoAula('juego-$i', 1);
    }
    await progreso.marcarJuegoAula('juego-0', 2);
    expect(progreso.juegosAulaCompletados, 2, reason: 'otra versión del mismo juego no cuenta');
    expect(await progreso.sincronizarLogrosTrajes(catalogo.actividades), isEmpty);
    await progreso.marcarJuegoAula('juego-2', 1);
    expect(await progreso.sincronizarLogrosTrajes(catalogo.actividades), ['birrete_aula']);
    for (var i = 3; i < 10; i++) {
      await progreso.marcarJuegoAula('juego-$i', 1);
    }
    expect(await progreso.sincronizarLogrosTrajes(catalogo.actividades), ['medalla_aula']);
    expect(Progreso.slotDeTraje('birrete_aula'), 'cabeza');
    expect(Progreso.slotDeTraje('medalla_aula'), 'insignia');
    expect(Alcance, isNotNull);
  });
}
