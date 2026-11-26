import 'package:flutter/material.dart';

import 'package:naturalmente/modelo/aula/juego_aula.dart';
import 'package:naturalmente/panel/panel_app.dart' show miniaturaGaleria;
import 'package:naturalmente/ui/aula/juego_aula_page.dart' show ImagenDeAula;

int _siguienteId = 0;

/// Icono de cada tipo de reto en el panel.
IconData iconoReto(TipoReto tipo) => switch (tipo) {
  TipoReto.opcionMultiple => Icons.quiz_rounded,
  TipoReto.verdaderoFalso => Icons.rule_rounded,
  TipoReto.clasificar => Icons.category_rounded,
  TipoReto.ordenar => Icons.format_list_numbered_rounded,
  TipoReto.parejas => Icons.compare_arrows_rounded,
  TipoReto.huecos => Icons.short_text_rounded,
  TipoReto.buscar => Icons.touch_app_rounded,
  TipoReto.numero => Icons.pin_rounded,
  TipoReto.palabra => Icons.abc_rounded,
  TipoReto.lectura => Icons.menu_book_rounded,
};

/// Texto o imagen que el profesor está escribiendo.
class OpcionEditable {
  OpcionEditable({this.texto = '', this.imagen});
  factory OpcionEditable.desde(OpcionAula o) =>
      OpcionEditable(texto: o.texto, imagen: o.imagen);

  /// Identidad estable para que los campos no se mezclen al borrar o mover.
  final int id = _siguienteId++;
  String texto;
  ImagenAula? imagen;

  OpcionAula get opcion => OpcionAula(texto: texto.trim(), imagen: imagen);
  OpcionEditable copia() => OpcionEditable(texto: texto, imagen: imagen);
}

class ElementoEditable {
  ElementoEditable({OpcionEditable? opcion, this.grupo = -1})
    : opcion = opcion ?? OpcionEditable();
  final int id = _siguienteId++;
  final OpcionEditable opcion;
  int grupo;
}

class ParejaEditable {
  ParejaEditable({OpcionEditable? a, OpcionEditable? b})
    : a = a ?? OpcionEditable(),
      b = b ?? OpcionEditable();
  final int id = _siguienteId++;
  final OpcionEditable a;
  final OpcionEditable b;
}

/// Un reto mientras el profesor lo escribe. Guarda los campos de todos los
/// tipos para que cambiar de tipo no borre lo escrito.
class RetoEditable {
  RetoEditable(this.tipo, {required this.clave}) {
    if (tipo == TipoReto.ordenar) {
      pasos.add(OpcionEditable());
    }
  }

  factory RetoEditable.desde(RetoAula r, int clave) {
    final e = RetoEditable(r.tipo, clave: clave)
      ..enunciado = r.enunciado
      ..imagen = r.imagen
      ..pista = r.pista
      ..explicacion = r.explicacion;
    switch (r) {
      case PreguntaAula():
        e.opciones = [for (final o in r.opciones) OpcionEditable.desde(o)];
        e.correcta = r.correcta;
      case ClasificarAula():
        e.grupos = [for (final g in r.grupos) OpcionEditable.desde(g)];
        e.elementos = [
          for (final el in r.elementos)
            ElementoEditable(opcion: OpcionEditable.desde(el.elemento), grupo: el.grupo),
        ];
      case OrdenarAula():
        e.pasos = [for (final p in r.pasos) OpcionEditable.desde(p)];
      case ParejasAula():
        e.parejas = [
          for (final (a, b) in r.parejas)
            ParejaEditable(a: OpcionEditable.desde(a), b: OpcionEditable.desde(b)),
        ];
      case HuecosAula():
        e.frase = r.frase;
        e.distractores = r.distractores.join(', ');
      case BuscarAula():
        e.zonas = List.of(r.zonas);
        if (r.zonas.isNotEmpty) e.radio = r.zonas.first.radio;
      case NumeroAula():
        e.numero = r.respuesta?.toString() ?? '';
      case PalabraAula():
        e.palabra = r.respuesta;
      case LecturaAula():
        e.texto = r.texto;
    }
    return e;
  }

  final int clave;
  TipoReto tipo;
  String enunciado = '';
  ImagenAula? imagen;
  String pista = '';
  String explicacion = '';
  List<OpcionEditable> opciones = [OpcionEditable(), OpcionEditable()];
  int correcta = -1;
  List<OpcionEditable> grupos = [OpcionEditable(), OpcionEditable()];
  List<ElementoEditable> elementos = [ElementoEditable(), ElementoEditable()];
  List<OpcionEditable> pasos = [OpcionEditable(), OpcionEditable()];
  List<ParejaEditable> parejas = [ParejaEditable(), ParejaEditable()];
  String frase = '';
  String distractores = '';
  List<ZonaAula> zonas = [];
  double radio = 0.1;
  String numero = '';
  String palabra = '';
  String texto = '';

  RetoAula get reto {
    final e = enunciado.trim(), p = pista.trim(), x = explicacion.trim();
    return switch (tipo) {
      TipoReto.opcionMultiple => PreguntaAula(
        enunciado: e,
        imagen: imagen,
        opciones: [for (final o in opciones) o.opcion],
        correcta: correcta,
        pista: p,
        explicacion: x,
      ),
      TipoReto.verdaderoFalso => PreguntaAula(
        tipo: TipoReto.verdaderoFalso,
        enunciado: e,
        imagen: imagen,
        opciones: const [OpcionAula(texto: 'Verdadero'), OpcionAula(texto: 'Falso')],
        correcta: correcta > 1 ? -1 : correcta,
        pista: p,
        explicacion: x,
      ),
      TipoReto.clasificar => ClasificarAula(
        enunciado: e,
        imagen: imagen,
        grupos: [for (final g in grupos) g.opcion],
        elementos: [for (final el in elementos) ElementoGrupo(el.opcion.opcion, el.grupo)],
        pista: p,
        explicacion: x,
      ),
      TipoReto.ordenar => OrdenarAula(
        enunciado: e,
        imagen: imagen,
        pasos: [for (final paso in pasos) paso.opcion],
        pista: p,
        explicacion: x,
      ),
      TipoReto.parejas => ParejasAula(
        enunciado: e,
        imagen: imagen,
        parejas: [for (final par in parejas) (par.a.opcion, par.b.opcion)],
        pista: p,
        explicacion: x,
      ),
      TipoReto.huecos => HuecosAula(
        enunciado: e,
        imagen: imagen,
        frase: frase.trim(),
        distractores: [
          for (final d in distractores.split(','))
            if (d.trim().isNotEmpty) d.trim(),
        ],
        pista: p,
        explicacion: x,
      ),
      TipoReto.buscar => BuscarAula(
        enunciado: e,
        imagen: imagen,
        zonas: [for (final z in zonas) ZonaAula(z.x, z.y, radio)],
        pista: p,
        explicacion: x,
      ),
      TipoReto.numero => NumeroAula(
        enunciado: e,
        imagen: imagen,
        respuesta: int.tryParse(numero.trim()),
        pista: p,
        explicacion: x,
      ),
      TipoReto.palabra => PalabraAula(
        enunciado: e,
        imagen: imagen,
        respuesta: palabra.trim(),
        pista: p,
        explicacion: x,
      ),
      TipoReto.lectura => LecturaAula(enunciado: e, imagen: imagen, texto: texto.trim()),
    };
  }

  RetoEditable copia(int clave) => RetoEditable.desde(reto, clave)..tipo = tipo;
}

/// Hoja para elegir el tipo de un reto nuevo, con un ejemplo de cada uno.
Future<TipoReto?> elegirTipoReto(BuildContext context) => showModalBottomSheet<TipoReto>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (hoja) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '¿Qué tipo de reto añadimos?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          RejillaTiposReto(onElegir: (t) => Navigator.of(hoja).pop(t)),
        ],
      ),
    ),
  ),
);

/// Los 10 tipos de reto en tarjetas grandes.
class RejillaTiposReto extends StatelessWidget {
  const RejillaTiposReto({required this.onElegir, super.key});
  final ValueChanged<TipoReto> onElegir;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, medidas) {
      final columnas = (medidas.maxWidth / 300).floor().clamp(1, 4);
      final ancho = (medidas.maxWidth - 12 * (columnas - 1)) / columnas;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final tipo in TipoReto.values)
            SizedBox(
              width: ancho,
              child: Card(
                key: Key('editor-tipo-${tipo.id}'),
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onElegir(tipo),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(iconoReto(tipo), size: 36, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tipo.nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 4),
                              Text(tipo.descripcion),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// Subir una foto o elegir una de la app. Devuelve `null` si se cancela.
Future<ImagenAula?> elegirImagenAula(
  BuildContext context,
  Future<ImagenSubida?> Function() subir,
) async {
  final elegida = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (hoja) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Elige una imagen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('imagen-subir'),
              onPressed: () => Navigator.of(hoja).pop('subir'),
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Subir una foto mía'),
            ),
            const SizedBox(height: 16),
            const Text('O una de la app:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final id in galeriaAula.keys)
                  InkWell(
                    key: Key('imagen-galeria-$id'),
                    onTap: () => Navigator.of(hoja).pop(ImagenGaleria(id)),
                    child: Tooltip(message: galeriaAula[id]!.$2, child: miniaturaGaleria(id)),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (elegida == 'subir') return subir();
  return elegida is ImagenAula ? elegida : null;
}

/// Miniatura con botón para quitarla, o botón para añadir una imagen.
class CampoImagen extends StatelessWidget {
  const CampoImagen({
    required this.imagen,
    required this.onElegir,
    required this.onQuitar,
    required this.claveBase,
    this.texto = 'Añadir una imagen (opcional)',
    this.compacto = false,
    super.key,
  });

  final ImagenAula? imagen;
  final VoidCallback? onElegir;
  final VoidCallback onQuitar;
  final String claveBase;
  final String texto;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final actual = imagen;
    if (actual == null) {
      return compacto
          ? IconButton(
              key: Key('$claveBase-anadir'),
              tooltip: texto,
              onPressed: onElegir,
              icon: const Icon(Icons.add_photo_alternate_outlined),
            )
          : TextButton.icon(
              key: Key('$claveBase-anadir'),
              onPressed: onElegir,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(texto),
            );
    }
    final lado = compacto ? 40.0 : 100.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            key: Key('$claveBase-miniatura'),
            width: lado * 1.5,
            height: lado,
            child: ImagenDeAula(actual, ajuste: BoxFit.cover),
          ),
        ),
        IconButton(
          key: Key('$claveBase-quitar'),
          tooltip: 'Quitar imagen',
          onPressed: onQuitar,
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }
}

/// Editor de los campos propios de cada tipo de reto.
class EditorCamposReto extends StatelessWidget {
  const EditorCamposReto({
    required this.reto,
    required this.numero,
    required this.marcarErrores,
    required this.onCambio,
    required this.elegirImagen,
    super.key,
  });

  final RetoEditable reto;
  final int numero;
  final bool marcarErrores;
  final void Function(VoidCallback) onCambio;

  /// Abre la hoja de imágenes y devuelve la elegida (o `null`).
  final Future<ImagenAula?> Function() elegirImagen;

  Widget _campo({
    required String clave,
    required String valor,
    required String etiqueta,
    required ValueChanged<String> alCambiar,
    String? ayuda,
    String? error,
    int? lineas = 1,
    TextInputType? teclado,
    bool denso = false,
  }) => TextFormField(
    key: Key(clave),
    initialValue: valor,
    maxLines: lineas,
    keyboardType: teclado,
    decoration: InputDecoration(
      labelText: etiqueta,
      helperText: ayuda,
      helperMaxLines: 3,
      errorText: error,
      isDense: denso,
      border: const OutlineInputBorder(),
    ),
    onChanged: (v) => onCambio(() => alCambiar(v)),
  );

  /// Fila de una lista: texto, imagen y quitar.
  Widget _fila({
    required OpcionEditable opcion,
    required String clave,
    required String etiqueta,
    required bool puedeQuitar,
    required VoidCallback onQuitar,
    List<Widget> antes = const [],
    List<Widget> despues = const [],
  }) => KeyedSubtree(
    key: ValueKey(opcion.id),
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          ...antes,
          Expanded(
            child: _campo(
              clave: clave,
              valor: opcion.texto,
              etiqueta: etiqueta,
              denso: true,
              alCambiar: (v) => opcion.texto = v,
              error: marcarErrores && opcion.texto.trim().isEmpty && opcion.imagen == null
                  ? 'Escribe algo o pon una imagen'
                  : null,
            ),
          ),
          CampoImagen(
            claveBase: '$clave-imagen',
            compacto: true,
            imagen: opcion.imagen,
            onElegir: () async {
              final imagen = await elegirImagen();
              if (imagen != null) onCambio(() => opcion.imagen = imagen);
            },
            onQuitar: () => onCambio(() => opcion.imagen = null),
          ),
          ...despues,
          IconButton(
            key: Key('$clave-quitar'),
            tooltip: 'Quitar',
            onPressed: puedeQuitar ? onQuitar : null,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    ),
  );

  Widget _anadir(String clave, String texto, VoidCallback? onPressed) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      key: Key(clave),
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded),
      label: Text(texto),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final r = reto;
    final n = numero;
    final rojo = Theme.of(context).colorScheme.error;
    final hijos = <Widget>[];

    void ayuda(String texto) => hijos.add(
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );

    switch (r.tipo) {
      case TipoReto.opcionMultiple:
        ayuda('Respuestas: marca el círculo de la correcta');
        hijos.add(
          RadioGroup<int>(
            groupValue: r.correcta,
            onChanged: (v) => onCambio(() => r.correcta = v ?? -1),
            child: Column(
              children: [
                for (var j = 0; j < r.opciones.length; j++)
                  _fila(
                    opcion: r.opciones[j],
                    clave: 'editor-opcion-$n-$j',
                    etiqueta: 'Respuesta ${j + 1}',
                    puedeQuitar: r.opciones.length > 2,
                    antes: [Radio<int>(key: Key('editor-correcta-$n-$j'), value: j)],
                    onQuitar: () => onCambio(() {
                      r.opciones.removeAt(j);
                      if (r.correcta == j) {
                        r.correcta = -1;
                      } else if (r.correcta > j) {
                        r.correcta--;
                      }
                    }),
                  ),
              ],
            ),
          ),
        );
        if (marcarErrores && (r.correcta < 0 || r.correcta >= r.opciones.length)) {
          hijos.add(Text('Marca la respuesta correcta', style: TextStyle(color: rojo)));
        }
        if (r.opciones.length < 4) {
          hijos.add(_anadir('editor-anadir-opcion-$n', 'Añadir respuesta',
              () => onCambio(() => r.opciones.add(OpcionEditable()))));
        }
      case TipoReto.verdaderoFalso:
        hijos.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Text('Esta frase es: '),
                const SizedBox(width: 8),
                SegmentedButton<int>(
                  key: Key('editor-vf-$n'),
                  emptySelectionAllowed: true,
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Verdadera')),
                    ButtonSegment(value: 1, label: Text('Falsa')),
                  ],
                  selected: {if (r.correcta == 0 || r.correcta == 1) r.correcta},
                  onSelectionChanged: (s) {
                    if (s.isNotEmpty) onCambio(() => r.correcta = s.first);
                  },
                ),
              ],
            ),
          ),
        );
        if (marcarErrores && r.correcta != 0 && r.correcta != 1) {
          hijos.add(Text('Elige si es verdadera o falsa', style: TextStyle(color: rojo)));
        }
      case TipoReto.clasificar:
        ayuda('Grupos (de 2 a 4)');
        for (var g = 0; g < r.grupos.length; g++) {
          hijos.add(_fila(
            opcion: r.grupos[g],
            clave: 'editor-grupo-$n-$g',
            etiqueta: 'Grupo ${g + 1}',
            puedeQuitar: r.grupos.length > 2,
            onQuitar: () => onCambio(() {
              r.grupos.removeAt(g);
              for (final el in r.elementos) {
                if (el.grupo == g) {
                  el.grupo = -1;
                } else if (el.grupo > g) {
                  el.grupo--;
                }
              }
            }),
          ));
        }
        if (r.grupos.length < 4) {
          hijos.add(_anadir('editor-anadir-grupo-$n', 'Añadir grupo',
              () => onCambio(() => r.grupos.add(OpcionEditable()))));
        }
        ayuda('Cosas para clasificar (de 2 a 12) y su grupo');
        for (var i = 0; i < r.elementos.length; i++) {
          final el = r.elementos[i];
          hijos.add(KeyedSubtree(
            key: ValueKey(el.id),
            child: _fila(
              opcion: el.opcion,
              clave: 'editor-elemento-$n-$i',
              etiqueta: 'Cosa ${i + 1}',
              puedeQuitar: r.elementos.length > 2,
              onQuitar: () => onCambio(() => r.elementos.removeAt(i)),
              despues: [
                const SizedBox(width: 8),
                DropdownButton<int>(
                  key: Key('editor-elemento-grupo-$n-$i'),
                  hint: Text('¿Grupo?', style: TextStyle(color: marcarErrores && el.grupo < 0 ? rojo : null)),
                  value: el.grupo >= 0 && el.grupo < r.grupos.length ? el.grupo : null,
                  items: [
                    for (var g = 0; g < r.grupos.length; g++)
                      DropdownMenuItem(
                        value: g,
                        child: Text(r.grupos[g].texto.trim().isEmpty ? 'Grupo ${g + 1}' : r.grupos[g].texto.trim()),
                      ),
                  ],
                  onChanged: (g) => onCambio(() => el.grupo = g ?? -1),
                ),
              ],
            ),
          ));
        }
        if (r.elementos.length < 12) {
          hijos.add(_anadir('editor-anadir-elemento-$n', 'Añadir cosa',
              () => onCambio(() => r.elementos.add(ElementoEditable()))));
        }
      case TipoReto.ordenar:
        ayuda('Escribe los pasos en el orden correcto (de 3 a 8). La app los desordena.');
        for (var i = 0; i < r.pasos.length; i++) {
          hijos.add(_fila(
            opcion: r.pasos[i],
            clave: 'editor-paso-$n-$i',
            etiqueta: 'Paso ${i + 1}',
            puedeQuitar: r.pasos.length > 3,
            onQuitar: () => onCambio(() => r.pasos.removeAt(i)),
            antes: [
              IconButton(
                tooltip: 'Subir',
                onPressed: i == 0 ? null : () => onCambio(() => r.pasos.insert(i - 1, r.pasos.removeAt(i))),
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              ),
            ],
          ));
        }
        if (r.pasos.length < 8) {
          hijos.add(_anadir('editor-anadir-paso-$n', 'Añadir paso',
              () => onCambio(() => r.pasos.add(OpcionEditable()))));
        }
      case TipoReto.parejas:
        ayuda('Parejas (de 2 a 8): cada cosa con la suya. La app las desordena.');
        for (var i = 0; i < r.parejas.length; i++) {
          final par = r.parejas[i];
          hijos.add(KeyedSubtree(
            key: ValueKey(par.id),
            child: Row(
              children: [
                Expanded(
                  child: _fila(
                    opcion: par.a,
                    clave: 'editor-pareja-a-$n-$i',
                    etiqueta: 'Esto…',
                    puedeQuitar: false,
                    onQuitar: () {},
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 8), child: Icon(Icons.link_rounded)),
                Expanded(
                  child: _fila(
                    opcion: par.b,
                    clave: 'editor-pareja-b-$n-$i',
                    etiqueta: '…va con esto',
                    puedeQuitar: r.parejas.length > 2,
                    onQuitar: () => onCambio(() => r.parejas.removeAt(i)),
                  ),
                ),
              ],
            ),
          ));
        }
        if (r.parejas.length < 8) {
          hijos.add(_anadir('editor-anadir-pareja-$n', 'Añadir pareja',
              () => onCambio(() => r.parejas.add(ParejaEditable()))));
        }
      case TipoReto.huecos:
        hijos.add(const SizedBox(height: 8));
        hijos.add(_campo(
          clave: 'editor-frase-$n',
          valor: r.frase,
          etiqueta: 'Frase con huecos',
          lineas: null,
          ayuda: 'Pon entre corchetes las palabras que faltan. Ejemplo: El [corazón] bombea la [sangre].',
          error: marcarErrores && !r.frase.contains('[') ? 'Marca al menos un hueco con [ ]' : null,
          alCambiar: (v) => r.frase = v,
        ));
        hijos.add(const SizedBox(height: 10));
        hijos.add(_campo(
          clave: 'editor-distractores-$n',
          valor: r.distractores,
          etiqueta: 'Palabras de más para despistar (opcional)',
          ayuda: 'Separadas por comas. Ejemplo: pulmón, agua',
          alCambiar: (v) => r.distractores = v,
        ));
      case TipoReto.buscar:
        ayuda('Imagen donde buscar (obligatoria)');
        hijos.add(_EditorZonas(
          reto: r,
          numero: n,
          onCambio: onCambio,
          marcarErrores: marcarErrores,
          elegirImagen: elegirImagen,
        ));
      case TipoReto.numero:
        hijos.add(const SizedBox(height: 8));
        hijos.add(SizedBox(
          width: 260,
          child: _campo(
            clave: 'editor-numero-$n',
            valor: r.numero,
            etiqueta: 'Respuesta (un número)',
            teclado: TextInputType.number,
            error: marcarErrores && int.tryParse(r.numero.trim()) == null ? 'Escribe un número' : null,
            alCambiar: (v) => r.numero = v,
          ),
        ));
      case TipoReto.palabra:
        hijos.add(const SizedBox(height: 8));
        hijos.add(SizedBox(
          width: 320,
          child: _campo(
            clave: 'editor-palabra-$n',
            valor: r.palabra,
            etiqueta: 'Palabra que hay que formar',
            ayuda: 'De 2 a 12 letras. La app desordena las letras.',
            alCambiar: (v) => r.palabra = v,
          ),
        ));
      case TipoReto.lectura:
        hijos.add(const SizedBox(height: 8));
        hijos.add(_campo(
          clave: 'editor-texto-$n',
          valor: r.texto,
          etiqueta: 'Texto para leer',
          lineas: null,
          alCambiar: (v) => r.texto = v,
        ));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: hijos);
  }
}

/// Marcar en la imagen los sitios correctos: tocar añade, tocar encima quita.
class _EditorZonas extends StatelessWidget {
  const _EditorZonas({
    required this.reto,
    required this.numero,
    required this.onCambio,
    required this.marcarErrores,
    required this.elegirImagen,
  });

  final RetoEditable reto;
  final int numero;
  final void Function(VoidCallback) onCambio;
  final bool marcarErrores;
  final Future<ImagenAula?> Function() elegirImagen;

  @override
  Widget build(BuildContext context) {
    final imagen = reto.imagen;
    final rojo = Theme.of(context).colorScheme.error;
    if (imagen == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.tonalIcon(
          key: Key('editor-buscar-imagen-$numero'),
          onPressed: () async {
            final elegida = await elegirImagen();
            if (elegida != null) onCambio(() => reto.imagen = elegida);
          },
          icon: const Icon(Icons.add_photo_alternate_rounded),
          label: const Text('Elegir la imagen'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Toca en la imagen los sitios correctos (hasta 5). Toca un círculo para quitarlo.',
          style: TextStyle(color: marcarErrores && reto.zonas.isEmpty ? rojo : null),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: LayoutBuilder(
                builder: (context, medidas) {
                  final t = medidas.biggest;
                  return GestureDetector(
                    key: Key('editor-zonas-$numero'),
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (d) {
                      final x = d.localPosition.dx / t.width, y = d.localPosition.dy / t.height;
                      onCambio(() {
                        final i = reto.zonas.indexWhere((z) => ZonaAula(z.x, z.y, reto.radio).contiene(x, y));
                        if (i >= 0) {
                          reto.zonas.removeAt(i);
                        } else if (reto.zonas.length < 5) {
                          reto.zonas.add(ZonaAula(x, y, reto.radio));
                        }
                      });
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ImagenDeAula(imagen, ajuste: BoxFit.cover),
                        for (var i = 0; i < reto.zonas.length; i++)
                          Positioned(
                            left: (reto.zonas[i].x - reto.radio) * t.width,
                            top: reto.zonas[i].y * t.height - reto.radio * t.width,
                            child: IgnorePointer(
                              child: Container(
                                width: reto.radio * 2 * t.width,
                                height: reto.radio * 2 * t.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0x4440BE70),
                                  border: Border.all(color: const Color(0xFF2E9E57), width: 4),
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
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
        ),
        Row(
          children: [
            const Text('Tamaño del círculo'),
            Expanded(
              child: Slider(
                min: 0.04,
                max: 0.25,
                value: reto.radio.clamp(0.04, 0.25),
                onChanged: (v) => onCambio(() => reto.radio = v),
              ),
            ),
            TextButton(
              onPressed: () async {
                final elegida = await elegirImagen();
                if (elegida != null) onCambio(() => reto.imagen = elegida);
              },
              child: const Text('Cambiar imagen'),
            ),
          ],
        ),
      ],
    );
  }
}
