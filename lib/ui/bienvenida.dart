import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/mapa.dart';
import 'package:naturalmente/ui/selector_idioma.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Primera vez en la app: Natu presenta el mapa, los cromos y las semillas,
/// y el niño elige su curso. Se puede saltar en cualquier momento.
class BienvenidaPage extends StatefulWidget {
  const BienvenidaPage({super.key});

  @override
  State<BienvenidaPage> createState() => _BienvenidaPageState();
}

class _BienvenidaPageState extends State<BienvenidaPage> {
  static const _paginas = 3;

  final _controlador = PageController();
  int _pagina = 0;
  int? _curso;
  bool _saliendo = false;
  bool _error = false;

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Duration get _duracion =>
      Duration(milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 320);

  void _irA(int pagina) {
    context.sonidoToque();
    if (_duracion == Duration.zero) {
      _controlador.jumpToPage(pagina);
    } else {
      _controlador.animateToPage(
        pagina,
        duration: _duracion,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _elegirCurso(int curso) {
    context.sonidoSeleccion();
    setState(() {
      _curso = curso;
      _error = false;
    });
  }

  /// Guarda el curso (si hay) y que ya ha visto la bienvenida; luego abre el
  /// mapa. Si no se puede guardar, entra igual y avisa la próxima vez.
  Future<void> _terminar({required bool saltar}) async {
    if (_saliendo) return;
    final progreso = Alcance.of(context).progreso;
    setState(() => _saliendo = true);
    context.sonidoToque();
    var guardado = true;
    final curso = _curso;
    if (!saltar && curso != null) {
      guardado = await progreso.guardarCurso(curso);
    }
    if (guardado) guardado = await progreso.marcarBienvenidaVista();
    if (!mounted) return;
    if (!guardado && !saltar) {
      setState(() {
        _saliendo = false;
        _error = true;
      });
      return;
    }
    final reducido = MediaQuery.disableAnimationsOf(context);
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: Duration(milliseconds: reducido ? 0 : 260),
        pageBuilder: (_, _, _) => const MapaPage(),
        transitionsBuilder: (_, animacion, _, child) =>
            FadeTransition(opacity: animacion, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final ultima = _pagina == _paginas - 1;
    return Scaffold(
      key: const Key('bienvenida'),
      backgroundColor: colores.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      if (_pagina > 0)
                        IconButton(
                          key: const Key('bienvenida-atras'),
                          tooltip: context.tr('Atrás'),
                          onPressed: () => _irA(_pagina - 1),
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      TextButton(
                        key: const Key('bienvenida-saltar'),
                        onPressed: _saliendo
                            ? null
                            : () => _terminar(saltar: true),
                        child: const Texto(
                          'Saltar',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controlador,
                    onPageChanged: (p) => setState(() => _pagina = p),
                    children: [
                      const _PaginaBienvenida(
                        gesto: 'hola',
                        titulo: '¡Hola! Soy Natu',
                        frase: 'Vamos a explorar la naturaleza y tu cuerpo jugando.',
                        dibujos: [
                          InsigniaIlustradaZona(id: 'reserva', tamano: 64),
                          InsigniaIlustradaZona(id: 'invernadero', tamano: 64),
                          InsigniaIlustradaZona(id: 'cuerpo', tamano: 64),
                        ],
                        explicacion:
                            'Toca un mundo del mapa para ver sus juegos.',
                      ),
                      const _PaginaBienvenida(
                        gesto: 'feliz',
                        titulo: 'Gana cromos y semillas',
                        frase: 'Cada nivel que superas te da cromos para tu álbum.',
                        dibujos: [
                          InsigniaIlustradaZona(id: 'album', tamano: 64),
                          IconoSemilla(tamano: 56),
                        ],
                        explicacion: 'Con las semillas puedes vestir a Natu en su armario.',
                      ),
                      _PaginaCurso(
                        curso: _curso,
                        onElegir: _saliendo ? null : _elegirCurso,
                      ),
                    ],
                  ),
                ),
                if (_error)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Semantics(
                      liveRegion: true,
                      child: Texto(
                        'No se ha podido guardar el curso. Inténtalo de nuevo.',
                        key: const Key('bienvenida-error'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colores.pista, fontSize: 13),
                      ),
                    ),
                  ),
                _Puntos(actual: _pagina, total: _paginas),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('bienvenida-siguiente'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onPressed: _saliendo || (ultima && _curso == null)
                          ? null
                          : ultima
                          ? () => _terminar(saltar: false)
                          : () => _irA(_pagina + 1),
                      icon: Icon(
                        ultima
                            ? Icons.play_arrow_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Texto(ultima ? '¡A jugar!' : 'Siguiente'),
                    ),
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

class _PaginaBienvenida extends StatelessWidget {
  const _PaginaBienvenida({
    required this.gesto,
    required this.titulo,
    required this.frase,
    required this.dibujos,
    required this.explicacion,
  });

  final String gesto;
  final String titulo;
  final String frase;
  final List<Widget> dibujos;
  final String explicacion;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Column(
        children: [
          DibujoMascota(gesto: gesto, tamano: 150),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Texto(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colores.tinta,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Texto(
            frase,
            textAlign: TextAlign.center,
            style: TextStyle(color: colores.tenue, fontSize: 17, height: 1.3),
          ),
          const SizedBox(height: 26),
          ExcludeSemantics(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: dibujos,
            ),
          ),
          const SizedBox(height: 22),
          Texto(
            explicacion,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colores.tinta,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginaCurso extends StatelessWidget {
  const _PaginaCurso({required this.curso, required this.onElegir});

  final int? curso;
  final ValueChanged<int>? onElegir;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          DibujoMascota(
            gesto: curso == null ? 'pensando' : 'feliz',
            tamano: 110,
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Texto(
              '¿En qué curso estás?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colores.tinta,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Texto(
            'Así te recomiendo el nivel de cada juego.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colores.tenue, fontSize: 16, height: 1.3),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              for (var c = 1; c <= 6; c++)
                _BotonCurso(
                  curso: c,
                  seleccionado: curso == c,
                  onTap: onElegir == null ? null : () => onElegir!(c),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Texto(
            textoCursoRecomendado(curso),
            key: const Key('bienvenida-recomendacion'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colores.tinta,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Texto(
            'Podrás cambiarlo en Ajustes de Natu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colores.tenue, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _BotonCurso extends StatelessWidget {
  const _BotonCurso({
    required this.curso,
    required this.seleccionado,
    required this.onTap,
  });

  final int curso;
  final bool seleccionado;
  final VoidCallback? onTap;

  // Mismos colores de los niveles: verde fácil, ámbar medio, rojo difícil.
  Color get _color => switch (curso) {
    1 || 2 => const Color(0xFF16A34A),
    3 || 4 => const Color(0xFFF59E0B),
    _ => const Color(0xFFE11D48),
  };

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final color = colores.borde(_color);
    return Semantics(
      button: true,
      selected: seleccionado,
      inMutuallyExclusiveGroup: true,
      label: context.tr('$cursoº de primaria'),
      child: Material(
        color: seleccionado
            ? colores.superficie(_color.withValues(alpha: .16))
            : colores.tarjeta,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color, width: seleccionado ? 3.5 : 2),
        ),
        child: InkWell(
          key: Key('bienvenida-curso-$curso'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: ExcludeSemantics(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Texto(
                        '$cursoº',
                        style: TextStyle(
                          color: color,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Texto(
                        'de primaria',
                        style: TextStyle(
                          color: colores.tenue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (seleccionado)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: color,
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

class _Puntos extends StatelessWidget {
  const _Puntos({required this.actual, required this.total});
  final int actual;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Semantics(
      label: context.tr('Paso ${actual + 1} de $total'),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: Duration(
                milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 200,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == actual ? 22 : 9,
              height: 9,
              decoration: BoxDecoration(
                color: i == actual
                    ? colores.acierto
                    : colores.contorno.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
        ],
      ),
    );
  }
}
