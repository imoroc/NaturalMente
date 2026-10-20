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
import 'package:naturalmente/ui/nacimiento.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    actividad = catalogo.actividades.firstWhere((a) => a.id == 'nacimiento');
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
            home: NacimientoPage(actividad: actividad),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String key) async {
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

  Future<void> ordenarCiclo(WidgetTester tester, List<String> pasos) async {
    for (final paso in pasos) {
      await tocar(tester, 'paso-$paso');
    }
    await tocar(tester, 'comprobar-ciclo');
  }

  Future<void> resolverCiclos(WidgetTester tester, String nivelId) async {
    final nivel = actividad.nacimiento!.niveles.firstWhere(
      (n) => n.id == nivelId,
    );
    for (final ciclo in nivel.ciclos) {
      await ordenarCiclo(tester, ciclo.respuesta);
      await tocar(tester, 'respuesta-${ciclo.id}-${ciclo.pregunta.respuesta}');
      if (ciclo != nivel.ciclos.last) await tocar(tester, 'siguiente-ciclo');
    }
  }

  testWidgets('el juego se abre desde La reserva con sus tres niveles', (
    tester,
  ) async {
    await tester.pumpWidget(const NaturalmenteApp());
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.byKey(const Key('zona-reserva')).evaluate().isNotEmpty) break;
    }
    await tocar(tester, 'zona-reserva');
    expect(find.text('¿Huevo o barriga?'), findsOneWidget);
    await tocar(tester, 'juego-nacimiento');
    for (final nivel in ['facil', 'medio', 'dificil']) {
      expect(find.byKey(Key('nivel-$nivel')), findsOneWidget);
    }
    expect(find.text('Cromo: Huevo o barriga'), findsOneWidget);
  });

  testWidgets('Fácil: se falla sin castigo, se consulta y se guarda', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    expect(find.text('Animales colocados: 0 de 6'), findsOneWidget);

    await tocar(tester, 'nido-huevo');
    expect(find.text('Elige primero un animal.'), findsOneWidget);

    await tocar(tester, 'animal-delfin');
    expect(
      find.text('Seleccionado: El delfín. Toca cómo nace.'),
      findsOneWidget,
    );
    await tocar(tester, 'nido-huevo');
    expect(find.textContaining('no es un pez'), findsOneWidget);
    expect(find.byIcon(Icons.replay_rounded), findsOneWidget);
    await tocar(tester, 'nido-huevo');
    expect(find.textContaining('respira aire'), findsOneWidget);
    await tocar(tester, 'nido-barriga');
    expect(find.text('Animales colocados: 1 de 6'), findsOneWidget);
    expect(find.byKey(const Key('animal-delfin')), findsNothing);

    await tocar(tester, 'colocado-delfin');
    expect(find.text('CUADERNO DE NATU'), findsOneWidget);
    expect(find.textContaining('cola por delante'), findsOneWidget);
    await tocar(tester, 'cerrar-curiosidad');

    final nacimiento = actividad.nacimiento!;
    for (final id in nacimiento.niveles.first.animales) {
      if (id == 'delfin') continue;
      await tocar(tester, 'animal-$id');
      await tocar(tester, 'nido-${nacimiento.animal(id).respuesta}');
    }
    expect(find.byKey(const Key('nacimiento-completo')), findsOneWidget);
    expect(progreso.nivelJuegoHecho(actividad, 'facil'), isTrue);
    expect(progreso.fichaDesbloqueada('huevo'), isTrue);
    expect(progreso.fichaDesbloqueada('renacuajo'), isFalse);
    expect(progreso.medallaConseguida(catalogo.actividades), isFalse);

    await tocar(tester, 'nacimiento-otra-vez');
    expect(find.text('Animales colocados: 0 de 6'), findsOneWidget);
    await tocar(tester, 'nacimiento-cambiar-nivel');
    expect(find.text('✓ Nivel superado'), findsOneWidget);
  });

  testWidgets('Fácil: un animal también se lleva arrastrándolo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-facil');
    final animal = find.byKey(const Key('animal-pinguino'));
    final nido = find.byKey(const Key('nido-huevo'));
    final inicio = tester.getCenter(animal);
    final gesto = await tester.startGesture(inicio);
    await gesto.moveTo(inicio + const Offset(0, -20));
    await tester.pump();
    await gesto.moveTo(tester.getCenter(nido));
    await tester.pump();
    await gesto.up();
    await tester.pumpAndSettle();
    expect(find.text('Animales colocados: 1 de 6'), findsOneWidget);
    expect(find.byKey(const Key('colocado-pinguino')), findsOneWidget);
  });

  testWidgets('Medio: ordena, recibe pistas, responde y pasa de ciclo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-medio');
    expect(find.text('Ciclo 1 de 2: La rana'), findsOneWidget);

    await tocar(tester, 'comprobar-ciclo');
    expect(find.textContaining('Faltan pasos'), findsOneWidget);

    await ordenarCiclo(tester, ['renacuajo', 'huevos-rana', 'ranita', 'rana']);
    expect(find.textContaining('muchos huevos blanditos'), findsOneWidget);
    await tocar(tester, 'comprobar-ciclo');
    expect(find.textContaining('Fíjate en la cola'), findsOneWidget);

    // Devolver los dos primeros pasos y colocarlos bien.
    await tocar(tester, 'hueco-0');
    await tocar(tester, 'hueco-1');
    expect(find.text('Pasos colocados: 2 de 4'), findsOneWidget);
    await tocar(tester, 'paso-huevos-rana');
    await tocar(tester, 'paso-renacuajo');
    await tocar(tester, 'comprobar-ciclo');
    expect(find.textContaining('metamorfosis'), findsWidgets);
    expect(find.byKey(const Key('pregunta-rana')), findsOneWidget);
    expect(find.byKey(const Key('siguiente-ciclo')), findsNothing);

    await tocar(tester, 'respuesta-rana-arbol');
    expect(find.textContaining('Todavía no tiene patas'), findsOneWidget);
    await tocar(tester, 'respuesta-rana-agua');
    await tocar(tester, 'curiosidad-ciclo');
    expect(find.textContaining('branquias'), findsWidgets);
    await tocar(tester, 'cerrar-curiosidad');

    await tocar(tester, 'siguiente-ciclo');
    expect(find.text('Ciclo 2 de 2: La mariposa'), findsOneWidget);
    expect(progreso.nivelJuegoHecho(actividad, 'medio'), isFalse);
    await ordenarCiclo(tester, [
      'huevo-mariposa',
      'oruga',
      'crisalida',
      'mariposa',
    ]);
    await tocar(tester, 'respuesta-mariposa-crecer');
    expect(find.byKey(const Key('nacimiento-completo')), findsOneWidget);
    expect(progreso.nivelJuegoHecho(actividad, 'medio'), isTrue);
    expect(progreso.fichaDesbloqueada('renacuajo'), isTrue);
    expect(progreso.fichaDesbloqueada('mariposa'), isFalse);
  });

  testWidgets('Difícil completa las dos metamorfosis y da el último cromo', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester);
    await tocar(tester, 'nivel-dificil');
    expect(find.text('Pasos colocados: 0 de 5'), findsOneWidget);
    await resolverCiclos(tester, 'dificil');
    expect(find.byKey(const Key('nacimiento-completo')), findsOneWidget);
    expect(progreso.fichaDesbloqueada('mariposa'), isTrue);
    expect(progreso.nivelesSuperadosDe(actividad), 1);
  });

  testWidgets('se juega en inglés sin cambiar las respuestas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester, idioma: 'en');
    expect(find.text('Egg or tummy?'), findsOneWidget);
    await tocar(tester, 'nivel-facil');
    await tocar(tester, 'animal-camello');
    expect(
      find.text('Selected: The camel. Tap how it is born.'),
      findsOneWidget,
    );
    await tocar(tester, 'nido-huevo');
    expect(find.textContaining('it does not lay eggs'), findsOneWidget);
    await tocar(tester, 'nido-barriga');
    expect(find.text('Animals placed: 1 of 6'), findsOneWidget);
    await tocar(tester, 'nacimiento-cambiar-nivel');
    await tocar(tester, 'nivel-medio');
    expect(find.text('Cycle 1 of 2: The frog'), findsOneWidget);
    expect(find.text('Tadpole with a tail'), findsOneWidget);
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
      await tocar(tester, 'animal-oso');
      await tocar(tester, 'nido-huevo');
      expect(tester.takeException(), isNull);
      await tocar(tester, 'nido-barriga');
      await tocar(tester, 'colocado-oso');
      expect(tester.takeException(), isNull);
      await tocar(tester, 'cerrar-curiosidad');
      await tocar(tester, 'nacimiento-cambiar-nivel');
      await tocar(tester, 'nivel-dificil');
      await ordenarCiclo(tester, [
        'renacuajo',
        'huevos-rana',
        'patas',
        'ranita',
        'rana',
      ]);
      expect(tester.takeException(), isNull);
      await tocar(tester, 'nacimiento-cambiar-nivel');
      await tocar(tester, 'nivel-dificil');
      await resolverCiclos(tester, 'dificil');
      expect(find.byKey(const Key('nacimiento-completo')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
