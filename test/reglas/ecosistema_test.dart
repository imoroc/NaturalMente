import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/modelo/ecosistema.dart';
import 'package:naturalmente/reglas/ecosistema.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final catalogo = Catalogo.desdeTexto(
    File('content/catalog.json').readAsStringSync(),
  );
  final actividad = catalogo.actividades.firstWhere(
    (a) => a.id == 'ecosistemas',
  );
  final eco = actividad.ecosistema!;
  for (final nivel in eco.niveles) {
    test('${nivel.id}: todas las fases cuentan, doble respuesta no avanza', () {
      final p = PartidaEcosistema(eco, nivel);
      p.seguir();
      expect(p.pasos, 0);
      for (final e in eco.elementos) {
        p.colocar(e.id, e.id);
        final pasos = p.pasos;
        p.colocar(e.id, e.id);
        p.responder('hierba');
        expect(p.pasos, pasos);
        p.seguir();
      }
      expect(p.pasos, 3);
      expect(p.completa, nivel.id == 'facil');
      for (final r in nivel.retos) {
        expect(p.retoActual, r);
        final mal = r.opciones.firstWhere((o) => o.id != r.respuesta);
        p.responder(mal.id);
        expect(p.confirmado, isFalse);
        p.responder(mal.id);
        expect(p.frase, contains(r.pista));
        p.responder(r.respuesta);
        final pasos = p.pasos;
        p.responder(r.respuesta);
        expect(p.pasos, pasos);
        expect(p.relaciones, inInclusiveRange(1, 2));
        if (r.id.startsWith('menos-')) expect(p.cambio, r.id);
        p.seguir();
        expect(p.cambio, isNull);
      }
      expect(p.completa, isTrue);
      expect(p.pasos, p.total);
      p.seguir();
      expect(p.pasos, p.total);
    });
  }
  test('pistas de colocación, referencias inválidas y selección no pierden avances', () {
    final p = PartidaEcosistema(eco, eco.niveles.first);
    p.colocar('hierba', 'fuera');
    expect(p.intentos, 0);
    p.colocar('hierba', 'zorro');
    expect(p.acierto, isFalse);
    p.seleccionar('hierba');
    expect(p.ultimoDestino, isNull);
    p.colocar('hierba', 'conejo');
    expect(p.frase, eco.elementos.first.pista);
    p.colocar('hierba', 'hierba');
    expect(p.colocados, {'hierba'});
    p.seguir();
    expect(p.elementoActual!.id, 'conejo');
    expect(p.colocados, {'hierba'});
  });
  test('rechaza niveles duplicados y respuestas que no existen', () {
    final m =
        jsonDecode(File('content/catalog.json').readAsStringSync()) as Map;
    final data =
        (m['actividades'] as List).firstWhere(
              (a) => a['id'] == 'ecosistemas',
            )['ecosistema']
            as Map<String, dynamic>;
    data['niveles'][1]['retos'][0]['respuesta'] = 'ausente';
    expect(() => Ecosistema.desdeMapa(data), throwsArgumentError);
    data['niveles'][1]['retos'][0]['respuesta'] = 'hierba';
    data['niveles'][1]['id'] = 'facil';
    expect(() => Ecosistema.desdeMapa(data), throwsArgumentError);
  });
  test(
    'guarda niveles y cromo sin modificar la medalla ni progreso anterior',
    () async {
      SharedPreferences.setMockInitialValues({
        'hechos': ['hogar/camello', 'ficha/camello'],
      });
      final p = await Progreso.abrir();
      await p.recordarNivelEcosistema('medio');
      for (final n in eco.niveles) {
        await p.marcarNivelEcosistema(actividad, n.id);
      }
      await p.marcarNivelEcosistema(actividad, 'facil');
      final reabierto = await Progreso.abrir();
      expect(reabierto.ultimoNivelEcosistema, 'medio');
      expect(reabierto.nivelesSuperadosDe(actividad), 3);
      expect(reabierto.maxNivelesDe(actividad), 3);
      expect(reabierto.fichaDesbloqueada('claro-bosque'), isTrue);
      expect(reabierto.hecho('hogar/camello'), isTrue);
      expect(reabierto.medallaConseguida(catalogo.actividades), isFalse);
      expect(reabierto.totalMaxNiveles(catalogo.actividades), 21);
      expect(
        () => p.marcarNivelEcosistema(actividad, 'ausente'),
        throwsArgumentError,
      );
    },
  );
}
