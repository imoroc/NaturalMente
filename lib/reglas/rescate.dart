import 'package:naturalmente/modelo/rescate.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Estado de una partida de «Cuida la reserva», sin widgets.
///
/// Cada acierto es una sección comprobada: una basura recogida, un residuo
/// en su contenedor o una pregunta de una especie. Los fallos no se cuentan
/// como aciertos y Natu explica qué pasa.
class PartidaRescate {
  PartidaRescate({required this.nivel});

  final NivelRescate nivel;

  final Set<String> _recogidos = {};
  var _residuo = 0;
  var _especie = 0;
  var _pasoAyuda = false;
  final Map<String, int> _intentos = {};
  Resultado? resultado;

  /// Último objeto, contenedor u opción tocados, para resaltarlo.
  String? ultimaEleccion;

  // --- Fácil: recoger la basura de la escena ---

  bool recogido(String id) => _recogidos.contains(id);

  int get basuraTotal => nivel.objetos.where((o) => o.basura).length;
  int get basuraRecogida => _recogidos.length;

  void tocar(String objetoId) {
    if (!nivel.esEscena || completa || recogido(objetoId)) return;
    final objeto = nivel.objetos.firstWhere(
      (o) => o.id == objetoId,
      orElse: () => throw ArgumentError('El objeto $objetoId no existe.'),
    );
    ultimaEleccion = objetoId;
    if (objeto.basura) {
      _recogidos.add(objetoId);
      resultado = Resultado(
        acierto: true,
        frase: completa ? '${objeto.frase} ${nivel.despedida}' : objeto.frase,
        estado: 'recogido',
        gesto: 'feliz',
      );
    } else {
      resultado = Resultado(
        acierto: false,
        frase: objeto.frase,
        estado: 'natural',
        gesto: 'pensando',
      );
    }
  }

  // --- Medio: cada residuo a su contenedor ---

  Residuo? get residuoActual =>
      _residuo < nivel.residuos.length ? nivel.residuos[_residuo] : null;
  int get residuosColocados => _residuo;

  void tirar(String contenedorId) {
    final residuo = residuoActual;
    if (!nivel.esContenedores || residuo == null) return;
    ultimaEleccion = contenedorId;
    if (residuo.contenedor == contenedorId) {
      _residuo += 1;
      resultado = Resultado(
        acierto: true,
        frase: completa ? '${residuo.bien} ${nivel.despedida}' : residuo.bien,
        estado: 'bien',
        gesto: 'feliz',
      );
      return;
    }
    final intento = (_intentos[residuo.id] ?? 0) + 1;
    _intentos[residuo.id] = intento;
    resultado = Resultado(
      acierto: false,
      frase: residuo.mal,
      estado: 'otroContenedor',
      gesto: intento >= 2 ? 'pista' : 'pensando',
    );
  }

  // --- Difícil: especies amenazadas ---

  Especie? get especieActual =>
      _especie < nivel.especies.length ? nivel.especies[_especie] : null;
  int get especiesAyudadas => _especie;

  /// True cuando ya se sabe qué la amenaza y falta decir qué la ayuda.
  bool get preguntaAyuda => _pasoAyuda;

  void responder(String opcionId) {
    final especie = especieActual;
    if (!nivel.esEspecies || especie == null) return;
    ultimaEleccion = opcionId;
    final pregunta = _pasoAyuda ? especie.ayuda : especie.amenaza;
    final respuesta = resolverPreguntaExtra(
      pregunta: pregunta,
      eleccion: opcionId,
    );
    if (respuesta.acierto) {
      if (_pasoAyuda) {
        _pasoAyuda = false;
        _especie += 1;
      } else {
        _pasoAyuda = true;
      }
      ultimaEleccion = null;
    }
    resultado = respuesta.acierto && completa
        ? Resultado(
            acierto: true,
            frase: '${respuesta.frase} ${nivel.despedida}',
            estado: respuesta.estado,
            gesto: 'feliz',
          )
        : respuesta;
  }

  // --- Común ---

  bool get completa {
    if (nivel.esEscena) return basuraRecogida == basuraTotal;
    if (nivel.esContenedores) return _residuo == nivel.residuos.length;
    return _especie == nivel.especies.length;
  }

  double get progreso {
    if (nivel.esEscena) return basuraRecogida / basuraTotal;
    if (nivel.esContenedores) return _residuo / nivel.residuos.length;
    return (_especie * 2 + (_pasoAyuda ? 1 : 0)) / (nivel.especies.length * 2);
  }
}
