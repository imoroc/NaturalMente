import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _JuegoFinal extends StatefulWidget {
  const _JuegoFinal({required this.guardar});
  final Future<bool> Function() guardar;

  @override
  State<_JuegoFinal> createState() => _JuegoFinalState();
}

class _JuegoFinalState extends State<_JuegoFinal>
    with FeedbackAcierto<_JuegoFinal> {
  bool completo = false;
  int aciertos = 0;

  @override
  DatosFinJuego? construirFinJuego() => completo
      ? DatosFinJuego(
          actividad: 'Herbario desmontable',
          nivel: 'Fácil',
          resumen: Text('Aciertos: $aciertos'),
          onRepetir: () {
            ocultarAcierto();
            setState(() => completo = false);
          },
          onCambiarNivel: () {
            ocultarAcierto();
            setState(() => completo = false);
          },
          onVolver: () => Navigator.of(context).pop(),
        )
      : null;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Text('Aciertos: $aciertos'),
        FilledButton(
          key: const Key('completar'),
          onPressed: completo
              ? null
              : () {
                  setState(() {
                    completo = true;
                    aciertos++;
                  });
                  mostrarAcierto(finalDeNivel: true);
                  registrarGuardadoFinal(widget.guardar);
                },
          child: const Text('Completar'),
        ),
        TextButton(
          key: const Key('reiniciar'),
          onPressed: () {
            ocultarAcierto();
            setState(() => completo = false);
          },
          child: const Text('Reiniciar'),
        ),
      ],
    ),
  );
}

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
    }),
  );

  Future<void> abrir(
    WidgetTester tester, {
    Future<bool> Function()? guardar,
    Size size = const Size(390, 780),
    double escala = 1,
    bool reducido = false,
    String codigo = 'es',
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
      'idioma': codigo,
    });
    final traducciones = (jsonDecode(
      File('content/en.json').readAsStringSync(),
    ) as Map).cast<String, String>();
    final idioma = Idioma(await SharedPreferences.getInstance(), traducciones);
    await tester.pumpWidget(
      IdiomaScope(
        idioma: idioma,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(escala),
              disableAnimations: reducido,
            ),
            child: child!,
          ),
          home: _JuegoFinal(guardar: guardar ?? () async => true),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> completar(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('completar')));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'encadena victoria, opciones y repetición sin duplicar el cierre',
    (tester) async {
      await abrir(tester);
      await tester.tap(find.byKey(const Key('completar')));
      await tester.pump();
      expect(find.byType(AnimacionAcierto), findsOneWidget);
      expect(find.byType(FinJuego), findsNothing);
      await tester.tap(find.byKey(const Key('reiniciar')), warnIfMissed: false);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('completar')))
            .onPressed,
        isNull,
      );
      await tester.pump(const Duration(milliseconds: 2200));
      expect(find.byType(FinJuego), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(AnimacionAcierto), findsNothing);
      expect(find.byType(FinJuego), findsOneWidget);
      await tester.tap(find.byKey(const Key('fin-repetir')));
      await tester.pumpAndSettle();
      expect(find.byType(FinJuego), findsNothing);
      await completar(tester);
      expect(find.byType(FinJuego), findsOneWidget);
      expect(find.text('Aciertos: 2'), findsNWidgets(2));
    },
  );

  testWidgets(
    'dos avisos de victoria conservan el guardado en curso y un solo cierre',
    (tester) async {
      final guardado = Completer<bool>();
      await abrir(tester, guardar: () => guardado.future);
      await tester.tap(find.byKey(const Key('completar')));
      await tester.pump();
      tester
          .state<_JuegoFinalState>(find.byType(_JuegoFinal))
          .mostrarAcierto(finalDeNivel: true);
      await tester.pumpAndSettle();
      expect(find.byType(FinJuego), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('fin-nivel')))
            .onPressed,
        isNull,
      );
      guardado.complete(true);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('fin-nivel')))
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('espera el guardado y permite reintentar sin volver a puntuar', (
    tester,
  ) async {
    final guardado = Completer<bool>();
    var intentos = 0;
    await abrir(
      tester,
      guardar: () {
        intentos++;
        return intentos == 1 ? guardado.future : Future.value(true);
      },
    );
    await completar(tester);
    expect(find.text('Guardando tu progreso…'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('fin-nivel'))).onPressed,
      isNull,
    );
    guardado.complete(false);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fin-guardar')), findsOneWidget);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('fin-repetir')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('fin-guardar')));
    await tester.pumpAndSettle();
    expect(intentos, 2);
    expect(find.text('Aciertos: 1'), findsNWidgets(2));
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('fin-nivel'))).onPressed,
      isNotNull,
    );
    await tester.tap(find.byKey(const Key('fin-seguir')));
    await tester.pumpAndSettle();
    expect(find.byType(FinJuego), findsNothing);
    expect(find.text('Aciertos: 1'), findsOneWidget);
  });

  testWidgets(
    'cancelar o desmontar durante la victoria no deja un cierre pendiente',
    (tester) async {
      await abrir(tester);
      await tester.tap(find.byKey(const Key('completar')));
      await tester.pump();
      tester
          .widget<TextButton>(find.byKey(const Key('reiniciar')))
          .onPressed!();
      await tester.pumpAndSettle();
      expect(find.byType(FinJuego), findsNothing);
      await tester.tap(find.byKey(const Key('completar')));
      await tester.pump();
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();
      expect(find.byType(FinJuego), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(700, 360)]) {
    testWidgets(
      '$size: opciones visibles con texto doble, inglés y movimiento reducido',
      (tester) async {
        await abrir(
          tester,
          size: size,
          escala: 2,
          reducido: true,
          codigo: 'en',
        );
        await completar(tester);
        expect(find.text('Level complete!'), findsOneWidget);
        expect(find.text('Your progress is saved.'), findsOneWidget);
        for (final key in ['fin-nivel', 'fin-repetir', 'fin-volver']) {
          final rect = tester.getRect(find.byKey(Key(key)));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
