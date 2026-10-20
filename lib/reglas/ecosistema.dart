import 'package:naturalmente/modelo/ecosistema.dart';

/// La presentación anima los resultados; nunca decide si se avanza.
class PartidaEcosistema {
  PartidaEcosistema(this.ecosistema, this.nivel);
  final Ecosistema ecosistema;
  final NivelEcosistema nivel;
  final Set<String> _colocados = {};
  Set<String> get colocados => Set.unmodifiable(_colocados);
  int _reto = 0;
  int intentos = 0;
  bool confirmado = false;
  bool completa = false;
  String? seleccion, ultimoDestino;
  String? frase;
  bool? acierto;
  bool get montando => _colocados.length < ecosistema.elementos.length;
  ElementoEcosistema? get elementoActual => montando
      ? ecosistema.elementos.firstWhere((e) => !_colocados.contains(e.id))
      : null;
  RetoEcosistema? get retoActual =>
      !montando && _reto < nivel.retos.length ? nivel.retos[_reto] : null;
  int get relaciones =>
      _reto.clamp(0, 2) +
      (!montando && _reto < 2 && confirmado && ultimoDestino == null ? 1 : 0);
  int get pasos =>
      _colocados.length +
      _reto +
      (!montando &&
              confirmado &&
              ultimoDestino == null &&
              _reto < nivel.retos.length
          ? 1
          : 0);
  int get total => ecosistema.elementos.length + nivel.retos.length;
  String? get cambio =>
      retoActual?.id.startsWith('menos-') == true && confirmado
      ? retoActual!.id
      : null;

  void seleccionar(String id) {
    if (completa ||
        confirmado ||
        !montando ||
        !ecosistema.elementos.any((e) => e.id == id)) {
      return;
    }
    seleccion = id;
    ultimoDestino = null;
    frase = null;
    acierto = null;
  }

  void colocar(String pieza, String destino) {
    if (completa ||
        confirmado ||
        !montando ||
        !ecosistema.elementos.any((e) => e.id == destino) ||
        !ecosistema.elementos.any((e) => e.id == pieza)) {
      return;
    }
    seleccion = pieza;
    ultimoDestino = destino;
    acierto = pieza == elementoActual!.id && pieza == destino;
    if (acierto!) {
      frase = elementoActual!.explicacion;
      _colocados.add(pieza);
      confirmado = true;
      seleccion = null;
    } else {
      intentos++;
      frase = intentos > 1
          ? elementoActual!.pista
          : elementoActual!.observacion;
    }
  }

  void responder(String id) {
    final reto = retoActual;
    if (completa ||
        confirmado ||
        reto == null ||
        !reto.opciones.any((o) => o.id == id)) {
      return;
    }
    acierto = id == reto.respuesta;
    final opcion = reto.opciones.firstWhere((o) => o.id == id);
    if (acierto!) {
      frase = opcion.frase;
      confirmado = true;
    } else {
      intentos++;
      frase = intentos > 1 ? '${opcion.frase} ${reto.pista}' : opcion.frase;
    }
  }

  void seguir() {
    if (!confirmado || completa) return;
    // Una colocación acaba de completar el montaje: aún no se ha
    // respondido el primer reto. La fase se distingue por sus pasos.
    if (_colocados.length == ecosistema.elementos.length &&
        ultimoDestino == null) {
      _reto++;
    }
    ultimoDestino = null;
    confirmado = false;
    intentos = 0;
    acierto = null;
    frase = null;
    seleccion = null;
    if (!montando && _reto == nivel.retos.length) completa = true;
  }
}
