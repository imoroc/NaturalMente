import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/cromos_zona.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );

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
      expect(find.text('Cromo conseguido'), findsOneWidget);
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
      expect(tester.takeException(), isNull);
    },
  );
}
