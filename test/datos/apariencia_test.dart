import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/apariencia.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Preferencias extends Fake implements SharedPreferences {
  _Preferencias(this.guardar);
  final Future<bool> Function(String) guardar;
  @override
  String? getString(String key) => null;
  @override
  Future<bool> setString(String key, String value) => guardar(value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'idioma': 'en',
      'sonido': false,
      'vibracion': true,
      'estrellas': 7,
    }),
  );

  test(
    'inicial automático, tres elecciones persistentes y claves intactas',
    () async {
      final apariencia = await Apariencia.abrir();
      addTearDown(apariencia.dispose);
      expect(apariencia.tema, ThemeMode.system);
      for (final modo in [
        ModoApariencia.oscuro,
        ModoApariencia.claro,
        ModoApariencia.sistema,
      ]) {
        expect(await apariencia.elegir(modo), isTrue);
        final restaurada = await Apariencia.abrir();
        expect(restaurada.modo, modo);
        restaurada.dispose();
      }
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('idioma'), 'en');
      expect(prefs.getBool('sonido'), false);
      expect(prefs.getBool('vibracion'), true);
      expect(prefs.getInt('estrellas'), 7);
    },
  );

  test('valor desconocido sigue al sistema', () async {
    SharedPreferences.setMockInitialValues({'apariencia': 'desconocida'});
    final apariencia = await Apariencia.abrir();
    addTearDown(apariencia.dispose);
    expect(apariencia.modo, ModoApariencia.sistema);
  });

  test(
    'fallo o excepción no cambia la elección y se puede reintentar',
    () async {
      var llamadas = 0;
      final apariencia = Apariencia(
        _Preferencias((_) async {
          llamadas++;
          if (llamadas == 1) return false;
          if (llamadas == 2) throw StateError('disco');
          return true;
        }),
      );
      addTearDown(apariencia.dispose);
      var avisos = 0;
      apariencia.addListener(() => avisos++);
      expect(await apariencia.elegir(ModoApariencia.oscuro), isFalse);
      expect(await apariencia.elegir(ModoApariencia.oscuro), isFalse);
      expect(apariencia.modo, ModoApariencia.sistema);
      expect(avisos, 0);
      expect(await apariencia.elegir(ModoApariencia.oscuro), isTrue);
      expect(avisos, 1);
    },
  );

  test('escrituras rápidas se serializan y gana la última elección', () async {
    final primera = Completer<bool>();
    final escritas = <String>[];
    final apariencia = Apariencia(
      _Preferencias((valor) async {
        escritas.add(valor);
        return escritas.length == 1 ? primera.future : true;
      }),
    );
    addTearDown(apariencia.dispose);
    final oscuro = apariencia.elegir(ModoApariencia.oscuro);
    final claro = apariencia.elegir(ModoApariencia.claro);
    await Future<void>.delayed(Duration.zero);
    expect(escritas, ['oscuro']);
    primera.complete(true);
    expect(await oscuro, true);
    expect(await claro, true);
    expect(escritas, ['oscuro', 'claro']);
    expect(apariencia.modo, ModoApariencia.claro);
  });

  test(
    'desmontar durante el guardado no notifica un controlador cerrado',
    () async {
      final guardado = Completer<bool>();
      final apariencia = Apariencia(_Preferencias((_) => guardado.future));
      final pendiente = apariencia.elegir(ModoApariencia.oscuro);
      await Future<void>.delayed(Duration.zero);
      apariencia.dispose();
      guardado.complete(true);
      expect(await pendiente, false);
    },
  );
}
