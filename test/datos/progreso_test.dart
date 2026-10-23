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
    final germinacion = catalogo.actividades.firstWhere(
      (a) => a.id == 'germinacion',
    );
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

  test(
    'gestiona combos de precision, semillas, armario multi-slot de Natu y racha diaria sin farmeo',
    () async {
      SharedPreferences.setMockInitialValues({});
      final progreso = await Progreso.abrir();

      expect(progreso.semillas, 0);
      expect(progreso.mejorCombo, 0);
      expect(progreso.trajeEquipado, 'ninguno');
      expect(progreso.trajeDesbloqueado('ninguno'), isTrue);
      expect(progreso.trajeDesbloqueado('botanico'), isFalse);

      // Acierto con combo x3 da 3 semillas y registra mejorCombo = 3
      final ganadas = await progreso.registrarAciertoPrecision(
        aLaPrimera: true,
        comboActual: 3,
      );
      expect(ganadas, 3);
      expect(progreso.semillas, 3);
      expect(progreso.mejorCombo, 3);

      // Sumar semillas y desbloquear traje botánico (coste 12, slot cabeza)
      await progreso.sumarSemillas(35);
      expect(progreso.semillas, 38);

      final comprado = await progreso.desbloquearTraje('botanico', 12);
      expect(comprado, isTrue);
      expect(progreso.semillas, 26);
      expect(progreso.trajeDesbloqueado('botanico'), isTrue);
      expect(progreso.trajeEquipado, 'botanico');

      // Desbloquear gafas de doctor (coste 15, slot ojos) combina ambos accesorios
      final compradoDoctor = await progreso.desbloquearTraje('doctor', 15);
      expect(compradoDoctor, isTrue);
      expect(progreso.semillas, 11);
      expect(progreso.trajesEquipados, containsAll(<String>['botanico', 'doctor']));
      expect(progreso.trajeEquipado, 'botanico,doctor');

      // Expedición diaria consecutiva incrementa la racha
      final ayer = DateTime(2026, 10, 20);
      final hoy = DateTime(2026, 10, 21);
      final rachaDia1 = await progreso.completarExpedicionDiaria(
        fecha: ayer,
        semillasRecompensa: 8,
      );
      expect(rachaDia1, 1);
      expect(progreso.rachaActiva(hoy), 1);
      expect(progreso.expedicionHoyHecha(hoy), isFalse);
      expect(progreso.semillas, 19);

      final rachaDia2 = await progreso.completarExpedicionDiaria(
        fecha: hoy,
        semillasRecompensa: 8,
      );
      expect(rachaDia2, 2);
      expect(progreso.rachaActiva(hoy), 2);
      expect(progreso.expedicionHoyHecha(hoy), isTrue);
      expect(progreso.semillas, 27);

      // Repetir el reto diario el mismo día no da semillas extra
      final rachaRepetida = await progreso.completarExpedicionDiaria(
        fecha: hoy,
        semillasRecompensa: 8,
      );
      expect(rachaRepetida, 2);
      expect(progreso.semillas, 27);

      // Persistencia tras reabrir
      final reabierto = await Progreso.abrir();
      expect(reabierto.trajesEquipados, containsAll(<String>['botanico', 'doctor']));
      expect(reabierto.mejorCombo, 3);
      expect(reabierto.rachaActiva(hoy), 2);
    },
  );
}
