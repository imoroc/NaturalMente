import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/texto.dart';

enum AccionFinJuego { repetir, nivel, volver, explorar, extra }

class DatosFinJuego {
  const DatosFinJuego({
    required this.actividad,
    required this.nivel,
    required this.resumen,
    required this.onVolver,
    this.titulo = '¡Nivel superado!',
    this.onRepetir,
    this.onCambiarNivel,
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
  final VoidCallback? onExtra;
  final String? textoExtra;
  final String textoVolver;
}

/// Las acciones quedan a la vista incluso si el resumen necesita desplazarse.
class FinJuego extends StatefulWidget {
  const FinJuego({
    required this.datos,
    required this.guardado,
    required this.onGuardarDeNuevo,
    super.key,
  });

  final DatosFinJuego Function() datos;
  final Future<bool> guardado;
  final Future<bool> Function() onGuardarDeNuevo;

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
    return PopScope(
      canPop: !_guardando,
      child: Dialog.fullscreen(
        key: const Key('fin-juego'),
        backgroundColor: const Color(0xFFF7F4EB),
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
                          const DibujoMascota(gesto: 'feliz', tamano: 76),
                          const SizedBox(height: 12),
                          Semantics(
                            header: true,
                            child: Texto(
                              datos.titulo,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF157347),
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
                              avatar: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF16864B),
                                size: 20,
                              ),
                              label: Texto(datos.nivel),
                              backgroundColor: const Color(0xFFDCF5E4),
                              side: BorderSide.none,
                            ),
                          ],
                          const SizedBox(height: 18),
                          datos.resumen,
                          const SizedBox(height: 12),
                          if (_guardando)
                            Semantics(
                              liveRegion: true,
                              child: const Texto('Guardando tu progreso…'),
                            )
                          else if (_guardado)
                            const Texto('Tu progreso está guardado.')
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
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: color.withValues(alpha: .12)),
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
