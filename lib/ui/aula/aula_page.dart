import 'package:flutter/material.dart';

import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/aula/aula.dart';
import 'package:naturalmente/datos/aula/repositorio_aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/ui/aula/juego_aula_page.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/perfiles/quien_juega.dart';
import 'package:naturalmente/ui/selector_idioma.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Juegos que el profesor ha publicado para el curso del niño, y el ranking.
class AulaPage extends StatefulWidget {
  const AulaPage({super.key});

  @override
  State<AulaPage> createState() => _AulaPageState();
}

class _AulaPageState extends State<AulaPage> {
  bool _verRanking = false;
  int? _cursoCargado;

  bool _sincronizado = false;

  void _refrescarSiHaceFalta(Aula aula, int? curso) {
    // Al entrar en Aula se trae el progreso de las otras tablets del niño.
    // Aquí no hay ningún juego abierto que pueda estar guardando a la vez.
    final perfil = PerfilesScope.maybeOf(context)?.activo;
    if (!_sincronizado &&
        perfil != null &&
        aula.perfilNube(perfil.id) != null) {
      _sincronizado = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) aula.sincronizar(perfil.id);
      });
    }
    if (curso == null || curso == _cursoCargado) return;
    _cursoCargado = curso;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) aula.refrescar(curso);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final aula = AulaScope.maybeOf(context);
    final progreso = Alcance.of(context).progreso;
    final curso = progreso.curso;
    if (aula != null) _refrescarSiHaceFalta(aula, curso);

    return Scaffold(
      backgroundColor: colores.fondo,
      appBar: AppBar(
        backgroundColor: colores.fondo,
        title: const Texto('Aula'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: aula == null || !aula.disponible
                ? const _Mensaje(
                    clave: 'aula-no-disponible',
                    gesto: 'pensando',
                    texto: 'Aula todavía no está disponible en esta versión de la app.',
                  )
                : curso == null
                ? _Mensaje(
                    clave: 'aula-sin-curso',
                    gesto: 'hola',
                    texto: 'Dime en qué curso estás y te enseño los juegos de tu profe.',
                    accion: FilledButton.icon(
                      key: const Key('aula-elegir-curso'),
                      onPressed: () => mostrarSelectorCurso(context),
                      icon: const Icon(Icons.school_rounded),
                      label: const Texto('Elegir curso'),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: false,
                              icon: const Icon(Icons.extension_rounded),
                              label: Texto(
                                'Juegos de $cursoº',
                                key: const Key('aula-pestana-juegos'),
                              ),
                            ),
                            const ButtonSegment(
                              value: true,
                              icon: Icon(Icons.emoji_events_rounded),
                              label: Texto(
                                'Ranking',
                                key: Key('aula-pestana-ranking'),
                              ),
                            ),
                          ],
                          selected: {_verRanking},
                          onSelectionChanged: (s) {
                            context.sonidoSeleccion();
                            setState(() => _verRanking = s.first);
                          },
                        ),
                      ),
                      Expanded(
                        child: _verRanking
                            ? Align(
                                alignment: Alignment.topCenter,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 640,
                                  ),
                                  child: _Ranking(aula: aula, curso: curso),
                                ),
                              )
                            : _ListaJuegos(aula: aula, curso: curso),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ListaJuegos extends StatelessWidget {
  const _ListaJuegos({required this.aula, required this.curso});

  final Aula aula;
  final int curso;

  @override
  Widget build(BuildContext context) {
    final progreso = Alcance.of(context).progreso;
    final perfiles = PerfilesScope.maybeOf(context);
    final juegos = aula.juegos(curso);
    final estado = aula.estado(curso);
    final pendientes = perfiles == null
        ? 0
        : aula.pendientes(perfiles.activo.id).length;
    final colores = context.coloresNaturales;

    if (juegos.isEmpty) {
      if (estado == EstadoAula.cargando || estado == EstadoAula.sinCargar) {
        return const Center(
          child: CircularProgressIndicator(key: Key('aula-cargando')),
        );
      }
      return RefreshIndicator(
        onRefresh: () => aula.refrescar(curso),
        child: ListView(
          children: [
            estado == EstadoAula.sinConexion
                ? _Mensaje(
                    clave: 'aula-sin-conexion',
                    gesto: 'pensando',
                    texto: 'No hay conexión y todavía no tengo juegos guardados. Vuelve a intentarlo con internet.',
                    accion: OutlinedButton.icon(
                      key: const Key('aula-reintentar'),
                      onPressed: () => aula.refrescar(curso),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Texto('Reintentar'),
                    ),
                  )
                : _Mensaje(
                    clave: 'aula-vacia',
                    gesto: 'hola',
                    texto:
                        'Tu profe todavía no ha publicado juegos para $cursoº. ¡Vuelve pronto!',
                  ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => aula.refrescar(curso),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (estado == EstadoAula.sinConexion)
            _Banda(
              clave: 'aula-sin-conexion',
              icono: Icons.cloud_off_rounded,
              texto: 'Sin conexión: puedes jugar a los juegos guardados.',
            ),
          if (pendientes > 0)
            _Banda(
              clave: 'aula-pendientes',
              icono: Icons.cloud_upload_outlined,
              texto: pendientes == 1
                  ? 'Hay 1 partida esperando conexión para enviarse.'
                  : 'Hay $pendientes partidas esperando conexión para enviarse.',
            ),
          // Una columna en el móvil; dos o tres en tablets y ordenadores.
          LayoutBuilder(
            builder: (context, medidas) {
              final columnas = (medidas.maxWidth / 340).floor().clamp(1, 3);
              final ancho = (medidas.maxWidth - 12 * (columnas - 1)) / columnas;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final juego in juegos)
                    SizedBox(
                      width: ancho,
                      child: _TarjetaJuegoAula(
                        juego: juego,
                        hecho: progreso.juegoAulaHecho(juego.id, juego.version),
                        jugado: progreso.juegoAulaJugado(juego.id),
                        onTap: () {
                          context.sonidoToque();
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => JuegoAulaPage(juego: juego),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (estado == EstadoAula.cargando)
            const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Texto(
              'Desliza hacia abajo para buscar juegos nuevos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colores.tenue, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaJuegoAula extends StatelessWidget {
  const _TarjetaJuegoAula({
    required this.juego,
    required this.hecho,
    required this.jugado,
    required this.onTap,
  });

  final JuegoAula juego;
  final bool hecho;
  final bool jugado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final fondo = juego.fondo;
    final etiqueta = hecho
        ? '✓ Hecho'
        : (jugado ? 'Hay preguntas nuevas' : 'Nuevo');
    final colorEtiqueta = hecho
        ? colores.acierto
        : colores.contenido(const Color(0xFFB45309));
    return Material(
      key: Key('juego-aula-${juego.id}'),
      color: colores.tarjeta,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hecho ? colores.acierto : colores.contorno,
              width: 2.5,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 76,
                  height: 64,
                  child: fondo != null
                      ? ImagenDeAula(fondo, ajuste: BoxFit.cover)
                      : ColoredBox(
                          color: colores.superficie(const Color(0xFFE3F1FB)),
                          child: Icon(
                            juego.plantilla == PlantillaAula.verdaderoFalso
                                ? Icons.rule_rounded
                                : Icons.quiz_rounded,
                            size: 34,
                            color: colores.contenido(const Color(0xFF2F78B7)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      juego.titulo,
                      style: TextStyle(
                        color: colores.tinta,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Texto(
                      juego.plantilla == PlantillaAula.libre
                          ? '${juego.preguntas.length} retos'
                          : '${juego.plantilla.nombre} · ${juego.preguntas.length} preguntas',
                      style: TextStyle(color: colores.tenue, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Texto(
                      etiqueta,
                      style: TextStyle(
                        color: colorEtiqueta,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ranking extends StatefulWidget {
  const _Ranking({required this.aula, required this.curso});
  final Aula aula;
  final int curso;

  @override
  State<_Ranking> createState() => _RankingState();
}

class _RankingState extends State<_Ranking> {
  bool _semana = true;
  late Future<(bool?, List<FilaRanking>)> _carga = _cargar();

  Future<(bool?, List<FilaRanking>)> _cargar() async {
    final activo = await widget.aula.rankingActivo();
    if (activo != true) return (activo, const <FilaRanking>[]);
    try {
      return (true, await widget.aula.ranking(widget.curso, semana: _semana));
    } catch (_) {
      return (null, const <FilaRanking>[]);
    }
  }

  void _recargar() {
    final carga = _cargar();
    setState(() {
      _carga = carga;
    });
  }

  @override
  void didUpdateWidget(covariant _Ranking oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.curso != widget.curso) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                key: const Key('ranking-semana'),
                label: const Texto('Esta semana'),
                selected: _semana,
                onSelected: (_) {
                  if (_semana) return;
                  _semana = true;
                  _recargar();
                },
              ),
              ChoiceChip(
                key: const Key('ranking-siempre'),
                label: const Texto('Siempre'),
                selected: !_semana,
                onSelected: (_) {
                  if (!_semana) return;
                  _semana = false;
                  _recargar();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<(bool?, List<FilaRanking>)>(
            future: _carga,
            builder: (context, snapshot) {
              final datos = snapshot.data;
              if (datos == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final (activo, filas) = datos;
              if (activo == null) {
                return _Mensaje(
                  clave: 'ranking-sin-conexion',
                  gesto: 'pensando',
                  texto: 'Para ver el ranking hace falta conexión.',
                  accion: OutlinedButton.icon(
                    onPressed: _recargar,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Texto('Reintentar'),
                  ),
                );
              }
              if (!activo) {
                return const _Mensaje(
                  clave: 'ranking-apagado',
                  gesto: 'hola',
                  texto: 'Tu profe ha apagado el ranking por ahora.',
                );
              }
              if (filas.isEmpty) {
                return _Mensaje(
                  clave: 'ranking-vacio',
                  gesto: 'feliz',
                  texto: _semana
                      ? 'Esta semana todavía no ha jugado nadie. ¡Sé el primero!'
                      : 'Todavía no ha jugado nadie. ¡Sé el primero!',
                );
              }
              final perfiles = PerfilesScope.maybeOf(context);
              return RefreshIndicator(
                onRefresh: () async => _recargar(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final fila = filas[i];
                    final hueco =
                        i > 0 && fila.posicion > filas[i - 1].posicion + 1;
                    return Column(
                      children: [
                        if (hueco)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Icon(Icons.more_vert_rounded),
                          ),
                        Container(
                          key: Key('ranking-fila-${fila.posicion}'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: fila.esMio
                                ? colores.fondoAcierto
                                : colores.tarjeta,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: fila.esMio
                                  ? colores.acierto
                                  : colores.contorno,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 34,
                                child: Text(
                                  fila.posicion <= 3
                                      ? ['🥇', '🥈', '🥉'][fila.posicion - 1]
                                      : '${fila.posicion}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ExcludeSemantics(
                                child: DibujoMascota(
                                  gesto: fila.pose,
                                  traje: fila.traje,
                                  colorPanuelo: fila.perfil.colorPanuelo,
                                  tamano: 44,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  fila.esMio && perfiles != null
                                      ? '${moteDe(context, fila.perfil)} (${context.tr('tú')})'
                                      : moteDe(context, fila.perfil),
                                  style: TextStyle(
                                    color: colores.tinta,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                '${fila.puntos}',
                                style: TextStyle(
                                  color: colores.tinta,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Banda extends StatelessWidget {
  const _Banda({required this.clave, required this.icono, required this.texto});
  final String clave;
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Container(
      key: Key(clave),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colores.fondoPista,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icono, color: colores.pista),
          const SizedBox(width: 8),
          Expanded(child: Texto(texto)),
        ],
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.clave,
    required this.gesto,
    required this.texto,
    this.accion,
  });

  final String clave;
  final String gesto;
  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) => Padding(
    key: Key(clave),
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: DibujoMascota(gesto: gesto, tamano: 96)),
        const SizedBox(height: 16),
        Texto(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        if (accion != null) ...[const SizedBox(height: 16), accion!],
      ],
    ),
  );
}
