import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> contenido() =>
      jsonDecode(File('content/catalog.json').readAsStringSync())
          as Map<String, dynamic>;

  test('carga herbario y conserva las cuatro actividades anteriores', () {
    final catalogo = Catalogo.desdeTexto(jsonEncode(contenido()));
    expect(
      catalogo.actividades.map((a) => a.id),
      containsAll(['hogar', 'germinacion', 'piezas', 'vida', 'herbario']),
    );
    final herbario = catalogo.actividades.firstWhere((a) => a.id == 'herbario');
    expect(herbario.medalla, isFalse);
    expect(herbario.herbario!.niveles.map((n) => n.partes.length), [3, 5, 5]);
  });

  test(
    'rechaza referencias rotas, partes duplicadas y preguntas incompletas',
    () {
      for (final defecto in [
        'referencia',
        'duplicada',
        'respuesta',
        'frase',
        'nivel',
      ]) {
        final mapa = contenido();
        final actividad = (mapa['actividades'] as List).firstWhere(
          (a) => a['id'] == 'herbario',
        );
        final herbario = actividad['herbario'];
        switch (defecto) {
          case 'referencia':
            herbario['niveles'][0]['partes'][0] = 'rama';
          case 'duplicada':
            herbario['partes'][1]['reto']['id'] = 'raiz';
          case 'respuesta':
            herbario['partes'][0]['preguntaFuncion']['respuesta'] =
                'inexistente';
          case 'frase':
            herbario['partes'][0]['reto']['frases'].remove('hoja');
          case 'nivel':
            herbario['niveles'][2]['id'] = 'medio';
        }
        expect(
          () => Catalogo.desdeTexto(jsonEncode(mapa)),
          throwsArgumentError,
          reason: defecto,
        );
      }
    },
  );

  test('guardar niveles conserva el progreso anterior y la medalla', () async {
    SharedPreferences.setMockInitialValues({
      'hechos': ['hogar/camello', 'vida'],
    });
    final catalogo = Catalogo.desdeTexto(jsonEncode(contenido()));
    final herbario = catalogo.actividades.firstWhere((a) => a.id == 'herbario');
    final progreso = await Progreso.abrir();
    await progreso.marcarNivelHerbario(herbario, 'facil');
    final reabierto = await Progreso.abrir();
    expect(reabierto.hecho('hogar/camello'), isTrue);
    expect(reabierto.hecho('vida'), isTrue);
    expect(reabierto.nivelHerbarioHecho(herbario, 'facil'), isTrue);
    expect(reabierto.nivelHerbarioHecho(herbario, 'medio'), isFalse);
    expect(reabierto.actividadHecha(herbario), isTrue);
    expect(reabierto.medallaConseguida(catalogo.actividades), isFalse);
    await expectLater(
      reabierto.marcarNivelHerbario(herbario, 'inventado'),
      throwsArgumentError,
    );
    for (final actividad in catalogo.actividades.where((a) => a.medalla)) {
      if (actividad.tipo == 'lugar') {
        for (final reto in actividad.retos) {
          await reabierto.marcarReto(actividad, reto);
        }
      } else {
        await reabierto.marcarActividad(actividad);
      }
    }
    expect(reabierto.medallaConseguida(catalogo.actividades), isTrue);
    expect(reabierto.nivelHerbarioHecho(herbario, 'dificil'), isFalse);
  });
}
