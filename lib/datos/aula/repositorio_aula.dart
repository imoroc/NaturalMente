import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

/// Perfil de un niño en la nube: su id y la llave mágica para recuperarlo.
class PerfilNube {
  const PerfilNube({required this.id, required this.llave});
  final String id;
  final String llave;

  Map<String, dynamic> toJson() => {'id': id, 'llave': llave};
  static PerfilNube? desdeJson(Object? json) =>
      json is Map && json['id'] is String && json['llave'] is String
      ? PerfilNube(id: json['id'] as String, llave: json['llave'] as String)
      : null;
}

/// Perfil encontrado al canjear una llave mágica.
class PerfilCanjeado {
  const PerfilCanjeado({required this.id, required this.perfil, this.curso});
  final String id;

  /// Mote y color de su Natu (el id es el de la nube).
  final Perfil perfil;
  final int? curso;
}

/// Se han hecho demasiados intentos con llaves equivocadas en poco tiempo.
class LlaveBloqueada implements Exception {
  const LlaveBloqueada();
}

/// Resultado de una partida de Aula pendiente de enviar.
class ResultadoAula {
  const ResultadoAula({
    required this.idLocal,
    required this.juegoId,
    required this.version,
    required this.aciertos,
    required this.total,
    required this.jugado,
    this.respuestas = const [],
  });

  final String idLocal;
  final String juegoId;
  final int version;
  final int aciertos;
  final int total;
  final DateTime jugado;

  /// Por pregunta: si se acertó a la primera. Sirve al profesor para ver qué
  /// preguntas cuestan más.
  final List<bool> respuestas;

  Map<String, dynamic> toJson() => {
    'id_local': idLocal,
    'juego_id': juegoId,
    'version': version,
    'aciertos': aciertos,
    'total': total,
    'jugado': jugado.toUtc().toIso8601String(),
    'respuestas': respuestas,
  };

  static ResultadoAula desdeJson(Map<String, dynamic> json) => ResultadoAula(
    idLocal: json['id_local'] as String,
    juegoId: json['juego_id'] as String,
    version: json['version'] as int,
    aciertos: json['aciertos'] as int,
    total: json['total'] as int,
    jugado: DateTime.parse(json['jugado'] as String),
    respuestas: [
      for (final r in json['respuestas'] as List<dynamic>) r as bool,
    ],
  );
}

class FilaRanking {
  const FilaRanking({
    required this.posicion,
    required this.perfil,
    required this.traje,
    required this.pose,
    required this.puntos,
    required this.juegos,
    required this.esMio,
  });

  final int posicion;

  /// Solo mote y color: la fila no sirve para identificar a nadie.
  final Perfil perfil;
  final String traje;
  final String pose;
  final int puntos;
  final int juegos;
  final bool esMio;
}

/// Lo que Aula necesita de la nube. Las pruebas usan una versión en memoria.
abstract class RepositorioAula {
  Future<List<JuegoAula>> juegosDeCurso(int curso);

  Future<PerfilNube> crearPerfil(Perfil perfil, {int? curso});

  Future<void> actualizarPerfil(
    String perfilNube,
    Perfil perfil, {
    int? curso,
    required String traje,
    required String pose,
  });

  /// `null` si el mote y la llave no coinciden con ningún perfil.
  /// Lanza [LlaveBloqueada] tras muchos intentos fallidos.
  Future<PerfilCanjeado?> canjearLlave(
    String animal,
    String adjetivo,
    String llave,
  );

  /// Llave nueva. Los demás dispositivos dejan de tener el perfil.
  Future<String> cambiarLlave(String perfilNube);

  /// Envía el progreso de este dispositivo y devuelve el de todos juntos.
  Future<Map<String, dynamic>> sincronizar(
    String perfilNube,
    Map<String, dynamic> local,
  );

  /// Borra el perfil y, en cascada, todos sus resultados.
  Future<void> borrarPerfil(String perfilNube);

  /// Idempotente: reenviar el mismo [ResultadoAula.idLocal] no lo duplica.
  Future<void> enviarResultado(String perfilNube, ResultadoAula resultado);

  Future<List<FilaRanking>> ranking(int curso, {required bool semana});

  /// El profesor puede apagar el ranking desde el panel.
  Future<bool> rankingActivo();
}

/// Implementación con Supabase. Cada dispositivo entra como usuario anónimo.
class RepositorioAulaSupabase implements RepositorioAula {
  RepositorioAulaSupabase(this._cliente);

  final SupabaseClient _cliente;

  Future<void> _sesion() async {
    if (_cliente.auth.currentSession == null) {
      await _cliente.auth.signInAnonymously();
    }
  }

  @override
  Future<List<JuegoAula>> juegosDeCurso(int curso) async {
    await _sesion();
    final filas = await _cliente
        .from('juegos')
        .select('id, titulo, plantilla, version, cursos, contenido, tema')
        .eq('estado', 'publicado')
        .contains('cursos', [curso])
        .order('actualizado', ascending: false);
    return [for (final fila in filas) ?JuegoAula.desdeFila(fila)];
  }

  @override
  Future<PerfilNube> crearPerfil(Perfil perfil, {int? curso}) async {
    await _sesion();
    final filas = await _cliente.rpc<List<dynamic>>(
      'crear_perfil',
      params: {
        'p_animal': perfil.animal,
        'p_adjetivo': perfil.adjetivo,
        'p_color': perfil.color,
        'p_curso': curso,
      },
    );
    final fila = filas.single as Map<String, dynamic>;
    return PerfilNube(id: fila['id'] as String, llave: fila['llave'] as String);
  }

  @override
  Future<void> actualizarPerfil(
    String perfilNube,
    Perfil perfil, {
    int? curso,
    required String traje,
    required String pose,
  }) async {
    await _sesion();
    await _cliente
        .from('perfiles')
        .update({
          'animal': perfil.animal,
          'adjetivo': perfil.adjetivo,
          'color': perfil.color,
          'curso': curso,
          'traje': traje,
          'pose': pose,
        })
        .eq('id', perfilNube);
  }

  @override
  Future<PerfilCanjeado?> canjearLlave(
    String animal,
    String adjetivo,
    String llave,
  ) async {
    await _sesion();
    final List<dynamic> filas;
    try {
      filas = await _cliente.rpc<List<dynamic>>(
        'canjear_llave',
        params: {'p_animal': animal, 'p_adjetivo': adjetivo, 'p_llave': llave},
      );
    } on PostgrestException catch (e) {
      if (e.message.contains('demasiados_intentos'))
        throw const LlaveBloqueada();
      rethrow;
    }
    if (filas.isEmpty) return null;
    final f = filas.first as Map<String, dynamic>;
    return PerfilCanjeado(
      id: f['id'] as String,
      perfil: Perfil.desdeJson({...f, 'id': f['id']}),
      curso: f['curso'] as int?,
    );
  }

  @override
  Future<String> cambiarLlave(String perfilNube) async {
    await _sesion();
    return _cliente.rpc<String>(
      'cambiar_llave',
      params: {'p_perfil': perfilNube},
    );
  }

  @override
  Future<Map<String, dynamic>> sincronizar(
    String perfilNube,
    Map<String, dynamic> local,
  ) async {
    await _sesion();
    final respuesta = await _cliente.rpc<dynamic>(
      'sincronizar_progreso',
      params: {'p_perfil': perfilNube, 'p_local': local},
    );
    return Map<String, dynamic>.from(respuesta as Map);
  }

  @override
  Future<void> borrarPerfil(String perfilNube) async {
    await _sesion();
    await _cliente.from('perfiles').delete().eq('id', perfilNube);
  }

  @override
  Future<void> enviarResultado(
    String perfilNube,
    ResultadoAula resultado,
  ) async {
    await _sesion();
    await _cliente
        .from('resultados')
        .upsert(
          {...resultado.toJson(), 'perfil_id': perfilNube},
          onConflict: 'perfil_id,id_local',
          ignoreDuplicates: true,
        );
  }

  @override
  Future<bool> rankingActivo() async {
    await _sesion();
    final fila = await _cliente
        .from('ajustes')
        .select('ranking_activo')
        .single();
    return fila['ranking_activo'] as bool;
  }

  @override
  Future<List<FilaRanking>> ranking(int curso, {required bool semana}) async {
    await _sesion();
    final filas = await _cliente.rpc<List<dynamic>>(
      'ranking',
      params: {'p_curso': curso, 'p_periodo': semana ? 'semana' : 'siempre'},
    );
    return [
      for (final f in filas.cast<Map<String, dynamic>>())
        FilaRanking(
          posicion: f['posicion'] as int,
          perfil: Perfil.desdeJson({
            'id': '',
            'animal': f['animal'],
            'adjetivo': f['adjetivo'],
            'color': f['color'],
          }),
          traje: f['traje'] as String,
          pose: f['pose'] as String,
          puntos: f['puntos'] as int,
          juegos: f['juegos'] as int,
          esMio: f['es_mio'] as bool,
        ),
    ];
  }
}

/// Conexión con Supabase, configurada al compilar:
/// `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`.
/// Sin ellas, la app funciona igual y Aula avisa de que no está disponible.
abstract final class Nube {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const claveAnonima = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get configurada => url.isNotEmpty && claveAnonima.isNotEmpty;

  static Future<RepositorioAula?> abrir() async {
    if (!configurada) return null;
    try {
      final supabase = await Supabase.initialize(
        url: url,
        publishableKey: claveAnonima,
      );
      return RepositorioAulaSupabase(supabase.client);
    } catch (_) {
      return null;
    }
  }
}
