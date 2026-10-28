import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/ui/ecosistema.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'soporte_cierre.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final nivel in ['facil', 'medio', 'dificil']) {
    testWidgets(
      '$nivel: recorrido, pistas, idioma, persistencia y repetición',
      (t) async {
        await t.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => t.binding.setSurfaceSize(null));
        await abrir(t);
        await tocar(t, 'nivel-$nivel');
        expect(find.text('1 · Suelo al sol'), findsOneWidget);
        expect(find.text('2 · Pradera'), findsOneWidget);
        expect(find.text('3 · Árboles'), findsOneWidget);
        await tocar(t, 'eco-destino-hierba');
        expect(
          find.text('Primero toca un dibujo de la bandeja.'),
          findsOneWidget,
        );
        await tocar(t, 'eco-pieza-hierba');
        await tocar(t, 'eco-destino-zorro');
        await tocar(t, 'eco-destino-zorro');
        expect(
          find.text('Busca las hojas verdes junto al suelo.'),
          findsOneWidget,
        );
        // Arrastre y toques llevan al mismo estado.
        await t.ensureVisible(find.byKey(const Key('eco-pieza-hierba')));
        await t.drag(
          find.byKey(const Key('eco-pieza-hierba')),
          t.getCenter(find.byKey(const Key('eco-destino-hierba'))) -
              t.getCenter(find.byKey(const Key('eco-pieza-hierba'))),
        );
        await t.pumpAndSettle();
        expect(find.byKey(const Key('eco-seguir')), findsNothing);
        expect(
          find.textContaining('Sus raíces sujetan la tierra húmeda'),
          findsOneWidget,
        );
        for (final id in ['conejo', 'zorro']) {
          await tocar(t, 'eco-pieza-$id');
          await tocar(t, 'eco-destino-$id');
        }
        if (nivel != 'facil') {
          expect(
            find.text('Descubrimientos: 3 de ${nivel == 'medio' ? 5 : 7}'),
            findsOneWidget,
          );
          final context = t.element(find.byType(Scaffold).last);
          await IdiomaScope.of(context)!.elegir('en');
          await t.pumpAndSettle();
          expect(
            find.text(
              'Which food comes from a plant and is eaten by the rabbit?',
            ),
            findsOneWidget,
          );
          await tocar(t, 'eco-respuesta-hierba');
          await tocar(t, 'eco-respuesta-conejo');
          if (nivel == 'dificil') {
            await tocar(t, 'eco-respuesta-menos-comida');
            expect(
              find.text('How the clearing might change', skipOffstage: false),
              findsOneWidget,
            );
            await tocar(t, 'eco-restaurar');
            await tocar(t, 'eco-respuesta-menos-presas');
            await tocar(t, 'eco-restaurar');
          }
        }
        final context = t.element(find.byType(Scaffold).last);
        expect(
          Alcance.of(context).progreso.hecho('ecosistemas/$nivel/completo'),
          isTrue,
        );
        expect(
          Alcance.of(context).progreso.fichaDesbloqueada('claro-bosque'),
          isTrue,
        );
        await tocar(t, 'eco-otra-vez');
        expect(find.byKey(const Key('eco-pieza-hierba')), findsOneWidget);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('salida se puede cancelar y ayuda devuelve a la partida', (
    t,
  ) async {
    await abrir(t);
    await tocar(t, 'nivel-facil');
    await tocar(t, 'eco-ayuda');
    await t.tap(find.text('¡Vamos a jugar!'));
    await t.pumpAndSettle();
    await tocar(t, 'eco-cambiar-nivel');
    expect(find.text('¿Dejamos el claro por ahora?'), findsOneWidget);
    await t.tap(find.text('Seguir jugando'));
    await t.pumpAndSettle();
    expect(find.byKey(const Key('eco-pieza-hierba')), findsOneWidget);
    await tocar(t, 'eco-cambiar-nivel');
    await t.tap(find.text('Salir'));
    await t.pumpAndSettle();
    expect(find.text('Tu último nivel'), findsOneWidget);
  });
  testWidgets('teclado permite seleccionar una pieza y colocarla', (t) async {
    await abrir(t);
    await tocar(t, 'nivel-facil');
    Future<void> activar(String clave) async {
      final objetivo = t.element(find.byKey(Key(clave)));
      for (var i = 0; i < 25; i++) {
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        await t.pumpAndSettle();
        var encontrado = false;
        FocusManager.instance.primaryFocus?.context?.visitAncestorElements((e) {
          if (identical(e, objetivo)) encontrado = true;
          return !encontrado;
        });
        if (encontrado) {
          await t.sendKeyEvent(LogicalKeyboardKey.enter);
          await t.pumpAndSettle();
          return;
        }
      }
      fail('No se alcanzó $clave con teclado.');
    }

    await activar('eco-pieza-hierba');
    await activar('eco-destino-hierba');
    expect(find.text('Descubrimientos: 1 de 3'), findsOneWidget);
  });
  for (final size in [
    const Size(320, 568),
    const Size(700, 360),
    const Size(1024, 768),
  ]) {
    testWidgets('$size: inglés, texto doble y movimiento reducido', (t) async {
      SharedPreferences.setMockInitialValues({'idioma': 'en'});
      await t.binding.setSurfaceSize(size);
      addTearDown(() => t.binding.setSurfaceSize(null));
      final catalogo = Catalogo.desdeTexto(
        File('content/catalog.json').readAsStringSync(),
      );
      final progreso = await Progreso.abrir();
      final idioma = await Idioma.abrir();
      await t.pumpWidget(
        IdiomaScope(
          idioma: idioma,
          child: Alcance(
            catalogo: catalogo,
            progreso: progreso,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true,
                ),
                child: child!,
              ),
              home: EcosistemaPage(
                actividad: catalogo.actividades.firstWhere(
                  (a) => a.id == 'ecosistemas',
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await tocar(t, 'nivel-dificil');
      for (final id in ['hierba', 'conejo', 'zorro']) {
        await tocar(t, 'eco-pieza-$id');
        await tocar(t, 'eco-destino-$id');
      }
      await tocar(t, 'eco-respuesta-hierba');
      await tocar(t, 'eco-respuesta-conejo');
      await tocar(t, 'eco-respuesta-menos-comida');
      await tocar(t, 'eco-restaurar');
      await tocar(t, 'eco-respuesta-menos-presas');
      await tocar(t, 'eco-restaurar');
      expect(
        find.text(
          'Your woodland sticker is in Natu’s album.',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    });
  }
}

Future<void> abrir(WidgetTester t) async {
  await t.pumpWidget(const NaturalmenteApp());
  for (var i = 0; i < 60; i++) {
    await t.pump(const Duration(milliseconds: 50));
    if (find.byKey(const Key('zona-reserva')).evaluate().isNotEmpty) break;
  }
  await tocar(t, 'zona-reserva');
  await tocar(t, 'juego-ecosistemas');
}

Future<void> tocar(WidgetTester t, String key) async {
  await seguirExplorando(t);
  final f = find.byKey(Key(key));
  await t.ensureVisible(f);
  await t.pumpAndSettle();
  await t.tap(f);
  await t.pumpAndSettle();
}
