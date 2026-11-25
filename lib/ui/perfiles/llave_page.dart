import 'package:flutter/material.dart';

import 'package:naturalmente/datos/aula/aula.dart';
import 'package:naturalmente/datos/aula/llave.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Los tres dibujos y el número, grandes para que un mayor les haga una foto.
class LlaveVisual extends StatelessWidget {
  const LlaveVisual({required this.llave, this.tamano = 64, super.key});

  final Llave llave;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final nombres = [
      for (final d in llave.dibujos) context.tr(dibujosLlave[d]!.$2),
    ];
    return Semantics(
      label: '${nombres.join(', ')}, ${llave.numero}',
      child: ExcludeSemantics(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in llave.dibujos)
              _Casilla(tamano: tamano, child: Text(dibujosLlave[d]!.$1)),
            _Casilla(
              tamano: tamano,
              fondo: colores.superficie(const Color(0xFFFFF3C4)),
              child: Text(
                llave.numero.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: colores.tinta,
                  fontFamily: 'NunitoInicio',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({required this.tamano, required this.child, this.fondo});
  final double tamano;
  final Widget child;
  final Color? fondo;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Container(
      width: tamano,
      height: tamano,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo ?? colores.tarjeta,
        borderRadius: BorderRadius.circular(tamano * 0.25),
        border: Border.all(color: colores.contorno, width: 2.5),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontSize: tamano * 0.5),
        child: FittedBox(child: child),
      ),
    );
  }
}

/// Apartado «Mi llave mágica» dentro de la pantalla de cada Natu.
class SeccionMiLlave extends StatefulWidget {
  const SeccionMiLlave({required this.aula, required this.perfilId, super.key});

  final Aula aula;
  final String perfilId;

  @override
  State<SeccionMiLlave> createState() => _SeccionMiLlaveState();
}

class _SeccionMiLlaveState extends State<SeccionMiLlave> {
  bool _ocupada = false;
  String? _aviso;

  Future<void> _crear() async {
    setState(() {
      _ocupada = true;
      _aviso = null;
    });
    final nube = await widget.aula.crearLlave(widget.perfilId);
    if (!mounted) return;
    setState(() {
      _ocupada = false;
      _aviso = nube == null
          ? 'Para crear la llave hace falta conexión. Inténtalo luego.'
          : null;
    });
  }

  Future<void> _cambiar() async {
    final seguro = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Texto('¿Cambiar la llave?'),
        content: const Texto(
          'La llave de ahora dejará de servir y las otras tablets donde juegas tendrán que usar la nueva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Texto('Cancelar'),
          ),
          TextButton(
            key: const Key('confirmar-cambiar-llave'),
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Texto('Cambiar'),
          ),
        ],
      ),
    );
    if (seguro != true || !mounted) return;
    setState(() {
      _ocupada = true;
      _aviso = null;
    });
    final nueva = await widget.aula.cambiarLlave(widget.perfilId);
    if (!mounted) return;
    setState(() {
      _ocupada = false;
      _aviso = nueva == null
          ? 'Para cambiar la llave hace falta conexión. Inténtalo luego.'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return ListenableBuilder(
      listenable: widget.aula,
      builder: (context, _) {
        final nube = widget.aula.perfilNube(widget.perfilId);
        final llave = nube == null ? null : Llave.leer(nube.llave);
        return Container(
          key: const Key('seccion-llave'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colores.superficie(const Color(0xFFF3EEFF)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('🔑', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Texto(
                      'Mi llave mágica',
                      style: TextStyle(
                        color: colores.tinta,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (llave != null) ...[
                Texto(
                  'Con tu nombre y esta llave juegas con tu Natu en otra tablet o en casa. Pide a un mayor que le haga una foto.',
                  style: TextStyle(color: colores.tenue),
                ),
                const SizedBox(height: 14),
                LlaveVisual(key: const Key('mi-llave'), llave: llave),
                const SizedBox(height: 10),
                Align(
                  child: TextButton.icon(
                    key: const Key('cambiar-llave'),
                    onPressed: _ocupada ? null : _cambiar,
                    icon: const Icon(Icons.autorenew_rounded),
                    label: const Texto('Cambiar llave'),
                  ),
                ),
              ] else ...[
                Texto(
                  'Crea una llave para jugar con tu Natu en otra tablet o en casa sin perder nada.',
                  style: TextStyle(color: colores.tenue),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('crear-llave'),
                  onPressed: _ocupada ? null : _crear,
                  icon: _ocupada
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.key_rounded),
                  label: const Texto('Crear mi llave'),
                ),
              ],
              if (_aviso case final aviso?) ...[
                const SizedBox(height: 10),
                Texto(aviso, style: TextStyle(color: colores.pista)),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Recuperar un Natu en este dispositivo con su nombre y su llave.
class CanjearLlavePage extends StatefulWidget {
  const CanjearLlavePage({required this.aula, super.key});
  final Aula aula;

  @override
  State<CanjearLlavePage> createState() => _CanjearLlavePageState();
}

class _CanjearLlavePageState extends State<CanjearLlavePage> {
  String? _animal;
  String? _adjetivo;
  final List<String> _dibujos = [];
  final List<int> _cifras = [];
  bool _abriendo = false;
  String? _aviso;

  bool get _completa =>
      _animal != null &&
      _adjetivo != null &&
      _dibujos.length == 3 &&
      _cifras.length == 2;

  void _borrar() {
    context.sonidoQuitar();
    setState(() {
      if (_cifras.isNotEmpty) {
        _cifras.removeLast();
      } else if (_dibujos.isNotEmpty) {
        _dibujos.removeLast();
      }
    });
  }

  Future<void> _abrir() async {
    if (!_completa || _abriendo) return;
    setState(() {
      _abriendo = true;
      _aviso = null;
    });
    final resultado = await widget.aula.canjearLlave(
      _animal!,
      _adjetivo!,
      Llave(List.of(_dibujos), _cifras[0] * 10 + _cifras[1]),
    );
    if (!mounted) return;
    if (resultado == ResultadoCanje.recuperado) {
      context.sonidoCelebracion();
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _abriendo = false;
      _aviso = switch (resultado) {
        ResultadoCanje.noCoincide =>
          'Ese nombre y esa llave no coinciden. Revisa la foto de tu llave.',
        ResultadoCanje.bloqueado =>
          'Has probado muchas veces. Espera una hora y vuelve a intentarlo.',
        ResultadoCanje.lleno =>
          'En esta tablet ya hay 8 jugadores. Borra uno para traer tu Natu.',
        _ => 'Hace falta conexión para traer tu Natu. Inténtalo luego.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final idioma = IdiomaScope.of(context)?.codigo ?? 'es';
    final titulo = TextStyle(
      color: colores.tinta,
      fontSize: 18,
      fontWeight: FontWeight.w900,
    );
    final mote = _animal != null && _adjetivo != null
        ? Perfil(
            id: '_',
            animal: _animal!,
            adjetivo: _adjetivo!,
            color: 'naranja',
          ).mote(idioma)
        : null;

    Widget chip(
      String clave,
      String texto,
      bool elegido,
      VoidCallback alElegir,
    ) => ChoiceChip(
      key: Key(clave),
      label: Text(texto),
      selected: elegido,
      showCheckmark: false,
      onSelected: (_) {
        context.sonidoSeleccion();
        alElegir();
      },
    );

    return Scaffold(
      backgroundColor: colores.fondo,
      appBar: AppBar(
        backgroundColor: colores.fondo,
        title: const Texto('Tengo una llave'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                const Center(
                  child: DibujoMascota(gesto: 'pensando', tamano: 84),
                ),
                const SizedBox(height: 16),
                Texto('1. ¿Cómo se llama tu Natu?', style: titulo),
                const SizedBox(height: 4),
                Text(
                  mote ?? '…',
                  key: const Key('llave-mote'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colores.tinta,
                    fontFamily: 'NunitoInicio',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final MapEntry(key: id, value: (es, en))
                        in animalesMote.entries)
                      chip(
                        'llave-animal-$id',
                        idioma == 'en' ? en : es,
                        _animal == id,
                        () => setState(() => _animal = id),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final MapEntry(key: id, value: (es, en))
                        in adjetivosMote.entries)
                      chip(
                        'llave-adjetivo-$id',
                        idioma == 'en' ? en : es,
                        _adjetivo == id,
                        () => setState(() => _adjetivo = id),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Texto('2. Toca los tres dibujos de tu llave', style: titulo),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _Casilla(
                        tamano: 56,
                        child: Text(
                          i < _dibujos.length
                              ? dibujosLlave[_dibujos[i]]!.$1
                              : ' ',
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    for (var i = 0; i < 2; i++)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: _Casilla(
                          tamano: 44,
                          fondo: colores.superficie(const Color(0xFFFFF3C4)),
                          child: Text(
                            i < _cifras.length ? '${_cifras[i]}' : ' ',
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final MapEntry(key: id, value: (emoji, nombre))
                        in dibujosLlave.entries)
                      Semantics(
                        button: true,
                        label: context.tr(nombre),
                        child: InkWell(
                          key: Key('llave-dibujo-$id'),
                          borderRadius: BorderRadius.circular(14),
                          onTap: _dibujos.length >= 3
                              ? null
                              : () {
                                  context.sonidoToque();
                                  setState(() => _dibujos.add(id));
                                },
                          child: _Casilla(
                            tamano: 52,
                            child: ExcludeSemantics(child: Text(emoji)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Texto('3. Y el número', style: titulo),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var n = 0; n <= 9; n++)
                      InkWell(
                        key: Key('llave-numero-$n'),
                        borderRadius: BorderRadius.circular(14),
                        onTap: _cifras.length >= 2 || _dibujos.length < 3
                            ? null
                            : () {
                                context.sonidoToque();
                                setState(() => _cifras.add(n));
                              },
                        child: _Casilla(
                          tamano: 52,
                          fondo: colores.superficie(const Color(0xFFFFF3C4)),
                          child: Text(
                            '$n',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    IconButton.filledTonal(
                      key: const Key('llave-borrar'),
                      tooltip: context.tr('Borrar'),
                      iconSize: 28,
                      onPressed: _dibujos.isEmpty && _cifras.isEmpty
                          ? null
                          : _borrar,
                      icon: const Icon(Icons.backspace_rounded),
                    ),
                  ],
                ),
                if (_aviso case final aviso?) ...[
                  const SizedBox(height: 16),
                  Texto(
                    aviso,
                    key: const Key('llave-mensaje'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colores.pista,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton.icon(
                  key: const Key('llave-abrir'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: _completa && !_abriendo ? _abrir : null,
                  icon: _abriendo
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.lock_open_rounded),
                  label: const Texto(
                    'Traer mi Natu',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
