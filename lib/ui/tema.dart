import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Colores de interfaz de NaturalMente. Las ilustraciones conservan su paleta.
@immutable
class ColoresNaturales extends ThemeExtension<ColoresNaturales> {
  const ColoresNaturales({required bool oscuro}) : _oscuridad = oscuro ? 1 : 0;
  const ColoresNaturales._(this._oscuridad);
  final double _oscuridad;
  bool get oscuro => _oscuridad >= .5;
  Color _mezclar(Color claro, Color oscuro) =>
      Color.lerp(claro, oscuro, _oscuridad)!;

  Color get fondo => _mezclar(const Color(0xFFF7F4EB), const Color(0xFF101E19));
  Color get tarjeta =>
      _mezclar(const Color(0xFFFFFDF7), const Color(0xFF1B3027));
  Color get tinta => _mezclar(const Color(0xFF1D3528), const Color(0xFFECF5EE));
  Color get tenue => _mezclar(const Color(0xFF344E41), const Color(0xFFBFCEC4));
  Color get contorno =>
      _mezclar(const Color(0xFFD6CFC0), const Color(0xFF718A7C));
  Color get acierto =>
      _mezclar(const Color(0xFF157347), const Color(0xFF80E4AA));
  Color get fondoAcierto =>
      _mezclar(const Color(0xFFDCFCE7), const Color(0xFF173E2C));
  Color get pista => _mezclar(const Color(0xFF92400E), const Color(0xFFFFD18C));
  Color get fondoPista =>
      _mezclar(const Color(0xFFFEF3C7), const Color(0xFF3D2D1B));

  /// Adapta las superficies de la paleta ilustrada existente conservando su
  /// matiz (zona azul, invernadero naranja…). Los colores ya oscuros se
  /// conservan. Esta adaptación se aplica a la interfaz, nunca a animales,
  /// órganos o señales cuyo color forma parte de la actividad.
  Color superficie(Color color) {
    if (_oscuridad == 0 || color.a == 0) return color;
    if ((color.toARGB32() & 0xFFFFFF) == 0xF7F4EB) {
      return _mezclar(
        color,
        const Color(0xFF101E19).withValues(alpha: color.a),
      );
    }
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness < .30) return color;
    if (hsl.saturation < .10 ||
        (hsl.lightness > .93 &&
            (color.r - color.b).abs() < .09 &&
            (color.g - color.r).abs() < .09 &&
            (color.g - color.b).abs() < .09)) {
      return _mezclar(
        color,
        const Color(0xFF1B3027).withValues(alpha: color.a),
      );
    }
    return _mezclar(
      color,
      hsl
          .withSaturation(hsl.saturation.clamp(.12, .40))
          .withLightness(.16 + (1 - hsl.lightness) * .12)
          .toColor(),
    );
  }

  /// Texto/iconos sobre superficies. El blanco se usa sobre acciones o escenas
  /// oscuras y permanece blanco; la tinta oscura pasa a un tono claro afín.
  Color contenido(Color color) {
    if (_oscuridad == 0 || color.a == 0) return color;
    final hsl = HSLColor.fromColor(color);
    if (hsl.lightness > .78) return color;
    if (hsl.saturation < .12) {
      return _mezclar(
        color,
        const Color(0xFFECF5EE).withValues(alpha: color.a),
      );
    }
    return _mezclar(
      color,
      hsl
          .withSaturation(hsl.saturation.clamp(.15, .65))
          .withLightness(.80)
          .toColor(),
    );
  }

  Color borde(Color color) {
    if (_oscuridad == 0 || color.a == 0) return color;
    final hsl = HSLColor.fromColor(color);
    return _mezclar(
      color,
      hsl
          .withSaturation(hsl.saturation.clamp(.08, .55))
          .withLightness(.60)
          .toColor(),
    );
  }

  Color? superficieOpcional(Color? color) =>
      color == null ? null : superficie(color);
  Color? contenidoOpcional(Color? color) =>
      color == null ? null : contenido(color);
  Color? bordeOpcional(Color? color) => color == null ? null : borde(color);
  Color? sombraOpcional(Color? color) => color == null ? null : sombra(color);

  Color sombra(Color color) =>
      _mezclar(color, const Color(0xFF050E09).withValues(alpha: color.a * .7));

  @override
  ColoresNaturales copyWith({bool? oscuro}) =>
      oscuro == null ? this : ColoresNaturales(oscuro: oscuro);

  @override
  ColoresNaturales lerp(covariant ColoresNaturales? other, double t) =>
      other == null
      ? this
      : ColoresNaturales._(_oscuridad + (other._oscuridad - _oscuridad) * t);
}

extension TemaNaturalContext on BuildContext {
  ColoresNaturales get coloresNaturales =>
      Theme.of(this).extension<ColoresNaturales>() ??
      ColoresNaturales(oscuro: Theme.of(this).brightness == Brightness.dark);
}

abstract final class TemaNatural {
  static ThemeData crear(Brightness brillo) {
    final oscuro = brillo == Brightness.dark;
    final colores = ColoresNaturales(oscuro: oscuro);
    final esquema = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2ECC71),
      brightness: brillo,
      primary: oscuro ? const Color(0xFF80E4AA) : const Color(0xFF1B8045),
      onPrimary: oscuro ? const Color(0xFF103724) : Colors.white,
      secondary: oscuro ? const Color(0xFFFFD18C) : const Color(0xFFFF9F1C),
      onSecondary: const Color(0xFF3D2D1B),
      surface: colores.tarjeta,
      onSurface: colores.tinta,
      onSurfaceVariant: colores.tenue,
      outline: colores.contorno,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: esquema);
    return base.copyWith(
      extensions: [colores],
      scaffoldBackgroundColor: colores.fondo,
      appBarTheme: AppBarTheme(
        backgroundColor: colores.fondo,
        foregroundColor: colores.tinta,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: oscuro
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: colores.tinta,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: TextStyle(
          color: colores.tinta,
          fontWeight: FontWeight.w900,
          fontSize: 26,
          letterSpacing: -.5,
        ),
        titleLarge: TextStyle(
          color: colores.tinta,
          fontWeight: FontWeight.w800,
          fontSize: 19,
        ),
        bodyMedium: TextStyle(color: colores.tenue, fontSize: 15, height: 1.3),
      ),
      popupMenuTheme: PopupMenuThemeData(color: colores.tarjeta),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colores.tarjeta,
        modalBackgroundColor: colores.tarjeta,
      ),
      dialogTheme: DialogThemeData(backgroundColor: colores.tarjeta),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colores.tinta,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(color: colores.fondo),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: oscuro
            ? const Color(0xFF304D3E)
            : const Color(0xFF1D3528),
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: const Color(0xFFFFD18C),
      ),
    );
  }
}
