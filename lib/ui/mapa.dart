import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/expedicion_diaria.dart';
import 'package:naturalmente/ui/selector_idioma.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';
import 'package:naturalmente/ui/zona.dart';
import 'package:naturalmente/ui/cromos_zona.dart';

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final colores = context.coloresNaturales;

    return Scaffold(
      backgroundColor: colores.oscuro ? colores.fondo : const Color(0xFFFAF5EC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, espacio) => ListenableBuilder(
            listenable: progreso,
            builder: (context, _) {
              void abrir(Widget destino) {
                context.sonidoToque();
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => destino));
              }

              final cromos = _AccesoSecundario(
                key: const Key('tarjeta-album-principal'),
                titulo: 'Mis cromos',
                fondo: const Color(0xFFEDF2DE),
                borde: const Color(0xFFF59E0B),
                dibujo: const _IlustracionInicio(
                  'cromos',
                  ancho: 112,
                  alto: 76,
                ),
                onTap: () => abrir(const AlbumPage()),
              );
              final armario = _AccesoSecundario(
                key: const Key('abrir-armario-natu'),
                titulo: 'Vestir a Natu',
                fondo: const Color(0xFFFFEDD4),
                borde: const Color(0xFF40BE70),
                dibujo: const _IlustracionInicio(
                  'armario',
                  ancho: 120,
                  alto: 76,
                ),
                onTap: () {
                  context.sonidoToque();
                  mostrarArmarioNatu(context);
                },
              );
              final diasRacha = progreso.rachaActiva();
              final marca = Row(
                children: [
                  ExcludeSemantics(
                    child:
                        progreso.tienePosePersonalizada ||
                            progreso.trajeEquipado != 'ninguno'
                        ? DibujoMascota(
                            gesto: progreso.poseEquipada,
                            tamano: 58,
                          )
                        : const _IlustracionInicio('natu', ancho: 58, alto: 58),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Texto(
                      'NaturalMente',
                      style: TextStyle(
                        color: colores.tinta,
                        fontFamily: 'NunitoInicio',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              );
              final textoGrande =
                  MediaQuery.textScalerOf(context).scale(16) > 24;
              final compacto = espacio.maxWidth <= 360;
              final espacioTitulo = compacto ? 15.0 : 23.0;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      compacto ? 12 : 18,
                      10,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(child: marca),
                            const SizedBox(width: 8),
                            _AccesoRacha(
                              dias: diasRacha,
                              onTap: () => abrir(const ExpedicionDiariaPage()),
                            ),
                          ],
                        ),
                        SizedBox(height: espacioTitulo),
                        Semantics(
                          header: true,
                          child: Texto(
                            '¿A qué jugamos?',
                            style: TextStyle(
                              color: colores.tinta,
                              fontFamily: 'NunitoInicio',
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                        ),
                        SizedBox(height: espacioTitulo),
                        for (final zona in alcance.catalogo.zonas) ...[
                          _TarjetaMundo(
                            zona: zona,
                            compacto: compacto,
                            onTap: () => abrir(ZonaPage(zona: zona)),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(height: compacto ? 16 : 22),
                        _AccesoInicio(
                          key: const Key('abrir-expedicion-diaria'),
                          fondo: colores.tarjeta,
                          borde: colores.borde(const Color(0xFFF29026)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          onTap: () => abrir(const ExpedicionDiariaPage()),
                          child: Row(
                            children: [
                              const _IlustracionInicio(
                                'reto',
                                ancho: 76,
                                alto: 54,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _TextoAcceso(
                                  titulo: 'Reto de hoy',
                                  descripcion: progreso.expedicionHoyHecha()
                                      ? 'Completado por hoy'
                                      : null,
                                ),
                              ),
                              const _FlechaInicio(tono: Color(0xFFEAF0D8)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        LayoutBuilder(
                          builder: (context, medidas) {
                            if (medidas.maxWidth < 280 || textoGrande) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  cromos,
                                  const SizedBox(height: 10),
                                  armario,
                                ],
                              );
                            }
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: cromos),
                                  const SizedBox(width: 10),
                                  Expanded(child: armario),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Align(child: SelectorIdioma()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AccesoRacha extends StatelessWidget {
  const _AccesoRacha({required this.dias, required this.onTap});

  final int dias;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Tooltip(
      message: context.tr(dias == 1 ? 'Racha: 1 día' : 'Racha: $dias días'),
      child: _AccesoInicio(
        key: const Key('abrir-racha-inicio'),
        fondo: colores.superficie(const Color(0xFFFFEBD2)),
        borde: colores.borde(const Color(0xFFEA9C42)),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        onTap: onTap,
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _IlustracionInicio('racha', ancho: 27, alto: 32),
              const SizedBox(width: 4),
              Text(
                '$dias',
                style: TextStyle(
                  color: colores.tinta,
                  fontFamily: 'NunitoInicio',
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaMundo extends StatelessWidget {
  const _TarjetaMundo({
    required this.zona,
    required this.onTap,
    required this.compacto,
  });

  final Zona zona;
  final bool compacto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final (
      titulo,
      descripcion,
      dibujo,
      fondo,
      borde,
      sombra,
    ) = switch (zona.id) {
      'reserva' => (
        'Animales',
        'Conoce a los animales',
        const _IlustracionInicio('animales', ancho: 77, alto: 76),
        const Color(0xFFE1ECCD),
        const Color(0xFF2ECC71),
        const Color(0xFF239E56),
      ),
      'invernadero' => (
        'Plantas',
        'Mira cómo crecen',
        const _IlustracionInicio('plantas', ancho: 78, alto: 74),
        const Color(0xFFFFE4C1),
        const Color(0xFFFF9F1C),
        const Color(0xFFD97706),
      ),
      'cuerpo' => (
        'Mi cuerpo',
        'Descubre tu cuerpo',
        const _IlustracionInicio('cuerpo', ancho: 78, alto: 82),
        const Color(0xFFC7E7F4),
        const Color(0xFF38BDF8),
        const Color(0xFF0284C7),
      ),
      _ => (
        zona.nombre,
        zona.resumen,
        InsigniaIlustradaZona(id: zona.id),
        const Color(0xFFF6F1E6),
        const Color(0xFFD6CFC0),
        const Color(0xFFB8B0A0),
      ),
    };

    return _AccesoInicio(
      key: Key('zona-${zona.id}'),
      fondo: colores.superficie(fondo),
      borde: colores.borde(borde),
      sombra: colores.sombra(sombra),
      onTap: onTap,
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: compacto ? 84 : 94,
              height: compacto ? 84 : 94,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colores.superficie(const Color(0xFFFFF8E9)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: dibujo,
            ),
          ),
          SizedBox(width: compacto ? 10 : 14),
          Expanded(
            child: _TextoAcceso(
              titulo: titulo,
              descripcion: descripcion,
              tamano: 26,
            ),
          ),
          const SizedBox(width: 6),
          const _FlechaInicio(),
        ],
      ),
    );
  }
}

class _AccesoSecundario extends StatelessWidget {
  const _AccesoSecundario({
    required this.titulo,
    required this.fondo,
    required this.borde,
    required this.dibujo,
    required this.onTap,
    super.key,
  });

  final String titulo;
  final Color fondo;
  final Color borde;
  final Widget dibujo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return _AccesoInicio(
      fondo: colores.superficie(fondo),
      borde: colores.borde(borde),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 76,
            child: Center(child: ExcludeSemantics(child: dibujo)),
          ),
          const SizedBox(height: 6),
          Texto(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colores.tinta,
              fontFamily: 'NunitoInicio',
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccesoInicio extends StatefulWidget {
  const _AccesoInicio({
    required this.fondo,
    required this.borde,
    required this.onTap,
    required this.child,
    this.sombra,
    this.padding = const EdgeInsets.all(11),
    super.key,
  });

  final Color fondo;
  final Color borde;
  final Color? sombra;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_AccesoInicio> createState() => _AccesoInicioState();
}

class _AccesoInicioState extends State<_AccesoInicio> {
  int? _puntero;
  Offset _origen = Offset.zero;

  void _iniciarPresion(PointerDownEvent evento) {
    if (_puntero != null || evento.buttons != kPrimaryButton) return;
    _origen = evento.position;
    setState(() => _puntero = evento.pointer);
  }

  void _terminarPresion(PointerEvent evento) {
    if (evento.pointer == _puntero) setState(() => _puntero = null);
  }

  void _moverPuntero(PointerMoveEvent evento) {
    if ((evento.position - _origen).distanceSquared > kTouchSlop * kTouchSlop) {
      _terminarPresion(evento);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sombra = widget.sombra;
    final radio = BorderRadius.circular(sombra == null ? 20 : 24);
    final recorrido = sombra == null ? 3.0 : 4.0;
    final movimientoReducido = MediaQuery.disableAnimationsOf(context);
    final pulsado = _puntero != null;
    final base =
        sombra ?? Color.alphaBlend(const Color(0x40000000), widget.borde);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          top: recorrido,
          child: DecoratedBox(
            decoration: BoxDecoration(color: base, borderRadius: radio),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: recorrido),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: pulsado && !movimientoReducido ? recorrido : 0),
            duration: movimientoReducido
                ? Duration.zero
                : Duration(milliseconds: pulsado ? 55 : 105),
            curve: Curves.easeOut,
            builder: (context, desplazamiento, child) => Transform.translate(
              offset: Offset(0, movimientoReducido ? 0 : desplazamiento),
              transformHitTests: false,
              child: child,
            ),
            child: Material(
              color: widget.fondo,
              shape: RoundedRectangleBorder(
                borderRadius: radio,
                side: BorderSide(
                  color: widget.borde,
                  width: sombra == null ? 1.5 : 2.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Semantics(
                button: true,
                child: Listener(
                  onPointerDown: _iniciarPresion,
                  onPointerMove: _moverPuntero,
                  onPointerUp: _terminarPresion,
                  onPointerCancel: _terminarPresion,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Padding(
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextoAcceso extends StatelessWidget {
  const _TextoAcceso({
    required this.titulo,
    this.descripcion,
    this.tamano = 23,
  });

  final String titulo;
  final String? descripcion;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Texto(
          titulo,
          style: TextStyle(
            color: colores.tinta,
            fontFamily: 'NunitoInicio',
            fontSize: tamano,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (descripcion case final frase?) ...[
          const SizedBox(height: 3),
          Texto(
            frase,
            style: TextStyle(
              color: colores.tenue,
              fontFamily: 'NunitoInicio',
              fontSize: 16,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _FlechaInicio extends StatelessWidget {
  const _FlechaInicio({this.tono = const Color(0xFFFFF8E9)});

  final Color tono;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.superficie(tono),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: colores.tinta,
          size: 18,
        ),
      ),
    );
  }
}

class _IlustracionInicio extends StatelessWidget {
  const _IlustracionInicio(
    this.nombre, {
    required this.ancho,
    required this.alto,
  });

  final String nombre;
  final double ancho;
  final double alto;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/inicio/$nombre.webp',
    width: ancho,
    height: alto,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}
