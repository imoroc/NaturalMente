import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/aula/aula.dart';
import 'package:naturalmente/datos/aula/llave.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';

import '../soporte/preferencias_controladas.dart';
import '../soporte/repositorio_aula_falso.dart';

/// Un dispositivo con su almacenamiento, sus perfiles y su Aula.
class _Dispositivo {
  _Dispositivo(
    String nombre,
    RepositorioAulaFalso nube, {
    Map<String, Object> valores = const {},
  }) : prefs = PreferenciasControladas()..valores.addAll(valores),
       repo = RepositorioAulaFalso.otroDispositivo(nube, nombre) {
    perfiles = Perfiles.leer(prefs);
    aula = Aula(repositorio: repo, perfiles: perfiles, prefs: prefs);
  }

  final PreferenciasControladas prefs;
  final RepositorioAulaFalso repo;
  late final Perfiles perfiles;
  late final Aula aula;

  int get semillas => perfiles.progreso.semillas;
}

void main() {
  late RepositorioAulaFalso nube;
  setUp(() => nube = RepositorioAulaFalso());

  test('el mismo niño en dos dispositivos, jugando sin conexión, no pierde ni duplica nada', () async {
    final clase = _Dispositivo(
      'clase',
      nube,
      valores: {
        'hechos': <String>['hogar/facil/completo', 'ficha/camello'],
        'economia/semillas': 40,
        'perfil/curso': 3,
      },
    );
    final perfil = clase.perfiles.activo;

    // En clase crea su llave: su progreso sube a la nube.
    final nubeClase = await clase.aula.crearLlave(perfil.id);
    expect(nubeClase, isNotNull);
    final llave = Llave.leer(nubeClase!.llave)!;

    // En casa la canjea y aparece con todo lo de clase.
    final casa = _Dispositivo('casa', nube);
    expect(
      await casa.aula.canjearLlave(perfil.animal, perfil.adjetivo, llave),
      ResultadoCanje.recuperado,
    );
    expect(casa.perfiles.activo.mote('es'), perfil.mote('es'));
    expect(casa.perfiles.activo.color, perfil.color);
    expect(casa.semillas, 40);
    expect(casa.perfiles.progreso.hecho('ficha/camello'), isTrue);
    expect(casa.perfiles.progreso.curso, 3);

    // Sin conexión: en casa gana 3 semillas y en clase gasta 25 en un traje.
    casa.perfiles.progreso
      ..aplicarAciertoPrecision(aLaPrimera: true)
      ..aplicarAciertoPrecision(aLaPrimera: true);
    expect(await casa.perfiles.progreso.guardarPrecision(), isTrue);
    expect(casa.semillas, 43);
    expect(
      await clase.perfiles.progreso.desbloquearTraje('explorador', 25),
      isTrue,
    );
    expect(clase.semillas, 15);

    // Al volver la conexión, cada una sincroniza (en cualquier orden).
    expect(await casa.aula.sincronizar(casa.perfiles.activo.id), isTrue);
    expect(await clase.aula.sincronizar(perfil.id), isTrue);
    expect(await casa.aula.sincronizar(casa.perfiles.activo.id), isTrue);
    expect(clase.semillas, 18, reason: '40 + 3 - 25');
    expect(casa.semillas, 18);
    expect(casa.perfiles.progreso.hecho('traje/explorador'), isTrue);

    // Sincronizar otra vez sin cambios no mueve nada.
    expect(await clase.aula.sincronizar(perfil.id), isTrue);
    expect(await casa.aula.sincronizar(casa.perfiles.activo.id), isTrue);
    expect((clase.semillas, casa.semillas), (18, 18));
  });

  test('la ropa elegida en un dispositivo llega a la otra', () async {
    final clase = _Dispositivo(
      'clase',
      nube,
      valores: {'economia/semillas': 100},
    );
    final perfil = clase.perfiles.activo;
    final llave = Llave.leer((await clase.aula.crearLlave(perfil.id))!.llave)!;
    final casa = _Dispositivo('casa', nube);
    await casa.aula.canjearLlave(perfil.animal, perfil.adjetivo, llave);

    await clase.perfiles.progreso.desbloquearTraje('explorador', 25);
    await clase.perfiles.progreso.equiparTraje('explorador');
    await clase.aula.sincronizar(perfil.id);
    await casa.aula.sincronizar(casa.perfiles.activo.id);
    expect(casa.perfiles.progreso.trajesEquipados, {'explorador'});
  });

  test('una llave equivocada no entra y muchos intentos se bloquean', () async {
    final clase = _Dispositivo('clase', nube);
    final perfil = clase.perfiles.activo;
    await clase.aula.crearLlave(perfil.id);
    final casa = _Dispositivo('casa', nube);
    final mala = Llave.leer('sol-sol-sol-01')!;
    for (var i = 0; i < 5; i++) {
      expect(
        await casa.aula.canjearLlave(perfil.animal, perfil.adjetivo, mala),
        ResultadoCanje.noCoincide,
      );
    }
    expect(
      await casa.aula.canjearLlave(perfil.animal, perfil.adjetivo, mala),
      ResultadoCanje.bloqueado,
    );
    expect(casa.perfiles.lista, hasLength(1), reason: 'no se ha creado nada');
  });

  test(
    'canjear un perfil que ya está en el dispositivo solo cambia a él',
    () async {
      final clase = _Dispositivo('clase', nube);
      final perfil = clase.perfiles.activo;
      final llave = Llave.leer(
        (await clase.aula.crearLlave(perfil.id))!.llave,
      )!;
      expect(
        await clase.aula.canjearLlave(perfil.animal, perfil.adjetivo, llave),
        ResultadoCanje.recuperado,
      );
      expect(clase.perfiles.lista, hasLength(1));
    },
  );

  test('cambiar la llave guarda la nueva', () async {
    final clase = _Dispositivo('clase', nube);
    final perfil = clase.perfiles.activo;
    await clase.aula.crearLlave(perfil.id);
    final nueva = await clase.aula.cambiarLlave(perfil.id);
    expect(nueva?.llave, 'sol-luna-gota-42');
    expect(clase.aula.perfilNube(perfil.id)?.llave, 'sol-luna-gota-42');
  });

  test(
    'sin conexión, sincronizar no cambia nada y se puede reintentar',
    () async {
      final clase = _Dispositivo(
        'clase',
        nube,
        valores: {'economia/semillas': 10},
      );
      final perfil = clase.perfiles.activo;
      await clase.aula.crearLlave(perfil.id);
      clase.perfiles.progreso.aplicarAciertoPrecision(aLaPrimera: true);
      await clase.perfiles.progreso.guardarPrecision();
      clase.repo.sinConexion = true;
      expect(await clase.aula.sincronizar(perfil.id), isFalse);
      expect(clase.semillas, 11);
      clase.repo.sinConexion = false;
      expect(await clase.aula.sincronizar(perfil.id), isTrue);
      expect(await clase.aula.sincronizar(perfil.id), isTrue);
      expect(clase.semillas, 11, reason: 'la semilla ganada se cuenta una vez');
    },
  );

  test('la llave se lee y se escribe en el formato de la base de datos', () {
    expect(Llave.leer(' Zorro-Pino-Nube-07 ')?.texto, 'zorro-pino-nube-07');
    expect(Llave.leer('zorro-pino-07'), isNull);
    expect(Llave.leer('zorro-pino-planeta-07'), isNull);
    expect(Llave.leer('zorro-pino-nube-100'), isNull);
    expect(dibujosLlave, hasLength(16));
  });

  test('si se cambia la llave en otro dispositivo, este lo avisa y no duplica al niño', () async {
    final clase = _Dispositivo('clase', nube, valores: {'economia/semillas': 10});
    final perfil = clase.perfiles.activo;
    final llave = Llave.leer((await clase.aula.crearLlave(perfil.id))!.llave)!;
    final casa = _Dispositivo('casa', nube);
    await casa.aula.canjearLlave(perfil.animal, perfil.adjetivo, llave);
    final enCasa = casa.perfiles.activo.id;

    // En clase cambian la llave: la tablet de casa pierde el acceso.
    final nueva = await clase.aula.cambiarLlave(perfil.id);
    expect(await casa.aula.sincronizar(enCasa), isFalse);
    expect(casa.aula.desvinculado(enCasa), isTrue);

    // Lo que juegue en casa espera, sin crear otro perfil en la nube.
    await casa.aula.guardarResultado(
      enCasa,
      ResultadoAula(
        idLocal: 'partida-casa',
        juegoId: 'j',
        version: 1,
        aciertos: 1,
        total: 1,
        jugado: DateTime(2026, 11, 27),
      ),
    );
    await casa.aula.enviarPendientes();
    expect(nube.perfilesCreados, hasLength(1));
    expect(casa.aula.pendientes(enCasa), hasLength(1));

    // Con la llave nueva vuelve a su mismo Natu y se envía lo pendiente.
    expect(
      await casa.aula.canjearLlave(perfil.animal, perfil.adjetivo, Llave.leer(nueva!.llave)!),
      ResultadoCanje.recuperado,
    );
    await casa.aula.enviarPendientes();
    expect(casa.perfiles.lista, hasLength(2), reason: 'el mismo Natu, no uno nuevo');
    expect(casa.aula.desvinculado(enCasa), isFalse);
    expect(casa.aula.pendientes(enCasa), isEmpty);
    expect(nube.totalRecibidos, 1);
  });

  test('quitar un jugador de un dispositivo no borra su progreso de la nube', () async {
    final clase = _Dispositivo('clase', nube, valores: {'economia/semillas': 30});
    final perfil = clase.perfiles.activo;
    final llave = Llave.leer((await clase.aula.crearLlave(perfil.id))!.llave)!;
    final tablet = _Dispositivo('tablet-cole', nube);
    await tablet.aula.canjearLlave(perfil.animal, perfil.adjetivo, llave);
    final enTablet = tablet.perfiles.activo.id;

    expect(await tablet.aula.quitarDeEsteDispositivo(enTablet), ResultadoQuitar.quitado);
    expect(tablet.perfiles.lista, hasLength(1));
    expect(nube.perfilesBorrados, isEmpty);
    // En la otra tablet sigue igual y esta puede volver a traerlo.
    expect(await clase.aula.sincronizar(perfil.id), isTrue);
    expect(clase.semillas, 30);
    expect(
      await tablet.aula.canjearLlave(perfil.animal, perfil.adjetivo, llave),
      ResultadoCanje.recuperado,
    );
    expect(tablet.semillas, 30);
  });

  test('no se quita un jugador con partidas sin enviar', () async {
    final clase = _Dispositivo('clase', nube);
    final otro = await clase.perfiles.crear(animal: 'lobo', adjetivo: 'feliz', color: 'azul');
    await clase.aula.crearLlave(otro!.id);
    clase.repo.sinConexion = true;
    await clase.aula.guardarResultado(
      otro.id,
      ResultadoAula(idLocal: 'p1', juegoId: 'j', version: 1, aciertos: 1, total: 1, jugado: DateTime(2026)),
    );
    expect(await clase.aula.quitarDeEsteDispositivo(otro.id), ResultadoQuitar.pendientes);
    expect(clase.perfiles.lista, hasLength(2));
  });
}
