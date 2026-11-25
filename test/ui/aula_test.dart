import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/main.dart';
import 'package:naturalmente/ui/aula/juego_aula_page.dart';
import 'package:naturalmente/ui/perfiles/quien_juega.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../soporte/repositorio_aula_falso.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> abrirAula(
    WidgetTester tester, {
    RepositorioAula? repositorio,
    Map<String, Object> valores = const {},
    String idioma = 'es',
  }) async {
    SharedPreferences.setMockInitialValues({
      'idioma': idioma,
      'sonido': false,
      'vibracion': false,
      ...valores,
    });
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      NaturalmenteApp(
        conBienvenida: false,
        usarNube: false,
        repositorioAula: repositorio,
      ),
    );
    final acceso = find.byKey(const Key('abrir-aula'));
    for (var i = 0; i < 30 && acceso.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.ensureVisible(acceso);
    await tester.pumpAndSettle();
    await tester.tap(acceso);
    await tester.pumpAndSettle();
  }

  testWidgets('sin conexión configurada, Aula lo explica', (tester) async {
    await abrirAula(tester);
    expect(find.byKey(const Key('aula-no-disponible')), findsOneWidget);
  });

  for (final idioma in ['es', 'en']) {
    testWidgets('sin curso pide elegirlo y luego muestra solo los de ese curso ($idioma)', (
      tester,
    ) async {
      final repositorio = RepositorioAulaFalso(
        juegos: [
          juegoDePrueba(),
          juegoDePrueba(id: 'juego-4', titulo: 'Plantas de 4º', cursos: [4]),
        ],
      );
      await abrirAula(tester, repositorio: repositorio, idioma: idioma);
      expect(find.byKey(const Key('aula-sin-curso')), findsOneWidget);

      await tester.tap(find.byKey(const Key('aula-elegir-curso')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('curso-3')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('juego-aula-juego-1')), findsOneWidget);
      expect(find.byKey(const Key('juego-aula-juego-4')), findsNothing);
      // El título lo escribe el profe y se enseña tal cual en los dos idiomas.
      expect(find.text('Animales vertebrados'), findsOneWidget);

      await tester.tap(find.byKey(const Key('juego-aula-juego-1')));
      await tester.pumpAndSettle();
      expect(find.byType(JuegoAulaPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sin conexión se puede jugar a lo guardado', (tester) async {
    final repositorio = RepositorioAulaFalso();
    await abrirAula(
      tester,
      repositorio: repositorio,
      valores: {'perfil/curso': 3},
    );
    expect(find.byKey(const Key('juego-aula-juego-1')), findsOneWidget);
    expect(find.byKey(const Key('aula-sin-conexion')), findsNothing);

    // Se cierra Aula, se va la conexión y se vuelve a entrar.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    repositorio.sinConexion = true;
    // Al entrar, Aula intenta refrescar y se queda con lo guardado.
    await tester.tap(find.byKey(const Key('abrir-aula')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('aula-sin-conexion')), findsOneWidget);
    expect(find.byKey(const Key('juego-aula-juego-1')), findsOneWidget);
  });

  testWidgets('sin conexión y sin nada guardado ofrece reintentar', (tester) async {
    final repositorio = RepositorioAulaFalso()..sinConexion = true;
    await abrirAula(
      tester,
      repositorio: repositorio,
      valores: {'perfil/curso': 3},
    );
    expect(find.byKey(const Key('aula-sin-conexion')), findsOneWidget);
    repositorio.sinConexion = false;
    await tester.tap(find.byKey(const Key('aula-reintentar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('juego-aula-juego-1')), findsOneWidget);
  });

  testWidgets('un curso sin juegos lo dice', (tester) async {
    await abrirAula(
      tester,
      repositorio: RepositorioAulaFalso(),
      valores: {'perfil/curso': 6},
    );
    expect(find.byKey(const Key('aula-vacia')), findsOneWidget);
  });

  testWidgets('el ranking marca tu fila y respeta si el profe lo apaga', (
    tester,
  ) async {
    final repositorio = RepositorioAulaFalso()
      ..filasRanking = [
        for (final (posicion, animal, mio) in [
          (1, 'lince', false),
          (2, 'zorro', true),
          (14, 'oso', false),
        ])
          FilaRanking(
            posicion: posicion,
            perfil: Perfil(
              id: '',
              animal: animal,
              adjetivo: 'veloz',
              color: 'azul',
            ),
            traje: 'ninguno',
            pose: 'hola',
            puntos: 200 - posicion,
            juegos: 2,
            esMio: mio,
          ),
      ];
    await abrirAula(
      tester,
      repositorio: repositorio,
      valores: {'perfil/curso': 3},
    );
    await tester.tap(find.byKey(const Key('aula-pestana-ranking')));
    await tester.pumpAndSettle();
    expect(find.text('🥇'), findsOneWidget);
    expect(find.text('Zorro Veloz (tú)'), findsOneWidget);
    expect(find.byKey(const Key('ranking-fila-14')), findsOneWidget);

    repositorio.rankingEncendido = false;
    await tester.tap(find.byKey(const Key('ranking-siempre')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ranking-apagado')), findsOneWidget);
  });

  testWidgets('borrar un jugador borra antes sus datos de la nube', (tester) async {
    final repositorio = RepositorioAulaFalso()..sinConexion = true;
    SharedPreferences.setMockInitialValues({
      'sonido': false,
      'vibracion': false,
      'perfiles/lista':
          '[{"id":"principal","animal":"oso","adjetivo":"libre","color":"naranja"},'
          '{"id":"p2","animal":"rana","adjetivo":"feliz","color":"rosa"}]',
      'perfiles/activo': 'p2',
      'perfiles/p2/aula/nube': '{"id":"nube-9","llave":"sol-sol-sol-01"}',
      'perfiles/p2/economia/semillas': 12,
    });
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      NaturalmenteApp(conBienvenida: false, usarNube: false, repositorioAula: repositorio),
    );
    final cabecera = find.byKey(const Key('abrir-quien-juega'));
    for (var i = 0; i < 30 && cabecera.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.tap(cabecera);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('editar-perfil')));
    await tester.pumpAndSettle();

    Future<void> borrar() async {
      await tester.ensureVisible(find.byKey(const Key('borrar-perfil')));
      await tester.tap(find.byKey(const Key('borrar-perfil')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmar-borrar-perfil')));
      await tester.pumpAndSettle();
    }

    // Sin conexión no se borra nada: sus datos no se quedan huérfanos.
    await borrar();
    expect(find.byType(EditorPerfilPage), findsOneWidget);
    expect(
      find.text('Para borrar a este jugador hace falta conexión, porque también se borran sus resultados de Aula.'),
      findsOneWidget,
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('perfiles/p2/economia/semillas'), 12);
    expect(repositorio.perfilesBorrados, isEmpty);

    repositorio.sinConexion = false;
    await borrar();
    expect(find.byType(EditorPerfilPage), findsNothing);
    expect(repositorio.perfilesBorrados, ['nube-9']);
    expect(prefs.getKeys().where((k) => k.startsWith('perfiles/p2/')), isEmpty);
  });
}
