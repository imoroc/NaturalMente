import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/pelicula.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  final actividad = catalogo.actividades.firstWhere((a) => a.id == 'pelicula');

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
            home: PeliculaPage(actividad: actividad),
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

  testWidgets('una carta que no toca explica cuándo va y no da el check', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final rollo = actividad.pelicula!.niveles.first.rollos.first;
    final brote = rollo.carta('brote')!;

    await tocar(tester, 'carta-brote');
    expect(find.text(brote.aviso), findsOneWidget);
    expect(find.byKey(const Key('check-acierto')), findsNothing);
    expect(find.byKey(const Key('carta-brote')), findsOneWidget);
  });

  testWidgets('arrastrar la carta buena al fotograma la deja en la tira', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-medio');
    final rollo = actividad.pelicula!.niveles[1].rollos.first;
    final carta = find.byKey(const Key('carta-semilla'));
    final hueco = find.byKey(const Key('fotograma-0'));
    await tester.ensureVisible(carta);
    await tester.pumpAndSettle();
    final gesto = await tester.startGesture(tester.getCenter(carta));
    await tester.pump(const Duration(milliseconds: 50));
    await gesto.moveTo(tester.getCenter(hueco));
    await tester.pump();
    await gesto.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('check-acierto')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(rollo.fotogramas.first.como), findsOneWidget);
    // La carta deja su sitio vacío en la bandeja.
    expect(find.byKey(const Key('carta-semilla')), findsNothing);
    expect(find.byType(FinJuego), findsNothing);
  });

  testWidgets('al llenar la tira se proyecta y espera a Continuar', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final niveles = actividad.pelicula!.niveles.first;
    for (final f in niveles.rollos.first.fotogramas) {
      await tocar(tester, 'carta-${f.id}');
    }
    expect(find.byKey(const Key('continuar-paso')), findsOneWidget);
    expect(find.text('Rollos: 1 de 3'), findsOneWidget);
    await tocar(tester, 'continuar-paso');
    expect(find.text(niveles.rollos[1].titulo), findsOneWidget);
  });
}
