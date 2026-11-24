import 'package:flutter/material.dart';
import 'package:naturalmente/ui/tema.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/ficha.dart';
import 'package:naturalmente/modelo/zona.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/carta_cromo.dart';
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

class AlbumPage extends StatelessWidget {
  const AlbumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final catalogo = alcance.catalogo;
    final progreso = alcance.progreso;
    final conseguidos = catalogo.fichas
        .where((f) => progreso.fichaDesbloqueada(f.id))
        .length;

    return Scaffold(
      appBar: AppBar(title: const Texto('Mis cromos')),
      body: SafeArea(
        child: _PaginaAlbum(
          child: Column(
            children: [
              Image.asset(
                'assets/inicio/cromos.webp',
                height: 78,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 8),
              Texto('Elige un mundo', style: _tituloAlbum(context, 28)),
              const SizedBox(height: 4),
              Texto(
                'Cromos conseguidos: $conseguidos de ${catalogo.fichas.length}',
              ),
              const SizedBox(height: 15),
              DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/cromos/libro-abierto.webp'),
                    fit: BoxFit.fill,
                    colorFilter: Theme.of(context).brightness == Brightness.dark
                        ? const ColorFilter.mode(
                            Color(0x88000000),
                            BlendMode.srcATop,
                          )
                        : null,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 46),
                  child: Column(
                    children: [
                      for (final zona in catalogo.zonas)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _EntradaAlbum(
                            zona: zona,
                            total: catalogo
                                .fichasDe(zona.id)
                                .where((f) => progreso.fichaDesbloqueada(f.id))
                                .length,
                          ),
                        ),
                    ],
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

class _EntradaAlbum extends StatelessWidget {
  const _EntradaAlbum({required this.zona, required this.total});
  final Zona zona;
  final int total;

  @override
  Widget build(BuildContext context) {
    final (titulo, tono, borde) = switch (zona.id) {
      'reserva' => (
        'Animales',
        const Color(0xFFE4F2D6),
        const Color(0xFF4C9B39),
      ),
      'invernadero' => (
        'Plantas',
        const Color(0xFFFFEDBC),
        const Color(0xFFD38B20),
      ),
      _ => ('Mi cuerpo', const Color(0xFFDDF1FB), const Color(0xFF2E9AC8)),
    };
    final colores = context.coloresNaturales;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: colores.borde(borde), width: 2),
    );
    return Material(
      color: colores.superficie(tono),
      shape: forma,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('album-${zona.id}'),
        customBorder: forma,
        onTap: () {
          context.sonidoToque();
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => CromosZonaPage(zona: zona)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 9, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Texto(titulo, style: _tituloAlbum(context, 23)),
                    Texto(total == 1 ? '1 conseguido' : '$total conseguidos'),
                  ],
                ),
              ),
              ArteCromo('album-${zona.id}', alto: 86, ancho: 125),
            ],
          ),
        ),
      ),
    );
  }
}

class CromosZonaPage extends StatefulWidget {
  const CromosZonaPage({required this.zona, this.destacado, super.key});
  final Zona zona;
  final String? destacado;

  @override
  State<CromosZonaPage> createState() => _CromosZonaPageState();
}

class _CromosZonaPageState extends State<CromosZonaPage> {
  final _destacado = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.destacado != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final destino = _destacado.currentContext;
        if (mounted && destino != null) {
          Scrollable.ensureVisible(destino, alignment: .12);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alcance = Alcance.of(context);
    final progreso = alcance.progreso;
    final fichas = alcance.catalogo.fichasDe(widget.zona.id);
    final conseguidas = fichas
        .where((f) => progreso.fichaDesbloqueada(f.id))
        .toList();
    final pendientes = fichas
        .where((f) => !progreso.fichaDesbloqueada(f.id))
        .toList();
    final primera = pendientes.firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Texto(widget.zona.nombre)),
      body: SafeArea(
        child: _PaginaAlbum(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Texto(
                '${conseguidas.length} de ${fichas.length} descubiertos',
                style: _tituloAlbum(context, 25),
              ),
              const SizedBox(height: 14),
              if (conseguidas.isEmpty && primera != null)
                _PistaCromo(ficha: primera, primerCromo: true),
              if (conseguidas.isNotEmpty) ...[
                Texto('Conseguidos', style: _tituloAlbum(context, 21)),
                const SizedBox(height: 8),
                _rejilla(conseguidas, true),
              ],
              if (pendientes.isNotEmpty) ...[
                const SizedBox(height: 18),
                Texto('Por descubrir', style: _tituloAlbum(context, 21)),
                const SizedBox(height: 8),
                _rejilla(pendientes, false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _rejilla(List<Ficha> fichas, bool conseguidas) => LayoutBuilder(
    builder: (context, medidas) {
      const espacio = 10.0;
      final dosColumnas =
          medidas.maxWidth >= 295 &&
          MediaQuery.textScalerOf(context).scale(16) <= 24;
      final ancho = dosColumnas
          ? (medidas.maxWidth - espacio) / 2
          : medidas.maxWidth;
      final reducido = MediaQuery.disableAnimationsOf(context);
      return Wrap(
        spacing: espacio,
        runSpacing: espacio,
        children: [
          for (final ficha in fichas)
            SizedBox(
              key: ficha.id == widget.destacado ? _destacado : null,
              width: ancho,
              child: Column(
                children: [
                  Material(
                    key: Key('cromo-${ficha.id}'),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.sonidoToque();
                        Navigator.of(context).push(
                          _rutaCromo(
                            context,
                            _VistaCromo(
                              ficha: ficha,
                              conseguida: conseguidas,
                              hero: !reducido,
                            ),
                          ),
                        );
                      },
                      child: HeroMode(
                        enabled: !reducido,
                        child: Hero(
                          tag: 'carta-${ficha.id}',
                          flightShuttleBuilder: _vueloCarta,
                          child: CartaCromo(
                            ficha: ficha,
                            conseguida: conseguidas,
                            altoArte: 90,
                            miniatura: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (ficha.id == widget.destacado)
                    const Texto(
                      'Recién conseguido',
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

PageRoute<void> _rutaCromo(BuildContext context, Widget pagina) {
  final reducido = MediaQuery.disableAnimationsOf(context);
  return PageRouteBuilder<void>(
    transitionDuration: Duration(milliseconds: reducido ? 0 : 220),
    reverseTransitionDuration: Duration(milliseconds: reducido ? 0 : 220),
    pageBuilder: (_, _, _) => pagina,
    transitionsBuilder: (_, animacion, _, child) =>
        FadeTransition(opacity: animacion, child: child),
  );
}

Future<void> abrirCelebracionCromos(BuildContext context, List<Ficha> fichas) {
  context.sonidoToque();
  return Navigator.of(context).push(
    _rutaCromo(context, _CelebracionCromos(fichas: List.unmodifiable(fichas))),
  );
}

class _VistaCromo extends StatelessWidget {
  const _VistaCromo({
    required this.ficha,
    required this.conseguida,
    required this.hero,
  });
  final Ficha ficha;
  final bool conseguida;
  final bool hero;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Texto('Mis cromos')),
    body: SafeArea(
      child: _PaginaAlbum(
        ancho: 390,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Texto(
              conseguida ? 'Cromo conseguido' : 'Por descubrir',
              textAlign: TextAlign.center,
              style: _tituloAlbum(context, 28),
            ),
            const SizedBox(height: 14),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 304),
                child: HeroMode(
                  enabled: hero,
                  child: Hero(
                    tag: 'carta-${ficha.id}',
                    flightShuttleBuilder: _vueloCarta,
                    child: CartaCromo(
                      ficha: ficha,
                      conseguida: conseguida,
                      altoArte: 235,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (conseguida)
              FilledButton.tonalIcon(
                key: const Key('sobre-este-cromo'),
                onPressed: () =>
                    mostrarDetalleFicha(context, ficha, desbloqueada: true),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Texto('Sobre este cromo'),
              )
            else
              _PistaCromo(ficha: ficha),
          ],
        ),
      ),
    ),
  );
}

class _CelebracionCromos extends StatefulWidget {
  const _CelebracionCromos({required this.fichas});
  final List<Ficha> fichas;

  @override
  State<_CelebracionCromos> createState() => _CelebracionCromosState();
}

class _CelebracionCromosState extends State<_CelebracionCromos> {
  int _indice = 0;

  void _mover(int cantidad) {
    context.sonidoToque();
    setState(() => _indice += cantidad);
  }

  @override
  Widget build(BuildContext context) {
    final ficha = widget.fichas[_indice];
    final total = widget.fichas.length;
    final zona = Alcance.of(context).catalogo.zonas
        .where((z) => z.id == ficha.zona)
        .firstOrNull;
    final reducido = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      key: const Key('celebracion-cromos'),
      appBar: AppBar(title: const Texto('Mis cromos')),
      body: SafeArea(
        child: _PaginaAlbum(
          ancho: 390,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ArteCromo('natu-victoria', alto: 96),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/cromos/banda.webp',
                    height: 73,
                    width: 260,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36, 8, 36, 24),
                    child: Semantics(
                      header: true,
                      child: Texto(
                        '¡Nuevo cromo!',
                        textAlign: TextAlign.center,
                        style: _tituloAlbum(
                          context,
                          26,
                        ).copyWith(color: const Color(0xFF34421E)),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 304),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: reducido ? 1 : .91, end: 1),
                    curve: Curves.easeOutCubic,
                    duration: Duration(milliseconds: reducido ? 0 : 260),
                    builder: (_, escala, child) =>
                        Transform.scale(scale: escala, child: child),
                    child: CartaCromo(
                      ficha: ficha,
                      conseguida: true,
                      altoArte: 235,
                      destacada: true,
                    ),
                  ),
                ),
              ),
              if (total > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      key: const Key('cromo-nuevo-anterior'),
                      tooltip: context.tr('Cromo anterior'),
                      onPressed: _indice > 0 ? () => _mover(-1) : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Flexible(
                      child: Semantics(
                        liveRegion: true,
                        child: Texto(
                          'Cromo ${_indice + 1} de $total',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('cromo-nuevo-siguiente'),
                      tooltip: context.tr('Siguiente cromo'),
                      onPressed: _indice + 1 < total ? () => _mover(1) : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              if (zona != null)
                FilledButton.icon(
                  key: const Key('celebracion-abrir-album'),
                  onPressed: () {
                    context.sonidoToque();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CromosZonaPage(zona: zona, destacado: ficha.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_stories_rounded),
                  label: const Texto('Ver en mi álbum'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PistaCromo extends StatelessWidget {
  const _PistaCromo({required this.ficha, this.primerCromo = false});
  final Ficha ficha;
  final bool primerCromo;

  @override
  Widget build(BuildContext context) {
    final catalogo = Alcance.of(context).catalogo;
    final actividad = catalogo
        .actividadesDe(ficha.zona)
        .where((a) => a.titulo == ficha.juego)
        .firstOrNull;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (primerCromo)
              Texto('Tu próximo cromo', style: _tituloAlbum(context, 19)),
            Texto(Progreso.pistaDesbloqueoFicha(ficha.id)),
            if (actividad case final Actividad juego)
              TextButton.icon(
                onPressed: () => abrirActividad(context, juego),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Texto('Ir al juego'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaginaAlbum extends StatelessWidget {
  const _PaginaAlbum({required this.child, this.ancho = 560});
  final Widget child;
  final double ancho;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ancho),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: child,
      ),
    ),
  );
}

TextStyle _tituloAlbum(BuildContext context, double tamano) => TextStyle(
  color: context.coloresNaturales.tinta,
  fontFamily: 'NunitoInicio',
  fontWeight: FontWeight.w900,
  fontSize: tamano,
  height: 1.13,
);

Widget _vueloCarta(
  BuildContext contexto,
  Animation<double> animacion,
  HeroFlightDirection direccion,
  BuildContext origen,
  BuildContext destino,
) {
  final grande =
      (direccion == HeroFlightDirection.push ? destino : origen).widget as Hero;
  return FittedBox(child: SizedBox(width: 344, child: grande.child));
}
