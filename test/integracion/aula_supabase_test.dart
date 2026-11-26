// Prueba la app contra un Supabase de verdad (el local de `supabase start`).
// No se ejecuta por defecto. Para lanzarla:
//
//   SUPABASE_PRUEBAS_URL=http://127.0.0.1:54321 \
//   SUPABASE_PRUEBAS_ANON=<ANON_KEY> SUPABASE_PRUEBAS_SERVICE=<SERVICE_ROLE_KEY> \
//   flutter test test/integracion
//
// Las claves salen de `npx supabase status`. Nunca uses las de producción.
@Tags(['integracion'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final url = Platform.environment['SUPABASE_PRUEBAS_URL'];
  final anon = Platform.environment['SUPABASE_PRUEBAS_ANON'];
  final servicio = Platform.environment['SUPABASE_PRUEBAS_SERVICE'];
  final configurado = url != null && anon != null && servicio != null;

  test(
    'la app ve los juegos de su curso, envía resultados una vez y sale en el ranking',
    () async {
      final admin = SupabaseClient(url!, servicio!);
      final sufijo = DateTime.now().microsecondsSinceEpoch.toString();
      final profe = await admin.auth.admin.createUser(
        AdminUserAttributes(
          email: 'prueba$sufijo@profes.naturalmente.app',
          password: 'pino-nube-zorro-rio-27',
          emailConfirm: true,
        ),
      );
      final profeId = profe.user!.id;
      addTearDown(() => admin.auth.admin.deleteUser(profeId));
      await admin.from('profesores').insert({
        'id': profeId,
        'usuario': 'prueba$sufijo',
        'nombre': 'Prueba',
      });
      final juego = await admin
          .from('juegos')
          .insert({
            'profesor_id': profeId,
            'titulo': 'Integración $sufijo',
            'plantilla': 'verdadero_falso',
            'cursos': [5],
            'estado': 'publicado',
            'contenido': {
              'preguntas': [
                {'enunciado': 'El Sol es una estrella.', 'correcta': true},
                {'enunciado': 'Las ranas son mamíferos.', 'correcta': false},
              ],
            },
          })
          .select('id')
          .single();
      await admin.from('juegos').insert({
        'profesor_id': profeId,
        'titulo': 'Borrador $sufijo',
        'plantilla': 'verdadero_falso',
        'cursos': [5],
        'contenido': {'preguntas': []},
      });

      final repo = RepositorioAulaSupabase(SupabaseClient(url, anon!));
      final juegos = await repo.juegosDeCurso(5);
      final mio = juegos.where((j) => j.titulo.endsWith(sufijo)).toList();
      expect(mio.map((j) => j.titulo), ['Integración $sufijo']);
      expect((mio.single.preguntas.first as PreguntaAula).correcta, 0);

      const perfil = Perfil(
        id: 'local',
        animal: 'nutria',
        adjetivo: 'tenaz',
        color: 'turquesa',
      );
      final nube = await repo.crearPerfil(perfil, curso: 5);
      expect(nube.llave, matches(RegExp(r'^[a-z]+-[a-z]+-[a-z]+-\d\d$')));
      await repo.actualizarPerfil(
        nube.id,
        perfil,
        curso: 5,
        traje: 'explorador',
        pose: 'feliz',
      );

      final resultado = ResultadoAula(
        idLocal: 'partida-$sufijo',
        juegoId: juego['id'] as String,
        version: 1,
        aciertos: 1,
        total: 2,
        jugado: DateTime.now(),
        respuestas: const [true, false],
      );
      await repo.enviarResultado(nube.id, resultado);
      await repo.enviarResultado(nube.id, resultado);
      final guardados = await admin
          .from('resultados')
          .select('id')
          .eq('perfil_id', nube.id);
      expect(guardados, hasLength(1));

      expect(await repo.rankingActivo(), isTrue);
      final ranking = await repo.ranking(5, semana: true);
      final fila = ranking.singleWhere((f) => f.esMio);
      expect(fila.perfil.mote('es'), 'Nutria Tenaz');
      expect((fila.traje, fila.pose, fila.puntos), ('explorador', 'feliz', 60));

      // Otra tablet canjea la llave y las dos sincronizan su progreso.
      final otra = RepositorioAulaSupabase(SupabaseClient(url, anon));
      expect(
        await otra.canjearLlave('nutria', 'tenaz', 'sol-sol-sol-00'),
        isNull,
      );
      final canjeado = await otra.canjearLlave('nutria', 'tenaz', nube.llave);
      expect(canjeado?.id, nube.id);
      expect(canjeado?.perfil.color, 'turquesa');
      await repo.sincronizar(nube.id, {
        'hechos': ['hogar/facil/completo'],
        'ganadas': 30,
        'gastadas': 0,
      });
      final juntos = await otra.sincronizar(nube.id, {
        'hechos': ['ficha/camello'],
        'ganadas': 5,
        'gastadas': 12,
      });
      expect(juntos['semillas'], 23);
      expect((juntos['hechos'] as List).toSet(), {
        'hogar/facil/completo',
        'ficha/camello',
      });

      // Cambiar la llave deja fuera a la otra tablet.
      final nueva = await repo.cambiarLlave(nube.id);
      expect(nueva, isNot(nube.llave));
      await expectLater(
        otra.sincronizar(nube.id, const {}),
        throwsA(isA<PostgrestException>()),
      );
      await admin.from('perfiles').delete().eq('id', nube.id);
    },
    skip: configurado ? false : 'Define SUPABASE_PRUEBAS_URL, _ANON y _SERVICE para probar contra Supabase.',
  );
}
