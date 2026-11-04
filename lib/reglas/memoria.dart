import 'package:naturalmente/modelo/memoria.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Estado de una partida de «Memoria de las plantas», sin widgets.
///
/// Se destapan dos cartas: si son pareja se quedan boca arriba y Natu explica
/// qué tienen que ver. Si no, se quedan a la vista hasta que se toca otra
/// carta, para que dé tiempo a fijarse en ellas.
class PartidaMemoria {
  PartidaMemoria({required this.nivel});

  final NivelMemoria nivel;

  final Set<String> _encontradas = {};
  final List<String> _abiertas = [];
  Resultado? resultado;

  bool encontrada(String parejaId) => _encontradas.contains(parejaId);

  /// Cartas boca arriba que todavía no forman pareja.
  List<String> get abiertas => List.unmodifiable(_abiertas);

  bool visible(String cartaId) =>
      _abiertas.contains(cartaId) || encontrada(nivel.pareja(cartaId).id);

  int get parejasEncontradas => _encontradas.length;

  bool get completa => _encontradas.length == nivel.parejas.length;

  double get progreso => _encontradas.length / nivel.parejas.length;

  /// Da la vuelta a una carta. Devuelve si la jugada se ha evaluado (al
  /// destapar la segunda carta); la primera carta solo se muestra.
  bool tocar(String cartaId) {
    if (completa) return false;
    // Tras un fallo, la siguiente carta tapa las dos que no eran pareja.
    if (_abiertas.length == 2) {
      _abiertas.clear();
      resultado = null;
    }
    if (visible(cartaId)) return false;
    _abiertas.add(cartaId);
    if (_abiertas.length < 2) return false;
    final primera = nivel.pareja(_abiertas[0]);
    final segunda = nivel.pareja(_abiertas[1]);
    if (primera.id == segunda.id) {
      _encontradas.add(primera.id);
      _abiertas.clear();
      resultado = Resultado(
        acierto: true,
        frase: completa ? '${primera.frase} ${nivel.despedida}' : primera.frase,
        estado: 'pareja',
        gesto: 'feliz',
      );
    } else {
      resultado = const Resultado(
        acierto: false,
        frase: 'Esas dos cartas no van juntas. Fíjate bien en ellas y busca otra pareja.',
        estado: 'noPareja',
        gesto: 'pensando',
      );
    }
    return true;
  }
}
