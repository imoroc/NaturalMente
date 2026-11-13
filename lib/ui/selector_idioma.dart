import 'package:flutter/material.dart';
import 'package:naturalmente/datos/apariencia.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Conserva el acceso ES/EN del mapa; el panel permite varios cambios seguidos.
class SelectorIdioma extends StatelessWidget {
  const SelectorIdioma({super.key});

  Future<void> _abrir(BuildContext context, Idioma idioma) async {
    context.sonidoToque();
    final apariencia = AparienciaScope.of(context);
    final reducido = MediaQuery.disableAnimationsOf(context);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.tr('Cerrar ajustes'),
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: reducido ? 0 : 200),
      pageBuilder: (_, _, _) =>
          _PanelAjustes(idioma: idioma, apariencia: apariencia),
      transitionBuilder: (_, animacion, _, child) => FadeTransition(
        opacity: animacion.drive(CurveTween(curve: Curves.easeOut)),
        child: ScaleTransition(
          scale: animacion
              .drive(CurveTween(curve: Curves.easeOutCubic))
              .drive(Tween<double>(begin: .96, end: 1)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final idioma = IdiomaScope.of(context);
    if (idioma == null) return const SizedBox.shrink();
    final colores = context.coloresNaturales;
    return Tooltip(
      message: context.tr('Ajustes de Natu'),
      child: Material(
        color: colores.fondoAcierto,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colores.acierto.withValues(alpha: .65),
            width: 1.5,
          ),
        ),
        child: InkWell(
          key: const Key('selector-idioma'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _abrir(context, idioma),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, color: colores.acierto, size: 20),
                  const SizedBox(width: 7),
                  Text(
                    idioma.codigo.toUpperCase(),
                    style: TextStyle(
                      color: colores.acierto,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
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

class _PanelAjustes extends StatefulWidget {
  const _PanelAjustes({required this.idioma, required this.apariencia});
  final Idioma idioma;
  final Apariencia? apariencia;

  @override
  State<_PanelAjustes> createState() => _PanelAjustesState();
}

class _PanelAjustesState extends State<_PanelAjustes> {
  final Set<String> _guardando = {};
  String? _error;

  Future<void> _guardar(
    String grupo,
    Future<bool> Function() accion, {
    String error = 'No se han podido guardar los ajustes. Inténtalo de nuevo.',
    bool sonidoSeleccion = false,
  }) async {
    if (_guardando.contains(grupo)) return;
    setState(() {
      _guardando.add(grupo);
      _error = null;
    });
    var guardado = false;
    try {
      guardado = await accion();
    } catch (_) {
      guardado = false;
    }
    if (!mounted) return;
    if (guardado && sonidoSeleccion) context.sonidoSeleccion();
    setState(() {
      _guardando.remove(grupo);
      _error = guardado ? null : error;
    });
  }

  void _cerrar() {
    context.sonidoToque();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.idioma, ?widget.apariencia]),
    builder: (context, _) {
      final colores = context.coloresNaturales;
      final apariencia = widget.apariencia;
      return Dialog(
        key: const Key('panel-ajustes'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        constraints: const BoxConstraints(maxWidth: 440),
        backgroundColor: colores.tarjeta,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: colores.contorno.withValues(alpha: .6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 12, 18),
              child: Row(
                children: [
                  const DibujoMascota(tamano: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Texto(
                      'Ajustes de Natu',
                      style: TextStyle(
                        color: colores.tinta,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    key: const Key('cerrar-ajustes'),
                    tooltip: context.tr('Cerrar ajustes'),
                    onPressed: _cerrar,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                key: const Key('contenido-ajustes'),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (apariencia != null) ...[
                      const _TituloSeccion('Apariencia'),
                      const SizedBox(height: 10),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (i, modo) in const [
                              ModoApariencia.claro,
                              ModoApariencia.oscuro,
                              ModoApariencia.sistema,
                            ].indexed) ...[
                              if (i > 0) const SizedBox(width: 8),
                              Expanded(
                                child: _OpcionAjuste(
                                  key: Key('apariencia-${modo.name}'),
                                  etiqueta: modo == ModoApariencia.sistema
                                      ? 'Auto'
                                      : modo.etiqueta,
                                  ayuda: modo.etiqueta,
                                  icono: switch (modo) {
                                    ModoApariencia.claro =>
                                      Icons.light_mode_rounded,
                                    ModoApariencia.oscuro =>
                                      Icons.dark_mode_rounded,
                                    ModoApariencia.sistema =>
                                      Icons.phone_android_rounded,
                                  },
                                  seleccionada: apariencia.modo == modo,
                                  habilitada: !_guardando.contains(
                                    'apariencia',
                                  ),
                                  onTap: () {
                                    if (apariencia.modo == modo) return;
                                    _guardar(
                                      'apariencia',
                                      () => apariencia.elegir(modo),
                                      error: 'No se ha podido guardar la apariencia. Inténtalo de nuevo.',
                                      sonidoSeleccion: true,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Texto(
                        switch (apariencia.modo) {
                          ModoApariencia.sistema => 'Según el teléfono',
                          ModoApariencia.claro => 'Siempre claro',
                          ModoApariencia.oscuro => 'Siempre oscuro',
                        },
                        style: TextStyle(fontSize: 12.5, color: colores.tenue),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const _TituloSeccion('Idioma'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final (i, opcion) in const [
                          ('es', 'Español'),
                          ('en', 'English'),
                        ].indexed) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _OpcionAjuste(
                              key: Key('idioma-${opcion.$1}'),
                              etiqueta: opcion.$2,
                              seleccionada: widget.idioma.codigo == opcion.$1,
                              habilitada: !_guardando.contains('idioma'),
                              onTap: () => _guardar(
                                'idioma',
                                () => widget.idioma.elegir(opcion.$1),
                                error: 'No se ha podido guardar el idioma. Inténtalo de nuevo.',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    const _TituloSeccion('Sonido y vibración'),
                    const SizedBox(height: 10),
                    Material(
                      color: colores.fondo,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Column(
                          children: [
                            _interruptor(
                              'sonido',
                              'Efectos de sonido',
                              widget.idioma.sonido,
                              Icons.volume_up_rounded,
                              Icons.volume_off_rounded,
                              widget.idioma.cambiarSonido,
                            ),
                            Divider(
                              height: 1,
                              indent: 52,
                              endIndent: 8,
                              color: colores.contorno.withValues(alpha: .35),
                            ),
                            _interruptor(
                              'musica',
                              'Música de fondo',
                              widget.idioma.musica,
                              Icons.music_note_rounded,
                              Icons.music_off_rounded,
                              widget.idioma.cambiarMusica,
                            ),
                            Divider(
                              height: 1,
                              indent: 52,
                              endIndent: 8,
                              color: colores.contorno.withValues(alpha: .35),
                            ),
                            _interruptor(
                              'vibracion',
                              'Vibración al tocar',
                              widget.idioma.vibracion,
                              Icons.vibration_rounded,
                              Icons.smartphone_rounded,
                              widget.idioma.cambiarVibracion,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: _AvisoAjustes(_error!),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('listo-ajustes'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  onPressed: _cerrar,
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Texto('Listo'),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _interruptor(
    String id,
    String titulo,
    bool activo,
    IconData iconoActivo,
    IconData iconoInactivo,
    Future<bool> Function(bool) cambiar,
  ) {
    final colores = context.coloresNaturales;
    return SwitchListTile.adaptive(
      key: Key('ajuste-$id'),
      value: activo,
      onChanged: _guardando.contains(id)
          ? null
          : (valor) => _guardar(id, () => cambiar(valor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      secondary: Icon(
        activo ? iconoActivo : iconoInactivo,
        size: 23,
        color: activo ? colores.acierto : colores.tenue,
      ),
      title: Texto(
        titulo,
        style: TextStyle(
          color: colores.tinta,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
      subtitle: Texto(
        activo ? 'Activado' : 'Desactivado',
        style: TextStyle(color: colores.tenue, fontSize: 12, height: 1.4),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.titulo);
  final String titulo;
  @override
  Widget build(BuildContext context) => Texto(
    titulo,
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: context.coloresNaturales.tinta,
    ),
  );
}

/// Respuesta táctil breve y selección visible sin depender solo del color.
class _OpcionAjuste extends StatefulWidget {
  const _OpcionAjuste({
    required this.etiqueta,
    required this.seleccionada,
    required this.habilitada,
    required this.onTap,
    this.icono,
    this.ayuda,
    super.key,
  });
  final String etiqueta;
  final String? ayuda;
  final IconData? icono;
  final bool seleccionada;
  final bool habilitada;
  final VoidCallback onTap;
  @override
  State<_OpcionAjuste> createState() => _OpcionAjusteState();
}

class _OpcionAjusteState extends State<_OpcionAjuste> {
  bool _pulsada = false;
  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final duracion = Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 140,
    );
    return Semantics(
      button: true,
      selected: widget.seleccionada,
      enabled: widget.habilitada,
      inMutuallyExclusiveGroup: true,
      label: context.tr(widget.ayuda ?? widget.etiqueta),
      child: Tooltip(
        message: context.tr(widget.ayuda ?? widget.etiqueta),
        child: AnimatedScale(
          scale: _pulsada ? .96 : 1,
          duration: duracion,
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: duracion,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 1.5,
                color: widget.seleccionada
                    ? colores.acierto
                    : colores.contorno.withValues(alpha: .65),
              ),
              color: widget.seleccionada
                  ? colores.fondoAcierto
                  : colores.tarjeta,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: widget.habilitada ? widget.onTap : null,
                onHighlightChanged: (valor) => setState(() => _pulsada = valor),
                child: ExcludeSemantics(
                  child: Stack(
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: widget.icono == null ? 48 : 78,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: widget.icono == null ? 14 : 12,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icono != null) ...[
                                  Icon(
                                    widget.icono,
                                    size: 24,
                                    color: widget.seleccionada
                                        ? colores.acierto
                                        : colores.tenue,
                                  ),
                                  const SizedBox(height: 7),
                                ],
                                Texto(
                                  widget.etiqueta,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: widget.seleccionada
                                        ? colores.acierto
                                        : colores.tinta,
                                    fontWeight: FontWeight.w800,
                                    fontSize: widget.icono == null ? 14 : 12.5,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 5,
                        child: AnimatedSwitcher(
                          duration: duracion,
                          child: widget.seleccionada
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  key: const ValueKey(true),
                                  size: 14,
                                  color: colores.acierto,
                                )
                              : const SizedBox(
                                  key: ValueKey(false),
                                  width: 14,
                                  height: 14,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvisoAjustes extends StatelessWidget {
  const _AvisoAjustes(this.texto);
  final String texto;
  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('error-ajustes'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colores.fondoPista,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: colores.pista, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Texto(
                texto,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: colores.pista,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
