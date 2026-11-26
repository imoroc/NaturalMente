import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/oscuras.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  final actividad = catalogo.actividades.firstWhere((a) => a.id == 'oscuras');

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
            home: OscurasPage(actividad: actividad),
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

  testWidgets('elegir el sitio no evalúa; pasan los días y se ve la planta', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final reto = actividad.oscuras!.niveles.first.retos.first;

    await tocar(tester, 'oscuras-probar');
    expect(find.text('Elige primero una opción.'), findsOneWidget);

    await tocar(tester, 'opcion-armario');
    expect(find.byKey(const Key('check-acierto')), findsNothing);
    await tocar(tester, 'oscuras-probar');
    expect(find.text(reto.frases['armario']!), findsOneWidget);
    expect(find.byKey(const Key('check-acierto')), findsNothing);
    expect(find.text('Día 7'), findsOneWidget);

    await tocar(tester, 'opcion-ventana');
    await tester.tap(find.byKey(const Key('oscuras-probar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('check-acierto')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(reto.frases['ventana']!), findsOneWidget);
    expect(find.byKey(const Key('continuar-paso')), findsOneWidget);
    await tocar(tester, 'continuar-paso');
    expect(find.text('Retos: 1 de 3'), findsOneWidget);
    expect(
      find.text(actividad.oscuras!.niveles.first.retos[1].pregunta),
      findsOneWidget,
    );
    expect(find.byType(FinJuego), findsNothing);
  });

  testWidgets('la hoja explica lo que sobra antes de fabricar', (tester) async {
    await abrir(tester);
    await tocar(tester, 'nivel-dificil');
    final nivel = actividad.oscuras!.niveles.last;
    for (final reto in nivel.retos.take(3)) {
      await tocar(tester, 'opcion-${reto.respuesta}');
      await tocar(tester, 'oscuras-probar');
      await tocar(tester, 'continuar-paso');
    }
    final hoja = nivel.retos.last;
    for (final id in ['luz', 'agua', 'aire', 'azucar']) {
      await tocar(tester, 'ingrediente-$id');
    }
    await tocar(tester, 'oscuras-probar');
    expect(
      find.text(hoja.ingredientes.firstWhere((i) => i.id == 'azucar').aviso),
      findsOneWidget,
    );
    await tocar(tester, 'ingrediente-azucar');
    await tocar(tester, 'oscuras-probar');
    expect(find.byType(FinJuego), findsOneWidget);
  });
}
