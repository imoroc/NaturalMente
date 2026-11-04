import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/modelo/adivinanza.dart';
import 'package:naturalmente/reglas/adivinanza.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos_nuevos_juegos.dart';
import 'package:naturalmente/ui/estilos_juego.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/juego_propio.dart';
import 'package:naturalmente/ui/texto.dart';

class AdivinanzaPage extends StatefulWidget {
  const AdivinanzaPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<AdivinanzaPage> createState() => _AdivinanzaPageState();
}

class _AdivinanzaPageState extends State<AdivinanzaPage>
    with FeedbackAcierto<AdivinanzaPage>, JuegoPropio<AdivinanzaPage> {
  PartidaAdivinanza? _partida;
  final Map<String, List<String>> _opciones = {};

  Adivinanza get _adivinanza => widget.actividad.adivinanza!;

  @override
  Actividad get actividad => widget.actividad;

  @override
  String get volverA => 'Volver a La reserva';

  @override
  List<NivelJuegoPropio> get nivelesJuego => [
    for (final nivel in _adivinanza.niveles)
      NivelJuegoPropio(
        id: nivel.id,
        nombre: nivel.nombre,
        curso: nivel.curso,
        resumen: nivel.resumen,
        curiosidad: nivel.curiosidad,
        muestras: [
          for (final ronda in nivel.rondas.take(2))
            DibujoNuevoJuego(
              id: _adivinanza.animal(ronda.respuesta).dibujo,
              tamano: 38,
            ),
        ],
      ),
  ];

  @override
  String? get nivelActual => _partida?.nivel.id;

  @override
  bool get partidaCompleta => _partida?.completa ?? false;

  @override
  void iniciarPartida(String nivelId) {
    final nivel = _adivinanza.niveles.firstWhere((n) => n.id == nivelId);
    _partida = PartidaAdivinanza(adivinanza: _adivinanza, nivel: nivel);
    _opciones
      ..clear()
      ..addAll({
        for (final ronda in nivel.rondas)
          ronda.id: BarajadorOpciones.barajarConRespuesta<String>(
            clave: 'adivina-${ronda.id}',
            opciones: ronda.opciones,
            idDe: (id) => id,
            respuestaCorrecta: ronda.respuesta,
          ),
      });
  }

  @override
  void quitarPartida() => _partida = null;

  void _adivinar(String animalId) {
    final partida = _partida!;
    final estabaCompleta = partida.completa;
    if (estabaCompleta || partida.descartado(animalId)) return;
    setState(() => partida.adivinar(animalId));
    registrarJugada(
      acierto: partida.resultado!.acierto,
      estabaCompleta: estabaCompleta,
    );
  }

  void _otraPista() {
    final partida = _partida!;
    if (!partida.quedanPistas) return;
    context.sonidoToque();
    setState(partida.otraPista);
    usarAyuda();
  }

  @override
  Widget build(BuildContext context) => construirPagina(context);

  @override
  Widget construirJuego(BuildContext context, double ancho) {
    final partida = _partida!;
    final nivel = partida.nivel;
    final ronda = partida.ronda;
    final columnas = ancho >= 560 ? 3 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Texto(
          ronda == null
              ? 'Animales adivinados: ${nivel.rondas.length} de ${nivel.rondas.length}'
              : 'Animal ${partida.indiceRonda + 1} de ${nivel.rondas.length}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          key: const Key('adivinanza-progreso'),
          value: partida.progreso,
          minHeight: 10,
          borderRadius: BorderRadius.circular(10),
          semanticsLabel: context.traducir('Progreso de ¿Quién soy?'),
        ),
        const SizedBox(height: 12),
        if (ronda != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF4ADE80), width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.help_rounded, color: Color(0xFF15803D)),
                    SizedBox(width: 6),
                    Texto(
                      '¿Quién soy?',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < partida.pistasVistas; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF16A34A),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Texto(
                            ronda.pistas[i],
                            key: Key('pista-${ronda.id}-$i'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF14532D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  key: const Key('otra-pista'),
                  onPressed: partida.quedanPistas ? _otraPista : null,
                  icon: const Icon(Icons.lightbulb_rounded),
                  label: Texto(
                    'Otra pista (${partida.pistasVistas} de ${ronda.pistas.length})',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: columnas,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            children: [
              for (final id in _opciones[ronda.id] ?? ronda.opciones)
                _OpcionAnimal(
                  animal: _adivinanza.animal(id),
                  descartado: partida.descartado(id),
                  fallo:
                      partida.resultado?.acierto == false &&
                      partida.ultimaEleccion == id,
                  onTap: () => _adivinar(id),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Burbuja(
            quien: actividad.quien,
            frase: partida.resultado?.frase ?? nivel.intro,
            gesto: partida.resultado?.gesto ?? 'hola',
          ),
        ),
      ],
    );
  }
}

class _OpcionAnimal extends StatelessWidget {
  const _OpcionAnimal({
    required this.animal,
    required this.descartado,
    required this.fallo,
    required this.onTap,
  });

  final AnimalAdivinanza animal;
  final bool descartado;
  final bool fallo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: descartado && !fallo ? .4 : 1,
      child: Semantics(
        button: true,
        label: context.traducir(animal.nombre),
        child: TarjetaJuego(
          claveAccion: Key('adivina-${animal.id}'),
          onTap: descartado ? null : onTap,
          borde: fallo ? EstilosJuego.fallo : const Color(0xFF86EFAC),
          fondo: descartado ? const Color(0xFFF1F5F9) : Colors.white,
          destacada: fallo,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) => Center(
                      child: DibujoNuevoJuego(
                        id: animal.dibujo,
                        tamano: (c.maxHeight * .95).clamp(40, 120),
                      ),
                    ),
                  ),
                ),
                Texto(
                  animal.nombre,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
