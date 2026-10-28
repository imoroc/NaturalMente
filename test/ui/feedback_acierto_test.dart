import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _JuegoPrueba extends StatefulWidget {
  const _JuegoPrueba();

  @override
  State<_JuegoPrueba> createState() => _JuegoPruebaState();
}

class _JuegoPruebaState extends State<_JuegoPrueba>
    with FeedbackAcierto<_JuegoPrueba> {
  int toques = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ejercicio')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          FilledButton(onPressed: mostrarAcierto, child: const Text('Acierto')),
          FilledButton(
            onPressed: () => mostrarAcierto(finalDeNivel: true),
            child: const Text('Final'),
          ),
          FilledButton(onPressed: ocultarAcierto, child: const Text('Repetir')),
          const SizedBox(height: 500),
          FilledButton(
            onPressed: () {
              setState(() => toques++);
              mostrarAcierto();
            },
            child: Text('Seguir: $toques'),
          ),
        ],
      ),
    ),
  );
}

void main() {
  const canalAudio = MethodChannel('naturalmente/audio');
  const canalHaptica = MethodChannel('naturalmente/haptica');
  final llamadas = <MethodCall>[];
  final pulsos = <MethodCall>[];
  final vibraciones = <String>[];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    llamadas.clear();
    pulsos.clear();
    vibraciones.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalAudio, (llamada) async {
          llamadas.add(llamada);
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalHaptica, (llamada) async {
          pulsos.add(llamada);
          return true;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (llamada) async {
          if (llamada.method == 'HapticFeedback.vibrate') {
            vibraciones.add(llamada.arguments as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalAudio, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canalHaptica, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> abrir(
    WidgetTester tester, {
    bool reducido = false,
    bool sonido = true,
    bool vibracion = true,
  }) async {
    SharedPreferences.setMockInitialValues({
      'sonido': sonido,
      'vibracion': vibracion,
    });
    final idioma = Idioma(await SharedPreferences.getInstance(), const {});
    await tester.runAsync(idioma.prepararAciertos);
    await tester.pumpWidget(
      IdiomaScope(
        idioma: idioma,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reducido),
            child: child!,
          ),
          home: const _JuegoPrueba(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder getCheck() => find.byKey(const Key('check-acierto'));

  double opacidad(WidgetTester tester) => tester
      .widget<Opacity>(
        find.ancestor(of: getCheck(), matching: find.byType(Opacity)).first,
      )
      .opacity;

  testWidgets('aparece con audio y vibración, aguanta y se desvanece', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Acierto'));
    expect(llamadas, isEmpty);
    await tester.pump();
    expect(getCheck(), findsOneWidget);
    expect(llamadas.single.arguments['id'], 'acierto');
    expect(pulsos.single.method, 'acierto');
    expect(pulsos.single.arguments['finalDeNivel'], isFalse);
    expect(vibraciones, isEmpty);
    expect(tester.getCenter(getCheck()), const Offset(400, 300));
    await tester.pump(const Duration(milliseconds: 350));
    expect(opacidad(tester), 1);
    await tester.pump(const Duration(milliseconds: 500));
    expect(opacidad(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(getCheck(), findsNothing);
    expect(llamadas, hasLength(1));
  });

  testWidgets('el trazo conserva un verde intenso sobre el círculo claro', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Acierto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 430));
    final boundary = tester
        .element(getCheck())
        .findAncestorRenderObjectOfType<RenderRepaintBoundary>()!;
    final color = await tester.runAsync(() async {
      final imagen = await boundary.toImage();
      final bytes = await imagen.toByteData(format: ui.ImageByteFormat.rawRgba);
      // Punto interior de la unión de los dos brazos del check.
      final x = (imagen.width * .46).round();
      final y = (imagen.height * .60).round();
      final indice = (y * imagen.width + x) * 4;
      final color = Color.fromARGB(
        bytes!.getUint8(indice + 3),
        bytes.getUint8(indice),
        bytes.getUint8(indice + 1),
        bytes.getUint8(indice + 2),
      );
      imagen.dispose();
      return color;
    });
    expect(color!.a, 1);
    expect(color.r, lessThan(.25));
    expect(color.g, greaterThan(color.r * 2));
    await tester.pumpAndSettle();
  });

  testWidgets('el final es mayor y acompaña la fanfarria antes de salir', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Acierto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final tamanoNormal = tester.getSize(getCheck());
    await tester.tap(find.text('Final'));
    await tester.pump();
    expect(getCheck(), findsOneWidget);
    expect(tester.getSize(getCheck()).width, greaterThan(tamanoNormal.width));
    expect(llamadas.last.arguments['id'], 'celebracion');
    expect(pulsos.last.arguments['finalDeNivel'], isTrue);
    expect(vibraciones, isEmpty);
    await tester.pump(const Duration(milliseconds: 1300));
    expect(opacidad(tester), 1);
    await tester.pump(const Duration(milliseconds: 700));
    expect(opacidad(tester), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
    expect(getCheck(), findsNothing);
  });

  testWidgets('sigue centrado al desplazar y permite tocar detrás', (
    tester,
  ) async {
    await abrir(tester);
    await tester.ensureVisible(find.text('Seguir: 0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seguir: 0'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.getCenter(getCheck()), const Offset(400, 300));
    await tester.tap(find.text('Seguir: 1'));
    await tester.pump();
    expect(find.text('Seguir: 2'), findsOneWidget);
    expect(getCheck(), findsOneWidget);
    await tester.pumpAndSettle();
    expect(getCheck(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('movimiento reducido conserva confirmación sin rebote', (
    tester,
  ) async {
    await abrir(tester, reducido: true, sonido: false, vibracion: false);
    await tester.tap(find.text('Final'));
    await tester.pump();
    final transformacion = tester.widget<Transform>(
      find.ancestor(of: getCheck(), matching: find.byType(Transform)).first,
    );
    expect(transformacion.transform.getMaxScaleOnAxis(), 1);
    await tester.pump(const Duration(milliseconds: 350));
    expect(opacidad(tester), 1);
    expect(llamadas, isEmpty);
    expect(pulsos, isEmpty);
    expect(vibraciones, isEmpty);
    await tester.pumpAndSettle();
    expect(getCheck(), findsNothing);
  });

  testWidgets('vibración y sonido respetan sus ajustes por separado', (
    tester,
  ) async {
    await abrir(tester, sonido: false);
    await tester.tap(find.text('Final'));
    await tester.pump();
    expect(pulsos.single.arguments['finalDeNivel'], isTrue);
    expect(llamadas, isEmpty);
    await tester.pumpAndSettle();

    pulsos.clear();
    await abrir(tester, vibracion: false);
    await tester.tap(find.text('Acierto'));
    await tester.pump();
    expect(llamadas.single.arguments['id'], 'acierto');
    expect(pulsos, isEmpty);
    expect(vibraciones, isEmpty);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'usa háptica del sistema si el patrón nativo no está disponible',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(canalHaptica, (llamada) async {
            throw PlatformException(code: 'vibracion_no_disponible');
          });
      await abrir(tester);
      await tester.tap(find.text('Acierto'));
      await tester.pump();
      expect(vibraciones, ['HapticFeedbackType.mediumImpact']);
      await tester.tap(find.text('Final'));
      await tester.pump();
      expect(vibraciones.last, 'HapticFeedbackType.successNotification');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('repetir o salir elimina el overlay y cancela su reloj', (
    tester,
  ) async {
    await abrir(tester);
    await tester.tap(find.text('Acierto'));
    await tester.pump();
    await tester.tap(find.text('Repetir'));
    await tester.pump();
    expect(getCheck(), findsNothing);
    await tester.tap(find.text('Final'));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();
    expect(getCheck(), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
