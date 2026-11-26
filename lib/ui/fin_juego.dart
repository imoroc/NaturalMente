import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/ui/accion_natu.dart';
import 'package:naturalmente/ui/carta_cromo.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/texto.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/ui/cromos_zona.dart';

enum AccionFinJuego { repetir, siguiente, nivel, volver, explorar, extra }

typedef SiguienteNivel = ({String nombre, VoidCallback empezar});

SiguienteNivel? prepararSiguienteNivel<T>(
  List<T> niveles,
  T? actual,
  String Function(T) nombre,
  ValueChanged<T> empezar,
) {
  if (actual == null) return null;
  final indice = niveles.indexOf(actual);
  if (indice < 0 || indice + 1 >= niveles.length) return null;
  final siguiente = niveles[indice + 1];
  return (nombre: nombre(siguiente), empezar: () => empezar(siguiente));
}

class DatosFinJuego {
  const DatosFinJuego({
    required this.actividad,
    required this.nivel,
    required this.resumen,
    required this.onVolver,
    this.titulo = '¡Nivel superado!',
    this.onRepetir,
    this.onCambiarNivel,
    this.siguiente,
    this.onExtra,
    this.textoExtra,
    this.textoVolver = 'Volver al mundo',
  });

  final String actividad;
  final String nivel;
  final String titulo;
  final Widget resumen;
  final VoidCallback onVolver;
  final VoidCallback? onRepetir;
  final VoidCallback? onCambiarNivel;
  final SiguienteNivel? siguiente;
  final VoidCallback? onExtra;
  final String? textoExtra;
  final String textoVolver;
}

/// Resultado compartido de los niveles y del reto diario.
class FinJuego extends StatefulWidget {
  const FinJuego({
    required this.datos,
    required this.guardado,
    required this.onGuardarDeNuevo,
    this.cromosNuevos,
    super.key,
  });

  final DatosFinJuego Function() datos;
  final Future<bool> guardado;
  final Future<bool> Function() onGuardarDeNuevo;
  final List<Ficha> Function()? cromosNuevos;

  @override
  State<FinJuego> createState() => _FinJuegoState();
}

class _FinJuegoState extends State<FinJuego> {
  bool _guardando = true;
  bool _guardado = false;

  @override
  void initState() {
    super.initState();
    _esperarGuardado(widget.guardado);
  }

  Future<void> _esperarGuardado(Future<bool> tarea) async {
    final guardado = await tarea;
    if (!mounted) return;
    setState(() {
      _guardado = guardado;
      _guardando = false;
    });
  }

  void _elegir(AccionFinJuego accion) {
    context.sonidoToque();
    Navigator.of(context).pop(accion);
  }

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos();
    final color = Theme.of(context).colorScheme.primary;
    final esPartida = datos.onRepetir != null;
    final siguiente = datos.siguiente;
    final nuevos = esPartida && _guardado
        ? widget.cromosNuevos?.call() ?? const <Ficha>[]
        : const <Ficha>[];
    final habilitado = _guardado && !_guardando;
    return PopScope(
      canPop: !_guardando,
      child: Dialog.fullscreen(
        key: const Key('fin-juego'),
        backgroundColor: context.coloresNaturales.superficie(
          const Color(0xFFF7F4EB),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      key: const Key('fin-seguir'),
                      tooltip: context.tr('Seguir explorando'),
                      onPressed: _guardando
                          ? null
                          : () => _elegir(AccionFinJuego.explorar),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  Expanded(
                    child: _ContenidoFinJuego(
                      centrar: esPartida,
                      children: [
                        if (esPartida)
                          Image.asset(
                            'assets/cromos/natu-victoria.webp',
                            height: 118,
                            fit: BoxFit.contain,
                            excludeFromSemantics: true,
                          )
                        else
                          const DibujoMascota(gesto: 'feliz', tamano: 76),
                        const SizedBox(height: 12),
                        Semantics(
                          header: true,
                          child: Texto(
                            datos.titulo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: esPartida ? 'NunitoInicio' : null,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: context.coloresNaturales.contenido(
                                Color(0xFF157347),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Texto(
                          datos.actividad,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (datos.nivel.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Chip(
                            avatar: Icon(
                              Icons.check_circle_rounded,
                              color: context.coloresNaturales.contenido(
                                Color(0xFF16864B),
                              ),
                              size: 20,
                            ),
                            label: Texto(datos.nivel),
                            backgroundColor: context.coloresNaturales
                                .superficie(const Color(0xFFDCF5E4)),
                            side: BorderSide.none,
                          ),
                        ],
                        const SizedBox(height: 18),
                        if (nuevos.isNotEmpty) ...[
                          FilledButton.tonalIcon(
                            key: const Key('fin-cromos-nuevos'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(64, 56),
                            ),
                            icon: _IconoCromosNuevos(fichas: nuevos),
                            label: Texto(
                              nuevos.length == 1
                                  ? 'Ver tu nuevo cromo'
                                  : 'Ver tus nuevos cromos',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'NunitoInicio',
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            onPressed: () =>
                                abrirCelebracionCromos(context, nuevos),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (!esPartida) datos.resumen,
                        if (!habilitado) ...[
                          const SizedBox(height: 12),
                          if (_guardando)
                            Semantics(
                              liveRegion: true,
                              child: const Texto('Guardando tu progreso…'),
                            )
                          else ...[
                            Semantics(
                              liveRegion: true,
                              child: const Texto(
                                'No he podido guardar tu progreso. Puedes intentarlo otra vez.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextButton.icon(
                              key: const Key('fin-guardar'),
                              onPressed: () {
                                setState(() => _guardando = true);
                                _esperarGuardado(widget.onGuardarDeNuevo());
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Texto('Guardar de nuevo'),
                            ),
                          ],
                          if (esPartida) const SizedBox(height: 14),
                        ],
                        if (esPartida) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (siguiente != null) ...[
                                AccionNatu(
                                  key: const Key('fin-siguiente'),
                                  arte: 'siguiente',
                                  titulo: 'Probar el siguiente nivel',
                                  detalle: siguiente.nombre,
                                  fondo: const Color(0xFFE5F5D8),
                                  borde: const Color(0xFF24A85D),
                                  onTap: habilitado
                                      ? () => _elegir(AccionFinJuego.siguiente)
                                      : null,
                                ),
                                const SizedBox(height: 9),
                              ] else if (datos.onCambiarNivel != null) ...[
                                AccionNatu(
                                  key: const Key('fin-nivel'),
                                  arte: 'siguiente',
                                  titulo: 'Elegir nivel',
                                  fondo: const Color(0xFFE5F5D8),
                                  borde: const Color(0xFF24A85D),
                                  onTap: habilitado
                                      ? () => _elegir(AccionFinJuego.nivel)
                                      : null,
                                ),
                                const SizedBox(height: 9),
                              ],
                              AccionNatu(
                                key: const Key('fin-repetir'),
                                arte: 'repetir',
                                titulo: 'Jugar otra vez',
                                fondo: const Color(0xFFFFEAD0),
                                borde: const Color(0xFFE49029),
                                onTap: habilitado
                                    ? () => _elegir(AccionFinJuego.repetir)
                                    : null,
                              ),
                              const SizedBox(height: 9),
                              AccionNatu(
                                key: const Key('fin-volver'),
                                arte: 'volver',
                                titulo: datos.textoVolver,
                                fondo: const Color(0xFFDDF2FC),
                                borde: const Color(0xFF249ACD),
                                onTap: habilitado
                                    ? () => _elegir(AccionFinJuego.volver)
                                    : null,
                              ),
                              if (siguiente != null &&
                                  datos.onCambiarNivel != null)
                                TextButton(
                                  key: const Key('fin-nivel'),
                                  onPressed: habilitado
                                      ? () => _elegir(AccionFinJuego.nivel)
                                      : null,
                                  child: const Texto('Elegir nivel'),
                                ),
                            ],
                          ),
                          ExpansionTile(
                            title: const Texto('Resumen de la partida'),
                            children: [datos.resumen],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!esPartida)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: context.coloresNaturales.borde(
                              color.withValues(alpha: .12),
                            ),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (datos.onCambiarNivel != null) ...[
                            FilledButton.icon(
                              key: const Key('fin-nivel'),
                              onPressed: _guardado && !_guardando
                                  ? () => _elegir(AccionFinJuego.nivel)
                                  : null,
                              icon: const Icon(Icons.explore_rounded),
                              label: const Texto('Cambiar nivel'),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (datos.onRepetir != null) ...[
                            OutlinedButton.icon(
                              key: const Key('fin-repetir'),
                              onPressed: _guardado && !_guardando
                                  ? () => _elegir(AccionFinJuego.repetir)
                                  : null,
                              icon: const Icon(Icons.replay_rounded),
                              label: const Texto('Otra vez'),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (datos.onExtra != null) ...[
                            OutlinedButton.icon(
                              key: const Key('fin-extra'),
                              onPressed: _guardado && !_guardando
                                  ? () => _elegir(AccionFinJuego.extra)
                                  : null,
                              icon: const Icon(Icons.checkroom_rounded),
                              label: Texto(datos.textoExtra!),
                            ),
                            const SizedBox(height: 8),
                          ],
                          FilledButton.tonalIcon(
                            key: const Key('fin-volver'),
                            onPressed: _guardado && !_guardando
                                ? () => _elegir(AccionFinJuego.volver)
                                : null,
                            icon: const Icon(Icons.map_rounded),
                            label: Texto(datos.textoVolver),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContenidoFinJuego extends StatelessWidget {
  const _ContenidoFinJuego({required this.centrar, required this.children});

  final bool centrar;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final margen = centrar
        ? const EdgeInsets.fromLTRB(24, 8, 24, 8)
        : const EdgeInsets.fromLTRB(24, 0, 24, 16);
    return LayoutBuilder(
      builder: (context, medidas) => SingleChildScrollView(
        padding: margen,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: centrar
                ? math.max(0, medidas.maxHeight - margen.vertical)
                : 0,
          ),
          child: Column(
            mainAxisAlignment: centrar
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _IconoCromosNuevos extends StatelessWidget {
  const _IconoCromosNuevos({required this.fichas});

  final List<Ficha> fichas;

  @override
  Widget build(BuildContext context) {
    final varios = fichas.length > 1;
    return ExcludeSemantics(
      child: SizedBox(
        width: varios ? 48 : 38,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (varios)
              Positioned(
                right: 4,
                child: Transform.rotate(
                  angle: math.pi / 18,
                  child: _CromoEnBoton(ficha: fichas[1]),
                ),
              ),
            Positioned(
              left: varios ? 4 : 5,
              child: Transform.rotate(
                angle: varios ? -math.pi / 14 : -math.pi / 26,
                child: _CromoEnBoton(ficha: fichas.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CromoEnBoton extends StatelessWidget {
  const _CromoEnBoton({required this.ficha});

  final Ficha ficha;

  @override
  Widget build(BuildContext context) {
    final (borde, metal) = switch (ficha.acabado) {
      AcabadoCromo.laton => (
        const Color(0xFF9A702C),
        const [Color(0xFFFFE8A6), Color(0xFFC89142), Color(0xFFFFE5A4)],
      ),
      AcabadoCromo.nacar => (
        const Color(0xFF638B84),
        const [Color(0xFFC0ECDA), Color(0xFFF2BFD6), Color(0xFFFFF2D1)],
      ),
    };
    return Container(
      width: 28,
      height: 38,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: metal,
        ),
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0x55412D18), offset: Offset(1, 1)),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IlustracionCromo(ficha, alto: 19),
            const SizedBox(height: 2),
            SizedBox(width: 9, height: 1, child: ColoredBox(color: borde)),
          ],
        ),
      ),
    );
  }
}
