import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/cromo_coleccionable.dart';
import 'package:naturalmente/ui/cromos_zona.dart';
import 'package:naturalmente/ui/zona.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );

  testWidgets('los rótulos largos se leen completos en inglés', (tester) async {
    SharedPreferences.setMockInitialValues({'idioma': 'en'});
    final idioma = await tester.runAsync(() async {
      final fuente = FontLoader('NunitoInicio')
        ..addFont(rootBundle.load('assets/fuentes/Nunito-900.ttf'));
      await fuente.load();
      return Idioma.abrir();
    });
    Future<void> montar(String id, double escala) => tester.pumpWidget(
      IdiomaScope(
        idioma: idioma!,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(escala)),
            child: child!,
          ),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 232,
                child: CromoColeccionable(
                  ficha: catalogo.fichas.firstWhere((f) => f.id == id),
                  conseguida: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await montar('fotosintesis', 1);
    const titulo = 'Photosynthesis';
    final parrafo = tester.renderObject<RenderParagraph>(find.text(titulo));
    final cajas = parrafo.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: titulo.length),
    );
    expect(cajas.map((caja) => caja.top).toSet(), hasLength(1));

    await montar('esqueleto', 1.5);
    final parte = find.text('Bones and muscles');
    final funcion = find.text('Support and movement');
    expect(
      tester.renderObject<RenderParagraph>(parte).didExceedMaxLines,
      isFalse,
    );
    expect(
      tester.renderObject<RenderParagraph>(funcion).didExceedMaxLines,
      isFalse,
    );
    expect(
      tester.getTopLeft(parte).dy,
      lessThan(tester.getTopLeft(funcion).dy),
    );
  });

  testWidgets('el álbum usa la misma cabecera y alinea todas las cartas', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({'sonido': false});
    final prefs = await SharedPreferences.getInstance();
    final progreso = await Progreso.abrir();
    await progreso.desbloquearFicha('camello');
    await progreso.desbloquearFicha('pinguino');

    await tester.pumpWidget(
      IdiomaScope(
        idioma: Idioma(prefs, const {}),
        child: Alcance(
          catalogo: catalogo,
          progreso: progreso,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AlbumPage()),
                  ),
                  child: const Text('Abrir álbum'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir álbum'));
    await tester.pumpAndSettle();
    expect(find.byType(CabeceraMundo), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    await tester.tap(find.byKey(const Key('album-reserva')));
    await tester.pumpAndSettle();

    expect(find.byType(CabeceraMundo), findsOneWidget);
    final corto = find.byKey(const Key('cromo-camello'));
    final largo = find.byKey(const Key('cromo-pinguino'));
    final pendiente = find.byKey(const Key('cromo-delfin'));
    expect(tester.getSize(corto), tester.getSize(largo));
    expect(tester.getSize(corto), tester.getSize(pendiente));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('album-reserva')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'el resumen abre una cuadrícula por estado y la carta conserva la ficha',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({
        'sonido': false,
        'vibracion': false,
      });
      final progreso = await Progreso.abrir();
      final zona = catalogo.zonas.firstWhere((z) => z.id == 'reserva');
      final fichas = catalogo.fichasDe(zona.id);
      final ultima = fichas.last;
      await progreso.desbloquearFicha(ultima.id);

      await tester.pumpWidget(
        IdiomaScope(
          idioma: Idioma(await SharedPreferences.getInstance(), const {}),
          child: Alcance(
            catalogo: catalogo,
            progreso: progreso,
            child: MaterialApp(
              home: Scaffold(
                body: ResumenCromosZona(
                  zona: zona,
                  fichas: fichas,
                  progreso: progreso,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('4. CROMOS · 1/${fichas.length}'), findsOneWidget);

      await tester.tap(find.byKey(const Key('abrir-cromos-zona')));
      await tester.pumpAndSettle();
      expect(find.text('1 de ${fichas.length} descubiertos'), findsOneWidget);
      final conseguida = find.byKey(Key('cromo-${ultima.id}'));
      final pendiente = find.byKey(Key('cromo-${fichas.first.id}'));
      expect(
        tester.getTopLeft(conseguida).dy,
        lessThan(tester.getTopLeft(pendiente).dy),
      );
      await tester.tap(conseguida);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Latón'), findsOneWidget);
      expect(find.text('Arrastra para inclinar'), findsOneWidget);
      expect(find.text('¡Nuevo cromo!'), findsNothing);
      await tester.tap(find.byKey(const Key('sobre-este-cromo')));
      await tester.pumpAndSettle();
      final cerrarFicha = find.byKey(const Key('cerrar-detalle-ficha'));
      expect(cerrarFicha, findsOneWidget);
      await tester.ensureVisible(cerrarFicha);
      await tester.tap(cerrarFicha);
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(pendiente);
      await tester.tap(pendiente);
      await tester.pumpAndSettle();
      expect(find.text('Ir al juego'), findsOneWidget);
      expect(find.text('Grupo'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'la vista inclina, vuelve a reposo y respeta movimiento reducido',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 510));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({'sonido': false});
      final prefs = await SharedPreferences.getInstance();
      final progreso = await Progreso.abrir();
      await progreso.desbloquearFicha('pulpo');
      final zona = catalogo.zonas.firstWhere((z) => z.id == 'reserva');
      final reducido = ValueNotifier(false);
      addTearDown(reducido.dispose);
      await tester.pumpWidget(
        IdiomaScope(
          idioma: Idioma(prefs, const {}),
          child: Alcance(
            catalogo: catalogo,
            progreso: progreso,
            child: MaterialApp(
              builder: (context, child) => ValueListenableBuilder<bool>(
                valueListenable: reducido,
                builder: (context, valor, _) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: valor,
                    textScaler: valor ? const TextScaler.linear(2) : null,
                  ),
                  child: child!,
                ),
              ),
              home: CromosZonaPage(zona: zona),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cromo-pulpo')));
      await tester.pumpAndSettle();
      expect(find.text('Nácar especial'), findsOneWidget);
      expect(find.text('Molusco'), findsOneWidget);
      expect(find.text('Mar'), findsOneWidget);

      final carta = find.byKey(const Key('inclinacion-cromo'));
      expect(tester.getSize(carta).width, greaterThan(232));
      final cabecera = find.text('Mis cromos');
      final alturaCabecera = tester.getTopLeft(cabecera).dy;
      final reposo = tester.widget<Transform>(carta).transform.clone();
      expect(reposo.entry(1, 0).abs(), greaterThan(.01));
      final arrastre = await tester.startGesture(tester.getCenter(carta));
      await arrastre.moveBy(const Offset(55, 8));
      await tester.pump();
      expect(tester.widget<Transform>(carta).transform, isNot(reposo));
      await arrastre.cancel();
      await tester.pumpAndSettle();
      expect(tester.widget<Transform>(carta).transform, reposo);

      Focus.of(tester.element(carta)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(tester.widget<Transform>(carta).transform, isNot(reposo));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tester.widget<Transform>(carta).transform, reposo);

      final antesDeDesplazar = tester.getCenter(carta).dy;
      await tester.drag(carta, const Offset(0, -95));
      await tester.pumpAndSettle();
      expect(tester.getCenter(carta).dy, lessThan(antesDeDesplazar));
      expect(tester.getTopLeft(cabecera).dy, alturaCabecera);
      expect(tester.widget<Transform>(carta).transform, reposo);

      reducido.value = true;
      await tester.pumpAndSettle();
      expect(carta, findsNothing);
      expect(find.text('Arrastra para inclinar'), findsNothing);
      expect(find.text('Nácar especial'), findsOneWidget);
      expect(find.text('Pulpo'), findsOneWidget);
      expect(find.text('La reserva'), findsOneWidget);
      expect(find.text('Grupo · Molusco'), findsOneWidget);
      expect(find.text('Hábitat · Mar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
