import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/carrera.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  final actividad = catalogo.actividades.firstWhere((a) => a.id == 'carrera');

  Future<Progreso> abrir(WidgetTester tester, Actividad actividad) async {
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
            home: CarreraPage(actividad: actividad),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return progreso;
  }

  Future<void> tocar(WidgetTester tester, String clave) async {
    final finder = find.byKey(Key(clave));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('arrastrar coloca sin evaluar y un atasco no celebra nada', (
    tester,
  ) async {
    await abrir(tester, actividad);
    await tocar(tester, 'nivel-facil');
    final nivel = actividad.carrera!.niveles.first;
    final ronda = nivel.rondas.first;
    final volador = ronda.corredores.firstWhere((c) => c.tramo == 'vuela');
    final andador = ronda.corredores.firstWhere((c) => c.tramo == 'anda');
    final nadador = ronda.corredores.firstWhere((c) => c.tramo == 'nada');

    Future<void> arrastrar(String corredor, String tramo) async {
      final desde = find.byKey(Key('corredor-$corredor'));
      await tester.ensureVisible(desde);
      await tester.pumpAndSettle();
      final gesto = await tester.startGesture(tester.getCenter(desde));
      await tester.pump(const Duration(milliseconds: 50));
      final hasta = find.byKey(Key('tramo-$tramo'));
      await gesto.moveTo(tester.getCenter(hasta));
      await tester.pump();
      await gesto.up();
      await tester.pumpAndSettle();
    }

    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('carrera-ya')))
          .onPressed,
      isNull,
    );
    await arrastrar(volador.id, 'vuela');
    await arrastrar(nadador.id, 'anda');
    await arrastrar(andador.id, 'nada');
    expect(find.byKey(const Key('check-acierto')), findsNothing);

    await tocar(tester, 'carrera-ya');
    final tramo = nivel.tramos.firstWhere((t) => t.id == 'anda');
    expect(find.text('${tramo.reto} ${nadador.como}'), findsOneWidget);
    expect(find.byKey(const Key('check-acierto')), findsNothing);
    expect(find.byType(FinJuego), findsNothing);

    // El que se atasca vuelve a la salida; se corrige y el relevo llega.
    // Ocupar un tramo devuelve a la salida al que estaba allí.
    await tocar(tester, 'corredor-${nadador.id}');
    await tocar(tester, 'tramo-nada');
    await tocar(tester, 'corredor-${andador.id}');
    await tocar(tester, 'tramo-anda');
    await tester.ensureVisible(find.byKey(const Key('carrera-ya')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('carrera-ya')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('check-acierto')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Relevos: 1 de 3'), findsOneWidget);
    expect(find.byKey(Key('corredor-${volador.id}')), findsNothing);
  });

  testWidgets('en Difícil se ve la parte del cuerpo y luego el animal', (
    tester,
  ) async {
    await abrir(tester, actividad);
    await tocar(tester, 'nivel-dificil');
    final ronda = actividad.carrera!.niveles.last.rondas.first;
    final aguila = ronda.corredores.firstWhere((c) => c.tramo == 'vuela');
    expect(find.text(aguila.parte), findsOneWidget);
    expect(find.text(aguila.nombre), findsNothing);
    for (final corredor in ronda.corredores) {
      await tocar(tester, 'corredor-${corredor.id}');
      await tocar(tester, 'tramo-${corredor.tramo}');
    }
    await tocar(tester, 'carrera-ya');
    expect(find.text(aguila.nombre), findsOneWidget);
    expect(find.byKey(const Key('continuar-paso')), findsOneWidget);
  });
}
