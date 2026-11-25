import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/linterna.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  final actividad = catalogo.actividades.firstWhere((a) => a.id == 'linterna');

  Future<void> abrir(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
    });
    final progreso = await Progreso.abrir();
    final idioma = Idioma(await SharedPreferences.getInstance(), const {});
    await tester.pumpWidget(
      IdiomaScope(
        idioma: idioma,
        child: Alcance(
          catalogo: catalogo,
          progreso: progreso,
          child: MaterialApp(
            theme: TemaNatural.crear(Brightness.light),
            home: LinternaPage(actividad: actividad),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String clave) async {
    final finder = find.byKey(Key(clave));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('mover la luz y tocar donde no hay nada no evalúa', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final escena = find.byKey(const Key('linterna-escena'));
    await tester.ensureVisible(escena);
    await tester.pumpAndSettle();
    final rect = tester.getRect(escena);

    await tester.dragFrom(rect.center, const Offset(40, 60));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('check-acierto')), findsNothing);

    await tester.tapAt(rect.topLeft + const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(
      find.text('Aquí no hay nada de la lista. Mueve la luz y sigue buscando.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('check-acierto')), findsNothing);
  });

  testWidgets('tocar otra cosa explica qué es; lo buscado se enciende', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final objetivos = actividad.linterna!.niveles.first.escenas.first.objetivos;
    final cabeza = objetivos.first;
    final tronco = objetivos[1];

    await tocar(tester, 'zona-${tronco.id}-0');
    expect(find.text(tronco.aviso), findsOneWidget);
    expect(find.byKey(const Key('check-acierto')), findsNothing);

    final zona = find.byKey(Key('zona-${cabeza.id}-0'));
    await tester.tap(zona);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('check-acierto')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(cabeza.como), findsOneWidget);
    expect(find.byType(FinJuego), findsNothing);
  });

  testWidgets('al terminar una escena se enciende la luz y espera', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-dificil');
    final escena = actividad.linterna!.niveles.last.escenas.first;
    for (final objetivo in escena.objetivos) {
      await tocar(tester, 'zona-${objetivo.id}-0');
    }
    expect(find.byKey(const Key('continuar-paso')), findsOneWidget);
    expect(find.text('Escenas: 1 de 3'), findsOneWidget);
    await tocar(tester, 'continuar-paso');
    expect(find.text('Escenas: 1 de 3'), findsOneWidget);
    expect(
      find.byKey(
        Key(
          'objetivo-${actividad.linterna!.niveles.last.escenas[1].objetivos.first.id}',
        ),
      ),
      findsOneWidget,
    );
  });
}
