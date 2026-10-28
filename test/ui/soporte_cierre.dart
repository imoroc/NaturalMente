import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';

/// Permite que las pruebas del contenido continúen explorando tras el cierre.
/// Las pruebas específicas del final eligen sus acciones de forma explícita.
Future<void> seguirExplorando(WidgetTester tester) async {
  final victoria = find.byWidgetPredicate(
    (widget) => widget is AnimacionAcierto && widget.finalDeNivel,
  );
  if (victoria.evaluate().isNotEmpty) {
    await tester.pump(AnimacionAcierto.duracionFinal);
    await tester.pumpAndSettle();
  }
  final cerrar = find.byKey(const Key('fin-seguir'));
  if (cerrar.evaluate().isEmpty) return;
  await tester.tap(cerrar);
  await tester.pumpAndSettle();
}
