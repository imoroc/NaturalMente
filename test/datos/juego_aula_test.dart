import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

import '../soporte/jugar_aula.dart';
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
      final fila =
          jsonDecode(jsonEncode(juego.toFila())) as Map<String, dynamic>;
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
    expect((juego.preguntas[1] as PreguntaAula).correcta, 1);
  });

  Map<String, dynamic> fila(
    Map<String, dynamic> contenido, {
    List<int>? cursos,
  }) => {
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
      JuegoAula.desdeFila({
        ...fila({'preguntas': []}),
        'plantilla': 'otra',
      }),
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
          opciones: [
            OpcionAula(texto: 'Sí'),
            OpcionAula(texto: 'sí'),
          ],
          correcta: 0,
        ),
        PreguntaAula(
          enunciado: '¿Cuál?',
          opciones: [
            OpcionAula(texto: 'A'),
            OpcionAula(texto: ''),
          ],
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
    expect(
      ImagenAula.desdeJson({'escena': 'selva'}),
      const ImagenEscena('selva'),
    );
    expect(ImagenAula.desdeJson({'escena': 'planetas'}), isNull);
    expect(ImagenAula.desdeJson({'galeria': 'herbario'}), isA<ImagenGaleria>());
    expect(ImagenAula.desdeJson({'galeria': 'no-existe'}), isNull);
    expect(
      ImagenAula.desdeJson({'url': 'https://x.supabase.co/a.webp'}),
      isA<ImagenSubida>(),
    );
    expect(ImagenAula.desdeJson({'url': 'http://inseguro/a.png'}), isNull);
    expect(
      ImagenAula.desdeJson({'url': 'http://127.0.0.1:54321/a.jpg'}),
      isA<ImagenSubida>(),
      reason: 'el Supabase local de desarrollo',
    );
    expect(ImagenAula.desdeJson('texto'), isNull);
  });

  test('un juego con los 10 tipos de reto se guarda y se lee igual', () {
    final juego = juegoConTodosLosTipos();
    expect(juego.errores(), isEmpty);
    final fila = jsonDecode(jsonEncode(juego.toFila())) as Map<String, dynamic>;
    final leido = JuegoAula.desdeFila(fila)!;
    expect(leido.toFila(), juego.toFila());
    expect(leido.preguntas.map((r) => r.tipo).toSet(), TipoReto.values.toSet());
    expect(leido.evaluables, hasLength(9));
    final huecos = leido.preguntas[6] as HuecosAula;
    expect(huecos.respuestas, ['corazón', 'sangre']);
    expect((leido.preguntas[9] as PalabraAula).letras.join(), 'CEREBRO');
  });

  test('los juegos antiguos (sin tipo en cada pregunta) se siguen leyendo', () {
    final antiguo = JuegoAula.desdeFila({
      'id': 'viejo',
      'titulo': 'Viejo',
      'plantilla': 'verdadero_falso',
      'version': 3,
      'cursos': [2],
      'contenido': {
        'preguntas': [
          {'enunciado': 'Las ranas saltan.', 'correcta': true},
        ],
      },
      'tema': <String, dynamic>{},
    })!;
    expect(antiguo.preguntas.single.tipo, TipoReto.verdaderoFalso);
    expect((antiguo.preguntas.single as PreguntaAula).correcta, 0);
    expect(
      (antiguo.contenidoJson()['preguntas'] as List).single,
      {'enunciado': 'Las ranas saltan.', 'correcta': true},
      reason: 'se guarda igual que antes, sin versión nueva',
    );
  });

  test('cada tipo explica qué le falta', () {
    const vacios = <RetoAula>[
      ClasificarAula(enunciado: '', grupos: [], elementos: []),
      OrdenarAula(enunciado: '', pasos: [OpcionAula(texto: 'Uno')]),
      ParejasAula(enunciado: '', parejas: []),
      HuecosAula(enunciado: '', frase: 'Sin huecos'),
      BuscarAula(enunciado: '', zonas: []),
      NumeroAula(enunciado: '¿Cuántos?', respuesta: null),
      PalabraAula(enunciado: 'Palabra', respuesta: 'a'),
      LecturaAula(enunciado: '', texto: ''),
    ];
    for (final reto in vacios) {
      expect(reto.errores(1), isNotEmpty, reason: reto.tipo.id);
    }
    expect(const ZonaAula(0.5, 0.5, 0.1).contiene(0.55, 0.5), isTrue);
    expect(const ZonaAula(0.5, 0.5, 0.1).contiene(0.8, 0.5), isFalse);
  });

  test('un juego solo con tarjetas para leer no se puede publicar', () {
    const juego = JuegoAula(
      id: 'x',
      titulo: 'Solo leer',
      plantilla: PlantillaAula.libre,
      version: 1,
      cursos: [1],
      preguntas: [LecturaAula(enunciado: 'Hola', texto: 'Texto')],
    );
    expect(juego.errores(), ['Añade al menos una pregunta: las tarjetas para leer no cuentan.']);
  });
}
