import 'package:flutter/material.dart';
import 'package:naturalmente/datos/alcance.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos.dart';
import 'package:naturalmente/ui/feedback_acierto.dart';
import 'package:naturalmente/ui/fin_juego.dart';

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
        final poseActual = progreso.poseEquipada;
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
                              gesto: poseActual,
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
                                        color: poseActual == idPose
                                            ? Colors.white
                                            : const Color(0xFF3B2314),
                                      ),
                                    ),
                                    selected: poseActual == idPose,
                                    selectedColor: const Color(0xFF72B034),
                                    backgroundColor: const Color(0xFFFDF6E2),
                                    checkmarkColor: Colors.white,
                                    side: BorderSide(
                                      color: poseActual == idPose
                                          ? const Color(0xFF3B2314)
                                          : const Color(0xFFB8C99D),
                                      width: 1.6,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    onSelected: (_) {
                                      progreso.equiparPose(idPose);
                                    },
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
    opciones: ['La flor', 'La raíz', 'El fruto'],
    indiceCorrecto: 1,
    explicacion:
        '¡Exacto! La raíz sujeta la planta al suelo y absorbe el agua con sales minerales.',
  ),
  PreguntaExpedicion(
    id: 'f-corazon',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'corazon',
    pregunta: '¿Qué órgano late sin parar en el pecho para impulsar la sangre?',
    opciones: ['El estómago', 'El esqueleto', 'El corazón'],
    indiceCorrecto: 2,
    explicacion:
        '¡Genial! El corazón funciona como una bomba que lleva la sangre a todo el cuerpo.',
  ),
  PreguntaExpedicion(
    id: 'f-huevo',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'huevo',
    pregunta: '¿Cómo nacen los pollitos, los patos y las tortugas?',
    opciones: [
      'Salen de un huevo (ovíparos)',
      'Nacen de la barriga de su madre',
      'Brotan de una semilla',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Eso es! Las aves y los reptiles son animales ovíparos porque nacen de un huevo.',
  ),
  PreguntaExpedicion(
    id: 'f-encina',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'encina',
    pregunta:
        'La encina tiene un tronco grueso y duro de madera. ¿Qué tipo de planta es?',
    opciones: ['Una hierba blanda', 'Un árbol', 'Un alga marina'],
    indiceCorrecto: 1,
    explicacion:
        '¡Correcto! Los árboles tienen un tronco leñoso, grueso y alto del que salen las ramas.',
  ),
  PreguntaExpedicion(
    id: 'f-sentidos',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'sentidos',
    pregunta:
        '¿Con qué órgano de los sentidos podemos ver los colores del semáforo?',
    opciones: [
      'Con las orejas (el oído)',
      'Con la piel (el tacto)',
      'Con los ojos (la vista)',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Estupendo! Los ojos son los órganos del sentido de la vista.',
  ),
  PreguntaExpedicion(
    id: 'f-delfin',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'delfin',
    pregunta:
        'El delfín nada en el mar, pero sale a respirar aire y mama leche al nacer. ¿Qué es?',
    opciones: ['Un mamífero marino', 'Un insecto con alas', 'Un árbol acuático'],
    indiceCorrecto: 0,
    explicacion:
        '¡Muy bien! Aunque vive en el mar, el delfín es un mamífero vivíparo que respira con pulmones.',
  ),
  PreguntaExpedicion(
    id: 'f-semilla',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'semilla',
    pregunta:
        '¿Qué necesita una semilla en la maceta para germinar y empezar a crecer?',
    opciones: [
      'Estar guardada en hielo seco',
      'Agua, aire y una temperatura adecuada',
      'Pintura de colores y ruido fuerte',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Exacto! Con agua y buen temple la semilla despierta y saca su primera raíz.',
  ),
  PreguntaExpedicion(
    id: 'f-dientes',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'dientes',
    pregunta:
        '¿Dónde empieza el viaje de la comida cuando mordemos y masticamos una manzana?',
    opciones: [
      'En los tobillos',
      'En los pulmones',
      'En la boca, con los dientes y la saliva',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Genial! En la boca los dientes trituran el alimento y la lengua lo mezcla con la saliva.',
  ),
  PreguntaExpedicion(
    id: 'f-herbivoro',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'herbivoro',
    pregunta:
        'La vaca, la oveja y el conejo se alimentan de hierba, hojas y plantas. ¿Cómo se llaman?',
    opciones: ['Herbívoros', 'Carnívoros', 'Minerales'],
    indiceCorrecto: 0,
    explicacion:
        '¡Bravo! Los animales que comen únicamente plantas, hojas o frutos son herbívoros.',
  ),
  PreguntaExpedicion(
    id: 'f-hoja-caduca',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'hoja-caduca',
    pregunta:
        '¿Cómo llamamos a los árboles como el haya o el chopo que tiran todas sus hojas en otoño?',
    opciones: [
      'Árboles de plástico',
      'Árboles de hoja caduca',
      'Plantas sin raíces',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Eso es! Los árboles de hoja caduca pierden sus hojas en otoño y brotan de nuevo en primavera.',
  ),
  PreguntaExpedicion(
    id: 'f-higiene',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'higiene',
    pregunta:
        '¿Qué hábito saludable debemos hacer después de comer para cuidar nuestros dientes?',
    opciones: [
      'Comer caramelos pegajosos sin parar',
      'No beber nunca agua',
      'Cepillarnos bien los dientes con el cepillo',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Muy bien! Cepillarse los dientes después de las comidas evita las caries y cuida la boca.',
  ),
  PreguntaExpedicion(
    id: 'f-vertebrado',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'vertebrado',
    pregunta:
        'El caballo y el gorrión tienen huesos y columna vertebral por dentro. ¿Qué son?',
    opciones: [
      'Animales vertebrados',
      'Animales invertebrados sin huesos',
      'Rocas del río',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Perfecto! Los animales con esqueleto interno y columna vertebral son vertebrados.',
  ),
  PreguntaExpedicion(
    id: 'f-abeja-polen',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'abeja-polen',
    pregunta:
        'Cuando una abeja viaja de flor en flor buscando néctar, ¿qué polvillo amarillo transporta en sus patas?',
    opciones: ['Arena de la playa', 'El polen de las flores', 'Copos de nieve'],
    indiceCorrecto: 1,
    explicacion:
        '¡Fantástico! Las abejas llevan el polen de una flor a otra y ayudan a que nazcan frutos y semillas.',
  ),
  PreguntaExpedicion(
    id: 'f-cerebro',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'cerebro',
    pregunta:
        '¿Qué órgano protegido dentro de la cabeza piensa, aprende y dirige nuestros movimientos?',
    opciones: ['El estómago', 'La rodilla', 'El cerebro'],
    indiceCorrecto: 2,
    explicacion:
        '¡Así es! El cerebro está protegido por el cráneo y dirige lo que pensamos, sentimos y hacemos.',
  ),
  PreguntaExpedicion(
    id: 'f-pinguino',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'pinguino',
    pregunta:
        'El pingüino tiene plumas y pico, pone huevos y usa sus alas como aletas para nadar. ¿Qué es?',
    opciones: ['Un ave marina que no vuela', 'Un pez con escamas', 'Un anfibio de charca'],
    indiceCorrecto: 0,
    explicacion:
        '¡Excelente! Aunque no vuela por el aire, el pingüino es un ave adaptada a nadar en aguas muy frías.',
  ),
  PreguntaExpedicion(
    id: 'f-huerta-organos',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'huerta-organos',
    pregunta:
        'Cuando comemos una zanahoria fresca de la huerta, ¿qué parte de la planta nos estamos comiendo?',
    opciones: [
      'Una flor con pétalos azules',
      'Una raíz que crece bajo tierra',
      'La corteza de un tronco gigante',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Muy bien! La zanahoria es una raíz gruesa donde la planta guarda alimento bajo el suelo.',
  ),
  PreguntaExpedicion(
    id: 'f-una-vida',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'una-vida',
    pregunta:
        'Las personas, los animales y las plantas nacen, crecen, se alimentan y se relacionan. ¿Qué son?',
    opciones: [
      'Objetos inertes sin vida',
      'Juguetes de cuerda',
      'Seres vivos',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Exacto! Todos los seres vivos realizan las funciones vitales de nutrición, relación y reproducción.',
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
      'Una raíz secundaria subterránea',
      'El fruto, que protege las semillas en su interior',
      'El tallo leñoso principal',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Genial! La flor se transforma en el fruto, que guarda y protege las semillas.',
  ),
  PreguntaExpedicion(
    id: 'm-pulmones',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'pulmones',
    pregunta:
        'Al inspirar aire por la nariz, ¿qué órganos esponjosos recogen el oxígeno para nuestro cuerpo?',
    opciones: ['Los intestinos', 'Los huesos del cráneo', 'Los pulmones'],
    indiceCorrecto: 2,
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
    id: 'm-romero',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'romero',
    pregunta:
        'El romero tiene tallos leñosos pero se ramifica desde el mismo suelo sin un tronco único. ¿Qué es?',
    opciones: [
      'Un árbol gigante',
      'Un arbusto',
      'Una hierba de tallo flexible',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Muy bien! Los arbustos tienen tallos leñosos que nacen directamente desde la base del suelo.',
  ),
  PreguntaExpedicion(
    id: 'm-aparato',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'aparato-digestivo',
    pregunta:
        'Después de masticar en la boca, ¿por qué tubo baja el bolo alimenticio hasta llegar al estómago?',
    opciones: [
      'Por la tráquea hacia los pulmones',
      'Por los nervios ópticos',
      'Por el esófago',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Así se hace! El esófago empuja el bolo alimenticio desde la boca hasta el estómago.',
  ),
  PreguntaExpedicion(
    id: 'm-pico-garra',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'pico-garra',
    pregunta:
        'El águila tiene un pico curvo y ganchudo y fuertes garras afiladas. ¿Qué tipo de alimentación tiene?',
    opciones: [
      'Es un ave rapaz carnívora que caza sus presas',
      'Solo filtra barro del fondo con pico plano',
      'Se alimenta únicamente de polen líquido',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Exacto! Las aves rapaces usan sus garras para sujetar la presa y su pico ganchudo para desgarrar.',
  ),
  PreguntaExpedicion(
    id: 'm-semilla-viajera',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'semilla-viajera',
    pregunta:
        '¿Por qué las semillas del diente de león tienen un penacho blanco parecido a un paracaídas?',
    opciones: [
      'Para hundirse en las rocas del río',
      'Para flotar en el viento y viajar lejos de la planta madre',
      'Para dar calor al tronco en invierno',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Bravo! Su vilano ligero permite que la brisa disperse las semillas hacia nuevos suelos.',
  ),
  PreguntaExpedicion(
    id: 'm-esqueleto',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'esqueleto',
    pregunta:
        '¿Qué dos partes trabajan juntas en el aparato locomotor para sostenernos y producir el movimiento?',
    opciones: [
      'Los dientes y la saliva',
      'Las pestañas y el oído interno',
      'Los huesos del esqueleto y los músculos',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Genial! Los músculos tiran de los huesos en las articulaciones para que podamos movernos.',
  ),
  PreguntaExpedicion(
    id: 'm-anfibio',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'anfibio',
    pregunta:
        '¿Qué dos grupos de vertebrados tienen el cuerpo cubierto de pelo o de plumas para mantener su calor?',
    opciones: [
      'Los mamíferos (pelo) y las aves (plumas)',
      'Los peces y las medusas',
      'Los reptiles y las lombrices',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Muy bien! Los mamíferos tienen pelo y las aves plumas, lo que les ayuda a conservar su temperatura.',
  ),
  PreguntaExpedicion(
    id: 'm-formas-hoja',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'formas-hoja',
    pregunta:
        '¿Cómo se llama el borde de una hoja cuando tiene pequeños picos parecidos a los dientes de una sierra?',
    opciones: ['Borde lobulado redondo', 'Borde aserrado', 'Raíz principal'],
    indiceCorrecto: 1,
    explicacion:
        '¡Correcto! Los botánicos observan el limbo y el borde (liso, aserrado o lobulado) para identificar cada árbol.',
  ),
  PreguntaExpedicion(
    id: 'm-estomago',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'estomago',
    pregunta:
        'Cuando el bolo alimenticio se mezcla y se bate con los jugos gástricos en el estómago, ¿en qué se transforma?',
    opciones: [
      'En aire puro de los pulmones',
      'En saliva fresca de la boca',
      'En una papilla llamada quimo',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Estupendo! En el estómago los jugos gástricos transforman el bolo alimenticio en quimo.',
  ),
  PreguntaExpedicion(
    id: 'm-tucan',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'tucan',
    pregunta:
        '¿En qué ecosistema cálido, lluvioso y lleno de árboles altos vive el tucán alcanzando frutos de las ramas?',
    opciones: [
      'En la selva tropical',
      'En el desierto de dunas secas',
      'En el hielo de los polos',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Así es! En la selva tropical llueve mucho todo el año y abundan los árboles con frutos.',
  ),
  PreguntaExpedicion(
    id: 'm-partes-comestibles',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'partes-comestibles',
    pregunta:
        'El tomate y la calabaza se forman a partir de la flor y guardan semillas dentro. ¿Qué órgano vegetal son?',
    opciones: [
      'Raíces subterráneas sin semillas',
      'Frutos de la planta',
      'Hojas aciculares de pino',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Exacto! En botánica, cualquier parte que procede de la flor y encierra las semillas es un fruto.',
  ),
  PreguntaExpedicion(
    id: 'm-avisos',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'avisos',
    pregunta:
        '¿Qué órgano del sentido del oído vibra cuando llegan las ondas sonoras y envía el aviso hacia el cerebro?',
    opciones: [
      'La pupila del ojo',
      'Las papilas gustativas de la lengua',
      'El tímpano y el caracol en el oído',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Muy bien! El sonido entra por la oreja, hace vibrar el tímpano y el oído interno avisa al cerebro.',
  ),
  PreguntaExpedicion(
    id: 'm-oso',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'oso',
    pregunta:
        'El oso pardo come frutos del bosque, raíces, miel y también peces del río. ¿Qué tipo de dieta tiene?',
    opciones: [
      'Es omnívoro porque come alimentos de origen vegetal y animal',
      'Es exclusivamente herbívoro de hierba seca',
      'Fabrica su alimento con luz solar como las plantas',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Perfecto! Los animales omnívoros aprovechan tanto plantas y frutos como otros animales.',
  ),
  PreguntaExpedicion(
    id: 'm-huerto',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'huerto',
    pregunta:
        '¿Por dónde sube el agua con sales minerales desde la raíz hasta las hojas de una planta?',
    opciones: [
      'Por los pétalos caídos en el suelo',
      'Por los vasos conductores dentro del tallo',
      'Saltando por fuera de las ramas',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Genial! El tallo sostiene la planta y reparte el agua y el alimento por sus conductos internos.',
  ),
  PreguntaExpedicion(
    id: 'm-descanso',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'descanso',
    pregunta:
        '¿Por qué es fundamental dormir suficientes horas cada noche durante la infancia?',
    opciones: [
      'Para que los huesos se vuelvan blandos como gelatina',
      'Para no tener que respirar oxígeno',
      'Porque mientras dormimos el cuerpo descansa, crece y el cerebro afianza lo aprendido',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Exacto! El descanso nocturno repara la energía, ayuda al crecimiento y cuida el sistema nervioso.',
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
      'Vapor de gasolina',
      'Oxígeno, imprescindible para la respiración de los seres vivos',
      'Sales minerales sólidas',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Excelente! Al fabricar savia elaborada en los cloroplastos, las hojas liberan oxígeno al aire.',
  ),
  PreguntaExpedicion(
    id: 'd-nutrientes',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'nutrientes',
    pregunta:
        '¿En qué parte del aparato digestivo se forma el quilo y pasan los nutrientes hacia la sangre?',
    opciones: [
      'En los dientes incisivos al morder',
      'En el intestino grueso al expulsar las heces',
      'En el intestino delgado, a través de sus vellosidades',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Impecable! En el intestino delgado el quimo pasa a ser quilo y los nutrientes pasan a la sangre.',
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
  PreguntaExpedicion(
    id: 'd-helecho-espora',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'helecho-espora',
    pregunta:
        'Los helechos y los musgos son plantas que nunca tienen flores ni semillas. ¿Cómo se reproducen?',
    opciones: [
      'Dando frutos carnosos como el melocotón',
      'Mediante esporas diminutas que en los helechos se forman en los soros',
      'Mediante piñas leñosas como los pinos',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Magnífico! Los musgos y los helechos se reproducen por esporas en lugares húmedos y sombríos.',
  ),
  PreguntaExpedicion(
    id: 'd-reflejo',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'reflejo',
    pregunta:
        'En la función de relación, ¿quién lleva los impulsos desde los órganos de los sentidos hasta el cerebro y los músculos?',
    opciones: [
      'Los huesos del esqueleto',
      'Los jugos gástricos del estómago',
      'Los nervios del sistema nervioso',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Perfecto! Los sentidos captan la información y los nervios transmiten las señales al cerebro y al aparato locomotor.',
  ),
  PreguntaExpedicion(
    id: 'd-artropodo',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'artropodo',
    pregunta:
        '¿Cómo diferenciamos científicamente a un insecto como la abeja de un arácnido como la araña dentro de los artrópodos?',
    opciones: [
      'Los insectos tienen 6 patas y 2 antenas; los arácnidos tienen 8 patas y carecen de antenas',
      'Los insectos tienen columna vertebral ósea y las arañas tienen concha de caracol',
      'Los arácnidos respiran por branquias de pez y tienen plumas',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Exacto! Ambos son artrópodos con patas articuladas, pero los insectos tienen 6 patas y los arácnidos 8.',
  ),
  PreguntaExpedicion(
    id: 'd-bosque-clima',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'bosque-clima',
    pregunta:
        '¿Por qué la encina del bosque mediterráneo tiene hojas pequeñas, duras y coriáceas durante todo el año?',
    opciones: [
      'Para absorber sal marina bajo el océano',
      'Para resistir los veranos largos, secos y calurosos perdiendo muy poca agua',
      'Porque pierde todas sus hojas al llegar octubre',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Sobresaliente! Sus hojas perennes y duras evitan que el árbol se seque durante la sequía estival.',
  ),
  PreguntaExpedicion(
    id: 'd-celula',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'celula',
    pregunta:
        '¿Cómo se agrupan las células del mismo tipo cuando trabajan juntas en nuestro cuerpo (como en un músculo)?',
    opciones: [
      'En rocas minerales inertes',
      'En semillas con cáscara',
      'Forman tejidos, que a su vez se unen formando órganos, aparatos y sistemas',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Científico experto! Células → tejidos → órganos → aparatos y sistemas → organismo completo.',
  ),
  PreguntaExpedicion(
    id: 'd-branquias',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'branquias',
    pregunta:
        '¿Cómo obtienen los peces como el atún o la trucha el oxígeno que necesitan sin salir del agua?',
    opciones: [
      'El agua entra por la boca y pasa por las branquias, que filtran el oxígeno disuelto',
      'Tienen pulmones de ave escondidos en la aleta caudal',
      'No necesitan oxígeno para vivir',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Muy bien! Las branquias son láminas muy finas llenas de capilares que captan el oxígeno disuelto en el agua.',
  ),
  PreguntaExpedicion(
    id: 'd-trigo',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'trigo',
    pregunta:
        '¿Cómo se llaman los poros microscópicos de las hojas por donde la planta intercambia gases con el aire?',
    opciones: ['Alvéolos pulmonares', 'Estomas', 'Tubérculos subterráneos'],
    indiceCorrecto: 1,
    explicacion:
        '¡Brillante! A través de los estomas de las hojas entran y salen el dióxido de carbono, el oxígeno y el vapor de agua.',
  ),
  PreguntaExpedicion(
    id: 'd-intestinos',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'intestinos',
    pregunta:
        '¿Qué ocurre en el intestino grueso con los restos de alimentos que el cuerpo no puede aprovechar?',
    opciones: [
      'Se convierten de nuevo en bolo alimenticio y suben al esófago',
      'Pasan directamente a los pulmones para convertirse en aire',
      'Se absorbe el agua sobrante y se compactan formando las heces para su expulsión',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Excelente! El intestino grueso recupera el agua y transforma los desechos no digeridos en heces.',
  ),
  PreguntaExpedicion(
    id: 'd-pulpo',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'pulpo',
    pregunta:
        'El pulpo, el calamar, la almeja y el caracol tienen el cuerpo blando y musculoso. ¿A qué grupo de invertebrados pertenecen?',
    opciones: ['A los moluscos', 'A los vertebrados anfibios', 'A los insectos con seis patas'],
    indiceCorrecto: 0,
    explicacion:
        '¡Genial! Todos ellos son moluscos, aunque unos tengan concha externa y otros como el pulpo no.',
  ),
  PreguntaExpedicion(
    id: 'd-recursos-plantas',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'recursos-plantas',
    pregunta:
        'La patata crece bajo tierra, tiene yemas y almacena reservas, pero no es una raíz. ¿Qué órgano vegetal es?',
    opciones: [
      'Un fruto carnoso de árbol',
      'Un tallo subterráneo engrosado llamado tubérculo',
      'Una hoja flotante de charca',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Exacto! La patata es un tubérculo: un tallo subterráneo donde la planta acumula almidón de reserva.',
  ),
  PreguntaExpedicion(
    id: 'd-cuidar-sentidos',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'cuidar-sentidos',
    pregunta:
        '¿Por qué no debemos escuchar música con auriculares a un volumen muy alto durante mucho tiempo?',
    opciones: [
      'Porque gasta el esmalte de los dientes incisivos',
      'Porque impide que el estómago produzca jugos gástricos',
      'Porque las vibraciones intensas pueden dañar el tímpano y las células del oído interno',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Muy bien! Cuidar la salud auditiva moderando el volumen protege el tímpano y el oído interno.',
  ),
  PreguntaExpedicion(
    id: 'd-cadena-equilibrio',
    zonaNombre: 'Reserva de Animales',
    fichaIlustracion: 'claro-bosque',
    pregunta:
        'En un ecosistema, ¿qué ocurriría primero con la hierba si desaparecieran todos los herbívoros como los conejos?',
    opciones: [
      'Al principio crecería más hierba al no ser consumida, alterando el equilibrio de toda la red trófica',
      'Los depredadores carnívoros empezarían a hacer la fotosíntesis con sus hojas',
      'Las rocas se transformarían en mamíferos acuáticos',
    ],
    indiceCorrecto: 0,
    explicacion:
        '¡Gran razonamiento! En un ecosistema todos los eslabones dependen unos de otros para mantener el equilibrio.',
  ),
  PreguntaExpedicion(
    id: 'd-fruto',
    zonaNombre: 'Invernadero Botánico',
    fichaIlustracion: 'fruto',
    pregunta:
        '¿Qué diferencia hay entre la savia bruta y la savia elaborada que circulan por el interior de una planta?',
    opciones: [
      'Son exactamente lo mismo y solo circulan por las flores secas',
      'La savia bruta es agua y sales de la raíz; la savia elaborada lleva los nutrientes fabricados en la hoja',
      'La savia bruta la fabrican las abejas y la savia elaborada cae de la lluvia',
    ],
    indiceCorrecto: 1,
    explicacion:
        '¡Sobresaliente! El xilema sube la savia bruta hasta las hojas y el floema reparte la savia elaborada a toda la planta.',
  ),
  PreguntaExpedicion(
    id: 'd-etapas-vida',
    zonaNombre: 'Nuestro Cuerpo',
    fichaIlustracion: 'etapas-vida',
    pregunta:
        '¿Cómo cooperan el aparato digestivo, el respiratorio y el circulatorio en la función de nutrición humana?',
    opciones: [
      'Solo funciona uno cada día de la semana mientras los demás se apagan',
      'Se encargan únicamente de mover los huesos del codo al saltar',
      'El digestivo aporta nutrientes y el respiratorio oxígeno, y la sangre del circulatorio los reparte a las células',
    ],
    indiceCorrecto: 2,
    explicacion:
        '¡Brillante! La nutrición requiere el trabajo coordinado de varios aparatos para llevar nutrientes y oxígeno a cada célula.',
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
      final idx = (semillaDia + i * 5) % banco.length;
      seleccion.add(banco[idx]);
    }
    return seleccion;
  }

  @override
  State<ExpedicionDiariaPage> createState() => _ExpedicionDiariaPageState();
}

class _ExpedicionDiariaPageState extends State<ExpedicionDiariaPage>
    with FeedbackAcierto<ExpedicionDiariaPage> {
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
    ocultarAcierto();
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
    ocultarAcierto();
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
        mostrarAcierto(finalDeNivel: true);
      } else {
        mostrarAcierto();
      }
      if (_pasoActual + 1 >= _mision.length) {
        await registrarGuardadoFinal(() async {
          await _siguientePaso();
          return _completada;
        });
      } else {
        await _siguientePaso();
      }
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
  DatosFinJuego? construirFinJuego() {
    if (!_completada && !(_pasoResuelto && _pasoActual + 1 == _mision.length)) {
      return null;
    }
    return DatosFinJuego(
      titulo: '¡Desafío diario completado!',
      actividad: 'Reto diario',
      nivel: '',
      resumen: ResumenPrecisionFinal(
        aciertosALaPrimera: _aciertosALaPrimera,
        totalPasos: _mision.length,
        mejorComboSesion: _mejorComboSesion,
        semillasGanadas: _semillasSesion,
      ),
      textoVolver: 'Volver al mapa',
      onVolver: () => Navigator.of(context).pop(),
      textoExtra: 'Armario de Natu',
      onExtra: () => mostrarArmarioNatu(context, _progreso),
    );
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                    Container(
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
