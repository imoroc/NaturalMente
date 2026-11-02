import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/juego.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'soporte_cierre.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Catalogo catalogo;
  late Progreso progreso;
  late Actividad actividad;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    progreso = await Progreso.abrir();
    actividad = catalogo.actividades.firstWhere((a) => a.id == 'plato');
  });

  Future<void> abrir(
    WidgetTester tester, {
    double escala = 1,
    String idioma = 'es',
  }) async {
    final traducciones = (jsonDecode(
      File('content/en.json').readAsStringSync(),
    ) as Map).cast<String, String>();
    SharedPreferences.setMockInitialValues({'idioma': idioma});
    final preferencias = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      IdiomaScope(
        idioma: Idioma(preferencias, traducciones),
        child: Alcance(
          catalogo: catalogo,
          progreso: progreso,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(escala)),
              child: child!,
            ),
            home: JuegoPage(actividad: actividad),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String key) async {
    await seguirExplorando(tester);
    final finder = find.byKey(Key(key), skipOffstage: false);
    expect(finder, findsOneWidget, reason: 'No encuentro $key');
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // Posición (0 arriba) de la respuesta correcta en cada pregunta extra.
  final posicionesCorrectas = <int>[];

  Future<void> jugarNivel(WidgetTester tester, NivelLugar nivel) async {
    await tocar(tester, 'nivel-${nivel.id}');
    for (final reto in nivel.retos) {
      if (nivel.opciones.length == 2) {
        final izquierda = tester.getCenter(
          find.byKey(const Key('sitio-de-vez-en-cuando'), skipOffstage: false),
        );
        final derecha = tester.getCenter(
          find.byKey(const Key('sitio-cada-dia'), skipOffstage: false),
        );
        expect(
          izquierda.dx,
          lessThan(derecha.dx),
          reason: '«De vez en cuando» va a la izquierda en ${reto.id}',
        );
      }

      if (nivel.id == 'dificil') {
        expect(find.byKey(const Key('bandeja-plato')), findsNothing);
      } else {
        expect(find.byKey(const Key('bandeja-plato'), skipOffstage: false),
            findsOneWidget);
      }

      final otra = nivel.opciones.firstWhere((o) => o.id != reto.respuesta).id;
      await tocar(tester, 'sitio-$otra');
      await tocar(tester, 'sitio-${reto.respuesta}');
      final adaptacion = reto.adaptacion;
      if (nivel.preguntaAdaptacion && adaptacion != null) {
        final alturas = {
          for (final opcion in adaptacion.opciones)
            opcion.id: tester
                .getCenter(
                  find.byKey(
                    Key('adaptacion-${reto.id}-${opcion.id}'),
                    skipOffstage: false,
                  ),
                )
                .dy,
        };
        final ordenadas = alturas.keys.toList()
          ..sort((a, b) => alturas[a]!.compareTo(alturas[b]!));
        posicionesCorrectas.add(ordenadas.indexOf(adaptacion.respuesta));
        await tocar(tester, 'adaptacion-${reto.id}-${adaptacion.respuesta}');
      }
      if (nivel.id != 'dificil') {
        expect(
          find.byKey(Key('bandeja-plato-${reto.id}'), skipOffstage: false),
          nivel.id == 'medio' || reto.respuesta == 'cada-dia'
              ? findsOneWidget
              : findsNothing,
          reason: 'La bandeja guarda ${reto.id} solo si va en el plato',
        );
      }
    }
  }

  for (final tamano in const [Size(360, 640), Size(1024, 768)]) {
    for (final (idioma, escala) in const [('es', 1.0), ('en', 1.3)]) {
      testWidgets(
        'se juegan los tres niveles en $tamano ($idioma, texto x$escala)',
        (tester) async {
          await tester.binding.setSurfaceSize(tamano);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          posicionesCorrectas.clear();
          await abrir(tester, escala: escala, idioma: idioma);

          for (final nivel in actividad.nivelesLugar) {
            await jugarNivel(tester, nivel);
            expect(progreso.nivelLugarHecho(actividad, nivel.id), isTrue);
            await tocar(tester, 'cambiar-nivel');
          }

          expect(progreso.fichaDesbloqueada('merienda'), isTrue);
          expect(progreso.fichaDesbloqueada('plato-equilibrado'), isTrue);
          expect(progreso.fichaDesbloqueada('etiqueta'), isTrue);
          expect(progreso.medallaConseguida(catalogo.actividades), isFalse);
          expect(posicionesCorrectas, hasLength(5));
          expect(
            posicionesCorrectas.toSet().length,
            greaterThan(1),
            reason: 'En Difícil la respuesta correcta cambia de sitio',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
