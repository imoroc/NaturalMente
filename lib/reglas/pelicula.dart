import 'package:naturalmente/modelo/pelicula.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Qué pasó al poner una carta.
enum JugadaPelicula {
  /// La carta ya está en la tira o no se puede jugar ahora: no se evalúa.
  nada,

  /// Era la carta del fotograma que toca.
  acierto,

  /// Era otra carta: cuenta como intento.
  fallo,
}

/// Estado de una partida de «La película de la planta», sin widgets.
///
/// Los fotogramas se llenan de uno en uno y en orden. Poner la carta que toca
/// la deja en la tira. Poner otra explica cuándo pasa lo de esa carta y, a la
/// segunda, da la pista del fotograma. Al llenar la tira se proyecta la
/// película y se espera a pasar al rollo siguiente.
class PartidaPelicula {
  PartidaPelicula({required this.nivel});

  final NivelPelicula nivel;

  var _rollo = 0;
  bool _proyectando = false;
  final List<String> _puestas = [];
  final Map<String, int> _intentos = {};
  int _hechos = 0;

  Resultado? resultado;

  /// La última carta que se puso donde no tocaba.
  String? fallada;

  RolloPelicula? get rolloActual =>
      _rollo < nivel.rollos.length ? nivel.rollos[_rollo] : null;

  int get rollosHechos => _rollo + (_proyectando ? 1 : 0);

  int get totalFotogramas =>
      nivel.rollos.fold(0, (total, r) => total + r.fotogramas.length);

  double get progreso => _hechos / totalFotogramas;

  /// La tira está llena y se proyecta la película.
  bool get proyectando => _proyectando;

  bool get completa => rollosHechos == nivel.rollos.length;

  List<String> get puestas => List.unmodifiable(_puestas);

  bool puesta(String cartaId) => _puestas.contains(cartaId);

  /// Índice del fotograma que hay que llenar, o `null` si la tira está llena.
  int? get hueco {
    final rollo = rolloActual;
    if (rollo == null || _proyectando) return null;
    return _puestas.length < rollo.fotogramas.length ? _puestas.length : null;
  }

  FotogramaPelicula? get fotogramaActual {
    final indice = hueco;
    return indice == null ? null : rolloActual!.fotogramas[indice];
  }

  /// Pone la carta en el fotograma que toca.
  JugadaPelicula poner(String cartaId) {
    final rollo = rolloActual;
    final fotograma = fotogramaActual;
    if (rollo == null || fotograma == null) return JugadaPelicula.nada;
    final carta = rollo.carta(cartaId);
    if (carta == null || _puestas.contains(cartaId)) {
      return JugadaPelicula.nada;
    }
    if (cartaId != fotograma.id) {
      final intento = (_intentos[fotograma.id] ?? 0) + 1;
      _intentos[fotograma.id] = intento;
      fallada = cartaId;
      resultado = Resultado(
        acierto: false,
        frase: intento >= 2 ? '${carta.aviso} ${fotograma.pista}' : carta.aviso,
        estado: 'fallo',
        gesto: intento >= 2 ? 'pista' : 'pensando',
      );
      return JugadaPelicula.fallo;
    }
    fallada = null;
    _puestas.add(cartaId);
    _hechos++;
    final fin = _puestas.length == rollo.fotogramas.length;
    if (fin) _proyectando = true;
    resultado = Resultado(
      acierto: true,
      frase: !fin
          ? fotograma.como
          : completa
          ? '${fotograma.como} ${rollo.bien} ${nivel.despedida}'
          : '${fotograma.como} ${rollo.bien}',
      estado: fin ? 'proyectar' : 'puesta',
      gesto: 'feliz',
    );
    return JugadaPelicula.acierto;
  }

  /// Pasa al rollo siguiente después de ver la película.
  void siguiente() {
    if (!_proyectando || completa) return;
    _rollo++;
    _proyectando = false;
    _puestas.clear();
    fallada = null;
    resultado = null;
  }
}
