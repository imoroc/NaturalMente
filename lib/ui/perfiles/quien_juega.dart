import 'package:flutter/material.dart';

import 'package:naturalmente/datos/aula/aula.dart';
import 'package:naturalmente/datos/perfiles.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/datos/aula/llave.dart';
import 'package:naturalmente/ui/perfiles/llave_page.dart';
import 'package:naturalmente/ui/tema.dart';
import 'package:naturalmente/ui/texto.dart';

/// Mote del perfil en el idioma de la app.
String moteDe(BuildContext context, Perfil perfil) =>
    perfil.mote(IdiomaScope.of(context)?.codigo ?? 'es');

/// Natu de un perfil, con su color y el traje y la pose de su propio armario.
class NatuDePerfil extends StatelessWidget {
  const NatuDePerfil({
    required this.perfiles,
    required this.perfil,
    this.tamano = 64,
    super.key,
  });

  final Perfiles perfiles;
  final Perfil perfil;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final progreso = perfiles.progresoDe(perfil.id);
    return DibujoMascota(
      gesto: progreso.poseEquipada,
      traje: progreso.trajeEquipado,
      colorPanuelo: perfil.colorPanuelo,
      tamano: tamano,
    );
  }
}

/// Hoja para elegir quién juega en este dispositivo.
Future<void> mostrarQuienJuega(BuildContext context) {
  final perfiles = PerfilesScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: context.coloresNaturales.tarjeta,
    builder: (_) => _HojaQuienJuega(perfiles: perfiles),
  );
}

class _HojaQuienJuega extends StatefulWidget {
  const _HojaQuienJuega({required this.perfiles});
  final Perfiles perfiles;

  @override
  State<_HojaQuienJuega> createState() => _HojaQuienJuegaState();
}

class _HojaQuienJuegaState extends State<_HojaQuienJuega> {
  bool _ocupada = false;
  String? _aviso;

  Future<void> _elegir(Perfil perfil) async {
    if (_ocupada) return;
    setState(() {
      _ocupada = true;
      _aviso = null;
    });
    final ok = await widget.perfiles.elegir(perfil.id);
    if (!mounted) return;
    if (ok) {
      context.sonidoSeleccion();
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _ocupada = false;
      _aviso = 'No se ha podido cambiar de jugador. Inténtalo de nuevo.';
    });
  }

  void _abrirEditor({Perfil? perfil}) {
    context.sonidoToque();
    final navegador = Navigator.of(context);
    navegador.pop();
    navegador.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EditorPerfilPage(perfiles: widget.perfiles, perfil: perfil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return ListenableBuilder(
      listenable: widget.perfiles,
      builder: (context, _) {
        final perfiles = widget.perfiles;
        return SafeArea(
          child: SingleChildScrollView(
            key: const Key('hoja-quien-juega'),
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Texto(
                    '¿Quién juega?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colores.tinta,
                      fontFamily: 'NunitoInicio',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 14,
                  children: [
                    for (final perfil in perfiles.lista)
                      _FichaPerfil(
                        key: Key('perfil-${perfil.id}'),
                        etiqueta: moteDe(context, perfil),
                        activo: perfil.id == perfiles.activo.id,
                        habilitada: !_ocupada,
                        onTap: () => _elegir(perfil),
                        dibujo: NatuDePerfil(
                          perfiles: perfiles,
                          perfil: perfil,
                          tamano: 72,
                        ),
                      ),
                    if (!perfiles.lleno)
                      _FichaPerfil(
                        key: const Key('nuevo-perfil'),
                        etiqueta: 'Nuevo jugador',
                        activo: false,
                        habilitada: !_ocupada,
                        onTap: () => _abrirEditor(),
                        dibujo: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colores.superficie(const Color(0xFFEAF6E4)),
                            border: Border.all(
                              color: colores.borde(const Color(0xFF40BE70)),
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            size: 38,
                            color: colores.contenido(const Color(0xFF2B8A4F)),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_aviso case final aviso?) ...[
                  const SizedBox(height: 12),
                  Texto(aviso, style: TextStyle(color: colores.pista)),
                ],
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  key: const Key('editar-perfil'),
                  onPressed: _ocupada
                      ? null
                      : () => _abrirEditor(perfil: perfiles.activo),
                  icon: const Icon(Icons.palette_rounded),
                  label: Texto('Cambiar mi Natu'),
                ),
                if (AulaScope.maybeOf(context) case final aula?
                    when aula.disponible && !perfiles.lleno) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    key: const Key('tengo-llave'),
                    onPressed: _ocupada
                        ? null
                        : () {
                            context.sonidoToque();
                            final navegador = Navigator.of(context);
                            navegador.pop();
                            navegador.push(
                              MaterialPageRoute<void>(
                                builder: (_) => CanjearLlavePage(aula: aula),
                              ),
                            );
                          },
                    icon: const Text('🔑', style: TextStyle(fontSize: 18)),
                    label: Texto('Tengo una llave de otra tablet'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FichaPerfil extends StatelessWidget {
  const _FichaPerfil({
    required this.etiqueta,
    required this.activo,
    required this.habilitada,
    required this.onTap,
    required this.dibujo,
    super.key,
  });

  final String etiqueta;
  final bool activo;
  final bool habilitada;
  final VoidCallback onTap;
  final Widget dibujo;

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    return Semantics(
      button: true,
      selected: activo,
      label: context.tr(etiqueta),
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: habilitada ? onTap : null,
          child: Container(
            width: 104,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: activo
                  ? colores.superficie(const Color(0xFFEAF6E4))
                  : Colors.transparent,
              border: Border.all(
                color: activo
                    ? colores.borde(const Color(0xFF40BE70))
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    dibujo,
                    if (activo)
                      const Positioned(
                        right: -4,
                        bottom: -2,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Color(0xFF2ECC71),
                          child: Icon(
                            Icons.check_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Texto(
                  etiqueta,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    color: colores.tinta,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    height: 1.15,
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

/// Crea un jugador nuevo o cambia el color y el mote del que ya existe.
class EditorPerfilPage extends StatefulWidget {
  const EditorPerfilPage({required this.perfiles, this.perfil, super.key});

  final Perfiles perfiles;

  /// `null` para crear un jugador nuevo.
  final Perfil? perfil;

  @override
  State<EditorPerfilPage> createState() => _EditorPerfilPageState();
}

class _EditorPerfilPageState extends State<EditorPerfilPage> {
  late String _animal, _adjetivo, _color;
  int? _curso;
  bool _guardando = false;
  String? _aviso;

  bool get _nuevo => widget.perfil == null;

  @override
  void initState() {
    super.initState();
    final perfil = widget.perfil;
    if (perfil != null) {
      _animal = perfil.animal;
      _adjetivo = perfil.adjetivo;
      _color = perfil.color;
    } else {
      final (animal, adjetivo) = widget.perfiles.proponerMote();
      _animal = animal;
      _adjetivo = adjetivo;
      final usados = {for (final p in widget.perfiles.lista) p.color};
      _color = coloresNatu.keys.firstWhere(
        (c) => !usados.contains(c),
        orElse: () => coloresNatu.keys.first,
      );
    }
  }

  void _otroMote() {
    context.sonidoToque();
    setState(() {
      var mote = widget.perfiles.proponerMote();
      while (mote == (_animal, _adjetivo)) {
        mote = widget.perfiles.proponerMote();
      }
      _animal = mote.$1;
      _adjetivo = mote.$2;
    });
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    setState(() {
      _guardando = true;
      _aviso = null;
    });
    final bool ok;
    if (widget.perfil case final perfil?) {
      ok = await widget.perfiles.actualizar(
        perfil.copiar(animal: _animal, adjetivo: _adjetivo, color: _color),
      );
    } else {
      ok =
          await widget.perfiles.crear(
            animal: _animal,
            adjetivo: _adjetivo,
            color: _color,
            curso: _curso,
          ) !=
          null;
    }
    if (!mounted) return;
    if (ok) {
      context.sonidoAcierto();
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _guardando = false;
      _aviso = 'No se ha podido guardar. Inténtalo de nuevo.';
    });
  }

  Future<void> _quitar() async {
    final perfil = widget.perfil;
    final aula = AulaScope.maybeOf(context);
    if (perfil == null || aula == null) return;
    final llave = Llave.leer(aula.perfilNube(perfil.id)?.llave ?? '');
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Texto('¿Quitar a ${moteDe(context, perfil)} de esta tablet?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Texto(
              'Su progreso sigue guardado. Para traerlo de nuevo hará falta su nombre y esta llave:',
            ),
            if (llave != null) ...[
              const SizedBox(height: 12),
              LlaveVisual(llave: llave, tamano: 48),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Texto('Cancelar'),
          ),
          TextButton(
            key: const Key('confirmar-quitar-perfil'),
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Texto('Quitar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _guardando = true);
    final resultado = await aula.quitarDeEsteDispositivo(perfil.id);
    if (!mounted) return;
    if (resultado == ResultadoQuitar.quitado) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _guardando = false;
      _aviso = resultado == ResultadoQuitar.pendientes
          ? 'Tiene partidas sin enviar. Conéctate a internet y vuelve a intentarlo.'
          : 'No se ha podido quitar. Inténtalo de nuevo.';
    });
  }

  Future<void> _borrar() async {
    final perfil = widget.perfil;
    if (perfil == null || perfil.principal) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Texto('¿Borrar a ${moteDe(context, perfil)}?'),
        content: Texto(
          'Se borrarán su progreso, sus semillas, sus cromos y sus resultados de Aula.',
        ),
        actions: [
          TextButton(
            key: const Key('cancelar-borrar-perfil'),
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: Texto('Cancelar'),
          ),
          TextButton(
            key: const Key('confirmar-borrar-perfil'),
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: Texto('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _guardando = true);
    // Primero la nube: si fallara después, sus datos quedarían sin dueño.
    final aula = AulaScope.maybeOf(context);
    if (aula != null && !await aula.borrarPerfilNube(perfil.id)) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _aviso = 'Para borrar a este jugador hace falta conexión, porque también se borran sus resultados de Aula.';
      });
      return;
    }
    final ok = await widget.perfiles.eliminar(perfil.id);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _guardando = false;
      _aviso = 'No se ha podido borrar. Inténtalo de nuevo.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.coloresNaturales;
    final idioma = IdiomaScope.of(context)?.codigo ?? 'es';
    final vista = Perfil(
      id: widget.perfil?.id ?? '_',
      animal: _animal,
      adjetivo: _adjetivo,
      color: _color,
    );
    final progreso = widget.perfil == null
        ? null
        : widget.perfiles.progresoDe(widget.perfil!.id);
    TextStyle titulo() => TextStyle(
      color: colores.tinta,
      fontSize: 16,
      fontWeight: FontWeight.w800,
    );

    return Scaffold(
      backgroundColor: colores.fondo,
      appBar: AppBar(
        title: Texto(_nuevo ? 'Nuevo jugador' : 'Mi Natu'),
        backgroundColor: colores.fondo,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Center(
                  child: DibujoMascota(
                    gesto: progreso?.poseEquipada ?? 'hola',
                    traje: progreso?.trajeEquipado ?? 'ninguno',
                    colorPanuelo: vista.colorPanuelo,
                    tamano: 140,
                  ),
                ),
                const SizedBox(height: 14),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    vista.mote(idioma),
                    key: const Key('mote-perfil'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colores.tinta,
                      fontFamily: 'NunitoInicio',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Center(
                  child: TextButton.icon(
                    key: const Key('otro-mote'),
                    onPressed: _guardando ? null : _otroMote,
                    icon: const Icon(Icons.casino_rounded),
                    label: Texto('Otro nombre'),
                  ),
                ),
                const SizedBox(height: 14),
                Texto('Color del pañuelo', style: titulo()),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final MapEntry(key: id, value: (color, nombre))
                        in coloresNatu.entries)
                      Semantics(
                        button: true,
                        selected: id == _color,
                        label: context.tr(nombre),
                        child: InkResponse(
                          key: Key('color-$id'),
                          radius: 28,
                          onTap: _guardando
                              ? null
                              : () {
                                  context.sonidoSeleccion();
                                  setState(() => _color = id);
                                },
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: id == _color
                                    ? colores.tinta
                                    : Colors.transparent,
                                width: 3.5,
                              ),
                            ),
                            child: id == _color
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_nuevo) ...[
                  const SizedBox(height: 22),
                  Texto('¿En qué curso estás?', style: titulo()),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (var c = 1; c <= 6; c++) ...[
                        if (c > 1) const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            key: Key('curso-nuevo-$c'),
                            label: Center(child: Text('$cº')),
                            showCheckmark: false,
                            selected: _curso == c,
                            onSelected: _guardando
                                ? null
                                : (sel) =>
                                      setState(() => _curso = sel ? c : null),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Texto(
                    'Puedes dejarlo sin elegir y cambiarlo después.',
                    style: TextStyle(color: colores.tenue, fontSize: 12.5),
                  ),
                ],
                if (_aviso case final aviso?) ...[
                  const SizedBox(height: 14),
                  Texto(aviso, style: TextStyle(color: colores.pista)),
                ],
                const SizedBox(height: 26),
                FilledButton(
                  key: const Key('guardar-perfil'),
                  onPressed: _guardando ? null : _guardar,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                  ),
                  child: Texto(
                    _nuevo ? '¡A jugar!' : 'Guardar',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if ((widget.perfil, AulaScope.maybeOf(context))
                    case (final perfil?, final aula?) when aula.disponible) ...[
                  const SizedBox(height: 26),
                  SeccionMiLlave(aula: aula, perfilId: perfil.id),
                ],
                if (widget.perfil case final perfil?
                    when !perfil.principal) ...[
                  const SizedBox(height: 12),
                  // Con llave, quitarlo de una tablet compartida no borra su
                  // progreso de la nube: lo recupera con su llave.
                  if (AulaScope.maybeOf(context)?.perfilNube(perfil.id) != null)
                    OutlinedButton.icon(
                      key: const Key('quitar-perfil'),
                      onPressed: _guardando ? null : _quitar,
                      icon: const Icon(Icons.logout_rounded),
                      label: Texto('Quitar de esta tablet'),
                    ),
                  TextButton.icon(
                    key: const Key('borrar-perfil'),
                    onPressed: _guardando ? null : _borrar,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Texto(
                      AulaScope.maybeOf(context)?.perfilNube(perfil.id) != null
                          ? 'Borrar para siempre'
                          : 'Borrar este jugador',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
