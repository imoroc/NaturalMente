import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('al cerrar y abrir siguen la medalla y los retos', () async {
    SharedPreferences.setMockInitialValues({});
    final catalogo = Catalogo.desdeTexto(
      File('content/catalog.json').readAsStringSync(),
    );
    final hogar = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final germinacion = catalogo.actividades.firstWhere((a) => a.id == 'germinacion');
    final piezas = catalogo.actividades.firstWhere((a) => a.id == 'piezas');

    final primera = await Progreso.abrir();
    expect(primera.medallaConseguida(catalogo.actividades), isFalse);
    for (final reto in hogar.retos) {
      await primera.marcarReto(hogar, reto);
    }
    await primera.marcarActividad(germinacion);
    for (final reto in piezas.retos) {
      await primera.marcarReto(piezas, reto);
    }

    final segunda = await Progreso.abrir();
    expect(segunda.retoHecho(hogar, hogar.retos.first), isTrue);
    expect(segunda.actividadHecha(germinacion), isTrue);
    expect(segunda.medallaConseguida(catalogo.actividades), isTrue);
  });
}
