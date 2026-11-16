import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/progreso.dart';

import '../soporte/preferencias_controladas.dart';

void main() {
  test(
    'reintentar una escritura de precisión no entrega otra recompensa',
    () async {
      final prefs = PreferenciasControladas()..fallar = true;
      final progreso = Progreso(prefs, {});
      expect(progreso.aplicarAciertoPrecision(aLaPrimera: true), 1);
      expect(await progreso.guardarPrecision(), isFalse);
      expect(progreso.semillas, 1);
      prefs.fallar = false;
      expect(await progreso.guardarPrecision(), isTrue);
      expect(await progreso.guardarPrecision(), isTrue);
      expect(Progreso(prefs, {}).semillas, 1);
      expect(progreso.comboActual, 1);
    },
  );

  test('escrituras solapadas conservan todos los aciertos aceptados', () async {
    final bloqueo = Completer<void>();
    final prefs = PreferenciasControladas()..bloqueo = bloqueo;
    final progreso = Progreso(prefs, {});
    progreso.aplicarAciertoPrecision(aLaPrimera: true);
    final primero = progreso.guardarPrecision();
    progreso.aplicarAciertoPrecision(aLaPrimera: true);
    final segundo = progreso.guardarPrecision();
    expect(progreso.semillas, 3);
    bloqueo.complete();
    expect(await primero, isTrue);
    expect(await segundo, isTrue);
    expect(Progreso(prefs, {}).semillas, 3);
    expect(Progreso(prefs, {}).comboActual, 2);
  });

  test(
    'el bono diario se prepara una vez y un fallo parcial no lo duplica',
    () async {
      final prefs = PreferenciasControladas()..falloEnClave = 'hechos';
      final progreso = Progreso(prefs, {});
      final fecha = DateTime(2026, 11, 16);
      progreso.aplicarAciertoPrecision(aLaPrimera: true);
      final cierre = progreso.prepararExpedicionDiaria(
        fecha: fecha,
        semillasRecompensa: 8,
        dificultad: 'facil',
        semillasTotalesSesion: 1,
      );
      expect(progreso.semillas, 9);
      expect(await progreso.guardarExpedicionDiaria(cierre), isFalse);
      expect(progreso.expedicionHoyHecha(fecha), isFalse);
      expect(progreso.cierreExpedicionPendiente(fecha), same(cierre));
      expect(
        progreso.prepararExpedicionDiaria(
          fecha: fecha,
          semillasRecompensa: 100,
        ),
        same(cierre),
      );
      prefs.falloEnClave = null;
      expect(await progreso.guardarExpedicionDiaria(cierre), isTrue);
      expect(await progreso.guardarExpedicionDiaria(cierre), isTrue);
      final reabierto = Progreso(prefs, prefs.getStringList('hechos')!.toSet());
      expect(reabierto.semillas, 9);
      expect(reabierto.expedicionHoyHecha(fecha), isTrue);
      expect(reabierto.rachaActiva(fecha), 1);
      expect(progreso.cierreExpedicionPendiente(fecha), isNull);
    },
  );

  test('un reinicio después de un fallo parcial recupera el cierre y no vuelve a conceder el bono', () async {
    final prefs = PreferenciasControladas()
      ..falloEnClave = 'racha/ultima-fecha';
    final fecha = DateTime(2026, 11, 16);
    final primero = Progreso(prefs, {});
    primero.aplicarAciertoPrecision(aLaPrimera: true);
    final cierre = primero.prepararExpedicionDiaria(
      fecha: fecha,
      semillasRecompensa: 8,
      dificultad: 'facil',
      semillasTotalesSesion: 1,
    );
    // Una escritura de precisión anterior al guardado final también conserva
    // el cierre antes de escribir un saldo que ya contiene el bono.
    expect(await primero.guardarPrecision(), isTrue);
    expect(await primero.guardarExpedicionDiaria(cierre), isFalse);
    final reabierto = Progreso(prefs, {});
    final pendiente = reabierto.cierreExpedicionPendiente(fecha)!;
    expect(reabierto.semillas, 9);
    expect(reabierto.expedicionHoyHecha(fecha), isFalse);
    prefs.falloEnClave = null;
    expect(await reabierto.guardarExpedicionDiaria(pendiente), isTrue);
    expect(reabierto.semillas, 9);
    expect(reabierto.expedicionHoyHecha(fecha), isTrue);
  });
}
