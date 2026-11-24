import 'package:flutter/material.dart';
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Column(
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
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: Texto(
                                nuevos.length == 1
                                    ? 'Ver tu nuevo cromo'
                                    : 'Ver tus nuevos cromos',
                              ),
                              onPressed: () =>
                                  abrirCelebracionCromos(context, nuevos),
                            ),
                            const SizedBox(height: 6),
                          ],
                          if (!esPartida) datos.resumen,
                          const SizedBox(height: 12),
                          if (_guardando)
                            Semantics(
                              liveRegion: true,
                              child: const Texto('Guardando tu progreso…'),
                            )
                          else if (_guardado)
                            const Texto(
                              'Tu progreso está guardado.',
                              textAlign: TextAlign.center,
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
                          if (esPartida) ...[
                            const SizedBox(height: 14),
                            Texto(
                              '¿Qué quieres hacer?',
                              style: TextStyle(
                                fontFamily: 'NunitoInicio',
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: context.coloresNaturales.tinta,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (siguiente != null) ...[
                                  _TarjetaFin(
                                    key: const Key('fin-siguiente'),
                                    arte: 'siguiente',
                                    titulo: 'Probar el siguiente nivel',
                                    detalle: siguiente.nombre,
                                    fondo: const Color(0xFFE5F5D8),
                                    borde: const Color(0xFF24A85D),
                                    onTap: habilitado
                                        ? () =>
                                              _elegir(AccionFinJuego.siguiente)
                                        : null,
                                  ),
                                  const SizedBox(height: 9),
                                ] else if (datos.onCambiarNivel != null) ...[
                                  _TarjetaFin(
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
                                _TarjetaFin(
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
                                _TarjetaFin(
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

class _TarjetaFin extends StatelessWidget {
  const _TarjetaFin({
    required this.arte,
    required this.titulo,
    required this.fondo,
    required this.borde,
    required this.onTap,
    this.detalle,
    super.key,
  });

  final String arte;
  final String titulo;
  final String? detalle;
  final Color fondo;
  final Color borde;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final radio = BorderRadius.circular(19);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colores.sombra(borde),
        borderRadius: radio,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Material(
          color: colores.superficie(fondo),
          shape: RoundedRectangleBorder(
            borderRadius: radio,
            side: BorderSide(color: colores.borde(borde), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Opacity(
              opacity: onTap == null ? .55 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/cromos/$arte.webp',
                      width: 62,
                      height: 49,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Texto(
                            titulo,
                            style: TextStyle(
                              fontFamily: 'NunitoInicio',
                              color: colores.tinta,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          if (detalle case final nivel?)
                            Texto(
                              nivel,
                              style: TextStyle(color: colores.tenue),
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
      ),
    );
  }
}
