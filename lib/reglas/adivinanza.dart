import 'package:naturalmente/modelo/adivinanza.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Estado de una partida de «¿Quién soy?», sin widgets.
///
/// Empieza con una pista. Se puede pedir otra o arriesgarse: si no es ese
/// animal, sale sola la siguiente pista. Al acertar se pasa a la ronda
/// siguiente.
class PartidaAdivinanza {
  PartidaAdivinanza({required this.adivinanza, required this.nivel});

  final Adivinanza adivinanza;
  final NivelAdivinanza nivel;

  var _ronda = 0;
  var _pistasVistas = 1;
  final Set<String> _descartados = {};
  Resultado? resultado;

  /// Animal elegido en el último intento, para resaltarlo.
  String? ultimaEleccion;

  /// Pistas que hicieron falta en la última ronda acertada.
  int pistasUltimoAcierto = 0;

  RondaAdivinanza? get ronda =>
      _ronda < nivel.rondas.length ? nivel.rondas[_ronda] : null;
  int get indiceRonda => _ronda;
  int get pistasVistas => _pistasVistas;
  bool descartado(String animalId) => _descartados.contains(animalId);

  bool get quedanPistas {
    final actual = ronda;
    return actual != null && _pistasVistas < actual.pistas.length;
  }

  bool get completa => _ronda == nivel.rondas.length;

  double get progreso => _ronda / nivel.rondas.length;

  void otraPista() {
    if (!quedanPistas) return;
    _pistasVistas += 1;
    ultimaEleccion = null;
    resultado = null;
  }

  void adivinar(String animalId) {
    final actual = ronda;
    if (actual == null || descartado(animalId)) return;
    if (!actual.opciones.contains(animalId)) {
      throw ArgumentError('$animalId no es una opción de ${actual.id}.');
    }
    ultimaEleccion = animalId;
    if (animalId == actual.respuesta) {
      pistasUltimoAcierto = _pistasVistas;
      _ronda += 1;
      _pistasVistas = 1;
      _descartados.clear();
      resultado = Resultado(
        acierto: true,
        frase: completa ? '${actual.frase} ${nivel.despedida}' : actual.frase,
        estado: 'acierto',
        gesto: 'feliz',
      );
      return;
    }
    _descartados.add(animalId);
    final nombre = adivinanza.animal(animalId).conArticulo;
    final hayNueva = quedanPistas;
    if (hayNueva) _pistasVistas += 1;
    resultado = Resultado(
      acierto: false,
      frase: hayNueva
          ? 'No soy $nombre. Lee la nueva pista.'
          : 'No soy $nombre. Vuelve a leer las pistas.',
      estado: 'fallo',
      gesto: 'pensando',
    );
  }
}
