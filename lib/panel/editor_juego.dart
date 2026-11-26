import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/panel/editor_retos.dart';
import 'package:naturalmente/panel/imagenes_panel.dart';
import 'package:naturalmente/panel/panel_app.dart' show miniaturaGaleria;
import 'package:naturalmente/panel/repositorio_panel.dart';
import 'package:naturalmente/ui/aula/escenas.dart';
import 'package:naturalmente/ui/aula/juego_aula_page.dart';

enum _Guardado { guardado, pendiente, guardando, error }

/// Crea o cambia un juego: elegir plantilla, rellenar y publicar.
class EditorJuegoPage extends StatefulWidget {
  const EditorJuegoPage({
    required this.repositorio,
    this.ficha,
    this.duplicar = false,
    this.elegirImagen = elegirYSubirImagen,
    super.key,
  });

  final RepositorioPanel repositorio;
  final FichaJuego? ficha;
  final bool duplicar;

  /// Elige, comprime y sube una foto. Las pruebas la sustituyen.
  final Future<ImagenSubida?> Function(RepositorioPanel) elegirImagen;

  @override
  State<EditorJuegoPage> createState() => _EditorJuegoPageState();
}

class _EditorJuegoPageState extends State<EditorJuegoPage> {
  PlantillaAula? _plantilla;
  String _id = '';
  String _titulo = '';
  String _intro = '';
  List<int> _cursos = [];
  ImagenAula? _fondo = const ImagenEscena('pradera');
  bool _natu = true;
  final List<RetoEditable> _preguntas = [];
  int _siguienteClave = 0;
  EstadoJuego _estado = EstadoJuego.borrador;
  _Guardado _guardado = _Guardado.guardado;
  Timer? _autoguardado;
  bool _intentoPublicar = false;
  bool _subiendo = false;
  String? _mensaje;

  /// Sube una foto y la devuelve, o `null` si se cancela o falla.
  Future<ImagenSubida?> _subirImagen() async {
    if (_subiendo) return null;
    setState(() {
      _subiendo = true;
      _mensaje = null;
    });
    try {
      return await widget.elegirImagen(widget.repositorio);
    } on ErrorPanel catch (e) {
      if (mounted) setState(() => _mensaje = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(
          () => _mensaje = 'No se ha podido subir la imagen. Prueba otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _subiendo = false);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final ficha = widget.ficha;
    if (ficha == null) return;
    final juego = ficha.juego;
    _plantilla = juego.plantilla;
    _titulo = widget.duplicar ? '${juego.titulo} (copia)' : juego.titulo;
    _id = widget.duplicar ? '' : juego.id;
    _estado = widget.duplicar ? EstadoJuego.borrador : ficha.estado;
    _intro = juego.intro;
    _cursos = List.of(juego.cursos);
    _fondo = juego.fondo;
    _natu = juego.mostrarNatu;
    for (final p in juego.preguntas) {
      _preguntas.add(RetoEditable.desde(p, _siguienteClave++));
    }
    if (widget.duplicar) _guardado = _Guardado.pendiente;
  }

  @override
  void dispose() {
    _autoguardado?.cancel();
    super.dispose();
  }

  /// Los juegos antiguos siguen con su plantilla mientras todos sus retos
  /// sean de ese tipo; si se añade otro tipo, pasan a ser libres.
  PlantillaAula get _plantillaGuardada {
    final original = _plantilla!;
    if (original == PlantillaAula.libre) return original;
    return _preguntas.every((p) => p.tipo == original.tipoPorDefecto)
        ? original
        : PlantillaAula.libre;
  }

  JuegoAula get _juego => JuegoAula(
    id: _id,
    titulo: _titulo.trim(),
    plantilla: _plantillaGuardada,
    version: 1,
    cursos: List.of(_cursos)..sort(),
    preguntas: [for (final p in _preguntas) p.reto],
    fondo: _fondo,
    mostrarNatu: _natu,
    intro: _intro.trim(),
  );

  void _empezarCon(TipoReto tipo) {
    setState(() {
      _plantilla = PlantillaAula.libre;
      _preguntas.add(RetoEditable(tipo, clave: _siguienteClave++));
    });
  }

  Future<void> _anadirReto() async {
    final tipo = await elegirTipoReto(context);
    if (tipo == null || !mounted) return;
    _cambio(() => _preguntas.add(RetoEditable(tipo, clave: _siguienteClave++)));
  }

  /// Hoja de imágenes: subir una foto o elegir una de la app.
  Future<ImagenAula?> _elegirImagen() => elegirImagenAula(context, _subirImagen);

  /// Cada cambio se guarda solo en los borradores. Un juego publicado se
  /// guarda con su botón, para no crear una versión nueva a cada letra.
  void _cambio(VoidCallback cambiar) {
    setState(() {
      cambiar();
      _guardado = _Guardado.pendiente;
      _mensaje = null;
    });
    _autoguardado?.cancel();
    if (_estado == EstadoJuego.borrador) {
      _autoguardado = Timer(const Duration(milliseconds: 1500), () {
        _guardar(EstadoJuego.borrador, silencioso: true);
      });
    }
  }

  Future<bool> _guardar(EstadoJuego estado, {bool silencioso = false}) async {
    _autoguardado?.cancel();
    if (estado == EstadoJuego.publicado) {
      setState(() => _intentoPublicar = true);
      if (_juego.errores().isNotEmpty) return false;
    }
    if (_guardado == _Guardado.guardando) return false;
    setState(() => _guardado = _Guardado.guardando);
    try {
      final ficha = await widget.repositorio.guardar(_juego, estado);
      if (!mounted) return true;
      setState(() {
        _id = ficha.juego.id;
        _estado = ficha.estado;
        _guardado = _Guardado.guardado;
        if (!silencioso) {
          _mensaje = estado == EstadoJuego.publicado
              ? '¡Publicado! Tus alumnos ya lo ven en Aula.'
              : 'Guardado como borrador. Los niños todavía no lo ven.';
        }
      });
      return true;
    } on ErrorPanel catch (e) {
      if (mounted) {
        setState(() {
          _guardado = _Guardado.error;
          _mensaje = e.mensaje;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardado = _Guardado.error;
          _mensaje = 'No se ha podido guardar. Comprueba internet.';
        });
      }
    }
    return false;
  }

  Future<bool> _puedeSalir() async {
    if (_guardado == _Guardado.guardado) return true;
    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Hay cambios sin guardar'),
        content: const Text('¿Quieres guardarlos antes de salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Salir sin guardar'),
          ),
          FilledButton(
            key: const Key('editor-guardar-y-salir'),
            onPressed: () async {
              final ok = await _guardar(
                _estado == EstadoJuego.publicado && _juego.errores().isEmpty
                    ? EstadoJuego.publicado
                    : EstadoJuego.borrador,
              );
              if (dialogo.mounted) Navigator.of(dialogo).pop(ok);
            },
            child: const Text('Guardar y salir'),
          ),
        ],
      ),
    );
    return salir ?? false;
  }

  void _probar() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JuegoAulaPage(juego: _juego, vistaPrevia: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantilla = _plantilla;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (salio, _) async {
        if (salio) return;
        final navegador = Navigator.of(context);
        if (await _puedeSalir()) navegador.pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF5EC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF5EC),
          title: Text(
            plantilla == null
                ? 'Nuevo juego: ¿con qué reto empezamos?'
                : (_titulo.isEmpty ? 'Juego sin título' : _titulo),
          ),
          actions: [if (plantilla != null) _EstadoGuardado(_guardado)],
        ),
        body: plantilla == null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Un juego es una serie de retos. Elige el primero; luego podrás añadir más, de cualquier tipo y en el orden que quieras.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        RejillaTiposReto(onElegir: _empezarCon),
                      ],
                    ),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, medidas) {
                  final ancho = medidas.maxWidth >= 1100;
                  final formulario = _formulario(context, plantilla, ancho);
                  if (!ancho) return formulario;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: formulario),
                      SizedBox(width: 420, child: _VistaPrevia(juego: _juego)),
                    ],
                  );
                },
              ),
        bottomNavigationBar: plantilla == null ? null : _barraAcciones(),
      ),
    );
  }

  Widget _barraAcciones() {
    final publicado = _estado == EstadoJuego.publicado;
    final errores = _intentoPublicar ? _juego.errores() : const <String>[];
    return Material(
      elevation: 8,
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errores.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Antes de publicar: ${errores.join(' ')}',
                    key: const Key('editor-errores'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else if (_mensaje case final mensaje?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    mensaje,
                    key: const Key('editor-mensaje'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('editor-probar'),
                    onPressed: _juego.errores().isEmpty ? _probar : null,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Probar como un niño'),
                  ),
                  if (publicado)
                    OutlinedButton.icon(
                      key: const Key('editor-retirar'),
                      onPressed: () => _guardar(EstadoJuego.borrador),
                      icon: const Icon(Icons.visibility_off_rounded),
                      label: const Text('Retirar de Aula'),
                    )
                  else
                    OutlinedButton.icon(
                      key: const Key('editor-borrador'),
                      onPressed: () => _guardar(EstadoJuego.borrador),
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Guardar borrador'),
                    ),
                  FilledButton.icon(
                    key: const Key('editor-publicar'),
                    onPressed: () => _guardar(EstadoJuego.publicado),
                    icon: const Icon(Icons.public_rounded),
                    label: Text(publicado ? 'Guardar cambios' : 'Publicar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formulario(
    BuildContext context,
    PlantillaAula plantilla,
    bool ancho,
  ) {
    final estilo = Theme.of(context).textTheme;
    return ListView(
      key: const Key('editor-formulario'),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        _Seccion(
          titulo: '1. Datos del juego',
          children: [
            TextFormField(
              key: const Key('editor-titulo'),
              initialValue: _titulo,
              maxLength: 120,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Por ejemplo: Los animales vertebrados',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _cambio(() => _titulo = v),
            ),
            const SizedBox(height: 8),
            Text('¿Para qué cursos es?', style: estilo.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (var c = 1; c <= 6; c++)
                  FilterChip(
                    key: Key('editor-curso-$c'),
                    label: Text('$cº'),
                    selected: _cursos.contains(c),
                    onSelected: (si) =>
                        _cambio(() => si ? _cursos.add(c) : _cursos.remove(c)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('editor-intro'),
              initialValue: _intro,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Lo que dice Natu al empezar (opcional)',
                hintText: '¡Vamos a repasar lo que hemos visto en clase!',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _cambio(() => _intro = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _natu,
              onChanged: (v) => _cambio(() => _natu = v),
              title: const Text('Que aparezca Natu'),
            ),
            Text('Fondo', style: estilo.titleMedium),
            const SizedBox(height: 4),
            const Text('Dibujos que se adaptan a cualquier pantalla:'),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 10,
              children: [
                for (final MapEntry(key: id, value: nombre)
                    in escenasAula.entries)
                  _OpcionFondo(
                    key: Key('editor-escena-$id'),
                    seleccionado: _fondo == ImagenEscena(id),
                    tooltip: nombre,
                    onTap: () => _cambio(() => _fondo = ImagenEscena(id)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 96,
                        height: 64,
                        child: EscenaAula(id),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Fotos de la app:'),
            const SizedBox(height: 8),
            Wrap(
              runSpacing: 10,
              children: [
                _OpcionFondo(
                  key: const Key('editor-sin-fondo'),
                  seleccionado: _fondo == null,
                  onTap: () => _cambio(() => _fondo = null),
                  child: Container(
                    width: 96,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Sin fondo'),
                  ),
                ),
                for (final id in galeriaAula.keys)
                  _OpcionFondo(
                    key: Key('editor-fondo-$id'),
                    seleccionado: _fondo == ImagenGaleria(id),
                    tooltip: galeriaAula[id]!.$2,
                    onTap: () => _cambio(() => _fondo = ImagenGaleria(id)),
                    child: miniaturaGaleria(id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (_fondo case final ImagenSubida foto)
                  _OpcionFondo(
                    key: const Key('editor-fondo-subido'),
                    seleccionado: true,
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 96,
                        height: 64,
                        child: ImagenDeAula(foto, ajuste: BoxFit.cover),
                      ),
                    ),
                  ),
                OutlinedButton.icon(
                  key: const Key('editor-subir-fondo'),
                  onPressed: _subiendo
                      ? null
                      : () async {
                          final foto = await _subirImagen();
                          if (foto != null) _cambio(() => _fondo = foto);
                        },
                  icon: _subiendo
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_photo_alternate_rounded),
                  label: const Text('Subir una foto mía'),
                ),
              ],
            ),
          ],
        ),
        _Seccion(
          titulo: '2. Retos (${_preguntas.length})',
          children: [
            for (var i = 0; i < _preguntas.length; i++)
              _TarjetaReto(
                key: ValueKey(_preguntas[i].clave),
                numero: i + 1,
                reto: _preguntas[i],
                marcarErrores: _intentoPublicar,
                onCambio: _cambio,
                elegirImagen: _elegirImagen,
                onSubir: i == 0
                    ? null
                    : () => _cambio(() => _preguntas.insert(i - 1, _preguntas.removeAt(i))),
                onBajar: i == _preguntas.length - 1
                    ? null
                    : () => _cambio(() => _preguntas.insert(i + 1, _preguntas.removeAt(i))),
                onDuplicar: _preguntas.length >= JuegoAula.maxPreguntas
                    ? null
                    : () => _cambio(
                        () => _preguntas.insert(i + 1, _preguntas[i].copia(_siguienteClave++)),
                      ),
                onBorrar: _preguntas.length == 1
                    ? null
                    : () => _cambio(() => _preguntas.removeAt(i)),
              ),
            if (_preguntas.length < JuegoAula.maxPreguntas)
              OutlinedButton.icon(
                key: const Key('editor-anadir-pregunta'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                onPressed: _anadirReto,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Añadir reto', style: TextStyle(fontSize: 17)),
              ),
          ],
        ),
        if (!ancho)
          _Seccion(
            titulo: '3. Así lo verán',
            children: [
              SizedBox(height: 640, child: _VistaPrevia(juego: _juego)),
            ],
          ),
      ],
    );
  }
}

/// Un reto en el editor: su tipo, el enunciado, sus campos y la ayuda.
class _TarjetaReto extends StatelessWidget {
  const _TarjetaReto({
    required this.numero,
    required this.reto,
    required this.marcarErrores,
    required this.onCambio,
    required this.elegirImagen,
    required this.onSubir,
    required this.onBajar,
    required this.onDuplicar,
    required this.onBorrar,
    super.key,
  });

  final int numero;
  final RetoEditable reto;
  final bool marcarErrores;
  final void Function(VoidCallback) onCambio;
  final Future<ImagenAula?> Function() elegirImagen;
  final VoidCallback? onSubir;
  final VoidCallback? onBajar;
  final VoidCallback? onDuplicar;
  final VoidCallback? onBorrar;

  @override
  Widget build(BuildContext context) {
    final r = reto;
    final n = numero;
    final lectura = r.tipo == TipoReto.lectura;
    final etiqueta = switch (r.tipo) {
      TipoReto.verdaderoFalso => 'Frase',
      TipoReto.lectura => 'Título (opcional)',
      TipoReto.buscar => 'Qué hay que buscar (por ejemplo: Toca el corazón)',
      TipoReto.clasificar || TipoReto.ordenar || TipoReto.parejas || TipoReto.huecos =>
        'Instrucción (opcional, por ejemplo: Ordena el ciclo de la rana)',
      _ => 'Pregunta',
    };
    final obligatorio = r.tipo == TipoReto.opcionMultiple ||
        r.tipo == TipoReto.verdaderoFalso ||
        r.tipo == TipoReto.buscar;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(iconoReto(r.tipo), color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$n. ${r.tipo.nombre}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(tooltip: 'Subir', onPressed: onSubir, icon: const Icon(Icons.arrow_upward_rounded)),
                IconButton(tooltip: 'Bajar', onPressed: onBajar, icon: const Icon(Icons.arrow_downward_rounded)),
                IconButton(tooltip: 'Duplicar', onPressed: onDuplicar, icon: const Icon(Icons.copy_rounded)),
                IconButton(
                  key: Key('editor-borrar-pregunta-$n'),
                  tooltip: 'Borrar reto',
                  onPressed: onBorrar,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('editor-enunciado-$n'),
              initialValue: r.enunciado,
              maxLines: null,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                labelText: etiqueta,
                border: const OutlineInputBorder(),
                errorText: marcarErrores && obligatorio && r.enunciado.trim().isEmpty &&
                        (r.imagen == null || r.tipo == TipoReto.buscar)
                    ? 'Escribe la pregunta'
                    : null,
              ),
              onChanged: (v) => onCambio(() => r.enunciado = v),
            ),
            if (r.tipo != TipoReto.buscar) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: CampoImagen(
                  claveBase: 'editor-imagen-$n',
                  texto: 'Añadir una imagen (opcional)',
                  imagen: r.imagen,
                  onElegir: () async {
                    final imagen = await elegirImagen();
                    if (imagen != null) onCambio(() => r.imagen = imagen);
                  },
                  onQuitar: () => onCambio(() => r.imagen = null),
                ),
              ),
            ],
            EditorCamposReto(
              reto: r,
              numero: n,
              marcarErrores: marcarErrores,
              onCambio: onCambio,
              elegirImagen: elegirImagen,
            ),
            if (!lectura) ...[
              const SizedBox(height: 12),
              TextFormField(
                key: Key('editor-pista-$n'),
                initialValue: r.pista,
                decoration: const InputDecoration(
                  labelText: 'Pista si se equivoca (opcional)',
                  hintText: 'Ayúdale a pensar sin decirle la respuesta',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => onCambio(() => r.pista = v),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: Key('editor-explicacion-$n'),
                initialValue: r.explicacion,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Explicación al acertar (opcional)',
                  hintText: 'Un dato para que aprenda algo más',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => onCambio(() => r.explicacion = v),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La misma pantalla que verá el niño, dentro de un marco de móvil.
class _VistaPrevia extends StatelessWidget {
  const _VistaPrevia({required this.juego});
  final JuegoAula juego;

  @override
  Widget build(BuildContext context) {
    final errores = juego.errores()
      ..removeWhere((e) => e.contains('título') || e.contains('curso'));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Así lo verán tus alumnos',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 9 / 18,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: errores.isNotEmpty
                      ? ColoredBox(
                          color: Colors.white,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Completa las preguntas para verlas aquí.\n\n${errores.first}',
                                key: const Key('vista-previa-pendiente'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        )
                      : Navigator(
                          // Al cambiar el contenido, la vista previa empieza de nuevo.
                          key: ValueKey(jsonEncode(juego.toFila())),
                          onGenerateRoute: (_) => MaterialPageRoute<void>(
                            builder: (_) => JuegoAulaPage(
                              key: const Key('vista-previa'),
                              juego: juego.titulo.isEmpty
                                  ? juego.copiar(titulo: 'Vista previa')
                                  : juego,
                              vistaPrevia: true,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.children});
  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          titulo,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _OpcionFondo extends StatelessWidget {
  const _OpcionFondo({
    required this.seleccionado,
    required this.onTap,
    required this.child,
    this.tooltip,
    super.key,
  });

  final bool seleccionado;
  final VoidCallback onTap;
  final Widget child;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip ?? '',
    child: Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}

class _EstadoGuardado extends StatelessWidget {
  const _EstadoGuardado(this.estado);
  final _Guardado estado;

  @override
  Widget build(BuildContext context) {
    final (icono, texto) = switch (estado) {
      _Guardado.guardado => (Icons.cloud_done_rounded, 'Guardado'),
      _Guardado.pendiente => (Icons.edit_rounded, 'Cambios sin guardar'),
      _Guardado.guardando => (Icons.cloud_upload_rounded, 'Guardando…'),
      _Guardado.error => (Icons.cloud_off_rounded, 'Sin guardar'),
    };
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        key: const Key('editor-estado'),
        children: [
          Icon(icono, size: 20),
          const SizedBox(width: 6),
          Text(texto),
        ],
      ),
    );
  }
}
