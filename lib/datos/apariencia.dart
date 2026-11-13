import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La elección del usuario; el brillo del teléfono nunca se persiste.
enum ModoApariencia {
  sistema(ThemeMode.system, 'Según el teléfono'),
  claro(ThemeMode.light, 'Claro'),
  oscuro(ThemeMode.dark, 'Oscuro');

  const ModoApariencia(this.tema, this.etiqueta);
  final ThemeMode tema;
  final String etiqueta;
}

class Apariencia extends ChangeNotifier {
  Apariencia(this._preferencias)
    : _modo = ModoApariencia.values.firstWhere(
        (m) => m.name == _preferencias?.getString('apariencia'),
        orElse: () => ModoApariencia.sistema,
      );

  final SharedPreferences? _preferencias;
  ModoApariencia _modo;
  Future<void> _cola = Future.value();
  bool _cerrada = false;

  ModoApariencia get modo => _modo;
  ThemeMode get tema => _modo.tema;

  static Future<Apariencia> abrir() async {
    try {
      return Apariencia(await SharedPreferences.getInstance());
    } catch (_) {
      // La apariencia no debe impedir abrir el catálogo ni el progreso.
      return Apariencia(null);
    }
  }

  /// Serializa las escrituras para conservar el orden de las pulsaciones.
  Future<bool> elegir(ModoApariencia modo) {
    final resultado = _cola.then((_) async {
      if (_cerrada) return false;
      if (modo == _modo) return true;
      try {
        final preferencias =
            _preferencias ?? await SharedPreferences.getInstance();
        if (!await preferencias.setString('apariencia', modo.name)) {
          return false;
        }
        if (_cerrada) return false;
        _modo = modo;
        notifyListeners();
        return true;
      } catch (_) {
        return false;
      }
    });
    _cola = resultado.then((_) {});
    return resultado;
  }

  @override
  void dispose() {
    _cerrada = true;
    super.dispose();
  }
}

class AparienciaScope extends InheritedNotifier<Apariencia> {
  const AparienciaScope({
    required Apariencia apariencia,
    required super.child,
    super.key,
  }) : super(notifier: apariencia);

  static Apariencia? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AparienciaScope>()?.notifier;
}
