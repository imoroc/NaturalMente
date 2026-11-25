import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:image/image.dart' as img;
import 'package:naturalmente/panel/editor_juego.dart';
import 'package:naturalmente/panel/imagenes_panel.dart';
import 'package:naturalmente/panel/panel_app.dart';
import 'package:naturalmente/panel/repositorio_panel.dart';
import 'package:naturalmente/panel/resultados_page.dart';
import 'package:naturalmente/ui/aula/juego_aula_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;

import '../soporte/repositorio_aula_falso.dart';

class _PanelFalso implements RepositorioPanel {
  String? sesion;
  final Map<String, FichaJuego> juegos = {};
  bool ranking = true;
  int guardados = 0;
  List<PartidaPanel> partidasGuardadas = const [];

  @override
  Future<String?> profesorActual() async => sesion;

  @override
  Future<String> entrar(String identificador, String contrasena) async {
    final usuario = identificador.trim().toLowerCase();
    if ((usuario == 'profe.luis' || usuario == 'luis@colegio.es') &&
        contrasena == 'pino-nube-zorro-rio-27') {
      return sesion = 'Luis';
    }
    throw const ErrorPanel('El usuario o la contraseña no son correctos.');
  }

  @override
  Future<void> entrarConProveedor(OAuthProvider proveedor) async =>
      throw StateError('Proveedor sin configurar');

  @override
  Future<void> salir() async => sesion = null;

  @override
  Future<List<FichaJuego>> misJuegos() async => juegos.values.toList();

  @override
  Future<FichaJuego> guardar(JuegoAula juego, EstadoJuego estado) async {
    if (estado == EstadoJuego.publicado && juego.errores().isNotEmpty) {
      throw ErrorPanel(juego.errores().first);
    }
    guardados++;
    final id = juego.id.isEmpty ? 'j${juegos.length + 1}' : juego.id;
    final anterior = juegos[id]?.juego;
    final version = anterior == null
        ? 1
        : (anterior.contenidoJson().toString() ==
                  juego.contenidoJson().toString()
              ? anterior.version
              : anterior.version + 1);
    return juegos[id] = FichaJuego(
      juego: juego.copiar(id: id, version: version),
      estado: estado,
      actualizado: DateTime(2026, 11, 25),
    );
  }

  @override
  Future<void> borrar(String juegoId) async => juegos.remove(juegoId);

  int subidas = 0;

  @override
  Future<ImagenSubida> subirImagen(Uint8List jpg) async => ImagenSubida(
    'https://ejemplo.supabase.co/storage/v1/object/public/imagenes/p/${++subidas}.jpg',
  );

  @override
  Future<bool> rankingActivo() async => ranking;

  @override
  Future<void> cambiarRanking(bool activo) async => ranking = activo;

  @override
  Future<List<PartidaPanel>> partidas(String juegoId) async =>
      partidasGuardadas;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _PanelFalso repo;

  setUp(() => repo = _PanelFalso());

  Future<void> abrirPanel(
    WidgetTester tester, {
    Size tamano = const Size(1400, 1000),
  }) async {
    await tester.binding.setSurfaceSize(tamano);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(PanelApp(repositorio: repo));
    await tester.pumpAndSettle();
  }

  Future<void> buscar(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        300,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('editor-formulario')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }
    await tester.ensureVisible(finder);
  }

  Future<void> tocar(WidgetTester tester, Finder finder) async {
    await buscar(tester, finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> escribir(
    WidgetTester tester,
    Finder finder,
    String texto,
  ) async {
    await buscar(tester, finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, texto);
    await tester.pump();
  }

  Future<void> entrar(WidgetTester tester, String usuario, String clave) async {
    await tester.enterText(find.byKey(const Key('panel-usuario')), usuario);
    await tester.enterText(find.byKey(const Key('panel-contrasena')), clave);
    await tester.tap(find.byKey(const Key('panel-entrar')));
    await tester.pumpAndSettle();
  }

  testWidgets('se entra con el nombre de usuario o con el correo', (
    tester,
  ) async {
    await abrirPanel(tester);
    await entrar(tester, 'profe.luis', 'mal');
    expect(
      find.text('El usuario o la contraseña no son correctos.'),
      findsOneWidget,
    );

    await entrar(tester, ' Profe.Luis ', 'pino-nube-zorro-rio-27');
    expect(find.text('¡Hola, Luis!'), findsOneWidget);
    expect(find.byKey(const Key('panel-sin-juegos')), findsOneWidget);

    await tester.tap(find.byKey(const Key('panel-salir')));
    await tester.pumpAndSettle();
    await entrar(tester, 'luis@colegio.es', 'pino-nube-zorro-rio-27');
    expect(find.text('¡Hola, Luis!'), findsOneWidget);
  });

  testWidgets('un botón de proveedor sin configurar avisa sin romper', (
    tester,
  ) async {
    await abrirPanel(tester);
    await tester.tap(find.byKey(const Key('panel-microsoft')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('panel-error')), findsOneWidget);
  });

  testWidgets(
    'crear un test, ver errores al publicar, completarlo y publicarlo',
    (tester) async {
      repo.sesion = 'Luis';
      await abrirPanel(tester);
      await tocar(tester, find.byKey(const Key('panel-nuevo')));
      await tester.pumpAndSettle();
      await tocar(
        tester,
        find.byKey(const Key('editor-plantilla-opcion_multiple')),
      );
      await tester.pumpAndSettle();

      // Publicar a medias explica qué falta y no publica.
      await tocar(tester, find.byKey(const Key('editor-publicar')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('editor-errores')), findsOneWidget);
      expect(
        repo.juegos.values.where((f) => f.estado == EstadoJuego.publicado),
        isEmpty,
      );
      expect(find.byKey(const Key('vista-previa-pendiente')), findsOneWidget);

      await escribir(
        tester,
        find.byKey(const Key('editor-titulo')),
        'Los vertebrados',
      );
      await tocar(tester, find.byKey(const Key('editor-curso-3')));
      await tocar(tester, find.byKey(const Key('editor-fondo-herbario')));
      await escribir(
        tester,
        find.byKey(const Key('editor-enunciado-1')),
        '¿Cuál es un mamífero?',
      );
      await escribir(
        tester,
        find.byKey(const Key('editor-opcion-1-0')),
        'Tiburón',
      );
      await escribir(
        tester,
        find.byKey(const Key('editor-opcion-1-1')),
        'Delfín',
      );
      await tocar(tester, find.byKey(const Key('editor-anadir-opcion-1')));
      await tester.pump();
      await escribir(
        tester,
        find.byKey(const Key('editor-opcion-1-2')),
        'Pulpo',
      );
      await tocar(tester, find.byKey(const Key('editor-correcta-1-1')));
      await escribir(
        tester,
        find.byKey(const Key('editor-pista-1')),
        'Piensa en cómo respira.',
      );
      await tester.pumpAndSettle();

      // Los borradores se guardan solos.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(repo.juegos, hasLength(1));
      expect(repo.juegos.values.single.estado, EstadoJuego.borrador);
      expect(find.text('Guardado'), findsOneWidget);

      // La vista previa es la pantalla del niño.
      expect(find.byKey(const Key('vista-previa')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(JuegoAulaPage),
          matching: find.text('¿Cuál es un mamífero?'),
        ),
        findsOneWidget,
      );

      await tocar(tester, find.byKey(const Key('editor-publicar')));
      await tester.pumpAndSettle();
      expect(
        find.text('¡Publicado! Tus alumnos ya lo ven en Aula.'),
        findsOneWidget,
      );
      final publicado = repo.juegos.values.single;
      expect(publicado.estado, EstadoJuego.publicado);
      expect(publicado.juego.cursos, [3]);
      expect(publicado.juego.preguntas.single.correcta, 1);
      expect(publicado.juego.preguntas.single.opciones.map((o) => o.texto), [
        'Tiburón',
        'Delfín',
        'Pulpo',
      ]);
      expect(publicado.juego.fondo, const ImagenGaleria('herbario'));

      // Un juego publicado no se autoguarda: cada guardado es una versión.
      final antes = repo.guardados;
      await escribir(
        tester,
        find.byKey(const Key('editor-pista-1')),
        'Otra pista',
      );
      await tester.pump(const Duration(seconds: 3));
      expect(repo.guardados, antes);
      expect(find.text('Cambios sin guardar'), findsOneWidget);
    },
  );

  testWidgets('verdadero o falso pide elegir si la frase es verdadera', (
    tester,
  ) async {
    repo.sesion = 'Luis';
    await abrirPanel(tester, tamano: const Size(800, 1000));
    await tocar(tester, find.byKey(const Key('panel-nuevo')));
    await tester.pumpAndSettle();
    await tocar(
      tester,
      find.byKey(const Key('editor-plantilla-verdadero_falso')),
    );
    await tester.pumpAndSettle();
    await escribir(
      tester,
      find.byKey(const Key('editor-titulo')),
      'Verdad o mentira',
    );
    await tocar(tester, find.byKey(const Key('editor-curso-1')));
    await escribir(
      tester,
      find.byKey(const Key('editor-enunciado-1')),
      'La ballena es un pez.',
    );
    await tester.pumpAndSettle();
    await tocar(tester, find.byKey(const Key('editor-publicar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-errores')), findsOneWidget);

    await tocar(tester, find.text('Falsa'));
    await tester.pumpAndSettle();
    await tocar(tester, find.byKey(const Key('editor-publicar')));
    await tester.pumpAndSettle();
    final juego = repo.juegos.values.single;
    expect(juego.estado, EstadoJuego.publicado);
    expect(juego.juego.preguntas.single.correcta, 1);
    expect(juego.juego.contenidoJson()['preguntas'], [
      {'enunciado': 'La ballena es un pez.', 'correcta': false},
    ]);
  });

  testWidgets('el profe apaga el ranking y borra un juego', (tester) async {
    repo
      ..sesion = 'Luis'
      ..juegos['juego-1'] = FichaJuego(
        juego: juegoDePrueba(),
        estado: EstadoJuego.publicado,
        actualizado: DateTime(2026, 11, 20),
      );
    await abrirPanel(tester);
    expect(find.byKey(const Key('panel-juego-juego-1')), findsOneWidget);

    await tester.tap(find.byKey(const Key('panel-ranking')));
    await tester.pumpAndSettle();
    expect(repo.ranking, isFalse);

    await tester.tap(find.byKey(const Key('panel-borrar-juego-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('panel-confirmar-borrar')));
    await tester.pumpAndSettle();
    expect(repo.juegos, isEmpty);
    expect(find.byKey(const Key('panel-sin-juegos')), findsOneWidget);
  });

  test('los resultados usan la primera partida de cada niño por pregunta', () {
    final juego = juegoDePrueba(version: 2);
    const zorro = Perfil(
      id: 'a',
      animal: 'zorro',
      adjetivo: 'veloz',
      color: 'azul',
    );
    const rana = Perfil(
      id: 'b',
      animal: 'rana',
      adjetivo: 'feliz',
      color: 'rojo',
    );
    PartidaPanel partida(
      Perfil perfil,
      List<bool> respuestas,
      int dia, {
      int version = 2,
    }) => PartidaPanel(
      perfilId: perfil.id,
      perfil: perfil,
      version: version,
      aciertos: respuestas.where((r) => r).length,
      total: respuestas.length,
      respuestas: respuestas,
      jugado: DateTime(2026, 11, dia),
    );
    final resumen = ResumenResultados.calcular([
      partida(zorro, [false, true, true], 20),
      partida(zorro, [true, true, true], 21),
      partida(rana, [true, false, true], 22),
      partida(rana, [false, false, false], 10, version: 1),
    ], juego);
    expect(
      resumen.porPerfil.map((f) => (f.perfil.animal, f.partidas, f.mejor)),
      [('zorro', 2, 100), ('rana', 2, 67)],
    );
    expect(resumen.porPregunta, [50, 50, 100]);
    expect(resumen.mediaPorcentaje, 58, reason: '(67 + 100 + 67 + 0) / 4');
  });

  test('las fotos se reducen a 1600 px en JPEG y pesan poco', () {
    final grande = img.Image(width: 4000, height: 3000);
    for (var y = 0; y < grande.height; y += 1) {
      for (var x = 0; x < grande.width; x += 1) {
        grande.setPixelRgb(x, y, x % 256, y % 256, (x * y) % 256);
      }
    }
    final jpg = comprimirImagen(img.encodePng(grande, level: 1));
    final leida = img.decodeJpg(jpg)!;
    expect((leida.width, leida.height), (1600, 1200));
    expect(jpg.length, lessThanOrEqualTo(pesoMaximoImagen));
    expect(
      () => comprimirImagen(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<ErrorPanel>()),
    );
  });

  testWidgets('subir una foto de fondo y otra para una pregunta', (
    tester,
  ) async {
    final anterior = ImagenDeAula.proveedorRed;
    final pixel = MemoryImage(img.encodePng(img.Image(width: 1, height: 1)));
    ImagenDeAula.proveedorRed = (_) => pixel;
    addTearDown(() => ImagenDeAula.proveedorRed = anterior);
    await tester.binding.setSurfaceSize(const Size(1400, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var elegidas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: EditorJuegoPage(
          repositorio: repo,
          elegirImagen: (r) async {
            elegidas++;
            return r.subirImagen(Uint8List(0));
          },
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('editor-plantilla-verdadero_falso')));
    await tester.pumpAndSettle();
    await tocar(tester, find.byKey(const Key('editor-subir-fondo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-fondo-subido')), findsOneWidget);
    await tocar(tester, find.byKey(const Key('editor-anadir-imagen-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-imagen-1')), findsOneWidget);
    expect(elegidas, 2);

    await escribir(tester, find.byKey(const Key('editor-titulo')), 'Con fotos');
    await tocar(tester, find.byKey(const Key('editor-curso-2')));
    await escribir(
      tester,
      find.byKey(const Key('editor-enunciado-1')),
      'Es un árbol.',
    );
    await tocar(tester, find.text('Verdadera'));
    await tester.pumpAndSettle();
    await tocar(tester, find.byKey(const Key('editor-publicar')));
    await tester.pumpAndSettle();
    final juego = repo.juegos.values.single.juego;
    expect(juego.fondo, isA<ImagenSubida>());
    expect(juego.preguntas.single.imagen, isA<ImagenSubida>());
    expect(tester.takeException(), isNull);
  });
}
