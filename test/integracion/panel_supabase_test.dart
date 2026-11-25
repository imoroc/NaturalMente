// El panel contra un Supabase de verdad: entrar con usuario, subir una foto,
// publicar y borrar limpiando la foto. Se lanza igual que aula_supabase_test.
@Tags(['integracion'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/panel/imagenes_panel.dart';
import 'package:naturalmente/panel/repositorio_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final url = Platform.environment['SUPABASE_PRUEBAS_URL'];
  final anon = Platform.environment['SUPABASE_PRUEBAS_ANON'];
  final servicio = Platform.environment['SUPABASE_PRUEBAS_SERVICE'];

  test(
    'el profe entra con su usuario, sube una foto y al borrar el juego se limpia',
    () async {
      final admin = SupabaseClient(url!, servicio!);
      final sufijo = DateTime.now().microsecondsSinceEpoch.toString();
      const clave = 'pino-nube-zorro-rio-27';
      final creado = await admin.auth.admin.createUser(
        AdminUserAttributes(
          email: 'foto$sufijo@profes.naturalmente.app',
          password: clave,
          emailConfirm: true,
        ),
      );
      final id = creado.user!.id;
      addTearDown(() => admin.auth.admin.deleteUser(id));
      await admin.from('profesores').insert({
        'id': id,
        'usuario': 'foto$sufijo',
        'nombre': 'Foto',
      });

      final repo = RepositorioPanelSupabase(SupabaseClient(url, anon!));
      expect(await repo.entrar('Foto$sufijo', clave), 'Foto');

      final foto = img.Image(width: 2400, height: 1200)
        ..clear(img.ColorRgb8(80, 160, 90));
      final subida = await repo.subirImagen(
        comprimirImagen(img.encodePng(foto)),
      );
      final cliente = HttpClient();
      Future<int> estado(String direccion) async {
        final r = await (await cliente.getUrl(Uri.parse(direccion))).close();
        await r.drain<void>();
        return r.statusCode;
      }

      expect(await estado(subida.url), 200);

      final ficha = await repo.guardar(
        JuegoAula(
          id: '',
          titulo: 'Con foto $sufijo',
          plantilla: PlantillaAula.verdaderoFalso,
          version: 1,
          cursos: const [2],
          fondo: subida,
          preguntas: const [
            PreguntaAula(
              enunciado: 'Es verde.',
              opciones: [
                OpcionAula(texto: 'Verdadero'),
                OpcionAula(texto: 'Falso'),
              ],
              correcta: 0,
            ),
          ],
        ),
        EstadoJuego.publicado,
      );
      expect(ficha.juego.fondo, subida);

      await repo.borrar(ficha.juego.id);
      expect(await repo.misJuegos(), isEmpty);
      expect(await estado(subida.url), isNot(200));
      cliente.close();
    },
    skip: url != null && anon != null && servicio != null ? false : 'Define SUPABASE_PRUEBAS_URL, _ANON y _SERVICE para probar contra Supabase.',
  );
}
