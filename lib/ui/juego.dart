import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:naturalmente/ui/burbuja.dart';
import 'package:naturalmente/ui/dibujos.dart';

class JuegoPage extends StatefulWidget {
  const JuegoPage({required this.actividad, super.key});

  final Actividad actividad;

  @override
  State<JuegoPage> createState() => _JuegoPageState();
}

class _JuegoPageState extends State<JuegoPage> {
  var _reto = 0;
  var _listo = false;
  int _intento = 1;
  Resultado? _resultado;
  final Map<String, String> _valores = {};
  final List<String> _orden = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listo) return;
    _listo = true;
    final actividad = widget.actividad;
    if (actividad.tipo != 'lugar' || actividad.retos.isEmpty) return;
    final progreso = Alcance.of(context).progreso;
    final pendiente = actividad.retos.indexWhere(
      (reto) => !progreso.retoHecho(actividad, reto),
    );
    _reto = pendiente < 0 ? actividad.retos.length - 1 : pendiente;
  }

  @override
  Widget build(BuildContext context) {
    final actividad = widget.actividad;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          _titulo(actividad),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: switch (actividad.tipo) {
        'lugar' => _Lugar(
          actividad: actividad,
          reto: actividad.retos[_reto],
          indice: _reto,
          total: actividad.retos.length,
          resultado: _resultado,
          pie: _resultado?.acierto == true
              ? (_reto < actividad.retos.length - 1 ? 'Siguiente' : 'Volver')
              : null,
          onSoltar: _soltar,
          onPie: _resultado?.acierto == true && _reto < actividad.retos.length - 1
              ? _siguiente
              : _volver,
        ),
        'controles' => _Controles(
          actividad: actividad,
          valores: _valores,
          resultado: _resultado,
          frase: _fraseControles(),
          onElegir: (control, opcion) => setState(() => _valores[control] = opcion),
          onAvanzar: _avanzar,
          onOtraVez: _resultado?.estado == 'brote' ? _otraVez : null,
        ),
        _ => _Orden(
          actividad: actividad,
          orden: _orden,
          resultado: _resultado,
          onAnadir: (id) => setState(() {
            _orden.add(id);
            _resultado = null;
          }),
          onQuitar: (indice) => setState(() {
            _orden.removeAt(indice);
            _resultado = null;
          }),
          onComprobar: _comprobar,
        ),
      },
    );
  }

  String _titulo(Actividad actividad) {
    if (actividad.tipo != 'lugar') return actividad.titulo;
    return '${actividad.titulo} · ${_reto + 1} de ${actividad.retos.length}';
  }

  String? _fraseControles() {
    final resultado = _resultado;
    if (resultado == null) return null;
    if (resultado.estado != 'falta') return resultado.frase;
    final faltan = [
      for (final control in widget.actividad.controles)
        if (!_valores.containsKey(control.id)) control.nombre,
    ];
    if (faltan.isEmpty) return resultado.frase;
    if (faltan.length == 1) return 'Falta elegir ${faltan.single}.';
    return 'Falta elegir ${faltan.join(', ')}.';
  }

  Future<void> _soltar(String sitio) async {
    final actividad = widget.actividad;
    final reto = actividad.retos[_reto];
    final resultado = resolverLugar(
      reto: reto,
      eleccion: sitio,
      intento: _intento,
    );
    setState(() {
      _resultado = resultado;
      if (!resultado.acierto) _intento += 1;
    });
    if (resultado.acierto) {
      await Alcance.of(context).progreso.marcarReto(actividad, reto);
    }
  }

  void _siguiente() {
    setState(() {
      _reto += 1;
      _intento = 1;
      _resultado = null;
    });
  }

  void _volver() {
    Navigator.of(context).pop();
  }

  Future<void> _avanzar() async {
    final actividad = widget.actividad;
    final resultado = resolverControles(
      actividad: actividad,
      valores: _valores,
    );
    setState(() => _resultado = resultado);
    if (resultado.acierto) {
      await Alcance.of(context).progreso.marcarActividad(actividad);
    }
  }

  void _otraVez() {
    setState(() {
      _valores.clear();
      _resultado = null;
    });
  }

  Future<void> _comprobar() async {
    final actividad = widget.actividad;
    final resultado = resolverOrden(actividad: actividad, orden: _orden);
    setState(() => _resultado = resultado);
    if (resultado.acierto) {
      await Alcance.of(context).progreso.marcarActividad(actividad);
    }
  }
}

class _Lugar extends StatelessWidget {
  const _Lugar({
    required this.actividad,
    required this.reto,
    required this.indice,
    required this.total,
    required this.resultado,
    required this.pie,
    required this.onSoltar,
    required this.onPie,
  });

  final Actividad actividad;
  final Reto reto;
  final int indice;
  final int total;
  final Resultado? resultado;
  final String? pie;
  final ValueChanged<String> onSoltar;
  final VoidCallback onPie;

  @override
  Widget build(BuildContext context) {
    final elegido = resultado?.estado;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (indice + (resultado?.acierto == true ? 1 : 0.25)) / total,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5DFCF),
              color: const Color(0xFF2ECC71),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pensado para ${actividad.curso}. Puedes jugarlo igual.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD6CFC0),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Draggable<String>(
                  data: reto.id,
                  feedback: Material(
                    color: Colors.transparent,
                    child: _Miniatura(id: reto.id),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: _Miniatura(id: reto.id),
                  ),
                  child: _Miniatura(id: reto.id),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reto.pregunta,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const separacion = 10.0;
                final filas = (actividad.opciones.length / 2).ceil();
                final ancho = (constraints.maxWidth - separacion) / 2;
                final alto =
                    (constraints.maxHeight - separacion * (filas - 1)) / filas;
                return GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: separacion,
                  crossAxisSpacing: separacion,
                  childAspectRatio: ancho / alto,
                  children: [
                    for (final opcion in actividad.opciones)
                      _Sitio(
                        opcion: opcion,
                        elegido: elegido == opcion.id,
                        acierto:
                            resultado?.acierto == true && elegido == opcion.id,
                        criatura: reto.id,
                        onElegir: () => onSoltar(opcion.id),
                      ),
                  ],
                );
              },
            ),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 8),
            Burbuja(
              quien: actividad.quien,
              frase: resultado!.frase,
              gesto: resultado!.gesto,
            ),
          ],
          if (pie != null) ...[
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onPie,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(pie!),
            ),
          ],
        ],
      ),
    );
  }
}

class _Sitio extends StatelessWidget {
  const _Sitio({
    required this.opcion,
    required this.elegido,
    required this.acierto,
    required this.criatura,
    required this.onElegir,
  });

  final Opcion opcion;
  final bool elegido;
  final bool acierto;
  final String criatura;
  final VoidCallback onElegir;

  @override
  Widget build(BuildContext context) {
    final colorFondo = _colorSitio(opcion.id);
    final colorBorde = elegido
        ? (acierto ? const Color(0xFF2ECC71) : const Color(0xFFFF9F1C))
        : _bordeSitio(opcion.id);

    return DragTarget<String>(
      onAcceptWithDetails: (_) => onElegir(),
      builder: (context, candidatos, _) {
        final encima = candidatos.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: encima ? const Color(0xFF2ECC71) : colorBorde,
              width: encima || elegido ? 3.5 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorBorde.withValues(alpha: 0.55),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: Key('sitio-${opcion.id}'),
              borderRadius: BorderRadius.circular(20),
              onTap: onElegir,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (elegido)
                        _Miniatura(id: criatura, tamano: 48)
                      else
                        IconoSitio(id: opcion.id),
                      const SizedBox(height: 6),
                      Text(
                        opcion.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Controles extends StatelessWidget {
  const _Controles({
    required this.actividad,
    required this.valores,
    required this.resultado,
    required this.frase,
    required this.onElegir,
    required this.onAvanzar,
    required this.onOtraVez,
  });

  final Actividad actividad;
  final Map<String, String> valores;
  final Resultado? resultado;
  final String? frase;
  final void Function(String control, String opcion) onElegir;
  final VoidCallback onAvanzar;
  final VoidCallback? onOtraVez;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pensado para ${actividad.curso}. Puedes jugarlo igual.',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              children: [
                DibujoSemilla(estado: resultado?.estado ?? 'seca'),
                const SizedBox(height: 8),
                Text(
                  actividad.sujeto,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final control in actividad.controles) ...[
                  Text(
                    control.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      for (var i = 0; i < control.opciones.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: _OpcionControl(
                            nombre: control.opciones[i].nombre,
                            elegido:
                                valores[control.id] == control.opciones[i].id,
                            onTap: () => onElegir(
                              control.id,
                              control.opciones[i].id,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          if (frase != null) ...[
            const SizedBox(height: 6),
            Burbuja(
              quien: actividad.quien,
              frase: frase!,
              gesto: resultado?.gesto ?? 'hola',
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('avanzar'),
            onPressed: onAvanzar,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(actividad.boton),
          ),
          if (onOtraVez != null) ...[
            const SizedBox(height: 6),
            OutlinedButton(
              onPressed: onOtraVez,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Otra vez'),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpcionControl extends StatelessWidget {
  const _OpcionControl({
    required this.nombre,
    required this.elegido,
    required this.onTap,
  });

  final String nombre;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final boton = elegido
        ? FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(nombre, textAlign: TextAlign.center),
          )
        : FilledButton.tonal(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text(nombre, textAlign: TextAlign.center),
          );
    return SizedBox(height: 46, child: boton);
  }
}

class _Orden extends StatelessWidget {
  const _Orden({
    required this.actividad,
    required this.orden,
    required this.resultado,
    required this.onAnadir,
    required this.onQuitar,
    required this.onComprobar,
  });

  final Actividad actividad;
  final List<String> orden;
  final Resultado? resultado;
  final ValueChanged<String> onAnadir;
  final ValueChanged<int> onQuitar;
  final VoidCallback onComprobar;

  @override
  Widget build(BuildContext context) {
    String nombre(String id) =>
        actividad.pasos.firstWhere((paso) => paso.id == id).nombre;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pensado para ${actividad.curso}. Puedes jugarlo igual.',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            actividad.intro,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < actividad.pasos.length; i++) ...[
            if (i < orden.length)
              FilledButton.tonal(
                key: Key('hueco-$i'),
                onPressed: () => onQuitar(i),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  alignment: Alignment.centerLeft,
                ),
                child: Text('${i + 1}. ${nombre(orden[i])}'),
              )
            else
              Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD6CFC0), width: 2),
                ),
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            const SizedBox(height: 6),
          ],
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              children: [
                for (final paso in actividad.pasos)
                  if (!orden.contains(paso.id)) ...[
                    FilledButton(
                      key: Key('paso-${paso.id}'),
                      onPressed: () => onAnadir(paso.id),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: Text(paso.nombre),
                    ),
                    const SizedBox(height: 6),
                  ],
              ],
            ),
          ),
          if (resultado != null) ...[
            const SizedBox(height: 6),
            Burbuja(
              quien: actividad.quien,
              frase: resultado!.frase,
              gesto: resultado!.gesto,
            ),
          ],
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('comprobar'),
            onPressed: onComprobar,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(actividad.boton),
          ),
        ],
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.id, this.tamano = 64});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: FittedBox(fit: BoxFit.contain, child: Criatura(id: id)),
    );
  }
}

Color _colorSitio(String id) {
  switch (id) {
    case 'desierto':
      return const Color(0xFFFFF3C4);
    case 'mar':
      return const Color(0xFFE0F2FE);
    case 'polo':
      return const Color(0xFFF0F9FF);
    case 'bosque':
      return const Color(0xFFDCFCE7);
    case 'cabeza':
      return const Color(0xFFF3E8FF);
    case 'pecho':
      return const Color(0xFFFFE4E6);
    case 'barriga':
      return const Color(0xFFFEF3C7);
    default:
      return const Color(0xFFF6F1E6);
  }
}

Color _bordeSitio(String id) {
  switch (id) {
    case 'desierto':
      return const Color(0xFFF59E0B);
    case 'mar':
      return const Color(0xFF38BDF8);
    case 'polo':
      return const Color(0xFF7DD3FC);
    case 'bosque':
      return const Color(0xFF4ADE80);
    case 'cabeza':
      return const Color(0xFFC084FC);
    case 'pecho':
      return const Color(0xFFFB7185);
    case 'barriga':
      return const Color(0xFFFBBF24);
    default:
      return const Color(0xFFD6CFC0);
  }
}
