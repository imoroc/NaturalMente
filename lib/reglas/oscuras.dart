import 'package:naturalmente/modelo/oscuras.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Estado de una partida de «La planta a oscuras», sin widgets.
///
/// Elegir un sitio, una predicción o un ingrediente no se evalúa. Se evalúa
/// al pulsar el botón del experimento: entonces pasan los días (o la hoja
/// intenta fabricar) y se ve el resultado. Si no era lo que se pedía, la
/// planta se queda como ha crecido para que se vea por qué, y Natu lo explica;
/// a la segunda añade la pista.
class PartidaOscuras {
  PartidaOscuras({required this.nivel});

  final NivelOscuras nivel;

  var _reto = 0;
  bool _avancePendiente = false;
  final Map<String, int> _intentos = {};
  final Set<String> _metidos = {};
  int _hechos = 0;

  Resultado? resultado;

  /// La opción elegida en `montar` o `predecir`.
  String? elegida;

  /// Dónde estaba la maceta la última vez que pasaron los días. `null` si
  /// todavía no han pasado en este intento.
  String? probado;

  /// Cuántas veces han pasado los días: sirve para repetir la animación.
  int dias = 0;

  /// En `fabricar`, si la hoja ha conseguido fabricar el alimento.
  bool fabricado = false;

  RetoOscuras? get retoActual =>
      _reto < nivel.retos.length ? nivel.retos[_reto] : null;

  int get retosHechos => _reto + (_avancePendiente ? 1 : 0);

  double get progreso => _hechos / nivel.retos.length;

  bool get resuelto => _avancePendiente;

  bool get completa => retosHechos == nivel.retos.length;

  Set<String> get metidos => Set.unmodifiable(_metidos);

  /// Cómo ha crecido la planta, según [crecimientoOscuras], o `null` si aún no
  /// han pasado los días.
  String? get crecimiento =>
      probado == null ? null : crecimientoOscuras[probado];

  /// Dónde se dibuja la maceta ahora mismo.
  String? get montajeVisible {
    final reto = retoActual;
    if (reto == null) return null;
    return probado ?? reto.montajeCon(elegida);
  }

  /// Si ya se puede pulsar el botón del experimento.
  bool get listo {
    final reto = retoActual;
    if (reto == null || _avancePendiente) return false;
    return reto.tipo == 'fabricar' ? _metidos.isNotEmpty : elegida != null;
  }

  /// Elige una opción. No se evalúa.
  void elegir(String opcionId) {
    final reto = retoActual;
    if (reto == null || _avancePendiente || reto.tipo == 'fabricar') return;
    if (!nivel.opciones.any((o) => o.id == opcionId)) return;
    elegida = opcionId;
    probado = null;
    resultado = null;
  }

  /// Mete o saca un ingrediente de la hoja. No se evalúa.
  void alternar(String ingredienteId) {
    final reto = retoActual;
    if (reto == null || _avancePendiente || reto.tipo != 'fabricar') return;
    if (!reto.ingredientes.any((i) => i.id == ingredienteId)) return;
    if (!_metidos.remove(ingredienteId)) _metidos.add(ingredienteId);
    resultado = null;
  }

  /// Hace el experimento. Devuelve si era lo que se pedía, o `null` si aún no
  /// se puede hacer.
  bool? probar() {
    final reto = retoActual;
    if (reto == null || !listo) return null;
    final bien = reto.tipo == 'fabricar'
        ? _probarHoja(reto)
        : _probarDias(reto);
    if (bien) {
      _hechos++;
      _avancePendiente = true;
      if (completa) {
        resultado = Resultado(
          acierto: true,
          frase: '${resultado!.frase} ${nivel.despedida}',
          estado: 'completo',
          gesto: 'feliz',
        );
      }
    }
    return bien;
  }

  bool _probarDias(RetoOscuras reto) {
    final opcion = elegida!;
    probado = reto.montajeCon(opcion);
    dias++;
    final bien = opcion == reto.respuesta;
    final frase = reto.frases[opcion]!;
    resultado = bien
        ? Resultado(acierto: true, frase: frase, estado: 'bien', gesto: 'feliz')
        : _fallo(reto, frase);
    return bien;
  }

  bool _probarHoja(RetoOscuras reto) {
    IngredienteOscuras? culpable;
    for (final ingrediente in reto.ingredientes) {
      if (ingrediente.entra != _metidos.contains(ingrediente.id)) {
        culpable = ingrediente;
        break;
      }
    }
    if (culpable == null) {
      fabricado = true;
      resultado = Resultado(
        acierto: true,
        frase: reto.como,
        estado: 'bien',
        gesto: 'feliz',
      );
      return true;
    }
    resultado = _fallo(reto, culpable.aviso);
    return false;
  }

  Resultado _fallo(RetoOscuras reto, String frase) {
    final intento = (_intentos[reto.id] ?? 0) + 1;
    _intentos[reto.id] = intento;
    return Resultado(
      acierto: false,
      frase: intento >= 2 ? '$frase ${reto.pista}' : frase,
      estado: 'fallo',
      gesto: intento >= 2 ? 'pista' : 'pensando',
    );
  }

  /// Pasa al reto siguiente.
  void siguiente() {
    if (!_avancePendiente || completa) return;
    _reto++;
    _avancePendiente = false;
    elegida = null;
    probado = null;
    fabricado = false;
    _metidos.clear();
    resultado = null;
  }
}
