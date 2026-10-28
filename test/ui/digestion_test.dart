import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/digestion.dart';
import 'package:naturalmente/ui/digestion.dart';
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
    actividad = catalogo.actividades.firstWhere((a) => a.id == 'digestion');
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
            home: ViajePage(actividad: actividad),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String key) async {
  await seguirExplorando(tester);
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    // Con el texto ampliado una tarjeta puede ser más alta que la pantalla:
    // se toca su parte visible, como haría el niño.
    final rect = tester.getRect(finder);
    final alto = tester.getSize(find.byType(Scaffold).first).height;
    if (rect.center.dy > alto) {
      await tester.tapAt(rect.topLeft + const Offset(24, 24));
    } else {
      await tester.tap(finder);
    }
    await tester.pumpAndSettle();
  }

  Future<void> masticarTodo(WidgetTester tester) async {
    for (var i = 0; i < mordiscosNecesarios; i++) {
      await tocar(tester, 'masticar');
    }
  }

  Future<void> recorrer(WidgetTester tester, String nivelId) async {
    final nivel = actividad.viaje!.niveles.firstWhere((n) => n.id == nivelId);
    for (final parada in nivel.paradas) {
      await tocar(tester, 'destino-${parada.id}');
      if (parada.id == 'boca' && nivel.masticar) await masticarTodo(tester);
      final pregunta = parada.pregunta;
      if (pregunta != null) {
        await tocar(tester, 'respuesta-${parada.id}-${pregunta.respuesta}');
      }
    }
    final preguntaFinal = nivel.preguntaFinal;
    if (preguntaFinal != null) {
      await tocar(tester, 'respuesta-final-${preguntaFinal.respuesta}');
    }
  }

  testWidgets('el juego se abre desde Dentro de mí con sus tres niveles', (
    tester,
  ) async {
    await tester.pumpWidget(const NaturalmenteApp());
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('zona-cuerpo')).evaluate().isNotEmpty) break;
    }
    await tocar(tester, 'zona-cuerpo');
    expect(find.text('El viaje de la comida'), findsOneWidget);
    await tocar(tester, 'juego-digestion');
    for (final nivel in ['facil', 'medio', 'dificil']) {
      expect(find.byKey(Key('nivel-$nivel')), findsOneWidget);
    }
    expect(find.text('Cromo: Dientes'), findsOneWidget);
  });

  testWidgets('Fácil: se equivoca, mastica, llega a la barriga y se guarda', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    expect(find.text('Paradas recorridas: 0 de 2'), findsOneWidget);
    expect(find.byKey(const Key('masticar')), findsNothing);

    await tocar(tester, 'destino-pulmones');
    expect(find.textContaining('entra el aire'), findsOneWidget);
    expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    await tocar(tester, 'destino-barriga');
    expect(find.textContaining('hablas y sonríes'), findsOneWidget);

    await tocar(tester, 'destino-boca');
    expect(find.text('Paradas recorridas: 1 de 2'), findsOneWidget);
    expect(find.text('Masticar (0/3)'), findsOneWidget);
    await tocar(tester, 'destino-barriga');
    expect(find.textContaining('Toca «Masticar»'), findsOneWidget);
    await masticarTodo(tester);
    expect(find.byKey(const Key('masticar')), findsNothing);
    expect(find.textContaining('bola blandita'), findsOneWidget);

    await tocar(tester, 'destino-barriga');
    expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
    expect(progreso.nivelJuegoHecho(actividad, 'facil'), isTrue);
    expect(progreso.fichaDesbloqueada('dientes'), isTrue);
    expect(progreso.fichaDesbloqueada('aparato-digestivo'), isFalse);

    await tocar(tester, 'curiosidad-viaje');
    expect(find.text('CUADERNO DE NATU'), findsOneWidget);
    expect(find.textContaining('Masticar despacio'), findsOneWidget);
    await tocar(tester, 'cerrar-curiosidad');

    await tocar(tester, 'viaje-otra-vez');
    expect(find.text('Paradas recorridas: 0 de 2'), findsOneWidget);
    await tocar(tester, 'viaje-cambiar-nivel');
    expect(find.text('✓ Nivel superado'), findsOneWidget);
  });

  testWidgets('se puede tocar el cuerpo y arrastrar la manzana', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final diagrama = find.byKey(const Key('diagrama-digestivo'));
    final caja = tester.getRect(diagrama);
    // La boca está a la mitad del ancho y a 92/400 del alto del dibujo.
    final boca = Offset(caja.center.dx, caja.top + caja.height * 92 / 400);
    await tester.tapAt(boca);
    await tester.pumpAndSettle();
    expect(find.text('Paradas recorridas: 1 de 2'), findsOneWidget);
    expect(progreso.comboActual, 1);
    await masticarTodo(tester);
    expect(progreso.comboActual, 1);

    final inicio = tester.getCenter(find.byKey(const Key('bocado')));
    final barriga = Offset(caja.center.dx, caja.top + caja.height * 300 / 400);
    final gesto = await tester.startGesture(inicio);
    await gesto.moveTo(inicio + const Offset(0, -20));
    await tester.pump();
    await gesto.moveTo(barriga);
    await tester.pump();
    await gesto.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
  });

  testWidgets('Medio: avisa al saltar paradas y termina con la pregunta', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-medio');
    await tocar(tester, 'destino-boca');
    await masticarTodo(tester);
    await tocar(tester, 'destino-intestino');
    expect(find.textContaining('primero tengo que bajar'), findsOneWidget);
    await tocar(tester, 'destino-esofago');
    await tocar(tester, 'destino-estomago');
    await tocar(tester, 'destino-intestino');
    expect(find.byKey(const Key('pregunta-final')), findsOneWidget);
    expect(find.byKey(const Key('viaje-completo')), findsNothing);
    await tocar(tester, 'respuesta-final-aire');
    expect(find.textContaining('otro camino'), findsOneWidget);
    await tocar(tester, 'respuesta-final-energia');
    expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
    expect(progreso.fichaDesbloqueada('aparato-digestivo'), isTrue);
    expect(progreso.fichaDesbloqueada('nutrientes'), isFalse);
  });

  testWidgets('Difícil: pregunta en cada parada y da el último cromo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-dificil');
    expect(find.text('Paradas recorridas: 0 de 5'), findsOneWidget);
    await tocar(tester, 'destino-boca');
    expect(find.byKey(const Key('masticar')), findsOneWidget);
    await masticarTodo(tester);
    expect(find.byKey(const Key('pregunta-boca')), findsOneWidget);
    await tocar(tester, 'destino-esofago');
    expect(find.textContaining('responde qué pasa'), findsOneWidget);
    await tocar(tester, 'respuesta-boca-nutrientes');
    expect(find.textContaining('intestino delgado'), findsWidgets);
    await tocar(tester, 'respuesta-boca-masticar');
    expect(find.textContaining('bolo alimenticio'), findsOneWidget);
    final nivel = actividad.viaje!.niveles[2];
    for (final parada in nivel.paradas.skip(1)) {
      await tocar(tester, 'destino-${parada.id}');
      await tocar(
        tester,
        'respuesta-${parada.id}-${parada.pregunta!.respuesta}',
      );
    }
    expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
    expect(progreso.fichaDesbloqueada('nutrientes'), isTrue);
    expect(progreso.nivelesSuperadosDe(actividad), 1);
  });

  testWidgets('se juega en inglés sin cambiar las respuestas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester, idioma: 'en');
    expect(find.text("The food's journey"), findsOneWidget);
    await tocar(tester, 'nivel-facil');
    expect(find.text('Where does the apple go now?'), findsOneWidget);
    await tocar(tester, 'destino-pulmones');
    expect(find.textContaining('not food'), findsOneWidget);
    await tocar(tester, 'destino-boca');
    expect(find.text('Chew (0/3)'), findsOneWidget);
    await tocar(tester, 'masticar');
    expect(find.text('Yum! Bite 1 of 3. Keep chewing.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 568),
    const Size(700, 360),
    const Size(1024, 768),
  ]) {
    testWidgets('sin desbordamientos en $size con texto ampliado', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await abrir(tester, escala: 2);
      expect(tester.takeException(), isNull);
      await tocar(tester, 'nivel-facil');
      await recorrer(tester, 'facil');
      expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
      await tocar(tester, 'curiosidad-viaje');
      expect(tester.takeException(), isNull);
      await tocar(tester, 'cerrar-curiosidad');
      await tocar(tester, 'viaje-cambiar-nivel');
      await tocar(tester, 'nivel-dificil');
      await tocar(tester, 'destino-pulmones');
      expect(tester.takeException(), isNull);
      await recorrer(tester, 'dificil');
      expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
      await tocar(tester, 'viaje-cambiar-nivel');
      await tocar(tester, 'nivel-medio');
      await recorrer(tester, 'medio');
      expect(find.byKey(const Key('viaje-completo')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
