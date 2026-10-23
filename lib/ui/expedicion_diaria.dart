import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';

class InfoTrajeNatu {
  const InfoTrajeNatu({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.slotEtiqueta,
    required this.coste,
    this.logroRequerido,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String slotEtiqueta;
  final int coste;
  final String? logroRequerido;

  bool get esPorLogro => logroRequerido != null;
}

const catalogoTrajesNatu = <InfoTrajeNatu>[
  InfoTrajeNatu(
    id: 'ninguno',
    nombre: 'Natu al natural',
    descripcion: 'Quitar todos los accesorios equipados.',
    slotEtiqueta: 'Base',
    coste: 0,
  ),
  InfoTrajeNatu(
    id: 'explorador',
    nombre: 'Sombrero Explorador',
    descripcion: 'Salacot clásico con brújula para recorrer ecosistemas.',
    slotEtiqueta: 'Cabeza',
    coste: 25,
  ),
  InfoTrajeNatu(
    id: 'botanico',
    nombre: 'Corona Botánica',
    descripcion: 'Guirnalda de hojas y flores silvestres del invernadero.',
    slotEtiqueta: 'Cabeza',
    coste: 35,
  ),
  InfoTrajeNatu(
    id: 'doctor',
    nombre: 'Gafas y Estetoscopio',
    descripcion: 'Lentes de laboratorio y fonendoscopio médico.',
    slotEtiqueta: 'Ojos y cuello',
    coste: 45,
  ),
  InfoTrajeNatu(
    id: 'guardian',
    nombre: 'Insignia Guardián',
    descripcion: 'Medallón esmeralda y diadema dorada combinable.',
    slotEtiqueta: 'Emblema',
    coste: 55,
  ),
  InfoTrajeNatu(
    id: 'marino',
    nombre: 'Visor Submarino',
    descripcion: 'Máscara panorámica de buceo y tubo para el océano.',
    slotEtiqueta: 'Ojos',
    coste: 65,
  ),
  InfoTrajeNatu(
    id: 'brujula',
    nombre: 'Brújula de Expedición',
    descripcion: 'Reloj solar y brújula dorada con rosa de los vientos.',
    slotEtiqueta: 'Emblema',
    coste: 75,
  ),
  InfoTrajeNatu(
    id: 'aviador',
    nombre: 'Gafas de Vuelo',
    descripcion: 'Gafas aerodinámicas de cuero y ámbar para volar alto.',
    slotEtiqueta: 'Ojos',
    coste: 90,
  ),
  InfoTrajeNatu(
    id: 'nocturno',
    nombre: 'Linterna Nocturna',
    descripcion: 'Foco frontal para observar fauna de noche.',
    slotEtiqueta: 'Cabeza',
    coste: 105,
  ),
  InfoTrajeNatu(
    id: 'apicultor',
    nombre: 'Sombrero Apicultor',
    descripcion: 'Sombrero de paja con abejita polinizadora y miel.',
    slotEtiqueta: 'Cabeza',
    coste: 120,
  ),
  InfoTrajeNatu(
    id: 'herbarioro',
    nombre: 'Broche de Roble Dorado',
    descripcion: 'Insignia botánica con bellota de oro y hojas de encina.',
    slotEtiqueta: 'Emblema',
    coste: 135,
  ),
  InfoTrajeNatu(
    id: 'lupas',
    nombre: 'Monóculo Botánico',
    descripcion: 'Lente de aumento de latón con cadena para ver detalles.',
    slotEtiqueta: 'Ojos',
    coste: 150,
  ),
  InfoTrajeNatu(
    id: 'polar',
    nombre: 'Gorro Ártico',
    descripcion: 'Gorro acolchado polar con orejeras para climas helados.',
    slotEtiqueta: 'Cabeza',
    coste: 170,
  ),
  InfoTrajeNatu(
    id: 'racha_fuego',
    nombre: 'Emblema Llama Solar',
    descripcion: 'Medallón ígneo que premia la constancia y precisión.',
    slotEtiqueta: 'Logro · Emblema',
    coste: 0,
    logroRequerido: 'Consigue una racha de 3 días o un combo x8 sin fallos',
  ),
  InfoTrajeNatu(
    id: 'maestro_reserva',
    nombre: 'Guardabosques de Élite',
    descripcion: 'Sombrero de guardabosques con pluma real y escudo de fauna.',
    slotEtiqueta: 'Logro · Cabeza',
    coste: 0,
    logroRequerido: 'Completa todos los juegos y niveles de la Reserva',
  ),
  InfoTrajeNatu(
    id: 'maestro_invernadero',
    nombre: 'Tiara de Loto Botánico',
    descripcion: 'Corona dorada con flor de loto imperial y hojas esmeralda.',
    slotEtiqueta: 'Logro · Cabeza',
    coste: 0,
    logroRequerido: 'Completa todos los juegos y niveles del Invernadero',
  ),
  InfoTrajeNatu(
    id: 'maestro_cuerpo',
    nombre: 'Visor Biomédico',
    descripcion: 'Lentes científicas holográficas con pulso vital ECG.',
    slotEtiqueta: 'Logro · Ojos',
    coste: 0,
    logroRequerido: 'Completa todos los juegos y niveles de Nuestro Cuerpo',
  ),
  InfoTrajeNatu(
    id: 'leyenda_natu',
    nombre: 'Manto de Leyenda',
    descripcion: 'Capa real bordada en oro y gran medallón solar de la naturaleza.',
    slotEtiqueta: 'Logro · Emblema',
    coste: 0,
    logroRequerido: 'Completa el 100 % de los juegos y niveles de NaturalMente',
  ),
];

Future<void> mostrarArmarioNatu(
  BuildContext context, [
  Progreso? progreso,
]) {
  final alcance = Alcance.maybeOf(context);
  final prog = progreso ?? alcance!.progreso;
  if (alcance != null) {
    prog.sincronizarLogrosTrajes(alcance.catalogo.actividades);
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _HojaArmarioNatu(
      progreso: prog,
      catalogo: alcance?.catalogo,
    ),
  );
}

class _HojaArmarioNatu extends StatefulWidget {
  const _HojaArmarioNatu({required this.progreso, this.catalogo});

  final Progreso progreso;
  final Catalogo? catalogo;

  @override
  State<_HojaArmarioNatu> createState() => _HojaArmarioNatuState();
}

class _HojaArmarioNatuState extends State<_HojaArmarioNatu> {
  String _gestoVista = 'hola';

  static const List<(String id, String etiqueta)> _posesNatu = [
    ('hola', 'Saludo'),
    ('feliz', 'Celebración'),
    ('pensando', 'Lupa'),
    ('estudio', 'Lectura'),
    ('pista', '¡Tú puedes!'),
  ];

  Progreso get progreso => widget.progreso;
  Catalogo? get catalogo => widget.catalogo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: progreso,
      builder: (context, _) {
        final equipados = progreso.trajesEquipados;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFFDF6E2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: Color(0xFF3B2314), width: 3.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6C7A9),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFEFBF0), Color(0xFFF5EBD0)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF72B034),
                        width: 2.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            DibujoMascota(
                              gesto: _gestoVista,
                              tamano: 84,
                              traje: progreso.trajeEquipado,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          context.tr(
                                            'Armario Científico de Natu',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF3B2314),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFF59E0B),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const IconoSemilla(tamano: 16),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${progreso.semillas}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr(
                                      '¡Combina accesorios de distintas ranuras (Cabeza + Ojos + Emblema) y desbloquea reliquias por logros!',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF54331D),
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _ChipSlotResumen(
                                        etiqueta: context.tr('Activos:'),
                                        valor: equipados.isEmpty
                                            ? context.tr('Al natural')
                                            : '${equipados.length} ${context.tr('equipados')}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final (idPose, etiquetaPose) in _posesNatu)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(
                                      context.tr(etiquetaPose),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: _gestoVista == idPose
                                            ? Colors.white
                                            : const Color(0xFF3B2314),
                                      ),
                                    ),
                                    selected: _gestoVista == idPose,
                                    selectedColor: const Color(0xFF72B034),
                                    backgroundColor: const Color(0xFFFDF6E2),
                                    checkmarkColor: Colors.white,
                                    side: BorderSide(
                                      color: _gestoVista == idPose
                                          ? const Color(0xFF3B2314)
                                          : const Color(0xFFB8C99D),
                                      width: 1.6,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    onSelected: (_) =>
                                        setState(() => _gestoVista = idPose),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 195,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.74,
                          ),
                      itemCount: catalogoTrajesNatu.length,
                      itemBuilder: (context, index) {
                        final info = catalogoTrajesNatu[index];
                        final logroCumplido = info.esPorLogro &&
                            catalogo != null &&
                            progreso.logroTrajeCumplido(
                              info.id,
                              catalogo!.actividades,
                            );
                        final desbloqueado =
                            progreso.trajeDesbloqueado(info.id) ||
                            logroCumplido;
                        final equipado = progreso.trajeEstaEquipado(info.id);
                        final puedeComprar =
                            !info.esPorLogro && progreso.semillas >= info.coste;
                        return _TarjetaTrajeNatu(
                          key: Key('traje-natu-${info.id}'),
                          info: info,
                          desbloqueado: desbloqueado,
                          equipado: equipado,
                          puedeComprar: puedeComprar,
                          alPulsar: () async {
                            if (desbloqueado) {
                              if (!progreso.trajeDesbloqueado(info.id) &&
                                  catalogo != null) {
                                await progreso.sincronizarLogrosTrajes(
                                  catalogo!.actividades,
                                );
                              }
                              await progreso.alternarTraje(info.id);
                            } else if (puedeComprar) {
                              await progreso.desbloquearTraje(
                                info.id,
                                info.coste,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key('cerrar-armario-natu'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        context.tr('¡Listo para explorar!'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChipSlotResumen extends StatelessWidget {
  const _ChipSlotResumen({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF16A34A), width: 1.4),
      ),
      child: Text(
        '$etiqueta $valor',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF14532D),
        ),
      ),
    );
  }
}

class _TarjetaTrajeNatu extends StatelessWidget {
  const _TarjetaTrajeNatu({
    required this.info,
    required this.desbloqueado,
    required this.equipado,
    required this.puedeComprar,
    required this.alPulsar,
    super.key,
  });

  final InfoTrajeNatu info;
  final bool desbloqueado;
  final bool equipado;
  final bool puedeComprar;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final esLogro = info.esPorLogro;
    final colorBorde = equipado
        ? const Color(0xFF16A34A)
        : (desbloqueado
              ? (esLogro ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8))
              : const Color(0xFFE2E8F0));
    final colorFondo = equipado
        ? const Color(0xFFECFDF5)
        : (desbloqueado
              ? (esLogro ? const Color(0xFFFFFBEB) : Colors.white)
              : const Color(0xFFF8FAFC));

    return Material(
      color: colorFondo,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: (desbloqueado || puedeComprar) ? alPulsar : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorBorde, width: equipado ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: colorBorde.withValues(alpha: 0.25),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: esLogro
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.tr(info.slotEtiqueta),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: esLogro
                        ? const Color(0xFF92400E)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
              IconoAccesorioNatu(id: info.id, tamano: 52),
              Text(
                context.tr(info.nombre),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                context.tr(
                  !desbloqueado && esLogro
                      ? info.logroRequerido!
                      : info.descripcion,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  color: !desbloqueado && esLogro
                      ? const Color(0xFFB45309)
                      : const Color(0xFF64748B),
                  height: 1.15,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                decoration: BoxDecoration(
                  color: equipado
                      ? const Color(0xFF16A34A)
                      : (desbloqueado
                            ? const Color(0xFFE2E8F0)
                            : (esLogro
                                  ? const Color(0xFFFEF3C7)
                                  : (puedeComprar
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFF1F5F9)))),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!desbloqueado && !esLogro) ...[
                      const IconoSemilla(tamano: 13),
                      const SizedBox(width: 4),
                    ],
                    if (!desbloqueado && esLogro) ...[
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 13,
                        color: Color(0xFFB45309),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        equipado
                            ? context.tr('Puesto (toca para quitar)')
                            : (desbloqueado
                                  ? context.tr('Equipar')
                                  : (esLogro
                                        ? context.tr('Por logro')
                                        : '${info.coste}')),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: equipado
                              ? Colors.white
                              : (desbloqueado
                                    ? const Color(0xFF334155)
                                    : (esLogro
                                          ? const Color(0xFF92400E)
                                          : (puedeComprar
                                                ? const Color(0xFF92400E)
                                                : const Color(0xFF94A3B8)))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreguntaExpedicion {
  const PreguntaExpedicion({
    required this.id,
    required this.zonaNombre,
    required this.fichaIlustracion,
    required this.pregunta,
    required this.opciones,
    required this.indiceCorrecto,
    required this.explicacion,
  });

  final String id;
  final String zonaNombre;
  final String fichaIlustracion;
  final String pregunta;
  final List<String> opciones;
  final int indiceCorrecto;
  final String explicacion;
}

const _bancoFacil = <PreguntaExpedicion>[
  PreguntaExpedicion(
    id: 'f-camello',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'camello',
    pregunta: '¿Dónde vive el camello, donde apenas llueve y hace mucho calor?',
    opciones: ['En el desierto', 'En el hielo polar', 'En el fondo del mar'],
    indiceCorrecto: 0,
    explicacion:
        '¡Muy bien! El camello vive en el desierto y aguanta muchos días con poca agua.',
  ),
  PreguntaExpedicion(
    id: 'f-raiz',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'raiz',
    pregunta: '¿Qué parte de la planta está bajo tierra y bebe agua?',
    opciones: ['La raíz', 'La flor', 'El fruto'],
    indiceCorrecto: 0,
    explicacion:
        '¡Exacto! La raíz sujeta la planta al suelo y absorbe el agua con sales minerales.',
  ),
  PreguntaExpedicion(
    id: 'f-corazon',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'corazon',
    pregunta: '¿Qué órgano late sin parar en el pecho para impulsar la sangre?',
    opciones: ['El corazón', 'El estómago', 'El esqueleto'],
    indiceCorrecto: 0,
    explicacion:
        '¡Genial! El corazón funciona como una bomba que lleva la sangre a todo el cuerpo.',
  ),
  PreguntaExpedicion(
    id: 'f-sentidos',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'sentidos',
    pregunta: '¿Con qué órgano de los sentidos podemos ver los colores del semáforo?',
    opciones: ['Con los ojos (la vista)', 'Con las orejas (el oído)', 'Con la piel (el tacto)'],
    indiceCorrecto: 0,
    explicacion:
        '¡Estupendo! Los ojos son los órganos del sentido de la vista.',
  ),
  PreguntaExpedicion(
    id: 'f-huevo',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'huevo',
    pregunta: '¿Cómo nacen los pollitos, los patos y las tortugas?',
    opciones: ['Salen de un huevo (ovíparos)', 'Nacen de la barriga de su madre', 'Brotan de una semilla'],
    indiceCorrecto: 0,
    explicacion:
        '¡Eso es! Las aves y los reptiles son animales ovíparos porque nacen de un huevo.',
  ),
  PreguntaExpedicion(
    id: 'f-encina',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'encina',
    pregunta: 'La encina tiene un tronco grueso y duro de madera. ¿Qué tipo de planta es?',
    opciones: ['Un árbol', 'Una hierba blanda', 'Un alga marina'],
    indiceCorrecto: 0,
    explicacion:
        '¡Correcto! Los árboles tienen un tronco leñoso, grueso y alto del que salen las ramas.',
  ),
];

const _bancoMedio = <PreguntaExpedicion>[
  PreguntaExpedicion(
    id: 'm-rana',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'rana',
    pregunta:
        '¿Por qué la rana necesita vivir siempre cerca de una charca o zona húmeda?',
    opciones: [
      'Porque su piel fina y desnuda necesita mantenerse húmeda',
      'Porque tiene plumas impermeables de ave marina',
      'Porque solo se alimenta de cactus del desierto',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Exacto! Los anfibios tienen la piel desnuda y húmeda; si se seca, no pueden sobrevivir.',
  ),
  PreguntaExpedicion(
    id: 'm-flor',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'flor',
    pregunta:
        'Cuando la flor de un manzano se transforma tras la polinización, ¿qué se forma alrededor de las semillas?',
    opciones: [
      'El fruto, que protege las semillas en su interior',
      'Una raíz secundaria subterránea',
      'El tallo leñoso principal',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Genial! La flor se transforma en el fruto, que guarda y protege las semillas.',
  ),
  PreguntaExpedicion(
    id: 'm-pulmones',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'pulmones',
    pregunta:
        'Al inspirar aire por la nariz, ¿qué órganos esponjosos recogen el oxígeno para nuestro cuerpo?',
    opciones: ['Los pulmones', 'Los intestinos', 'Los huesos del cráneo'],
    indiceCorrecto: 0,
    explicacion:
        '¡Muy bien! Los pulmones toman el oxígeno del aire y expulsan el dióxido de carbono.',
  ),
  PreguntaExpedicion(
    id: 'm-renacuajo',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'renacuajo',
    pregunta:
        '¿Cómo respira el renacuajo mientras vive dentro del agua antes de convertirse en rana adulta?',
    opciones: [
      'Por branquias, igual que los peces',
      'Por estomas como las hojas de las plantas',
      'No necesita oxígeno en el agua',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Fantástico! Al nacer del huevo, el renacuajo vive en el agua y respira por branquias.',
  ),
  PreguntaExpedicion(
    id: 'm-aparato',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'aparato-digestivo',
    pregunta:
        'Después de masticar en la boca, ¿por qué tubo baja el bolo alimenticio hasta llegar al estómago?',
    opciones: ['Por el esófago', 'Por la tráquea hacia los pulmones', 'Por los nervios ópticos'],
    indiceCorrecto: 0,
    explicacion:
        '¡Así se hace! El esófago empuja el bolo alimenticio desde la boca hasta el estómago.',
  ),
  PreguntaExpedicion(
    id: 'm-romero',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'romero',
    pregunta:
        'El romero tiene tallos leñosos pero se ramifica desde el mismo suelo sin un tronco único. ¿Qué es?',
    opciones: ['Un arbusto', 'Un árbol gigante', 'Una hierba de tallo flexible'],
    indiceCorrecto: 0,
    explicacion:
        '¡Muy bien! Los arbustos tienen tallos leñosos que nacen directamente desde la base del suelo.',
  ),
];

const _bancoDificil = <PreguntaExpedicion>[
  PreguntaExpedicion(
    id: 'd-ecosistema',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'claro-bosque',
    pregunta:
        'En una cadena alimentaria del bosque, ¿qué papel cumplen las plantas verdes como la encina o el trébol?',
    opciones: [
      'Son los productores porque fabrican su propio alimento con la luz solar',
      'Son consumidores secundarios depredadores',
      'Solo intervienen cuando no hay luz del sol',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Brillante! Las plantas son los productores del ecosistema y la base de toda la cadena alimentaria.',
  ),
  PreguntaExpedicion(
    id: 'd-fotosintesis',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'fotosintesis',
    pregunta:
        'Durante la fotosíntesis, la hoja combina savia bruta, luz solar y dióxido de carbono. ¿Qué gas libera al aire?',
    opciones: [
      'Oxígeno, imprescindible para la respiración de los seres vivos',
      'Vapor de gasolina',
      'Sales minerales sólidas',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Excelente! Al fabricar savia elaborada en los cloroplastos, las hojas liberan oxígeno al aire.',
  ),
  PreguntaExpedicion(
    id: 'd-nutrientes',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'nutrientes',
    pregunta:
        '¿En qué parte del aparato digestivo pasan los nutrientes de los alimentos hacia la sangre?',
    opciones: [
      'En el intestino delgado, a través de sus paredes',
      'En los dientes incisivos al morder',
      'En el intestino grueso al expulsar las heces',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Impecable! En el intestino delgado los nutrientes atraviesan sus paredes y pasan a la sangre.',
  ),
  PreguntaExpedicion(
    id: 'd-reflejo',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'reflejo',
    pregunta:
        'En la función de relación, ¿quién lleva el mensaje desde los órganos de los sentidos hasta el cerebro?',
    opciones: [
      'Los nervios del sistema nervioso',
      'Los huesos del esqueleto',
      'Los jugos gástricos del estómago',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Perfecto! Los sentidos captan la información y los nervios la transmiten rápidamente al cerebro.',
  ),
  PreguntaExpedicion(
    id: 'd-celula',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'celula',
    pregunta:
        '¿Cuál es la unidad viva más pequeña que forma todos los tejidos y órganos de los seres vivos?',
    opciones: ['La célula', 'El órgano completo', 'El grano de arena'],
    indiceCorrecto: 0,
    explicacion:
        '¡Científico experto! Todos los seres vivos están formados por células vivas.',
  ),
  PreguntaExpedicion(
    id: 'd-mariposa',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'mariposa',
    pregunta:
        '¿Cómo se llama el proceso de transformación por el que una oruga pasa por crisálida hasta ser mariposa?',
    opciones: ['Metamorfosis', 'Fotosíntesis', 'Germinación'],
    indiceCorrecto: 0,
    explicacion:
        '¡Sobresaliente! Los insectos como la mariposa y los anfibios como la rana realizan la metamorfosis.',
  ),
];

class ExpedicionDiariaPage extends StatefulWidget {
  const ExpedicionDiariaPage({
    this.catalogo,
    this.progreso,
    this.fechaReferencia,
    super.key,
  });

  final Catalogo? catalogo;
  final Progreso? progreso;
  final DateTime? fechaReferencia;

  static List<PreguntaExpedicion> generarMisionDelDia([
    DateTime? fecha,
    String dificultad = 'facil',
  ]) {
    final banco = switch (dificultad) {
      'medio' => _bancoMedio,
      'dificil' => _bancoDificil,
      _ => _bancoFacil,
    };
    final ref = fecha ?? DateTime.now();
    final semillaDia = ref.year * 372 + ref.month * 31 + ref.day;
    final seleccion = <PreguntaExpedicion>[];
    for (var i = 0; i < 3; i++) {
      final idx = (semillaDia + i * 2) % banco.length;
      seleccion.add(banco[idx]);
    }
    return seleccion;
  }

  @override
  State<ExpedicionDiariaPage> createState() => _ExpedicionDiariaPageState();
}

class _ExpedicionDiariaPageState extends State<ExpedicionDiariaPage> {
  String _dificultad = 'facil';
  late List<PreguntaExpedicion> _mision;
  bool _enSelectorDificultad = true;
  bool _inicializado = false;
  int _pasoActual = 0;
  int? _opcionElegida;
  bool _pasoResuelto = false;
  bool _falloEnPasoActual = false;
  int _comboActual = 0;
  int _mejorComboSesion = 0;
  int _aciertosALaPrimera = 0;
  int _semillasSesion = 0;
  bool _completada = false;

  Progreso get _progreso => widget.progreso ?? Alcance.of(context).progreso;

  @override
  void initState() {
    super.initState();
    _mision = ExpedicionDiariaPage.generarMisionDelDia(
      widget.fechaReferencia,
      _dificultad,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      _comboActual = _progreso.comboActual;
      _mejorComboSesion = _comboActual;
      final hechaHoy = _progreso.expedicionHoyHecha(widget.fechaReferencia);
      if (hechaHoy) {
        // Si ya completó el reto diario hoy, bloqueamos volver a jugarlo hasta mañana
        // y mostramos directamente el resumen de desafío diario completado.
        _dificultad = _progreso.dificultadExpedicionHoy(widget.fechaReferencia);
        _mision = ExpedicionDiariaPage.generarMisionDelDia(
          widget.fechaReferencia,
          _dificultad,
        );
        _aciertosALaPrimera = _progreso.aciertosExpedicionHoy(
          widget.fechaReferencia,
        );
        _mejorComboSesion = _progreso.mejorComboExpedicionHoy(
          widget.fechaReferencia,
        );
        _semillasSesion = _progreso.semillasExpedicionHoy(
          widget.fechaReferencia,
        );
        _enSelectorDificultad = false;
        _completada = true;
      } else {
        _enSelectorDificultad = true;
        _completada = false;
      }
    }
  }

  void _iniciarConDificultad(String dificultadElegida) {
    if (_progreso.expedicionHoyHecha(widget.fechaReferencia)) return;
    setState(() {
      _dificultad = dificultadElegida;
      _mision = ExpedicionDiariaPage.generarMisionDelDia(
        widget.fechaReferencia,
        _dificultad,
      );
      _enSelectorDificultad = false;
      _pasoActual = 0;
      _opcionElegida = null;
      _pasoResuelto = false;
      _falloEnPasoActual = false;
      _comboActual = _progreso.comboActual;
      _mejorComboSesion = _comboActual;
      _aciertosALaPrimera = 0;
      _semillasSesion = 0;
      _completada = false;
    });
  }

  void _volverAlSelectorDificultad() {
    // Solo se puede cambiar de dificultad si aún NO se ha completado hoy
    if (_completada || _progreso.expedicionHoyHecha(widget.fechaReferencia)) {
      return;
    }
    setState(() {
      _enSelectorDificultad = true;
      _pasoActual = 0;
      _opcionElegida = null;
      _pasoResuelto = false;
      _falloEnPasoActual = false;
    });
  }

  int get _premioBaseDificultad => switch (_dificultad) {
    'dificil' => 12,
    'medio' => 10,
    _ => 8,
  };

  Future<void> _elegirOpcion(int indice) async {
    if (_pasoResuelto || _completada) return;
    final pregunta = _mision[_pasoActual];
    if (indice == pregunta.indiceCorrecto) {
      final aLaPrimera = !_falloEnPasoActual;
      final nuevoCombo = aLaPrimera ? _progreso.comboActual + 1 : 1;
      int ganadas = 0;
      if (!_progreso.expedicionHoyHecha(widget.fechaReferencia)) {
        ganadas = await _progreso.registrarAciertoPrecision(
          aLaPrimera: aLaPrimera,
          comboActual: nuevoCombo,
        );
      }
      if (!mounted) return;
      setState(() {
        _opcionElegida = indice;
        _pasoResuelto = true;
        _comboActual = _progreso.comboActual;
        if (_comboActual > _mejorComboSesion) {
          _mejorComboSesion = _comboActual;
        }
        if (aLaPrimera) {
          _aciertosALaPrimera++;
        }
        _semillasSesion += ganadas;
      });
      if (_pasoActual + 1 >= _mision.length) {
        context.sonidoCelebracion();
      } else {
        context.sonidoAcierto();
      }
      await _siguientePaso();
    } else {
      await _progreso.romperComboPrecision();
      if (!mounted) return;
      context.sonidoPista();
      setState(() {
        _opcionElegida = indice;
        _falloEnPasoActual = true;
        _comboActual = 0;
      });
    }
  }

  Future<void> _siguientePaso() async {
    if (_pasoActual + 1 < _mision.length) {
      setState(() {
        _pasoActual++;
        _opcionElegida = null;
        _pasoResuelto = false;
        _falloEnPasoActual = false;
      });
    } else {
      final antes = _progreso.semillas;
      final bonoBase = _progreso.expedicionHoyHecha(widget.fechaReferencia)
          ? 0
          : _premioBaseDificultad;
      await _progreso.completarExpedicionDiaria(
        fecha: widget.fechaReferencia,
        semillasRecompensa: bonoBase,
        dificultad: _dificultad,
        aciertosALaPrimera: _aciertosALaPrimera,
        mejorComboSesion: _mejorComboSesion,
        semillasTotalesSesion: _semillasSesion,
      );
      final bonoFinal = _progreso.semillas - antes;
      if (!mounted) return;
      setState(() {
        _semillasSesion += bonoFinal;
        _completada = true;
        _enSelectorDificultad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3D6),
        foregroundColor: const Color(0xFF7C2D12),
        elevation: 0,
        title: Row(
          children: [
            const IconoLlamaRacha(tamano: 22, activa: true, intensa: true),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.tr('Reto diario'),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        actions: [
          if (!_enSelectorDificultad && !_completada)
            TextButton.icon(
              key: const Key('cambiar-dificultad-reto'),
              onPressed: _volverAlSelectorDificultad,
              icon: const Icon(
                Icons.tune_rounded,
                size: 16,
                color: Color(0xFF9A3412),
              ),
              label: Text(
                context.tr('Nivel'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF9A3412),
                ),
              ),
            ),
          InsigniaPrecisionAppBar(
            comboActual: _comboActual,
            semillasSesion: _semillasSesion,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _completada
                ? _construirPantallaFinal(context)
                : (_enSelectorDificultad
                      ? _construirPantallaSeleccionDificultad(context)
                      : _construirReto(context)),
          ),
        ),
      ),
    );
  }

  Widget _construirPantallaSeleccionDificultad(BuildContext context) {
    final rachaDias = _progreso.rachaActiva(widget.fechaReferencia);
    const opciones = [
      (
        'facil',
        'Fácil · 1.º y 2.º Primaria',
        'Preguntas directas de observación sobre animales, plantas y sentidos.',
        8,
        Color(0xFF16A34A),
        Color(0xFFECFDF5),
      ),
      (
        'medio',
        'Medio · 3.º y 4.º Primaria',
        'Adaptaciones al hábitat, ciclos de las plantas y aparatos del cuerpo.',
        10,
        Color(0xFFD97706),
        Color(0xFFFFFBEB),
      ),
      (
        'dificil',
        'Difícil · 5.º y 6.º Primaria',
        'Cadenas tróficas, fotosíntesis, células y función de relación.',
        12,
        Color(0xFFDC2626),
        Color(0xFFFEF2F2),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CelebracionRachaDiariaDuolingo(
            rachaDias: rachaDias,
            completadoHoy: false,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const DibujoMascota(gesto: 'hola', tamano: 60),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('Elige la dificultad del reto de hoy'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr(
                              'El reto diario se juega una vez al día. Si te equivocas de nivel antes de terminarlo, podrás volver atrás para cambiarlo.',
                            ),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final (id, titulo, desc, premio, color, fondo)
                    in opciones) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: fondo,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        key: Key('dificultad-reto-$id'),
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _iniciarConDificultad(id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: color, width: 2.4),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr(titulo),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      context.tr(desc),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: color, width: 1.8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const IconoSemilla(tamano: 15),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+$premio',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: color,
                                      ),
                                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirReto(BuildContext context) {
    final pregunta = _mision[_pasoActual];
    final progresoFraccion =
        (_pasoActual + (_pasoResuelto ? 1 : 0)) / _mision.length;
    final etiquetaDif = switch (_dificultad) {
      'dificil' => 'Difícil · 5.º-6.º',
      'medio' => 'Medio · 3.º-4.º',
      _ => 'Fácil · 1.º-2.º',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFED7AA), width: 2.2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      key: const Key('progreso-expedicion-diaria'),
                      '${context.tr('Reto')} ${_pasoActual + 1} / ${_mision.length}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _volverAlSelectorDificultad,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFFB923C)),
                        ),
                        child: Text(
                          '${context.tr(etiquetaDif)} ↺',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF9A3412),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFF6EE7B7),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          context.tr(pregunta.zonaNombre),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progresoFraccion),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, valor, _) => LinearProgressIndicator(
                      value: valor,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2DEC9), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFD0C9B8),
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    DibujoMascota(
                      gesto: _pasoResuelto
                          ? (_comboActual >= 2 ? 'racha' : 'feliz')
                          : (_falloEnPasoActual ? 'pista' : 'hola'),
                      tamano: 60,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr(pregunta.pregunta),
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                  ),
                  child: IlustracionFicha(
                    id: pregunta.fichaIlustracion,
                    alto: 84,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < pregunta.opciones.length; i++) ...[
            _BotonOpcionExpedicion(
              key: Key('opcion-expedicion-$i'),
              texto: context.tr(pregunta.opciones[i]),
              seleccionada: _opcionElegida == i,
              esCorrecta: i == pregunta.indiceCorrecto,
              mostrarResultado:
                  _pasoResuelto || (_opcionElegida == i && _falloEnPasoActual),
              alPulsar: () => _elegirOpcion(i),
            ),
            const SizedBox(height: 10),
          ],
          if (_falloEnPasoActual && !_pasoResuelto)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 2),
              ),
              child: Text(
                context.tr(
                  '¡Casi! Fíjate bien en la ilustración y prueba con otra opción.',
                ),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
          if (_pasoResuelto) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF10B981), width: 2.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr(pregunta.explicacion),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construirPantallaFinal(BuildContext context) {
    final rachaDias = _progreso.rachaActiva(widget.fechaReferencia);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Container(
        key: const Key('expedicion-completada'),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF59E0B), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33F59E0B),
              offset: Offset(0, 6),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CelebracionRachaDiariaDuolingo(
              rachaDias: rachaDias,
              completadoHoy: true,
            ),
            const SizedBox(height: 14),
            const DibujoMascota(gesto: 'racha', tamano: 84),
            const SizedBox(height: 10),
            Text(
              context.tr('¡Desafío diario completado!'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr(
                'Ya has superado la expedición de hoy. ¡Vuelve mañana para desbloquear un nuevo reto diario y seguir aumentando tu racha!',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            ResumenPrecisionFinal(
              aciertosALaPrimera: _aciertosALaPrimera,
              totalPasos: _mision.length,
              mejorComboSesion: _mejorComboSesion,
              semillasGanadas: _semillasSesion,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B5E20),
                      side: const BorderSide(
                        color: Color(0xFF1B5E20),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => mostrarArmarioNatu(context, _progreso),
                    icon: const Icon(Icons.checkroom_rounded),
                    label: Text(
                      context.tr('Armario de Natu'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.map_rounded),
                    label: Text(
                      context.tr('Volver al mapa'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonOpcionExpedicion extends StatelessWidget {
  const _BotonOpcionExpedicion({
    required this.texto,
    required this.seleccionada,
    required this.esCorrecta,
    required this.mostrarResultado,
    required this.alPulsar,
    super.key,
  });

  final String texto;
  final bool seleccionada;
  final bool esCorrecta;
  final bool mostrarResultado;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    Color fondo = Colors.white;
    Color borde = const Color(0xFFCBD5E1);
    Color textoColor = const Color(0xFF1E293B);
    IconData icono = Icons.circle_outlined;

    if (mostrarResultado) {
      if (esCorrecta) {
        fondo = const Color(0xFFECFDF5);
        borde = const Color(0xFF10B981);
        textoColor = const Color(0xFF065F46);
        icono = Icons.check_circle_rounded;
      } else if (seleccionada) {
        fondo = const Color(0xFFFFFBEB);
        borde = const Color(0xFFF59E0B);
        textoColor = const Color(0xFF92400E);
        icono = Icons.lightbulb_outline_rounded;
      }
    }

    return Material(
      color: fondo,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: alPulsar,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borde, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: borde.withValues(alpha: 0.25),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icono, color: textoColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textoColor,
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
