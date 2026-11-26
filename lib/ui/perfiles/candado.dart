import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:naturalmente/datos/aula/llave.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/aula/escenas.dart';
import 'package:naturalmente/ui/perfiles/quien_juega.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Tres casillas y los 16 dibujos de la llave para elegirlos en orden.
class SelectorTresDibujos extends StatefulWidget {
  const SelectorTresDibujos({required this.alCompletar, this.tamano = 54, super.key});

  /// Se llama al tocar el tercer dibujo. Devuelve si hay que vaciar las casillas.
  final bool Function(List<String> dibujos) alCompletar;
  final double tamano;

  @override
  State<SelectorTresDibujos> createState() => _SelectorTresDibujosState();
}

class _SelectorTresDibujosState extends State<SelectorTresDibujos> {
  final List<String> _elegidos = [];

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    Widget casilla(Widget hijo, {Key? key, VoidCallback? onTap, Color? fondo}) => Material(
      key: key,
      color: fondo ?? colores.tarjeta,
      borderRadius: BorderRadius.circular(widget.tamano * 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(widget.tamano * 0.25),
        onTap: onTap,
        child: Container(
          width: widget.tamano,
          height: widget.tamano,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.tamano * 0.25),
            border: Border.all(color: colores.contorno, width: 2.5),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: widget.tamano * 0.5),
            child: hijo,
          ),
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              casilla(
                Text(i < _elegidos.length ? '•' : ''),
                fondo: i < _elegidos.length ? colores.superficie(const Color(0xFFE3F1FB)) : null,
              ),
            ],
            const SizedBox(width: 10),
            IconButton.filledTonal(
              key: const Key('candado-borrar'),
              tooltip: context.tr('Borrar'),
              onPressed: _elegidos.isEmpty ? null : () => setState(_elegidos.removeLast),
              icon: const Icon(Icons.backspace_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final MapEntry(key: id, value: (emoji, nombre)) in dibujosLlave.entries)
              Semantics(
                button: true,
                label: context.tr(nombre),
                child: casilla(
                  ExcludeSemantics(child: Text(emoji)),
                  key: Key('candado-dibujo-$id'),
                  onTap: () {
                    context.sonidoToque();
                    setState(() => _elegidos.add(id));
                    if (_elegidos.length == 3) {
                      final vaciar = widget.alCompletar(List.of(_elegidos));
                      if (vaciar && mounted) setState(_elegidos.clear);
                    }
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Tapa la app mientras el jugador activo no abra su candado. Se pone por
/// encima de todas las pantallas, así que una partida a medias no se pierde.
/// Tras 5 minutos con la app en segundo plano los candados se vuelven a cerrar.
class GuardiaCandado extends StatefulWidget {
  const GuardiaCandado({required this.perfiles, required this.child, super.key});

  final Perfiles perfiles;
  final Widget child;

  @override
  State<GuardiaCandado> createState() => _GuardiaCandadoState();
}

class _GuardiaCandadoState extends State<GuardiaCandado> with WidgetsBindingObserver {
  DateTime? _fuera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.paused || estado == AppLifecycleState.hidden) {
      _fuera ??= DateTime.now();
    } else if (estado == AppLifecycleState.resumed) {
      final desde = _fuera;
      _fuera = null;
      if (desde != null && DateTime.now().difference(desde) > const Duration(minutes: 5)) {
        widget.perfiles.cerrarCandados();
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.perfiles,
    builder: (context, _) {
      final bloqueado = widget.perfiles.necesitaCandado(widget.perfiles.activo.id);
      return Stack(
        fit: StackFit.expand,
        children: [
          // La app sigue montada debajo, sin poder tocarse.
          ExcludeSemantics(
            excluding: bloqueado,
            child: AbsorbPointer(absorbing: bloqueado, child: widget.child),
          ),
          if (bloqueado)
            Overlay(
              initialEntries: [
                OverlayEntry(builder: (_) => PantallaCandado(perfiles: widget.perfiles)),
              ],
            ),
        ],
      );
    },
  );
}

enum _Vista { candado, otros, mayor }

class PantallaCandado extends StatefulWidget {
  const PantallaCandado({required this.perfiles, super.key});
  final Perfiles perfiles;

  @override
  State<PantallaCandado> createState() => _PantallaCandadoState();
}

class _PantallaCandadoState extends State<PantallaCandado> {
  _Vista _vista = _Vista.candado;
  bool _fallo = false;
  late (int, int) _cuenta = _nuevaCuenta();
  String _respuesta = '';

  static (int, int) _nuevaCuenta() {
    final azar = math.Random();
    return (6 + azar.nextInt(4), 6 + azar.nextInt(4));
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final perfiles = widget.perfiles;
    final perfil = perfiles.activo;
    final titulo = TextStyle(
      color: colores.tinta,
      fontFamily: 'NunitoInicio',
      fontSize: 26,
      fontWeight: FontWeight.w900,
    );

    final Widget contenido = switch (_vista) {
      _Vista.candado => Column(
        key: const Key('pantalla-candado'),
        mainAxisSize: MainAxisSize.min,
        children: [
          NatuDePerfil(perfiles: perfiles, perfil: perfil, tamano: 110),
          const SizedBox(height: 10),
          Text(moteDe(context, perfil), style: titulo, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Texto(
            _fallo ? 'Esos no son. Prueba otra vez.' : 'Toca tus tres dibujos secretos',
            key: const Key('candado-mensaje'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _fallo ? colores.pista : colores.tenue,
            ),
          ),
          const SizedBox(height: 16),
          SelectorTresDibujos(
            alCompletar: (dibujos) {
              final ok = perfiles.abrirCandado(perfil.id, dibujos);
              if (ok) {
                context.sonidoSeleccion();
              } else {
                context.sonidoPista();
                setState(() => _fallo = true);
              }
              return !ok;
            },
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              if (perfiles.lista.length > 1)
                TextButton.icon(
                  key: const Key('candado-otro'),
                  onPressed: () => setState(() => _vista = _Vista.otros),
                  icon: const Icon(Icons.people_alt_rounded),
                  label: const Texto('Soy otro jugador'),
                ),
              TextButton.icon(
                key: const Key('candado-olvidado'),
                onPressed: () => setState(() {
                  _vista = _Vista.mayor;
                  _cuenta = _nuevaCuenta();
                  _respuesta = '';
                }),
                icon: const Icon(Icons.help_outline_rounded),
                label: const Texto('He olvidado mis dibujos'),
              ),
            ],
          ),
        ],
      ),
      _Vista.otros => Column(
        key: const Key('candado-lista'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Texto('¿Quién juega?', style: titulo),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final p in perfiles.lista)
                InkWell(
                  key: Key('candado-perfil-${p.id}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    context.sonidoToque();
                    await perfiles.elegir(p.id);
                    if (mounted) setState(() => _vista = _Vista.candado);
                  },
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      children: [
                        NatuDePerfil(perfiles: perfiles, perfil: p, tamano: 64),
                        const SizedBox(height: 4),
                        Text(
                          moteDe(context, p),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w800, color: colores.tinta),
                        ),
                        if (perfiles.candado(p.id) != null) const Text('🔒'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _vista = _Vista.candado),
            child: const Texto('Volver'),
          ),
        ],
      ),
      _Vista.mayor => Column(
        key: const Key('candado-mayor'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Texto('Pide ayuda a un mayor', style: titulo, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Texto(
            'Para quitar el candado de {0}, resuelve esta cuenta:'.replaceAll('{0}', moteDe(context, perfil)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '${_cuenta.$1} × ${_cuenta.$2} = ${_respuesta.isEmpty ? '?' : _respuesta}',
            key: const Key('candado-cuenta'),
            style: titulo,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
                SizedBox(
                  width: 56,
                  height: 52,
                  child: FilledButton.tonal(
                    key: Key('candado-tecla-$d'),
                    style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: _respuesta.length >= 2 ? null : () => setState(() => _respuesta += '$d'),
                    child: Text('$d', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                ),
              SizedBox(
                width: 56,
                height: 52,
                child: IconButton.filledTonal(
                  onPressed: _respuesta.isEmpty
                      ? null
                      : () => setState(() => _respuesta = _respuesta.substring(0, _respuesta.length - 1)),
                  icon: const Icon(Icons.backspace_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            key: const Key('candado-quitar'),
            onPressed: _respuesta.isEmpty
                ? null
                : () async {
                    if (int.tryParse(_respuesta) == _cuenta.$1 * _cuenta.$2) {
                      await perfiles.fijarCandado(perfil.id, null);
                    } else {
                      setState(() {
                        _cuenta = _nuevaCuenta();
                        _respuesta = '';
                      });
                    }
                  },
            child: const Texto('Quitar el candado'),
          ),
          TextButton(
            onPressed: () => setState(() => _vista = _Vista.candado),
            child: const Texto('Volver'),
          ),
        ],
      ),
    };

    return Material(
      color: colores.fondo,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // El mismo fondo a cualquier tamaño: sin franjas vacías a los lados.
          const ExcludeSemantics(child: EscenaAula('pradera')),
          ColoredBox(color: colores.fondo.withValues(alpha: 0.55)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 560),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colores.tarjeta.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: contenido,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Apartado «Candado» en la pantalla de cada Natu.
class SeccionCandado extends StatefulWidget {
  const SeccionCandado({required this.perfiles, required this.perfilId, super.key});
  final Perfiles perfiles;
  final String perfilId;

  @override
  State<SeccionCandado> createState() => _SeccionCandadoState();
}

class _SeccionCandadoState extends State<SeccionCandado> {
  bool _eligiendo = false;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final tiene = widget.perfiles.candado(widget.perfilId) != null;
    return Container(
      key: const Key('seccion-candado'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colores.superficie(const Color(0xFFFFF3E0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(tiene ? '🔒' : '🔓', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Texto(
                  'Candado',
                  style: TextStyle(color: colores.tinta, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Texto(
            tiene
                ? 'Para jugar con esta Natu hay que tocar sus tres dibujos secretos.'
                : 'Si compartes el dispositivo, pon un candado para que nadie juegue con tu Natu.',
            style: TextStyle(color: colores.tenue),
          ),
          const SizedBox(height: 12),
          if (_eligiendo) ...[
            const Texto('Elige tus tres dibujos secretos y recuérdalos:', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            SelectorTresDibujos(
              alCompletar: (dibujos) {
                widget.perfiles.fijarCandado(widget.perfilId, dibujos).then((_) {
                  if (mounted) setState(() => _eligiendo = false);
                });
                return false;
              },
            ),
          ] else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('poner-candado'),
                  onPressed: () => setState(() => _eligiendo = true),
                  icon: const Icon(Icons.lock_rounded),
                  label: Texto(tiene ? 'Cambiar los dibujos' : 'Poner candado'),
                ),
                if (tiene)
                  TextButton.icon(
                    key: const Key('quitar-candado'),
                    onPressed: () async {
                      await widget.perfiles.fijarCandado(widget.perfilId, null);
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Texto('Quitar candado'),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
