import 'package:flutter/material.dart';

/// Estado de presentación compartido por los componentes del ejercicio.
class AtencionPaso extends InheritedWidget {
  const AtencionPaso({
    required this.confirmando,
    required this.transicionando,
    required this.anunciosSuspendidos,
    required super.child,
    super.key,
  });
  final bool confirmando;
  final bool transicionando;
  final bool anunciosSuspendidos;
  static AtencionPaso? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AtencionPaso>();
  @override
  bool updateShouldNotify(AtencionPaso oldWidget) =>
      confirmando != oldWidget.confirmando ||
      transicionando != oldWidget.transicionando ||
      anunciosSuspendidos != oldWidget.anunciosSuspendidos;
}

/// Las cifras siguen siendo legibles, pero solo la explicación o el nuevo
/// enunciado usan el canal automático. El check tiene su propio anuncio.
class AnuncioPaso extends StatelessWidget {
  const AnuncioPaso({required this.child, this.anunciar = false, super.key});
  final Widget child;
  final bool anunciar;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion:
        anunciar && AtencionPaso.of(context)?.anunciosSuspendidos != true,
    child: child,
  );
}

Duration duracionSeleccionPaso(BuildContext context) =>
    Duration(milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 120);

/// Conserva el progreso mientras se confirma y actualiza un único indicador.
class ProgresoPaso extends StatefulWidget {
  const ProgresoPaso({required this.child, super.key});
  final LinearProgressIndicator child;
  @override
  State<ProgresoPaso> createState() => _ProgresoPasoState();
}

class _ProgresoPasoState extends State<ProgresoPaso> {
  double? _presentado;
  @override
  Widget build(BuildContext context) {
    final scope = AtencionPaso.of(context);
    final indicador = widget.child;
    _presentado ??= indicador.value;
    if (scope?.confirmando != true) _presentado = indicador.value;
    final valor = _presentado;
    if (valor == null) return indicador;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: valor, end: valor),
      duration: Duration(
        milliseconds:
            MediaQuery.disableAnimationsOf(context) ||
                scope?.confirmando == true
            ? 0
            : 160,
      ),
      builder: (context, valor, _) => LinearProgressIndicator(
        key: indicador.key,
        value: valor,
        minHeight: indicador.minHeight,
        backgroundColor: indicador.backgroundColor,
        color: indicador.color,
        valueColor: indicador.valueColor,
        borderRadius: indicador.borderRadius,
        semanticsLabel: indicador.semanticsLabel,
        semanticsValue: indicador.semanticsValue,
      ),
    );
  }
}

/// Asentamiento local, simultáneo con el check; no añade otra espera.
class AsentamientoPaso extends StatelessWidget {
  const AsentamientoPaso({
    required this.confirmado,
    required this.child,
    super.key,
  });
  final bool confirmado;
  final Widget child;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    key: ValueKey(confirmado),
    tween: Tween(begin: 0, end: 1),
    duration: Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 160,
    ),
    builder: (_, valor, child) => Transform.translate(
      offset: Offset(
        0,
        confirmado && !MediaQuery.disableAnimationsOf(context)
            ? -3 * (1 - valor)
            : 0,
      ),
      child: child,
    ),
    child: child,
  );
}
