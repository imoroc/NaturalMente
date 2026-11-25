import 'dart:io';
import 'dart:async';

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
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/nacimiento.dart';
import 'package:naturalmente/ui/rescate.dart';
import 'package:naturalmente/ui/carrera.dart';
import 'package:naturalmente/ui/linterna.dart';
import 'package:naturalmente/ui/adivinanza.dart';
import 'package:naturalmente/ui/memoria.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../soporte/preferencias_controladas.dart';

import 'package:naturalmente/ui/feedback_acierto.dart';

Widget _pagina(Actividad actividad) => switch (actividad.tipo) {
  'herbario' => HerbarioPage(actividad: actividad),
  'nacimiento' => NacimientoPage(actividad: actividad),
  'viaje' => ViajePage(actividad: actividad),
  'ecosistema' => EcosistemaPage(actividad: actividad),
  'rescate' => RescatePage(actividad: actividad),
  'carrera' => CarreraPage(actividad: actividad),
  'linterna' => LinternaPage(actividad: actividad),
  'memoria' => MemoriaPage(actividad: actividad),
  'adivinanza' => AdivinanzaPage(actividad: actividad),
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
    case 'rescate':
      final nivel = actividad.rescate!.niveles.firstWhere(
        (n) => n.id == nivelId,
      );
      for (final objeto in nivel.objetos.where((o) => o.basura)) {
        await _tocar(tester, 'objeto-${objeto.id}');
      }
      for (final residuo in nivel.residuos) {
        await _tocar(tester, 'contenedor-${residuo.contenedor}');
      }
      for (final especie in nivel.especies) {
        await _tocar(
          tester,
          'respuesta-${especie.id}-${especie.amenaza.respuesta}',
        );
        expect(find.byType(FinJuego), findsNothing);
        await _tocar(tester, 'continuar-paso');
        await _tocar(
          tester,
          'respuesta-${especie.id}-${especie.ayuda.respuesta}',
        );
        if (especie != nivel.especies.last) {
          await _tocar(tester, 'continuar-paso');
        }
      }
    case 'linterna':
      final nivel = actividad.linterna!.niveles.firstWhere(
        (n) => n.id == nivelId,
      );
      for (final escena in nivel.escenas) {
        for (final objetivo in escena.objetivos) {
          expect(find.byType(FinJuego), findsNothing);
          await _tocar(tester, 'zona-${objetivo.id}-0');
        }
        if (escena != nivel.escenas.last) {
          expect(find.byType(FinJuego), findsNothing);
          await _tocar(tester, 'continuar-paso');
        }
      }
    case 'carrera':
      final nivel = actividad.carrera!.niveles.firstWhere(
        (n) => n.id == nivelId,
      );
      for (final ronda in nivel.rondas) {
        for (final corredor in ronda.corredores) {
          await _tocar(tester, 'corredor-${corredor.id}');
          await _tocar(tester, 'tramo-${corredor.tramo}');
        }
        expect(find.byType(FinJuego), findsNothing);
        await _tocar(tester, 'carrera-ya');
        if (ronda != nivel.rondas.last) {
          expect(find.byType(FinJuego), findsNothing);
          if (nivel.lupa) await _tocar(tester, 'continuar-paso');
        }
      }
    case 'memoria':
      final nivel = actividad.memoria!.niveles.firstWhere(
        (n) => n.id == nivelId,
      );
      for (final pareja in nivel.parejas) {
        await _tocar(tester, 'carta-${pareja.id}-a');
        await _tocar(tester, 'carta-${pareja.id}-b');
      }
    case 'adivinanza':
      final nivel = actividad.adivinanza!.niveles.firstWhere(
        (n) => n.id == nivelId,
      );
      for (final ronda in nivel.rondas) {
        await _tocar(tester, 'adivina-${ronda.respuesta}');
        if (ronda != nivel.rondas.last) await _tocar(tester, 'continuar-paso');
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

  Future<void> abrir(
    WidgetTester tester,
    Widget juego,
    Brightness brillo,
  ) async {
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
            theme: TemaNatural.crear(brillo),
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

  testWidgets('cromos nuevos se muestran tras guardar y no se repiten', (
    tester,
  ) async {
    final prefs = PreferenciasControladas();
    progreso = Progreso(prefs, {});
    final actividad = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final retos = actividad.nivelesLugar.first.retos;
    await abrir(tester, _pagina(actividad), Brightness.light);
    await _tocar(tester, 'nivel-facil');
    for (final reto in retos.take(retos.length - 1)) {
      await _tocar(tester, 'sitio-${reto.respuesta}');
    }
    prefs.falloEnClave = 'hechos';
    await _tocar(tester, 'sitio-${retos.last.respuesta}');
    expect(find.byKey(const Key('fin-cromos-nuevos')), findsNothing);
    expect(find.byKey(const Key('fin-guardar')), findsOneWidget);
    prefs.falloEnClave = null;
    await _tocar(tester, 'fin-guardar');
    final semillas = progreso.semillas;
    await _tocar(tester, 'fin-cromos-nuevos');
    expect(find.text('¡Nuevo cromo!'), findsOneWidget);
    expect(find.text('Camello'), findsOneWidget);
    await _tocar(tester, 'cromo-nuevo-siguiente');
    expect(find.text('Delfín'), findsOneWidget);
    await _tocar(tester, 'celebracion-abrir-album');
    expect(find.byKey(const Key('cromo-delfin')), findsOneWidget);
    expect(find.text('Recién conseguido'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(progreso.semillas, semillas);
    await _tocar(tester, 'fin-repetir');
    await _jugar(tester, actividad, 'facil');
    expect(find.byKey(const Key('fin-cromos-nuevos')), findsNothing);
    await _tocar(tester, 'fin-siguiente');
    expect(find.byType(FinJuego), findsNothing);
    expect(find.byKey(const Key('nivel-medio')), findsNothing);
    expect(find.byKey(const Key('sitio-selva')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final brillo in Brightness.values) {
    group(brillo.name, () {
      for (final actividad in catalogo.actividades) {
        testWidgets(
          '${actividad.id}: cierre automático y acciones en los tres niveles',
          (tester) async {
            await abrir(tester, _pagina(actividad), brillo);
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

      for (final nivelId in ['facil', 'medio']) {
        testWidgets(
          'hogar $nivelId: confirma el reto antes de avanzar y descarta toques rápidos',
          (tester) async {
            final actividad = catalogo.actividades.firstWhere(
              (a) => a.id == 'hogar',
            );
            final nivel = actividad.nivelesLugar.firstWhere(
              (n) => n.id == nivelId,
            );
            final primero = nivel.retos.first;
            final segundo = nivel.retos[1];
            await abrir(tester, JuegoPage(actividad: actividad), brillo);
            await _tocar(tester, 'nivel-$nivelId');
            final progresoAntes = tester
                .widget<LinearProgressIndicator>(
                  find.byType(LinearProgressIndicator),
                )
                .value;
            final destino = find.byKey(Key('sitio-${primero.respuesta}'));
            await tester.tap(destino);
            await tester.tap(destino);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 400));
            expect(find.byKey(const Key('check-acierto')), findsOneWidget);
            expect(find.text(primero.pregunta), findsOneWidget);
            expect(find.text(segundo.pregunta), findsNothing);
            expect(
              tester
                  .widget<LinearProgressIndicator>(
                    find.byType(LinearProgressIndicator),
                  )
                  .value,
              progresoAntes,
            );
            expect(progreso.comboActual, 1);
            expect(progreso.semillas, 1);
            if (nivelId == 'medio') {
              expect(find.text(primero.adaptacion!.enunciado), findsNothing);
              await tester.pumpAndSettle();
              expect(find.text(primero.adaptacion!.enunciado), findsOneWidget);
              expect(find.byType(FinJuego), findsNothing);
              final progresoComprension = tester
                  .widget<LinearProgressIndicator>(
                    find.byType(LinearProgressIndicator),
                  )
                  .value;
              final respuesta = find.byKey(
                Key(
                  'adaptacion-${primero.id}-${primero.adaptacion!.respuesta}',
                ),
              );
              await tester.tap(respuesta);
              await tester.tap(respuesta);
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 400));
              expect(find.text(primero.adaptacion!.enunciado), findsOneWidget);
              expect(find.text(segundo.pregunta), findsNothing);
              expect(
                tester
                    .widget<LinearProgressIndicator>(
                      find.byType(LinearProgressIndicator),
                    )
                    .value,
                progresoComprension,
              );
              expect(progreso.comboActual, 2);
            }
            await tester.pumpAndSettle();
            expect(find.text(segundo.pregunta), findsOneWidget);
            expect(find.byKey(const Key('check-acierto')), findsNothing);
            expect(find.byType(FinJuego), findsNothing);
          },
        );
      }

      testWidgets(
        'volver durante el check cancela el avance de la partida anterior',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'hogar',
          );
          final nivel = actividad.nivelesLugar.first;
          await abrir(tester, JuegoPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-facil');
          await tester.tap(
            find.byKey(Key('sitio-${nivel.retos.first.respuesta}')),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.text('Mapa de prueba'), findsOneWidget);
          expect(find.byKey(const Key('check-acierto')), findsNothing);
          await _tocar(tester, 'abrir');
          await _tocar(tester, 'nivel-facil');
          expect(find.text(nivel.retos.first.pregunta), findsOneWidget);
          await tester.pump(const Duration(seconds: 3));
          expect(find.text(nivel.retos.first.pregunta), findsOneWidget);
          expect(find.byType(FinJuego), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('germinación confirma una etapa antes de pedir otro riego', (
        tester,
      ) async {
        final actividad = catalogo.actividades.firstWhere(
          (a) => a.id == 'germinacion',
        );
        await abrir(tester, JuegoPage(actividad: actividad), brillo);
        await _tocar(tester, 'nivel-medio');
        for (final control in actividad.nivelesLugar[1].controles) {
          await _tocar(
            tester,
            'control-${control.id}-${respuestaOptimaControl(control.id)}',
          );
        }
        final avanzar = find.byKey(const Key('avanzar'));
        await tester.tap(avanzar);
        await tester.tap(avanzar);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.byKey(const Key('check-acierto')), findsOneWidget);
        expect(progreso.comboActual, 1);
        expect(progreso.semillas, 1);
        await tester.pumpAndSettle();
        // La semilla ya bebió; no se evalúa otro día hasta que se riegue.
        await _tocar(tester, 'avanzar');
        expect(progreso.semillas, 1);
        expect(find.byKey(const Key('check-acierto')), findsNothing);
        expect(find.byType(FinJuego), findsNothing);
      });

      testWidgets(
        'orden conserva la historia antes de abrir la pregunta final',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'vida',
          );
          final nivel = actividad.nivelesLugar[1];
          await abrir(tester, JuegoPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-medio');
          for (final paso in nivel.respuesta) {
            await _tocar(tester, 'paso-$paso');
          }
          await tester.tap(find.byKey(const Key('comprobar')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(
            find.byKey(Key('final-vida-${nivel.preguntaFinal!.respuesta}')),
            findsNothing,
          );
          expect(find.byType(FinJuego), findsNothing);
          await tester.pumpAndSettle();
          expect(
            find.byKey(Key('final-vida-${nivel.preguntaFinal!.respuesta}')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'herbario conserva la pregunta acertada hasta retirar el check',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'herbario',
          );
          final nivel = actividad.herbario!.niveles.last;
          await abrir(tester, HerbarioPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-dificil');
          for (final parte in nivel.partes) {
            await _tocar(tester, 'pieza-$parte');
            if (parte == nivel.partes.last) {
              await tester.tap(find.byKey(Key('destino-$parte')));
            } else {
              await _tocar(tester, 'destino-$parte');
            }
          }
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(
            find.byKey(Key('pregunta-${nivel.partes.first}')),
            findsNothing,
          );
          await tester.pumpAndSettle();
          final primera = actividad.herbario!.parte(nivel.partes.first);
          await tester.tap(
            find.byKey(
              Key('funcion-${primera.id}-${primera.pregunta.respuesta}'),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byKey(Key('pregunta-${primera.id}')), findsOneWidget);
          expect(find.byKey(Key('pregunta-${nivel.partes[1]}')), findsNothing);
          await tester.pumpAndSettle();
          expect(
            find.byKey(Key('pregunta-${nivel.partes[1]}')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'nacimiento presenta la comprensión después del check y conserva el ciclo al responder',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'nacimiento',
          );
          final ciclo = actividad.nacimiento!.niveles[1].ciclos.first;
          await abrir(tester, NacimientoPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-medio');
          for (final paso in ciclo.respuesta) {
            await _tocar(tester, 'paso-$paso');
          }
          await tester.tap(find.byKey(const Key('comprobar-ciclo')));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byKey(Key('pregunta-${ciclo.id}')), findsNothing);
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(
              Key('respuesta-${ciclo.id}-${ciclo.pregunta.respuesta}'),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byKey(Key('pregunta-${ciclo.id}')), findsOneWidget);
          expect(find.byType(FinJuego), findsNothing);
          await tester.pumpAndSettle();
          expect(find.byKey(Key('pregunta-${ciclo.id}')), findsNothing);
        },
      );

      testWidgets(
        'digestión conserva la pregunta contestada y masticar no entrega aciertos',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'digestion',
          );
          final nivel = actividad.viaje!.niveles.last;
          final parada = nivel.paradas.first;
          await abrir(tester, ViajePage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-dificil');
          final destino = find.byKey(Key('destino-${parada.id}'));
          await tester.ensureVisible(destino);
          await tester.pumpAndSettle();
          await tester.tap(destino);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text(parada.pregunta!.enunciado), findsNothing);
          await tester.pumpAndSettle();
          if (nivel.masticar) {
            final antes = progreso.semillas;
            for (var i = 0; i < mordiscosNecesarios; i++) {
              await _tocar(tester, 'masticar');
              expect(find.byKey(const Key('check-acierto')), findsNothing);
            }
            expect(progreso.semillas, antes);
          }
          final respuesta = find.byKey(
            Key('respuesta-${parada.id}-${parada.pregunta!.respuesta}'),
          );
          await tester.ensureVisible(respuesta);
          await tester.pumpAndSettle();
          await tester.tap(respuesta);
          await tester.tap(respuesta);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text(parada.pregunta!.enunciado), findsOneWidget);
          expect(progreso.comboActual, 2);
          await tester.pumpAndSettle();
          expect(find.text(parada.pregunta!.enunciado), findsNothing);
        },
      );

      testWidgets(
        'memoria solo confirma la segunda carta y no abre otra bajo el check',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'memoria-plantas',
          );
          final parejas = actividad.memoria!.niveles.first.parejas;
          await abrir(tester, MemoriaPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-facil');
          await _tocar(tester, 'carta-${parejas.first.id}-a');
          expect(find.byKey(const Key('check-acierto')), findsNothing);
          expect(progreso.semillas, 0);
          await tester.tap(find.byKey(Key('carta-${parejas.first.id}-b')));
          await tester.tap(find.byKey(Key('carta-${parejas[1].id}-a')));
          await tester.pumpAndSettle();
          expect(progreso.semillas, 1);
          await _tocar(tester, 'carta-${parejas[1].id}-b');
          expect(find.byKey(const Key('check-acierto')), findsNothing);
          expect(progreso.semillas, 1);
          await _tocar(tester, 'carta-${parejas[1].id}-a');
          expect(progreso.semillas, 3);
        },
      );

      testWidgets(
        'ecosistemas conserva la relación acertada antes de la siguiente',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'ecosistemas',
          );
          final retos = actividad.ecosistema!.niveles[1].retos;
          await abrir(tester, EcosistemaPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-medio');
          for (final pieza in ['hierba', 'conejo', 'zorro']) {
            await _tocar(tester, 'eco-pieza-$pieza');
            await _tocar(tester, 'eco-destino-$pieza');
          }
          await tester.tap(
            find.byKey(Key('eco-respuesta-${retos.first.respuesta}')),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text(retos.first.pregunta), findsOneWidget);
          expect(find.text(retos[1].pregunta), findsNothing);
          await tester.pumpAndSettle();
          expect(find.text(retos[1].pregunta), findsOneWidget);
        },
      );

      testWidgets(
        'rescate confirma el mismo residuo y no evalúa dos contenedores',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'cuida-reserva',
          );
          final nivel = actividad.rescate!.niveles[1];
          await abrir(tester, RescatePage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-medio');
          final contenedor = find.byKey(
            Key('contenedor-${nivel.residuos.first.contenedor}'),
          );
          await tester.tap(contenedor);
          await tester.tap(contenedor);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(
            find.byKey(ValueKey('residuo-${nivel.residuos.first.id}')),
            findsOneWidget,
          );
          expect(
            find.byKey(ValueKey('residuo-${nivel.residuos[1].id}')),
            findsNothing,
          );
          expect(progreso.semillas, 1);
          await tester.pumpAndSettle();
          expect(
            find.byKey(ValueKey('residuo-${nivel.residuos[1].id}')),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'adivinanza mantiene la revelación hasta Continuar sin volver a puntuar',
        (tester) async {
          final actividad = catalogo.actividades.firstWhere(
            (a) => a.id == 'quien-soy',
          );
          final nivel = actividad.adivinanza!.niveles.first;
          await abrir(tester, AdivinanzaPage(actividad: actividad), brillo);
          await _tocar(tester, 'nivel-facil');
          final respuesta = find.byKey(
            Key('adivina-${nivel.rondas.first.respuesta}'),
          );
          await tester.tap(respuesta);
          await tester.tap(respuesta);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text(nivel.rondas.first.pistas.first), findsOneWidget);
          expect(find.byKey(const Key('continuar-paso')), findsNothing);
          await tester.pumpAndSettle();
          final semillas = progreso.semillas;
          await tester.pump(const Duration(seconds: 20));
          expect(find.text(nivel.rondas.first.pistas.first), findsOneWidget);
          await _tocar(tester, 'continuar-paso');
          expect(find.text(nivel.rondas[1].pistas.first), findsOneWidget);
          expect(progreso.semillas, semillas);
        },
      );

      testWidgets(
        'diario conserva la explicación y un guardado lento o fallido no duplica semillas',
        (tester) async {
          final bloqueo = Completer<void>();
          final prefs = PreferenciasControladas()..bloqueo = bloqueo;
          progreso = Progreso(prefs, {});
          final fecha = DateTime(2026, 11, 16);
          final mision = ExpedicionDiariaPage.generarMisionDelDia(
            fecha,
            'facil',
          );
          await abrir(
            tester,
            ExpedicionDiariaPage(progreso: progreso, fechaReferencia: fecha),
            brillo,
          );
          await _tocar(tester, 'dificultad-reto-facil');
          final respuesta = find.byKey(
            Key('opcion-expedicion-${mision.first.indiceCorrecto}'),
          );
          await tester.tap(respuesta);
          await tester.tap(respuesta);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.text(mision.first.pregunta), findsOneWidget);
          expect(find.text(mision[1].pregunta), findsNothing);
          expect(progreso.semillas, 1);
          await tester.pumpAndSettle();
          expect(find.text(mision.first.explicacion), findsOneWidget);
          await tester.pump(const Duration(seconds: 10));
          expect(find.text(mision.first.pregunta), findsOneWidget);
          await _tocar(tester, 'continuar-paso');
          for (final pregunta in mision.skip(1)) {
            await _tocar(
              tester,
              'opcion-expedicion-${pregunta.indiceCorrecto}',
            );
            if (pregunta != mision.last) await _tocar(tester, 'continuar-paso');
          }
          expect(find.byType(FinJuego), findsOneWidget);
          expect(
            tester
                .widget<FilledButton>(find.byKey(const Key('fin-volver')))
                .onPressed,
            isNull,
          );
          final total = progreso.semillas;
          expect(total, 14);
          prefs.fallar = true;
          bloqueo.complete();
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('fin-guardar')), findsOneWidget);
          prefs.fallar = false;
          await _tocar(tester, 'fin-guardar');
          expect(progreso.expedicionHoyHecha(fecha), isTrue);
          expect(progreso.semillas, total);
          expect(find.byKey(const Key('fin-repetir')), findsNothing);
          expect(find.byKey(const Key('fin-nivel')), findsNothing);
        },
      );

      testWidgets(
        'reabrir un diario cuyo guardado falló recupera solo el cierre',
        (tester) async {
          final prefs = PreferenciasControladas()..falloEnClave = 'hechos';
          progreso = Progreso(prefs, {});
          final fecha = DateTime(2026, 11, 16);
          final mision = ExpedicionDiariaPage.generarMisionDelDia(
            fecha,
            'facil',
          );
          await abrir(
            tester,
            ExpedicionDiariaPage(progreso: progreso, fechaReferencia: fecha),
            brillo,
          );
          await _tocar(tester, 'dificultad-reto-facil');
          for (final pregunta in mision) {
            await _tocar(
              tester,
              'opcion-expedicion-${pregunta.indiceCorrecto}',
            );
            if (pregunta != mision.last) await _tocar(tester, 'continuar-paso');
          }
          expect(progreso.expedicionHoyHecha(fecha), isFalse);
          final total = progreso.semillas;
          await _tocar(tester, 'fin-seguir');
          await tester.pageBack();
          await tester.pumpAndSettle();
          prefs.falloEnClave = null;
          await _tocar(tester, 'abrir');
          expect(find.byType(FinJuego), findsOneWidget);
          expect(find.byType(AnimacionAcierto), findsNothing);
          expect(find.byKey(const Key('dificultad-reto-facil')), findsNothing);
          expect(progreso.semillas, total);
          expect(progreso.expedicionHoyHecha(fecha), isTrue);
        },
      );

      for (final id in ['hogar', 'herbario']) {
        testWidgets('$id: salir en la victoria cancela el efecto, pero conserva el guardado aceptado', (tester) async {
          final prefs = PreferenciasControladas();
          progreso = Progreso(prefs, {});
          final actividad = catalogo.actividades.firstWhere((a) => a.id == id);
          await abrir(tester, _pagina(actividad), brillo);
          await _tocar(tester, 'nivel-facil');
          late String ultimaAccion;
          if (id == 'hogar') {
            final retos = actividad.nivelesLugar.first.retos;
            for (final reto in retos.take(retos.length - 1)) {
              await _tocar(tester, 'sitio-${reto.respuesta}');
            }
            ultimaAccion = 'sitio-${retos.last.respuesta}';
          } else {
            final partes = actividad.herbario!.niveles.first.partes;
            for (final parte in partes) {
              await _tocar(tester, 'pieza-$parte');
              if (parte != partes.last) await _tocar(tester, 'destino-$parte');
            }
            ultimaAccion = 'destino-${partes.last}';
          }
          final bloqueo = Completer<void>();
          prefs.bloqueo = bloqueo;
          await tester.tap(find.byKey(Key(ultimaAccion)));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          expect(find.byKey(const Key('check-acierto')), findsOneWidget);
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(find.text('Mapa de prueba'), findsOneWidget);
          bloqueo.complete();
          await tester.pumpAndSettle();
          expect(progreso.nivelJuegoHecho(actividad, 'facil'), isTrue);
          expect(find.byType(FinJuego), findsNothing);
          expect(find.byKey(const Key('check-acierto')), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }

      for (final dificultad in ['facil', 'medio', 'dificil']) {
        testWidgets(
          'reto diario $dificultad: cierre sin repetir una misión ya guardada',
          (tester) async {
            final fecha = DateTime(2026, 10, 28);
            await abrir(
              tester,
              ExpedicionDiariaPage(progreso: progreso, fechaReferencia: fecha),
              brillo,
            );
            await _tocar(tester, 'dificultad-reto-$dificultad');
            for (final pregunta in ExpedicionDiariaPage.generarMisionDelDia(
              fecha,
              dificultad,
            )) {
              await _tocar(
                tester,
                'opcion-expedicion-${pregunta.indiceCorrecto}',
              );
              if (find.byType(FinJuego).evaluate().isEmpty) {
                expect(find.byKey(const Key('continuar-paso')), findsOneWidget);
                await _tocar(tester, 'continuar-paso');
              }
            }
            expect(find.byType(FinJuego), findsOneWidget);
            expect(find.byKey(const Key('fin-repetir')), findsNothing);
            expect(find.byKey(const Key('fin-nivel')), findsNothing);
            expect(progreso.expedicionHoyHecha(fecha), isTrue);
            if (dificultad == 'facil') {
              await _tocar(tester, 'fin-extra');
              expect(
                find.byKey(const Key('cerrar-armario-natu')),
                findsOneWidget,
              );
              await _tocar(tester, 'cerrar-armario-natu');
            } else {
              final semillas = progreso.semillas;
              await _tocar(tester, 'fin-volver');
              expect(find.text('Mapa de prueba'), findsOneWidget);
              await _tocar(tester, 'abrir');
              expect(find.byType(FinJuego), findsNothing);
              expect(
                find.byKey(Key('dificultad-reto-$dificultad')),
                findsNothing,
              );
              expect(progreso.semillas, semillas);
            }
            expect(
              find.byKey(const Key('expedicion-completada')),
              findsOneWidget,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    });
  }
}
