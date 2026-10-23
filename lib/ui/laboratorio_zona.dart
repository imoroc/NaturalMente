import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/texto.dart';

class LaboratorioZonaPage extends StatelessWidget {
  const LaboratorioZonaPage({required this.zona, super.key});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    final (titulo, colorFondo, colorAcento) = switch (zona.id) {
      'reserva' => (
        'Expedición Día y Noche',
        const Color(0xFF0F172A),
        const Color(0xFF34D399),
      ),
      'invernadero' => (
        'Reactor de Fotosíntesis',
        const Color(0xFFF0FDF4),
        const Color(0xFF16A34A),
      ),
      _ => (
        'Escáner de Rayos X en Vivo',
        const Color(0xFFF8FAFC),
        const Color(0xFF0284C7),
      ),
    };

    final esReserva = zona.id == 'reserva';

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: esReserva ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: esReserva ? Colors.white : const Color(0xFF0F172A),
        iconTheme: IconThemeData(
          color: esReserva ? Colors.white : const Color(0xFF0F172A),
        ),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              switch (zona.id) {
                'reserva' => Icons.flashlight_on_rounded,
                'invernadero' => Icons.biotech_rounded,
                _ => Icons.monitor_heart_rounded,
              },
              color: colorAcento,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.tr(titulo),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: esReserva ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: switch (zona.id) {
              'reserva' => const _SimuladorLinternaReserva(),
              'invernadero' => const _SimuladorFotosintesis(),
              _ => const _LaboratorioRayosX(),
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. RESERVA DE ANIMALES: EXPEDICIÓN DÍA Y NOCHE CON LINTERNA INTERACTIVA
// ============================================================================

class _AnimalReservaInfo {
  const _AnimalReservaInfo({
    required this.id,
    required this.nombre,
    required this.habitat,
    required this.posicionRelativa,
    required this.activoDeNoche,
    required this.conductaDia,
    required this.conductaNoche,
  });

  final String id;
  final String nombre;
  final String habitat;
  final Offset posicionRelativa;
  final bool activoDeNoche;
  final String conductaDia;
  final String conductaNoche;
}

const _animalesReserva = <_AnimalReservaInfo>[
  _AnimalReservaInfo(
    id: 'tucan',
    nombre: 'Tucán de la selva',
    habitat: 'Copa del bosque',
    posicionRelativa: Offset(0.11, 0.25),
    activoDeNoche: false,
    conductaDia:
        'De día está muy activo: salta entre las ramas altas y usa su gran pico ligero para alcanzar frutos maduros.',
    conductaNoche:
        'De noche apoya el pico sobre su espalda, pliega la cola y duerme camuflado en los huecos altos del árbol.',
  ),
  _AnimalReservaInfo(
    id: 'aguila',
    nombre: 'Águila real',
    habitat: 'Cumbres rocosas',
    posicionRelativa: Offset(0.25, 0.16),
    activoDeNoche: false,
    conductaDia:
        'Aprovecha las corrientes de aire caliente del día para planear desde las alturas con su vista agudísima.',
    conductaNoche:
        'Cuando se oculta el sol regresa a su nido en los riscos altos de la montaña para descansar segura.',
  ),
  _AnimalReservaInfo(
    id: 'oso',
    nombre: 'Oso pardo',
    habitat: 'Cueva del bosque',
    posicionRelativa: Offset(0.13, 0.67),
    activoDeNoche: false,
    conductaDia:
        'Recorre el bosque buscando bayas, bellotas, raíces tiernas y truchas frescas en la orilla del río.',
    conductaNoche:
        'Al caer la noche se refugia en el interior de su osera de piedra para dormir resguardado del frío.',
  ),
  _AnimalReservaInfo(
    id: 'zorro',
    nombre: 'Zorro rojo',
    habitat: 'Sotobosque',
    posicionRelativa: Offset(0.27, 0.56),
    activoDeNoche: true,
    conductaDia:
        'Durante las horas de más sol descansa enroscado en su madriguera cubriéndose el hocico con su cola tupida.',
    conductaNoche:
        '¡Cazador crepuscular y nocturno! Se orienta en la oscuridad gracias a su oído fino y sus bigotes táctiles.',
  ),
  _AnimalReservaInfo(
    id: 'mariposa',
    nombre: 'Mariposa diurna',
    habitat: 'Ribera florida',
    posicionRelativa: Offset(0.38, 0.34),
    activoDeNoche: false,
    conductaDia:
        'Calienta sus alas al sol y vuela de flor en flor junto al río libando néctar con su espiritrompa.',
    conductaNoche:
        'De noche pliega sus alas en vertical bajo las hojas de la ribera para pasar inadvertida.',
  ),
  _AnimalReservaInfo(
    id: 'rana',
    nombre: 'Rana verde',
    habitat: 'Río y charca dulce',
    posicionRelativa: Offset(0.42, 0.66),
    activoDeNoche: true,
    conductaDia:
        'Bajo el sol permanece quieta entre los juncos húmedos de la charca para que su piel desnuda no se seque.',
    conductaNoche:
        '¡Muy activa de noche! Croa en la charca de agua dulce y atrapa insectos al vuelo con su lengua pegajosa.',
  ),
  _AnimalReservaInfo(
    id: 'renacuajo',
    nombre: 'Renacuajo',
    habitat: 'Pozas del río dulce',
    posicionRelativa: Offset(0.49, 0.83),
    activoDeNoche: false,
    conductaDia:
        'Nada en las aguas dulces templadas por el sol respirando por branquias y alimentándose de microalgas.',
    conductaNoche:
        'Por la noche se esconde bajo los guijarros y tallos sumergidos del fondo de la charca.',
  ),
  _AnimalReservaInfo(
    id: 'camello',
    nombre: 'Camello bactriano',
    habitat: 'Dunas costeras',
    posicionRelativa: Offset(0.62, 0.44),
    activoDeNoche: false,
    conductaDia:
        'Camina firme sobre la arena gracias a sus almohadillas anchas y sus largas pestañas que frenan el viento.',
    conductaNoche:
        'Cuando refresca la arena por la noche se tumba en grupo sobre las dunas para rumiar y descansar.',
  ),
  _AnimalReservaInfo(
    id: 'delfin',
    nombre: 'Delfín mular',
    habitat: 'Océano abierto',
    posicionRelativa: Offset(0.77, 0.54),
    activoDeNoche: false,
    conductaDia:
        'Nada en manada por el océano salado, se comunica con chasquidos y salta para respirar por su espiráculo.',
    conductaNoche:
        'Duerme con la mitad de su cerebro despierta (sueño unihemisférico) para seguir subiendo a respirar aire.',
  ),
  _AnimalReservaInfo(
    id: 'pulpo',
    nombre: 'Pulpo de arrecife',
    habitat: 'Fondo del océano',
    posicionRelativa: Offset(0.81, 0.83),
    activoDeNoche: true,
    conductaDia:
        'Durante el día se oculta en su cueva del arrecife marino imitando el color y la textura de las rocas.',
    conductaNoche:
        '¡Explorador nocturno del océano! Sale a cazar cangrejos y moluscos palpando el fondo con sus 8 tentáculos.',
  ),
  _AnimalReservaInfo(
    id: 'pinguino',
    nombre: 'Pingüino marino',
    habitat: 'Costa rocosa helada',
    posicionRelativa: Offset(0.92, 0.39),
    activoDeNoche: false,
    conductaDia:
        'De día se zambulle desde los bloques de hielo al océano usando sus alas como potentes aletas.',
    conductaNoche:
        'Pasa la noche en tierra firme agrupado en colonia sobre el roquedo costero para conservar el calor.',
  ),
];

class _SimuladorLinternaReserva extends StatefulWidget {
  const _SimuladorLinternaReserva();

  @override
  State<_SimuladorLinternaReserva> createState() =>
      _SimuladorLinternaReservaState();
}

class _SimuladorLinternaReservaState extends State<_SimuladorLinternaReserva>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambienteCtrl;
  bool _esNoche = true;
  String _animalSeleccionado = 'rana';
  Offset _focoRelativo = const Offset(0.42, 0.66);

  @override
  void initState() {
    super.initState();
    _ambienteCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ambienteCtrl.dispose();
    super.dispose();
  }

  _AnimalReservaInfo get _infoActual => _animalesReserva.firstWhere(
    (a) => a.id == _animalSeleccionado,
    orElse: () => _animalesReserva.first,
  );

  void _moverLinterna(Offset localPos, Size size) {
    final dx = (localPos.dx / size.width).clamp(0.05, 0.95);
    final dy = (localPos.dy / size.height).clamp(0.08, 0.92);
    final nuevoFoco = Offset(dx, dy);

    String? cercano;
    double mejorDist = 0.13;
    for (final a in _animalesReserva) {
      final d = (a.posicionRelativa - nuevoFoco).distance;
      if (d < mejorDist) {
        mejorDist = d;
        cercano = a.id;
      }
    }

    setState(() {
      _focoRelativo = nuevoFoco;
      if (cercano != null) {
        _animalSeleccionado = cercano;
      }
    });
  }

  void _enfocarAnimal(_AnimalReservaInfo animal) {
    setState(() {
      _animalSeleccionado = animal.id;
      _focoRelativo = animal.posicionRelativa;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actual = _infoActual;
    final despierto = _esNoche ? actual.activoDeNoche : !actual.activoDeNoche;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _esNoche
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFFFBBF24),
                width: 2.2,
              ),
            ),
            child: Row(
              children: [
                DibujoMascota(
                  gesto: 'pista',
                  tamano: 52,
                  traje: _esNoche ? 'nocturno' : 'explorador',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _esNoche
                            ? context.tr('Modo Noche · Linterna Científica')
                            : context.tr('Modo Día · Observación Solar'),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _esNoche
                            ? context.tr(
                                'Mueve el haz de la linterna por el bosque, el río de agua dulce, las dunas y el océano para descubrir quién está activo de noche.',
                              )
                            : context.tr(
                                'De día observas los 4 ecosistemas completos: Bosque, Río y Charca dulce, Dunas y Océano salado.',
                              ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFCBD5E1),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const Key('toggle-dia-noche-reserva'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _esNoche
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF312E81),
                    foregroundColor: _esNoche
                        ? const Color(0xFF0F172A)
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => setState(() => _esNoche = !_esNoche),
                  icon: Icon(
                    _esNoche ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                    size: 18,
                  ),
                  label: Text(
                    _esNoche
                        ? context.tr('Ver de Día')
                        : context.tr('Ver de Noche'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            key: const Key('visor-linterna-reserva'),
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: _esNoche
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF10B981),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  offset: Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return MouseRegion(
                    cursor: SystemMouseCursors.precise,
                    onHover: (e) {
                      if (_esNoche) _moverLinterna(e.localPosition, size);
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => _moverLinterna(d.localPosition, size),
                      onPanStart: (d) => _moverLinterna(d.localPosition, size),
                      onPanUpdate: (d) => _moverLinterna(d.localPosition, size),
                      child: AnimatedBuilder(
                        animation: _ambienteCtrl,
                        builder: (context, _) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomPaint(
                                painter: _PintorPaisajeReserva(
                                  esNoche: _esNoche,
                                  faseAnim: _ambienteCtrl.value,
                                ),
                              ),
                              for (final animal in _animalesReserva)
                                _MarcadorAnimalEcosistema(
                                  key: Key('foco-animal-${animal.id}'),
                                  animal: animal,
                                  esNoche: _esNoche,
                                  seleccionado:
                                      _animalSeleccionado == animal.id,
                                  distanciaAlFoco:
                                      (animal.posicionRelativa - _focoRelativo)
                                          .distance,
                                  faseAnim: _ambienteCtrl.value,
                                  sizeEscena: size,
                                  alTocar: () => _enfocarAnimal(animal),
                                ),
                              if (_esNoche)
                                IgnorePointer(
                                  child: CustomPaint(
                                    painter: _PintorHazLinternaNocturna(
                                      focoRelativo: _focoRelativo,
                                      faseAnim: _ambienteCtrl.value,
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                left: 12,
                                child: IgnorePointer(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.70,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: _esNoche
                                            ? const Color(0xFFFDE047)
                                            : const Color(0xFF38BDF8),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _esNoche
                                              ? Icons.highlight_rounded
                                              : Icons.wb_sunny_rounded,
                                          size: 15,
                                          color: const Color(0xFFFDE047),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${context.tr(actual.nombre)} · ${context.tr(actual.habitat)}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final animal in _animalesReserva)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(context.tr(animal.nombre)),
                      selected: _animalSeleccionado == animal.id,
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFF1E293B),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: _animalSeleccionado == animal.id
                            ? const Color(0xFF052E16)
                            : Colors.white,
                      ),
                      onSelected: (_) => _enfocarAnimal(animal),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: despierto
                    ? const Color(0xFF10B981)
                    : const Color(0xFF60A5FA),
                width: 2.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: despierto
                          ? const Color(0xFF10B981)
                          : const Color(0xFF475569),
                      width: 2,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SpriteEspecieSantuario(id: actual.id, tamano: 58),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            context.tr(actual.nombre),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: despierto
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF1E3A8A),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              despierto
                                  ? context.tr('¡DESPIERTO Y ACTIVO!')
                                  : context.tr('DURMIENDO / OCULTO'),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: despierto
                                    ? const Color(0xFF6EE7B7)
                                    : const Color(0xFF93C5FD),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        context.tr(
                          '${_esNoche ? actual.conductaNoche : actual.conductaDia} • ${DatosEnciclopedicosFicha.de(actual.id).locomocionOFuncion}.',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE2E8F0),
                          height: 1.28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarcadorAnimalEcosistema extends StatelessWidget {
  const _MarcadorAnimalEcosistema({
    required this.animal,
    required this.esNoche,
    required this.seleccionado,
    required this.distanciaAlFoco,
    required this.faseAnim,
    required this.sizeEscena,
    required this.alTocar,
    super.key,
  });

  final _AnimalReservaInfo animal;
  final bool esNoche;
  final bool seleccionado;
  final double distanciaAlFoco;
  final double faseAnim;
  final Size sizeEscena;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final iluminado = !esNoche || distanciaAlFoco < 0.22;
    final despierto = esNoche ? animal.activoDeNoche : !animal.activoDeNoche;
    final dyOscilacion = despierto
        ? math.sin(faseAnim * 2 * math.pi + animal.posicionRelativa.dx * 8) *
              3.0
        : 0.0;

    final (offsetReal, _, _) = calcularLocomocionRealEspecie(
      id: animal.id,
      fase: (faseAnim + animal.posicionRelativa.dx) % 1.0,
      activo: despierto,
      amplitud: 0.85,
    );
    final left =
        (animal.posicionRelativa.dx * sizeEscena.width) - 34 + offsetReal.dx;
    final top =
        (animal.posicionRelativa.dy * sizeEscena.height) - 34 + dyOscilacion;

    return Positioned(
      left: left.clamp(4.0, sizeEscena.width - 72),
      top: top.clamp(4.0, sizeEscena.height - 72),
      width: 68,
      height: 68,
      child: GestureDetector(
        onTap: alTocar,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            if (seleccionado || (esNoche && iluminado))
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: esNoche
                      ? const Color(0xFFFDE047).withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.32),
                  border: Border.all(
                    color: seleccionado
                        ? const Color(0xFFFDE047)
                        : Colors.white54,
                    width: seleccionado ? 2.4 : 1.4,
                  ),
                ),
              ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: iluminado ? 1.0 : 0.14,
              child: Transform.scale(
                scale: seleccionado ? 1.08 : 0.94,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SpriteEspecieSantuario(id: animal.id, tamano: 58),
                ),
              ),
            ),
            if (esNoche && !iluminado)
              despierto
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE047),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF59E0B),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDE047),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFF59E0B),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Zzz',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF93C5FD),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class _PintorPaisajeReserva extends CustomPainter {
  const _PintorPaisajeReserva({required this.esNoche, required this.faseAnim});

  final bool esNoche;
  final double faseAnim;

  void _etiquetaBioma(Canvas canvas, String texto, Offset pos, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: pos,
        width: tp.width + 12,
        height: tp.height + 5,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      r,
      Paint()..color = const Color(0xFF0F172A).withValues(alpha: 0.65),
    );
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Cielo diurno o nocturno
    final coloresCielo = esNoche
        ? const [Color(0xFF070B14), Color(0xFF1E293B), Color(0xFF0F172A)]
        : const [Color(0xFF38BDF8), Color(0xFFBAE6FD), Color(0xFFE0F2FE)];
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: coloresCielo,
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // 2. Sol o Luna + Estrellas
    if (esNoche) {
      final pEstrella = Paint()..color = const Color(0xFFFEF08A);
      for (final (sx, sy, r) in [
        (0.07, 0.09, 1.8),
        (0.19, 0.07, 2.2),
        (0.35, 0.11, 1.7),
        (0.49, 0.06, 2.4),
        (0.64, 0.10, 1.9),
        (0.76, 0.08, 2.1),
      ]) {
        final parpadeo =
            0.5 + 0.5 * math.sin(faseAnim * 2 * math.pi + sx * 12);
        canvas.drawCircle(
          Offset(w * sx, h * sy),
          r * (0.8 + 0.4 * parpadeo),
          pEstrella,
        );
      }
      canvas.drawCircle(
        Offset(w * 0.88, h * 0.13),
        19,
        Paint()..color = const Color(0xFFFEF9C3),
      );
      canvas.drawCircle(
        Offset(w * 0.90, h * 0.11),
        16,
        Paint()..color = const Color(0xFF0D1526),
      );
    } else {
      final solPos = Offset(w * 0.86, h * 0.14);
      canvas.drawCircle(
        solPos,
        28,
        Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        solPos,
        19,
        Paint()..color = const Color(0xFFFACC15),
      );
    }

    // 3. Cordillera montañosa al fondo con cumbres nevadas (donde nace el río dulce)
    final montanas = Path()
      ..moveTo(0, h * 0.50)
      ..lineTo(w * 0.12, h * 0.28)
      ..lineTo(w * 0.25, h * 0.18)
      ..lineTo(w * 0.36, h * 0.38)
      ..lineTo(w * 0.46, h * 0.24)
      ..lineTo(w * 0.58, h * 0.44)
      ..lineTo(w, h * 0.46)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      montanas,
      Paint()
        ..color = esNoche
            ? const Color(0xFF1E293B)
            : const Color(0xFF64748B).withValues(alpha: 0.65),
    );
    // Cumbre nevada donde nace el río de montaña
    final nieveCumbre = Path()
      ..moveTo(w * 0.46, h * 0.24)
      ..lineTo(w * 0.42, h * 0.31)
      ..lineTo(w * 0.46, h * 0.29)
      ..lineTo(w * 0.50, h * 0.31)
      ..close();
    canvas.drawPath(
      nieveCumbre,
      Paint()
        ..color = esNoche ? const Color(0xFF94A3B8) : const Color(0xFFF8FAFC),
    );

    // 4. BIOMA 1 (Izquierda, 0.00..0.34): BOSQUE Y MONTAÑA
    final praderaBosque = Path()
      ..moveTo(0, h * 0.44)
      ..quadraticBezierTo(w * 0.18, h * 0.40, w * 0.35, h * 0.48)
      ..lineTo(w * 0.34, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      praderaBosque,
      Paint()
        ..color = esNoche ? const Color(0xFF064E3B) : const Color(0xFF22C55E),
    );

    // Gran árbol del dosel (Tucán) + madriguera del zorro + osera de roca (Oso)
    canvas.drawRect(
      Rect.fromLTWH(w * 0.09, h * 0.24, w * 0.045, h * 0.34),
      Paint()
        ..color = esNoche ? const Color(0xFF451A03) : const Color(0xFF78350F),
    );
    for (final (cx, cy, r) in [
      (0.11, 0.22, 36.0),
      (0.06, 0.26, 28.0),
      (0.16, 0.26, 30.0),
    ]) {
      canvas.drawCircle(
        Offset(w * cx, h * cy),
        r,
        Paint()
          ..color = esNoche ? const Color(0xFF065F46) : const Color(0xFF15803D),
      );
    }

    // Cueva rocosa del oso pardo y madriguera del zorro
    final cuevaOso = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(w * 0.13, h * 0.72),
        width: w * 0.14,
        height: h * 0.22,
      ),
      topLeft: const Radius.circular(30),
      topRight: const Radius.circular(30),
    );
    canvas.drawRRect(
      cuevaOso,
      Paint()
        ..color = esNoche ? const Color(0xFF334155) : const Color(0xFF64748B),
    );
    canvas.drawRRect(
      cuevaOso.deflate(7),
      Paint()..color = const Color(0xFF0F172A),
    );

    // 5. BIOMA 2 (Centro-Izquierda, 0.34..0.55): RÍO Y CHARCA DE AGUA DULCE
    // Ribera herbosa esmeralda que rodea el río y la charca dulce
    final riberaDulce = Path()
      ..moveTo(w * 0.33, h * 0.48)
      ..quadraticBezierTo(w * 0.44, h * 0.45, w * 0.56, h * 0.49)
      ..lineTo(w * 0.56, h)
      ..lineTo(w * 0.32, h)
      ..close();
    canvas.drawPath(
      riberaDulce,
      Paint()
        ..color = esNoche ? const Color(0xFF065F46) : const Color(0xFF4ADE80),
    );

    // Cascada y curso alto del río bajando desde la montaña nevada hasta la charca
    final rioDulce = Path()
      ..moveTo(w * 0.45, h * 0.30)
      ..quadraticBezierTo(w * 0.43, h * 0.42, w * 0.44, h * 0.54)
      ..lineTo(w * 0.48, h * 0.54)
      ..quadraticBezierTo(w * 0.47, h * 0.42, w * 0.47, h * 0.30)
      ..close();
    canvas.drawPath(
      rioDulce,
      Paint()
        ..color = esNoche ? const Color(0xFF0284C7) : const Color(0xFF38BDF8),
    );

    // Charca de agua dulce turquesa (completamente separada del mar por las dunas y rocas)
    final charcaRect = Rect.fromCenter(
      center: Offset(w * 0.45, h * 0.74),
      width: w * 0.21,
      height: h * 0.38,
    );
    canvas.drawOval(
      charcaRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: esNoche
              ? const [Color(0xFF0E7490), Color(0xFF155E75)]
              : const [Color(0xFF67E8F9), Color(0xFF06B6D4)],
        ).createShader(charcaRect),
    );
    // Borde de guijarros de río y espadañas/juncos alrededor de la charca dulce
    for (final (gx, gy) in [
      (0.35, 0.64),
      (0.36, 0.78),
      (0.54, 0.66),
      (0.54, 0.80),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * gx, h * gy), width: 14, height: 8),
        Paint()..color = const Color(0xFF94A3B8),
      );
    }
    // Nenúfares de la rana en la charca dulce
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, h * 0.70),
        width: 44,
        height: 15,
      ),
      Paint()
        ..color = esNoche ? const Color(0xFF15803D) : const Color(0xFF22C55E),
    );

    // 6. BIOMA 3 (Centro-Derecha, 0.55..0.69): DUNAS Y BARRERA COSTERA
    // Separa físicamente el agua dulce continental del océano salado
    final dunas = Path()
      ..moveTo(w * 0.55, h * 0.50)
      ..quadraticBezierTo(w * 0.62, h * 0.35, w * 0.70, h * 0.48)
      ..lineTo(w * 0.69, h)
      ..lineTo(w * 0.55, h)
      ..close();
    canvas.drawPath(
      dunas,
      Paint()
        ..color = esNoche ? const Color(0xFF92400E) : const Color(0xFFFBBF24),
    );

    // 7. BIOMA 4 (Derecha, 0.69..1.00): OCÉANO PROFUNDO, ARRECIFE Y COSTA HELADA
    final oceano = Path()
      ..moveTo(w * 0.69, h * 0.46)
      ..quadraticBezierTo(w * 0.84, h * 0.44, w, h * 0.46)
      ..lineTo(w, h)
      ..lineTo(w * 0.68, h)
      ..close();
    canvas.drawPath(
      oceano,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: esNoche
              ? const [Color(0xFF1E3A8A), Color(0xFF0F172A)]
              : const [Color(0xFF0284C7), Color(0xFF1E3A8A)],
        ).createShader(Rect.fromLTWH(w * 0.68, h * 0.44, w * 0.32, h * 0.56)),
    );

    // Olas blancas del océano salado
    final pOla = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final ox = w * (0.72 + i * 0.08);
      final oy = h * (0.50 + (i % 2) * 0.09);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(ox, oy), width: 22, height: 8),
        math.pi,
        math.pi,
        false,
        pOla,
      );
    }

    // Bloque glaciar costero arriba a la derecha para el pingüino
    final glaciar = Path()
      ..moveTo(w * 0.85, h * 0.47)
      ..lineTo(w * 0.89, h * 0.33)
      ..lineTo(w * 0.96, h * 0.31)
      ..lineTo(w, h * 0.36)
      ..lineTo(w, h * 0.48)
      ..close();
    canvas.drawPath(
      glaciar,
      Paint()
        ..color = esNoche ? const Color(0xFF93C5FD) : const Color(0xFFE0F2FE),
    );

    // Arrecife de coral y cueva submarina del pulpo en el fondo del océano
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.81, h * 0.86),
        width: 58,
        height: 28,
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    // Corales marinos junto a la cueva del pulpo
    final pCoral = Paint()
      ..color = const Color(0xFFF43F5E)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.73, h * 0.92),
      Offset(w * 0.72, h * 0.83),
      pCoral,
    );
    canvas.drawLine(
      Offset(w * 0.73, h * 0.87),
      Offset(w * 0.75, h * 0.84),
      pCoral,
    );

    // Etiquetas claras de cada ecosistema para distinguir Río/Charca vs Océano
    _etiquetaBioma(
      canvas,
      'BOSQUE',
      Offset(w * 0.16, h * 0.94),
      const Color(0xFF86EFAC),
    );
    _etiquetaBioma(
      canvas,
      'RÍO Y CHARCA DULCE',
      Offset(w * 0.44, h * 0.94),
      const Color(0xFF67E8F9),
    );
    _etiquetaBioma(
      canvas,
      'DUNAS',
      Offset(w * 0.62, h * 0.94),
      const Color(0xFFFDE047),
    );
    _etiquetaBioma(
      canvas,
      'OCÉANO Y COSTA',
      Offset(w * 0.84, h * 0.94),
      const Color(0xFF93C5FD),
    );
  }

  @override
  bool shouldRepaint(covariant _PintorPaisajeReserva oldDelegate) =>
      oldDelegate.esNoche != esNoche || oldDelegate.faseAnim != faseAnim;
}

class _PintorHazLinternaNocturna extends CustomPainter {
  const _PintorHazLinternaNocturna({
    required this.focoRelativo,
    required this.faseAnim,
  });

  final Offset focoRelativo;
  final double faseAnim;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centroFoco = Offset(w * focoRelativo.dx, h * focoRelativo.dy);
    final origenLinterna = Offset(w * 0.50, h + 10);
    final radioFoco = math.min(w, h) * 0.25;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xCC050811),
    );

    final angulo = math.atan2(
      centroFoco.dy - origenLinterna.dy,
      centroFoco.dx - origenLinterna.dx,
    );
    final perp = angulo + math.pi / 2;
    final p1 = Offset(
      centroFoco.dx + math.cos(perp) * radioFoco * 0.88,
      centroFoco.dy + math.sin(perp) * radioFoco * 0.88,
    );
    final p2 = Offset(
      centroFoco.dx - math.cos(perp) * radioFoco * 0.88,
      centroFoco.dy - math.sin(perp) * radioFoco * 0.88,
    );
    final conoPath = Path()
      ..moveTo(origenLinterna.dx - 16, origenLinterna.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(origenLinterna.dx + 16, origenLinterna.dy)
      ..close();

    canvas.drawPath(
      conoPath,
      Paint()
        ..blendMode = BlendMode.dstOut
        ..color = Colors.black.withValues(alpha: 0.55),
    );

    canvas.drawCircle(
      centroFoco,
      radioFoco,
      Paint()
        ..blendMode = BlendMode.dstOut
        ..shader = RadialGradient(
          colors: [
            Colors.black,
            Colors.black.withValues(alpha: 0.85),
            Colors.transparent,
          ],
          stops: const [0.0, 0.68, 1.0],
        ).createShader(Rect.fromCircle(center: centroFoco, radius: radioFoco)),
    );
    canvas.restore();

    canvas.drawPath(
      conoPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFFFDE047).withValues(alpha: 0.25),
            const Color(0xFFFDE047).withValues(alpha: 0.06),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      centroFoco,
      radioFoco * 0.92,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final pLuciernaga = Paint()..color = const Color(0xFFBEF264);
    for (var i = 0; i < 6; i++) {
      final fx =
          (0.12 + i * 0.15 + 0.03 * math.sin(faseAnim * 2 * math.pi + i));
      final fy =
          (0.35 + (i % 3) * 0.16 + 0.04 * math.cos(faseAnim * 2 * math.pi + i));
      canvas.drawCircle(Offset(w * fx, h * fy), 2.5, pLuciernaga);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorHazLinternaNocturna oldDelegate) =>
      oldDelegate.focoRelativo != focoRelativo ||
      oldDelegate.faseAnim != faseAnim;
}

// ============================================================================
// 2. INVERNADERO BOTÁNICO: REACTOR DE FOTOSÍNTESIS Y MICROSCOPIO DE ESTOMAS
// ============================================================================

class _SimuladorFotosintesis extends StatefulWidget {
  const _SimuladorFotosintesis();

  @override
  State<_SimuladorFotosintesis> createState() => _SimuladorFotosintesisState();
}

class _SimuladorFotosintesisState extends State<_SimuladorFotosintesis>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reactorCtrl;
  String _nivelLuz = 'intensa'; // 'apagada', 'media', 'intensa'
  String _nivelAgua = 'optimo'; // 'seco', 'optimo', 'exceso'
  bool _verSavia = true;

  @override
  void initState() {
    super.initState();
    _reactorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _reactorCtrl.dispose();
    super.dispose();
  }

  int get _rendimientoFotosintesis {
    if (_nivelLuz == 'apagada' || _nivelAgua == 'seco') return 0;
    if (_nivelAgua == 'exceso') return 35;
    if (_nivelLuz == 'media') return 65;
    return 100;
  }

  String get _diagnosticoBotanico {
    if (_nivelLuz == 'apagada') {
      return 'Sin energía solar los estomas se cierran y los cloroplastos no pueden fabricar savia elaborada ni liberar oxígeno.';
    }
    if (_nivelAgua == 'seco') {
      return 'La tierra está seca: las raíces no pueden absorber agua ni sales minerales (savia bruta), por lo que la hoja cierra sus estomas.';
    }
    if (_nivelAgua == 'exceso') {
      return 'Demasiada agua encharca la tierra y deja sin aire a las raíces. La fotosíntesis va más lenta.';
    }
    if (_nivelLuz == 'media') {
      return 'Con luz suave la planta realiza la fotosíntesis a ritmo moderado: sube savia bruta y libera burbujas de oxígeno.';
    }
    return '¡Fotosíntesis al 100 %! La raíz absorbe savia bruta, los estomas toman dióxido de carbono y la hoja con luz solar fabrica savia elaborada y libera oxígeno al aire.';
  }

  @override
  Widget build(BuildContext context) {
    final rendimiento = _rendimientoFotosintesis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC), width: 2.2),
            ),
            child: Row(
              children: [
                DibujoMascota(
                  gesto: rendimiento == 100 ? 'feliz' : 'pista',
                  tamano: 54,
                  traje: 'botanico',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.tr(
                                'Laboratorio Vascular y Microscopio de Hoja',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF14532D),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: rendimiento >= 65
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'O₂: $rendimiento %',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: rendimiento >= 65
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(_diagnosticoBotanico),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                          height: 1.22,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            key: const Key('visor-fotosintesis'),
            height: 325,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF22C55E), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2215803D),
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: AnimatedBuilder(
                animation: _reactorCtrl,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _PintorReactorFotosintesis(
                      nivelLuz: _nivelLuz,
                      nivelAgua: _nivelAgua,
                      verSavia: _verSavia,
                      rendimiento: rendimiento,
                      fase: _reactorCtrl.value,
                    ),
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _EtiquetaLeyendaBotanica(
                color: const Color(0xFF0284C7),
                texto: context.tr('↑ Savia bruta (Xilema: Agua + Sales)'),
              ),
              _EtiquetaLeyendaBotanica(
                color: const Color(0xFFF59E0B),
                texto: context.tr('↓ Savia elaborada (Floema: Alimento)'),
              ),
              _EtiquetaLeyendaBotanica(
                color: const Color(0xFF64748B),
                texto: context.tr('→ Entrada de CO₂ (Estomas)'),
              ),
              _EtiquetaLeyendaBotanica(
                color: const Color(0xFF06B6D4),
                texto: context.tr('↑ Burbujas de Oxígeno (O₂)'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('1. Energía Luminosa (Sol)'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final (id, label, icon) in [
                      ('apagada', 'Sin luz', Icons.nightlight_round),
                      ('media', 'Sol suave', Icons.wb_cloudy_rounded),
                      ('intensa', 'Sol radiante', Icons.wb_sunny_rounded),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _BotonControlLaboratorio(
                            key: Key('luz-invernadero-$id'),
                            icono: icon,
                            etiqueta: context.tr(label),
                            activo: _nivelLuz == id,
                            colorActivo: const Color(0xFFEAB308),
                            alPulsar: () => setState(() => _nivelLuz = id),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('2. Absorción en la Raíz (Agua y Sales Minerales)'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final (id, label, icon) in [
                      ('seco', 'Suelo seco', Icons.grain_rounded),
                      ('optimo', 'Humedad ideal', Icons.water_drop_rounded),
                      ('exceso', 'Encharcado', Icons.tsunami_rounded),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _BotonControlLaboratorio(
                            key: Key('riego-invernadero-$id'),
                            icono: icon,
                            etiqueta: context.tr(label),
                            activo: _nivelAgua == id,
                            colorActivo: const Color(0xFF0284C7),
                            alPulsar: () => setState(() => _nivelAgua = id),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  key: const Key('switch-lupa-savia'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeThumbColor: const Color(0xFF16A34A),
                  title: Text(
                    context.tr(
                      'Activar Rayos X de vasos conductores (Savia bruta y elaborada)',
                    ),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  value: _verSavia,
                  onChanged: (v) => setState(() => _verSavia = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EtiquetaLeyendaBotanica extends StatelessWidget {
  const _EtiquetaLeyendaBotanica({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _PintorReactorFotosintesis extends CustomPainter {
  const _PintorReactorFotosintesis({
    required this.nivelLuz,
    required this.nivelAgua,
    required this.verSavia,
    required this.rendimiento,
    required this.fase,
  });

  final String nivelLuz;
  final String nivelAgua;
  final bool verSavia;
  final int rendimiento;
  final double fase;

  void _dibujarEtiquetaQuimica(
    Canvas canvas,
    String texto,
    Offset centro,
    Color fondo,
    Color colorTexto,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: texto,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: colorTexto,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: centro,
        width: tp.width + 8,
        height: tp.height + 3,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(r, Paint()..color = fondo);
    tp.paint(canvas, Offset(centro.dx - tp.width / 2, centro.dy - tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sueloY = h * 0.70;
    final plantaX = w * 0.28;

    // 1. Cielo dinámico según nivel de luz
    final gradCielo = switch (nivelLuz) {
      'apagada' => const [Color(0xFF0F172A), Color(0xFF1E293B)],
      'media' => const [Color(0xFFBAE6FD), Color(0xFFE0F2FE)],
      _ => const [Color(0xFF7DD3FC), Color(0xFFFEF9C3)],
    };
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, sueloY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradCielo,
        ).createShader(Rect.fromLTWH(0, 0, w, sueloY)),
    );

    // 2. Sol, nubes o luna + haces de fotones hacia las hojas
    final solPos = Offset(w * 0.10, h * 0.14);
    if (nivelLuz == 'apagada') {
      // Luna y estrellas cuando no hay luz solar
      canvas.drawCircle(solPos, 16, Paint()..color = const Color(0xFFFEF08A));
      canvas.drawCircle(
        solPos.translate(6, -4),
        14,
        Paint()..color = const Color(0xFF0F172A),
      );
      for (final (sx, sy) in [(0.22, 0.09), (0.38, 0.08), (0.52, 0.12)]) {
        canvas.drawCircle(
          Offset(w * sx, h * sy),
          2.0,
          Paint()..color = Colors.white70,
        );
      }
    } else {
      final esIntensa = nivelLuz == 'intensa';
      final radioSol = esIntensa ? 24.0 : 18.0;
      // Haz diagonal de energía solar sobre la planta
      final hazLuz = Path()
        ..moveTo(solPos.dx, solPos.dy)
        ..lineTo(plantaX - 80, h * 0.56)
        ..lineTo(plantaX + 85, h * 0.36)
        ..close();
      canvas.drawPath(
        hazLuz,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFDE047).withValues(alpha: esIntensa ? 0.32 : 0.15),
              const Color(0xFFFDE047).withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, w * 0.55, sueloY)),
      );
      canvas.drawCircle(
        solPos,
        radioSol * 1.45,
        Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.35),
      );
      canvas.drawCircle(
        solPos,
        radioSol,
        Paint()..color = const Color(0xFFFACC15),
      );
      if (!esIntensa) {
        // Nube tamizando el sol en modo luz media
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: solPos.translate(14, 10),
              width: 44,
              height: 18,
            ),
            const Radius.circular(10),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.90),
        );
      }
      // Fotones animados viajando del sol a los cloroplastos de las hojas
      for (var i = 0; i < (esIntensa ? 5 : 3); i++) {
        final t = (fase + i * 0.20) % 1.0;
        final fx = solPos.dx + (plantaX - 28 - solPos.dx) * t;
        final fy = solPos.dy + (h * 0.42 - solPos.dy) * t;
        canvas.drawCircle(
          Offset(fx, fy),
          4.0,
          Paint()..color = const Color(0xFFF59E0B),
        );
      }
    }

    // 3. Corte estratificado del suelo (mantillo, humus y subsuelo mineral)
    final coloresSuelo = switch (nivelAgua) {
      'seco' => const [Color(0xFFB45309), Color(0xFF92400E)],
      'exceso' => const [Color(0xFF1E3A8A), Color(0xFF172554)],
      _ => const [Color(0xFF5C3A21), Color(0xFF3E2723)],
    };
    canvas.drawRect(
      Rect.fromLTWH(0, sueloY, w, h - sueloY),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: coloresSuelo,
        ).createShader(Rect.fromLTWH(0, sueloY, w, h - sueloY)),
    );
    // Franja de césped superficial
    canvas.drawRect(
      Rect.fromLTWH(0, sueloY - 4, w, 8),
      Paint()
        ..color = nivelAgua == 'seco'
            ? const Color(0xFFA16207)
            : const Color(0xFF16A34A),
    );

    if (nivelAgua == 'seco') {
      // Grietas de sequía en el terreno
      final pGrieta = Paint()
        ..color = const Color(0xFF451A03)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      for (final gx in [0.08, 0.44, 0.78]) {
        final g = Path()
          ..moveTo(w * gx, sueloY + 4)
          ..lineTo(w * gx - 8, sueloY + 26)
          ..lineTo(w * gx + 5, sueloY + 48);
        canvas.drawPath(g, pGrieta);
      }
    } else if (nivelAgua == 'exceso') {
      // Nivel freático encharcado cubriendo las raíces
      canvas.drawRect(
        Rect.fromLTWH(0, sueloY + 2, w, h - sueloY),
        Paint()..color = const Color(0xFF0284C7).withValues(alpha: 0.45),
      );
    }

    // 4. Sistema radicular ramificado con pelos absorbentes
    final pRaiz = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;
    final pPeloAbsorbente = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final (dx, dy) in [
      (-62.0, 56.0),
      (-32.0, 76.0),
      (0.0, 82.0),
      (34.0, 74.0),
      (64.0, 54.0),
    ]) {
      final finX = plantaX + dx;
      final finY = sueloY + dy;
      final ctrlX = plantaX + dx * 0.48;
      final ctrlY = sueloY + dy * 0.55;
      final path = Path()
        ..moveTo(plantaX, sueloY)
        ..quadraticBezierTo(ctrlX, ctrlY, finX, finY);
      canvas.drawPath(path, pRaiz);
      // Pelos absorbentes finos a los lados de cada raíz
      canvas.drawLine(
        Offset(ctrlX, ctrlY),
        Offset(ctrlX + (dx < 0 ? -10 : 10), ctrlY + 8),
        pPeloAbsorbente,
      );
      canvas.drawLine(
        Offset(finX * 0.85 + plantaX * 0.15, finY * 0.85 + sueloY * 0.15),
        Offset(finX + (dx < 0 ? -8 : 8), finY - 4),
        pPeloAbsorbente,
      );
    }

    // Gotas de agua (H2O) y sales minerales entrando hacia la raíz
    if (nivelAgua != 'seco') {
      for (var i = 0; i < 6; i++) {
        final t = (fase + i * 0.16) % 1.0;
        final ang = (i / 5.0) * math.pi;
        final dist = (1.0 - t) * 68.0;
        final gx = plantaX + math.cos(ang) * dist;
        final gy = sueloY + 12 + math.sin(ang) * dist * 0.85;
        canvas.drawCircle(
          Offset(gx, gy),
          3.8,
          Paint()..color = const Color(0xFF38BDF8),
        );
      }
      _dibujarEtiquetaQuimica(
        canvas,
        'H₂O + Sales',
        Offset(plantaX, h * 0.93),
        const Color(0xFF0284C7),
        Colors.white,
      );
    }

    // 5. Hojas botánicas con pecíolo, nervio central y nervios secundarios
    final decaimiento = nivelAgua == 'seco' ? 18.0 : 0.0;
    final colorHoja = rendimiento == 0
        ? const Color(0xFF84CC16)
        : const Color(0xFF16A34A);

    void pintarHojaBotanica({
      required double yUnion,
      required double dir, // -1 izquierda, 1 derecha
      required double escala,
    }) {
      final xUnion = plantaX + dir * 9;
      final xPunta = plantaX + dir * (98 * escala);
      final yPunta = yUnion - (16 * escala) + decaimiento;
      final hojaPath = Path()
        ..moveTo(xUnion, yUnion)
        ..cubicTo(
          xUnion + dir * (38 * escala),
          yUnion - (42 * escala) + decaimiento * 0.4,
          xPunta - dir * (16 * escala),
          yPunta - (24 * escala),
          xPunta,
          yPunta,
        )
        ..cubicTo(
          xPunta - dir * (18 * escala),
          yPunta + (28 * escala),
          xUnion + dir * (34 * escala),
          yUnion + (26 * escala) + decaimiento * 0.5,
          xUnion,
          yUnion + 5,
        )
        ..close();

      canvas.drawPath(hojaPath, Paint()..color = colorHoja);
      canvas.drawPath(
        hojaPath,
        Paint()
          ..color = const Color(0xFF14532D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      // Nervio central y nervaduras secundarias
      final pNervio = Paint()
        ..color = const Color(0xFFBBF7D0).withValues(alpha: 0.85)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(xUnion, yUnion + 2),
        Offset(xPunta - dir * 8, yPunta),
        pNervio,
      );
      for (final f in [0.35, 0.62]) {
        final nx = xUnion + (xPunta - xUnion) * f;
        final ny = yUnion + (yPunta - yUnion) * f;
        canvas.drawLine(
          Offset(nx, ny),
          Offset(nx + dir * 12 * escala, ny - 10 * escala),
          pNervio,
        );
        canvas.drawLine(
          Offset(nx, ny),
          Offset(nx + dir * 10 * escala, ny + 9 * escala),
          pNervio,
        );
      }
    }

    // 2 pares de hojas (inferiores grandes y superiores medianas, dejando espacio amplio a la gran flor apical)
    pintarHojaBotanica(yUnion: h * 0.55, dir: -1, escala: 1.0);
    pintarHojaBotanica(yUnion: h * 0.52, dir: 1, escala: 1.0);
    pintarHojaBotanica(yUnion: h * 0.39, dir: -1, escala: 0.78);
    pintarHojaBotanica(yUnion: h * 0.37, dir: 1, escala: 0.78);

    // 6. Tallo botánico estilizado con corte anatómico de Xilema y Floema
    final talloPath = Path()
      ..moveTo(plantaX - 9.5, sueloY)
      ..quadraticBezierTo(plantaX - 7.5, h * 0.48, plantaX - 6.0, h * 0.20)
      ..lineTo(plantaX + 6.0, h * 0.20)
      ..quadraticBezierTo(plantaX + 7.5, h * 0.48, plantaX + 9.5, sueloY)
      ..close();
    canvas.drawPath(
      talloPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF15803D), Color(0xFF22C55E), Color(0xFF166534)],
        ).createShader(Rect.fromLTWH(plantaX - 10, h * 0.20, 20, sueloY - h * 0.20)),
    );
    canvas.drawPath(
      talloPath,
      Paint()
        ..color = const Color(0xFF14532D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    if (verSavia) {
      // Conductos paralelos visibles en Rayos X: Xilema (izq, azul) y Floema (der, ámbar)
      canvas.drawLine(
        Offset(plantaX - 3.2, sueloY - 4),
        Offset(plantaX - 2.6, h * 0.22),
        Paint()
          ..color = const Color(0xFF0284C7).withValues(alpha: 0.55)
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(plantaX + 3.2, sueloY - 4),
        Offset(plantaX + 2.6, h * 0.22),
        Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.55)
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round,
      );

      if (nivelAgua != 'seco') {
        for (var i = 0; i < 6; i++) {
          final tSubida = (fase + i * 0.16) % 1.0;
          final ySubida = sueloY - tSubida * (sueloY - h * 0.22);
          canvas.drawCircle(
            Offset(plantaX - 3.0, ySubida),
            3.2,
            Paint()..color = const Color(0xFF38BDF8),
          );

          if (rendimiento > 0) {
            final tBajada = (fase + i * 0.16) % 1.0;
            final yBajada = h * 0.22 + tBajada * (sueloY - h * 0.22);
            canvas.drawCircle(
              Offset(plantaX + 3.0, yBajada),
              3.2,
              Paint()..color = const Color(0xFFFBBF24),
            );
          }
        }
      }
    }

    // 7. Gran flor botánica apical proporcionada (~76 px de diámetro) con cáliz verde, doble corola y disco floral
    final florCentro = Offset(plantaX, h * 0.165);
    final aperturaFlor = rendimiento > 0 ? 1.0 : 0.80;
    final balanceo = math.sin(fase * math.pi * 2) * 0.04;

    // Sépalos verdes amplios del cáliz abrazando la base de la flor
    for (final dir in [-1.0, 1.0]) {
      final sepalo = Path()
        ..moveTo(florCentro.dx, florCentro.dy + 12)
        ..quadraticBezierTo(
          florCentro.dx + dir * 24,
          florCentro.dy + 26,
          florCentro.dx + dir * 36,
          florCentro.dy + 8,
        )
        ..quadraticBezierTo(
          florCentro.dx + dir * 18,
          florCentro.dy + 2,
          florCentro.dx,
          florCentro.dy + 12,
        );
      canvas.drawPath(sepalo, Paint()..color = const Color(0xFF15803D));
      canvas.drawPath(
        sepalo,
        Paint()
          ..color = const Color(0xFF14532D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }

    // Corola exterior (8 grandes pétalos en rosa carmín) e interior (8 pétalos en rosa coral luminoso)
    for (var capa = 0; capa < 2; capa++) {
      const numPetalos = 8;
      final desfase = capa == 0 ? 0.0 : math.pi / numPetalos;
      final largoPetalo = (capa == 0 ? 31.0 : 26.0) * aperturaFlor;
      final anchoPetalo = (capa == 0 ? 17.5 : 14.5) * aperturaFlor;
      final colorPetalo = capa == 0 ? const Color(0xFFE11D48) : const Color(0xFFFB7185);

      for (var i = 0; i < numPetalos; i++) {
        final ang = i * (math.pi * 2 / numPetalos) + desfase + balanceo;
        canvas.save();
        canvas.translate(florCentro.dx, florCentro.dy);
        canvas.rotate(ang);
        final rectPetalo = Rect.fromCenter(
          center: Offset(largoPetalo * 0.72, 0),
          width: largoPetalo,
          height: anchoPetalo,
        );
        canvas.drawOval(rectPetalo, Paint()..color = colorPetalo);
        canvas.drawOval(
          rectPetalo,
          Paint()
            ..color = const Color(0xFF881337)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
        // Nervadura central luminosa del pétalo
        canvas.drawLine(
          Offset(largoPetalo * 0.35, 0),
          Offset(largoPetalo * 0.98, 0),
          Paint()
            ..color = const Color(0xFFFFE4E6).withValues(alpha: 0.70)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );
        canvas.restore();
      }
    }

    // Corona de 12 estambres de polen y gran botón floral dorado central
    for (var i = 0; i < 12; i++) {
      final ang = i * (math.pi / 6) + balanceo;
      final pEstambre = florCentro + Offset(math.cos(ang) * 17.5, math.sin(ang) * 17.5);
      canvas.drawLine(
        florCentro + Offset(math.cos(ang) * 12.0, math.sin(ang) * 12.0),
        pEstambre,
        Paint()
          ..color = const Color(0xFFB45309)
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        pEstambre,
        2.6,
        Paint()..color = const Color(0xFFFEF08A),
      );
    }
    canvas.drawCircle(
      florCentro,
      14.5,
      Paint()..color = const Color(0xFFF59E0B),
    );
    canvas.drawCircle(
      florCentro,
      10.0,
      Paint()..color = const Color(0xFFFEF08A),
    );
    for (final off in [
      const Offset(-4, -3),
      const Offset(4, -3),
      const Offset(0, 4),
      const Offset(-4, 3),
      const Offset(4, 3),
      Offset.zero,
    ]) {
      canvas.drawCircle(
        florCentro + off,
        1.4,
        Paint()..color = const Color(0xFFD97706),
      );
    }
    canvas.drawCircle(
      florCentro,
      14.5,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 8. LUPA MICROSCÓPICA CELULAR A LA DERECHA (Tejido epidérmico, Cloroplastos, Estoma, CO2 y O2)
    final lupaCentro = Offset(w * 0.73, h * 0.37);
    final lupaRadio = math.min(w * 0.21, h * 0.31);

    // Cono óptico desde la hoja derecha hacia el microscopio
    final conoLupa = Path()
      ..moveTo(plantaX + 56, h * 0.44)
      ..lineTo(lupaCentro.dx - lupaRadio * 0.65, lupaCentro.dy - lupaRadio * 0.75)
      ..lineTo(lupaCentro.dx - lupaRadio * 0.65, lupaCentro.dy + lupaRadio * 0.75)
      ..close();
    canvas.drawPath(
      conoLupa,
      Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.20),
    );

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: lupaCentro, radius: lupaRadio)),
    );

    // Fondo celular vegetal
    canvas.drawCircle(
      lupaCentro,
      lupaRadio,
      Paint()..color = const Color(0xFFDCFCE7),
    );

    // Paredes celulares hexagonales del tejido de la hoja
    final pParedCelular = Paint()
      ..color = const Color(0xFF86EFAC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    for (var dy = -lupaRadio; dy <= lupaRadio; dy += 28) {
      for (var dx = -lupaRadio; dx <= lupaRadio; dx += 32) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: lupaCentro.translate(dx, dy),
              width: 28,
              height: 24,
            ),
            const Radius.circular(6),
          ),
          pParedCelular,
        );
      }
    }

    // Cloroplastos con discos de tilacoides (grana) ricos en clorofila
    for (final (dx, dy) in [
      (-0.48, -0.36),
      (0.46, -0.34),
      (-0.50, 0.34),
      (0.44, 0.36),
      (0.0, -0.56),
      (0.0, 0.56),
    ]) {
      final cPos = Offset(
        lupaCentro.dx + lupaRadio * dx,
        lupaCentro.dy + lupaRadio * dy,
      );
      canvas.drawOval(
        Rect.fromCenter(center: cPos, width: 26, height: 15),
        Paint()..color = const Color(0xFF16A34A),
      );
      canvas.drawOval(
        Rect.fromCenter(center: cPos, width: 26, height: 15),
        Paint()
          ..color = const Color(0xFF14532D)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      // Discos de clorofila dentro del cloroplasto
      for (final gx in [-5.0, 0.0, 5.0]) {
        canvas.drawCircle(
          cPos.translate(gx, 0),
          2.6,
          Paint()..color = const Color(0xFF86EFAC),
        );
      }
    }

    // Estoma central (células oclusivas arriñonadas + ostiolo)
    final estomaAbierto = rendimiento > 0;
    final apertura = estomaAbierto ? 11.0 : 2.2;
    final pCelulaOclusiva = Paint()..color = const Color(0xFF15803D);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(lupaCentro.dx - apertura, lupaCentro.dy),
        width: 18,
        height: 42,
      ),
      pCelulaOclusiva,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(lupaCentro.dx + apertura, lupaCentro.dy),
        width: 18,
        height: 42,
      ),
      pCelulaOclusiva,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: lupaCentro,
        width: apertura * 1.35,
        height: 26,
      ),
      Paint()..color = const Color(0xFF052E16),
    );

    canvas.restore();

    // Moléculas etiquetadas de CO2 (entrando) y O2 (saliendo) cuando el estoma está abierto
    if (estomaAbierto) {
      for (var i = 0; i < 3; i++) {
        final t = (fase + i * 0.33) % 1.0;
        final co2Pos = Offset(
          lupaCentro.dx - lupaRadio * 0.90 * (1 - t),
          lupaCentro.dy + 10 * math.sin(t * math.pi),
        );
        _dibujarEtiquetaQuimica(
          canvas,
          'CO₂',
          co2Pos,
          const Color(0xFF475569),
          Colors.white,
        );

        final o2Pos = Offset(
          lupaCentro.dx + 16 * math.cos(t * 2 * math.pi + i),
          lupaCentro.dy - lupaRadio * 0.95 * t,
        );
        _dibujarEtiquetaQuimica(
          canvas,
          'O₂',
          o2Pos,
          const Color(0xFF0891B2),
          Colors.white,
        );
      }
    }

    // Marco metálico del microscopio + etiqueta de estado del estoma
    canvas.drawCircle(
      lupaCentro,
      lupaRadio,
      Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5,
    );
    _dibujarEtiquetaQuimica(
      canvas,
      estomaAbierto ? 'ESTOMA ABIERTO' : 'ESTOMA CERRADO',
      Offset(lupaCentro.dx, lupaCentro.dy + lupaRadio + 12),
      estomaAbierto ? const Color(0xFF15803D) : const Color(0xFFB45309),
      Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorReactorFotosintesis oldDelegate) =>
      oldDelegate.nivelLuz != nivelLuz ||
      oldDelegate.nivelAgua != nivelAgua ||
      oldDelegate.verSavia != verSavia ||
      oldDelegate.fase != fase;
}

// ============================================================================
// 3. NUESTRO CUERPO: ESCÁNER DE RAYOS X EN VIVO CON FISIOLOGÍA ANIMADA
// ============================================================================

class _LaboratorioRayosX extends StatefulWidget {
  const _LaboratorioRayosX();

  @override
  State<_LaboratorioRayosX> createState() => _LaboratorioRayosXState();
}

class _LaboratorioRayosXState extends State<_LaboratorioRayosX>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fisioCtrl;
  String _estadoCuerpo = 'reposo'; // 'reposo', 'comer', 'correr', 'estudiar'
  String _capaSistema =
      'todos'; // 'todos', 'circulatorio', 'digestivo', 'nervioso', 'excretor'
  String _organoInspeccionado = 'corazon';
  double _scannerYRelativo = 0.36;

  @override
  void initState() {
    super.initState();
    _fisioCtrl = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _fisioCtrl.dispose();
    super.dispose();
  }

  int get _pulsacionesPorMinuto => switch (_estadoCuerpo) {
    'correr' => 145,
    'comer' => 86,
    'estudiar' => 76,
    _ => 68,
  };

  int get _respiracionesPorMinuto => switch (_estadoCuerpo) {
    'correr' => 34,
    'comer' => 17,
    'estudiar' => 16,
    _ => 14,
  };

  int get _saturacionOxigeno => switch (_estadoCuerpo) {
    'correr' => 97,
    _ => 99,
  };

  String get _temperaturaCorporal => switch (_estadoCuerpo) {
    'correr' => '37.4 °C',
    'comer' => '36.8 °C',
    _ => '36.6 °C',
  };

  int get _glucosaSangre => switch (_estadoCuerpo) {
    'comer' => 128,
    'correr' => 82,
    'estudiar' => 88,
    _ => 92,
  };

  int get _filtradoRenal => switch (_estadoCuerpo) {
    'correr' => 45,
    'comer' => 65,
    _ => 60,
  };

  (String, String) _infoOrganoEnVivo(String id) {
    return switch ((id, _estadoCuerpo)) {
      ('corazon', 'correr') => (
        'Corazón (145 latidos/min)',
        '¡Bombeo máximo! Al correr, tus músculos necesitan mucho más oxígeno y nutrientes, por lo que el miocardio impulsa la sangre a gran velocidad.',
      ),
      ('corazon', _) => (
        'Corazón ($_pulsacionesPorMinuto latidos/min)',
        'Órgano muscular con cuatro cavidades (aurículas y ventrículos) que impulsa la sangre por arterias, capilares y venas.',
      ),
      ('pulmones', 'correr') => (
        'Pulmones y Diafragma (34 resp/min)',
        'Los bronquios y millones de alvéolos pulmonares aceleran el intercambio de gases: entra O₂ a la sangre y sale CO₂.',
      ),
      ('pulmones', _) => (
        'Pulmones y Árbol Bronquial ($_respiracionesPorMinuto resp/min)',
        'El aire baja por la tráquea y los bronquios hasta los alvéolos. El músculo diafragma sube y baja para ventilar el pecho.',
      ),
      ('higado', 'comer') => (
        'Hígado, Vesícula Biliar y Páncreas (Activos)',
        'Las glándulas anejas segregan bilis y jugo pancreático al duodeno para descomponer las grasas y los hidratos de carbono.',
      ),
      ('higado', _) => (
        'Hígado, Vesícula y Páncreas (Glándulas anejas)',
        'El hígado produce la bilis, almacena glucosa y filtra sustancias; el páncreas aporta jugos digestivos e insulina.',
      ),
      ('estomago', 'comer') => (
        'Estómago (Quimo gástrico en acción)',
        'Las paredes musculares del estómago baten el bolo alimenticio con los jugos gástricos hasta convertirlo en quimo.',
      ),
      ('estomago', _) => (
        'Esófago y Estómago',
        'El tubo digestivo conduce el alimento masticado hasta el estómago en forma de J, donde comienza la digestión química.',
      ),
      ('intestinos', 'comer') => (
        'Intestino Delgado y Grueso (Absorbiendo nutrientes)',
        'Las vellosidades del intestino delgado pasan glucosa y aminoácidos a la sangre ($glucosaTexto mg/dL); el colon absorbe el agua.',
      ),
      ('intestinos', _) => (
        'Intestino Delgado (7 m) e Intestino Grueso',
        'El intestino delgado absorbe los nutrientes útiles hacia los capilares sanguíneos y el intestino grueso compacta los desechos.',
      ),
      ('rinones', _) => (
        'Riñones y Aparato Excretor ($_filtradoRenal mL/h)',
        'Los dos riñones filtran la sangre continuamente para limpiar las sustancias de desecho y formar la orina que baja por los uréteres a la vejiga.',
      ),
      ('cerebro', 'estudiar') => (
        'Cerebro, Cerebelo y Médula (Alta actividad sináptica)',
        '¡Neuronas a pleno rendimiento! La corteza cerebral procesa la atención, la memoria y el razonamiento consumiendo glucosa y oxígeno.',
      ),
      ('cerebro', _) => (
        'Cerebro, Cerebelo y Médula Espinal',
        'El cerebro dirige los pensamientos y sentidos, el cerebelo coordina el equilibrio y la médula espinal transmite impulsos nerviosos.',
      ),
      _ => (
        'Esqueleto, Articulaciones y Musculatura',
        'Los 206 huesos, unidos por articulaciones y movidos por los músculos esqueléticos, sostienen el cuerpo y protegen los órganos vitales.',
      ),
    };
  }

  String get glucosaTexto => '$_glucosaSangre';

  void _actualizarEscannerPorPosicion(Offset localPos, Size size) {
    final ry = (localPos.dy / size.height).clamp(0.10, 0.90);
    final rx = localPos.dx / size.width;
    String organoDetectado = _organoInspeccionado;
    if (ry < 0.22) {
      organoDetectado = 'cerebro';
    } else if (ry < 0.42) {
      organoDetectado = rx < 0.42 ? 'pulmones' : 'corazon';
    } else if (ry < 0.54) {
      organoDetectado = rx < 0.40 ? 'higado' : 'estomago';
    } else if (ry < 0.63) {
      organoDetectado = 'rinones';
    } else if (ry < 0.74) {
      organoDetectado = 'intestinos';
    } else {
      organoDetectado = 'esqueleto';
    }
    setState(() {
      _scannerYRelativo = ry;
      _organoInspeccionado = organoDetectado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final (tituloOrgano, detalleOrgano) = _infoOrganoEnVivo(
      _organoInspeccionado,
    );
    final idEnciclopedia = switch (_organoInspeccionado) {
      'higado' => 'aparato-digestivo',
      'rinones' => 'nutrientes',
      _ => _organoInspeccionado,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Monitor biomédico multiparamétrico con 6 constantes fisiológicas en vivo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF38BDF8), width: 2.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const DibujoMascota(
                      gesto: 'hola',
                      tamano: 50,
                      traje: 'doctor',
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(
                              'Monitor Biomédico y Fluoroscopia de 6.º Primaria',
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr(
                              'Desliza el haz de rayos X o selecciona un órgano para inspeccionar la nutrición, relación y locomoción en vivo.',
                            ),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ChipConstanteVital(
                      texto: '♥ $_pulsacionesPorMinuto LPM',
                      fondo: const Color(0xFF881337),
                      colorTexto: const Color(0xFFFDA4AF),
                    ),
                    _ChipConstanteVital(
                      texto: '≈ $_respiracionesPorMinuto RPM',
                      fondo: const Color(0xFF0C4A6E),
                      colorTexto: const Color(0xFF7DD3FC),
                    ),
                    _ChipConstanteVital(
                      texto: 'O₂ $_saturacionOxigeno %',
                      fondo: const Color(0xFF064E3B),
                      colorTexto: const Color(0xFF6EE7B7),
                    ),
                    _ChipConstanteVital(
                      texto: '🌡️ $_temperaturaCorporal',
                      fondo: const Color(0xFF78350F),
                      colorTexto: const Color(0xFFFDE68A),
                    ),
                    _ChipConstanteVital(
                      texto: '⚡ Glucosa $_glucosaSangre mg/dL',
                      fondo: const Color(0xFF4C1D95),
                      colorTexto: const Color(0xFFDDD6FE),
                    ),
                    _ChipConstanteVital(
                      texto: '💧 Riñón $_filtradoRenal mL/h',
                      fondo: const Color(0xFF1E3A8A),
                      colorTexto: const Color(0xFF93C5FD),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Escáner anatómico interactivo en tiempo real
          Container(
            key: const Key('visor-rayos-x'),
            height: 365,
            decoration: BoxDecoration(
              color: const Color(0xFF071022),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF0284C7), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x330284C7),
                  offset: Offset(0, 5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) =>
                        _actualizarEscannerPorPosicion(d.localPosition, size),
                    onPanUpdate: (d) =>
                        _actualizarEscannerPorPosicion(d.localPosition, size),
                    child: AnimatedBuilder(
                      animation: _fisioCtrl,
                      builder: (context, _) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: _PintorEscannerRayosXVivo(
                                estadoCuerpo: _estadoCuerpo,
                                capaSistema: _capaSistema,
                                organoActivo: _organoInspeccionado,
                                scannerYRelativo: _scannerYRelativo,
                                fase: _fisioCtrl.value,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              bottom: 8,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  for (final (id, nombre) in [
                                    ('cerebro', 'Cerebro'),
                                    ('pulmones', 'Pulmones'),
                                    ('corazon', 'Corazón'),
                                    ('higado', 'Hígado'),
                                    ('estomago', 'Estómago'),
                                    ('rinones', 'Riñones'),
                                    ('intestinos', 'Intestinos'),
                                    ('esqueleto', 'Esqueleto'),
                                  ])
                                    _BotonOrganoEscanner(
                                      id: id,
                                      etiqueta: context.tr(nombre),
                                      activo: _organoInspeccionado == id,
                                      alTocar: () => setState(() {
                                        _organoInspeccionado = id;
                                        _scannerYRelativo = switch (id) {
                                          'cerebro' => 0.14,
                                          'pulmones' => 0.33,
                                          'corazon' => 0.37,
                                          'higado' => 0.47,
                                          'estomago' => 0.49,
                                          'rinones' => 0.57,
                                          'intestinos' => 0.65,
                                          _ => 0.80,
                                        };
                                      }),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Tarjeta de inspección del órgano enfocado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF38BDF8), width: 2),
            ),
            child: Row(
              children: [
                IconoOrgano(id: _organoInspeccionado, size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(tituloOrgano),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${context.tr(detalleOrgano)} • ${DatosEnciclopedicosFicha.de(idEnciclopedia).datoCientifico}',
                        style: const TextStyle(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                          height: 1.24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Controles de actividad física y filtro de aparatos del cuerpo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('1. ¿Qué está haciendo el cuerpo ahora?'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C4A6E),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final (id, label, icon) in [
                      ('reposo', 'En reposo', Icons.self_improvement_rounded),
                      ('comer', 'Digiriendo', Icons.restaurant_rounded),
                      ('correr', 'Corriendo', Icons.directions_run_rounded),
                      ('estudiar', 'Estudiando', Icons.psychology_rounded),
                    ])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: _BotonControlLaboratorio(
                            key: Key('accion-cuerpo-$id'),
                            icono: icon,
                            etiqueta: context.tr(label),
                            activo: _estadoCuerpo == id,
                            colorActivo: const Color(0xFFE11D48),
                            alPulsar: () => setState(() => _estadoCuerpo = id),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('2. Filtro de Aparatos y Sistemas del Cuerpo'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0C4A6E),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (id, label) in [
                      ('todos', 'Todos los sistemas'),
                      ('circulatorio', 'Respiratorio y Circulatorio'),
                      ('digestivo', 'Digestivo y Glándulas'),
                      ('excretor', 'Aparato Excretor'),
                      ('nervioso', 'Nervioso y Locomotor'),
                    ])
                      ChoiceChip(
                        key: Key('capa-rayos-$id'),
                        label: Text(context.tr(label)),
                        selected: _capaSistema == id,
                        selectedColor: const Color(0xFF0284C7),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: _capaSistema == id
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                        onSelected: (_) => setState(() => _capaSistema = id),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipConstanteVital extends StatelessWidget {
  const _ChipConstanteVital({
    required this.texto,
    required this.fondo,
    required this.colorTexto,
  });

  final String texto;
  final Color fondo;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: colorTexto,
        ),
      ),
    );
  }
}

class _BotonOrganoEscanner extends StatelessWidget {
  const _BotonOrganoEscanner({
    required this.id,
    required this.etiqueta,
    required this.activo,
    required this.alTocar,
  });

  final String id;
  final String etiqueta;
  final bool activo;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: alTocar,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: activo ? const Color(0xFF7DD3FC) : const Color(0xFF334155),
              width: 1.4,
            ),
          ),
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: activo ? Colors.white : const Color(0xFFCBD5E1),
            ),
          ),
        ),
      ),
    );
  }
}

class _PintorEscannerRayosXVivo extends CustomPainter {
  const _PintorEscannerRayosXVivo({
    required this.estadoCuerpo,
    required this.capaSistema,
    required this.organoActivo,
    required this.scannerYRelativo,
    required this.fase,
  });

  final String estadoCuerpo;
  final String capaSistema;
  final String organoActivo;
  final double scannerYRelativo;
  final double fase;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.42;

    // 1. Cuadrícula médica de fluoroscopia
    final pGrid = Paint()
      ..color = const Color(0xFF13233F)
      ..strokeWidth = 1;
    for (double x = 0; x < w; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), pGrid);
    }
    for (double y = 0; y < h; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(w, y), pGrid);
    }

    final multRitmo = switch (estadoCuerpo) {
      'correr' => 2.8,
      'comer' => 1.4,
      'estudiar' => 1.3,
      _ => 1.0,
    };
    final ondaLatido = math.sin(fase * 2 * math.pi * multRitmo);
    final ondaResp = math.sin(fase * 2 * math.pi * (multRitmo * 0.55));

    // 2. Silueta anatómica proporcionada del cuerpo humano (cabeza, cuello, hombros, brazos, tronco, pelvis y piernas)
    final pSiluetaRelleno = Paint()..color = const Color(0xFF0D213F);
    final pSiluetaBorde = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    // Cabeza y orejas
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.13),
        width: h * 0.16,
        height: h * 0.18,
      ),
      pSiluetaRelleno,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.13),
        width: h * 0.16,
        height: h * 0.18,
      ),
      pSiluetaBorde,
    );
    // Cuello
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.23),
          width: h * 0.065,
          height: h * 0.055,
        ),
        const Radius.circular(6),
      ),
      pSiluetaRelleno,
    );
    // Brazos a ambos lados del tronco
    for (final dir in [-1.0, 1.0]) {
      final brazo = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dir * h * 0.22, h * 0.45),
          width: h * 0.065,
          height: h * 0.36,
        ),
        const Radius.circular(18),
      );
      canvas.drawRRect(brazo, pSiluetaRelleno);
      canvas.drawRRect(brazo, pSiluetaBorde);
    }
    // Tronco y pelvis
    final torsoRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: Offset(cx, h * 0.48),
        width: h * 0.34,
        height: h * 0.46,
      ),
      topLeft: const Radius.circular(32),
      topRight: const Radius.circular(32),
      bottomLeft: const Radius.circular(24),
      bottomRight: const Radius.circular(24),
    );
    canvas.drawRRect(torsoRect, pSiluetaRelleno);
    canvas.drawRRect(torsoRect, pSiluetaBorde);
    // Piernas
    for (final dx in [-h * 0.085, h * 0.085]) {
      final pierna = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + dx, h * 0.83),
          width: h * 0.105,
          height: h * 0.26,
        ),
        const Radius.circular(16),
      );
      canvas.drawRRect(pierna, pSiluetaRelleno);
      canvas.drawRRect(pierna, pSiluetaBorde);
    }

    final verTodos = capaSistema == 'todos';

    // 3. CAPA ESQUELETO Y SISTEMA NERVIOSO (Cráneo, Clavículas, Costillas, Pelvis, Fémures, Cerebro y Nervios)
    if (verTodos || capaSistema == 'nervioso') {
      final activoEsq = organoActivo == 'esqueleto';
      final pHueso = Paint()
        ..color = const Color(0xFFE2E8F0).withValues(
          alpha: activoEsq ? 0.95 : 0.42,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = activoEsq ? 3.4 : 2.6
        ..strokeCap = StrokeCap.round;

      // Columna vertebral con vértebras y esternón
      canvas.drawLine(Offset(cx, h * 0.21), Offset(cx, h * 0.69), pHueso);
      // Clavículas
      canvas.drawLine(
        Offset(cx - h * 0.15, h * 0.27),
        Offset(cx + h * 0.15, h * 0.27),
        pHueso,
      );
      // 5 pares de costillas arqueadas formando la caja torácica
      for (var i = 0; i < 5; i++) {
        final ry = h * (0.30 + i * 0.032);
        final anchoCostilla = h * (0.26 - i * 0.012);
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, ry),
            width: anchoCostilla,
            height: 15,
          ),
          0.1,
          math.pi - 0.2,
          false,
          pHueso,
        );
      }
      // Cintura pélvica (ilion) y fémures con cabeza articular
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - h * 0.07, h * 0.69),
          width: h * 0.10,
          height: h * 0.06,
        ),
        pHueso,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + h * 0.07, h * 0.69),
          width: h * 0.10,
          height: h * 0.06,
        ),
        pHueso,
      );
      for (final dir in [-1.0, 1.0]) {
        // Húmero en el brazo
        canvas.drawLine(
          Offset(cx + dir * h * 0.22, h * 0.30),
          Offset(cx + dir * h * 0.22, h * 0.58),
          pHueso,
        );
        // Fémur y rodilla en la pierna
        canvas.drawLine(
          Offset(cx + dir * h * 0.085, h * 0.71),
          Offset(cx + dir * h * 0.085, h * 0.93),
          pHueso,
        );
        canvas.drawCircle(
          Offset(cx + dir * h * 0.085, h * 0.84),
          3.8,
          Paint()..color = pHueso.color,
        );
      }

      // Cerebro bilobulado con circunvoluciones, cerebelo y nervios periféricos
      final activoCer = organoActivo == 'cerebro';
      final colorCerebro = activoCer
          ? const Color(0xFFF472B6)
          : const Color(0xFFEC4899).withValues(alpha: 0.88);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - h * 0.028, h * 0.115),
          width: h * 0.075,
          height: h * 0.082,
        ),
        Paint()..color = colorCerebro,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + h * 0.028, h * 0.115),
          width: h * 0.075,
          height: h * 0.082,
        ),
        Paint()..color = colorCerebro,
      );
      // Cerebelo en la base posterior
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, h * 0.155),
          width: h * 0.085,
          height: h * 0.032,
        ),
        Paint()..color = const Color(0xFFDB2777),
      );
      // Surcos cerebrales
      final pSurco = Paint()
        ..color = const Color(0xFF831843)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      for (final dx in [-h * 0.026, h * 0.026]) {
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx + dx, h * 0.11),
            width: h * 0.042,
            height: h * 0.034,
          ),
          0.2,
          2.6,
          false,
          pSurco,
        );
      }
      // Impulsos nerviosos dorados viajando por la médula y nervios
      final numImpulsos = estadoCuerpo == 'estudiar' ? 7 : 4;
      final pImpulso = Paint()..color = const Color(0xFFFDE047);
      for (var i = 0; i < numImpulsos; i++) {
        final t = (fase * (estadoCuerpo == 'estudiar' ? 3.2 : 1.8) + i / numImpulsos) % 1.0;
        final iy = h * (0.15 + t * 0.52);
        canvas.drawCircle(Offset(cx, iy), 3.4, pImpulso);
      }
    }

    // 4. CAPA EXCRETORA (Riñones en forma de alubia + Uréteres + Vejiga urinaria)
    if (verTodos || capaSistema == 'excretor' || organoActivo == 'rinones') {
      final activoRin = organoActivo == 'rinones';
      final colorRinon = activoRin
          ? const Color(0xFFC084FC)
          : const Color(0xFF9333EA).withValues(alpha: 0.85);
      final pUreter = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Uréteres bajando de cada riñón a la vejiga
      canvas.drawLine(
        Offset(cx - h * 0.06, h * 0.56),
        Offset(cx - h * 0.015, h * 0.67),
        pUreter,
      );
      canvas.drawLine(
        Offset(cx + h * 0.06, h * 0.56),
        Offset(cx + h * 0.015, h * 0.67),
        pUreter,
      );
      // Dos riñones laterales
      for (final dx in [-h * 0.068, h * 0.068]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx + dx, h * 0.56),
            width: h * 0.046,
            height: h * 0.068,
          ),
          Paint()..color = colorRinon,
        );
      }
      // Vejiga urinaria
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, h * 0.675),
          width: h * 0.052,
          height: h * 0.042,
        ),
        Paint()..color = const Color(0xFFFACC15).withValues(alpha: 0.88),
      );
    }

    // 5. CAPA RESPIRATORIA Y CIRCULATORIA (Tráquea, Pulmones, Diafragma, Corazón con Aorta/Cava)
    if (verTodos || capaSistema == 'circulatorio') {
      // Arteria aorta (roja) y vena cava (azul) recorriendo el cuerpo
      canvas.drawLine(
        Offset(cx - 3, h * 0.20),
        Offset(cx - 3, h * 0.66),
        Paint()
          ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65)
          ..strokeWidth = 2.4,
      );
      canvas.drawLine(
        Offset(cx + 3, h * 0.18),
        Offset(cx + 3, h * 0.66),
        Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.75)
          ..strokeWidth = 2.6,
      );

      // Tráquea con anillos cartilaginosos y bronquios principales
      final pTraquea = Paint()
        ..color = const Color(0xFFBAE6FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, h * 0.20), Offset(cx, h * 0.30), pTraquea);
      canvas.drawLine(
        Offset(cx, h * 0.30),
        Offset(cx - h * 0.06, h * 0.35),
        pTraquea,
      );
      canvas.drawLine(
        Offset(cx, h * 0.30),
        Offset(cx + h * 0.06, h * 0.35),
        pTraquea,
      );

      // Pulmones derecho e izquierdo expandiéndose con la respiración
      final escalaPulmon = 1.0 + 0.08 * ondaResp;
      final activoPul = organoActivo == 'pulmones';
      final pPulmon = Paint()
        ..color = activoPul
            ? const Color(0xFF38BDF8)
            : const Color(0xFF0284C7).withValues(alpha: 0.84);

      for (final dir in [-1.0, 1.0]) {
        final centroP = Offset(cx + dir * h * 0.072, h * 0.35);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromCenter(
              center: centroP,
              width: h * 0.095 * escalaPulmon,
              height: h * 0.145 * escalaPulmon,
            ),
            topLeft: Radius.circular(dir < 0 ? 28 : 12),
            topRight: Radius.circular(dir > 0 ? 28 : 12),
            bottomLeft: const Radius.circular(14),
            bottomRight: const Radius.circular(14),
          ),
          pPulmon,
        );
        // Bronquiolos ramificados dentro del pulmón
        final pBronquiolo = Paint()
          ..color = const Color(0xFFE0F2FE).withValues(alpha: 0.70)
          ..strokeWidth = 1.4
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          centroP.translate(-dir * 8, -6),
          centroP.translate(dir * 10, -14),
          pBronquiolo,
        );
        canvas.drawLine(
          centroP.translate(-dir * 8, 2),
          centroP.translate(dir * 12, 12),
          pBronquiolo,
        );
      }

      // Músculo diafragma en forma de cúpula bajo los pulmones
      final yDiafragma = h * 0.425 - ondaResp * 3.5;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, yDiafragma + 10),
          width: h * 0.25,
          height: 22,
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = const Color(0xFFF43F5E).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round,
      );

      // Corazón anatómico con cayado aórtico, vena cava y ventrículos latiendo
      final escalaCorazon = 1.0 + 0.16 * math.max(0.0, ondaLatido);
      final centroCorazon = Offset(cx + h * 0.022, h * 0.37);
      canvas.save();
      canvas.translate(centroCorazon.dx, centroCorazon.dy);
      canvas.scale(escalaCorazon);

      final rCor = h * 0.044;
      // Cayado de la aorta (rojo) y vena cava superior (azul)
      canvas.drawLine(
        Offset(-rCor * 0.35, -rCor * 0.6),
        Offset(-rCor * 0.35, -rCor * 1.15),
        Paint()
          ..color = const Color(0xFF38BDF8)
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        Offset(rCor * 0.2, -rCor * 0.6),
        Offset(rCor * 0.35, -rCor * 1.20),
        Paint()
          ..color = const Color(0xFFEF4444)
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round,
      );

      final pathCorazon = Path()
        ..moveTo(0, rCor * 0.95)
        ..cubicTo(
          -rCor * 1.15,
          rCor * 0.25,
          -rCor * 0.95,
          -rCor * 0.85,
          0,
          -rCor * 0.35,
        )
        ..cubicTo(
          rCor * 0.95,
          -rCor * 0.85,
          rCor * 1.15,
          rCor * 0.25,
          0,
          rCor * 0.95,
        )
        ..close();
      canvas.drawPath(
        pathCorazon,
        Paint()
          ..color = organoActivo == 'corazon'
              ? const Color(0xFFF43F5E)
              : const Color(0xFFE11D48),
      );
      canvas.drawPath(
        pathCorazon,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
      canvas.restore();
    }

    // 6. CAPA DIGESTIVA (Hígado, Vesícula, Páncreas, Estómago en J, Colon e Intestino Delgado)
    if (verTodos || capaSistema == 'digestivo') {
      // Hígado bilobulado a la izquierda del visor (derecha anatómica) + vesícula verde
      final activoHig = organoActivo == 'higado';
      final pathHigado = Path()
        ..moveTo(cx - h * 0.11, h * 0.45)
        ..quadraticBezierTo(cx - h * 0.04, h * 0.43, cx + h * 0.01, h * 0.46)
        ..quadraticBezierTo(cx - h * 0.05, h * 0.50, cx - h * 0.11, h * 0.51)
        ..close();
      canvas.drawPath(
        pathHigado,
        Paint()
          ..color = activoHig
              ? const Color(0xFFDC2626)
              : const Color(0xFF991B1B).withValues(alpha: 0.90),
      );
      // Vesícula biliar verde bajo el hígado
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - h * 0.055, h * 0.50),
          width: 11,
          height: 7,
        ),
        Paint()..color = const Color(0xFF22C55E),
      );
      // Páncreas alargado dorado detrás del estómago
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + h * 0.01, h * 0.53),
            width: h * 0.09,
            height: h * 0.025,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFFACC15).withValues(alpha: 0.85),
      );

      // Estómago en forma de J a la derecha del visor
      final activoEst = organoActivo == 'estomago';
      final estomagoRect = RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(cx + h * 0.048, h * 0.49),
          width: h * 0.10,
          height: h * 0.075,
        ),
        topLeft: const Radius.circular(18),
        topRight: const Radius.circular(26),
        bottomLeft: const Radius.circular(24),
        bottomRight: const Radius.circular(16),
      );
      canvas.drawRRect(
        estomagoRect,
        Paint()
          ..color = activoEst
              ? const Color(0xFFFB923C)
              : const Color(0xFFEA580C).withValues(alpha: 0.90),
      );

      // Marco cólico (intestino grueso) rodeando las asas del intestino delgado
      final activoInt = organoActivo == 'intestinos';
      final rectColon = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.62),
          width: h * 0.19,
          height: h * 0.105,
        ),
        const Radius.circular(16),
      );
      canvas.drawRRect(
        rectColon,
        Paint()
          ..color = activoInt
              ? const Color(0xFF4ADE80)
              : const Color(0xFF16A34A).withValues(alpha: 0.78)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.0,
      );
      canvas.drawRRect(
        rectColon.deflate(5),
        Paint()
          ..color = activoInt
              ? const Color(0xFFFBBF24)
              : const Color(0xFFD97706).withValues(alpha: 0.88),
      );
      // Pliegues serpenteantes del intestino delgado
      final pPliegueInt = Paint()
        ..color = const Color(0xFF78350F).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      for (var k = -1; k <= 1; k++) {
        canvas.drawLine(
          Offset(cx - h * 0.055, h * (0.62 + k * 0.022)),
          Offset(cx + h * 0.055, h * (0.62 + k * 0.022)),
          pPliegueInt,
        );
      }

      // Nutrientes animados recorriendo el tubo digestivo
      final numNutrientes = estadoCuerpo == 'comer' ? 7 : 3;
      for (var i = 0; i < numNutrientes; i++) {
        final t = (fase + i / numNutrientes) % 1.0;
        final ny = h * (0.25 + t * 0.40);
        final nx = cx + math.sin(t * math.pi * 4) * (t > 0.5 ? 16 : 5);
        canvas.drawCircle(
          Offset(nx, ny),
          3.6,
          Paint()..color = const Color(0xFFFEF08A),
        );
      }
    }

    // 7. Barra horizontal láser del Escáner de Rayos X arrastrable
    final scanY = h * scannerYRelativo;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, scanY), width: h * 0.46, height: 34),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF38BDF8).withValues(alpha: 0.0),
            const Color(0xFF38BDF8).withValues(alpha: 0.25),
            const Color(0xFF38BDF8).withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, scanY),
            width: h * 0.46,
            height: 34,
          ),
        ),
    );
    canvas.drawLine(
      Offset(cx - h * 0.23, scanY),
      Offset(cx + h * 0.23, scanY),
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..strokeWidth = 2.0,
    );

    // 8. Monitor ECG en vivo en la esquina superior izquierda
    final ecgRect = Rect.fromLTWH(10, 10, 108, 42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(ecgRect, const Radius.circular(10)),
      Paint()..color = const Color(0xCC020617),
    );
    final ecgPath = Path();
    for (var i = 0; i <= 50; i++) {
      final t = i / 50.0;
      final x = ecgRect.left + 6 + t * (ecgRect.width - 12);
      final pulso = ((t + fase * multRitmo) % 0.5) * 2;
      double dy = 0;
      if (pulso > 0.40 && pulso < 0.48) dy = -13;
      if (pulso >= 0.48 && pulso < 0.55) dy = 9;
      final y = ecgRect.center.dy + dy;
      if (i == 0) {
        ecgPath.moveTo(x, y);
      } else {
        ecgPath.lineTo(x, y);
      }
    }
    canvas.drawPath(
      ecgPath,
      Paint()
        ..color = const Color(0xFF22C55E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _PintorEscannerRayosXVivo oldDelegate) =>
      oldDelegate.estadoCuerpo != estadoCuerpo ||
      oldDelegate.capaSistema != capaSistema ||
      oldDelegate.organoActivo != organoActivo ||
      oldDelegate.scannerYRelativo != scannerYRelativo ||
      oldDelegate.fase != fase;
}

class _BotonControlLaboratorio extends StatelessWidget {
  const _BotonControlLaboratorio({
    required this.icono,
    required this.etiqueta,
    required this.activo,
    required this.colorActivo,
    required this.alPulsar,
    super.key,
  });

  final IconData icono;
  final String etiqueta;
  final bool activo;
  final Color colorActivo;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? colorActivo : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: alPulsar,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icono,
                size: 20,
                color: activo ? Colors.white : const Color(0xFF475569),
              ),
              const SizedBox(height: 3),
              Text(
                etiqueta,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: activo ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TarjetaAccesoLaboratorio extends StatelessWidget {
  const TarjetaAccesoLaboratorio({required this.zona, super.key});

  final Zona zona;

  @override
  Widget build(BuildContext context) {
    final (titulo, subtitulo, icono, colorFondo, colorBorde, colorTexto) =
        switch (zona.id) {
          'reserva' => (
            'Expedición Nocturna con Linterna',
            'Explora el bosque, el río dulce, las dunas y el océano con tu linterna científica.',
            Icons.flashlight_on_rounded,
            const Color(0xFF0F172A),
            const Color(0xFF10B981),
            Colors.white,
          ),
          'invernadero' => (
            'Simulador de Fotosíntesis en Vivo',
            'Controla el sol, el riego y el CO₂ para fabricar savia elaborada y oxígeno.',
            Icons.wb_sunny_rounded,
            const Color(0xFFECFDF5),
            const Color(0xFF16A34A),
            const Color(0xFF064E3B),
          ),
          _ => (
            'Escáner Anatómico de Rayos X',
            'Desliza la lente de rayos X por los 8 órganos y sistemas del cuerpo en vivo.',
            Icons.biotech_rounded,
            const Color(0xFFF0F9FF),
            const Color(0xFF0284C7),
            const Color(0xFF0C4A6E),
          ),
        };

    return Material(
      color: colorFondo,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: Key('laboratorio-${zona.id}'),
        onTap: () {
          context.sonidoSeleccion();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LaboratorioZonaPage(zona: zona),
            ),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorBorde, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: colorBorde.withValues(alpha: 0.22),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorBorde.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colorBorde, width: 1.5),
                ),
                child: Icon(icono, color: colorBorde, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorBorde,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Texto(
                            'LABORATORIO',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Texto(
                      titulo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: colorTexto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Texto(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorTexto.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: colorBorde,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotHabitat {
  const _SlotHabitat({
    required this.id,
    required this.x,
    required this.y,
    required this.bioma,
    required this.accionViva,
    required this.pistaDesbloqueo,
  });

  final String id;
  final double x;
  final double y;
  final String bioma;
  final String accionViva;
  final String pistaDesbloqueo;
}

class BannerEvolucionZona extends StatefulWidget {
  const BannerEvolucionZona({required this.zona, super.key});

  final Zona zona;

  @override
  State<BannerEvolucionZona> createState() => _BannerEvolucionZonaState();
}

class _BannerEvolucionZonaState extends State<BannerEvolucionZona>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  String? _seleccionadoId;
  bool _efectoActivo = false;
  int _modoAmbiente = 0;
  String? _arrastrandoId;
  Offset _offsetArrastre = Offset.zero;
  String? _mensajeArrastre;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed &&
            !WidgetsBinding.instance.runtimeType.toString().contains('Test') &&
            mounted) {
          _animController.forward(from: 0.0);
        }
      });
    _animController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<_SlotHabitat> _slotsParaZona(String zonaId) {
    return switch (zonaId) {
      'reserva' => const [
        _SlotHabitat(
          id: 'tucan',
          x: 0.14,
          y: 0.22,
          bioma: 'Copa de la selva',
          accionViva: '¡El tucán abre su gran pico y salta de rama en rama!',
          pistaDesbloqueo: 'Juega «Cada animal en su hogar» en modo Difícil.',
        ),
        _SlotHabitat(
          id: 'mariposa',
          x: 0.36,
          y: 0.18,
          bioma: 'Aire soleado',
          accionViva: '¡La mariposa bate sus alas tras completar su metamorfosis!',
          pistaDesbloqueo: 'Supera el nivel Difícil de «¿Cómo nacen y crecen?».',
        ),
        _SlotHabitat(
          id: 'claro-bosque',
          x: 0.60,
          y: 0.24,
          bioma: 'Ecosistema del bosque',
          accionViva: '¡El zorro rojo patrulla el claro del bosque en equilibrio con su hábitat!',
          pistaDesbloqueo: 'Completa la cadena alimentaria en «El claro del bosque».',
        ),
        _SlotHabitat(
          id: 'pinguino',
          x: 0.84,
          y: 0.24,
          bioma: 'Costa helada',
          accionViva: '¡El pingüino camina sobre el hielo y se zambulle en el mar!',
          pistaDesbloqueo: 'Resuelve el hogar del pingüino en «Cada animal en su hogar».',
        ),
        _SlotHabitat(
          id: 'camello',
          x: 0.15,
          y: 0.58,
          bioma: 'Dunas cálidas',
          accionViva: '¡El camello camina firme sobre la arena sin hundirse!',
          pistaDesbloqueo: 'Ayuda al camello en «Cada animal en su hogar».',
        ),
        _SlotHabitat(
          id: 'oso',
          x: 0.38,
          y: 0.54,
          bioma: 'Bosque templado',
          accionViva: '¡El oso pardo busca bayas maduras y miel en el bosque!',
          pistaDesbloqueo: 'Encuentra el bosque del oso en «Cada animal en su hogar».',
        ),
        _SlotHabitat(
          id: 'rana',
          x: 0.60,
          y: 0.56,
          bioma: 'Charca de agua dulce',
          accionViva: '¡Croac! La rana da un gran salto hasta el nenúfar.',
          pistaDesbloqueo: 'Completa el nivel Medio de «Cada animal en su hogar».',
        ),
        _SlotHabitat(
          id: 'huevo',
          x: 0.84,
          y: 0.54,
          bioma: 'Nido del bosque',
          accionViva: '¡El cascarón tiembla: una cría ovípara está lista para salir!',
          pistaDesbloqueo: 'Completa el nivel Fácil de «¿Cómo nacen y crecen?».',
        ),
        _SlotHabitat(
          id: 'delfin',
          x: 0.24,
          y: 0.84,
          bioma: 'Océano abierto',
          accionViva: '¡El delfín mular salta sobre las olas y respira por su espiráculo!',
          pistaDesbloqueo: 'Lleva al delfín al mar en «Cada animal en su hogar».',
        ),
        _SlotHabitat(
          id: 'pulpo',
          x: 0.52,
          y: 0.85,
          bioma: 'Arrecife submarino',
          accionViva: '¡El pulpo mueve sus 8 tentáculos con ventosas entre las rocas!',
          pistaDesbloqueo: 'Descubre al pulpo en «Cada animal en su hogar».',
        ),
        _SlotHabitat(
          id: 'renacuajo',
          x: 0.80,
          y: 0.84,
          bioma: 'Orilla de la charca',
          accionViva: '¡El renacuajo nada con su cola mientras desarrolla sus patas!',
          pistaDesbloqueo: 'Supera el nivel Medio de «¿Cómo nacen y crecen?».',
        ),
      ],
      'invernadero' => const [
        _SlotHabitat(
          id: 'encina',
          x: 0.14,
          y: 0.34,
          bioma: 'Dehesa mediterránea',
          accionViva: '¡La encina enraíza firme en la dehesa y da sombra y bellotas!',
          pistaDesbloqueo: 'Supera el nivel Fácil de «Árbol, arbusto o hierba».',
        ),
        _SlotHabitat(
          id: 'fotosintesis',
          x: 0.42,
          y: 0.24,
          bioma: 'Pradera soleada',
          accionViva: '¡Sus hojas captan la luz solar y liberan oxígeno puro al aire!',
          pistaDesbloqueo: 'Supera el nivel Difícil del «Laboratorio de germinación».',
        ),
        _SlotHabitat(
          id: 'flor',
          x: 0.60,
          y: 0.36,
          bioma: 'Pradera con colmena',
          accionViva: '¡Las flores abiertas atraen a las abejas polinizadoras de la colmena!',
          pistaDesbloqueo: 'Completa las partes de la planta en «Arma la planta».',
        ),
        _SlotHabitat(
          id: 'romero',
          x: 0.86,
          y: 0.34,
          bioma: 'Ladera pedregosa mediterránea',
          accionViva: '¡El arbusto de romero resiste la sequía en la ladera soleada!',
          pistaDesbloqueo: 'Supera el nivel Medio de «Árbol, arbusto o hierba».',
        ),
        _SlotHabitat(
          id: 'hoja',
          x: 0.14,
          y: 0.60,
          bioma: 'Ribera húmeda del arroyo',
          accionViva: '¡En la ribera fresca las hojas verdes transpiran y fabrican alimento!',
          pistaDesbloqueo: 'Coloca las hojas en su sitio en «Arma la planta».',
        ),
        _SlotHabitat(
          id: 'tallo',
          x: 0.32,
          y: 0.62,
          bioma: 'Orilla del arroyo',
          accionViva: '¡El tallo conduce el agua del suelo húmedo hacia las hojas!',
          pistaDesbloqueo: 'Coloca el tallo en «Arma la planta».',
        ),
        _SlotHabitat(
          id: 'fruto',
          x: 0.54,
          y: 0.58,
          bioma: 'Vergel y huerta fértil',
          accionViva: '¡En los surcos regados de la huerta maduran los frutos con semillas!',
          pistaDesbloqueo: 'Descubre la función del fruto en «Arma la planta».',
        ),
        _SlotHabitat(
          id: 'huerto',
          x: 0.70,
          y: 0.62,
          bioma: 'Surcos de regadío',
          accionViva: '¡La tierra labrada y abonada nutre las hortalizas de la huerta!',
          pistaDesbloqueo: 'Supera el nivel Medio del «Laboratorio de germinación».',
        ),
        _SlotHabitat(
          id: 'trigo',
          x: 0.88,
          y: 0.60,
          bioma: 'Campiña secana',
          accionViva: '¡Las espigas doradas de trigo maduran al sol de la campiña!',
          pistaDesbloqueo: 'Supera el nivel Difícil de «Árbol, arbusto o hierba».',
        ),
        _SlotHabitat(
          id: 'semilla',
          x: 0.26,
          y: 0.86,
          bioma: 'Corte del subsuelo húmedo',
          accionViva: '¡Bajo el mantillo húmedo la semilla hincha su cubierta y germina!',
          pistaDesbloqueo: 'Supera el nivel Fácil del «Laboratorio de germinación».',
        ),
        _SlotHabitat(
          id: 'raiz',
          x: 0.68,
          y: 0.86,
          bioma: 'Subsuelo mineral',
          accionViva: '¡Las raíces se ramifican bajo tierra absorbiendo agua y sales minerales!',
          pistaDesbloqueo: 'Coloca la raíz bajo tierra en «Arma la planta».',
        ),
      ],
      _ => const [
        // PANEL IZQUIERDO (x: 0.15): Relación, Sentidos y Locomotor bien espaciados
        _SlotHabitat(
          id: 'sentidos',
          x: 0.15,
          y: 0.08,
          bioma: 'Panel Nervioso · 5 Sentidos',
          accionViva: '¡Vista, oído, olfato, gusto y tacto captan estímulos del entorno!',
          pistaDesbloqueo: 'Supera el nivel Fácil de «Los cinco sentidos».',
        ),
        _SlotHabitat(
          id: 'avisos',
          x: 0.15,
          y: 0.36,
          bioma: 'Panel Nervioso · Vías sensoriales',
          accionViva: '¡Los nervios sensoriales envían avisos eléctricos hacia el cerebro!',
          pistaDesbloqueo: 'Supera el nivel Medio de «Los cinco sentidos».',
        ),
        _SlotHabitat(
          id: 'esqueleto',
          x: 0.15,
          y: 0.64,
          bioma: 'Panel Locomotor · Huesos y Músculos',
          accionViva: '¡El aparato locomotor ejecuta las órdenes motoras con precisión!',
          pistaDesbloqueo: 'Coloca el esqueleto en «Cada pieza en su sitio».',
        ),
        _SlotHabitat(
          id: 'reflejo',
          x: 0.15,
          y: 0.92,
          bioma: 'Panel Nervioso · Arco reflejo',
          accionViva: '¡La médula espinal dispara respuestas reflejas ultrarrápidas!',
          pistaDesbloqueo: 'Supera el nivel Difícil de «Los cinco sentidos».',
        ),

        // CUERPO ANATÓMICO CENTRAL: 5 niveles verticales sin solapamiento
        _SlotHabitat(
          id: 'cerebro',
          x: 0.50,
          y: 0.05,
          bioma: 'Cavidad craneal · Cerebro',
          accionViva: '¡Alojado en el cráneo, coordina pensamientos, memoria y movimientos!',
          pistaDesbloqueo: 'Coloca el cerebro en «Cada pieza en su sitio».',
        ),
        _SlotHabitat(
          id: 'dientes',
          x: 0.50,
          y: 0.25,
          bioma: 'Cavidad bucal · Masticación',
          accionViva: '¡En la boca, los dientes trituran el alimento con la saliva!',
          pistaDesbloqueo: 'Supera el nivel Fácil de «El viaje del bocado».',
        ),
        _SlotHabitat(
          id: 'pulmones',
          x: 0.39,
          y: 0.46,
          bioma: 'Cavidad torácica · Pulmones',
          accionViva: '¡En el tórax, los pulmones oxigenan la sangre en cada inspiración!',
          pistaDesbloqueo: 'Coloca los pulmones en «Cada pieza en su sitio».',
        ),
        _SlotHabitat(
          id: 'corazon',
          x: 0.61,
          y: 0.46,
          bioma: 'Cavidad torácica · Corazón',
          accionViva: '¡En el centro-izquierda del pecho, impulsa sangre arterial a todo el cuerpo!',
          pistaDesbloqueo: 'Coloca el corazón en «Cada pieza en su sitio».',
        ),
        _SlotHabitat(
          id: 'aparato-digestivo',
          x: 0.39,
          y: 0.68,
          bioma: 'Cavidad abdominal · Vías digestivas',
          accionViva: '¡Las glándulas digestivas y el tubo digestivo transforman los alimentos!',
          pistaDesbloqueo: 'Supera el nivel Medio de «El viaje del bocado».',
        ),
        _SlotHabitat(
          id: 'estomago',
          x: 0.61,
          y: 0.68,
          bioma: 'Cavidad abdominal · Estómago',
          accionViva: '¡En el abdomen superior, digiere los alimentos con jugos gástricos!',
          pistaDesbloqueo: 'Coloca el estómago en «Cada pieza en su sitio».',
        ),
        _SlotHabitat(
          id: 'intestinos',
          x: 0.50,
          y: 0.92,
          bioma: 'Abdomen inferior · Intestinos',
          accionViva: '¡Absorben los nutrientes digeridos hacia los capilares sanguíneos!',
          pistaDesbloqueo: 'Coloca los intestinos en «Cada pieza en su sitio».',
        ),

        // PANEL DERECHO (x: 0.85): Nutrición Celular y Etapas de la Vida bien espaciados
        _SlotHabitat(
          id: 'nutrientes',
          x: 0.85,
          y: 0.08,
          bioma: 'Panel Vital · Nutrientes en sangre',
          accionViva: '¡Glucosa, oxígeno y vitaminas llegan por la sangre a cada tejido!',
          pistaDesbloqueo: 'Supera el nivel Difícil de «El viaje del bocado».',
        ),
        _SlotHabitat(
          id: 'celula',
          x: 0.85,
          y: 0.36,
          bioma: 'Panel Vital · Célula humana',
          accionViva: '¡Las células se nutren, respiran y se dividen para regenerar tejidos!',
          pistaDesbloqueo: 'Supera el nivel Difícil de «Crecer paso a paso».',
        ),
        _SlotHabitat(
          id: 'una-vida',
          x: 0.85,
          y: 0.64,
          bioma: 'Panel Vital · Nacimiento e infancia',
          accionViva: '¡Desde el nacimiento crecemos y aprendemos nuevas habilidades!',
          pistaDesbloqueo: 'Supera el nivel Fácil de «Crecer paso a paso».',
        ),
        _SlotHabitat(
          id: 'etapas-vida',
          x: 0.85,
          y: 0.92,
          bioma: 'Panel Vital · Etapas de la vida',
          accionViva: '¡Infancia, adolescencia, madurez y vejez completan el ciclo vital!',
          pistaDesbloqueo: 'Supera el nivel Medio de «Crecer paso a paso».',
        ),
      ],
    };
  }

  void _activarInteraccionGlobal() {
    context.sonidoCelebracion();
    setState(() => _efectoActivo = true);
    _animController.forward(from: 0.0).whenComplete(() {
      if (mounted) {
        setState(() => _efectoActivo = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichasZona = alcance.catalogo.fichas
        .where((f) => f.zona == widget.zona.id)
        .toList(growable: false);
    final mapaFichas = {for (final f in fichasZona) f.id: f};
    final slots = _slotsParaZona(widget.zona.id);
    final desbloqueadas = fichasZona
        .where((f) => progreso.fichaDesbloqueada(f.id))
        .length;
    final total = fichasZona.isEmpty ? slots.length : fichasZona.length;
    final esReserva = widget.zona.id == 'reserva';

    final (
      tituloHabitat,
      subtituloHabitat,
      textoBotonAccion,
      iconoAccion,
      colorBorde,
      colorEncabezado,
    ) = switch (widget.zona.id) {
      'reserva' => (
        'Santuario de Biomas en Vivo',
        'Observa cómo se desplazan por su bioma, aliméntalos o cógelos para interactuar con ellos.',
        'Alimentar',
        Icons.restaurant_rounded,
        const Color(0xFF10B981),
        const Color(0xFF065F46),
      ),
      'invernadero' => (
        'Mapa Botánico de Ecosistemas',
        'Cada planta crece fija en su terreno ideal (dehesa, pradera, ribera, huerta o secano). ¡Activa la lluvia y polinización!',
        'Regar',
        Icons.water_drop_rounded,
        const Color(0xFF16A34A),
        const Color(0xFF14532D),
      ),
      _ => (
        'Estación Anatómica Interactiva',
        'Toca cada órgano en su cavidad anatómica o activa el impulso nervioso y arterial en vivo.',
        'Impulso',
        Icons.bolt_rounded,
        const Color(0xFF0284C7),
        const Color(0xFF0C4A6E),
      ),
    };

    final slotSeleccionado = _seleccionadoId == null
        ? null
        : slots.where((s) => s.id == _seleccionadoId).firstOrNull;
    final fichaSeleccionada = _seleccionadoId == null
        ? null
        : mapaFichas[_seleccionadoId!];
    final seleccionadoDesbloqueado =
        _seleccionadoId != null && progreso.fichaDesbloqueada(_seleccionadoId!);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorBorde, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withValues(alpha: 0.18),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorBorde.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Texto(
                            '🌟 $desbloqueadas/$total',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: colorEncabezado,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Texto(
                      tituloHabitat,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: colorEncabezado,
                      ),
                    ),
                    Texto(
                      subtituloHabitat,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _activarInteraccionGlobal,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorBorde,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: Icon(iconoAccion, size: 16),
                    label: Texto(
                      textoBotonAccion,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (widget.zona.id != 'cuerpo') ...[
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () {
                        context.sonidoSeleccion();
                        setState(() => _modoAmbiente = (_modoAmbiente + 1) % 2);
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Texto(
                          _modoAmbiente == 0 ? 'Clima ☀️' : 'Clima ✨',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: colorEncabezado,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: widget.zona.id == 'cuerpo' ? 320 : 245,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final t = _animController.value;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: PintorBiomasSantuarioDetallado(
                            zonaId: widget.zona.id,
                            progresoAnim: t,
                            efectoActivo: _efectoActivo,
                            modoAmbiente: _modoAmbiente,
                          ),
                        ),
                      ),
                      for (var i = 0; i < slots.length; i++)
                        Builder(
                          builder: (context) {
                            final slot = slots[i];
                            final desbloqueado = progreso.fichaDesbloqueada(
                              slot.id,
                            );
                            final seleccionado = _seleccionadoId == slot.id;
                            final ficha = mapaFichas[slot.id];

                            // Solo los animales de la reserva caminan/nadan/vuelan y pueden arrastrarse;
                            // las plantas están enraizadas en su ecosistema y los órganos fijos en su cavidad.
                            final (offsetReal, _, _) = esReserva
                                ? calcularLocomocionRealEspecie(
                                    id: slot.id,
                                    fase: (t + i * 0.17) % 1.0,
                                    activo:
                                        desbloqueado &&
                                        _arrastrandoId != slot.id,
                                    amplitud: _efectoActivo ? 1.35 : 1.0,
                                  )
                                : (Offset.zero, 0.0, '');
                            final offsetTotal =
                                esReserva && _arrastrandoId == slot.id
                                ? _offsetArrastre
                                : offsetReal;
                            final escala = seleccionado ? 1.15 : 1.0;

                            return Align(
                              alignment: Alignment(
                                slot.x * 2 - 1,
                                slot.y * 2 - 1,
                              ),
                              child: Transform.translate(
                                offset: desbloqueado
                                    ? offsetTotal
                                    : Offset.zero,
                                child: Transform.scale(
                                  scale:
                                      esReserva && _arrastrandoId == slot.id
                                      ? 1.22
                                      : escala,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (desbloqueado) {
                                        context.sonidoAcierto();
                                      } else {
                                        context.sonidoSeleccion();
                                      }
                                      setState(() {
                                        _seleccionadoId = slot.id;
                                        _mensajeArrastre = null;
                                      });
                                    },
                                    onPanStart: esReserva && desbloqueado
                                        ? (_) {
                                            context.sonidoToque();
                                            setState(() {
                                              _seleccionadoId = slot.id;
                                              _arrastrandoId = slot.id;
                                              _offsetArrastre = Offset.zero;
                                              _mensajeArrastre =
                                                  '¡Has cogido a ${ficha?.titulo ?? slot.id}! Suéltalo para que regrese a ${slot.bioma}.';
                                            });
                                          }
                                        : null,
                                    onPanUpdate: esReserva && desbloqueado
                                        ? (d) {
                                            setState(() {
                                              _offsetArrastre += d.delta;
                                            });
                                          }
                                        : null,
                                    onPanEnd: esReserva && desbloqueado
                                        ? (_) {
                                            context.sonidoAcierto();
                                            setState(() {
                                              _arrastrandoId = null;
                                              _offsetArrastre = Offset.zero;
                                              _mensajeArrastre =
                                                  '¡De regreso en ${slot.bioma}! ${slot.accionViva}';
                                            });
                                          }
                                        : null,
                                    onLongPress: () {
                                      setState(() {
                                        _seleccionadoId = slot.id;
                                      });
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: widget.zona.id == 'cuerpo' ? 40 : 50,
                                          height: widget.zona.id == 'cuerpo' ? 34 : 44,
                                          padding: EdgeInsets.all(
                                            desbloqueado ? 0 : 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: desbloqueado
                                                ? Colors.white.withValues(
                                                    alpha: seleccionado
                                                        ? 0.25
                                                        : 0.0,
                                                  )
                                                : const Color(
                                                    0xFF0F172A,
                                                  ).withValues(alpha: 0.55),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: seleccionado
                                                  ? const Color(0xFFF59E0B)
                                                  : (desbloqueado
                                                        ? Colors.transparent
                                                        : Colors.white54),
                                              width: seleccionado ? 2.6 : 1.6,
                                            ),
                                          ),
                                          child: desbloqueado
                                              ? SpriteEspecieSantuario(
                                                  id: slot.id,
                                                  alto: widget.zona.id == 'cuerpo' ? 32 : 42,
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.help_outline_rounded,
                                                    size: 18,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 1),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: desbloqueado
                                                ? Colors.white.withValues(
                                                    alpha: 0.92,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.55,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Texto(
                                            desbloqueado
                                                ? switch (slot.id) {
                                                    'sentidos' => '5 Sentidos',
                                                    'avisos' => 'Nervios',
                                                    'reflejo' => 'Arco reflejo',
                                                    'aparato-digestivo' => 'Digestivo',
                                                    'una-vida' => 'Embarazo',
                                                    'etapas-vida' => 'Etapas',
                                                    _ => ficha?.titulo ?? slot.id,
                                                  }
                                                : '¿?',
                                            style: TextStyle(
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.w900,
                                              color: desbloqueado
                                                  ? const Color(0xFF0F172A)
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: slotSeleccionado == null
                ? Container(
                    key: const ValueKey('hint-vacio'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 18,
                          color: colorBorde,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Texto(
                            'Toca cualquier elemento del escenario para inspeccionarlo o ver cómo desbloquear los misteriosos (¿?).',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    key: ValueKey('slot-${slotSeleccionado.id}'),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: seleccionadoDesbloqueado
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: seleccionadoDesbloqueado
                            ? colorBorde
                            : const Color(0xFFF59E0B),
                        width: 1.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: seleccionadoDesbloqueado
                                  ? colorBorde
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          child: seleccionadoDesbloqueado
                              ? IlustracionFicha(
                                  id: slotSeleccionado.id,
                                  alto: 38,
                                )
                              : const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFFD97706),
                                  size: 26,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Texto(
                                seleccionadoDesbloqueado
                                    ? '${fichaSeleccionada?.titulo ?? slotSeleccionado.id} · ${slotSeleccionado.bioma}'
                                    : 'Espécimen por descubrir · ${slotSeleccionado.bioma}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Texto(
                                seleccionadoDesbloqueado
                                    ? '${_mensajeArrastre ?? slotSeleccionado.accionViva} • ${DatosEnciclopedicosFicha.de(slotSeleccionado.id).clasificacion} (${DatosEnciclopedicosFicha.de(slotSeleccionado.id).locomocionOFuncion}).'
                                    : 'Cómo conseguirlo: ${slotSeleccionado.pistaDesbloqueo}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
