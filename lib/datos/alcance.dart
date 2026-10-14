import 'package:flutter/material.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';

class Alcance extends InheritedNotifier<Progreso> {
  const Alcance({
    required this.catalogo,
    required this.progreso,
    required super.child,
    super.key,
  }) : super(notifier: progreso);

  final Catalogo catalogo;
  final Progreso progreso;

  static Alcance of(BuildContext context) {
    final alcance = context.dependOnInheritedWidgetOfExactType<Alcance>();
    assert(alcance != null, 'Alcance no está en el árbol');
    return alcance!;
  }

  @override
  bool updateShouldNotify(Alcance oldWidget) {
    return catalogo != oldWidget.catalogo ||
        super.updateShouldNotify(oldWidget);
  }
}
