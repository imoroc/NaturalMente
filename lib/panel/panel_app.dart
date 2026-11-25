import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;

import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/panel/editor_juego.dart';
import 'package:naturalmente/panel/repositorio_panel.dart';
import 'package:naturalmente/panel/resultados_page.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/tema.dart';

/// Panel web del profesor: crear, publicar y revisar juegos de Aula.
class PanelApp extends StatelessWidget {
  const PanelApp({required this.repositorio, super.key});

  final RepositorioPanel? repositorio;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NaturalMente · Panel del profe',
    debugShowCheckedModeBanner: false,
    theme: TemaNatural.crear(Brightness.light),
    locale: const Locale('es'),
    supportedLocales: const [Locale('es')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: repositorio == null
        ? const Scaffold(
            body: Center(
              child: Text(
                'Falta configurar la conexión (SUPABASE_URL y SUPABASE_ANON_KEY).',
              ),
            ),
          )
        : _Puerta(repositorio: repositorio!),
  );
}

class _Puerta extends StatefulWidget {
  const _Puerta({required this.repositorio});
  final RepositorioPanel repositorio;

  @override
  State<_Puerta> createState() => _PuertaState();
}

class _PuertaState extends State<_Puerta> {
  late Future<String?> _nombre = widget.repositorio.profesorActual().catchError(
    (_) => null,
  );

  void _cambiarSesion(String? nombre) {
    if (!mounted) return;
    setState(() {
      _nombre = Future.value(nombre);
    });
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: _nombre,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final nombre = snapshot.data;
      if (nombre == null) {
        return PantallaEntrar(
          repositorio: widget.repositorio,
          alEntrar: (nombre) => _cambiarSesion(nombre),
        );
      }
      return InicioPanel(
        repositorio: widget.repositorio,
        nombre: nombre,
        alSalir: () async {
          await widget.repositorio.salir();
          _cambiarSesion(null);
        },
      );
    },
  );
}

/// Usuario o correo y contraseña, o un clic con Microsoft o Google.
class PantallaEntrar extends StatefulWidget {
  const PantallaEntrar({
    required this.repositorio,
    required this.alEntrar,
    super.key,
  });

  final RepositorioPanel repositorio;
  final ValueChanged<String> alEntrar;

  @override
  State<PantallaEntrar> createState() => _PantallaEntrarState();
}

class _PantallaEntrarState extends State<PantallaEntrar> {
  final _usuario = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ver = false;
  bool _entrando = false;
  String? _error;

  @override
  void dispose() {
    _usuario.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_entrando) return;
    setState(() {
      _entrando = true;
      _error = null;
    });
    try {
      final nombre = await widget.repositorio.entrar(
        _usuario.text,
        _contrasena.text,
      );
      if (mounted) widget.alEntrar(nombre);
    } on ErrorPanel catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No se ha podido conectar. Comprueba internet y vuelve a probar.',
        );
      }
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  Future<void> _proveedor(OAuthProvider proveedor) async {
    try {
      await widget.repositorio.entrarConProveedor(proveedor);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Ese botón todavía no está activado. Entra con tu usuario y contraseña.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5EC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: DibujoMascota(tamano: 96)),
                      const SizedBox(height: 12),
                      Text(
                        'Panel del profe',
                        textAlign: TextAlign.center,
                        style: estilo.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crea juegos para tus alumnos de NaturalMente.',
                        textAlign: TextAlign.center,
                        style: estilo.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        key: const Key('panel-usuario'),
                        controller: _usuario,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          labelText: 'Usuario o correo',
                          prefixIcon: Icon(Icons.person_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        key: const Key('panel-contrasena'),
                        controller: _contrasena,
                        obscureText: !_ver,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _entrar(),
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          helperText:
                              'Son cuatro palabras y un número, con guiones.',
                          prefixIcon: const Icon(Icons.key_rounded),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: _ver
                                ? 'Ocultar contraseña'
                                : 'Mostrar contraseña',
                            icon: Icon(
                              _ver
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                            ),
                            onPressed: () => setState(() => _ver = !_ver),
                          ),
                        ),
                      ),
                      if (_error case final error?) ...[
                        const SizedBox(height: 14),
                        Text(
                          error,
                          key: const Key('panel-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('panel-entrar'),
                        onPressed: _entrando ? null : _entrar,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                        ),
                        child: _entrando
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('o también'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        key: const Key('panel-microsoft'),
                        onPressed: () => _proveedor(OAuthProvider.azure),
                        icon: const Icon(Icons.window_rounded),
                        label: const Text('Entrar con Microsoft (Educacyl)'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        key: const Key('panel-google'),
                        onPressed: () => _proveedor(OAuthProvider.google),
                        icon: const Icon(Icons.g_mobiledata_rounded),
                        label: const Text('Entrar con Google'),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '¿Has olvidado la contraseña? Escríbenos y te damos una nueva.',
                        textAlign: TextAlign.center,
                        style: estilo.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        'Privacidad: ${Uri.base.resolve('privacidad.html')}',
                        textAlign: TextAlign.center,
                        style: estilo.bodySmall,
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

/// Lista de juegos del profesor y ajustes generales.
class InicioPanel extends StatefulWidget {
  const InicioPanel({
    required this.repositorio,
    required this.nombre,
    required this.alSalir,
    super.key,
  });

  final RepositorioPanel repositorio;
  final String nombre;
  final VoidCallback alSalir;

  @override
  State<InicioPanel> createState() => _InicioPanelState();
}

class _InicioPanelState extends State<InicioPanel> {
  late Future<List<FichaJuego>> _juegos = widget.repositorio.misJuegos();
  bool? _ranking;

  @override
  void initState() {
    super.initState();
    widget.repositorio.rankingActivo().then(
      (activo) => mounted ? setState(() => _ranking = activo) : null,
      onError: (_) {},
    );
  }

  void _recargar() {
    final juegos = widget.repositorio.misJuegos();
    setState(() {
      _juegos = juegos;
    });
  }

  Future<void> _abrirEditor([FichaJuego? ficha, bool duplicar = false]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditorJuegoPage(
          repositorio: widget.repositorio,
          ficha: ficha,
          duplicar: duplicar,
        ),
      ),
    );
    _recargar();
  }

  Future<void> _borrar(FichaJuego ficha) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Text('¿Borrar «${ficha.juego.titulo}»?'),
        content: const Text(
          'Desaparecerá de Aula y se borrarán también sus resultados. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('panel-confirmar-borrar'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.repositorio.borrar(ficha.juego.id);
    _recargar();
  }

  Future<void> _cambiarRanking(bool activo) async {
    final anterior = _ranking;
    setState(() => _ranking = activo);
    try {
      await widget.repositorio.cambiarRanking(activo);
    } catch (_) {
      if (!mounted) return;
      setState(() => _ranking = anterior);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido cambiar el ranking.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF5EC),
        title: const Text('NaturalMente · Panel del profe'),
        actions: [
          TextButton.icon(
            key: const Key('panel-salir'),
            onPressed: widget.alSalir,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Salir'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<FichaJuego>>(
        future: _juegos,
        builder: (context, snapshot) {
          final juegos = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '¡Hola, ${widget.nombre}!',
                        style: estilo.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            key: const Key('panel-nuevo'),
                            onPressed: () => _abrirEditor(),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(260, 60),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 28),
                            label: const Text('Crear un juego nuevo'),
                          ),
                          if (_ranking != null)
                            Card(
                              child: SizedBox(
                                width: 360,
                                child: SwitchListTile(
                                  key: const Key('panel-ranking'),
                                  value: _ranking!,
                                  onChanged: _cambiarRanking,
                                  title: const Text('Ranking en la app'),
                                  subtitle: const Text(
                                    'Los niños ven quién ha jugado más y mejor en su curso.',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Mis juegos',
                        style: estilo.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (snapshot.hasError)
                        Column(
                          children: [
                            const Text(
                              'No se han podido cargar tus juegos. Comprueba internet.',
                            ),
                            TextButton(
                              onPressed: _recargar,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        )
                      else if (juegos == null)
                        const Center(child: CircularProgressIndicator())
                      else if (juegos.isEmpty)
                        const Card(
                          key: Key('panel-sin-juegos'),
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Todavía no has creado ningún juego. Pulsa «Crear un juego nuevo» para empezar: '
                              'eliges un tipo de juego, escribes las preguntas y lo publicas para tus cursos.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      else
                        for (final ficha in juegos)
                          _TarjetaJuegoPanel(
                            ficha: ficha,
                            onEditar: () => _abrirEditor(ficha),
                            onDuplicar: () => _abrirEditor(ficha, true),
                            onBorrar: () => _borrar(ficha),
                            onResultados: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ResultadosPage(
                                  repositorio: widget.repositorio,
                                  juego: ficha.juego,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TarjetaJuegoPanel extends StatelessWidget {
  const _TarjetaJuegoPanel({
    required this.ficha,
    required this.onEditar,
    required this.onDuplicar,
    required this.onBorrar,
    required this.onResultados,
  });

  final FichaJuego ficha;
  final VoidCallback onEditar;
  final VoidCallback onDuplicar;
  final VoidCallback onBorrar;
  final VoidCallback onResultados;

  @override
  Widget build(BuildContext context) {
    final juego = ficha.juego;
    final publicado = ficha.estado == EstadoJuego.publicado;
    final fecha = ficha.actualizado;
    return Card(
      key: Key('panel-juego-${juego.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEditar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            juego.titulo,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(publicado ? 'Publicado' : 'Borrador'),
                          avatar: Icon(
                            publicado
                                ? Icons.public_rounded
                                : Icons.edit_note_rounded,
                            size: 18,
                          ),
                          backgroundColor: publicado
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                        ),
                      ],
                    ),
                    Text(
                      '${juego.plantilla.nombre} · ${juego.preguntas.length} preguntas · '
                      '${juego.cursos.map((c) => '$cº').join(', ')} · '
                      'cambiado el ${fecha.day}/${fecha.month}/${fecha.year}',
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 6,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onResultados,
                    icon: const Icon(Icons.bar_chart_rounded),
                    label: const Text('Resultados'),
                  ),
                  IconButton(
                    tooltip: 'Duplicar',
                    onPressed: onDuplicar,
                    icon: const Icon(Icons.copy_rounded),
                  ),
                  IconButton(
                    key: Key('panel-borrar-${juego.id}'),
                    tooltip: 'Borrar',
                    onPressed: onBorrar,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fondo de la galería por su id, para el editor.
Widget miniaturaGaleria(String id, {double ancho = 96, double alto = 64}) =>
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: Image.asset(galeriaAula[id]!.$1, fit: BoxFit.cover),
      ),
    );
