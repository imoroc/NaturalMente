import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

import '../soporte/repositorio_aula_falso.dart';

void main() {
  test('todos los fondos de la galería existen y están declarados', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final (asset, _) in galeriaAula.values) {
      expect(File(asset).existsSync(), isTrue, reason: asset);
      final carpeta = asset.substring(0, asset.lastIndexOf('/') + 1);
      expect(pubspec, contains(carpeta), reason: carpeta);
    }
  });

  for (final plantilla in PlantillaAula.values) {
    test('${plantilla.id}: guardar y volver a leer da el mismo juego', () {
      final juego = juegoDePrueba(plantilla: plantilla);
      final fila = jsonDecode(jsonEncode(juego.toFila())) as Map<String, dynamic>;
      final leido = JuegoAula.desdeFila(fila)!;
      expect(leido.toFila(), juego.toFila());
      expect(leido.errores(), isEmpty);
    });
  }

  test('verdadero o falso se guarda como un booleano', () {
    final juego = juegoDePrueba(plantilla: PlantillaAula.verdaderoFalso);
    final preguntas = juego.contenidoJson()['preguntas'] as List<dynamic>;
    expect((preguntas.first as Map)['correcta'], isTrue);
    expect((preguntas.first as Map).containsKey('opciones'), isFalse);
    expect(juego.preguntas[1].correcta, 1);
  });

  Map<String, dynamic> fila(Map<String, dynamic> contenido, {List<int>? cursos}) => {
    'id': 'x',
    'titulo': 'Prueba',
    'plantilla': 'opcion_multiple',
    'version': 1,
    'cursos': cursos ?? [2],
    'contenido': contenido,
    'tema': <String, dynamic>{},
  };

  test('un juego mal guardado no se muestra en vez de romper Aula', () {
    expect(JuegoAula.desdeFila({'id': 'x'}), isNull);
    expect(
      JuegoAula.desdeFila({...fila({'preguntas': []}), 'plantilla': 'otra'}),
      isNull,
    );
    expect(JuegoAula.desdeFila(fila({'preguntas': []})), isNull);
    expect(
      JuegoAula.desdeFila(
        fila({
          'preguntas': [
            {
              'enunciado': '¿?',
              'opciones': [
                {'texto': 'A'},
                {'texto': 'B'},
              ],
              'correcta': 5,
            },
          ],
        }),
      ),
      isNull,
    );
  });

  test('los errores se explican al profesor pregunta por pregunta', () {
    const juego = JuegoAula(
      id: 'x',
      titulo: '',
      plantilla: PlantillaAula.opcionMultiple,
      version: 1,
      cursos: [],
      preguntas: [
        PreguntaAula(
          enunciado: '',
          opciones: [OpcionAula(texto: 'Sí'), OpcionAula(texto: 'sí')],
          correcta: 0,
        ),
        PreguntaAula(
          enunciado: '¿Cuál?',
          opciones: [OpcionAula(texto: 'A'), OpcionAula(texto: '')],
          correcta: 3,
        ),
      ],
    );
    expect(juego.errores(), [
      'Ponle un título al juego.',
      'Elige al menos un curso.',
      'La pregunta 1 no tiene texto ni imagen.',
      'La pregunta 1 tiene respuestas repetidas.',
      'Hay una respuesta vacía en la pregunta 2.',
      'Marca la respuesta correcta de la pregunta 2.',
    ]);
  });

  test('solo se aceptan imágenes de la galería o subidas por https', () {
    expect(ImagenAula.desdeJson({'galeria': 'herbario'}), isA<ImagenGaleria>());
    expect(ImagenAula.desdeJson({'galeria': 'no-existe'}), isNull);
    expect(
      ImagenAula.desdeJson({'url': 'https://x.supabase.co/a.webp'}),
      isA<ImagenSubida>(),
    );
    expect(ImagenAula.desdeJson({'url': 'http://inseguro/a.png'}), isNull);
    expect(ImagenAula.desdeJson('texto'), isNull);
  });
}
