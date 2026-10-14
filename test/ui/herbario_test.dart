import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/ui/herbario.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Catalogo catalogo;
  late Progreso progreso;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    progreso = await Progreso.abrir();
  });

  Future<void> abrir(WidgetTester tester, {double escala = 1}) async {
    final actividad = catalogo.actividades.firstWhere(
      (a) => a.id == 'herbario',
    );
    await tester.pumpWidget(
      Alcance(
        catalogo: catalogo,
        progreso: progreso,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: HerbarioPage(actividad: actividad),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> colocar(WidgetTester tester, String id) async {
    await tocar(tester, 'pieza-$id');
    await tocar(tester, 'destino-$id');
  }

  testWidgets('el herbario se abre desde El invernadero', (tester) async {
    await tester.pumpWidget(const NaturalmenteApp());
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('zona-invernadero')).evaluate().isNotEmpty) {
        break;
      }
    }
    await tocar(tester, 'zona-invernadero');
    await tocar(tester, 'juego-herbario');
    expect(find.byKey(const Key('nivel-facil')), findsOneWidget);
    expect(find.byKey(const Key('nivel-medio')), findsOneWidget);
    expect(find.byKey(const Key('nivel-dificil')), findsOneWidget);
  });

  testWidgets('Fácil permite fallar, consultar, guardar y repetir', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    expect(find.byKey(const Key('pieza-flor')), findsNothing);
    await tocar(tester, 'pieza-raiz');
    await tocar(tester, 'destino-hoja');
    expect(find.textContaining('bajo el suelo'), findsOneWidget);
    await tocar(tester, 'destino-tallo');
    expect(find.textContaining('Busca la parte'), findsOneWidget);
    await tocar(tester, 'destino-raiz');
    await tocar(tester, 'ficha-raiz');
    expect(find.textContaining('zanahoria'), findsOneWidget);
    await tocar(tester, 'cerrar-ficha');
    await colocar(tester, 'tallo');
    await colocar(tester, 'hoja');
    expect(find.byKey(const Key('herbario-completo')), findsOneWidget);
    final actividad = catalogo.actividades.firstWhere(
      (a) => a.id == 'herbario',
    );
    expect(progreso.nivelHerbarioHecho(actividad, 'facil'), isTrue);
    expect(progreso.medallaConseguida(catalogo.actividades), isFalse);
    await tocar(tester, 'herbario-otra-vez');
    expect(find.text('Partes colocadas: 0 de 3'), findsOneWidget);
    expect(find.byKey(const Key('pieza-raiz')), findsOneWidget);
    await tocar(tester, 'herbario-cambiar-nivel');
    expect(find.text('✓ Nivel superado'), findsOneWidget);
  });

  testWidgets('una pieza se coloca también mediante arrastre', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-medio');
    final pieza = find.byKey(const Key('pieza-flor'));
    final destino = find.byKey(const Key('destino-flor'));
    final inicio = tester.getCenter(pieza);
    final finalArrastre = tester.getCenter(destino);
    final gesto = await tester.startGesture(inicio);
    await gesto.moveTo(inicio + const Offset(0, -20));
    await tester.pump();
    await gesto.moveTo(finalArrastre);
    await tester.pump();
    await gesto.up();
    await tester.pumpAndSettle();
    expect(find.text('Partes colocadas: 1 de 5'), findsOneWidget);
    expect(find.byKey(const Key('pieza-flor')), findsNothing);
  });

  testWidgets(
    'Difícil requiere funciones y el cambio de nivel reinicia la partida',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await abrir(tester);
      await tocar(tester, 'nivel-dificil');
      final actividad = catalogo.actividades.firstWhere(
        (a) => a.id == 'herbario',
      );
      final herbario = actividad.herbario!;
      for (final parte in herbario.partes) {
        await colocar(tester, parte.id);
      }
      expect(find.byKey(const Key('herbario-completo')), findsNothing);
      expect(find.byKey(const Key('ficha-raiz')), findsNothing);
      expect(progreso.nivelHerbarioHecho(actividad, 'dificil'), isFalse);
      final raiz = herbario.parte('raiz');
      final mal = raiz.pregunta.opciones.firstWhere(
        (o) => o.id != raiz.pregunta.respuesta,
      );
      await tocar(tester, 'funcion-raiz-${mal.id}');
      expect(find.byKey(const Key('pregunta-raiz')), findsOneWidget);
      for (final parte in herbario.partes) {
        await tocar(tester, 'funcion-${parte.id}-${parte.pregunta.respuesta}');
      }
      expect(find.byKey(const Key('herbario-completo')), findsOneWidget);
      expect(progreso.nivelHerbarioHecho(actividad, 'dificil'), isTrue);
      await tocar(tester, 'herbario-cambiar-nivel');
      await tocar(tester, 'nivel-medio');
      expect(find.text('Partes colocadas: 0 de 5'), findsOneWidget);
    },
  );

  testWidgets('permite salir de una partida sin registrar un nivel completo', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-medio');
    await colocar(tester, 'raiz');
    await tocar(tester, 'herbario-cambiar-nivel');
    final actividad = catalogo.actividades.firstWhere(
      (a) => a.id == 'herbario',
    );
    expect(progreso.nivelHerbarioHecho(actividad, 'medio'), isFalse);
    expect(progreso.actividadHecha(actividad), isFalse);
    await tocar(tester, 'nivel-medio');
    expect(find.text('Partes colocadas: 0 de 5'), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(700, 360),
    const Size(1024, 768),
  ]) {
    testWidgets('sin desbordamientos en $size con texto ampliado', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await abrir(tester, escala: 2);
      expect(tester.takeException(), isNull);
      await tocar(tester, 'nivel-medio');
      expect(tester.takeException(), isNull);
      await colocar(tester, 'raiz');
      expect(tester.takeException(), isNull);
      await tocar(tester, 'ficha-raiz');
      expect(tester.takeException(), isNull);
    });
  }
}
