import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/ui/carta_cromo.dart';
import 'package:naturalmente/ui/texto.dart';

String nombreAcabadoCromo(AcabadoCromo acabado) => switch (acabado) {
  AcabadoCromo.laton => 'Latón',
  AcabadoCromo.nacar => 'Nácar especial',
};

String _textoDato(
  BuildContext context,
  DatoCromo dato, {
  String separador = ': ',
}) => '${context.tr(dato.etiqueta.texto)}$separador${context.tr(dato.valor)}';

/// Con texto ampliado, el nombre y el resumen se leen debajo de la carta.
class RotuloExteriorCromo extends StatelessWidget {
  const RotuloExteriorCromo({
    required this.titulo,
    required this.color,
    this.mundo,
    this.datos = const [],
    super.key,
  });

  static bool necesario(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(16) > 24;

  final String titulo;
  final String? mundo;
  final Color color;
  final List<DatoCromo> datos;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: ExcludeSemantics(
      child: Column(
        children: [
          Texto(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, color: color),
          ),
          if (mundo case final String nombre)
            Texto(
              nombre,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          if (datos.isNotEmpty) const SizedBox(height: 8),
          for (final dato in datos)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                _textoDato(context, dato, separador: ' · '),
                textAlign: TextAlign.center,
                style: TextStyle(color: color),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Carta de tamaño completo. La celebración usa la misma cara en reposo.
class CromoColeccionable extends StatefulWidget {
  const CromoColeccionable({
    required this.ficha,
    required this.conseguida,
    this.mundo,
    this.inclinable = false,
    super.key,
  });

  final Ficha ficha;
  final bool conseguida;
  final String? mundo;
  final bool inclinable;

  @override
  State<CromoColeccionable> createState() => _CromoColeccionableState();
}

class _CromoColeccionableState extends State<CromoColeccionable>
    with SingleTickerProviderStateMixin {
  final _posicion = ValueNotifier(Offset.zero);
  Offset? _origenArrastre;
  Offset _origenPosicion = Offset.zero;
  Offset _origenRetorno = Offset.zero;
  bool _mostrarFoco = false;
  bool _reducido = false;

  late final AnimationController _retorno =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 180),
      )..addListener(() {
        _posicion.value = Offset.lerp(
          _origenRetorno,
          Offset.zero,
          Curves.easeOutCubic.transform(_retorno.value),
        )!;
      });

  bool get _puedeInclinar =>
      widget.inclinable && widget.conseguida && !_reducido;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducido = MediaQuery.disableAnimationsOf(context);
    if (_reducido) _reiniciar();
  }

  @override
  void didUpdateWidget(covariant CromoColeccionable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ficha.id != widget.ficha.id || !_puedeInclinar) _reiniciar();
  }

  void _reiniciar() {
    _origenArrastre = null;
    _retorno.stop();
    _posicion.value = Offset.zero;
  }

  @override
  void dispose() {
    _retorno.dispose();
    _posicion.dispose();
    super.dispose();
  }

  void _empezarArrastre(DragStartDetails details) {
    _retorno.stop();
    _origenArrastre = details.localPosition;
    _origenPosicion = _posicion.value;
  }

  void _moverArrastre(DragUpdateDetails details) {
    if (_origenArrastre case final Offset origen) {
      _inclinar(_origenPosicion + (details.localPosition - origen) / 68);
    }
  }

  void _inclinar(Offset posicion) {
    _posicion.value = Offset(
      posicion.dx.clamp(-1.0, 1.0),
      posicion.dy.clamp(-1.0, 1.0),
    );
  }

  void _volverAlReposo() {
    _origenArrastre = null;
    if (_posicion.value == Offset.zero) return;
    _origenRetorno = _posicion.value;
    _retorno.forward(from: 0);
  }

  KeyEventResult _tecla(FocusNode _, KeyEvent evento) {
    if (evento is KeyUpEvent) return KeyEventResult.ignored;
    if (evento.logicalKey == LogicalKeyboardKey.escape) {
      if (_posicion.value == Offset.zero) return KeyEventResult.ignored;
      _volverAlReposo();
      return KeyEventResult.handled;
    }
    final paso = switch (evento.logicalKey) {
      LogicalKeyboardKey.arrowLeft => const Offset(-.25, 0),
      LogicalKeyboardKey.arrowRight => const Offset(.25, 0),
      LogicalKeyboardKey.arrowUp => const Offset(0, -.25),
      LogicalKeyboardKey.arrowDown => const Offset(0, .25),
      _ => null,
    };
    if (paso == null) return KeyEventResult.ignored;
    _retorno.stop();
    _inclinar(_posicion.value + paso);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final ficha = widget.ficha;
    final conseguida = widget.conseguida;
    final acabado = conseguida ? ficha.acabado : null;
    final contenido = _MarcoCromo(
      acabado: acabado,
      reflejo: _posicion,
      child: RepaintBoundary(
        child: _ContenidoCromo(
          ficha: ficha,
          conseguida: conseguida,
          mundo: widget.mundo,
        ),
      ),
    );
    final etiqueta = [
      context.tr(ficha.titulo),
      if (conseguida && widget.mundo != null) context.tr(widget.mundo!),
      context.tr(
        acabado == null ? 'Por descubrir' : nombreAcabadoCromo(acabado),
      ),
      if (conseguida)
        for (final dato in ficha.resumenCromo) _textoDato(context, dato),
    ].join(', ');

    return Semantics(
      label: etiqueta,
      image: true,
      child: AspectRatio(
        aspectRatio: 5 / 7,
        child: _puedeInclinar
            ? Focus(
                onFocusChange: (enfocado) {
                  setState(() => _mostrarFoco = enfocado);
                  if (!enfocado) _volverAlReposo();
                },
                onKeyEvent: _tecla,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    excludeFromSemantics: true,
                    dragStartBehavior: DragStartBehavior.down,
                    onHorizontalDragStart: _empezarArrastre,
                    onHorizontalDragUpdate: _moverArrastre,
                    onHorizontalDragEnd: (_) => _volverAlReposo(),
                    onHorizontalDragCancel: _volverAlReposo,
                    child: ValueListenableBuilder<Offset>(
                      valueListenable: _posicion,
                      child: ExcludeSemantics(child: contenido),
                      builder: (context, posicion, cara) {
                        const radian = math.pi / 180;
                        final horizontal = (-5 + 8 * posicion.dx).clamp(-8, 8);
                        final vertical = (3 - 6 * posicion.dy).clamp(-6, 6);
                        return Transform(
                          key: const Key('inclinacion-cromo'),
                          alignment: Alignment.center,
                          transformHitTests: false,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, .0015)
                            ..rotateZ(-4 * radian)
                            ..rotateX(vertical * radian)
                            ..rotateY(horizontal * radian),
                          child: _mostrarFoco
                              ? DecoratedBox(
                                  position: DecorationPosition.foreground,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFFFE498),
                                      width: 3,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: cara,
                                )
                              : cara,
                        );
                      },
                    ),
                  ),
                ),
              )
            : ExcludeSemantics(child: contenido),
      ),
    );
  }
}

/// Las capas del material se pueden usar sin ilustración ni rótulo.
class _MarcoCromo extends StatelessWidget {
  const _MarcoCromo({required this.acabado, required this.reflejo, this.child});

  final AcabadoCromo? acabado;
  final ValueListenable<Offset> reflejo;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final (metal, canto, papel, ribete) = switch (acabado) {
      AcabadoCromo.laton => (
        const [
          Color(0xFFFFF4C7),
          Color(0xFFA76B27),
          Color(0xFFF7D87F),
          Color(0xFFFFF1BC),
          Color(0xFFB0813B),
          Color(0xFFEFB955),
        ],
        const Color(0xFF745020),
        const Color(0xFFFFF1CB),
        const Color(0xFFB68B49),
      ),
      AcabadoCromo.nacar => (
        const [
          Color(0xFFFFF7DA),
          Color(0xFF9BBDBB),
          Color(0xFFF5BFDA),
          Color(0xFFFFFDF2),
          Color(0xFFA3E4D4),
          Color(0xFFB7AFD7),
        ],
        const Color(0xFF6C7976),
        const Color(0xFFF7F1E2),
        const Color(0xFF9B988C),
      ),
      null => (
        const [Color(0xFFE8E6DB), Color(0xFFB4B2A6), Color(0xFFD7D8CE)],
        const Color(0xFF777A70),
        const Color(0xFFEDEDE4),
        const Color(0xFFA8AB9B),
      ),
    };
    return LayoutBuilder(
      builder: (context, medidas) {
        final ancho = medidas.maxWidth;
        final grosor = ancho * .013;
        final cara = BorderRadius.circular(ancho * .066);
        final margen = ancho * .061;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(grosor, grosor),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: canto,
                  borderRadius: cara,
                  border: Border.all(color: ribete),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xB0081712),
                      blurRadius: 22,
                      offset: Offset(2, 13),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: cara,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: metal,
                ),
                border: Border.all(color: const Color(0xFFF8F2E2)),
              ),
            ),
            if (acabado != null)
              RepaintBoundary(
                child: CustomPaint(
                  painter: _ReflejoMarco(reflejo, margen, cara.topLeft),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(margen),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ancho * .04),
                  border: Border.all(color: ribete),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFFFFFBED), papel],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x452F230D), blurRadius: 3),
                  ],
                ),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReflejoMarco extends CustomPainter {
  _ReflejoMarco(this.reflejo, this.margen, this.radio)
    : super(repaint: reflejo);

  final ValueListenable<Offset> reflejo;
  final double margen;
  final Radius radio;

  // Repetir la veta en un shader evita dibujar y recortar líneas por separado.
  static final _veta = Paint()
    ..shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(1.5, 1.5),
      const [
        Color(0x00FFFFFF),
        Color(0x19FFFFFF),
        Color(0x19FFFFFF),
        Color(0x00FFFFFF),
      ],
      const [0, .10, .22, .32],
      TileMode.repeated,
    );

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final marco = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(RRect.fromRectAndRadius(rect.deflate(1), radio))
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(margen), const Radius.circular(8)),
      );
    final posicion = reflejo.value;
    final centro = Alignment(-.45 + posicion.dx * .9, -.55 + posicion.dy);
    final luz = Paint()
      ..shader = RadialGradient(
        center: centro,
        radius: .74,
        colors: const [Color(0xE8FFFFFF), Color(0x12FFFFFF), Color(0x00FFFFFF)],
        stops: const [0, .71, 1],
      ).createShader(rect);
    canvas.drawPath(marco, luz);
    canvas.drawPath(marco, _veta);
  }

  @override
  bool shouldRepaint(covariant _ReflejoMarco anterior) =>
      anterior.reflejo != reflejo ||
      anterior.margen != margen ||
      anterior.radio != radio;
}

class _ContenidoCromo extends StatelessWidget {
  const _ContenidoCromo({
    required this.ficha,
    required this.conseguida,
    required this.mundo,
  });

  final Ficha ficha;
  final bool conseguida;
  final String? mundo;

  @override
  Widget build(BuildContext context) {
    const tinta = Color(0xFF1D3528);
    final rotuloInterior = !RotuloExteriorCromo.necesario(context);
    final acento = conseguida
        ? switch (ficha.zona) {
            'invernadero' => const Color(0xFF6F9251),
            'cuerpo' => const Color(0xFF9A7895),
            _ => const Color(0xFF548D80),
          }
        : const Color(0xFF92968A);
    return LayoutBuilder(
      builder: (context, medidas) {
        final relleno = math.max(9.0, medidas.maxWidth * .064);
        final anchoInterior = medidas.maxWidth - 2 * relleno;
        return CustomPaint(
          painter: _GrabadoDeCampo(acento, conContornos: conseguida),
          child: Padding(
            padding: EdgeInsets.all(relleno),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (rotuloInterior) ...[
                  if (conseguida && mundo != null) ...[
                    Texto(
                      mundo!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: tinta,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        height: 1.16,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 21,
                              height: 1,
                              child: ColoredBox(color: acento),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Transform.rotate(
                                angle: math.pi / 4,
                                child: SizedBox.square(
                                  dimension: 3,
                                  child: ColoredBox(color: acento),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 14,
                              height: 1,
                              child: ColoredBox(color: acento),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  Texto(
                    ficha.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _ajustarTextoCromo(
                      context,
                      ficha.titulo,
                      ancho: anchoInterior,
                      minimo: 16,
                      estilo: TextStyle(
                        fontFamily: 'NunitoInicio',
                        fontWeight: FontWeight.w900,
                        fontSize: (anchoInterior * .158).clamp(14.0, 27.0),
                        color: tinta,
                        height: 1.08,
                      ),
                    ).estilo,
                  ),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: conseguida
                          ? IlustracionCromo(
                              ficha,
                              alto: math.min(235, anchoInterior),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(52),
                              child: Icon(
                                Icons.lock_rounded,
                                color: Color(0xFF566352),
                                size: 68,
                              ),
                            ),
                    ),
                  ),
                ),
                if (rotuloInterior &&
                    conseguida &&
                    ficha.resumenCromo.isNotEmpty)
                  _BandaDatosCromo(datos: ficha.resumenCromo, acento: acento),
              ],
            ),
          ),
        );
      },
    );
  }
}

({TextStyle estilo, bool cabe}) _ajustarTextoCromo(
  BuildContext context,
  String texto, {
  required double ancho,
  required double minimo,
  required TextStyle estilo,
}) {
  if (ancho <= 0) return (estilo: estilo, cabe: false);
  final traducido = context.tr(texto);
  final cuerpo = estilo.fontSize!;
  final estiloMedido = DefaultTextStyle.of(context).style.merge(estilo);
  final pintor = TextPainter(
    text: TextSpan(text: traducido, style: estiloMedido),
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
    maxLines: 2,
  )..layout();
  // Absorber el redondeo del espaciado al encajar una palabra larga.
  var tamano =
      cuerpo * math.min(1, math.max(1, ancho - 1) / pintor.minIntrinsicWidth);
  for (var intento = 0; intento < 4; intento++) {
    pintor.text = TextSpan(
      text: traducido,
      style: estiloMedido.copyWith(fontSize: tamano),
    );
    pintor.layout(maxWidth: ancho);
    if (!pintor.didExceedMaxLines || tamano <= minimo || intento == 3) break;
    tamano = math.max(minimo, tamano * .9);
  }
  final cabe = !pintor.didExceedMaxLines;
  pintor.dispose();
  return (estilo: estilo.copyWith(fontSize: tamano), cabe: cabe);
}

class _BandaDatosCromo extends StatelessWidget {
  const _BandaDatosCromo({required this.datos, required this.acento});

  final List<DatoCromo> datos;
  final Color acento;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: ShapeDecoration(
      color: Color.alphaBlend(
        acento.withValues(alpha: .10),
        const Color(0xFFFFF8E8),
      ),
      shape: BeveledRectangleBorder(
        side: BorderSide(color: acento.withValues(alpha: .85), width: .8),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: LayoutBuilder(
        builder: (context, medidas) {
          const relleno = 6.0;
          const valor = TextStyle(
            fontFamily: 'NunitoInicio',
            fontSize: 14,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1D3528),
          );
          final anchoColumna = medidas.maxWidth / datos.length - 2 * relleno;
          final ajustes = [
            for (final dato in datos)
              _ajustarTextoCromo(
                context,
                dato.valor,
                ancho: anchoColumna,
                minimo: 11,
                estilo: valor,
              ),
          ];
          final columnas = datos.length == 2 && ajustes.every((a) => a.cabe);

          Widget campo(int indice) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: relleno),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Texto(
                  datos[indice].etiqueta.texto,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF344D40),
                  ),
                ),
                Texto(
                  datos[indice].valor,
                  maxLines: columnas ? 2 : null,
                  style: columnas ? ajustes[indice].estilo : valor,
                ),
              ],
            ),
          );

          final separador = acento.withValues(alpha: .65);
          if (!columnas) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var indice = 0; indice < datos.length; indice++) ...[
                  if (indice > 0)
                    Divider(height: 7, thickness: .8, color: separador),
                  campo(indice),
                ],
              ],
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Center(
                  child: FractionallySizedBox(
                    heightFactor: .94,
                    child: SizedBox(
                      width: .8,
                      child: ColoredBox(color: separador),
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var indice = 0; indice < datos.length; indice++)
                    Expanded(child: campo(indice)),
                ],
              ),
            ],
          );
        },
      ),
    ),
  );
}

/// Trazos impresos sobre el papel, independientes del reflejo metálico.
class _GrabadoDeCampo extends CustomPainter {
  const _GrabadoDeCampo(this.acento, {required this.conContornos});

  final Color acento;
  final bool conContornos;

  @override
  void paint(Canvas canvas, Size size) {
    final caja = (Offset.zero & size).deflate(4);
    if (caja.isEmpty) return;
    const corte = 6.0;
    final borde = Path()
      ..moveTo(caja.left + corte, caja.top)
      ..lineTo(caja.right - corte, caja.top)
      ..lineTo(caja.right, caja.top + corte)
      ..lineTo(caja.right, caja.bottom - corte)
      ..lineTo(caja.right - corte, caja.bottom)
      ..lineTo(caja.left + corte, caja.bottom)
      ..lineTo(caja.left, caja.bottom - corte)
      ..lineTo(caja.left, caja.top + corte)
      ..close();
    final trazo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85
      ..color = acento.withValues(alpha: .72);
    canvas.drawPath(borde, trazo);
    if (!conContornos) return;

    canvas.save();
    canvas.clipPath(borde);
    trazo.color = acento.withValues(alpha: .48);
    final escala = caja.width / 195;
    canvas.translate(caja.right, caja.top);
    canvas.scale(escala);
    _contornos(canvas, trazo);
    canvas.restore();

    canvas.save();
    canvas.clipPath(borde);
    canvas.translate(caja.left, caja.bottom);
    canvas.scale(-escala);
    _contornos(canvas, trazo);
    canvas.restore();
  }

  void _contornos(Canvas canvas, Paint trazo) {
    final linea = Path()
      ..moveTo(-92, -12)
      ..cubicTo(-82, 6, -69, 2, -62, 18)
      ..cubicTo(-55, 36, -63, 35, -43, 41)
      ..cubicTo(-28, 45, -34, 53, -17, 61)
      ..quadraticBezierTo(-7, 69, 13, 73);
    for (var indice = 0; indice < 6; indice++) {
      canvas.drawPath(linea.shift(Offset(indice * 8, indice * -7)), trazo);
    }
  }

  @override
  bool shouldRepaint(covariant _GrabadoDeCampo anterior) =>
      anterior.acento != acento || anterior.conContornos != conContornos;
}
