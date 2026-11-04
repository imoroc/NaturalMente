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
    'el resumen abre los cromos del mundo, que se ordenan y se ven en lista o cuadrícula',
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
      expect(find.byType(GridView), findsNothing);
      final primeraAntes = tester.getTopLeft(
        find.byKey(Key('cromo-${fichas.first.id}')),
      );

      // «Descubiertos primero» sube el único cromo conseguido al principio.
      await tester.tap(find.byKey(const Key('orden-cromos')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descubiertos primero').last);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(Key('cromo-${ultima.id}'))),
        primeraAntes,
      );

      // En la cuadrícula hay dos por fila; en la lista, uno.
      final segunda = fichas.first;
      expect(
        tester.getTopLeft(find.byKey(Key('cromo-${segunda.id}'))).dy,
        primeraAntes.dy,
      );
      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byKey(Key('cromo-${segunda.id}'))).dy,
        greaterThan(primeraAntes.dy),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
