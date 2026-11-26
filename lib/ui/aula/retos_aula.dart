import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/ui/aula/juego_aula_page.dart' show ImagenDeAula;
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Lo que hace la pantalla con cada intento del niño.
///
/// [completa] es `false` en un acierto parcial (una pareja de varias): se
/// celebra, pero el reto sigue. Devuelve si el intento se ha aceptado (no lo
/// está si la pantalla aún muestra el anterior).
typedef EvaluarReto = bool Function(bool correcto, {bool completa});

/// La parte interactiva de un reto. La pregunta y la pista las pinta la
/// pantalla del juego; aquí van las respuestas, piezas o huecos.
class VistaReto extends StatelessWidget {
  const VistaReto({
    required this.reto,
    required this.resuelto,
    required this.evaluar,
    required this.semilla,
    super.key,
  });

  final RetoAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;

  /// Para barajar igual mientras dura el reto.
  final int semilla;

  @override
  Widget build(BuildContext context) => switch (reto) {
    final PreguntaAula r => _VistaPregunta(reto: r, resuelto: resuelto, evaluar: evaluar),
    final ClasificarAula r => _VistaClasificar(reto: r, resuelto: resuelto, evaluar: evaluar, semilla: semilla),
    final OrdenarAula r => _VistaOrdenar(reto: r, resuelto: resuelto, evaluar: evaluar, semilla: semilla),
    final ParejasAula r => _VistaParejas(reto: r, evaluar: evaluar, semilla: semilla),
    final HuecosAula r => _VistaHuecos(reto: r, resuelto: resuelto, evaluar: evaluar, semilla: semilla),
    final BuscarAula r => _VistaBuscar(reto: r, resuelto: resuelto, evaluar: evaluar),
    final NumeroAula r => _VistaNumero(reto: r, resuelto: resuelto, evaluar: evaluar),
    final PalabraAula r => _VistaPalabra(reto: r, resuelto: resuelto, evaluar: evaluar, semilla: semilla),
    LecturaAula() => const SizedBox.shrink(),
  };
}

List<int> _barajar(int n, int semilla, {bool distintoDelOrden = false}) {
  final orden = List.generate(n, (i) => i);
  final azar = math.Random(semilla);
  for (var intento = 0; intento < 10; intento++) {
    orden.shuffle(azar);
    if (!distintoDelOrden || n < 2) break;
    var igual = true;
    for (var i = 0; i < n; i++) {
      if (orden[i] != i) igual = false;
    }
    if (!igual) break;
  }
  return orden;
}

enum EstadoFicha { normal, elegida, bien, mal, usada }

/// Una pieza que se puede tocar: texto, imagen o ambos.
class FichaAula extends StatelessWidget {
  const FichaAula({
    required this.opcion,
    required this.onTap,
    this.estado = EstadoFicha.normal,
    this.traducir = false,
    this.compacta = false,
    this.prefijo,
    super.key,
  });

  final OpcionAula opcion;
  final VoidCallback? onTap;
  final EstadoFicha estado;
  final bool traducir;
  final bool compacta;
  final String? prefijo;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final (fondo, borde, icono) = switch (estado) {
      EstadoFicha.bien => (colores.fondoAcierto, colores.acierto, Icons.check_circle_rounded),
      EstadoFicha.mal => (colores.fondoPista, colores.pista, Icons.close_rounded),
      EstadoFicha.elegida => (
        colores.superficie(const Color(0xFFE3F1FB)),
        colores.borde(const Color(0xFF2F78B7)),
        null,
      ),
      EstadoFicha.usada => (colores.fondo, colores.contorno.withValues(alpha: 0.4), null),
      EstadoFicha.normal => (colores.tarjeta, colores.contorno, null),
    };
    final texto = traducir ? context.tr(opcion.texto) : opcion.texto;
    final imagenLado = compacta ? 44.0 : 64.0;
    return Semantics(
      button: onTap != null,
      selected: estado == EstadoFicha.elegida || estado == EstadoFicha.bien,
      label: [?prefijo, if (texto.isNotEmpty) texto].join(' '),
      child: ExcludeSemantics(
        child: Opacity(
          opacity: estado == EstadoFicha.usada ? 0.35 : 1,
          child: Material(
            color: fondo,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                constraints: BoxConstraints(minHeight: compacta ? 44 : 54),
                padding: EdgeInsets.symmetric(horizontal: compacta ? 10 : 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borde, width: estado == EstadoFicha.normal ? 2 : 3),
                ),
                child: Row(
                  mainAxisSize: compacta ? MainAxisSize.min : MainAxisSize.max,
                  children: [
                    if (prefijo != null) ...[
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: borde,
                        child: Text(
                          prefijo!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (opcion.imagen case final imagen?) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(width: imagenLado, height: imagenLado, child: ImagenDeAula(imagen)),
                      ),
                      if (texto.isNotEmpty) const SizedBox(width: 10),
                    ],
                    if (texto.isNotEmpty)
                      Flexible(
                        fit: compacta ? FlexFit.loose : FlexFit.tight,
                        child: Text(
                          texto,
                          style: TextStyle(
                            fontSize: compacta ? 16 : 18,
                            fontWeight: FontWeight.w800,
                            color: colores.tinta,
                          ),
                        ),
                      ),
                    if (icono != null) ...[const SizedBox(width: 6), Icon(icono, color: borde)],
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

class _BotonComprobar extends StatelessWidget {
  const _BotonComprobar({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: FilledButton.icon(
      key: const Key('comprobar-aula'),
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      onPressed: onPressed,
      icon: const Icon(Icons.check_rounded),
      label: const Texto('Comprobar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
    ),
  );
}

Widget _titulo(BuildContext context, String texto) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Texto(
    texto,
    style: TextStyle(
      color: context.coloresNaturales.tenue,
      fontWeight: FontWeight.w800,
      fontSize: 14,
    ),
  ),
);

// --- Elegir la respuesta y verdadero o falso --------------------------------

class _VistaPregunta extends StatefulWidget {
  const _VistaPregunta({required this.reto, required this.resuelto, required this.evaluar});
  final PreguntaAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;

  @override
  State<_VistaPregunta> createState() => _VistaPreguntaState();
}

class _VistaPreguntaState extends State<_VistaPregunta> {
  final Set<int> _descartadas = {};

  @override
  Widget build(BuildContext context) {
    final r = widget.reto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < r.opciones.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          FichaAula(
            key: Key('opcion-aula-$i'),
            opcion: r.opciones[i],
            traducir: r.tipo == TipoReto.verdaderoFalso,
            estado: widget.resuelto && i == r.correcta
                ? EstadoFicha.bien
                : (_descartadas.contains(i) ? EstadoFicha.mal : EstadoFicha.normal),
            onTap: widget.resuelto || _descartadas.contains(i)
                ? null
                : () {
                    final correcto = i == r.correcta;
                    if (widget.evaluar(correcto) && !correcto) {
                      setState(() => _descartadas.add(i));
                    }
                  },
          ),
        ],
      ],
    );
  }
}

// --- Clasificar en grupos ---------------------------------------------------

class _VistaClasificar extends StatefulWidget {
  const _VistaClasificar({required this.reto, required this.resuelto, required this.evaluar, required this.semilla});
  final ClasificarAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;
  final int semilla;

  @override
  State<_VistaClasificar> createState() => _VistaClasificarState();
}

class _VistaClasificarState extends State<_VistaClasificar> {
  late final List<int> _orden = _barajar(widget.reto.elementos.length, widget.semilla);

  /// Elemento → grupo donde lo ha puesto el niño.
  final Map<int, int> _colocados = {};
  int? _elegido;
  Set<int> _mal = {};

  void _colocar(int grupo) {
    final e = _elegido;
    if (e == null) return;
    context.sonidoSeleccion();
    setState(() {
      _colocados[e] = grupo;
      _elegido = null;
      _mal = {};
    });
  }

  void _comprobar() {
    final mal = {
      for (final MapEntry(key: e, value: g) in _colocados.entries)
        if (widget.reto.elementos[e].grupo != g) e,
    };
    if (widget.evaluar(mal.isEmpty) && mal.isNotEmpty) setState(() => _mal = mal);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reto;
    final colores = context.coloresNaturales;
    final sueltos = [for (final i in _orden) if (!_colocados.containsKey(i)) i];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sueltos.isNotEmpty) ...[
          _titulo(context, _elegido == null ? 'Toca una tarjeta y luego su grupo' : 'Ahora toca su grupo'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in sueltos)
                FichaAula(
                  key: Key('clasificar-elemento-$i'),
                  compacta: true,
                  opcion: r.elementos[i].elemento,
                  estado: _elegido == i ? EstadoFicha.elegida : EstadoFicha.normal,
                  onTap: widget.resuelto ? null : () {
                    context.sonidoToque();
                    setState(() => _elegido = _elegido == i ? null : i);
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        for (var g = 0; g < r.grupos.length; g++) ...[
          if (g > 0) const SizedBox(height: 10),
          Material(
            key: Key('clasificar-grupo-$g'),
            color: _elegido != null ? colores.superficie(const Color(0xFFE3F1FB)) : colores.tarjeta,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _elegido == null || widget.resuelto ? null : () => _colocar(g),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(minHeight: 72),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _elegido != null ? colores.borde(const Color(0xFF2F78B7)) : colores.contorno,
                    width: 2.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (r.grupos[g].imagen case final imagen?) ...[
                          SizedBox(width: 36, height: 36, child: ImagenDeAula(imagen)),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            r.grupos[g].texto,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: colores.tinta),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final i in _orden)
                          if (_colocados[i] == g)
                            FichaAula(
                              key: Key('clasificado-$i'),
                              compacta: true,
                              opcion: r.elementos[i].elemento,
                              estado: widget.resuelto
                                  ? EstadoFicha.bien
                                  : (_mal.contains(i) ? EstadoFicha.mal : EstadoFicha.normal),
                              onTap: widget.resuelto ? null : () {
                                context.sonidoQuitar();
                                setState(() {
                                  _colocados.remove(i);
                                  _mal = {};
                                });
                              },
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (!widget.resuelto)
          _BotonComprobar(onPressed: sueltos.isEmpty ? _comprobar : null),
      ],
    );
  }
}

// --- Ordenar ----------------------------------------------------------------

class _VistaOrdenar extends StatefulWidget {
  const _VistaOrdenar({required this.reto, required this.resuelto, required this.evaluar, required this.semilla});
  final OrdenarAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;
  final int semilla;

  @override
  State<_VistaOrdenar> createState() => _VistaOrdenarState();
}

class _VistaOrdenarState extends State<_VistaOrdenar> {
  late final List<int> _orden = _barajar(widget.reto.pasos.length, widget.semilla, distintoDelOrden: true);
  final List<int> _elegidos = [];
  Set<int> _mal = {};

  void _comprobar() {
    final mal = {
      for (var pos = 0; pos < _elegidos.length; pos++)
        if (_elegidos[pos] != pos) pos,
    };
    if (widget.evaluar(mal.isEmpty) && mal.isNotEmpty) setState(() => _mal = mal);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reto;
    final completo = _elegidos.length == r.pasos.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titulo(context, 'Toca los pasos en orden, del primero al último'),
        for (var pos = 0; pos < _elegidos.length; pos++) ...[
          FichaAula(
            key: Key('ordenado-$pos'),
            prefijo: '${pos + 1}',
            opcion: r.pasos[_elegidos[pos]],
            estado: widget.resuelto
                ? EstadoFicha.bien
                : (_mal.contains(pos) ? EstadoFicha.mal : EstadoFicha.elegida),
            onTap: widget.resuelto ? null : () {
              context.sonidoQuitar();
              setState(() {
                _elegidos.removeRange(pos, _elegidos.length);
                _mal = {};
              });
            },
          ),
          const SizedBox(height: 8),
        ],
        if (!completo) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in _orden)
                if (!_elegidos.contains(i))
                  FichaAula(
                    key: Key('ordenar-paso-$i'),
                    compacta: true,
                    opcion: r.pasos[i],
                    onTap: () {
                      context.sonidoToque();
                      setState(() {
                        _elegidos.add(i);
                        _mal = {};
                      });
                    },
                  ),
            ],
          ),
        ],
        if (!widget.resuelto) _BotonComprobar(onPressed: completo ? _comprobar : null),
      ],
    );
  }
}

// --- Unir parejas -------------------------------------------------------------

class _VistaParejas extends StatefulWidget {
  const _VistaParejas({required this.reto, required this.evaluar, required this.semilla});
  final ParejasAula reto;
  final EvaluarReto evaluar;
  final int semilla;

  @override
  State<_VistaParejas> createState() => _VistaParejasState();
}

class _VistaParejasState extends State<_VistaParejas> {
  late final List<int> _izquierda = _barajar(widget.reto.parejas.length, widget.semilla);
  late final List<int> _derecha = _barajar(widget.reto.parejas.length, widget.semilla + 7, distintoDelOrden: true);
  final Set<int> _unidas = {};
  int? _a;
  int? _b;
  (int, int)? _fallida;

  void _tocar({int? a, int? b}) {
    context.sonidoToque();
    setState(() {
      _fallida = null;
      if (a != null) _a = _a == a ? null : a;
      if (b != null) _b = _b == b ? null : b;
    });
    final ia = _a, ib = _b;
    if (ia == null || ib == null) return;
    final correcto = ia == ib;
    final completa = correcto && _unidas.length + 1 == widget.reto.parejas.length;
    if (!widget.evaluar(correcto, completa: completa)) return;
    setState(() {
      if (correcto) {
        _unidas.add(ia);
      } else {
        _fallida = (ia, ib);
      }
      _a = null;
      _b = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reto;
    EstadoFicha estado(int i, int? elegido, bool izquierda) {
      if (_unidas.contains(i)) return EstadoFicha.bien;
      final f = _fallida;
      if (f != null && (izquierda ? f.$1 : f.$2) == i) return EstadoFicha.mal;
      return elegido == i ? EstadoFicha.elegida : EstadoFicha.normal;
    }

    Widget columna(List<int> orden, bool izquierda) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final i in orden) ...[
          FichaAula(
            key: Key('pareja-${izquierda ? 'a' : 'b'}-$i'),
            compacta: true,
            opcion: izquierda ? r.parejas[i].$1 : r.parejas[i].$2,
            estado: estado(i, izquierda ? _a : _b, izquierda),
            onTap: _unidas.contains(i) ? null : () => izquierda ? _tocar(a: i) : _tocar(b: i),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titulo(context, 'Toca una tarjeta de cada lado para unirlas'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: columna(_izquierda, true)),
            const SizedBox(width: 10),
            Expanded(child: columna(_derecha, false)),
          ],
        ),
      ],
    );
  }
}

// --- Completar la frase -------------------------------------------------------

class _VistaHuecos extends StatefulWidget {
  const _VistaHuecos({required this.reto, required this.resuelto, required this.evaluar, required this.semilla});
  final HuecosAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;
  final int semilla;

  @override
  State<_VistaHuecos> createState() => _VistaHuecosState();
}

class _VistaHuecosState extends State<_VistaHuecos> {
  late final List<String> _banco = [...widget.reto.respuestas, ...widget.reto.distractores];
  late final List<int> _orden = _barajar(_banco.length, widget.semilla);

  /// Hueco → palabra del banco que ha puesto el niño.
  late final List<int?> _puestas = List.filled(widget.reto.respuestas.length, null);
  Set<int> _mal = {};

  static String _normal(String s) => s.trim().toLowerCase();

  void _comprobar() {
    final respuestas = widget.reto.respuestas;
    final mal = {
      for (var h = 0; h < respuestas.length; h++)
        if (_normal(_banco[_puestas[h]!]) != _normal(respuestas[h])) h,
    };
    if (widget.evaluar(mal.isEmpty) && mal.isNotEmpty) setState(() => _mal = mal);
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final estilo = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colores.tinta, height: 1.6);
    var hueco = 0;
    final piezas = <Widget>[];
    for (final parte in widget.reto.partes) {
      if (!parte.hueco) {
        for (final palabra in parte.texto.split(RegExp(r'(?<=\s)'))) {
          if (palabra.isNotEmpty) piezas.add(Text(palabra, style: estilo));
        }
        continue;
      }
      final h = hueco++;
      final puesta = _puestas[h];
      piezas.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          child: FichaAula(
            key: Key('hueco-$h'),
            compacta: true,
            opcion: OpcionAula(texto: puesta == null ? '      ' : _banco[puesta]),
            estado: widget.resuelto
                ? EstadoFicha.bien
                : (_mal.contains(h) ? EstadoFicha.mal : (puesta == null ? EstadoFicha.normal : EstadoFicha.elegida)),
            onTap: puesta == null || widget.resuelto ? null : () {
              context.sonidoQuitar();
              setState(() {
                _puestas[h] = null;
                _mal = {};
              });
            },
          ),
        ),
      );
    }
    final completo = !_puestas.contains(null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: colores.tarjeta, borderRadius: BorderRadius.circular(16)),
          child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: piezas),
        ),
        if (!widget.resuelto) ...[
          const SizedBox(height: 14),
          _titulo(context, 'Toca las palabras para rellenar los huecos'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in _orden)
                FichaAula(
                  key: Key('hueco-palabra-$i'),
                  compacta: true,
                  opcion: OpcionAula(texto: _banco[i]),
                  estado: _puestas.contains(i) ? EstadoFicha.usada : EstadoFicha.normal,
                  onTap: _puestas.contains(i) || completo ? null : () {
                    context.sonidoToque();
                    setState(() {
                      _puestas[_puestas.indexOf(null)] = i;
                      _mal = {};
                    });
                  },
                ),
            ],
          ),
          _BotonComprobar(onPressed: completo ? _comprobar : null),
        ],
      ],
    );
  }
}

// --- Tocar en la imagen -------------------------------------------------------

class _VistaBuscar extends StatefulWidget {
  const _VistaBuscar({required this.reto, required this.resuelto, required this.evaluar});
  final BuscarAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;

  @override
  State<_VistaBuscar> createState() => _VistaBuscarState();
}

class _VistaBuscarState extends State<_VistaBuscar> {
  final List<Offset> _fallos = [];
  ZonaAula? _acertada;

  void _tocar(Offset punto, Size tamano) {
    if (widget.resuelto) return;
    final x = punto.dx / tamano.width, y = punto.dy / tamano.height;
    final zona = widget.reto.zonas.where((z) => z.contiene(x, y)).firstOrNull;
    if (!widget.evaluar(zona != null)) return;
    setState(() {
      if (zona != null) {
        _acertada = zona;
      } else {
        _fallos.add(Offset(x, y));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final imagen = widget.reto.imagen;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titulo(context, 'Toca en la imagen'),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: LayoutBuilder(
              builder: (context, medidas) {
                final tamano = medidas.biggest;
                Widget marca(Offset p, Color color, IconData icono) => Positioned(
                  left: p.dx * tamano.width - 18,
                  top: p.dy * tamano.height - 18,
                  child: IgnorePointer(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Icon(icono, color: Colors.white),
                    ),
                  ),
                );
                return GestureDetector(
                  key: const Key('buscar-imagen'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _tocar(d.localPosition, tamano),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imagen != null) ImagenDeAula(imagen, ajuste: BoxFit.cover),
                      for (final f in _fallos) marca(f, colores.pista, Icons.close_rounded),
                      if (_acertada case final z?)
                        Positioned(
                          left: (z.x - z.radio) * tamano.width,
                          top: z.y * tamano.height - z.radio * tamano.width,
                          child: IgnorePointer(
                            child: Container(
                              width: z.radio * 2 * tamano.width,
                              height: z.radio * 2 * tamano.width,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colores.acierto, width: 5),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// --- Adivinar el número -------------------------------------------------------

class _VistaNumero extends StatefulWidget {
  const _VistaNumero({required this.reto, required this.resuelto, required this.evaluar});
  final NumeroAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;

  @override
  State<_VistaNumero> createState() => _VistaNumeroState();
}

class _VistaNumeroState extends State<_VistaNumero> {
  String _cifras = '';
  bool _mal = false;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    Widget tecla(String texto, VoidCallback? onTap, {Key? key}) => SizedBox(
      width: 64,
      height: 56,
      child: FilledButton.tonal(
        key: key,
        style: FilledButton.styleFrom(padding: EdgeInsets.zero, textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        onPressed: widget.resuelto ? null : onTap,
        child: Text(texto),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: const Key('numero-pantalla'),
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.resuelto ? colores.fondoAcierto : (_mal ? colores.fondoPista : colores.tarjeta),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.resuelto ? colores.acierto : (_mal ? colores.pista : colores.contorno),
              width: 3,
            ),
          ),
          child: Text(
            _cifras.isEmpty ? '?' : _cifras,
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: colores.tinta, fontFamily: 'NunitoInicio'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0])
              tecla('$d', _cifras.length >= 4 ? null : () {
                context.sonidoToque();
                setState(() {
                  _cifras = _cifras == '0' ? '$d' : '$_cifras$d';
                  _mal = false;
                });
              }, key: Key('numero-tecla-$d')),
            SizedBox(
              width: 64,
              height: 56,
              child: IconButton.filledTonal(
                key: const Key('numero-borrar'),
                tooltip: context.tr('Borrar'),
                onPressed: _cifras.isEmpty || widget.resuelto ? null : () {
                  context.sonidoQuitar();
                  setState(() {
                    _cifras = _cifras.substring(0, _cifras.length - 1);
                    _mal = false;
                  });
                },
                icon: const Icon(Icons.backspace_rounded),
              ),
            ),
          ],
        ),
        if (!widget.resuelto)
          _BotonComprobar(
            onPressed: _cifras.isEmpty ? null : () {
              final correcto = int.parse(_cifras) == widget.reto.respuesta;
              if (widget.evaluar(correcto) && !correcto) setState(() => _mal = true);
            },
          ),
      ],
    );
  }
}

// --- Formar la palabra --------------------------------------------------------

class _VistaPalabra extends StatefulWidget {
  const _VistaPalabra({required this.reto, required this.resuelto, required this.evaluar, required this.semilla});
  final PalabraAula reto;
  final bool resuelto;
  final EvaluarReto evaluar;
  final int semilla;

  @override
  State<_VistaPalabra> createState() => _VistaPalabraState();
}

class _VistaPalabraState extends State<_VistaPalabra> {
  late final List<String> _letras = widget.reto.letras;
  late final List<int> _orden = _barajar(_letras.length, widget.semilla, distintoDelOrden: true);
  final List<int> _puestas = [];
  bool _mal = false;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final completa = _puestas.length == _letras.length;
    Widget casilla(String letra, EstadoFicha estado, VoidCallback? onTap, Key key) => SizedBox(
      width: 46,
      height: 54,
      child: Material(
        key: key,
        color: switch (estado) {
          EstadoFicha.bien => colores.fondoAcierto,
          EstadoFicha.mal => colores.fondoPista,
          EstadoFicha.usada => colores.fondo,
          _ => colores.tarjeta,
        },
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: switch (estado) {
                  EstadoFicha.bien => colores.acierto,
                  EstadoFicha.mal => colores.pista,
                  _ => colores.contorno,
                },
                width: 2.5,
              ),
            ),
            child: Text(
              letra,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: estado == EstadoFicha.usada ? colores.contorno : colores.tinta,
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var pos = 0; pos < _letras.length; pos++)
              casilla(
                pos < _puestas.length ? _letras[_puestas[pos]] : '',
                widget.resuelto ? EstadoFicha.bien : (_mal ? EstadoFicha.mal : EstadoFicha.normal),
                pos < _puestas.length && !widget.resuelto
                    ? () {
                        context.sonidoQuitar();
                        setState(() {
                          _puestas.removeRange(pos, _puestas.length);
                          _mal = false;
                        });
                      }
                    : null,
                Key('palabra-hueco-$pos'),
              ),
          ],
        ),
        if (!widget.resuelto) ...[
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final i in _orden)
                casilla(
                  _letras[i],
                  _puestas.contains(i) ? EstadoFicha.usada : EstadoFicha.normal,
                  _puestas.contains(i) || completa ? null : () {
                    context.sonidoToque();
                    setState(() {
                      _puestas.add(i);
                      _mal = false;
                    });
                  },
                  Key('letra-$i'),
                ),
            ],
          ),
          _BotonComprobar(
            onPressed: completa
                ? () {
                    final palabra = [for (final i in _puestas) _letras[i]].join();
                    final correcto = palabra == _letras.join();
                    if (widget.evaluar(correcto) && !correcto) setState(() => _mal = true);
                  }
                : null,
          ),
        ],
      ],
    );
  }
}
