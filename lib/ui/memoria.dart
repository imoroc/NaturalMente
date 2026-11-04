import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/memoria.dart';
import 'package:naturalmente/reglas/memoria.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/dibujos_nuevos_juegos.dart';
import 'package:naturalmente/ui/dibujos_plantas.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/juego_propio.dart';
import 'package:naturalmente/ui/planta.dart';
import 'package:naturalmente/ui/texto.dart';

const _partesPlanta = {'raiz', 'tallo', 'hoja', 'flor', 'fruto'};

/// Iconos de las cartas que solo llevan texto.
const _iconosCarta = <String, (IconData, Color)>{
  'agua': (Icons.water_drop_rounded, Color(0xFF0284C7)),
  'sol': (Icons.wb_sunny_rounded, Color(0xFFF59E0B)),
  'semillas': (Icons.grain_rounded, Color(0xFF92400E)),
  'polen': (Icons.local_florist_rounded, Color(0xFFDB2777)),
  'otono': (Icons.eco_rounded, Color(0xFFEA580C)),
  'savia': (Icons.swap_vert_rounded, Color(0xFF16A34A)),
  'bellota': (Icons.park_rounded, Color(0xFF15803D)),
  'harina': (Icons.bakery_dining_rounded, Color(0xFFB45309)),
  'campo': (Icons.grass_rounded, Color(0xFF65A30D)),
  'fotosintesis': (Icons.light_mode_rounded, Color(0xFF16A34A)),
  'sales': (Icons.science_rounded, Color(0xFF7C3AED)),
};

/// Dibujo de una carta: una parte de la planta, una planta, un dibujo de los
/// juegos nuevos o, si no tiene, su icono.
class DibujoCartaMemoria extends StatelessWidget {
  const DibujoCartaMemoria({required this.carta, this.tamano = 56, super.key});

  final CartaMemoria carta;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final id = carta.dibujo;
    if (_partesPlanta.contains(id)) return IconoParte(id: id, size: tamano);
    if (plantasEntorno.contains(id)) {
      return DibujoPlanta(id: id, tamano: tamano);
    }
    if (esDibujoNuevoJuego(id)) {
      return DibujoNuevoJuego(id: id, tamano: tamano);
    }
    final icono = _iconosCarta[carta.icono];
    if (icono == null) return SizedBox.square(dimension: tamano);
    return SizedBox.square(
      dimension: tamano,
      child: Icon(icono.$1, size: tamano * .8, color: icono.$2),
    );
  }
}

class MemoriaPage extends StatefulWidget {
  const MemoriaPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<MemoriaPage> createState() => _MemoriaPageState();
}

class _MemoriaPageState extends State<MemoriaPage>
    with FeedbackAcierto<MemoriaPage>, JuegoPropio<MemoriaPage> {
  PartidaMemoria? _partida;
  List<String> _orden = const [];

  Memoria get _memoria => widget.actividad.memoria!;

  @override
  Actividad get actividad => widget.actividad;

  @override
  String get volverA => 'Volver a El invernadero';

  @override
  List<NivelJuegoPropio> get nivelesJuego => [
    for (final nivel in _memoria.niveles)
      NivelJuegoPropio(
        id: nivel.id,
        nombre: nivel.nombre,
        curso: nivel.curso,
        resumen: nivel.resumen,
        curiosidad: nivel.curiosidad,
        muestras: [
          for (final pareja in nivel.parejas.take(2))
            DibujoCartaMemoria(carta: pareja.a, tamano: 38),
        ],
      ),
  ];

  @override
  String? get nivelActual => _partida?.nivel.id;

  @override
  bool get partidaCompleta => _partida?.completa ?? false;

  @override
  void iniciarPartida(String nivelId) {
    final nivel = _memoria.niveles.firstWhere((n) => n.id == nivelId);
    _partida = PartidaMemoria(nivel: nivel);
    _orden = BarajadorOpciones.barajarIds(
      clave: 'memoria-${nivel.id}',
      ids: nivel.cartas,
    );
  }

  @override
  void quitarPartida() => _partida = null;

  void _tocar(String cartaId) {
    final partida = _partida!;
    final estabaCompleta = partida.completa;
    if (estabaCompleta) return;
    late bool evaluada;
    setState(() => evaluada = partida.tocar(cartaId));
    if (evaluada) {
      registrarJugada(
        acierto: partida.resultado!.acierto,
        estabaCompleta: estabaCompleta,
      );
    } else {
      context.sonidoToque();
    }
  }

  @override
  Widget build(BuildContext context) => construirPagina(context);

  @override
  Widget construirJuego(BuildContext context, double ancho) {
    final partida = _partida!;
    final nivel = partida.nivel;
    final columnas = ancho >= 560 ? 4 : 3;
    final textoGrande = MediaQuery.textScalerOf(context).scale(14) > 18;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          'Parejas encontradas: ${partida.parejasEncontradas} de ${nivel.parejas.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          key: const Key('memoria-progreso'),
          value: partida.progreso,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          semanticsLabel: context.traducir('Progreso de la memoria'),
        ),
        const SizedBox(height: 12),
        // Natu habla encima de las cartas para que se lea sin bajar.
        Semantics(
          liveRegion: true,
          child: Burbuja(
            quien: actividad.quien,
            frase: partida.resultado?.frase ?? nivel.intro,
            gesto: partida.resultado?.gesto ?? 'hola',
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: textoGrande ? math.max(2, columnas - 1) : columnas,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: textoGrande ? .62 : .78,
          children: [
            for (final cartaId in _orden)
              _Carta(
                key: ValueKey(cartaId),
                cartaId: cartaId,
                carta: nivel.carta(cartaId),
                visible: partida.visible(cartaId),
                encontrada: partida.encontrada(nivel.pareja(cartaId).id),
                fallo:
                    partida.abiertas.length == 2 &&
                    partida.abiertas.contains(cartaId),
                onTap: () => _tocar(cartaId),
              ),
          ],
        ),
      ],
    );
  }
}

class _Carta extends StatelessWidget {
  const _Carta({
    required this.cartaId,
    required this.carta,
    required this.visible,
    required this.encontrada,
    required this.fallo,
    required this.onTap,
    super.key,
  });

  final String cartaId;
  final CartaMemoria carta;
  final bool visible;
  final bool encontrada;
  final bool fallo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rapido = MediaQuery.disableAnimationsOf(context);
    final borde = encontrada
        ? EstilosJuego.acierto
        : fallo
        ? EstilosJuego.fallo
        : const Color(0xFF16A34A);
    final cara = Container(
      key: ValueKey('cara-$cartaId-$visible'),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: encontrada ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borde, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => Center(
                child: DibujoCartaMemoria(
                  carta: carta,
                  tamano: math.min(c.maxWidth, c.maxHeight) * .9,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Texto(
            carta.texto,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
    final dorso = Container(
      key: ValueKey('dorso-$cartaId'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ADE80), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0xFF166534), offset: Offset(0, 3)),
        ],
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, color: Colors.white, size: 34),
      ),
    );
    return Semantics(
      button: true,
      label: visible
          ? context.traducir(carta.texto)
          : context.traducir('Carta boca abajo'),
      child: GestureDetector(
        key: Key('carta-$cartaId'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: rapido ? 0 : 280),
          transitionBuilder: (child, animacion) => ScaleTransition(
            scale: Tween<double>(begin: .85, end: 1).animate(animacion),
            child: FadeTransition(opacity: animacion, child: child),
          ),
          child: visible ? cara : dorso,
        ),
      ),
    );
  }
}
