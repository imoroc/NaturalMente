import 'package:naturalmente/modelo/carrera.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Estado de una partida de «Carrera de relevos», sin widgets.
///
/// Colocar corredores en los tramos no se evalúa. Al pulsar «¡Ya!» el relevo
/// recorre la pista en orden: si todos están en su tramo, la ronda es un
/// acierto; si no, el primero que no encaja se atasca, explica por qué y
/// vuelve a la salida. Los demás se quedan donde estaban.
class PartidaCarrera {
  PartidaCarrera({required this.nivel});

  final NivelCarrera nivel;

  var _ronda = 0;
  bool _avancePendiente = false;
  final Map<String, String> _colocados = {};
  final Map<String, int> _intentos = {};

  Resultado? resultado;

  /// Corredor tocado para colocarlo con un segundo toque en un tramo.
  String? seleccionado;

  /// Corredor que se atascó en la última salida.
  String? atascado;

  /// Tramos que recorrió el relevo en la última salida.
  int llegada = 0;

  /// Cuántas veces se ha pulsado «¡Ya!» en esta partida, para animar.
  int salidas = 0;

  RondaCarrera? get rondaActual =>
      _ronda < nivel.rondas.length ? nivel.rondas[_ronda] : null;

  int get rondasHechas => _ronda + (_avancePendiente ? 1 : 0);

  /// En Difícil, los nombres se descubren cuando el relevo llega a la meta.
  bool get descubierto => _avancePendiente;

  bool get completa => rondasHechas == nivel.rondas.length;

  double get progreso => rondasHechas / nivel.rondas.length;

  String? tramoDe(String corredorId) => _colocados[corredorId];

  CorredorCarrera? enTramo(String tramoId) {
    final ronda = rondaActual;
    if (ronda == null) return null;
    for (final corredor in ronda.corredores) {
      if (_colocados[corredor.id] == tramoId) return corredor;
    }
    return null;
  }

  List<CorredorCarrera> get enSalida => [
    for (final corredor in rondaActual?.corredores ?? const <CorredorCarrera>[])
      if (!_colocados.containsKey(corredor.id)) corredor,
  ];

  /// Todos los corredores están en un tramo.
  bool get listo {
    final ronda = rondaActual;
    return ronda != null &&
        !_avancePendiente &&
        ronda.corredores.every((c) => _colocados.containsKey(c.id));
  }

  bool get _bloqueada => _avancePendiente || rondaActual == null;

  CorredorCarrera _corredor(String id) => rondaActual!.corredores.firstWhere(
    (c) => c.id == id,
    orElse: () => throw ArgumentError('El corredor $id no está en la ronda.'),
  );

  void seleccionar(String corredorId) {
    if (_bloqueada) return;
    _corredor(corredorId);
    seleccionado = seleccionado == corredorId ? null : corredorId;
  }

  /// Pone al corredor en un tramo. Si el tramo estaba ocupado, el que estaba
  /// pasa al sitio que deja libre el nuevo (o vuelve a la salida).
  void colocar(String corredorId, String tramoId) {
    if (_bloqueada) return;
    _corredor(corredorId);
    if (!nivel.tramos.any((t) => t.id == tramoId)) {
      throw ArgumentError('El tramo $tramoId no existe.');
    }
    final anterior = _colocados[corredorId];
    final ocupante = enTramo(tramoId);
    if (ocupante != null && ocupante.id != corredorId) {
      if (anterior == null) {
        _colocados.remove(ocupante.id);
      } else {
        _colocados[ocupante.id] = anterior;
      }
    }
    _colocados[corredorId] = tramoId;
    seleccionado = null;
    if (atascado == corredorId) atascado = null;
  }

  /// Toca un tramo: coloca al seleccionado o devuelve a la salida al que
  /// estaba allí.
  void tocarTramo(String tramoId) {
    if (_bloqueada) return;
    final elegido = seleccionado;
    if (elegido != null) {
      colocar(elegido, tramoId);
      return;
    }
    final ocupante = enTramo(tramoId);
    if (ocupante != null) quitar(ocupante.id);
  }

  void quitar(String corredorId) {
    if (_bloqueada) return;
    _colocados.remove(corredorId);
    if (seleccionado == corredorId) seleccionado = null;
  }

  /// «¡Ya!»: el relevo recorre los tramos en orden.
  void salir() {
    final ronda = rondaActual;
    if (ronda == null || !listo) return;
    salidas++;
    seleccionado = null;
    for (var i = 0; i < nivel.tramos.length; i++) {
      final tramo = nivel.tramos[i];
      final corredor = enTramo(tramo.id)!;
      if (corredor.tramo == tramo.id) continue;
      final intento = (_intentos[ronda.id] ?? 0) + 1;
      _intentos[ronda.id] = intento;
      llegada = i;
      atascado = corredor.id;
      _colocados.remove(corredor.id);
      resultado = Resultado(
        acierto: false,
        frase: intento >= 2
            ? '${tramo.reto} ${corredor.como} ${corredor.pista}'
            : '${tramo.reto} ${corredor.como}',
        estado: 'atasco',
        gesto: intento >= 2 ? 'pista' : 'pensando',
      );
      return;
    }
    llegada = nivel.tramos.length;
    atascado = null;
    _avancePendiente = true;
    resultado = Resultado(
      acierto: true,
      frase: completa ? '${ronda.bien} ${nivel.despedida}' : ronda.bien,
      estado: 'meta',
      gesto: 'feliz',
    );
  }

  /// Pasa a la ronda siguiente después de celebrar la anterior.
  void siguiente() {
    if (!_avancePendiente || completa) return;
    _ronda++;
    _avancePendiente = false;
    _colocados.clear();
    seleccionado = null;
    atascado = null;
    llegada = 0;
    resultado = null;
  }
}
