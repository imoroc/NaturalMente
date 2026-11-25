import 'package:naturalmente/modelo/linterna.dart';
import 'package:naturalmente/reglas/resolver.dart';

/// Qué pasó al tocar la escena.
enum ToqueLinterna {
  /// Ahí no hay nada que buscar: no se evalúa.
  nada,

  /// Ya estaba encontrado: no se evalúa.
  repetido,

  /// Era lo que se buscaba.
  acierto,

  /// Era otra cosa de la lista: cuenta como intento.
  otro,
}

/// Estado de una partida de «Linterna y microscopio», sin widgets.
///
/// Mover la luz no se evalúa. Al tocar la escena se mira qué hay debajo:
/// si es lo que se busca ahora, se queda encendido; si es otra cosa de la
/// lista, Natu dice qué es y, a la segunda, da una pista. Tocar donde no hay
/// nada no cuenta.
class PartidaLinterna {
  PartidaLinterna({required this.nivel});

  final NivelLinterna nivel;

  var _escena = 0;
  bool _avancePendiente = false;
  final Set<String> _encontrados = {};
  final Map<String, int> _intentos = {};
  int _hechos = 0;

  Resultado? resultado;

  /// Lo último que se tocó y no era lo que se buscaba.
  String? tocado;

  EscenaLinterna? get escenaActual =>
      _escena < nivel.escenas.length ? nivel.escenas[_escena] : null;

  int get escenasHechas => _escena + (_avancePendiente ? 1 : 0);

  int get totalObjetivos =>
      nivel.escenas.fold(0, (total, e) => total + e.objetivos.length);

  int get encontradosNivel => _hechos;

  double get progreso => _hechos / totalObjetivos;

  /// Al terminar una escena se enciende la luz entera.
  bool get iluminada => _avancePendiente;

  bool get completa => escenasHechas == nivel.escenas.length;

  bool encontrado(String objetivoId) => _encontrados.contains(objetivoId);

  /// El primero de la lista que falta por encontrar.
  ObjetivoLinterna? get buscado {
    final escena = escenaActual;
    if (escena == null || _avancePendiente) return null;
    for (final objetivo in escena.objetivos) {
      if (!_encontrados.contains(objetivo.id)) return objetivo;
    }
    return null;
  }

  /// El objetivo de la escena que está debajo del punto, o `null`.
  ObjetivoLinterna? queHay(double x, double y) {
    final escena = escenaActual;
    if (escena == null) return null;
    ObjetivoLinterna? mejor;
    var menor = 1.0;
    for (final objetivo in escena.objetivos) {
      for (final zona in objetivo.zonas) {
        final d = zona.distancia(x, y);
        if (d <= menor) {
          menor = d;
          mejor = objetivo;
        }
      }
    }
    return mejor;
  }

  /// Toca la escena en el punto (x, y), de 0 a 1.
  ToqueLinterna tocar(double x, double y) {
    final objetivo = buscado;
    if (objetivo == null) return ToqueLinterna.nada;
    final debajo = queHay(x, y);
    if (debajo == null) {
      tocado = null;
      return ToqueLinterna.nada;
    }
    if (_encontrados.contains(debajo.id)) {
      tocado = null;
      return ToqueLinterna.repetido;
    }
    if (debajo.id != objetivo.id) {
      final intento = (_intentos[objetivo.id] ?? 0) + 1;
      _intentos[objetivo.id] = intento;
      tocado = debajo.id;
      resultado = Resultado(
        acierto: false,
        frase: intento >= 2
            ? '${debajo.aviso} ${objetivo.pista}'
            : debajo.aviso,
        estado: 'otro',
        gesto: intento >= 2 ? 'pista' : 'pensando',
      );
      return ToqueLinterna.otro;
    }
    tocado = null;
    _encontrados.add(objetivo.id);
    _hechos++;
    final escena = escenaActual!;
    final fin = escena.objetivos.every((o) => _encontrados.contains(o.id));
    if (fin) _avancePendiente = true;
    resultado = Resultado(
      acierto: true,
      frase: !fin
          ? objetivo.como
          : completa
          ? '${objetivo.como} ${escena.bien} ${nivel.despedida}'
          : '${objetivo.como} ${escena.bien}',
      estado: fin ? 'luz' : 'encontrado',
      gesto: 'feliz',
    );
    return ToqueLinterna.acierto;
  }

  /// Pasa a la escena siguiente después de encender la luz.
  void siguiente() {
    if (!_avancePendiente || completa) return;
    _escena++;
    _avancePendiente = false;
    _encontrados.clear();
    tocado = null;
    resultado = null;
  }
}
