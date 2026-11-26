import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/ui/expedicion_diaria.dart';

void main() {
  const niveles = ['facil', 'medio', 'dificil'];
  final fechas = [
    for (var d = 0; d < 60; d++) DateTime(2026, 11, 1).add(Duration(days: d)),
  ];

  test('cada día hay cinco retos variados y el último es la sorpresa', () {
    for (final fecha in fechas) {
      for (final nivel in niveles) {
        final mision = ExpedicionDiariaPage.generarMisionDelDia(fecha, nivel);
        final donde = '$nivel ${fecha.toIso8601String()}';
        expect(mision, hasLength(ExpedicionDiariaPage.pasosPorDia));
        expect(mision.map((p) => p.id).toSet(), hasLength(5), reason: donde);
        expect(
          [for (final p in mision) p.sorpresa],
          [false, false, false, false, true],
          reason: donde,
        );
        expect(
          mision.map((p) => p.tipo).toSet().length,
          greaterThanOrEqualTo(3),
          reason: donde,
        );
        final tema = TemaDelDia.deFecha(fecha);
        final zonas = mision.map((p) => p.zonaNombre).toSet();
        expect(zonas, hasLength(3), reason: donde);
        if (tema.zona != null) {
          expect(
            mision.where((p) => p.zonaNombre == tema.zona),
            hasLength(3),
            reason: donde,
          );
        }
      }
    }
  });

  test('la misión es la misma al reabrir y cambia de un día a otro', () {
    final hoy = DateTime(2026, 11, 26);
    for (final nivel in niveles) {
      final a = ExpedicionDiariaPage.generarMisionDelDia(hoy, nivel);
      final b = ExpedicionDiariaPage.generarMisionDelDia(hoy, nivel);
      expect(
        [for (final p in a) '${p.id}${p.opciones}'],
        [for (final p in b) '${p.id}${p.opciones}'],
      );
      final manana = ExpedicionDiariaPage.generarMisionDelDia(
        hoy.add(const Duration(days: 1)),
        nivel,
      );
      expect(
        a
            .map((p) => p.id)
            .toSet()
            .intersection(manana.map((p) => p.id).toSet()),
        hasLength(lessThan(3)),
      );
    }
  });

  test('barajar conserva la respuesta correcta y desordena los pasos', () {
    for (final nivel in niveles) {
      final banco = {
        for (final p in ExpedicionDiariaPage.bancoDe(nivel)) p.id: p,
      };
      for (final fecha in fechas) {
        for (final p in ExpedicionDiariaPage.generarMisionDelDia(
          fecha,
          nivel,
        )) {
          final original = banco[p.id]!;
          expect(p.opciones.toSet(), original.opciones.toSet());
          if (p.tipo == FormatoRetoDiario.ordenar) {
            expect([
              for (final i in p.ordenCorrecto) p.opciones[i],
            ], original.opciones);
            expect(p.opciones, isNot(original.opciones));
          } else {
            expect(
              p.opciones[p.indiceCorrecto],
              original.opciones[original.indiceCorrecto],
            );
          }
          if (p.tipo == FormatoRetoDiario.verdaderoFalso) {
            expect(p.opciones, ['Verdadero', 'Falso']);
          }
        }
      }
    }
  });

  test('el tema rota por días y el domingo es mezcla', () {
    expect(TemaDelDia.deFecha(DateTime(2026, 11, 23)), TemaDelDia.animales);
    expect(TemaDelDia.deFecha(DateTime(2026, 11, 24)), TemaDelDia.plantas);
    expect(TemaDelDia.deFecha(DateTime(2026, 11, 25)), TemaDelDia.cuerpo);
    expect(TemaDelDia.deFecha(DateTime(2026, 11, 29)), TemaDelDia.mezcla);
  });

  test('todos los textos de los retos diarios están traducidos', () {
    final traducciones = jsonDecode(
      File('content/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    // Como en la app, vale la traducción sin distinguir mayúsculas.
    final claves = {for (final k in traducciones.keys) k.toLowerCase()};
    final faltan = <String>{};
    for (final nivel in niveles) {
      for (final p in ExpedicionDiariaPage.bancoDe(nivel)) {
        for (final texto in [p.pregunta, p.explicacion, ...p.opciones]) {
          if (!claves.contains(texto.toLowerCase())) faltan.add(texto);
        }
      }
    }
    for (final tema in [
      TemaDelDia.animales,
      TemaDelDia.plantas,
      TemaDelDia.cuerpo,
      TemaDelDia.mezcla,
    ]) {
      for (final texto in [tema.titulo, tema.descripcion]) {
        if (!claves.contains(texto.toLowerCase())) faltan.add(texto);
      }
    }
    expect(faltan, isEmpty);
  });
}
