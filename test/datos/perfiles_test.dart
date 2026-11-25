import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/datos/preferencias_perfil.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // Progreso de alguien que ya jugaba antes de que existieran perfiles.
      'hechos': ['hogar/facil/completo'],
      'economia/semillas': 40,
      'perfil/curso': 3,
    });
    prefs = await SharedPreferences.getInstance();
  });

  test('el progreso que ya existía pasa a ser el del perfil principal', () {
    final perfiles = Perfiles.leer(prefs, azar: Random(1));
    expect(perfiles.lista, hasLength(1));
    expect(perfiles.activo.principal, isTrue);
    expect(perfiles.progreso.semillas, 40);
    expect(perfiles.progreso.curso, 3);
    expect(perfiles.progreso.hecho('hogar/facil/completo'), isTrue);
    // Las claves antiguas siguen donde estaban.
    expect(prefs.getInt('economia/semillas'), 40);
  });

  test('cada perfil nuevo empieza de cero y no toca el progreso de otros',
      () async {
    final perfiles = Perfiles.leer(prefs, azar: Random(2));
    final (animal, adjetivo) = perfiles.proponerMote();
    final nuevo = await perfiles.crear(
      animal: animal,
      adjetivo: adjetivo,
      color: 'azul',
      curso: 5,
    );
    expect(nuevo, isNotNull);
    expect(perfiles.activo, nuevo);
    expect(perfiles.progreso.semillas, 0);
    expect(perfiles.progreso.curso, 5);
    expect(perfiles.progreso.bienvenidaVista, isTrue);

    perfiles.progreso.aplicarAciertoPrecision(aLaPrimera: true);
    expect(await perfiles.progreso.guardarPrecision(), isTrue);
    expect(prefs.getInt('perfiles/${nuevo!.id}/economia/semillas'), 1);
    expect(prefs.getInt('economia/semillas'), 40);

    await perfiles.elegir(Perfiles.idPrincipal);
    expect(perfiles.progreso.semillas, 40);
    expect(perfiles.progreso.curso, 3);
  });

  test('los perfiles y el jugador activo se recuerdan al reabrir', () async {
    final perfiles = Perfiles.leer(prefs, azar: Random(3));
    final nuevo = await perfiles.crear(
      animal: 'zorro',
      adjetivo: 'veloz',
      color: 'rojo',
    );
    final reabiertos = Perfiles.leer(prefs);
    expect(reabiertos.lista.map((p) => p.id), [
      Perfiles.idPrincipal,
      nuevo!.id,
    ]);
    expect(reabiertos.activo.id, nuevo.id);
    expect(reabiertos.activo.mote('es'), 'Zorro Veloz');
    expect(reabiertos.activo.mote('en'), 'Swift Fox');
  });

  test('borrar un perfil elimina solo su progreso y vuelve al principal',
      () async {
    final perfiles = Perfiles.leer(prefs, azar: Random(4));
    final nuevo = await perfiles.crear(
      animal: 'rana',
      adjetivo: 'feliz',
      color: 'rosa',
      curso: 1,
    );
    expect(prefs.getKeys().any((k) => k.startsWith('perfiles/${nuevo!.id}/')),
        isTrue);
    expect(await perfiles.eliminar(nuevo!.id), isTrue);
    expect(perfiles.lista, hasLength(1));
    expect(perfiles.activo.principal, isTrue);
    expect(prefs.getKeys().any((k) => k.startsWith('perfiles/${nuevo.id}/')),
        isFalse);
    expect(prefs.getInt('economia/semillas'), 40);
    expect(await perfiles.eliminar(Perfiles.idPrincipal), isFalse);
  });

  test('no se crean más perfiles de los permitidos', () async {
    final perfiles = Perfiles.leer(prefs, azar: Random(5));
    while (!perfiles.lleno) {
      final (a, b) = perfiles.proponerMote();
      expect(await perfiles.crear(animal: a, adjetivo: b, color: 'azul'),
          isNotNull);
    }
    expect(perfiles.lista, hasLength(Perfiles.maximo));
    final motes = perfiles.lista.map((p) => (p.animal, p.adjetivo)).toSet();
    expect(motes, hasLength(Perfiles.maximo), reason: 'sin motes repetidos');
    expect(
      await perfiles.crear(animal: 'oso', adjetivo: 'libre', color: 'azul'),
      isNull,
    );
  });

  test('una lista dañada no impide abrir la app', () {
    SharedPreferences.setMockInitialValues({'perfiles/lista': '{roto'});
    return SharedPreferences.getInstance().then((p) {
      final perfiles = Perfiles.leer(p);
      expect(perfiles.activo.principal, isTrue);
    });
  });

  test('la vista con prefijo solo ve y borra sus propias claves', () async {
    final vista = PreferenciasConPrefijo(prefs, 'perfiles/x/');
    await vista.setInt('economia/semillas', 7);
    expect(vista.getInt('economia/semillas'), 7);
    expect(vista.getKeys(), {'economia/semillas'});
    expect(await vista.clear(), isTrue);
    expect(vista.getKeys(), isEmpty);
    expect(prefs.getInt('economia/semillas'), 40);
  });
}
