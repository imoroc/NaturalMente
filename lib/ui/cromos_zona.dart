import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/texto.dart';
import 'package:naturalmente/ui/zona.dart';

const _ambar = Color(0xFFF59E0B);
const _ambarOscuro = Color(0xFF78350F);
const _ambarTexto = Color(0xFF92400E);
const _fondoAmbar = Color(0xFFFFFBEB);

/// Resumen de los cromos de un mundo, en lugar de la lista entera.
/// Al tocarlo se abre la página con todos los cromos del mundo.
class ResumenCromosZona extends StatelessWidget {
  const ResumenCromosZona({
    required this.zona,
    required this.fichas,
    required this.progreso,
    super.key,
  });

  final Zona zona;
  final List<Ficha> fichas;
  final Progreso progreso;

  @override
  Widget build(BuildContext context) {
    final conseguidas = [
      for (final f in fichas)
        if (progreso.fichaDesbloqueada(f.id)) f,
    ];
    final siguiente = fichas
        .where((f) => !progreso.fichaDesbloqueada(f.id))
        .firstOrNull;
    final muestra = [
      ...conseguidas.reversed,
      ...fichas.where((f) => !conseguidas.contains(f)),
    ].take(5).toList();
    final total = fichas.length;

    return Material(
      color: context.coloresNaturales.superficie(_fondoAmbar),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        key: const Key('abrir-cromos-zona'),
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.sonidoToque();
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => CromosZonaPage(zona: zona)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: context.coloresNaturales.borde(_ambar),
              width: 2.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: context.coloresNaturales.superficie(
                        const Color(0xFFFEF3C7),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.coloresNaturales.borde(
                          const Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 20,
                      color: context.coloresNaturales.contenido(
                        Color(0xFFB45309),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Texto(
                      '4. CROMOS · ${conseguidas.length}/$total',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: context.coloresNaturales.contenido(_ambarOscuro),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Texto(
                    'Ver todos',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: context.coloresNaturales.contenido(
                        Color(0xFFB45309),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.coloresNaturales.contenido(
                      Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : conseguidas.length / total,
                  minHeight: 8,
                  backgroundColor: context.coloresNaturales.superficie(
                    const Color(0xFFFEF3C7),
                  ),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF16A34A)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final ficha in muestra) ...[
                    _Miniatura(
                      ficha: ficha,
                      desbloqueada: conseguidas.contains(ficha),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (total > muestra.length)
                    Texto(
                      '+${total - muestra.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: context.coloresNaturales.contenido(_ambarTexto),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Texto(
                siguiente == null
                    ? '¡Has descubierto todos los cromos de este mundo!'
                    : 'Próximo cromo: ${Progreso.pistaDesbloqueoFicha(siguiente.id)}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: context.coloresNaturales.contenido(_ambarTexto),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Miniatura extends StatelessWidget {
  const _Miniatura({required this.ficha, required this.desbloqueada});

  final Ficha ficha;
  final bool desbloqueada;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.coloresNaturales.superficie(
          desbloqueada ? Colors.white : const Color(0xFFE2E8F0),
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.coloresNaturales.borde(
            desbloqueada ? const Color(0xFFFCD34D) : const Color(0xFFCBD5E1),
          ),
          width: 1.5,
        ),
      ),
      child: desbloqueada
          ? IlustracionFicha(id: ficha.id, alto: 32)
          : Icon(
              Icons.lock_rounded,
              size: 18,
              color: context.coloresNaturales.contenido(Color(0xFF64748B)),
            ),
    );
  }
}

enum _Orden { juego, descubiertos, curso, nombre }

/// Todos los cromos de un mundo, con orden y vista en lista o cuadrícula.
class CromosZonaPage extends StatefulWidget {
  const CromosZonaPage({required this.zona, super.key});

  final Zona zona;

  @override
  State<CromosZonaPage> createState() => _CromosZonaPageState();
}

class _CromosZonaPageState extends State<CromosZonaPage> {
  _Orden _orden = _Orden.juego;
  bool _cuadricula = true;

  static const _etiquetas = {
    _Orden.juego: 'Por juego',
    _Orden.descubiertos: 'Descubiertos primero',
    _Orden.curso: 'Por curso',
    _Orden.nombre: 'De la A a la Z',
  };

  List<Ficha> _ordenar(List<Ficha> fichas, Progreso progreso) {
    final lista = [...fichas];
    final posicion = {for (var i = 0; i < fichas.length; i++) fichas[i]: i};
    int porDefecto(Ficha a, Ficha b) => posicion[a]!.compareTo(posicion[b]!);
    switch (_orden) {
      case _Orden.juego:
        break;
      case _Orden.descubiertos:
        lista.sort((a, b) {
          final da = progreso.fichaDesbloqueada(a.id) ? 0 : 1;
          final db = progreso.fichaDesbloqueada(b.id) ? 0 : 1;
          return da != db ? da.compareTo(db) : porDefecto(a, b);
        });
      case _Orden.curso:
        lista.sort((a, b) {
          final c = a.curso.compareTo(b.curso);
          return c != 0 ? c : porDefecto(a, b);
        });
      case _Orden.nombre:
        lista.sort(
          (a, b) => context
              .traducir(a.titulo)
              .toLowerCase()
              .compareTo(context.traducir(b.titulo).toLowerCase()),
        );
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichasZona = alcance.catalogo.fichasDe(widget.zona.id);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Texto(
          'Cromos de ${widget.zona.nombre}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListenableBuilder(
        listenable: progreso,
        builder: (context, _) {
          final fichas = _ordenar(fichasZona, progreso);
          final conseguidas = fichas
              .where((f) => progreso.fichaDesbloqueada(f.id))
              .length;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Texto(
                            '$conseguidas de ${fichas.length} descubiertos',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: context.coloresNaturales.contenido(
                                    _ambarOscuro,
                                  ),
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: fichas.isEmpty
                                  ? 0
                                  : conseguidas / fichas.length,
                              minHeight: 9,
                              backgroundColor: context.coloresNaturales
                                  .superficie(const Color(0xFFFEF3C7)),
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _selectorOrden()),
                              const SizedBox(width: 8),
                              SegmentedButton<bool>(
                                key: const Key('vista-cromos'),
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                    value: true,
                                    icon: const Icon(Icons.grid_view_rounded),
                                    tooltip: context.traducir('Cuadrícula'),
                                  ),
                                  ButtonSegment(
                                    value: false,
                                    icon: const Icon(Icons.view_list_rounded),
                                    tooltip: context.traducir('Lista'),
                                  ),
                                ],
                                selected: {_cuadricula},
                                onSelectionChanged: (valor) {
                                  context.sonidoSeleccion();
                                  setState(() => _cuadricula = valor.first);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    sliver: _cuadricula
                        ? SliverGrid.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: .82,
                                ),
                            itemCount: fichas.length,
                            itemBuilder: (context, i) => _TarjetaCuadricula(
                              ficha: fichas[i],
                              desbloqueada: progreso.fichaDesbloqueada(
                                fichas[i].id,
                              ),
                            ),
                          )
                        : SliverList.separated(
                            itemCount: fichas.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) => TarjetaCromoFicha(
                              ficha: fichas[i],
                              desbloqueada: progreso.fichaDesbloqueada(
                                fichas[i].id,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectorOrden() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.coloresNaturales.superficie(Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.coloresNaturales.borde(const Color(0xFFFCD34D)),
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_Orden>(
          key: const Key('orden-cromos'),
          isExpanded: true,
          value: _orden,
          icon: Icon(
            Icons.sort_rounded,
            color: context.coloresNaturales.contenido(Color(0xFFB45309)),
          ),
          items: [
            for (final orden in _Orden.values)
              DropdownMenuItem(
                value: orden,
                child: Texto(
                  _etiquetas[orden]!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.coloresNaturales.contenido(_ambarOscuro),
                  ),
                ),
              ),
          ],
          onChanged: (orden) {
            if (orden == null) return;
            context.sonidoSeleccion();
            setState(() => _orden = orden);
          },
        ),
      ),
    );
  }
}

class _TarjetaCuadricula extends StatelessWidget {
  const _TarjetaCuadricula({required this.ficha, required this.desbloqueada});

  final Ficha ficha;
  final bool desbloqueada;

  @override
  Widget build(BuildContext context) {
    final borde = desbloqueada ? _ambar : const Color(0xFFCBD5E1);
    return Material(
      color: context.coloresNaturales.superficie(
        desbloqueada ? Colors.white : const Color(0xFFF8FAFC),
      ),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('cromo-${ficha.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () =>
            mostrarDetalleFicha(context, ficha, desbloqueada: desbloqueada),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.coloresNaturales.borde(borde),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.coloresNaturales.superficie(
                      desbloqueada ? _fondoAmbar : const Color(0xFFE2E8F0),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: desbloqueada
                      ? LayoutBuilder(
                          builder: (context, c) => IlustracionFicha(
                            id: ficha.id,
                            alto: (c.maxHeight * .72).clamp(32, 96),
                          ),
                        )
                      : Icon(
                          Icons.lock_rounded,
                          size: 34,
                          color: context.coloresNaturales.contenido(
                            Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Texto(
                ficha.titulo,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: context.coloresNaturales.contenido(
                    desbloqueada ? _ambarOscuro : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.coloresNaturales.superficie(
                    desbloqueada
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFE2E8F0),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Texto(
                  desbloqueada ? ficha.curso : 'Por descubrir',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: context.coloresNaturales.contenido(
                      desbloqueada
                          ? const Color(0xFFB45309)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
