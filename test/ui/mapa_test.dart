import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/main.dart';

void main() {
  testWidgets('el mapa abre la reserva y el polo responde', (tester) async {
    await tester.pumpWidget(const NaturalmenteApp());
    await tester.pumpAndSettle();

    expect(find.text('NaturalMente'), findsOneWidget);
    expect(find.text('La reserva'), findsOneWidget);
    expect(find.text('El invernadero'), findsOneWidget);
    expect(find.text('Dentro de mí'), findsOneWidget);

    await tester.tap(find.byKey(const Key('zona-reserva')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lugar-polo')));
    await tester.pumpAndSettle();

    expect(find.textContaining('frío'), findsOneWidget);

    await tester.tap(find.byKey(const Key('lugar-polo')));
    await tester.pumpAndSettle();
    expect(find.textContaining('poca agua'), findsOneWidget);
  });
}
