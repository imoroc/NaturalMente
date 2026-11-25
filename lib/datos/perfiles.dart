import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:naturalmente/datos/preferencias_perfil.dart';
import 'package:naturalmente/datos/progreso.dart';

/// Animales del mote. Se guardan por id para poder mostrarlos en ES o EN.
const animalesMote = <String, (String, String)>{
  'zorro': ('Zorro', 'Fox'),
  'buho': ('Búho', 'Owl'),
  'lince': ('Lince', 'Lynx'),
  'ardilla': ('Ardilla', 'Squirrel'),
  'tortuga': ('Tortuga', 'Turtle'),
  'delfin': ('Delfín', 'Dolphin'),
  'erizo': ('Erizo', 'Hedgehog'),
  'koala': ('Koala', 'Koala'),
  'panda': ('Panda', 'Panda'),
  'nutria': ('Nutria', 'Otter'),
  'castor': ('Castor', 'Beaver'),
  'pinguino': ('Pingüino', 'Penguin'),
  'jirafa': ('Jirafa', 'Giraffe'),
  'colibri': ('Colibrí', 'Hummingbird'),
  'halcon': ('Halcón', 'Falcon'),
  'ciervo': ('Ciervo', 'Deer'),
  'lobo': ('Lobo', 'Wolf'),
  'oso': ('Oso', 'Bear'),
  'mariposa': ('Mariposa', 'Butterfly'),
  'rana': ('Rana', 'Frog'),
};

/// Adjetivos que valen igual en masculino y femenino, para que el mote
/// siempre concuerde con el animal.
const adjetivosMote = <String, (String, String)>{
  'veloz': ('Veloz', 'Swift'),
  'valiente': ('Valiente', 'Brave'),
  'alegre': ('Alegre', 'Cheerful'),
  'feliz': ('Feliz', 'Happy'),
  'amable': ('Amable', 'Kind'),
  'brillante': ('Brillante', 'Bright'),
  'genial': ('Genial', 'Awesome'),
  'agil': ('Ágil', 'Nimble'),
  'fuerte': ('Fuerte', 'Strong'),
  'audaz': ('Audaz', 'Bold'),
  'sonriente': ('Sonriente', 'Smiling'),
  'paciente': ('Paciente', 'Patient'),
  'gentil': ('Gentil', 'Gentle'),
  'libre': ('Libre', 'Free'),
  'tenaz': ('Tenaz', 'Steady'),
};

/// Colores del pañuelo de Natu. El primero es el naranja original.
const coloresNatu = <String, (Color, String)>{
  'naranja': (Color(0xFFF38333), 'Naranja'),
  'rojo': (Color(0xFFE5484D), 'Rojo'),
  'rosa': (Color(0xFFEC6FB0), 'Rosa'),
  'morado': (Color(0xFF8B5CF6), 'Morado'),
  'azul': (Color(0xFF3B82F6), 'Azul'),
  'turquesa': (Color(0xFF14B8A6), 'Turquesa'),
  'amarillo': (Color(0xFFF5C518), 'Amarillo'),
  'marron': (Color(0xFF9A6B3F), 'Marrón'),
};

/// Un niño que juega en este dispositivo. Solo tiene un mote generado y el
/// color de su Natu: ningún dato personal.
@immutable
class Perfil {
  const Perfil({
    required this.id,
    required this.animal,
    required this.adjetivo,
    required this.color,
  });

  factory Perfil.desdeJson(Map<String, dynamic> json) => Perfil(
    id: json['id'] as String,
    animal: animalesMote.containsKey(json['animal'])
        ? json['animal'] as String
        : 'tortuga',
    adjetivo: adjetivosMote.containsKey(json['adjetivo'])
        ? json['adjetivo'] as String
        : 'valiente',
    color: coloresNatu.containsKey(json['color'])
        ? json['color'] as String
        : 'naranja',
  );

  final String id, animal, adjetivo, color;

  bool get principal => id == Perfiles.idPrincipal;

  Color get colorPanuelo => coloresNatu[color]!.$1;

  /// "Zorro Veloz" en español y "Swift Fox" en inglés.
  String mote(String idioma) {
    final a = animalesMote[animal]!, b = adjetivosMote[adjetivo]!;
    return idioma == 'en' ? '${b.$2} ${a.$2}' : '${a.$1} ${b.$1}';
  }

  Perfil copiar({String? animal, String? adjetivo, String? color}) => Perfil(
    id: id,
    animal: animal ?? this.animal,
    adjetivo: adjetivo ?? this.adjetivo,
    color: color ?? this.color,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'animal': animal,
    'adjetivo': adjetivo,
    'color': color,
  };

  @override
  bool operator ==(Object other) =>
      other is Perfil &&
      other.id == id &&
      other.animal == animal &&
      other.adjetivo == adjetivo &&
      other.color == color;

  @override
  int get hashCode => Object.hash(id, animal, adjetivo, color);
}

/// Los perfiles de este dispositivo y cuál está jugando.
///
/// El perfil principal usa las claves de siempre, así que el progreso de
/// quien ya jugaba antes de que existieran los perfiles sigue intacto. Los
/// demás guardan su progreso bajo `perfiles/<id>/`.
class Perfiles extends ChangeNotifier {
  Perfiles._(this._prefs, this._lista, this._activoId, this._azar);

  static const idPrincipal = 'principal';
  static const maximo = 8;
  static const _claveLista = 'perfiles/lista';
  static const _claveActivo = 'perfiles/activo';

  final SharedPreferences _prefs;
  final Random _azar;
  List<Perfil> _lista;
  String _activoId;
  final Map<String, Progreso> _progresos = {};

  static Future<Perfiles> abrir() async =>
      leer(await SharedPreferences.getInstance());

  static Perfiles leer(SharedPreferences prefs, {Random? azar}) {
    final generador = azar ?? Random();
    var lista = <Perfil>[];
    try {
      final texto = prefs.getString(_claveLista);
      if (texto != null) {
        lista = [
          for (final item in jsonDecode(texto) as List<dynamic>)
            Perfil.desdeJson(item as Map<String, dynamic>),
        ];
      }
    } catch (_) {
      lista = [];
    }
    if (!lista.any((p) => p.principal)) {
      final (animal, adjetivo) = _moteAlAzar(generador, const {});
      lista.insert(
        0,
        Perfil(
          id: idPrincipal,
          animal: animal,
          adjetivo: adjetivo,
          color: 'naranja',
        ),
      );
      // Si no se puede guardar ahora, se vuelve a intentar al cambiar algo.
      unawaited(
        prefs
            .setString(_claveLista, _codificar(lista))
            .then<void>((_) {}, onError: (Object _) {}),
      );
    }
    final activo = prefs.getString(_claveActivo);
    return Perfiles._(
      prefs,
      lista,
      lista.any((p) => p.id == activo) ? activo! : idPrincipal,
      generador,
    );
  }

  List<Perfil> get lista => List.unmodifiable(_lista);
  Perfil get activo => _lista.firstWhere((p) => p.id == _activoId);
  bool get lleno => _lista.length >= maximo;

  /// Progreso del perfil que está jugando.
  Progreso get progreso => progresoDe(_activoId);

  Progreso progresoDe(String id) =>
      _progresos.putIfAbsent(id, () => Progreso.leer(_preferenciasDe(id)));

  /// Almacenamiento propio del perfil: se borra con él.
  SharedPreferences preferenciasDe(String id) => _preferenciasDe(id);

  SharedPreferences _preferenciasDe(String id) => id == idPrincipal
      ? _prefs
      : PreferenciasConPrefijo(_prefs, 'perfiles/$id/');

  /// Un mote que no repite el de otro perfil de este dispositivo.
  (String, String) proponerMote() =>
      _moteAlAzar(_azar, {for (final p in _lista) (p.animal, p.adjetivo)});

  static (String, String) _moteAlAzar(
    Random azar,
    Set<(String, String)> usados,
  ) {
    final animales = animalesMote.keys.toList();
    final adjetivos = adjetivosMote.keys.toList();
    for (var intento = 0; intento < 50; intento++) {
      final mote = (
        animales[azar.nextInt(animales.length)],
        adjetivos[azar.nextInt(adjetivos.length)],
      );
      if (!usados.contains(mote)) return mote;
    }
    return (animales.first, adjetivos.first);
  }

  /// Crea un perfil, lo deja jugando y devuelve `null` si no se pudo guardar.
  Future<Perfil?> crear({
    required String animal,
    required String adjetivo,
    required String color,
    int? curso,
  }) async {
    if (lleno) return null;
    String id;
    do {
      id = _azar.nextInt(0x7fffffff).toRadixString(36);
    } while (id == idPrincipal || _lista.any((p) => p.id == id));
    final perfil = Perfil(
      id: id,
      animal: animal,
      adjetivo: adjetivo,
      color: color,
    );
    final nueva = [..._lista, perfil];
    try {
      if (!await _prefs.setString(_claveLista, _codificar(nueva))) return null;
    } catch (_) {
      return null;
    }
    _lista = nueva;
    final progreso = progresoDe(id);
    // El curso y la bienvenida se eligen al crear el perfil.
    await progreso.marcarBienvenidaVista();
    if (curso != null) await progreso.guardarCurso(curso);
    await elegir(id);
    return perfil;
  }

  /// Crea un perfil para un niño que ya existe en la nube (al canjear su
  /// llave). No cambia de jugador: eso se hace después de traer su progreso.
  Future<Perfil?> crearDesdeNube(Perfil nube, {int? curso}) async {
    if (lleno) return null;
    String id;
    do {
      id = _azar.nextInt(0x7fffffff).toRadixString(36);
    } while (id == idPrincipal || _lista.any((p) => p.id == id));
    final perfil = Perfil(
      id: id,
      animal: nube.animal,
      adjetivo: nube.adjetivo,
      color: nube.color,
    );
    final nueva = [..._lista, perfil];
    try {
      if (!await _prefs.setString(_claveLista, _codificar(nueva))) return null;
    } catch (_) {
      return null;
    }
    _lista = nueva;
    final progreso = progresoDe(id);
    await progreso.marcarBienvenidaVista();
    if (curso != null) await progreso.guardarCurso(curso);
    notifyListeners();
    return perfil;
  }

  Future<bool> elegir(String id) async {
    if (!_lista.any((p) => p.id == id)) return false;
    if (id == _activoId) return true;
    try {
      if (!await _prefs.setString(_claveActivo, id)) return false;
    } catch (_) {
      return false;
    }
    _activoId = id;
    notifyListeners();
    return true;
  }

  Future<bool> actualizar(Perfil perfil) async {
    final indice = _lista.indexWhere((p) => p.id == perfil.id);
    if (indice < 0) return false;
    final nueva = [..._lista]..[indice] = perfil;
    try {
      if (!await _prefs.setString(_claveLista, _codificar(nueva))) {
        return false;
      }
    } catch (_) {
      return false;
    }
    _lista = nueva;
    notifyListeners();
    return true;
  }

  /// Borra un perfil y todo su progreso. El principal no se puede borrar.
  Future<bool> eliminar(String id) async {
    if (id == idPrincipal || !_lista.any((p) => p.id == id)) return false;
    final nueva = _lista.where((p) => p.id != id).toList();
    try {
      if (!await _prefs.setString(_claveLista, _codificar(nueva))) {
        return false;
      }
      if (_activoId == id) {
        await _prefs.setString(_claveActivo, idPrincipal);
      }
      await PreferenciasConPrefijo(_prefs, 'perfiles/$id/').clear();
    } catch (_) {
      return false;
    }
    _lista = nueva;
    _progresos.remove(id);
    if (_activoId == id) _activoId = idPrincipal;
    notifyListeners();
    return true;
  }

  static String _codificar(List<Perfil> lista) =>
      jsonEncode([for (final p in lista) p.toJson()]);
}

/// Da acceso a los perfiles desde cualquier pantalla.
class PerfilesScope extends InheritedNotifier<Perfiles> {
  const PerfilesScope({
    required Perfiles perfiles,
    required super.child,
    super.key,
  }) : super(notifier: perfiles);

  static Perfiles? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PerfilesScope>()?.notifier;

  static Perfiles of(BuildContext context) {
    final perfiles = maybeOf(context);
    assert(perfiles != null, 'PerfilesScope no está en el árbol');
    return perfiles!;
  }
}
