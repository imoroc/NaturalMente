import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

/// Error que se enseña tal cual al profesor.
class ErrorPanel implements Exception {
  const ErrorPanel(this.mensaje);
  final String mensaje;
  @override
  String toString() => mensaje;
}

enum EstadoJuego { borrador, publicado }

/// Un juego del profesor con su estado de publicación.
class FichaJuego {
  const FichaJuego({
    required this.juego,
    required this.estado,
    required this.actualizado,
  });

  final JuegoAula juego;
  final EstadoJuego estado;
  final DateTime actualizado;
}

/// Una partida de un niño a un juego, vista desde el panel.
class PartidaPanel {
  const PartidaPanel({
    required this.perfilId,
    required this.perfil,
    required this.version,
    required this.aciertos,
    required this.total,
    required this.respuestas,
    required this.jugado,
  });

  final String perfilId;
  final Perfil perfil;
  final int version;
  final int aciertos;
  final int total;
  final List<bool> respuestas;
  final DateTime jugado;
}

abstract class RepositorioPanel {
  /// Nombre del profesor con sesión abierta, o `null` si no hay sesión.
  Future<String?> profesorActual();

  /// [identificador] puede ser el nombre de usuario o el correo.
  Future<String> entrar(String identificador, String contrasena);

  Future<void> entrarConProveedor(OAuthProvider proveedor);

  Future<void> salir();

  Future<List<FichaJuego>> misJuegos();

  /// Crea el juego si su id está vacío. Devuelve la ficha guardada.
  Future<FichaJuego> guardar(JuegoAula juego, EstadoJuego estado);

  /// Borra el juego y las fotos suyas que no use ningún otro juego.
  Future<void> borrar(String juegoId);

  /// Sube una foto ya comprimida (JPEG) y devuelve su dirección pública.
  Future<ImagenSubida> subirImagen(Uint8List jpg);

  Future<bool> rankingActivo();

  Future<void> cambiarRanking(bool activo);

  Future<List<PartidaPanel>> partidas(String juegoId);
}

class RepositorioPanelSupabase implements RepositorioPanel {
  RepositorioPanelSupabase(this._cliente);

  final SupabaseClient _cliente;

  static const _columnas =
      'id, titulo, plantilla, version, cursos, contenido, tema, estado, actualizado';

  @override
  Future<String?> profesorActual() async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null || usuario.isAnonymous) return null;
    final fila = await _cliente
        .from('profesores')
        .select('nombre')
        .eq('id', usuario.id)
        .maybeSingle();
    return fila?['nombre'] as String?;
  }

  Future<String> _exigirProfesor() async {
    final nombre = await profesorActual();
    if (nombre == null) {
      await _cliente.auth.signOut();
      throw const ErrorPanel(
        'Esta cuenta no tiene permiso para crear juegos. Pide acceso al equipo de NaturalMente.',
      );
    }
    return nombre;
  }

  @override
  Future<String> entrar(String identificador, String contrasena) async {
    final texto = identificador.trim();
    if (texto.isEmpty || contrasena.isEmpty) {
      throw const ErrorPanel('Escribe tu usuario o correo y tu contraseña.');
    }
    String? correo = texto;
    if (!texto.contains('@')) {
      correo = await _cliente.rpc<String?>(
        'correo_profesor',
        params: {'p_usuario': texto},
      );
    }
    if (correo == null) {
      throw const ErrorPanel('El usuario o la contraseña no son correctos.');
    }
    try {
      await _cliente.auth.signInWithPassword(
        email: correo,
        password: contrasena.trim(),
      );
    } on AuthException catch (e) {
      if (e.statusCode == '429') {
        throw const ErrorPanel(
          'Demasiados intentos. Espera unos minutos y vuelve a probar.',
        );
      }
      throw const ErrorPanel('El usuario o la contraseña no son correctos.');
    }
    return _exigirProfesor();
  }

  @override
  Future<void> entrarConProveedor(OAuthProvider proveedor) async {
    await _cliente.auth.signInWithOAuth(
      proveedor,
      redirectTo: Uri.base.removeFragment().toString(),
    );
  }

  @override
  Future<void> salir() => _cliente.auth.signOut();

  FichaJuego _ficha(Map<String, dynamic> fila) => FichaJuego(
    juego:
        JuegoAula.desdeFila(fila, validar: false) ??
        (throw const ErrorPanel('Hay un juego guardado que no se puede leer.')),
    estado: fila['estado'] == 'publicado'
        ? EstadoJuego.publicado
        : EstadoJuego.borrador,
    actualizado: DateTime.parse(fila['actualizado'] as String).toLocal(),
  );

  @override
  Future<List<FichaJuego>> misJuegos() async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) return const [];
    final filas = await _cliente
        .from('juegos')
        .select(_columnas)
        .eq('profesor_id', usuario.id)
        .order('actualizado', ascending: false);
    return [for (final fila in filas) _ficha(fila)];
  }

  @override
  Future<FichaJuego> guardar(JuegoAula juego, EstadoJuego estado) async {
    if (estado == EstadoJuego.publicado) {
      final errores = juego.errores();
      if (errores.isNotEmpty) throw ErrorPanel(errores.first);
    }
    final datos = {
      'titulo': juego.titulo.trim().isEmpty
          ? 'Sin título'
          : juego.titulo.trim(),
      'plantilla': juego.plantilla.id,
      'cursos': juego.cursos.isEmpty ? [1] : juego.cursos,
      'contenido': juego.contenidoJson(),
      'tema': juego.temaJson(),
      'estado': estado.name,
    };
    final fila = juego.id.isEmpty
        ? await _cliente.from('juegos').insert(datos).select(_columnas).single()
        : await _cliente
              .from('juegos')
              .update(datos)
              .eq('id', juego.id)
              .select(_columnas)
              .single();
    return _ficha(fila);
  }

  static const _bucket = 'imagenes';

  @override
  Future<ImagenSubida> subirImagen(Uint8List jpg) async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) throw const ErrorPanel('Vuelve a entrar en el panel.');
    // Cada profesor sube a su carpeta; el nombre no se repite nunca.
    final ruta =
        '${usuario.id}/${DateTime.now().toUtc().microsecondsSinceEpoch}.jpg';
    try {
      await _cliente.storage
          .from(_bucket)
          .uploadBinary(
            ruta,
            jpg,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              // Nunca cambia: la app y el navegador la guardan un año.
              cacheControl: '31536000',
            ),
          );
    } on StorageException {
      throw const ErrorPanel(
        'No se ha podido subir la imagen. Prueba otra vez.',
      );
    }
    return ImagenSubida(_cliente.storage.from(_bucket).getPublicUrl(ruta));
  }

  /// Ruta dentro del bucket de una foto subida por nosotros, o `null`.
  String? _rutaPropia(String url) {
    final marca = '/storage/v1/object/public/$_bucket/';
    final i = url.indexOf(marca);
    return i < 0 ? null : Uri.decodeComponent(url.substring(i + marca.length));
  }

  static Iterable<String> _urls(JuegoAula juego) sync* {
    if (juego.fondo case ImagenSubida(:final url)) yield url;
    for (final p in juego.preguntas) {
      if (p.imagen case ImagenSubida(:final url)) yield url;
      for (final o in p.opciones) {
        if (o.imagen case ImagenSubida(:final url)) yield url;
      }
    }
  }

  @override
  Future<void> borrar(String juegoId) async {
    final juegos = await misJuegos();
    final borrado = juegos.where((f) => f.juego.id == juegoId).firstOrNull;
    await _cliente.from('juegos').delete().eq('id', juegoId);
    if (borrado == null) return;
    final enUso = {
      for (final f in juegos)
        if (f.juego.id != juegoId) ..._urls(f.juego),
    };
    final rutas = [
      for (final url in _urls(borrado.juego).toSet())
        if (!enUso.contains(url)) ?_rutaPropia(url),
    ];
    if (rutas.isEmpty) return;
    try {
      await _cliente.storage.from(_bucket).remove(rutas);
    } catch (_) {
      // El juego ya está borrado; una foto suelta no molesta a nadie.
    }
  }

  @override
  Future<bool> rankingActivo() async {
    final fila = await _cliente
        .from('ajustes')
        .select('ranking_activo')
        .single();
    return fila['ranking_activo'] as bool;
  }

  @override
  Future<void> cambiarRanking(bool activo) => _cliente
      .from('ajustes')
      .update({
        'ranking_activo': activo,
        'actualizado': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', true);

  @override
  Future<List<PartidaPanel>> partidas(String juegoId) async {
    final filas = await _cliente
        .from('resultados')
        .select(
          'perfil_id, version, aciertos, total, respuestas, jugado, '
          'perfiles(animal, adjetivo, color)',
        )
        .eq('juego_id', juegoId)
        .order('jugado', ascending: false);
    return [
      for (final f in filas)
        PartidaPanel(
          perfilId: f['perfil_id'] as String,
          perfil: Perfil.desdeJson({
            'id': f['perfil_id'],
            ...?(f['perfiles'] as Map<String, dynamic>?),
          }),
          version: f['version'] as int,
          aciertos: f['aciertos'] as int,
          total: f['total'] as int,
          respuestas: [
            for (final r in f['respuestas'] as List<dynamic>) r == true,
          ],
          jugado: DateTime.parse(f['jugado'] as String).toLocal(),
        ),
    ];
  }
}
