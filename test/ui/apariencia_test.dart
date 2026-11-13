import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/apariencia.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/ui/expedicion_diaria.dart';
import 'package:naturalmente/ui/juego.dart';
import 'package:naturalmente/ui/laboratorio_zona.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/zona.dart';
import 'package:naturalmente/ui/planta.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _tocar(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<Apariencia> _abrir(
  WidgetTester tester, {
  String idioma = 'es',
  Apariencia? controlador,
}) async {
  await tester.binding.setSurfaceSize(const Size(430, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  SharedPreferences.setMockInitialValues({
    'sonido': false,
    'musica': false,
    'vibracion': false,
    'idioma': idioma,
  });
  final apariencia = controlador ?? await Apariencia.abrir();
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('captura-apariencia'),
      child: NaturalmenteApp(apariencia: apariencia),
    ),
  );
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byKey(const Key('zona-reserva')).evaluate().isNotEmpty) break;
  }
  expect(find.byKey(const Key('zona-reserva')), findsOneWidget);
  return apariencia;
}

Brightness _brillo(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).last)).brightness;

Future<void> _capturar(WidgetTester tester, String nombre) async {
  await expectLater(
    find.byKey(const Key('captura-apariencia')),
    matchesGoldenFile('goldens/apariencia/$nombre.png'),
  );
  if (!const bool.fromEnvironment('CAPTURAR_TEMAS')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('captura-apariencia')),
  );
  await tester.runAsync(() async {
    final imagen = await boundary.toImage();
    final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
    await Directory('/tmp/naturalmente-temas').create(recursive: true);
    await File('/tmp/naturalmente-temas/$nombre.png')
        .writeAsBytes(datos!.buffer.asUint8List());
    imagen.dispose();
  });
}

double _contraste(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
}

class _DiscoLleno extends Fake implements SharedPreferences {
  @override
  String? getString(String key) => null;
  @override
  Future<bool> setString(String key, String value) async => false;
}

void main() {
  test('paletas y adaptación de textos tienen contraste y transición', () {
    for (final brillo in Brightness.values) {
      final tema = TemaNatural.crear(brillo);
      final c = tema.extension<ColoresNaturales>()!;
      for (final pareja in [
        (c.tinta, c.tarjeta),
        (c.tenue, c.fondo),
        (c.acierto, c.fondoAcierto),
        (c.pista, c.fondoPista),
        (tema.colorScheme.onPrimary, tema.colorScheme.primary),
        (tema.colorScheme.onSecondary, tema.colorScheme.secondary),
      ]) {
        expect(_contraste(pareja.$1, pareja.$2), greaterThanOrEqualTo(4.5));
      }
      for (final tinta in [
        const Color(0xFF1E293B),
        const Color(0xFF15803D),
        const Color(0xFFB45309),
      ]) {
        for (final fondo in [
          Colors.white,
          const Color(0xFFECFDF5),
          const Color(0xFFFEF3C7),
        ]) {
          if (brillo == Brightness.dark) {
            expect(
              _contraste(c.contenido(tinta), c.superficie(fondo)),
              greaterThanOrEqualTo(4.5),
            );
          }
        }
      }
    }
    const claro = ColoresNaturales(oscuro: false);
    const oscuro = ColoresNaturales(oscuro: true);
    expect(
      claro.lerp(oscuro, .5).tarjeta,
      Color.lerp(claro.tarjeta, oscuro.tarjeta, .5),
    );
  });

  testWidgets('fallo de guardado conserva el modo y muestra una explicación', (
    tester,
  ) async {
    final apariencia = await _abrir(
      tester,
      controlador: Apariencia(_DiscoLleno()),
    );
    await _tocar(tester, 'selector-idioma');
    await _tocar(tester, 'apariencia-oscuro');
    expect(apariencia.modo, ModoApariencia.sistema);
    expect(
      find.text('No se ha podido guardar la apariencia. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    final aviso = tester.getRect(find.byKey(const Key('error-ajustes')));
    final panel = tester.getRect(find.byKey(const Key('panel-ajustes')));
    expect(aviso.top, greaterThan(panel.top));
    expect(aviso.bottom, lessThan(panel.bottom));
    await _tocar(tester, 'apariencia-oscuro');
    expect(find.byKey(const Key('error-ajustes')), findsOneWidget);
    expect(find.byKey(const Key('panel-ajustes')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'automático responde al teléfono y los modos manuales prevalecen',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final apariencia = await _abrir(tester);
      expect(_brillo(tester), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(_brillo(tester), Brightness.dark);
      await apariencia.elegir(ModoApariencia.claro);
      await tester.pumpAndSettle();
      expect(_brillo(tester), Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await apariencia.elegir(ModoApariencia.oscuro);
      await tester.pumpAndSettle();
      expect(_brillo(tester), Brightness.dark);
      await apariencia.elegir(ModoApariencia.sistema);
      await tester.pumpAndSettle();
      expect(_brillo(tester), Brightness.light);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(_brillo(tester), Brightness.dark);
    },
  );

  for (final idioma in ['es', 'en']) {
    testWidgets('selector y menú completo traducidos $idioma', (tester) async {
      final apariencia = await _abrir(tester, idioma: idioma);
      await _capturar(tester, 'mapa-claro-$idioma');
      await _tocar(tester, 'selector-idioma');
      expect(
        find.text(
          idioma == 'es' ? 'Según el teléfono' : 'Follow phone settings',
        ),
        findsOneWidget,
      );
      await _capturar(tester, 'ajustes-claro-$idioma');
      await _tocar(tester, 'apariencia-oscuro');
      expect(apariencia.modo, ModoApariencia.oscuro);
      expect(_brillo(tester), Brightness.dark);
      expect(find.byKey(const Key('panel-ajustes')), findsOneWidget);
      await _tocar(tester, 'listo-ajustes');
      await _capturar(tester, 'mapa-oscuro-$idioma');
      await _tocar(tester, 'selector-idioma');
      await _capturar(tester, 'ajustes-oscuro-$idioma');
      // Las opciones de idioma y sonido siguen siendo alcanzables al crecer el menú.
      await _tocar(tester, 'idioma-${idioma == 'es' ? 'en' : 'es'}');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ajustes accesibles con texto grande en pantalla pequeña', (
    tester,
  ) async {
    await _abrir(tester);
    await tester.binding.setSurfaceSize(const Size(360, 640));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    await _tocar(tester, 'selector-idioma');
    await _tocar(tester, 'apariencia-oscuro');
    expect(find.byKey(const Key('panel-ajustes')), findsOneWidget);
    await _capturar(tester, 'ajustes-compacto-oscuro');
    await _tocar(tester, 'idioma-en');
    await _tocar(tester, 'listo-ajustes');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'ajustes permanecen abiertos, botones alineados y cambios independientes',
    (tester) async {
      final apariencia = await _abrir(tester);
      await _tocar(tester, 'selector-idioma');
      final panel = find.byKey(const Key('panel-ajustes'));
      final semantics = tester.ensureSemantics();
      try {
        final estado = tester.state(
          find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_PanelAjustes',
          ),
        );
        final botones = [
          for (final modo in ['claro', 'oscuro', 'sistema'])
            tester.getRect(find.byKey(Key('apariencia-$modo'))),
        ];
        expect(botones[0].top, botones[1].top);
        expect(botones[1].top, botones[2].top);
        expect(botones[0].height, botones[2].height);
        expect(botones[0].right, lessThan(botones[1].left));
        expect(botones[1].right, lessThan(botones[2].left));
        final idioma = IdiomaScope.of(tester.element(panel))!;
        for (final modo in ['oscuro', 'claro', 'sistema']) {
          await _tocar(tester, 'apariencia-$modo');
          expect(panel, findsOneWidget);
          expect(apariencia.modo.name, modo);
          expect(
            tester
                .getSemantics(find.byKey(Key('apariencia-$modo')))
                .flagsCollection
                .isSelected,
            ui.Tristate.isTrue,
          );
        }
        await _tocar(tester, 'apariencia-oscuro');
        expect(Theme.of(tester.element(panel)).brightness, Brightness.dark);
        await _tocar(tester, 'ajuste-vibracion');
        expect(idioma.vibracion, true);
        expect(idioma.sonido, false);
        expect(idioma.musica, false);
        await _tocar(tester, 'ajuste-sonido');
        expect(idioma.sonido, true);
        expect(idioma.vibracion, true);
        await _tocar(tester, 'ajuste-sonido');
        await _tocar(tester, 'ajuste-vibracion');
        await _tocar(tester, 'ajuste-musica');
        expect(idioma.musica, true);
        expect(idioma.sonido, false);
        expect(idioma.vibracion, false);
        await _tocar(tester, 'ajuste-musica');
        await _tocar(tester, 'idioma-en');
        expect(find.text('Sound and vibration'), findsOneWidget);
        expect(
          tester.state(
            find.byWidgetPredicate(
              (w) => w.runtimeType.toString() == '_PanelAjustes',
            ),
          ),
          same(estado),
        );
        expect(panel, findsOneWidget);
        await _tocar(tester, 'listo-ajustes');
        expect(panel, findsNothing);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('apariencia'), 'oscuro');
        expect(prefs.getString('idioma'), 'en');
        await _tocar(tester, 'selector-idioma');
        expect(
          tester
              .getSemantics(find.byKey(const Key('idioma-en')))
              .flagsCollection
              .isSelected,
          ui.Tristate.isTrue,
        );
        await _tocar(tester, 'cerrar-ajustes');
        expect(panel, findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'se cierra con atrás o al tocar fuera, sin descartar preferencias',
    (tester) async {
      final apariencia = await _abrir(tester);
      await _tocar(tester, 'selector-idioma');
      await _tocar(tester, 'apariencia-oscuro');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('panel-ajustes')), findsNothing);
      expect(apariencia.modo, ModoApariencia.oscuro);
      await _tocar(tester, 'selector-idioma');
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('panel-ajustes')), findsNothing);
      expect(apariencia.modo, ModoApariencia.oscuro);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('zonas y fichas usan las dos paletas', (tester) async {
    final apariencia = await _abrir(tester);
    for (final modo in [ModoApariencia.claro, ModoApariencia.oscuro]) {
      await apariencia.elegir(modo);
      await tester.pumpAndSettle();
      await _tocar(tester, 'zona-reserva');
      await _capturar(tester, 'zona-${modo.name}');
      final context = tester.element(find.byType(Scaffold).last);
      final ficha = Alcance.of(context).catalogo.fichasDe('reserva').first;
      mostrarDetalleFicha(context, ficha, desbloqueada: true);
      await tester.pumpAndSettle();
      await _capturar(tester, 'ficha-${modo.name}');
      await _tocar(tester, 'cerrar-detalle-ficha');
      Navigator.of(context).pop();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('armario oscuro sobre el mapa', (tester) async {
    final apariencia = await _abrir(tester);
    await apariencia.elegir(ModoApariencia.oscuro);
    await tester.pumpAndSettle();
    mostrarArmarioNatu(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
    await _capturar(tester, 'armario-oscuro');
    await _tocar(tester, 'cerrar-armario-natu');
    expect(tester.takeException(), isNull);
  });

  testWidgets('tablero de herbario con estados fijos en ambos temas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final brillo in Brightness.values) {
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('captura-apariencia'),
          child: MaterialApp(
            theme: TemaNatural.crear(brillo),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: PlantaHerbario(
                    nombres: const {
                      'raiz': 'Raíz',
                      'tallo': 'Tallo',
                      'hoja': 'Hoja',
                      'flor': 'Flor',
                      'fruto': 'Fruto',
                    },
                    colocadas: const {'raiz', 'tallo'},
                    seleccionada: 'hoja',
                    onColocar: (_, _) {},
                    onConsultar: (_) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _capturar(tester, 'tablero-herbario-${brillo.name}');
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('cambiar con partida y armario abiertos conserva ruta y estado', (
    tester,
  ) async {
    final apariencia = await _abrir(tester);
    await _tocar(tester, 'zona-reserva');
    await _tocar(tester, 'juego-hogar');
    await apariencia.elegir(ModoApariencia.oscuro);
    await tester.pumpAndSettle();
    await _capturar(tester, 'selector-oscuro');
    await apariencia.elegir(ModoApariencia.claro);
    await tester.pumpAndSettle();
    await _tocar(tester, 'nivel-facil');
    await _tocar(tester, 'sitio-desierto');
    final estado = tester.state(find.byType(JuegoPage));
    await apariencia.elegir(ModoApariencia.oscuro);
    await tester.pumpAndSettle();
    expect(tester.state(find.byType(JuegoPage)), same(estado));
    expect(find.byKey(const Key('nivel-facil')), findsNothing);
    final context = tester.element(find.byType(JuegoPage));
    final idioma = IdiomaScope.of(context)!;
    expect(idioma.sonido, false);
    expect(idioma.vibracion, false);
    mostrarArmarioNatu(context);
    await tester.pumpAndSettle();
    await apariencia.elegir(ModoApariencia.claro);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('cerrar-armario-natu')), findsOneWidget);
    await _tocar(tester, 'cerrar-armario-natu');
    expect(tester.state(find.byType(JuegoPage)), same(estado));
    await apariencia.elegir(ModoApariencia.oscuro);
    await tester.pumpAndSettle();
    final hogar = Alcance.of(context).catalogo.actividades
        .firstWhere((a) => a.id == 'hogar');
    for (final reto
        in hogar.nivelesLugar
            .firstWhere((n) => n.id == 'facil')
            .retos
            .skip(1)) {
      await _tocar(tester, 'sitio-${reto.respuesta}');
    }
    await _capturar(tester, 'resultado-oscuro');
    expect(tester.takeException(), isNull);
  });

  testWidgets('laboratorios cambian el tema conservando su simulación', (
    tester,
  ) async {
    final apariencia = await _abrir(tester);
    await _tocar(tester, 'zona-invernadero');
    final zonaContext = tester.element(find.byType(Scaffold).last);
    // Usa la misma ruta del acceso al laboratorio de la zona.
    final navigator = Navigator.of(zonaContext);
    // Se obtiene la zona desde el alcance, igual que la pantalla.
    final zona = Alcance.of(zonaContext).catalogo.zonas
        .firstWhere((z) => z.id == 'invernadero');
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => LaboratorioZonaPage(zona: zona)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final estado = tester.state(
      find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_SimuladorFotosintesis',
      ),
    );
    await apariencia.elegir(ModoApariencia.oscuro);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester.state(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_SimuladorFotosintesis',
        ),
      ),
      same(estado),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await _capturar(tester, 'laboratorio-oscuro');
    navigator.pop();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
