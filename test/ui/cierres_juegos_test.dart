import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/digestion.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/digestion.dart';
import 'package:naturalmente/ui/ecosistema.dart';
import 'package:naturalmente/ui/expedicion_diaria.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:naturalmente/ui/herbario.dart';
import 'package:naturalmente/ui/juego.dart';
import 'package:naturalmente/ui/nacimiento.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _pagina(Actividad actividad) => switch (actividad.tipo) {
  'herbario' => HerbarioPage(actividad: actividad),
  'nacimiento' => NacimientoPage(actividad: actividad),
  'viaje' => ViajePage(actividad: actividad),
  'ecosistema' => EcosistemaPage(actividad: actividad),
  _ => JuegoPage(actividad: actividad),
};

Future<void> _tocar(WidgetTester tester, String clave) async {
  final finder = find.byKey(Key(clave));
  if (finder.evaluate().isEmpty && clave.startsWith('paso-')) {
    await tester.scrollUntilVisible(
      finder,
      140,
      scrollable: find.byType(Scrollable).last,
    );
  }
  expect(finder, findsOneWidget, reason: 'Falta $clave');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _jugar(
  WidgetTester tester,
  Actividad actividad,
  String nivelId,
) async {
  switch (actividad.tipo) {
    case 'lugar':
      final nivel = actividad.nivelesLugar.firstWhere((n) => n.id == nivelId);
      for (final reto in nivel.retos) {
        await _tocar(tester, 'sitio-${reto.respuesta}');
        if (nivel.preguntaAdaptacion && reto.adaptacion != null) {
          expect(find.byType(FinJuego), findsNothing);
          await _tocar(
            tester,
            'adaptacion-${reto.id}-${reto.adaptacion!.respuesta}',
          );
        }
      }
    case 'controles':
      final nivel = actividad.nivelesLugar.firstWhere((n) => n.id == nivelId);
      for (final control in nivel.controles) {
        await _tocar(
          tester,
          'control-${control.id}-${respuestaOptimaControl(control.id)}',
        );
      }
      for (var dia = 0; dia < 3; dia++) {
        if (dia > 0) await _tocar(tester, 'control-agua-justa');
        await _tocar(tester, 'avanzar');
      }
      if (nivel.preguntaFinal != null) {
        expect(find.byType(FinJuego), findsNothing);
        await _tocar(
          tester,
          'final-${actividad.id}-${nivel.preguntaFinal!.respuesta}',
        );
      }
    case 'orden':
      final nivel = actividad.nivelesLugar.firstWhere((n) => n.id == nivelId);
      for (final paso
          in nivel.respuesta.isNotEmpty
              ? nivel.respuesta
              : actividad.respuesta) {
        await _tocar(tester, 'paso-$paso');
      }
      await _tocar(tester, 'comprobar');
      if (nivel.preguntaFinal != null) {
        expect(find.byType(FinJuego), findsNothing);
        await _tocar(
          tester,
          'final-${actividad.id}-${nivel.preguntaFinal!.respuesta}',
        );
      }
    case 'herbario':
      final herbario = actividad.herbario!;
      final nivel = herbario.niveles.firstWhere((n) => n.id == nivelId);
      for (final parte in nivel.partes) {
        await _tocar(tester, 'pieza-$parte');
        await _tocar(tester, 'destino-$parte');
      }
      if (nivel.preguntaFunciones) {
        expect(find.byType(FinJuego), findsNothing);
        for (final parte in nivel.partes) {
          await _tocar(
            tester,
            'funcion-$parte-${herbario.parte(parte).pregunta.respuesta}',
          );
        }
      }
    case 'nacimiento':
      final nacimiento = actividad.nacimiento!;
      final nivel = nacimiento.niveles.firstWhere((n) => n.id == nivelId);
      if (nivel.animales.isNotEmpty) {
        for (final animal in nivel.animales) {
          await _tocar(tester, 'animal-$animal');
          await _tocar(tester, 'nido-${nacimiento.animal(animal).respuesta}');
        }
      } else {
        for (final ciclo in nivel.ciclos) {
          for (final paso in ciclo.respuesta) {
            await _tocar(tester, 'paso-$paso');
          }
          await _tocar(tester, 'comprobar-ciclo');
          expect(find.byType(FinJuego), findsNothing);
          await _tocar(
            tester,
            'respuesta-${ciclo.id}-${ciclo.pregunta.respuesta}',
          );
        }
      }
    case 'viaje':
      final nivel = actividad.viaje!.niveles.firstWhere((n) => n.id == nivelId);
      for (final parada in nivel.paradas) {
        await _tocar(tester, 'destino-${parada.id}');
        if (parada.id == 'boca' && nivel.masticar) {
          for (var i = 0; i < mordiscosNecesarios; i++) {
            await _tocar(tester, 'masticar');
          }
        }
        if (parada.pregunta != null) {
          await _tocar(
            tester,
            'respuesta-${parada.id}-${parada.pregunta!.respuesta}',
          );
        }
      }
      if (nivel.preguntaFinal != null) {
        expect(find.byType(FinJuego), findsNothing);
        await _tocar(
          tester,
          'respuesta-final-${nivel.preguntaFinal!.respuesta}',
        );
      }
    case 'ecosistema':
      final nivel = actividad.ecosistema!.niveles.firstWhere(
        (n) => n.id == nivelId,
      );
      for (final pieza in ['hierba', 'conejo', 'zorro']) {
        await _tocar(tester, 'eco-pieza-$pieza');
        await _tocar(tester, 'eco-destino-$pieza');
      }
      for (final reto in nivel.retos) {
        await _tocar(tester, 'eco-respuesta-${reto.respuesta}');
        if (find.byKey(const Key('eco-restaurar')).evaluate().isNotEmpty) {
          await _tocar(tester, 'eco-restaurar');
        }
      }
    default:
      fail('Tipo de juego sin recorrido de cierre: ${actividad.tipo}');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  late Progreso progreso;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
    });
    progreso = await Progreso.abrir();
  });

  Future<void> abrir(WidgetTester tester, Widget juego) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final idioma = Idioma(await SharedPreferences.getInstance(), const {});
    await tester.pumpWidget(
      IdiomaScope(
        idioma: idioma,
        child: Alcance(
          catalogo: catalogo,
          progreso: progreso,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    key: const Key('abrir'),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => juego));
                    },
                    child: const Text('Mapa de prueba'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, 'abrir');
  }

  for (final actividad in catalogo.actividades) {
    testWidgets(
      '${actividad.id}: cierre automático y acciones en los tres niveles',
      (tester) async {
        await abrir(tester, _pagina(actividad));
        for (final nivel in ['facil', 'medio', 'dificil']) {
          await _tocar(tester, 'nivel-$nivel');
          await _jugar(tester, actividad, nivel);
          expect(find.byType(FinJuego), findsOneWidget);
          expect(find.byKey(const Key('check-acierto')), findsNothing);
          for (final clave in ['fin-nivel', 'fin-repetir', 'fin-volver']) {
            expect(find.byKey(Key(clave)), findsOneWidget);
          }
          expect(progreso.nivelJuegoHecho(actividad, nivel), isTrue);
          if (nivel == 'dificil') {
            await _tocar(tester, 'fin-repetir');
            expect(find.byType(FinJuego), findsNothing);

            await _jugar(tester, actividad, nivel);
            expect(find.byType(FinJuego), findsOneWidget);
            await _tocar(tester, 'fin-volver');
            expect(find.text('Mapa de prueba'), findsOneWidget);
          } else {
            await _tocar(tester, 'fin-nivel');
            expect(find.byKey(const Key('nivel-dificil')), findsOneWidget);
          }
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final dificultad in ['facil', 'medio', 'dificil']) {
    testWidgets(
      'reto diario $dificultad: cierre sin repetir una misión ya guardada',
      (tester) async {
        final fecha = DateTime(2026, 10, 28);
        await abrir(
          tester,
          ExpedicionDiariaPage(progreso: progreso, fechaReferencia: fecha),
        );
        await _tocar(tester, 'dificultad-reto-$dificultad');
        for (final pregunta in ExpedicionDiariaPage.generarMisionDelDia(
          fecha,
          dificultad,
        )) {
          await _tocar(tester, 'opcion-expedicion-${pregunta.indiceCorrecto}');
        }
        expect(find.byType(FinJuego), findsOneWidget);
        expect(find.byKey(const Key('fin-repetir')), findsNothing);
        expect(find.byKey(const Key('fin-nivel')), findsNothing);
        expect(progreso.expedicionHoyHecha(fecha), isTrue);
        if (dificultad == 'facil') {
          await _tocar(tester, 'fin-extra');
          expect(find.byKey(const Key('cerrar-armario-natu')), findsOneWidget);
          await _tocar(tester, 'cerrar-armario-natu');
        } else {
          final semillas = progreso.semillas;
          await _tocar(tester, 'fin-volver');
          expect(find.text('Mapa de prueba'), findsOneWidget);
          await _tocar(tester, 'abrir');
          expect(find.byType(FinJuego), findsNothing);
          expect(find.byKey(Key('dificultad-reto-$dificultad')), findsNothing);
          expect(progreso.semillas, semillas);
        }
        expect(find.byKey(const Key('expedicion-completada')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
