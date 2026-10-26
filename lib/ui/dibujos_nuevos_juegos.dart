import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/ui/componentes_juego.dart';
import 'package:naturalmente/ui/dibujos_natu.dart';

const Set<String> idsNuevosJuegos = {
  // Cromos
  'herbivoro',
  'diente-herbivoro',
  'pico-garra',
  'branquias',
  'vertebrado',
  'anfibio',
  'artropodo',
  'abeja-polen',
  'semilla-viajera',
  'helecho-espora',
  'hoja-caduca',
  'formas-hoja',
  'bosque-clima',
  'huerta-organos',
  'partes-comestibles',
  'recursos-plantas',
  'savia-planta',

  // Opciones dieta
  'dieta-herbivoro',
  'dieta-carnivoro',
  'dieta-omnivoro',
  'adaptacion-desgarrar',
  'adaptacion-filtrar-pescar',
  'adaptacion-triturar-roer',
  'huella-pezuna',
  'huella-garra',
  'huella-palmeada',
  'resp-pulmones',
  'resp-branquias',
  'resp-piel-traqueas',

  // Retos dieta
  'ciervo-bellota',
  'conejo-prado',
  'lobo-iberico',
  'lince-cazador',
  'jabali-bosque',
  'oso-pardo',
  'aguila-real',
  'buho-nocturno',
  'garza-charca',
  'pato-cuchara',
  'ardilla-pinar',
  'castor-ribera',
  'cabra-montes',
  'caballo-galope',
  'lobo-huella',
  'lince-huella',
  'nutria-huella',
  'delfin-mar',
  'trucha-arroyo',
  'renacuajo-charca',
  'saltamontes-prado',
  'lombriz-tierra',

  // Opciones grupos
  'grupo-vertebrado',
  'grupo-invertebrado',
  'vert-mamifero-ave',
  'vert-reptil-anfibio',
  'vert-mamifero',
  'vert-ave',
  'vert-reptil',
  'vert-anfibio',
  'vert-pez',
  'inv-artropodo',
  'inv-molusco',
  'inv-anelido-cnidario',

  // Retos grupos
  'caballo-prado',
  'ciguena-nido',
  'triton-charca',
  'sardina-banco',
  'pulpo-roca',
  'escarabajo-corteza',
  'cangrejo-rio',
  'cangrejo-playa',
  'mariposa-flor',
  'murcielago-cueva',
  'murcielago-noche',
  'gorrion-rama',
  'lagartija-sol',
  'lagartija-muro',
  'salamandra-musgo',
  'rana-charca',
  'caballito-mar',
  'atun-oceano',
  'salmon-rio',
  'abeja-colmena',
  'arana-tela',
  'caracol-huerta',
  'medusa-costa',
  'medusa-mar',
  'lombriz-humeda',
  'lombriz-galeria',

  // Opciones polinizacion
  'flor-caliz-corola',
  'flor-estambres',
  'flor-pistilo',
  'viaje-viento',
  'viaje-agua',
  'viaje-animal',
  'planta-angiosperma',
  'planta-gimnosperma',
  'planta-esporas',

  // Retos polinizacion
  'sepalo-verde',
  'sepalos-verdes',
  'petalo-color',
  'petalos-colores',
  'antena-polen',
  'filamento-antera',
  'saco-polinico',
  'granos-polen',
  'ovario-flor',
  'ovario-fruto',
  'estigma-cuello',
  'diente-leon',
  'samara-arce',
  'coco-costa',
  'coco-playa',
  'nenufar-semilla',
  'nenufar-charca',
  'cereza-pajaro',
  'cereza-ave',
  'cadillo-pelo',
  'cadillo-gancho',
  'manzano-flor',
  'manzano-fruto',
  'pino-pina',
  'pino-pinonero',
  'abeto-cono',
  'abeto-montana',
  'helecho-soros',
  'helecho-sombra',
  'musgo-capsula',
  'musgo-roca',

  // Opciones estaciones y huerta
  'arbol-caduco',
  'arbol-caduca',
  'arbol-perenne',
  'hoja-aguja',
  'hoja-lobulada-aserrada',
  'hoja-entera-dura',
  'bosque-atlantico',
  'bosque-mediterraneo',
  'bosque-montana',
  'huerta-raiz',
  'huerta-hoja',
  'huerta-fruto',
  'huerto-raiz-tallo',
  'huerto-hoja-flor',
  'huerto-fruto-semilla',
  'recurso-tuberculo-raiz',
  'recurso-bulbo-cereal',
  'recurso-fibra-aceite',
  'proceso-savia-bruta',
  'savia-bruta',
  'proceso-fotosintesis',
  'fotosintesis-hoja',
  'proceso-savia-elaborada',
  'savia-elaborada',

  // Retos estaciones y huerta
  'haya-otono',
  'haya-bosque',
  'roble-bosque',
  'roble-otono',
  'cerezo-valle',
  'cerezo-flor',
  'pino-verde',
  'encina-dehesa',
  'olivo-campo',
  'pino-acicula',
  'cedro-aguja',
  'roble-lobulada',
  'castano-aserrada',
  'encina-coriacea',
  'olivo-lanceolada',
  'hayedo-niebla',
  'robledal-humedo',
  'encinar-seco',
  'alcornocal-corcho',
  'pinar-cumbre',
  'abetal-nieve',
  'zanahoria-raiz',
  'rabano-raiz',
  'esparrago-tallo',
  'lechuga-hoja',
  'espinaca-hoja',
  'alcachofa-flor',
  'tomate-fruto',
  'fresa-fruto',
  'guisante-vaina',
  'guisante-semilla',
  'patata-tuberculo',
  'remolacha-raiz',
  'cebolla-bulbo',
  'trigo-harina',
  'algodon-fibra',
  'aceituna-aceite',
  'absorcion-raiz',
  'subida-xilema',
  'ascenso-tallo',
  'captura-luz-sol',
  'clorofila-sol',
  'entrada-co2-hoja',
  'estomas-aire',
  'reparto-floema',
  'reparto-planta',
};

bool esDibujoNuevoJuego(String id) => idsNuevosJuegos.contains(id);

String pistaRetoNuevoJuego(String id, [String? actividadId]) => switch (id) {
  'ciervo-bellota' => 'Muelas anchas para moler hojas y bellotas',
  'conejo-prado' => 'Incisivos largos que cortan hierba y tréboles',
  'lobo-iberico' => 'Colmillos afilados y muelas carniceras',
  'lince-cazador' => 'Colmillos largos y garras retráctiles',
  'jabali-bosque' => 'Muelas resistentes: come bellotas, raíces y lombrices',
  'oso-pardo' => 'Come bayas, miel, brotes y también peces',
  'aguila-real' => 'Pico curvo en gancho y garras prensiles fuertes',
  'buho-nocturno' => 'Rapaz nocturna con pico ganchudo y garras curvas',
  'garza-charca' => 'Pico largo y recto como pinza para pescar',
  'pato-cuchara' => 'Pico ancho y plano con laminillas para filtrar agua',
  'ardilla-pinar' => 'Incisivos fuertes como cinceles para abrir piñas',
  'castor-ribera' => 'Grandes incisivos naranjas para roer ramas y corteza',
  'cabra-montes' => 'Pezuña hendida en dos dedos duros y elásticos',
  'caballo-galope' => 'Casco duro de una sola pieza para galopar',
  'lobo-huella' => '4 almohadillas con marcas de uñas fijas delante',
  'lince-huella' => '4 almohadillas redondeadas sin marcas de uñas',
  'nutria-huella' => '5 dedos unidos por membrana para remar en el río',
  'caballo-prado' => 'Rayos X: cráneo, columna vertebral y costillas',
  'ciguena-nido' => 'Rayos X: esqueleto interno ligero con columna y plumas',
  'triton-charca' => 'Rayos X: columna vertebral interna y piel húmeda',
  'sardina-banco' => 'Rayos X: espina central con vértebras',
  'pulpo-roca' => 'Rayos X: cuerpo blando y flexible sin huesos',
  'escarabajo-corteza' => 'Coraza exterior articulada con 6 patas y sin huesos',
  'cangrejo-rio' || 'cangrejo-playa' => 'Caparazón duro por fuera, 10 patas y sin columna',
  'mariposa-flor' => 'Exoesqueleto articulado, 6 patas y sin huesos',
  'murcielago-cueva' || 'murcielago-noche' => 'Piel con pelo, orejas y crías que maman leche',
  'gorrion-rama' => 'Plumas, pico sin dientes, 2 alas y ovíparo',
  'lagartija-sol' || 'lagartija-muro' => 'Escamas secas pegadas al cuerpo y 4 patas',
  'salamandra-musgo' || 'rana-charca' => 'Piel húmeda desnuda y metamorfosis desde larva',
  'caballito-mar' => 'Pez óseo con aleta dorsal que vibra y branquias',
  'atun-oceano' || 'salmon-rio' => 'Escamas brillantes, aletas y branquias para el agua',
  'abeja-colmena' => '6 patas articuladas, 2 antenas y alas',
  'arana-tela' => '8 patas articuladas y cuerpo sin antenas',
  'caracol-huerta' => 'Cuerpo blando musculoso protegido por una concha',
  'medusa-costa' || 'medusa-mar' => 'Cuerpo gelatinoso en sombrilla con tentáculos',
  'lombriz-humeda' || 'lombriz-galeria' => 'Cuerpo blando alargado dividido en anillos',
  'sepalo-verde' || 'sepalos-verdes' => 'Hojitas verdes de la base que abrigan el capullo cerrado',
  'petalo-color' || 'petalos-colores' => 'Láminas coloreadas y perfumadas que atraen a los insectos',
  'antena-polen' || 'filamento-antera' => 'Hilito flexible que sostiene dos bolsitas amarillas arriba',
  'saco-polinico' || 'granos-polen' => 'Polvillo dorado que sale de las bolsitas masculinas',
  'ovario-flor' || 'ovario-fruto' => 'Cámara abombada del fondo central con óvulos que dará el fruto',
  'estigma-cuello' => 'Cuello central con punta pegajosa donde aterriza el polen',
  'diente-leon' => 'Paracaídas de pelitos blancos muy ligero',
  'samara-arce' => 'Semilla con ala que gira como un helicóptero',
  'coco-costa' || 'coco-playa' => 'Fibra con aire dentro que flota en el mar',
  'nenufar-semilla' || 'nenufar-charca' => 'Bolsita flotante arrastrada por la corriente',
  'cereza-pajaro' || 'cereza-ave' => 'Pulpa roja y dulce que comen los pájaros',
  'cadillo-pelo' || 'cadillo-gancho' => 'Ganchitos como velcro que se pegan al pelaje',
  'manzano-flor' || 'manzano-fruto' => 'Flores vistosas y semillas dentro de una manzana',
  'pino-pina' || 'pino-pinonero' => 'Piñones en piñas leñosas sin fruto carnoso',
  'abeto-cono' || 'abeto-montana' => 'Conos erguidos con semillas aladas desnudas',
  'helecho-soros' || 'helecho-sombra' => 'Sin flores ni semillas: soros con esporas',
  'musgo-capsula' || 'musgo-roca' => 'Alfombra verde con cápsulas llenas de esporas',
  'haya-otono' || 'haya-bosque' => 'Hojas cobrizas en otoño y ramas desnudas en invierno',
  'roble-bosque' || 'roble-otono' => 'Tira sus hojas lobuladas cuando llega el frío',
  'cerezo-valle' || 'cerezo-flor' => 'Flores en primavera y sin hojas en invierno',
  'pino-verde' => 'Agujas verdes que resisten la nieve todo el año',
  'encina-dehesa' => 'Copa siempre verde en las cuatro estaciones',
  'olivo-campo' => 'Hojas verde-plateadas durante todo el año',
  'pino-acicula' => 'Acículas largas y muy finas en pares que no caen en invierno',
  'cedro-aguja' => 'Ramilletes de agujas cortas y duras siempre verdes',
  'roble-lobulada' => 'Hoja ancha con entrantes redondeados (lóbulos) que cae en otoño',
  'castano-aserrada' => 'Hoja grande con borde de dientes de sierra que cae en otoño',
  'encina-coriacea' => 'Hoja dura, entera y con pelusilla blanca debajo todo el año',
  'olivo-lanceolada' => 'Hoja alargada de borde liso y dura que resiste el sol',
  'hayedo-niebla' => 'Clima húmedo y suave: hojas anchas y finas que caen en otoño',
  'robledal-humedo' => 'Suelos frescos y lluviosos: reposo invernal sin hojas',
  'encinar-seco' => 'Veranos muy secos y calurosos: hojas duras que ahorran agua',
  'alcornocal-corcho' => 'Clima mediterráneo: corteza gruesa de corcho y hoja perenne',
  'pinar-cumbre' => 'Alta montaña con heladas: agujas con resina y copa cónica',
  'abetal-nieve' => 'Cumbres nevadas: porte piramidal para que resbale la nieve',
  'zanahoria-raiz' => 'Crece bajo tierra con pelitos absorbentes y guarda reservas',
  'rabano-raiz' => 'Raíz redonda y rojiza que engorda bajo la tierra del huerto',
  'esparrago-tallo' => 'Brote tierno que sube recto desde el suelo con yema en la punta',
  'lechuga-hoja' => 'Láminas verdes y frescas abiertas al sol en roseta',
  'espinaca-hoja' => 'Hojas verdes y tiernas con nervios que hacen la fotosíntesis',
  'alcachofa-flor' => 'Capullo en lo alto del tallo formado por brácteas antes de abrirse',
  'tomate-fruto' => 'Nace de la flor fecundada y guarda pepitas en su pulpa',
  'fresa-fruto' => 'Nace de la flor blanca y madura roja y dulce con aquenios',
  'guisante-vaina' || 'guisante-semilla' => 'Bolitas verdes dentro de la vaina que germinan',
  'patata-tuberculo' => 'Tallo subterráneo (tubérculo) con yemas que almacena almidón',
  'remolacha-raiz' => 'Raíz gruesa subterránea muy rica en azúcares naturales',
  'cebolla-bulbo' => 'Bulbo subterráneo de capas carnosas superpuestas',
  'trigo-harina' => 'Espiga de cereal cuyos granos secos se muelen en harina',
  'algodon-fibra' => 'Cápsula blanca cuyas fibras envuelven las semillas para hilar tela',
  'aceituna-aceite' => 'Fruto del olivo que se prensa en la almazara para obtener aceite',
  'absorcion-raiz' => 'Agua y sales minerales que entran desde el suelo',
  'subida-xilema' || 'ascenso-tallo' => 'Vasos leñosos que suben agua y sales a las hojas',
  'captura-luz-sol' || 'clorofila-sol' => 'Pigmento verde que capta la energía del Sol',
  'entrada-co2-hoja' || 'estomas-aire' => 'Poros de la hoja que toman CO₂ y sueltan oxígeno',
  'reparto-floema' || 'reparto-planta' => 'Azúcares que viajan desde la hoja a toda la planta',
  _ => 'Observa sus características en el visor interactivo',
};

String subtituloSitioNuevoJuego(String id) => switch (id) {
  'dieta-herbivoro' => 'Muelas planas · Solo plantas',
  'dieta-carnivoro' => 'Colmillos afilados · Caza presas',
  'dieta-omnivoro' => 'Come plantas y animales',
  'adaptacion-desgarrar' => 'Pico en gancho y garras curvas',
  'adaptacion-filtrar-pescar' => 'Pico largo o plano para el agua',
  'adaptacion-triturar-roer' => 'Incisivos fuertes para semillas',
  'huella-pezuna' => 'Estuche duro de 1 o 2 dedos',
  'huella-garra' => 'Cojinetes plantares y uñas',
  'huella-palmeada' => 'Membrana entre los dedos',
  'grupo-vertebrado' => 'Con columna vertebral interna',
  'grupo-invertebrado' => 'Sin huesos internos',
  'vert-mamifero-ave' => 'Pelo o plumas · Pulmones',
  'vert-reptil-anfibio' => 'Escamas secas o piel húmeda',
  'vert-mamifero' => 'Pelo · Pulmones · Vivíparos',
  'vert-ave' => 'Plumas · Pico · 2 alas',
  'vert-reptil' => 'Escamas duras · Ovíparos',
  'vert-anfibio' => 'Piel húmeda · Metamorfosis',
  'vert-pez' => 'Aletas · Escamas · Branquias',
  'inv-artropodo' => 'Patas articuladas · Exoesqueleto',
  'inv-molusco' => 'Cuerpo blando · A veces concha',
  'inv-anelido-cnidario' => 'Anillos blandos o tentáculos',
  'flor-caliz-corola' => 'Envoltura que protege y atrae',
  'flor-estambres' => 'Órgano masculino de la flor',
  'flor-pistilo' => 'Órgano femenino central',
  'viaje-viento' => 'Alas o pelitos ligeros',
  'viaje-agua' => 'Flotan en ríos o en el mar',
  'viaje-animal' => 'Fruto dulce o ganchitos',
  'planta-angiosperma' => 'Semillas dentro de un fruto',
  'planta-gimnosperma' => 'Semillas desnudas en piñas',
  'planta-esporas' => 'Musgos y helechos con esporas',
  'arbol-caduco' || 'arbol-caduca' => 'Pierde la hoja en otoño',
  'arbol-perenne' => 'Verde durante todo el año',
  'hoja-aguja' => 'Fina y dura · Coníferas',
  'hoja-lobulada-aserrada' => 'Entrantes o dientes · Caduca',
  'hoja-entera-dura' => 'Borde liso y coriácea · Perenne',
  'bosque-atlantico' => 'Lluvia abundante · Hoja caduca',
  'bosque-mediterraneo' => 'Verano seco · Hoja dura perenne',
  'bosque-montana' => 'Frío y nieve · Copa cónica',
  'huerta-raiz' => 'Crece bajo la tierra',
  'huerta-hoja' => 'Láminas verdes al sol',
  'huerta-fruto' => 'Nace de la flor · Con semillas',
  'huerto-raiz-tallo' => 'Crece bajo tierra o sostiene',
  'huerto-hoja-flor' => 'Láminas verdes o capullos',
  'huerto-fruto-semilla' => 'Nace de la flor o germina',
  'recurso-tuberculo-raiz' => 'Almidón o azúcar bajo tierra',
  'recurso-bulbo-cereal' => 'Capas subterráneas o grano',
  'recurso-fibra-aceite' => 'Tejido vegetal o aceite',
  'proceso-savia-bruta' || 'savia-bruta' => 'Agua y sales · Raíz → Hojas',
  'proceso-fotosintesis' || 'fotosintesis-hoja' => 'Sol + CO₂ → Alimento + O₂',
  'proceso-savia-elaborada' || 'savia-elaborada' => 'Alimento · Hojas → Planta',
  _ => '',
};

Color colorSitioNuevoJuego(String id) => switch (id) {
  'dieta-herbivoro' ||
  'adaptacion-triturar-roer' ||
  'vert-reptil-anfibio' ||
  'flor-caliz-corola' ||
  'planta-esporas' ||
  'arbol-perenne' ||
  'hoja-entera-dura' ||
  'bosque-atlantico' ||
  'huerta-hoja' ||
  'huerto-hoja-flor' ||
  'recurso-fibra-aceite' ||
  'proceso-fotosintesis' ||
  'fotosintesis-hoja' => const Color(0xFFDCFCE7),
  'dieta-carnivoro' ||
  'adaptacion-desgarrar' ||
  'huella-garra' ||
  'planta-angiosperma' ||
  'huerta-fruto' ||
  'huerto-fruto-semilla' ||
  'recurso-tuberculo-raiz' => const Color(0xFFFFE4E6),
  'dieta-omnivoro' ||
  'huella-pezuna' ||
  'vert-mamifero-ave' ||
  'flor-estambres' ||
  'viaje-animal' ||
  'planta-gimnosperma' ||
  'arbol-caduco' ||
  'arbol-caduca' ||
  'hoja-lobulada-aserrada' ||
  'bosque-mediterraneo' ||
  'huerta-raiz' ||
  'huerto-raiz-tallo' ||
  'recurso-bulbo-cereal' ||
  'proceso-savia-elaborada' ||
  'savia-elaborada' => const Color(0xFFFEF3C7),
  'adaptacion-filtrar-pescar' ||
  'huella-palmeada' ||
  'grupo-vertebrado' ||
  'vert-pez' ||
  'vert-ave' ||
  'viaje-viento' ||
  'viaje-agua' ||
  'hoja-aguja' ||
  'bosque-montana' ||
  'proceso-savia-bruta' ||
  'savia-bruta' => const Color(0xFFE0F2FE),
  _ => const Color(0xFFF3E8FF),
};

Color bordeSitioNuevoJuego(String id) => switch (id) {
  'dieta-herbivoro' ||
  'adaptacion-triturar-roer' ||
  'vert-reptil-anfibio' ||
  'flor-caliz-corola' ||
  'planta-esporas' ||
  'arbol-perenne' ||
  'hoja-entera-dura' ||
  'bosque-atlantico' ||
  'huerta-hoja' ||
  'huerto-hoja-flor' ||
  'recurso-fibra-aceite' ||
  'proceso-fotosintesis' ||
  'fotosintesis-hoja' => const Color(0xFF16A34A),
  'dieta-carnivoro' ||
  'adaptacion-desgarrar' ||
  'huella-garra' ||
  'planta-angiosperma' ||
  'huerta-fruto' ||
  'huerto-fruto-semilla' ||
  'recurso-tuberculo-raiz' => const Color(0xFFE11D48),
  'dieta-omnivoro' ||
  'huella-pezuna' ||
  'vert-mamifero-ave' ||
  'flor-estambres' ||
  'viaje-animal' ||
  'planta-gimnosperma' ||
  'arbol-caduco' ||
  'arbol-caduca' ||
  'hoja-lobulada-aserrada' ||
  'bosque-mediterraneo' ||
  'huerta-raiz' ||
  'huerto-raiz-tallo' ||
  'recurso-bulbo-cereal' ||
  'proceso-savia-elaborada' ||
  'savia-elaborada' => const Color(0xFFD97706),
  'adaptacion-filtrar-pescar' ||
  'huella-palmeada' ||
  'grupo-vertebrado' ||
  'vert-pez' ||
  'vert-ave' ||
  'viaje-viento' ||
  'viaje-agua' ||
  'hoja-aguja' ||
  'bosque-montana' ||
  'proceso-savia-bruta' ||
  'savia-bruta' => const Color(0xFF0284C7),
  _ => const Color(0xFF9333EA),
};

class DibujoNuevoJuego extends StatelessWidget {
  const DibujoNuevoJuego({required this.id, this.tamano = 92, super.key});

  final String id;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(painter: _PintorNuevoJuego(id)),
    );
  }
}

class _PintorNuevoJuego extends CustomPainter {
  const _PintorNuevoJuego([this.id = '']);

  final String id;

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  Paint _stroke(Color c, [double w = 2.1]) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  Paint _grad(
    Rect rect,
    Color arriba,
    Color abajo, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) =>
      Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: [arriba, abajo],
        ).createShader(rect)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

  Paint _fillGrad(
    Rect rect,
    List<Color> colors, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) =>
      Paint()
        ..shader = LinearGradient(
          begin: begin,
          end: end,
          colors: colors,
        ).createShader(rect)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

  void _sombraSuelo(Canvas c, [double cx = 50, double cy = 87, double rx = 31, double ry = 6.5]) {
    final rect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
    c.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.22),
            const Color(0xFF0F172A).withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );
  }

  void _ojo(Canvas c, double x, double y, [double r = 3.2]) {
    c.drawCircle(Offset(x, y), r * 1.32, _fill(Colors.white));
    c.drawCircle(Offset(x, y), r * 1.32, _stroke(const Color(0xFF1E293B), 1.0));
    c.drawCircle(Offset(x + r * 0.14, y), r * 0.86, _fill(const Color(0xFF0F172A)));
    c.drawCircle(Offset(x - r * 0.26, y - r * 0.3), r * 0.36, _fill(Colors.white));
  }

  void _moflete(Canvas c, double x, double y, [double rx = 4.2, double ry = 2.6]) {
    c.drawOval(
      Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2),
      _fill(const Color(0xFFFB7185).withValues(alpha: 0.34)),
    );
  }

  void _delegarAnimalDetallado(Canvas c, String idAnimal) {
    PintorAnimalDetallado(id: idAnimal, sinFondo: true).paint(c, const Size(100, 100));
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100.0, size.height / 100.0);
    _dibujarIcono(canvas, id);
    canvas.restore();
  }

  void _dibujarIcono(Canvas c, String id) {
    switch (id) {
      // ==================== CROMOS Y DIETAS ====================
      case 'herbivoro':
      case 'diente-herbivoro':
      case 'dieta-herbivoro':
        // Emblema detallado: hoja de roble lobulada + muela ancha de corona estriada con raíces
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFECFDF5), const Color(0xFFBBF7D0)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF16A34A), 2.2));
        final hojaRoble = Path()
          ..moveTo(16, 72)
          ..quadraticBezierTo(16, 46, 30, 38)
          ..quadraticBezierTo(26, 24, 42, 22)
          ..quadraticBezierTo(52, 14, 62, 24)
          ..quadraticBezierTo(72, 30, 60, 44)
          ..quadraticBezierTo(48, 66, 16, 72)
          ..close();
        c.drawPath(
          hojaRoble,
          _grad(const Rect.fromLTWH(16, 16, 56, 56), const Color(0xFF4ADE80), const Color(0xFF15803D)),
        );
        c.drawPath(hojaRoble, _stroke(const Color(0xFF14532D), 2.0));
        c.drawLine(const Offset(18, 70), const Offset(54, 26), _stroke(const Color(0xFFBBF7D0), 1.8));
        // Muela molar herbívora con raíces y crestas de esmalte
        final raizMuela = Path()
          ..moveTo(46, 58)
          ..lineTo(43, 81)
          ..quadraticBezierTo(48, 84, 52, 66)
          ..lineTo(60, 66)
          ..quadraticBezierTo(64, 84, 69, 81)
          ..lineTo(66, 58)
          ..close();
        c.drawPath(raizMuela, _fill(const Color(0xFFFDE68A)));
        c.drawPath(raizMuela, _stroke(const Color(0xFF475569), 2.0));
        final coronaMuela = RRect.fromRectAndRadius(
          const Rect.fromLTWH(38, 36, 38, 25),
          const Radius.circular(8),
        );
        c.drawRRect(
          coronaMuela,
          _grad(const Rect.fromLTWH(38, 36, 38, 25), Colors.white, const Color(0xFFFEF3C7)),
        );
        c.drawRRect(coronaMuela, _stroke(const Color(0xFF334155), 2.2));
        for (final y in [43.0, 50.0]) {
          c.drawLine(Offset(44, y), Offset(70, y), _stroke(const Color(0xFF94A3B8), 2.0));
        }
        break;

      case 'boca-herbivoro':
        // Cráneo/mandíbula lateral de herbívoro: incisivos delanteros, diastema ancho y fila de muelas planas
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(14)),
          _grad(const Rect.fromLTWH(8, 12, 84, 76), const Color(0xFF0F172A), const Color(0xFF1E293B)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(14)),
          _stroke(const Color(0xFF38BDF8), 2.0),
        );
        // Hueso mandibular inferior con rama ascendente
        final mandHerb = Path()
          ..moveTo(14, 62)
          ..lineTo(68, 62)
          ..quadraticBezierTo(82, 62, 84, 30)
          ..lineTo(74, 28)
          ..quadraticBezierTo(70, 50, 58, 52)
          ..lineTo(14, 54)
          ..close();
        c.drawPath(mandHerb, _fill(const Color(0xFF38BDF8).withValues(alpha: 0.25)));
        c.drawPath(mandHerb, _stroke(const Color(0xFF38BDF8), 2.2));
        // Incisivos cortantes delanteros
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(15, 42, 7, 13), const Radius.circular(2)),
          _fill(Colors.white),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(23, 43, 6, 12), const Radius.circular(2)),
          _fill(const Color(0xFFE0F2FE)),
        );
        // Muelas anchas estriadas tras el diastema (hueco sin colmillos)
        for (double x = 40; x <= 64; x += 11) {
          final m = RRect.fromRectAndRadius(Rect.fromLTWH(x, 40, 10, 13), const Radius.circular(2.5));
          c.drawRRect(m, _fill(Colors.white));
          c.drawRRect(m, _stroke(const Color(0xFF0284C7), 1.4));
          c.drawLine(Offset(x + 2, 44), Offset(x + 8, 44), _stroke(const Color(0xFF0284C7), 1.2));
        }
        break;

      case 'dieta-carnivoro':
        // Emblema detallado: gran colmillo curvo de marfil + muela carnicera en punta
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFF1F2), const Color(0xFFFECDD3)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFE11D48), 2.2));
        // Encía superior
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(22, 18, 56, 14), const Radius.circular(7)),
          _grad(const Rect.fromLTWH(22, 18, 56, 14), const Color(0xFFFB7185), const Color(0xFFBE123C)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(22, 18, 56, 14), const Radius.circular(7)),
          _stroke(const Color(0xFF881337), 2.0),
        );
        // Colmillo largo afilado
        final colmillo = Path()
          ..moveTo(27, 29)
          ..quadraticBezierTo(30, 68, 42, 82)
          ..quadraticBezierTo(48, 60, 45, 29)
          ..close();
        c.drawPath(
          colmillo,
          _grad(const Rect.fromLTWH(27, 29, 20, 54), Colors.white, const Color(0xFFFEF3C7)),
        );
        c.drawPath(colmillo, _stroke(const Color(0xFF334155), 2.2));
        // Muela carnicera tricúspide
        final carnicera = Path()
          ..moveTo(49, 29)
          ..lineTo(54, 48)
          ..lineTo(61, 37)
          ..lineTo(68, 54)
          ..lineTo(75, 29)
          ..close();
        c.drawPath(
          carnicera,
          _grad(const Rect.fromLTWH(49, 29, 26, 26), Colors.white, const Color(0xFFFEF3C7)),
        );
        c.drawPath(carnicera, _stroke(const Color(0xFF334155), 2.2));
        break;

      case 'boca-carnivoro':
        // Rayos X de mandíbula carnívora con grandes caninos curvos y muelas carniceras afiladas
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(14)),
          _grad(const Rect.fromLTWH(8, 12, 84, 76), const Color(0xFF0F172A), const Color(0xFF1E293B)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(14)),
          _stroke(const Color(0xFFFB7185), 2.0),
        );
        final mandCarn = Path()
          ..moveTo(14, 66)
          ..lineTo(74, 66)
          ..quadraticBezierTo(84, 64, 84, 36)
          ..lineTo(74, 36)
          ..quadraticBezierTo(70, 54, 60, 56)
          ..lineTo(14, 56)
          ..close();
        c.drawPath(mandCarn, _fill(const Color(0xFFFB7185).withValues(alpha: 0.25)));
        c.drawPath(mandCarn, _stroke(const Color(0xFFFB7185), 2.2));
        // Gran colmillo canino curvo
        final caninoRx = Path()
          ..moveTo(18, 56)
          ..quadraticBezierTo(20, 26, 30, 22)
          ..quadraticBezierTo(32, 42, 30, 56)
          ..close();
        c.drawPath(caninoRx, _fill(Colors.white));
        c.drawPath(caninoRx, _stroke(const Color(0xFFF43F5E), 1.5));
        // Muelas carniceras en sierra
        for (double x = 35; x <= 63; x += 13) {
          final mCarn = Path()
            ..moveTo(x, 56)
            ..lineTo(x + 4, 38)
            ..lineTo(x + 8, 47)
            ..lineTo(x + 11, 36)
            ..lineTo(x + 13, 56)
            ..close();
          c.drawPath(mCarn, _fill(Colors.white));
          c.drawPath(mCarn, _stroke(const Color(0xFFF43F5E), 1.3));
        }
        break;

      case 'dieta-omnivoro':
        // Emblema detallado: bellota de bosque + trucha plateada + muela mixta redondeada
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFD97706), 2.2));
        // Bellota con cúpula texturizada
        c.drawOval(
          const Rect.fromLTWH(18, 38, 24, 30),
          _grad(const Rect.fromLTWH(18, 38, 24, 30), const Color(0xFFD97706), const Color(0xFF92400E)),
        );
        c.drawOval(const Rect.fromLTWH(18, 38, 24, 30), _stroke(const Color(0xFF451A03), 2.0));
        c.drawArc(
          const Rect.fromLTWH(16, 30, 28, 20),
          math.pi,
          math.pi,
          true,
          _fill(const Color(0xFF78350F)),
        );
        c.drawArc(
          const Rect.fromLTWH(16, 30, 28, 20),
          math.pi,
          math.pi,
          true,
          _stroke(const Color(0xFF451A03), 2.0),
        );
        c.drawLine(const Offset(30, 30), const Offset(30, 22), _stroke(const Color(0xFF451A03), 2.5));
        // Pez fresco azulado a la derecha
        final colaO = Path()
          ..moveTo(80, 54)
          ..lineTo(89, 45)
          ..lineTo(89, 63)
          ..close();
        c.drawPath(colaO, _fill(const Color(0xFF0284C7)));
        c.drawPath(colaO, _stroke(const Color(0xFF0C4A6E), 1.8));
        final cuerpoPezO = Path()
          ..moveTo(45, 54)
          ..quadraticBezierTo(62, 38, 81, 54)
          ..quadraticBezierTo(62, 70, 45, 54)
          ..close();
        c.drawPath(
          cuerpoPezO,
          _grad(const Rect.fromLTWH(45, 40, 36, 28), const Color(0xFF7DD3FC), const Color(0xFF0284C7)),
        );
        c.drawPath(cuerpoPezO, _stroke(const Color(0xFF0C4A6E), 2.0));
        c.drawCircle(const Offset(53, 52), 2.0, _fill(const Color(0xFF0F172A)));
        break;

      case 'boca-omnivoro':
        // Rayos X de mandíbula omnívora: incisivos, canino moderado y molares redondeados
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(14)),
          _grad(const Rect.fromLTWH(8, 12, 84, 76), const Color(0xFF0F172A), const Color(0xFF1E293B)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(14)),
          _stroke(const Color(0xFFFBBF24), 2.0),
        );
        final mandOmn = Path()
          ..moveTo(14, 64)
          ..lineTo(72, 64)
          ..quadraticBezierTo(84, 62, 84, 34)
          ..lineTo(74, 34)
          ..quadraticBezierTo(70, 52, 60, 54)
          ..lineTo(14, 54)
          ..close();
        c.drawPath(mandOmn, _fill(const Color(0xFFFBBF24).withValues(alpha: 0.25)));
        c.drawPath(mandOmn, _stroke(const Color(0xFFFBBF24), 2.2));
        // Incisivo
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(16, 42, 7, 12), const Radius.circular(2)),
          _fill(Colors.white),
        );
        // Colmillo medio
        final colmOmn = Path()
          ..moveTo(26, 54)
          ..lineTo(31, 33)
          ..lineTo(37, 54)
          ..close();
        c.drawPath(colmOmn, _fill(const Color(0xFFFEF08A)));
        // Muelas bunodontas redondeadas
        for (final x in [41.0, 55.0]) {
          final mOmn = RRect.fromRectAndRadius(Rect.fromLTWH(x, 42, 12, 12), const Radius.circular(4));
          c.drawRRect(mOmn, _fill(Colors.white));
          c.drawRRect(mOmn, _stroke(const Color(0xFFD97706), 1.4));
        }
        break;

      case 'pico-garra':
      case 'adaptacion-desgarrar':
        // Emblema detallado: pico ganchudo de rapaz + garra curva prensil
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFB45309), 2.2));
        // Cera y pico curvado hacia abajo
        final picoRapaz = Path()
          ..moveTo(20, 28)
          ..quadraticBezierTo(68, 20, 76, 58)
          ..quadraticBezierTo(62, 46, 46, 46)
          ..lineTo(20, 46)
          ..close();
        c.drawPath(
          picoRapaz,
          _grad(const Rect.fromLTWH(20, 20, 58, 40), const Color(0xFFFACC15), const Color(0xFFD97706)),
        );
        c.drawPath(picoRapaz, _stroke(const Color(0xFF78350F), 2.3));
        // Punta oscura del gancho
        final puntaNegra = Path()
          ..moveTo(64, 38)
          ..quadraticBezierTo(74, 44, 76, 58)
          ..quadraticBezierTo(67, 49, 59, 47)
          ..close();
        c.drawPath(puntaNegra, _fill(const Color(0xFF1E293B)));
        // Garra curvada inferior
        final garraCurva = Path()
          ..moveTo(28, 66)
          ..quadraticBezierTo(50, 58, 60, 80)
          ..quadraticBezierTo(44, 68, 28, 74)
          ..close();
        c.drawPath(garraCurva, _fill(const Color(0xFF1E293B)));
        c.drawPath(garraCurva, _stroke(const Color(0xFF0F172A), 1.8));
        break;

      case 'adaptacion-filtrar-pescar':
        // Emblema detallado: pico acuático con laminillas filtradoras y ondas de charca
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF0284C7), 2.2));
        final picoAcuatico = Path()
          ..moveTo(16, 36)
          ..lineTo(72, 34)
          ..quadraticBezierTo(86, 44, 72, 54)
          ..lineTo(16, 50)
          ..close();
        c.drawPath(
          picoAcuatico,
          _grad(const Rect.fromLTWH(16, 34, 70, 22), const Color(0xFFFBBF24), const Color(0xFFD97706)),
        );
        c.drawPath(picoAcuatico, _stroke(const Color(0xFF78350F), 2.2));
        for (double x = 24; x <= 68; x += 6.5) {
          c.drawLine(Offset(x, 38), Offset(x, 51), _stroke(const Color(0xFF78350F), 1.8));
        }
        final onda1 = Path()
          ..moveTo(18, 66)
          ..quadraticBezierTo(34, 58, 50, 66)
          ..quadraticBezierTo(66, 74, 82, 66);
        final onda2 = Path()
          ..moveTo(24, 76)
          ..quadraticBezierTo(38, 70, 52, 76)
          ..quadraticBezierTo(66, 82, 78, 76);
        c.drawPath(onda1, _stroke(const Color(0xFF0284C7), 2.8));
        c.drawPath(onda2, _stroke(const Color(0xFF38BDF8), 2.2));
        break;

      case 'adaptacion-triturar-roer':
        // Emblema detallado: par de incisivos en cincel de esmalte naranja + avellana leñosa
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF059669), 2.2));
        for (final x in [33.0, 51.0]) {
          final inc = RRect.fromRectAndRadius(Rect.fromLTWH(x, 16, 15, 34), const Radius.circular(3.5));
          c.drawRRect(
            inc,
            _grad(Rect.fromLTWH(x, 16, 15, 34), const Color(0xFFFB923C), const Color(0xFFEA580C)),
          );
          c.drawRRect(inc, _stroke(const Color(0xFF7C2D12), 2.1));
          // Bisel cortante blanco en el filo inferior
          c.drawRect(Rect.fromLTWH(x + 2, 44, 11, 5), _fill(const Color(0xFFFFFBEB)));
        }
        // Fruto seco de cáscara dura debajo
        c.drawOval(
          const Rect.fromLTWH(30, 56, 40, 28),
          _grad(const Rect.fromLTWH(30, 56, 40, 28), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(30, 56, 40, 28), _stroke(const Color(0xFF451A03), 2.2));
        c.drawLine(const Offset(50, 56), const Offset(46, 69), _stroke(const Color(0xFFFEF08A), 2.2));
        c.drawLine(const Offset(46, 69), const Offset(53, 82), _stroke(const Color(0xFFFEF08A), 2.2));
        break;

      case 'branquias':
      case 'huella-garra':
        // Emblema de huella digitígrada con almohadilla plantar y 4 dedos
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFB45309), 2.2));
        final cojinete = Path()
          ..moveTo(34, 68)
          ..quadraticBezierTo(32, 52, 50, 50)
          ..quadraticBezierTo(68, 52, 66, 68)
          ..quadraticBezierTo(58, 76, 50, 72)
          ..quadraticBezierTo(42, 76, 34, 68)
          ..close();
        c.drawPath(cojinete, _fill(const Color(0xFF44403C)));
        c.drawPath(cojinete, _stroke(const Color(0xFF1C1917), 2.0));
        for (final pos in [
          const Offset(27, 43),
          const Offset(42, 33),
          const Offset(58, 33),
          const Offset(73, 43),
        ]) {
          c.drawOval(
            Rect.fromCenter(center: pos, width: 12, height: 16),
            _fill(const Color(0xFF44403C)),
          );
          c.drawOval(
            Rect.fromCenter(center: pos, width: 12, height: 16),
            _stroke(const Color(0xFF1C1917), 1.8),
          );
          final una = Path()
            ..moveTo(pos.dx - 3, pos.dy - 10)
            ..lineTo(pos.dx, pos.dy - 18)
            ..lineTo(pos.dx + 3, pos.dy - 10)
            ..close();
          c.drawPath(una, _fill(const Color(0xFF1C1917)));
        }
        break;

      case 'lobo-huella':
      case 'lobo-iberico':
        // Lobo ibérico detallado con pelaje en capas, pecho crema, cola tupida y mirada expresiva
        _sombraSuelo(c, 50, 87, 32, 6.5);
        // Cola tupida en dos tonos
        final colaLobo = Path()
          ..moveTo(22, 54)
          ..quadraticBezierTo(6, 56, 9, 72)
          ..quadraticBezierTo(18, 70, 26, 60)
          ..close();
        c.drawPath(
          colaLobo,
          _grad(const Rect.fromLTWH(6, 54, 22, 20), const Color(0xFF64748B), const Color(0xFF334155)),
        );
        c.drawPath(colaLobo, _stroke(const Color(0xFF1E293B), 2.0));
        // Patas traseras (plano posterior más oscuro)
        for (final x in [25.0, 52.0]) {
          final pTras = RRect.fromRectAndRadius(Rect.fromLTWH(x, 62, 7.5, 23), const Radius.circular(3.5));
          c.drawRRect(pTras, _fill(const Color(0xFF475569)));
          c.drawRRect(pTras, _stroke(const Color(0xFF1E293B), 1.9));
        }
        // Cuerpo musculoso con lomo gris pizarra
        final cuerpoLobo = RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 44, 46, 24),
          const Radius.circular(12),
        );
        c.drawRRect(
          cuerpoLobo,
          _grad(const Rect.fromLTWH(20, 44, 46, 24), const Color(0xFF94A3B8), const Color(0xFF475569)),
        );
        // Pecho y vientre claros
        c.drawOval(const Rect.fromLTWH(28, 55, 34, 12), _fill(const Color(0xFFE2E8F0)));
        c.drawRRect(cuerpoLobo, _stroke(const Color(0xFF1E293B), 2.1));
        // Patas delanteras (primer plano)
        for (final x in [32.0, 59.0]) {
          final pDel = RRect.fromRectAndRadius(Rect.fromLTWH(x, 63, 7.5, 23), const Radius.circular(3.5));
          c.drawRRect(pDel, _fill(const Color(0xFF64748B)));
          c.drawRRect(pDel, _stroke(const Color(0xFF1E293B), 1.9));
        }
        // Cuello tupido y cabeza
        final orejaTrasL = Path()
          ..moveTo(54, 30)
          ..lineTo(57, 13)
          ..lineTo(64, 27)
          ..close();
        c.drawPath(orejaTrasL, _fill(const Color(0xFF334155)));
        c.drawPath(orejaTrasL, _stroke(const Color(0xFF1E293B), 1.9));
        c.drawCircle(
          const Offset(63, 39),
          14.5,
          _grad(const Rect.fromLTWH(48, 24, 30, 30), const Color(0xFF94A3B8), const Color(0xFF475569)),
        );
        // Hocico alargado bicolor
        final hocicoL = RRect.fromRectAndRadius(
          const Rect.fromLTWH(68, 35, 21, 12),
          const Radius.circular(5.5),
        );
        c.drawRRect(hocicoL, _fill(const Color(0xFF64748B)));
        c.drawOval(const Rect.fromLTWH(66, 41, 21, 7), _fill(const Color(0xFFF1F5F9)));
        c.drawRRect(hocicoL, _stroke(const Color(0xFF1E293B), 2.0));
        c.drawCircle(const Offset(63, 39), 14.5, _stroke(const Color(0xFF1E293B), 2.1));
        // Oreja delantera con interior rosado
        final orejaDelL = Path()
          ..moveTo(60, 29)
          ..lineTo(65, 13)
          ..lineTo(72, 29)
          ..close();
        c.drawPath(orejaDelL, _fill(const Color(0xFF64748B)));
        c.drawPath(orejaDelL, _stroke(const Color(0xFF1E293B), 1.9));
        final orejaIntL = Path()
          ..moveTo(62, 27)
          ..lineTo(65, 17)
          ..lineTo(69, 27)
          ..close();
        c.drawPath(orejaIntL, _fill(const Color(0xFFFDA4AF)));
        _ojo(c, 68, 35, 2.8);
        c.drawCircle(const Offset(87, 38), 3.0, _fill(const Color(0xFF0F172A)));
        break;

      case 'lince-huella':
      case 'lince-cazador':
        // Lince ibérico detallado: pelaje ocre moteado, patillas blancas y pinceles negros en las orejas
        _sombraSuelo(c, 50, 87, 31, 6.5);
        // Cola corta con borla negra característica del lince
        final colaLince = RRect.fromRectAndRadius(
          const Rect.fromLTWH(10, 50, 14, 7),
          const Radius.circular(3.5),
        );
        c.drawRRect(colaLince, _fill(const Color(0xFFD97706)));
        c.drawCircle(const Offset(12, 53.5), 4.0, _fill(const Color(0xFF0F172A)));
        c.drawRRect(colaLince, _stroke(const Color(0xFF451A03), 1.9));
        // Patas traseras
        for (final x in [24.0, 52.0]) {
          final pTras = RRect.fromRectAndRadius(Rect.fromLTWH(x, 62, 7.5, 23), const Radius.circular(3.5));
          c.drawRRect(pTras, _fill(const Color(0xFFB45309)));
          c.drawRRect(pTras, _stroke(const Color(0xFF451A03), 1.9));
        }
        // Cuerpo ocre leonado con vientre crema y motas oscuras
        final cuerpoLince = RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 45, 45, 23),
          const Radius.circular(11.5),
        );
        c.drawRRect(
          cuerpoLince,
          _grad(const Rect.fromLTWH(20, 45, 45, 23), const Color(0xFFFBBF24), const Color(0xFFD97706)),
        );
        c.drawOval(const Rect.fromLTWH(27, 57, 31, 10), _fill(const Color(0xFFFFFBEB)));
        c.drawRRect(cuerpoLince, _stroke(const Color(0xFF451A03), 2.1));
        for (final m in [
          const Offset(30, 52),
          const Offset(38, 49),
          const Offset(44, 54),
          const Offset(52, 50),
          const Offset(35, 57),
        ]) {
          c.drawCircle(m, 2.2, _fill(const Color(0xFF451A03)));
        }
        // Patas delanteras
        for (final x in [31.0, 58.0]) {
          final pDel = RRect.fromRectAndRadius(Rect.fromLTWH(x, 63, 7.5, 23), const Radius.circular(3.5));
          c.drawRRect(pDel, _fill(const Color(0xFFF59E0B)));
          c.drawRRect(pDel, _stroke(const Color(0xFF451A03), 1.9));
        }
        // Cabeza con patillas blancas (barba de lince) y pinceles negros
        final patillas = Path()
          ..moveTo(52, 42)
          ..lineTo(47, 54)
          ..lineTo(60, 52)
          ..lineTo(75, 54)
          ..lineTo(78, 42)
          ..close();
        c.drawPath(patillas, _fill(const Color(0xFFFFFBEB)));
        c.drawPath(patillas, _stroke(const Color(0xFF451A03), 1.8));
        c.drawCircle(
          const Offset(64, 39),
          14.0,
          _grad(const Rect.fromLTWH(50, 25, 28, 28), const Color(0xFFFBBF24), const Color(0xFFD97706)),
        );
        c.drawCircle(const Offset(64, 39), 14.0, _stroke(const Color(0xFF451A03), 2.1));
        for (final ox in [56.0, 68.0]) {
          final oreja = Path()
            ..moveTo(ox - 4, 28)
            ..lineTo(ox, 16)
            ..lineTo(ox + 5, 28)
            ..close();
          c.drawPath(oreja, _fill(const Color(0xFFD97706)));
          c.drawPath(oreja, _stroke(const Color(0xFF451A03), 1.9));
          c.drawLine(Offset(ox, 16), Offset(ox + 1, 8), _stroke(const Color(0xFF0F172A), 2.8));
        }
        _ojo(c, 67, 37, 2.8);
        c.drawCircle(const Offset(75, 42), 2.6, _fill(const Color(0xFFBE123C)));
        break;

      case 'huella-pezuna':
        // Emblema detallado de pezuña hendida simétrica
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF92400E), 2.2));
        final pezIzq = Path()
          ..moveTo(46, 20)
          ..quadraticBezierTo(22, 36, 28, 76)
          ..quadraticBezierTo(38, 78, 46, 70)
          ..close();
        final pezDer = Path()
          ..moveTo(54, 20)
          ..quadraticBezierTo(78, 36, 72, 76)
          ..quadraticBezierTo(62, 78, 54, 70)
          ..close();
        c.drawPath(
          pezIzq,
          _grad(const Rect.fromLTWH(24, 20, 24, 58), const Color(0xFF57534E), const Color(0xFF292524)),
        );
        c.drawPath(
          pezDer,
          _grad(const Rect.fromLTWH(52, 20, 24, 58), const Color(0xFF57534E), const Color(0xFF292524)),
        );
        c.drawPath(pezIzq, _stroke(const Color(0xFF0F172A), 2.2));
        c.drawPath(pezDer, _stroke(const Color(0xFF0F172A), 2.2));
        break;

      case 'huella-palmeada':
        // Emblema detallado de huella palmeada con membrana interdigital
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF0284C7), 2.2));
        final memb = Path()
          ..moveTo(50, 78)
          ..lineTo(22, 42)
          ..quadraticBezierTo(34, 34, 38, 27)
          ..quadraticBezierTo(45, 32, 50, 23)
          ..quadraticBezierTo(55, 32, 62, 27)
          ..quadraticBezierTo(66, 34, 78, 42)
          ..close();
        c.drawPath(memb, _fill(const Color(0xFF38BDF8).withValues(alpha: 0.65)));
        c.drawPath(memb, _stroke(const Color(0xFF0284C7), 2.2));
        for (final dest in [
          const Offset(22, 42),
          const Offset(38, 27),
          const Offset(50, 23),
          const Offset(62, 27),
          const Offset(78, 42),
        ]) {
          c.drawLine(const Offset(50, 76), dest, _stroke(const Color(0xFF78350F), 3.2));
          c.drawCircle(dest, 3.6, _fill(const Color(0xFF451A03)));
        }
        break;

      case 'nutria-huella':
        // Nutria de río detallada con cuerpo hidrodinámico, garganta crema y bigotes sensoriales
        _sombraSuelo(c, 50, 85, 34, 6.0);
        // Ondas suaves de río
        c.drawArc(const Rect.fromLTWH(12, 68, 76, 14), 0, math.pi, false, _stroke(const Color(0xFF38BDF8), 3.0));
        final colaNutria = Path()
          ..moveTo(24, 56)
          ..quadraticBezierTo(6, 60, 8, 72)
          ..quadraticBezierTo(20, 68, 28, 61)
          ..close();
        c.drawPath(colaNutria, _fill(const Color(0xFF78350F)));
        c.drawPath(colaNutria, _stroke(const Color(0xFF451A03), 2.0));
        final cuerpoNutria = RRect.fromRectAndRadius(
          const Rect.fromLTWH(21, 45, 48, 22),
          const Radius.circular(11),
        );
        c.drawRRect(
          cuerpoNutria,
          _grad(const Rect.fromLTWH(21, 45, 48, 22), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(30, 55, 36, 11), _fill(const Color(0xFFFEF3C7)));
        c.drawRRect(cuerpoNutria, _stroke(const Color(0xFF451A03), 2.1));
        c.drawCircle(
          const Offset(69, 41),
          12.5,
          _grad(const Rect.fromLTWH(56, 28, 26, 26), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawCircle(const Offset(69, 41), 12.5, _stroke(const Color(0xFF451A03), 2.1));
        c.drawCircle(const Offset(61, 31), 4.2, _fill(const Color(0xFF78350F)));
        c.drawCircle(const Offset(61, 31), 4.2, _stroke(const Color(0xFF451A03), 1.8));
        c.drawOval(const Rect.fromLTWH(69, 41, 15, 9), _fill(const Color(0xFFFFFBEB)));
        c.drawOval(const Rect.fromLTWH(69, 41, 15, 9), _stroke(const Color(0xFF451A03), 1.7));
        c.drawCircle(const Offset(81, 43), 2.5, _fill(const Color(0xFF0F172A)));
        c.drawLine(const Offset(75, 46), const Offset(88, 44), _stroke(const Color(0xFF475569), 1.6));
        c.drawLine(const Offset(75, 48), const Offset(88, 50), _stroke(const Color(0xFF475569), 1.6));
        _ojo(c, 71, 37, 2.5);
        break;

      // ==================== ANIMALES DIETA ====================
      case 'ciervo-bellota':
        // Ciervo ibérico detallado con pelaje leonado, pecho crema y gran cornamenta ramificada
        _sombraSuelo(c, 50, 88, 31, 6.5);
        // Patas traseras
        for (final x in [24.0, 50.0]) {
          final p = RRect.fromRectAndRadius(Rect.fromLTWH(x, 62, 6.5, 25), const Radius.circular(3));
          c.drawRRect(p, _fill(const Color(0xFF78350F)));
          c.drawRRect(p, _stroke(const Color(0xFF451A03), 1.9));
        }
        // Cuerpo y cuello esbelto
        final cuerpoCiervo = RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 46, 44, 22),
          const Radius.circular(11),
        );
        c.drawRRect(
          cuerpoCiervo,
          _grad(const Rect.fromLTWH(20, 46, 44, 22), const Color(0xFFD97706), const Color(0xFF92400E)),
        );
        c.drawOval(const Rect.fromLTWH(26, 57, 32, 10), _fill(const Color(0xFFFEF3C7)));
        c.drawRRect(cuerpoCiervo, _stroke(const Color(0xFF451A03), 2.1));
        // Patas delanteras
        for (final x in [31.0, 56.0]) {
          final p = RRect.fromRectAndRadius(Rect.fromLTWH(x, 63, 6.5, 25), const Radius.circular(3));
          c.drawRRect(p, _fill(const Color(0xFFB45309)));
          c.drawRRect(p, _stroke(const Color(0xFF451A03), 1.9));
        }
        // Cuernas ramificadas
        final cuerna = _stroke(const Color(0xFF78350F), 3.0);
        c.drawLine(const Offset(60, 32), const Offset(48, 10), cuerna);
        c.drawLine(const Offset(54, 21), const Offset(41, 17), cuerna);
        c.drawLine(const Offset(57, 26), const Offset(63, 12), cuerna);
        c.drawLine(const Offset(66, 32), const Offset(72, 12), cuerna);
        c.drawLine(const Offset(69, 22), const Offset(79, 17), cuerna);
        // Cabeza
        final cabCiervo = RRect.fromRectAndRadius(
          const Rect.fromLTWH(54, 31, 26, 17),
          const Radius.circular(8.5),
        );
        c.drawRRect(
          cabCiervo,
          _grad(const Rect.fromLTWH(54, 31, 26, 17), const Color(0xFFD97706), const Color(0xFF92400E)),
        );
        c.drawRRect(cabCiervo, _stroke(const Color(0xFF451A03), 2.1));
        c.drawOval(const Rect.fromLTWH(49, 31, 10, 6), _fill(const Color(0xFFB45309)));
        c.drawOval(const Rect.fromLTWH(49, 31, 10, 6), _stroke(const Color(0xFF451A03), 1.7));
        _ojo(c, 66, 38, 2.7);
        _moflete(c, 65, 43, 3.5, 2.2);
        c.drawCircle(const Offset(78, 39), 3.0, _fill(const Color(0xFF1E293B)));
        break;

      case 'conejo-prado':
        _delegarAnimalDetallado(c, 'conejo');
        break;

      case 'jabali-bosque':
        // Jabalí ibérico detallado con crin dorsal erizada, pelaje pardo oscuro y jeta rosada
        _sombraSuelo(c, 50, 88, 32, 6.5);
        for (final x in [24.0, 52.0]) {
          final p = RRect.fromRectAndRadius(Rect.fromLTWH(x, 65, 7.5, 22), const Radius.circular(3.5));
          c.drawRRect(p, _fill(const Color(0xFF44403C)));
          c.drawRRect(p, _stroke(const Color(0xFF1C1917), 1.9));
        }
        // Crin dorsal oscura
        final crinJ = Path()
          ..moveTo(22, 46)
          ..lineTo(30, 36)
          ..lineTo(36, 43)
          ..lineTo(44, 34)
          ..lineTo(50, 42)
          ..lineTo(58, 35)
          ..lineTo(64, 44)
          ..close();
        c.drawPath(crinJ, _fill(const Color(0xFF292524)));
        c.drawPath(crinJ, _stroke(const Color(0xFF1C1917), 1.8));
        // Cuerpo robusto
        final cuerpoJab = RRect.fromRectAndRadius(
          const Rect.fromLTWH(16, 42, 52, 30),
          const Radius.circular(15),
        );
        c.drawRRect(
          cuerpoJab,
          _grad(const Rect.fromLTWH(16, 42, 52, 30), const Color(0xFF78716C), const Color(0xFF44403C)),
        );
        c.drawRRect(cuerpoJab, _stroke(const Color(0xFF1C1917), 2.1));
        for (final x in [31.0, 58.0]) {
          final p = RRect.fromRectAndRadius(Rect.fromLTWH(x, 66, 7.5, 22), const Radius.circular(3.5));
          c.drawRRect(p, _fill(const Color(0xFF57534E)));
          c.drawRRect(p, _stroke(const Color(0xFF1C1917), 1.9));
        }
        // Cabeza cónica y jeta
        final cabJab = Path()
          ..moveTo(54, 40)
          ..lineTo(84, 47)
          ..lineTo(84, 62)
          ..lineTo(54, 68)
          ..close();
        c.drawPath(
          cabJab,
          _grad(const Rect.fromLTWH(54, 40, 30, 28), const Color(0xFF78716C), const Color(0xFF44403C)),
        );
        c.drawPath(cabJab, _stroke(const Color(0xFF1C1917), 2.1));
        c.drawOval(const Rect.fromLTWH(79, 46, 8, 16), _fill(const Color(0xFFFDA4AF)));
        c.drawOval(const Rect.fromLTWH(79, 46, 8, 16), _stroke(const Color(0xFF9F1239), 1.8));
        c.drawCircle(const Offset(83, 51), 1.4, _fill(const Color(0xFF881337)));
        c.drawCircle(const Offset(83, 57), 1.4, _fill(const Color(0xFF881337)));
        // Pequeño colmillo natural discreto
        final colmJ = Path()
          ..moveTo(73, 61)
          ..quadraticBezierTo(78, 53, 75, 48)
          ..quadraticBezierTo(71, 54, 69, 60)
          ..close();
        c.drawPath(colmJ, _fill(const Color(0xFFFFFBEB)));
        c.drawPath(colmJ, _stroke(const Color(0xFF44403C), 1.6));
        _ojo(c, 66, 49, 2.7);
        break;

      case 'oso-pardo':
        _delegarAnimalDetallado(c, 'oso');
        break;

      case 'aguila-real':
        _delegarAnimalDetallado(c, 'aguila');
        break;

      case 'buho-nocturno':
        // Búho real detallado sobre rama con disco facial, penachos, plumaje moteado y grandes ojos ámbar
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(16, 80, 68, 8), const Radius.circular(4)),
          _grad(const Rect.fromLTWH(16, 80, 68, 8), const Color(0xFF92400E), const Color(0xFF451A03)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(16, 80, 68, 8), const Radius.circular(4)),
          _stroke(const Color(0xFF292524), 2.0),
        );
        c.drawOval(
          const Rect.fromLTWH(27, 38, 46, 44),
          _grad(const Rect.fromLTWH(27, 38, 46, 44), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(34, 46, 32, 32), _fill(const Color(0xFFFEF3C7)));
        for (final p in [
          const Offset(42, 54),
          const Offset(50, 54),
          const Offset(58, 54),
          const Offset(45, 63),
          const Offset(55, 63),
        ]) {
          c.drawArc(
            Rect.fromCenter(center: p, width: 6, height: 5),
            0,
            math.pi,
            false,
            _stroke(const Color(0xFF78350F), 1.8),
          );
        }
        c.drawOval(const Rect.fromLTWH(27, 38, 46, 44), _stroke(const Color(0xFF451A03), 2.1));
        // Cabeza y penachos auriculares
        final penIzq = Path()
          ..moveTo(33, 24)
          ..lineTo(24, 11)
          ..lineTo(42, 20)
          ..close();
        final penDer = Path()
          ..moveTo(67, 24)
          ..lineTo(76, 11)
          ..lineTo(58, 20)
          ..close();
        c.drawPath(penIzq, _fill(const Color(0xFF78350F)));
        c.drawPath(penDer, _fill(const Color(0xFF78350F)));
        c.drawPath(penIzq, _stroke(const Color(0xFF451A03), 1.9));
        c.drawPath(penDer, _stroke(const Color(0xFF451A03), 1.9));
        c.drawCircle(
          const Offset(50, 34),
          19,
          _grad(const Rect.fromLTWH(31, 15, 38, 38), const Color(0xFFD97706), const Color(0xFF92400E)),
        );
        c.drawCircle(const Offset(50, 34), 19, _stroke(const Color(0xFF451A03), 2.1));
        c.drawCircle(const Offset(42, 34), 8.2, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(58, 34), 8.2, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(42, 34), 6.5, _fill(const Color(0xFFFACC15)));
        c.drawCircle(const Offset(58, 34), 6.5, _fill(const Color(0xFFFACC15)));
        c.drawCircle(const Offset(42, 34), 6.5, _stroke(const Color(0xFF78350F), 1.5));
        c.drawCircle(const Offset(58, 34), 6.5, _stroke(const Color(0xFF78350F), 1.5));
        c.drawCircle(const Offset(42, 34), 3.3, _fill(const Color(0xFF0F172A)));
        c.drawCircle(const Offset(58, 34), 3.3, _fill(const Color(0xFF0F172A)));
        c.drawCircle(const Offset(40.5, 32.5), 1.3, _fill(Colors.white));
        c.drawCircle(const Offset(56.5, 32.5), 1.3, _fill(Colors.white));
        final picoBuho = Path()
          ..moveTo(47, 39)
          ..lineTo(53, 39)
          ..lineTo(50, 47)
          ..close();
        c.drawPath(picoBuho, _fill(const Color(0xFF334155)));
        c.drawPath(picoBuho, _stroke(const Color(0xFF0F172A), 1.6));
        break;

      case 'garza-charca':
        // Garza real detallada: plumaje gris azulado, penacho nucal negro, cuello en S y patas largas en el agua
        c.drawArc(const Rect.fromLTWH(16, 80, 68, 12), 0, math.pi, false, _stroke(const Color(0xFF38BDF8), 2.8));
        c.drawLine(const Offset(39, 64), const Offset(39, 88), _stroke(const Color(0xFFD97706), 2.8));
        c.drawLine(const Offset(48, 64), const Offset(50, 88), _stroke(const Color(0xFFD97706), 2.8));
        final cuelloG = Path()
          ..moveTo(52, 52)
          ..quadraticBezierTo(66, 36, 54, 22);
        c.drawPath(cuelloG, _stroke(const Color(0xFFCBD5E1), 7.5));
        c.drawPath(cuelloG, _stroke(const Color(0xFF475569), 2.0));
        c.drawOval(
          const Rect.fromLTWH(23, 45, 38, 22),
          _grad(const Rect.fromLTWH(23, 45, 38, 22), const Color(0xFFCBD5E1), const Color(0xFF64748B)),
        );
        c.drawOval(const Rect.fromLTWH(23, 45, 38, 22), _stroke(const Color(0xFF334155), 2.1));
        c.drawOval(const Rect.fromLTWH(28, 49, 26, 13), _fill(const Color(0xFF94A3B8)));
        c.drawOval(const Rect.fromLTWH(28, 49, 26, 13), _stroke(const Color(0xFF334155), 1.7));
        c.drawCircle(const Offset(55, 20), 7.5, _fill(const Color(0xFFF8FAFC)));
        c.drawCircle(const Offset(55, 20), 7.5, _stroke(const Color(0xFF334155), 2.0));
        c.drawLine(const Offset(49, 16), const Offset(38, 19), _stroke(const Color(0xFF0F172A), 2.6));
        final picoGarza = Path()
          ..moveTo(61, 17)
          ..lineTo(88, 21)
          ..lineTo(61, 24)
          ..close();
        c.drawPath(picoGarza, _fill(const Color(0xFFF59E0B)));
        c.drawPath(picoGarza, _stroke(const Color(0xFF92400E), 1.8));
        _ojo(c, 56, 19, 2.2);
        break;

      case 'pato-cuchara':
        // Pato cuchara detallado nadando: cabeza verde tornasolada, pecho blanco, flanco castaño y pico espatulado
        c.drawArc(const Rect.fromLTWH(12, 68, 76, 14), 0, math.pi, false, _stroke(const Color(0xFF38BDF8), 3.0));
        final cuerpoPato = Path()
          ..moveTo(16, 56)
          ..quadraticBezierTo(20, 44, 46, 46)
          ..quadraticBezierTo(64, 46, 64, 60)
          ..quadraticBezierTo(42, 70, 16, 56)
          ..close();
        c.drawPath(
          cuerpoPato,
          _grad(const Rect.fromLTWH(16, 44, 48, 26), const Color(0xFFF8FAFC), const Color(0xFFCBD5E1)),
        );
        c.drawPath(cuerpoPato, _stroke(const Color(0xFF334155), 2.1));
        c.drawOval(
          const Rect.fromLTWH(26, 51, 28, 14),
          _grad(const Rect.fromLTWH(26, 51, 28, 14), const Color(0xFFD97706), const Color(0xFF92400E)),
        );
        c.drawOval(const Rect.fromLTWH(26, 51, 28, 14), _stroke(const Color(0xFF451A03), 1.8));
        c.drawCircle(
          const Offset(59, 36),
          11.5,
          _grad(const Rect.fromLTWH(47, 24, 24, 24), const Color(0xFF22C55E), const Color(0xFF14532D)),
        );
        c.drawCircle(const Offset(59, 36), 11.5, _stroke(const Color(0xFF052E16), 2.1));
        final picoEspatula = Path()
          ..moveTo(68, 33)
          ..lineTo(87, 31)
          ..quadraticBezierTo(93, 37, 87, 43)
          ..lineTo(68, 40)
          ..close();
        c.drawPath(picoEspatula, _fill(const Color(0xFF475569)));
        c.drawPath(picoEspatula, _stroke(const Color(0xFF1E293B), 1.9));
        _ojo(c, 61, 34, 2.4);
        break;

      case 'ardilla-pinar':
        // Ardilla roja detallada con gran cola esponjosa en S, pecho crema y pinceles en las orejas (sin piña spoiler)
        _sombraSuelo(c, 50, 86, 26, 6.0);
        final colaArd = Path()
          ..moveTo(34, 68)
          ..quadraticBezierTo(8, 64, 14, 34)
          ..quadraticBezierTo(18, 14, 34, 20)
          ..quadraticBezierTo(44, 26, 36, 48)
          ..close();
        c.drawPath(
          colaArd,
          _grad(const Rect.fromLTWH(10, 14, 34, 56), const Color(0xFFFB923C), const Color(0xFFC2410C)),
        );
        c.drawPath(colaArd, _stroke(const Color(0xFF7C2D12), 2.1));
        c.drawOval(
          const Rect.fromLTWH(33, 44, 28, 34),
          _grad(const Rect.fromLTWH(33, 44, 28, 34), const Color(0xFFF97316), const Color(0xFFC2410C)),
        );
        c.drawOval(const Rect.fromLTWH(44, 49, 15, 24), _fill(const Color(0xFFFFFBEB)));
        c.drawOval(const Rect.fromLTWH(33, 44, 28, 34), _stroke(const Color(0xFF7C2D12), 2.1));
        c.drawOval(const Rect.fromLTWH(36, 72, 16, 9), _fill(const Color(0xFFEA580C)));
        c.drawOval(const Rect.fromLTWH(36, 72, 16, 9), _stroke(const Color(0xFF7C2D12), 1.9));
        c.drawCircle(
          const Offset(53, 35),
          12.0,
          _grad(const Rect.fromLTWH(41, 23, 24, 24), const Color(0xFFFB923C), const Color(0xFFEA580C)),
        );
        c.drawCircle(const Offset(53, 35), 12.0, _stroke(const Color(0xFF7C2D12), 2.1));
        final orejaArd = Path()
          ..moveTo(47, 25)
          ..lineTo(49, 13)
          ..lineTo(55, 24)
          ..close();
        c.drawPath(orejaArd, _fill(const Color(0xFFEA580C)));
        c.drawPath(orejaArd, _stroke(const Color(0xFF7C2D12), 1.8));
        _ojo(c, 57, 33, 2.6);
        _moflete(c, 56, 38, 3.2, 2.0);
        c.drawCircle(const Offset(64, 36), 2.3, _fill(const Color(0xFF1E293B)));
        break;

      case 'castor-ribera':
        // Castor europeo detallado con cola plana reticulada, pelaje castaño brillante y hocico rechoncho
        _sombraSuelo(c, 50, 86, 33, 6.5);
        // Cola plana escamosa característica
        final colaCastor = RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 56, 26, 13),
          const Radius.circular(6.5),
        );
        c.drawRRect(
          colaCastor,
          _grad(const Rect.fromLTWH(8, 56, 26, 13), const Color(0xFF57534E), const Color(0xFF292524)),
        );
        c.drawRRect(colaCastor, _stroke(const Color(0xFF1C1917), 2.0));
        c.drawLine(const Offset(14, 58), const Offset(26, 67), _stroke(const Color(0xFF1C1917), 1.3));
        c.drawLine(const Offset(20, 58), const Offset(30, 67), _stroke(const Color(0xFF1C1917), 1.3));
        // Cuerpo redondeado
        c.drawOval(
          const Rect.fromLTWH(28, 40, 42, 36),
          _grad(const Rect.fromLTWH(28, 40, 42, 36), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(38, 50, 26, 22), _fill(const Color(0xFFFEF3C7).withValues(alpha: 0.45)));
        c.drawOval(const Rect.fromLTWH(28, 40, 42, 36), _stroke(const Color(0xFF451A03), 2.1));
        // Cabeza
        c.drawCircle(
          const Offset(65, 42),
          13.5,
          _grad(const Rect.fromLTWH(51, 28, 28, 28), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawCircle(const Offset(65, 42), 13.5, _stroke(const Color(0xFF451A03), 2.1));
        c.drawCircle(const Offset(58, 31), 4.0, _fill(const Color(0xFF78350F)));
        c.drawCircle(const Offset(58, 31), 4.0, _stroke(const Color(0xFF451A03), 1.8));
        c.drawOval(const Rect.fromLTWH(67, 42, 13, 9), _fill(const Color(0xFFFDE68A)));
        c.drawOval(const Rect.fromLTWH(67, 42, 13, 9), _stroke(const Color(0xFF451A03), 1.7));
        c.drawCircle(const Offset(78, 44), 2.6, _fill(const Color(0xFF1E293B)));
        _ojo(c, 67, 38, 2.5);
        break;

      case 'cabra-montes':
        // Cabra montés detallada sobre risco de montaña con grandes cuernos anillados en arco
        final risco = Path()
          ..moveTo(14, 90)
          ..lineTo(28, 68)
          ..lineTo(74, 68)
          ..lineTo(86, 90)
          ..close();
        c.drawPath(
          risco,
          _grad(const Rect.fromLTWH(14, 68, 72, 22), const Color(0xFFCBD5E1), const Color(0xFF64748B)),
        );
        c.drawPath(risco, _stroke(const Color(0xFF334155), 2.1));
        for (final x in [33.0, 56.0]) {
          c.drawLine(Offset(x, 58), Offset(x, 71), _stroke(const Color(0xFF451A03), 4.2));
        }
        final cuerpoCabra = RRect.fromRectAndRadius(
          const Rect.fromLTWH(28, 41, 38, 20),
          const Radius.circular(10),
        );
        c.drawRRect(
          cuerpoCabra,
          _grad(const Rect.fromLTWH(28, 41, 38, 20), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(34, 52, 26, 8), _fill(const Color(0xFFFEF3C7)));
        c.drawRRect(cuerpoCabra, _stroke(const Color(0xFF451A03), 2.1));
        final cuernoC = Path()
          ..moveTo(61, 27)
          ..quadraticBezierTo(42, 6, 24, 22);
        c.drawPath(cuernoC, _stroke(const Color(0xFF292524), 4.5));
        c.drawCircle(
          const Offset(64, 34),
          10.5,
          _grad(const Rect.fromLTWH(53, 23, 22, 22), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawCircle(const Offset(64, 34), 10.5, _stroke(const Color(0xFF451A03), 2.0));
        _ojo(c, 67, 33, 2.4);
        break;

      case 'caballo-galope':
      case 'caballo-prado':
        // Caballo alazán anatómico: silueta orgánica en curvas Bézier, patas en 2 planos con articulaciones y cascos, crin al viento y lucero blanco
        _sombraSuelo(c, 50, 89, 34, 6.0);
        // Cola larga y ondulada en mechas
        final colaCab = Path()
          ..moveTo(22, 47)
          ..cubicTo(10, 46, 5, 58, 8, 75)
          ..cubicTo(13, 73, 17, 63, 20, 56)
          ..cubicTo(16, 64, 15, 72, 19, 77)
          ..cubicTo(24, 68, 25, 56, 24, 50)
          ..close();
        c.drawPath(
          colaCab,
          _grad(const Rect.fromLTWH(5, 46, 20, 32), const Color(0xFF451A03), const Color(0xFF1C1917)),
        );
        c.drawPath(colaCab, _stroke(const Color(0xFF0F172A), 2.0));
        // Patas traseras (plano lejano, tono más oscuro)
        for (final x in [24.0, 53.0]) {
          final pataLejana = Path()
            ..moveTo(x - 3, 58)
            ..quadraticBezierTo(x - 5, 70, x - 3, 83)
            ..lineTo(x + 4, 83)
            ..quadraticBezierTo(x + 3, 70, x + 5, 58)
            ..close();
          c.drawPath(pataLejana, _fill(const Color(0xFF78350F)));
          c.drawPath(pataLejana, _stroke(const Color(0xFF451A03), 1.9));
          final cascoLej = RRect.fromRectAndRadius(Rect.fromLTWH(x - 4, 82, 8.5, 5.0), const Radius.circular(2));
          c.drawRRect(cascoLej, _fill(const Color(0xFF1C1917)));
          c.drawRRect(cascoLej, _stroke(const Color(0xFF0F172A), 1.5));
        }
        // Cuerpo musculoso unido orgánicamente al cuello esbelto
        final cuerpoCab = Path()
          ..moveTo(20, 52)
          ..cubicTo(18, 42, 30, 41, 44, 43)
          ..cubicTo(52, 44, 57, 34, 62, 20)
          ..lineTo(70, 21)
          ..cubicTo(72, 34, 69, 48, 65, 58)
          ..cubicTo(56, 65, 34, 65, 22, 60)
          ..close();
        c.drawPath(
          cuerpoCab,
          _grad(const Rect.fromLTWH(18, 20, 54, 46), const Color(0xFFEA580C), const Color(0xFF9A3412)),
        );
        // Brillo dorsal y vientre sombreado
        final brilloDorso = Path()
          ..moveTo(25, 46)
          ..quadraticBezierTo(40, 44, 54, 46)
          ..quadraticBezierTo(40, 50, 25, 49)
          ..close();
        c.drawPath(brilloDorso, _fill(const Color(0xFFFDBA74).withValues(alpha: 0.45)));
        c.drawPath(cuerpoCab, _stroke(const Color(0xFF451A03), 2.2));
        // Patas delanteras (primer plano con cuartilla blanca y casco)
        for (final x in [31.0, 60.0]) {
          final pataCercana = Path()
            ..moveTo(x - 3.5, 58)
            ..quadraticBezierTo(x - 2, 71, x - 3, 84)
            ..lineTo(x + 4.5, 84)
            ..quadraticBezierTo(x + 4, 71, x + 5.5, 58)
            ..close();
          c.drawPath(
            pataCercana,
            _grad(Rect.fromLTWH(x - 4, 58, 10, 26), const Color(0xFFD97706), const Color(0xFF92400E)),
          );
          c.drawRect(Rect.fromLTWH(x - 3, 78, 7.2, 6), _fill(const Color(0xFFFEF3C7)));
          c.drawPath(pataCercana, _stroke(const Color(0xFF451A03), 2.0));
          final cascoCer = RRect.fromRectAndRadius(Rect.fromLTWH(x - 3.8, 83, 8.8, 5.2), const Radius.circular(2));
          c.drawRRect(cascoCer, _fill(const Color(0xFF292524)));
          c.drawRRect(cascoCer, _stroke(const Color(0xFF0F172A), 1.6));
        }
        // Crin oscura escalonada a lo largo del cuello
        final crinCab = Path()
          ..moveTo(52, 43)
          ..quadraticBezierTo(51, 31, 61, 18)
          ..lineTo(65, 21)
          ..quadraticBezierTo(59, 33, 57, 44)
          ..close();
        c.drawPath(crinCab, _fill(const Color(0xFF292524)));
        c.drawPath(crinCab, _stroke(const Color(0xFF0F172A), 1.8));
        // Orejas erguidas
        for (final ox in [62.0, 67.0]) {
          final orejaCab = Path()
            ..moveTo(ox, 21)
            ..lineTo(ox + 2, 11)
            ..lineTo(ox + 6, 20)
            ..close();
          c.drawPath(orejaCab, _fill(const Color(0xFFB45309)));
          c.drawPath(orejaCab, _stroke(const Color(0xFF451A03), 1.8));
        }
        // Cabeza alargada con hocico aterciopelado y lucero blanco
        final cabezaCab = Path()
          ..moveTo(61, 20)
          ..quadraticBezierTo(73, 18, 84, 28)
          ..quadraticBezierTo(87, 33, 82, 37)
          ..quadraticBezierTo(73, 37, 65, 31)
          ..close();
        c.drawPath(
          cabezaCab,
          _grad(const Rect.fromLTWH(61, 18, 26, 20), const Color(0xFFEA580C), const Color(0xFF9A3412)),
        );
        final hocicoCab = Path()
          ..moveTo(77, 25)
          ..quadraticBezierTo(86, 28, 83, 36)
          ..quadraticBezierTo(78, 37, 75, 34)
          ..close();
        c.drawPath(hocicoCab, _fill(const Color(0xFFFEF3C7)));
        c.drawPath(cabezaCab, _stroke(const Color(0xFF451A03), 2.1));
        c.drawCircle(const Offset(81, 31), 1.8, _fill(const Color(0xFF1C1917)));
        _ojo(c, 69, 25, 2.6);
        break;

      // ==================== ANIMALES GRUPOS ====================
      case 'vertebrado':
      case 'grupo-vertebrado':
        // Emblema de radiografía con columna vertebral articulada, cráneo y costillas brillantes
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(10, 14, 80, 72), const Radius.circular(16)),
          _grad(const Rect.fromLTWH(10, 14, 80, 72), const Color(0xFF0F172A), const Color(0xFF1E293B)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(10, 14, 80, 72), const Radius.circular(16)),
          _stroke(const Color(0xFF38BDF8), 2.4),
        );
        c.drawLine(const Offset(18, 50), const Offset(68, 50), _stroke(const Color(0xFF38BDF8), 4.5));
        for (double x = 24; x <= 60; x += 9.0) {
          c.drawOval(
            Rect.fromCenter(center: Offset(x, 50), width: 6.5, height: 28),
            _stroke(const Color(0xFFBAE6FD), 2.2),
          );
          c.drawCircle(Offset(x, 50), 3.0, _fill(Colors.white));
        }
        c.drawOval(const Rect.fromLTWH(64, 39, 18, 22), _fill(const Color(0xFFE0F2FE)));
        c.drawOval(const Rect.fromLTWH(64, 39, 18, 22), _stroke(const Color(0xFF38BDF8), 2.0));
        c.drawCircle(const Offset(75, 47), 3.0, _fill(const Color(0xFF0F172A)));
        break;

      case 'grupo-invertebrado':
      case 'artropodo':
      case 'inv-artropodo':
        // Emblema detallado de coraza de quitina segmentada y patas articuladas con bisagras visibles
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFF7ED), const Color(0xFFFED7AA)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFEA580C), 2.2));
        for (final sign in [-1.0, 1.0]) {
          for (final dy in [-10.0, 4.0]) {
            final pArt = Path()
              ..moveTo(50 + sign * 18, 46 + dy)
              ..lineTo(50 + sign * 33, 36 + dy)
              ..lineTo(50 + sign * 38, 60 + dy);
            c.drawPath(pArt, _stroke(const Color(0xFF7C2D12), 3.6));
            c.drawCircle(Offset(50 + sign * 33, 36 + dy), 3.2, _fill(const Color(0xFFFACC15)));
            c.drawCircle(Offset(50 + sign * 33, 36 + dy), 3.2, _stroke(const Color(0xFF7C2D12), 1.5));
          }
        }
        final escudoQuitina = Path()
          ..moveTo(50, 18)
          ..quadraticBezierTo(74, 24, 70, 60)
          ..quadraticBezierTo(50, 82, 30, 60)
          ..quadraticBezierTo(26, 24, 50, 18)
          ..close();
        c.drawPath(
          escudoQuitina,
          _grad(const Rect.fromLTWH(26, 18, 48, 64), const Color(0xFFFB923C), const Color(0xFFC2410C)),
        );
        c.drawPath(escudoQuitina, _stroke(const Color(0xFF7C2D12), 2.2));
        c.drawLine(const Offset(33, 38), const Offset(67, 38), _stroke(const Color(0xFFFEF3C7), 2.2));
        c.drawLine(const Offset(31, 52), const Offset(69, 52), _stroke(const Color(0xFFFEF3C7), 2.2));
        break;

      case 'cangrejo-rio':
      case 'cangrejo-playa':
        // Cangrejo detallado con caparazón festoneado, 8 patas marchadoras articuladas, 2 grandes pinzas dentadas y ojos pedunculados
        _sombraSuelo(c, 50, 85, 36, 6.5);
        // 4 pares de patas marchadoras articuladas con rodilla marcada
        for (final sign in [-1.0, 1.0]) {
          for (int i = 0; i < 4; i++) {
            final yBase = 48.0 + i * 6.5;
            final xKnee = 50 + sign * (30 + (2 - i) * 3);
            final yKnee = yBase - 5 + i * 2;
            final xTip = 50 + sign * (40 - i * 2);
            final yTip = yBase + 11;
            final pataCang = Path()
              ..moveTo(50 + sign * 20, yBase)
              ..lineTo(xKnee, yKnee)
              ..lineTo(xTip, yTip);
            c.drawPath(pataCang, _stroke(const Color(0xFF7F1D1D), 5.2));
            c.drawPath(pataCang, _stroke(const Color(0xFFDC2626), 3.0));
            c.drawCircle(Offset(xKnee, yKnee), 2.3, _fill(const Color(0xFFFCA5A5)));
          }
        }
        // Brazos quelípedos y grandes pinzas abiertas en tenaza
        for (final sign in [-1.0, 1.0]) {
          final brazoPinza = Path()
            ..moveTo(50 + sign * 16, 42)
            ..quadraticBezierTo(50 + sign * 30, 32, 50 + sign * 26, 22);
          c.drawPath(brazoPinza, _stroke(const Color(0xFF7F1D1D), 6.5));
          c.drawPath(brazoPinza, _stroke(const Color(0xFFEF4444), 4.0));
          final pinza = Path()
            ..moveTo(50 + sign * 26, 26)
            ..cubicTo(50 + sign * 38, 22, 50 + sign * 38, 9, 50 + sign * 25, 11)
            ..lineTo(50 + sign * 27, 18)
            ..lineTo(50 + sign * 20, 13)
            ..cubicTo(50 + sign * 15, 17, 50 + sign * 18, 26, 50 + sign * 26, 26)
            ..close();
          c.drawPath(
            pinza,
            _grad(Rect.fromLTWH(50 + sign * 18 - 10, 9, 26, 18), const Color(0xFFF87171), const Color(0xFFB91C1C)),
          );
          c.drawPath(pinza, _stroke(const Color(0xFF7F1D1D), 2.0));
        }
        // Caparazón ancho esculpido con relieves branquiales
        final caparazonCang = Path()
          ..moveTo(23, 52)
          ..cubicTo(20, 36, 36, 33, 50, 34)
          ..cubicTo(64, 33, 80, 36, 77, 52)
          ..cubicTo(74, 69, 62, 74, 50, 74)
          ..cubicTo(38, 74, 26, 69, 23, 52)
          ..close();
        c.drawPath(
          caparazonCang,
          _grad(const Rect.fromLTWH(21, 33, 58, 42), const Color(0xFFFB7185), const Color(0xFFB91C1C)),
        );
        c.drawOval(
          const Rect.fromLTWH(32, 40, 22, 10),
          _fill(Colors.white.withValues(alpha: 0.25)),
        );
        c.drawPath(caparazonCang, _stroke(const Color(0xFF7F1D1D), 2.3));
        // Surcos anatómicos y sonrisa
        c.drawArc(const Rect.fromLTWH(38, 52, 24, 14), 0.2, math.pi - 0.4, false, _stroke(const Color(0xFF7F1D1D), 2.0));
        // Ojos pedunculados sobresaliendo del borde frontal
        for (final ox in [41.0, 59.0]) {
          c.drawLine(Offset(ox, 36), Offset(ox, 28), _stroke(const Color(0xFF991B1B), 3.6));
          _ojo(c, ox, 27, 3.2);
        }
        break;

      case 'escarabajo-corteza':
        // Escarabajo ciervo detallado: élitros abombados de quitina caoba, pronoto esculpido, 6 patas con tarsos y grandes mandíbulas ramificadas
        _sombraSuelo(c, 50, 86, 28, 6.0);
        // 3 pares de patas articuladas con fémur, tibia y tarso
        for (final sign in [-1.0, 1.0]) {
          for (final (y0, yKnee, yTip) in [(42.0, 34.0, 26.0), (54.0, 52.0, 58.0), (66.0, 72.0, 82.0)]) {
            final pataEsc = Path()
              ..moveTo(50 + sign * 15, y0)
              ..lineTo(50 + sign * 29, yKnee)
              ..lineTo(50 + sign * 35, yTip);
            c.drawPath(pataEsc, _stroke(const Color(0xFF1C1917), 4.2));
            c.drawPath(pataEsc, _stroke(const Color(0xFF78350F), 2.2));
            c.drawCircle(Offset(50 + sign * 29, yKnee), 2.0, _fill(const Color(0xFFD97706)));
          }
        }
        // Grandes mandíbulas de ciervo volante con puntas internas
        for (final sign in [-1.0, 1.0]) {
          final mandEsc = Path()
            ..moveTo(50 + sign * 6, 23)
            ..cubicTo(50 + sign * 20, 18, 50 + sign * 22, 8, 50 + sign * 10, 5)
            ..lineTo(50 + sign * 8, 9)
            ..lineTo(50 + sign * 13, 12)
            ..lineTo(50 + sign * 8, 15)
            ..quadraticBezierTo(50 + sign * 12, 19, 50 + sign * 4, 22)
            ..close();
          c.drawPath(
            mandEsc,
            _grad(const Rect.fromLTWH(28, 5, 44, 20), const Color(0xFF92400E), const Color(0xFF451A03)),
          );
          c.drawPath(mandEsc, _stroke(const Color(0xFF1C1917), 1.9));
          // Antena acodada
          c.drawLine(Offset(50 + sign * 10, 24), Offset(50 + sign * 22, 19), _stroke(const Color(0xFF1C1917), 2.0));
        }
        // Cabeza y pronoto torácico ancho
        final pronoto = RRect.fromRectAndRadius(
          const Rect.fromLTWH(33, 27, 34, 16),
          const Radius.circular(7),
        );
        c.drawRRect(
          pronoto,
          _grad(const Rect.fromLTWH(33, 27, 34, 16), const Color(0xFF57534E), const Color(0xFF1C1917)),
        );
        c.drawRRect(pronoto, _stroke(const Color(0xFF0F172A), 2.1));
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(38, 19, 24, 11), const Radius.circular(5)),
          _fill(const Color(0xFF292524)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(38, 19, 24, 11), const Radius.circular(5)),
          _stroke(const Color(0xFF0F172A), 2.0),
        );
        _ojo(c, 41, 24, 2.2);
        _ojo(c, 59, 24, 2.2);
        // Abdomen cubierto por élitros brillantes con escudete triangular y sutura central
        final elitro = RRect.fromRectAndCorners(
          const Rect.fromLTWH(31, 41, 38, 41),
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
        );
        c.drawRRect(
          elitro,
          _grad(const Rect.fromLTWH(31, 41, 38, 41), const Color(0xFFD97706), const Color(0xFF451A03)),
        );
        c.drawOval(
          const Rect.fromLTWH(36, 46, 10, 24),
          _fill(Colors.white.withValues(alpha: 0.25)),
        );
        c.drawRRect(elitro, _stroke(const Color(0xFF1C1917), 2.2));
        final escudete = Path()
          ..moveTo(45, 41)
          ..lineTo(55, 41)
          ..lineTo(50, 48)
          ..close();
        c.drawPath(escudete, _fill(const Color(0xFF1C1917)));
        c.drawLine(const Offset(50, 47), const Offset(50, 81), _stroke(const Color(0xFF1C1917), 2.2));
        break;

      case 'vert-ave':
        // Emblema detallado de pluma de vuelo con raquis y barbas suaves
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF0284C7), 2.2));
        final pluma = Path()
          ..moveTo(22, 76)
          ..quadraticBezierTo(28, 32, 76, 22)
          ..quadraticBezierTo(66, 66, 22, 76)
          ..close();
        c.drawPath(
          pluma,
          _grad(const Rect.fromLTWH(22, 22, 54, 54), const Color(0xFF38BDF8), const Color(0xFF0284C7)),
        );
        c.drawPath(pluma, _stroke(const Color(0xFF0C4A6E), 2.2));
        c.drawLine(const Offset(18, 80), const Offset(72, 26), _stroke(Colors.white, 3.0));
        break;

      case 'ciguena-nido':
        // Cigüeña blanca detallada: largas patas rojas zancudas, cuello esbelto en S, plumaje blanco con rémiges negras y largo pico rojo
        _sombraSuelo(c, 48, 90, 26, 5.0);
        // Patas largas rojas con articulación tibial y dedos
        for (final (xTop, xKnee, xFoot) in [(41.0, 39.0, 37.0), (50.0, 52.0, 54.0)]) {
          final pataCig = Path()
            ..moveTo(xTop, 60)
            ..lineTo(xKnee, 74)
            ..lineTo(xFoot, 88);
          c.drawPath(pataCig, _stroke(const Color(0xFFDC2626), 3.0));
          c.drawCircle(Offset(xKnee, 74), 2.0, _fill(const Color(0xFFEF4444)));
          c.drawLine(Offset(xFoot - 4, 88), Offset(xFoot + 6, 88), _stroke(const Color(0xFFDC2626), 2.4));
        }
        // Cuerpo estilizado y cuello largo en S
        final cuerpoCig = Path()
          ..moveTo(16, 54)
          ..cubicTo(20, 40, 42, 38, 56, 44)
          ..cubicTo(60, 34, 56, 24, 60, 16)
          ..cubicTo(65, 12, 72, 14, 71, 22)
          ..cubicTo(68, 30, 69, 44, 64, 56)
          ..cubicTo(52, 64, 30, 62, 16, 54)
          ..close();
        c.drawPath(
          cuerpoCig,
          _grad(const Rect.fromLTWH(16, 12, 56, 52), Colors.white, const Color(0xFFE2E8F0)),
        );
        c.drawPath(cuerpoCig, _stroke(const Color(0xFF1E293B), 2.1));
        // Ala plegada bicolor con plumas remeras negras escalonadas
        final alaCig = Path()
          ..moveTo(28, 45)
          ..cubicTo(42, 42, 54, 46, 56, 54)
          ..lineTo(14, 58)
          ..cubicTo(16, 50, 22, 46, 28, 45)
          ..close();
        c.drawPath(
          alaCig,
          _grad(const Rect.fromLTWH(14, 42, 42, 16), const Color(0xFF334155), const Color(0xFF0F172A)),
        );
        c.drawPath(alaCig, _stroke(const Color(0xFF0F172A), 1.9));
        // Pico largo cónico rojo intenso
        final picoCig = Path()
          ..moveTo(70, 17)
          ..lineTo(94, 22)
          ..lineTo(70, 24)
          ..close();
        c.drawPath(
          picoCig,
          _grad(const Rect.fromLTWH(70, 17, 24, 7), const Color(0xFFEF4444), const Color(0xFFB91C1C)),
        );
        c.drawPath(picoCig, _stroke(const Color(0xFF7F1D1D), 1.8));
        _ojo(c, 65, 19, 2.3);
        break;

      case 'gorrion-rama':
        // Gorrión común detallado posado en rama: píleo castaño, babero negro, pecho crema esponjoso, ala listada y pico granívoro cónico
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(14, 80, 72, 6.5), const Radius.circular(3.2)),
          _grad(const Rect.fromLTWH(14, 80, 72, 6.5), const Color(0xFF92400E), const Color(0xFF451A03)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(14, 80, 72, 6.5), const Radius.circular(3.2)),
          _stroke(const Color(0xFF292524), 1.9),
        );
        // Hoja brotando en la rama
        final hojaRama = Path()
          ..moveTo(22, 80)
          ..quadraticBezierTo(12, 70, 18, 62)
          ..quadraticBezierTo(28, 68, 22, 80)
          ..close();
        c.drawPath(hojaRama, _fill(const Color(0xFF22C55E)));
        c.drawPath(hojaRama, _stroke(const Color(0xFF14532D), 1.7));
        // Cola ahorquillada parda
        final colaGor = Path()
          ..moveTo(28, 56)
          ..lineTo(10, 64)
          ..lineTo(14, 71)
          ..lineTo(32, 63)
          ..close();
        c.drawPath(colaGor, _fill(const Color(0xFF78350F)));
        c.drawPath(colaGor, _stroke(const Color(0xFF451A03), 1.9));
        // Patitas agarrando la rama
        c.drawLine(const Offset(45, 68), const Offset(43, 81), _stroke(const Color(0xFFD97706), 2.8));
        c.drawLine(const Offset(55, 68), const Offset(57, 81), _stroke(const Color(0xFFD97706), 2.8));
        // Cuerpo rechoncho con vientre crema y dorso pardo cálido
        final cuerpoGor = Path()
          ..moveTo(25, 54)
          ..cubicTo(26, 40, 44, 38, 56, 42)
          ..cubicTo(68, 46, 68, 66, 52, 70)
          ..cubicTo(38, 72, 26, 66, 25, 54)
          ..close();
        c.drawPath(
          cuerpoGor,
          _grad(const Rect.fromLTWH(25, 38, 44, 34), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(38, 49, 26, 20), _fill(const Color(0xFFFEF3C7)));
        c.drawPath(cuerpoGor, _stroke(const Color(0xFF451A03), 2.1));
        // Ala plegada con franja alar blanca y plumas escalonadas
        final alaGor = Path()
          ..moveTo(31, 46)
          ..quadraticBezierTo(49, 44, 53, 57)
          ..quadraticBezierTo(38, 63, 28, 56)
          ..close();
        c.drawPath(
          alaGor,
          _grad(const Rect.fromLTWH(28, 44, 26, 19), const Color(0xFF92400E), const Color(0xFF451A03)),
        );
        c.drawLine(const Offset(34, 51), const Offset(48, 53), _stroke(const Color(0xFFFEF3C7), 2.4));
        c.drawPath(alaGor, _stroke(const Color(0xFF292524), 1.9));
        // Cabeza con píleo castaño, mejilla clara y babero negro
        c.drawCircle(
          const Offset(59, 36),
          12.5,
          _grad(const Rect.fromLTWH(46, 23, 26, 26), const Color(0xFFB45309), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(53, 35, 11, 8), _fill(const Color(0xFFF8FAFC)));
        final babero = Path()
          ..moveTo(64, 41)
          ..quadraticBezierTo(70, 48, 62, 53)
          ..quadraticBezierTo(56, 48, 64, 41)
          ..close();
        c.drawPath(babero, _fill(const Color(0xFF1E293B)));
        c.drawCircle(const Offset(59, 36), 12.5, _stroke(const Color(0xFF451A03), 2.1));
        final picoGor = Path()
          ..moveTo(69, 33)
          ..lineTo(81, 37)
          ..lineTo(69, 41)
          ..close();
        c.drawPath(picoGor, _fill(const Color(0xFF334155)));
        c.drawPath(picoGor, _stroke(const Color(0xFF0F172A), 1.8));
        _ojo(c, 62, 33, 2.5);
        break;

      case 'vert-pez':
        // Emblema detallado de escamas imbricadas, aleta caudal y arcos branquiales
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF0284C7), 2.2));
        for (final cx in [36.0, 53.0, 70.0]) {
          c.drawArc(
            Rect.fromCenter(center: Offset(cx, 40), width: 18, height: 20),
            -math.pi * 0.5,
            math.pi,
            false,
            _stroke(const Color(0xFF0369A1), 3.0),
          );
          c.drawArc(
            Rect.fromCenter(center: Offset(cx, 60), width: 18, height: 20),
            -math.pi * 0.5,
            math.pi,
            false,
            _stroke(const Color(0xFF0369A1), 3.0),
          );
        }
        c.drawArc(const Rect.fromLTWH(16, 30, 12, 40), -math.pi * 0.5, math.pi, false, _stroke(const Color(0xFFEF4444), 3.8));
        break;

      case 'sardina-banco':
      case 'atun-oceano':
        // Pez pelágico hidrodinámico: aleta caudal en media luna, dorsal falciforme, dorso azul metálico, vientre plateado, línea lateral y opérculo
        final colaPez = Path()
          ..moveTo(25, 50)
          ..cubicTo(16, 42, 10, 32, 7, 27)
          ..quadraticBezierTo(16, 44, 16, 50)
          ..quadraticBezierTo(16, 56, 7, 73)
          ..cubicTo(10, 68, 16, 58, 25, 50)
          ..close();
        c.drawPath(
          colaPez,
          _grad(const Rect.fromLTWH(7, 27, 18, 46), const Color(0xFF0284C7), const Color(0xFF0C4A6E)),
        );
        c.drawPath(colaPez, _stroke(const Color(0xFF0F172A), 2.0));
        // Aletas dorsal y ventral con radios
        final aletaDorsal = Path()
          ..moveTo(40, 36)
          ..quadraticBezierTo(45, 19, 56, 22)
          ..quadraticBezierTo(54, 30, 60, 36)
          ..close();
        c.drawPath(aletaDorsal, _fill(const Color(0xFF0284C7)));
        c.drawPath(aletaDorsal, _stroke(const Color(0xFF0F172A), 1.9));
        final aletaVentral = Path()
          ..moveTo(44, 63)
          ..lineTo(38, 74)
          ..lineTo(52, 64)
          ..close();
        c.drawPath(aletaVentral, _fill(const Color(0xFF38BDF8)));
        c.drawPath(aletaVentral, _stroke(const Color(0xFF0F172A), 1.8));
        // Cuerpo fusiforme en doble capa (dorso azul profundo + flanco plateado)
        final cuerpoPez = Path()
          ..moveTo(22, 50)
          ..cubicTo(30, 31, 64, 30, 88, 50)
          ..cubicTo(64, 70, 30, 69, 22, 50)
          ..close();
        c.drawPath(
          cuerpoPez,
          _grad(const Rect.fromLTWH(22, 32, 66, 36), const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
        );
        final vientrePez = Path()
          ..moveTo(24, 51)
          ..quadraticBezierTo(55, 47, 86, 51)
          ..cubicTo(64, 69, 32, 68, 24, 51)
          ..close();
        c.drawPath(vientrePez, _fill(const Color(0xFFF8FAFC).withValues(alpha: 0.78)));
        c.drawPath(cuerpoPez, _stroke(const Color(0xFF0C4A6E), 2.2));
        // Línea lateral, opérculo branquial y aleta pectoral
        c.drawArc(const Rect.fromLTWH(61, 38, 10, 24), math.pi * 0.5, math.pi, false, _stroke(const Color(0xFF0369A1), 2.4));
        final aletaPec = Path()
          ..moveTo(60, 53)
          ..lineTo(48, 59)
          ..lineTo(53, 50)
          ..close();
        c.drawPath(aletaPec, _fill(const Color(0xFF38BDF8)));
        c.drawPath(aletaPec, _stroke(const Color(0xFF0C4A6E), 1.7));
        _ojo(c, 75, 46, 2.8);
        break;

      case 'salmon-rio':
      case 'trucha-arroyo':
        // Salmón / trucha de río detallado: dorso verdoso moteado, franja lateral asalmonada, aleta adiposa y ondas de corriente fluvial
        c.drawArc(const Rect.fromLTWH(14, 76, 72, 10), 0, math.pi, false, _stroke(const Color(0xFF38BDF8), 2.6));
        final colaSal = Path()
          ..moveTo(24, 49)
          ..lineTo(8, 33)
          ..lineTo(14, 49)
          ..lineTo(8, 65)
          ..close();
        c.drawPath(colaSal, _fill(const Color(0xFF0F766E)));
        c.drawPath(colaSal, _stroke(const Color(0xFF134E4A), 2.0));
        final dorsalSal = Path()
          ..moveTo(42, 35)
          ..lineTo(48, 22)
          ..lineTo(58, 35)
          ..close();
        c.drawPath(dorsalSal, _fill(const Color(0xFF14B8A6)));
        c.drawPath(dorsalSal, _stroke(const Color(0xFF134E4A), 1.9));
        final cuerpoSalm = Path()
          ..moveTo(21, 49)
          ..cubicTo(30, 30, 64, 30, 88, 49)
          ..cubicTo(64, 68, 30, 68, 21, 49)
          ..close();
        c.drawPath(
          cuerpoSalm,
          _grad(const Rect.fromLTWH(21, 31, 67, 36), const Color(0xFF0D9488), const Color(0xFFFEF2F2)),
        );
        // Franja lateral asalmonada / coral y motas oscuras
        final franjaCoral = Path()
          ..moveTo(25, 49)
          ..quadraticBezierTo(55, 45, 84, 49)
          ..quadraticBezierTo(55, 54, 25, 50)
          ..close();
        c.drawPath(franjaCoral, _fill(const Color(0xFFFB7185).withValues(alpha: 0.75)));
        for (final p in [
          const Offset(36, 42),
          const Offset(46, 40),
          const Offset(56, 41),
          const Offset(65, 43),
        ]) {
          c.drawCircle(p, 1.6, _fill(const Color(0xFF134E4A)));
        }
        c.drawPath(cuerpoSalm, _stroke(const Color(0xFF134E4A), 2.2));
        c.drawArc(const Rect.fromLTWH(62, 37, 10, 24), math.pi * 0.5, math.pi, false, _stroke(const Color(0xFF0F766E), 2.4));
        _ojo(c, 75, 45, 2.7);
        break;

      case 'caballito-mar':
        // Caballito de mar detallado: coronilla, hocico tubular, placas anulares dérmicas, aleta dorsal en abanico y cola prensil en espiral
        // Aleta dorsal traslúcida con radios
        final aletaCab = Path()
          ..moveTo(39, 41)
          ..cubicTo(22, 36, 20, 56, 39, 55)
          ..close();
        c.drawPath(aletaCab, _fill(const Color(0xFFFEF08A)));
        c.drawPath(aletaCab, _stroke(const Color(0xFFB45309), 1.8));
        c.drawLine(const Offset(38, 45), const Offset(26, 44), _stroke(const Color(0xFFD97706), 1.4));
        c.drawLine(const Offset(38, 50), const Offset(26, 51), _stroke(const Color(0xFFD97706), 1.4));
        // Cuerpo curvado en S y cola prensil enrollada
        final cuerpoCabM = Path()
          ..moveTo(48, 26)
          ..cubicTo(34, 34, 32, 54, 46, 64)
          ..cubicTo(56, 72, 52, 86, 41, 86)
          ..cubicTo(32, 86, 31, 75, 39, 73)
          ..cubicTo(45, 72, 46, 78, 41, 79)
          ..cubicTo(46, 79, 47, 71, 39, 68)
          ..cubicTo(54, 62, 62, 44, 54, 29)
          ..close();
        c.drawPath(
          cuerpoCabM,
          _grad(const Rect.fromLTWH(31, 26, 31, 60), const Color(0xFFFBBF24), const Color(0xFFD97706)),
        );
        c.drawPath(cuerpoCabM, _stroke(const Color(0xFF78350F), 2.1));
        // Anillos óseos transversales en el tronco
        for (final y in [36.0, 43.0, 50.0, 57.0]) {
          c.drawLine(Offset(38, y), Offset(54, y + 1), _stroke(const Color(0xFF92400E), 1.7));
        }
        // Cabeza equina con coronilla superior y hocico tubular
        final cabHip = Path()
          ..moveTo(44, 26)
          ..lineTo(45, 13)
          ..lineTo(50, 17)
          ..lineTo(55, 12)
          ..lineTo(58, 18)
          ..lineTo(75, 20)
          ..lineTo(75, 26)
          ..lineTo(58, 27)
          ..close();
        c.drawPath(
          cabHip,
          _grad(const Rect.fromLTWH(44, 12, 31, 16), const Color(0xFFFDE047), const Color(0xFFD97706)),
        );
        c.drawPath(cabHip, _stroke(const Color(0xFF78350F), 2.0));
        _ojo(c, 53, 21, 2.3);
        break;

      case 'pulpo-roca':
        _delegarAnimalDetallado(c, 'pulpo');
        break;

      case 'mariposa-flor':
        _delegarAnimalDetallado(c, 'mariposa');
        break;

      case 'vert-mamifero-ave':
      case 'vert-mamifero':
        // Emblema detallado de mamífero/ave de sangre caliente: gota de leche materna y pelaje cálido
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFD97706), 2.2));
        final gotaLeche = Path()
          ..moveTo(36, 22)
          ..quadraticBezierTo(54, 48, 49, 68)
          ..quadraticBezierTo(36, 81, 23, 68)
          ..quadraticBezierTo(18, 48, 36, 22)
          ..close();
        c.drawPath(gotaLeche, _fill(Colors.white));
        c.drawPath(gotaLeche, _stroke(const Color(0xFFB45309), 2.3));
        for (final x in [57.0, 67.0, 76.0]) {
          c.drawLine(Offset(x, 72), Offset(x + 4, 28), _stroke(const Color(0xFF92400E), 3.4));
        }
        break;

      case 'murcielago-cueva':
      case 'murcielago-noche':
        // Murciélago detallado en vuelo: patagio festoneado con falanges alares visibles, pulgar con uña, pelaje suave, pies prensiles y grandes orejas
        for (final sign in [-1.0, 1.0]) {
          final ala = Path()
            ..moveTo(50 + sign * 10, 44)
            ..lineTo(50 + sign * 26, 26)
            ..lineTo(50 + sign * 46, 30)
            ..quadraticBezierTo(50 + sign * 40, 44, 50 + sign * 39, 56)
            ..quadraticBezierTo(50 + sign * 30, 50, 50 + sign * 25, 62)
            ..quadraticBezierTo(50 + sign * 18, 56, 50 + sign * 10, 64)
            ..close();
          c.drawPath(
            ala,
            _grad(const Rect.fromLTWH(4, 24, 92, 42), const Color(0xFF475569), const Color(0xFF1E293B)),
          );
          c.drawPath(ala, _stroke(const Color(0xFF0F172A), 2.1));
          // Huesos largos de los dedos sosteniendo la membrana de piel
          c.drawLine(Offset(50 + sign * 26, 26), Offset(50 + sign * 26, 21), _stroke(const Color(0xFFCBD5E1), 2.0));
          c.drawLine(Offset(50 + sign * 26, 26), Offset(50 + sign * 39, 55), _stroke(const Color(0xFF94A3B8), 1.8));
          c.drawLine(Offset(50 + sign * 26, 26), Offset(50 + sign * 25, 61), _stroke(const Color(0xFF94A3B8), 1.8));
          // Patitas inferiores
          c.drawLine(Offset(50 + sign * 6, 66), Offset(50 + sign * 8, 76), _stroke(const Color(0xFF334155), 2.4));
        }
        // Cuerpo peludo marrón/grisáceo con pecho afelpado
        c.drawOval(
          const Rect.fromLTWH(37, 38, 26, 31),
          _grad(const Rect.fromLTWH(37, 38, 26, 31), const Color(0xFF64748B), const Color(0xFF334155)),
        );
        c.drawOval(const Rect.fromLTWH(42, 44, 16, 18), _fill(const Color(0xFF94A3B8).withValues(alpha: 0.45)));
        c.drawOval(const Rect.fromLTWH(37, 38, 26, 31), _stroke(const Color(0xFF0F172A), 2.1));
        // Grandes orejas de ecolocalización
        for (final sign in [-1.0, 1.0]) {
          final orejaMur = Path()
            ..moveTo(50 + sign * 4, 29)
            ..quadraticBezierTo(50 + sign * 16, 12, 50 + sign * 13, 33)
            ..close();
          c.drawPath(orejaMur, _fill(const Color(0xFF334155)));
          c.drawPath(orejaMur, _stroke(const Color(0xFF0F172A), 1.9));
          c.drawOval(
            Rect.fromCenter(center: Offset(50 + sign * 9, 25), width: 4.5, height: 10),
            _fill(const Color(0xFFFDA4AF)),
          );
        }
        // Cabeza redondeada, nariz de herradura y colmillitos
        c.drawCircle(
          const Offset(50, 35),
          11.0,
          _grad(const Rect.fromLTWH(39, 24, 22, 22), const Color(0xFF64748B), const Color(0xFF334155)),
        );
        c.drawCircle(const Offset(50, 35), 11.0, _stroke(const Color(0xFF0F172A), 2.0));
        _ojo(c, 45, 34, 2.3);
        _ojo(c, 55, 34, 2.3);
        c.drawOval(const Rect.fromLTWH(47, 37, 6, 4.5), _fill(const Color(0xFFFDA4AF)));
        break;

      case 'vert-reptil-anfibio':
      case 'vert-reptil':
        // Emblema detallado de mosaico de escamas epidérmicas verdes
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFECFDF5), const Color(0xFFBBF7D0)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF16A34A), 2.2));
        for (final pos in [
          const Offset(34, 40),
          const Offset(50, 40),
          const Offset(66, 40),
          const Offset(42, 58),
          const Offset(58, 58),
        ]) {
          final escama = Path()
            ..moveTo(pos.dx, pos.dy - 11)
            ..lineTo(pos.dx + 10, pos.dy)
            ..lineTo(pos.dx, pos.dy + 11)
            ..lineTo(pos.dx - 10, pos.dy)
            ..close();
          c.drawPath(
            escama,
            _grad(Rect.fromCenter(center: pos, width: 20, height: 22), const Color(0xFF4ADE80), const Color(0xFF15803D)),
          );
          c.drawPath(escama, _stroke(const Color(0xFF14532D), 2.0));
        }
        break;

      case 'lagartija-sol':
      case 'lagartija-muro':
        // Lagartija ibérica tomando el sol sobre piedra cálida: cuerpo escamoso verde esmeralda, 4 patas con deditos largos y cola larga afilada
        // Piedra soleada de apoyo
        final rocaSol = Path()
          ..moveTo(12, 84)
          ..quadraticBezierTo(20, 66, 52, 68)
          ..quadraticBezierTo(82, 70, 88, 84)
          ..close();
        c.drawPath(
          rocaSol,
          _grad(const Rect.fromLTWH(12, 66, 76, 18), const Color(0xFFE7E5E4), const Color(0xFFA8A29E)),
        );
        c.drawPath(rocaSol, _stroke(const Color(0xFF57534E), 2.0));
        // Patas traseras y delanteras con rodilla y dedos extendidos
        for (final (x0, y0, x1, y1, x2, y2) in [
          (34.0, 58.0, 26.0, 68.0, 31.0, 76.0),
          (42.0, 52.0, 35.0, 42.0, 42.0, 38.0),
          (58.0, 55.0, 54.0, 67.0, 62.0, 74.0),
          (62.0, 47.0, 56.0, 37.0, 64.0, 34.0),
        ]) {
          final pataLag = Path()
            ..moveTo(x0, y0)
            ..lineTo(x1, y1)
            ..lineTo(x2, y2);
          c.drawPath(pataLag, _stroke(const Color(0xFF14532D), 4.4));
          c.drawPath(pataLag, _stroke(const Color(0xFF22C55E), 2.4));
        }
        // Cola larga curvada y cuerpo fusiforme escamoso
        final cuerpoLag = Path()
          ..moveTo(10, 74)
          ..cubicTo(12, 54, 24, 52, 42, 49)
          ..cubicTo(54, 47, 64, 42, 72, 39)
          ..cubicTo(72, 46, 60, 56, 44, 59)
          ..cubicTo(28, 61, 18, 62, 10, 74)
          ..close();
        c.drawPath(
          cuerpoLag,
          _grad(const Rect.fromLTWH(10, 39, 64, 36), const Color(0xFF4ADE80), const Color(0xFF15803D)),
        );
        c.drawPath(cuerpoLag, _stroke(const Color(0xFF14532D), 2.1));
        // Escamas dorsales y banda lateral ocelada
        for (final (sx, sy) in [(36.0, 53.0), (45.0, 51.0), (54.0, 49.0), (62.0, 46.0)]) {
          c.drawCircle(Offset(sx, sy), 1.8, _fill(const Color(0xFFFEF08A)));
        }
        // Cabeza triangular de reptil con placas cefálicas
        final cabLag = Path()
          ..moveTo(66, 39)
          ..quadraticBezierTo(78, 35, 88, 41)
          ..quadraticBezierTo(82, 50, 68, 49)
          ..close();
        c.drawPath(
          cabLag,
          _grad(const Rect.fromLTWH(66, 35, 22, 15), const Color(0xFF4ADE80), const Color(0xFF16A34A)),
        );
        c.drawPath(cabLag, _stroke(const Color(0xFF14532D), 2.0));
        _ojo(c, 76, 41, 2.3);
        break;

      case 'salamandra-musgo':
      case 'triton-charca':
        // Salamandra común / tritón jaspeado: piel húmeda brillante con manchas gualdas/naranjas, 4 patas sin uñas y cresta dorsal en el tritón
        _sombraSuelo(c, 50, 84, 35, 6.0);
        final esTriton = id == 'triton-charca';
        if (esTriton) {
          // Cresta dorsal ondulada característica del tritón en época acuática
          final cresta = Path()
            ..moveTo(22, 62)
            ..quadraticBezierTo(34, 40, 46, 46)
            ..quadraticBezierTo(56, 34, 66, 38)
            ..lineTo(44, 56)
            ..close();
          c.drawPath(cresta, _fill(const Color(0xFFF59E0B).withValues(alpha: 0.85)));
          c.drawPath(cresta, _stroke(const Color(0xFF78350F), 1.7));
        }
        // 4 patas anfibias articuladas
        for (final (x0, y0, x1, y1) in [
          (34.0, 58.0, 24.0, 46.0),
          (40.0, 63.0, 48.0, 77.0),
          (56.0, 45.0, 48.0, 31.0),
          (62.0, 50.0, 72.0, 65.0),
        ]) {
          c.drawLine(Offset(x0, y0), Offset(x1, y1), _stroke(const Color(0xFF0F172A), 6.0));
          c.drawLine(Offset(x0, y0), Offset(x1, y1), _stroke(const Color(0xFF334155), 3.4));
          c.drawCircle(Offset(x1, y1), 2.5, _fill(const Color(0xFFFACC15)));
        }
        // Cuerpo sinuoso en S con brillo húmedo
        final cuerpoAnf = Path()
          ..moveTo(12, 75)
          ..cubicTo(18, 60, 32, 52, 48, 46)
          ..cubicTo(58, 42, 66, 36, 72, 33)
          ..cubicTo(76, 40, 66, 50, 52, 56)
          ..cubicTo(36, 63, 24, 69, 12, 75)
          ..close();
        c.drawPath(
          cuerpoAnf,
          _grad(const Rect.fromLTWH(12, 33, 64, 42), const Color(0xFF334155), const Color(0xFF0F172A)),
        );
        c.drawPath(cuerpoAnf, _stroke(const Color(0xFF020617), 2.1));
        // Cabeza redondeada de anfibio con ojos saltones
        c.drawOval(
          const Rect.fromLTWH(64, 25, 21, 17),
          _grad(const Rect.fromLTWH(64, 25, 21, 17), const Color(0xFF334155), const Color(0xFF0F172A)),
        );
        c.drawOval(const Rect.fromLTWH(64, 25, 21, 17), _stroke(const Color(0xFF020617), 2.0));
        // Manchas amarillas intensas y línea de brillo mucoso
        for (final (mx, my, mw, mh) in [
          (25.0, 64.0, 7.0, 4.5),
          (37.0, 56.0, 8.5, 5.5),
          (50.0, 49.0, 9.0, 5.5),
          (62.0, 41.0, 8.0, 5.0),
          (70.0, 33.0, 6.5, 4.5),
        ]) {
          c.drawOval(Rect.fromCenter(center: Offset(mx, my), width: mw, height: mh), _fill(const Color(0xFFFACC15)));
        }
        c.drawLine(const Offset(30, 58), const Offset(58, 43), _stroke(Colors.white.withValues(alpha: 0.45), 1.8));
        _ojo(c, 77, 30, 2.7);
        break;

      case 'anfibio':
      case 'vert-anfibio':
        // Emblema de metamorfosis y gotas de agua sobre hoja húmeda
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFE0F2FE), const Color(0xFFBBF7D0)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF0284C7), 2.2));
        c.drawCircle(const Offset(34, 38), 9, _fill(const Color(0xFF38BDF8)));
        c.drawCircle(const Offset(34, 38), 9, _stroke(const Color(0xFF0369A1), 2.0));
        c.drawCircle(const Offset(66, 38), 9, _fill(const Color(0xFF22C55E)));
        c.drawCircle(const Offset(66, 38), 9, _stroke(const Color(0xFF15803D), 2.0));
        c.drawArc(const Rect.fromLTWH(26, 36, 48, 34), 0, math.pi, false, _stroke(const Color(0xFF0284C7), 3.5));
        break;

      case 'renacuajo-charca':
        _delegarAnimalDetallado(c, 'renacuajo');
        break;

      case 'rana-charca':
        _delegarAnimalDetallado(c, 'rana');
        break;

      case 'saltamontes-prado':
        // Saltamontes detallado con fémures traseros saltadores, tórax verde en capas y antenas
        _sombraSuelo(c, 50, 86, 32, 5.5);
        // Gran pata trasera saltadora
        final musloSalt = Path()
          ..moveTo(42, 56)
          ..lineTo(22, 26)
          ..lineTo(28, 24)
          ..lineTo(48, 54)
          ..close();
        c.drawPath(musloSalt, _fill(const Color(0xFF15803D)));
        c.drawPath(musloSalt, _stroke(const Color(0xFF052E16), 2.0));
        c.drawLine(const Offset(24, 26), const Offset(16, 78), _stroke(const Color(0xFF15803D), 3.5));
        // Patas delanteras y medias
        c.drawLine(const Offset(48, 62), const Offset(44, 80), _stroke(const Color(0xFF15803D), 3.0));
        c.drawLine(const Offset(62, 62), const Offset(66, 80), _stroke(const Color(0xFF15803D), 3.0));
        // Abdomen y ala plegada
        final cuerpoSalt = RRect.fromRectAndRadius(
          const Rect.fromLTWH(24, 44, 48, 20),
          const Radius.circular(10),
        );
        c.drawRRect(
          cuerpoSalt,
          _grad(const Rect.fromLTWH(24, 44, 48, 20), const Color(0xFF4ADE80), const Color(0xFF16A34A)),
        );
        c.drawRRect(cuerpoSalt, _stroke(const Color(0xFF052E16), 2.1));
        c.drawCircle(
          const Offset(71, 49),
          10.5,
          _grad(const Rect.fromLTWH(60, 38, 22, 22), const Color(0xFF4ADE80), const Color(0xFF15803D)),
        );
        c.drawCircle(const Offset(71, 49), 10.5, _stroke(const Color(0xFF052E16), 2.1));
        c.drawLine(const Offset(75, 40), const Offset(87, 22), _stroke(const Color(0xFF052E16), 2.2));
        c.drawLine(const Offset(78, 43), const Offset(90, 28), _stroke(const Color(0xFF052E16), 2.0));
        _ojo(c, 74, 47, 2.5);
        break;

      case 'abeja-colmena':
      case 'abeja-polen':
        // Abeja melífera anatómica: 3 regiones diferenciadas (cabeza, tórax afelpado y abdomen listado), 6 patas articuladas con cestillo de polen, 2 antenas acodadas y 4 alas venadas
        _sombraSuelo(c, 50, 86, 30, 5.5);
        // 3 pares de patas articuladas (delantera, media y trasera con corbícula)
        for (final (xBase, xKnee, xFoot) in [
          (60.0, 66.0, 62.0),
          (48.0, 46.0, 42.0),
          (37.0, 30.0, 26.0),
        ]) {
          final pataAb = Path()
            ..moveTo(xBase, 59)
            ..lineTo(xKnee, 70)
            ..lineTo(xFoot, 80);
          c.drawPath(pataAb, _stroke(const Color(0xFF1E293B), 3.0));
          c.drawCircle(Offset(xKnee, 70), 1.8, _fill(const Color(0xFFF59E0B)));
        }
        // Par de alas anteriores y posteriores translúcidas con nervaduras
        for (final (cx, cy, w, h, ang) in [
          (42.0, 27.0, 17.0, 28.0, -0.35),
          (53.0, 26.0, 20.0, 32.0, 0.15),
        ]) {
          c.save();
          c.translate(cx, cy);
          c.rotate(ang);
          final rAla = Rect.fromCenter(center: Offset.zero, width: w, height: h);
          c.drawOval(rAla, _fill(const Color(0xFFE0F2FE).withValues(alpha: 0.88)));
          c.drawOval(rAla, _stroke(const Color(0xFF0284C7), 1.8));
          c.drawLine(const Offset(0, 10), const Offset(0, -10), _stroke(const Color(0xFF38BDF8), 1.3));
          c.restore();
        }
        // Abdomen ovalado con franjas doradas y negras curvadas + aguijón discreto
        final aguijon = Path()
          ..moveTo(18, 52)
          ..lineTo(10, 54)
          ..lineTo(18, 56)
          ..close();
        c.drawPath(aguijon, _fill(const Color(0xFF0F172A)));
        final abdRect = const Rect.fromLTWH(16, 39, 34, 26);
        c.save();
        c.clipPath(Path()..addOval(abdRect));
        c.drawOval(
          abdRect,
          _grad(abdRect, const Color(0xFFFDE047), const Color(0xFFF59E0B)),
        );
        for (final x in [22.0, 32.0, 42.0]) {
          c.drawArc(
            Rect.fromLTWH(x, 36, 9, 32),
            -math.pi * 0.5,
            math.pi,
            false,
            _stroke(const Color(0xFF1E293B), 5.5),
          );
        }
        c.restore();
        c.drawOval(abdRect, _stroke(const Color(0xFF0F172A), 2.2));
        // Tórax velludo ámbar oscuro
        c.drawOval(
          const Rect.fromLTWH(45, 38, 22, 24),
          _grad(const Rect.fromLTWH(45, 38, 22, 24), const Color(0xFFD97706), const Color(0xFF78350F)),
        );
        c.drawOval(const Rect.fromLTWH(45, 38, 22, 24), _stroke(const Color(0xFF451A03), 2.1));
        // Cabeza redondeada con ojo compuesto y 2 antenas acodadas
        c.drawCircle(
          const Offset(70, 49),
          11.0,
          _grad(const Rect.fromLTWH(59, 38, 22, 22), const Color(0xFF334155), const Color(0xFF0F172A)),
        );
        c.drawCircle(const Offset(70, 49), 11.0, _stroke(const Color(0xFF020617), 2.0));
        final ant1 = Path()
          ..moveTo(73, 40)
          ..lineTo(78, 28)
          ..lineTo(86, 26);
        final ant2 = Path()
          ..moveTo(76, 43)
          ..lineTo(83, 33)
          ..lineTo(90, 32);
        c.drawPath(ant1, _stroke(const Color(0xFF0F172A), 2.2));
        c.drawPath(ant2, _stroke(const Color(0xFF0F172A), 2.2));
        _ojo(c, 73, 47, 3.0);
        _moflete(c, 71, 53, 3.2, 2.0);
        break;

      case 'arana-tela':
        // Araña de jardín detallada: hilo de seda, 8 patas articuladas (4 pares) naciendo del cefalotórax, abdomen globoso con dibujo dorsal y quelíceros
        // Hilo de seda vertical y radios sutiles de telaraña
        c.drawLine(const Offset(50, 6), const Offset(50, 32), _stroke(const Color(0xFFCBD5E1), 2.0));
        c.drawArc(const Rect.fromLTWH(20, 12, 60, 40), 0, math.pi, false, _stroke(const Color(0xFFE2E8F0), 1.5));
        _sombraSuelo(c, 50, 88, 34, 5.5);
        // 4 pares de patas articuladas (8 en total) con fémur, patela y tibia
        for (final sign in [-1.0, 1.0]) {
          for (final (yBase, xKnee, yKnee, xTip, yTip) in [
            (40.0, 24.0, 22.0, 12.0, 16.0),
            (44.0, 20.0, 36.0, 8.0, 40.0),
            (48.0, 20.0, 52.0, 9.0, 64.0),
            (52.0, 24.0, 66.0, 15.0, 82.0),
          ]) {
            final pataAr = Path()
              ..moveTo(50 + sign * 9, yBase)
              ..lineTo(50 + sign * (50 - xKnee), yKnee)
              ..lineTo(50 + sign * (50 - xTip), yTip);
            c.drawPath(pataAr, _stroke(const Color(0xFF1E293B), 3.4));
            c.drawPath(pataAr, _stroke(const Color(0xFF64748B), 1.6));
            c.drawCircle(Offset(50 + sign * (50 - xKnee), yKnee), 2.0, _fill(const Color(0xFFD97706)));
          }
        }
        // Abdomen (opistosoma) globoso con marca dorsal clara en cruz
        c.drawOval(
          const Rect.fromLTWH(33, 49, 34, 34),
          _grad(const Rect.fromLTWH(33, 49, 34, 34), const Color(0xFF475569), const Color(0xFF0F172A)),
        );
        c.drawOval(const Rect.fromLTWH(33, 49, 34, 34), _stroke(const Color(0xFF020617), 2.2));
        for (final o in [
          const Offset(50, 59),
          const Offset(50, 66),
          const Offset(44, 63),
          const Offset(56, 63),
          const Offset(50, 73),
        ]) {
          c.drawCircle(o, 2.3, _fill(const Color(0xFFFEF3C7)));
        }
        // Cefalotórax (prosoma) anterior y pedipalpos
        c.drawOval(
          const Rect.fromLTWH(39, 31, 22, 21),
          _grad(const Rect.fromLTWH(39, 31, 22, 21), const Color(0xFF334155), const Color(0xFF0F172A)),
        );
        c.drawOval(const Rect.fromLTWH(39, 31, 22, 21), _stroke(const Color(0xFF020617), 2.1));
        c.drawLine(const Offset(45, 32), const Offset(42, 25), _stroke(const Color(0xFF1E293B), 2.6));
        c.drawLine(const Offset(55, 32), const Offset(58, 25), _stroke(const Color(0xFF1E293B), 2.6));
        _ojo(c, 46, 37, 2.2);
        _ojo(c, 54, 37, 2.2);
        c.drawCircle(const Offset(42, 39), 1.3, _fill(const Color(0xFFEF4444)));
        c.drawCircle(const Offset(58, 39), 1.3, _fill(const Color(0xFFEF4444)));
        break;

      case 'inv-molusco':
        // Emblema detallado de valva marina acanalada nacarada
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFD97706), 2.2));
        final valva = Path()
          ..moveTo(50, 76)
          ..lineTo(22, 42)
          ..quadraticBezierTo(50, 18, 78, 42)
          ..close();
        c.drawPath(
          valva,
          _grad(const Rect.fromLTWH(22, 18, 56, 58), const Color(0xFFFBBF24), const Color(0xFFB45309)),
        );
        c.drawPath(valva, _stroke(const Color(0xFF78350F), 2.3));
        for (final dx in [-14.0, 0.0, 14.0]) {
          c.drawLine(const Offset(50, 74), Offset(50 + dx, 31), _stroke(const Color(0xFFFFFBEB), 2.0));
        }
        break;

      case 'caracol-huerta':
        // Caracol de huerta detallado: pie musculoso húmedo sin patas, cabeza con 4 tentáculos (2 oculares largos y 2 táctiles cortos) y concha calcárea en espiral
        _sombraSuelo(c, 50, 84, 38, 5.5);
        // Rastro plateado húmedo y pie musculoso ondulado
        final pieCar = Path()
          ..moveTo(10, 76)
          ..cubicTo(18, 68, 42, 66, 66, 66)
          ..cubicTo(74, 65, 80, 56, 86, 58)
          ..cubicTo(91, 61, 89, 76, 80, 80)
          ..cubicTo(60, 83, 24, 83, 10, 76)
          ..close();
        c.drawPath(
          pieCar,
          _grad(const Rect.fromLTWH(10, 56, 80, 27), const Color(0xFFBEF264), const Color(0xFF65A30D)),
        );
        c.drawPath(pieCar, _stroke(const Color(0xFF365314), 2.1));
        // Tentáculos oculares superiores y tentáculos sensoriales inferiores
        c.drawLine(const Offset(77, 60), const Offset(81, 40), _stroke(const Color(0xFF4D7C0F), 3.0));
        c.drawLine(const Offset(83, 61), const Offset(90, 43), _stroke(const Color(0xFF4D7C0F), 3.0));
        c.drawLine(const Offset(86, 68), const Offset(93, 66), _stroke(const Color(0xFF4D7C0F), 2.2));
        _ojo(c, 81, 39, 2.3);
        _ojo(c, 90, 42, 2.3);
        // Concha calcárea redondeada con bandas y espiral logarítmica
        c.drawCircle(
          const Offset(43, 47),
          23,
          _grad(const Rect.fromLTWH(20, 24, 46, 46), const Color(0xFFFBBF24), const Color(0xFF92400E)),
        );
        c.drawOval(
          const Rect.fromLTWH(28, 30, 18, 10),
          _fill(Colors.white.withValues(alpha: 0.28)),
        );
        c.drawCircle(const Offset(43, 47), 23, _stroke(const Color(0xFF451A03), 2.3));
        // Espiral continua y estrías de crecimiento
        final espiral = Path()
          ..moveTo(43, 47)
          ..quadraticBezierTo(48, 42, 50, 47)
          ..quadraticBezierTo(51, 55, 42, 56)
          ..quadraticBezierTo(31, 56, 31, 45)
          ..quadraticBezierTo(32, 32, 46, 32)
          ..quadraticBezierTo(60, 33, 60, 49)
          ..quadraticBezierTo(59, 64, 43, 66);
        c.drawPath(espiral, _stroke(const Color(0xFF451A03), 2.5));
        break;

      case 'medusa-costa':
      case 'medusa-mar':
        // Medusa acampanada marina: umbrela gelatinosa translúcida con reflejos de agua, brazos orales rizados y tentáculos largos urticantes
        // Brazos orales centrales suaves y tentáculos periféricos ondulantes
        for (final (x, amp, col, w) in [
          (26.0, -7.0, const Color(0xFFF472B6), 2.6),
          (36.0, 6.0, const Color(0xFFEC4899), 3.0),
          (45.0, -5.0, const Color(0xFFDB2777), 3.8),
          (55.0, 5.0, const Color(0xFFDB2777), 3.8),
          (64.0, -6.0, const Color(0xFFEC4899), 3.0),
          (74.0, 7.0, const Color(0xFFF472B6), 2.6),
        ]) {
          final tent = Path()
            ..moveTo(x, 48)
            ..cubicTo(x + amp, 60, x - amp, 74, x + amp * 0.5, 88);
          c.drawPath(tent, _stroke(col, w));
        }
        // Campana / umbrela gelatinosa con borde festoneado en lóbulos
        final umbrela = Path()
          ..moveTo(16, 48)
          ..cubicTo(16, 16, 84, 16, 84, 48)
          ..quadraticBezierTo(73, 54, 62, 47)
          ..quadraticBezierTo(50, 54, 38, 47)
          ..quadraticBezierTo(27, 54, 16, 48)
          ..close();
        c.drawPath(
          umbrela,
          _grad(const Rect.fromLTWH(16, 16, 68, 38), const Color(0xFFFBCFE8), const Color(0xFFDB2777)),
        );
        // Brillo translúcido en la cúpula de gelatina
        c.drawOval(
          const Rect.fromLTWH(28, 22, 28, 12),
          _fill(Colors.white.withValues(alpha: 0.45)),
        );
        c.drawPath(umbrela, _stroke(const Color(0xFF831843), 2.2));
        _ojo(c, 41, 36, 2.5);
        _ojo(c, 59, 36, 2.5);
        _moflete(c, 37, 41, 3.2, 2.0);
        _moflete(c, 63, 41, 3.2, 2.0);
        break;

      case 'inv-anelido-cnidario':
        // Emblema detallado de anillos metaméricos blandos y tentáculos urticantes
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFF1F2), const Color(0xFFFECDD3)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFE11D48), 2.2));
        for (double y = 28; y <= 64; y += 12) {
          final rAnillo = RRect.fromRectAndRadius(Rect.fromLTWH(25, y, 50, 9), const Radius.circular(4.5));
          c.drawRRect(
            rAnillo,
            _grad(Rect.fromLTWH(25, y, 50, 9), const Color(0xFFFB7185), const Color(0xFFE11D48)),
          );
          c.drawRRect(rAnillo, _stroke(const Color(0xFF881337), 1.8));
        }
        break;

      case 'lombriz-humeda':
      case 'lombriz-galeria':
      case 'lombriz-tierra':
        // Lombriz de tierra detallada asomando de la tierra húmeda: cuerpo cilíndrico blando en S dividido en anillos (metámeros), clitelo engrosado y piel brillante
        // Montículo de tierra húmeda de jardín con terrones
        final tierra = Path()
          ..moveTo(10, 84)
          ..quadraticBezierTo(28, 66, 52, 70)
          ..quadraticBezierTo(74, 66, 90, 84)
          ..close();
        c.drawPath(
          tierra,
          _grad(const Rect.fromLTWH(10, 66, 80, 18), const Color(0xFF78350F), const Color(0xFF451A03)),
        );
        c.drawPath(tierra, _stroke(const Color(0xFF292524), 2.0));
        // Cuerpo blando ondulado en S compuesto por anillos sucesivos
        final ejeLombriz = Path()
          ..moveTo(22, 74)
          ..cubicTo(14, 52, 42, 58, 48, 40)
          ..cubicTo(54, 22, 78, 22, 78, 36);
        c.drawPath(ejeLombriz, _stroke(const Color(0xFF881337), 17.5));
        c.drawPath(ejeLombriz, _stroke(const Color(0xFFF43F5E), 13.5));
        c.drawPath(ejeLombriz, _stroke(const Color(0xFFFDA4AF), 6.0));
        // Clitelo (anillo glandular más grueso y rosado intenso característico de la lombriz)
        final clitelo = Path()
          ..moveTo(43, 47)
          ..quadraticBezierTo(48, 39, 54, 32);
        c.drawPath(clitelo, _stroke(const Color(0xFF881337), 20.0));
        c.drawPath(clitelo, _stroke(const Color(0xFFFB7185), 16.0));
        // Líneas divisorias de los anillos metaméricos a lo largo del cuerpo
        for (final (x1, y1, x2, y2) in [
          (16.0, 66.0, 28.0, 64.0),
          (20.0, 56.0, 31.0, 59.0),
          (29.0, 50.0, 37.0, 59.0),
          (37.0, 46.0, 46.0, 53.0),
          (52.0, 26.0, 58.0, 36.0),
          (61.0, 22.0, 65.0, 33.0),
          (70.0, 23.0, 69.0, 34.0),
        ]) {
          c.drawLine(Offset(x1, y1), Offset(x2, y2), _stroke(const Color(0xFF9F1239), 1.8));
        }
        // Extremo anterior redondeado con ojos simpáticos y brillo húmedo
        c.drawCircle(const Offset(77, 35), 8.2, _fill(const Color(0xFFF43F5E)));
        c.drawCircle(const Offset(77, 35), 8.2, _stroke(const Color(0xFF881337), 2.0));
        _ojo(c, 75, 33, 2.1);
        _ojo(c, 81, 34, 2.1);
        c.drawArc(const Rect.fromLTWH(74, 36, 6, 4), 0, math.pi, false, _stroke(const Color(0xFF881337), 1.5));
        break;

      // ==================== POLINIZACIÓN Y SEMILLAS ====================
      case 'flor-caliz-corola':
        // Emblema botánico de la envoltura floral: copa protectora (cáliz) y abanico de pétalos (corola)
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFFF1F2)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFDA4AF), 2));
        // Abanico de 3 pétalos superiores con degradado y venas
        for (final (dx, dy, ang) in [(-15.0, -4.0, -0.42), (15.0, -4.0, 0.42), (0.0, -10.0, 0.0)]) {
          c.save();
          c.translate(50 + dx, 46 + dy);
          c.rotate(ang);
          final pet = Path()
            ..moveTo(0, 14)
            ..cubicTo(-18, 4, -16, -20, 0, -24)
            ..cubicTo(16, -20, 18, 4, 0, 14)
            ..close();
          c.drawPath(
            pet,
            _fillGrad(
              const Rect.fromLTWH(-18, -24, 36, 38),
              const [Color(0xFFFB7185), Color(0xFFE11D48)],
            ),
          );
          c.drawPath(pet, _stroke(const Color(0xFF9F1239), 1.8));
          c.drawLine(const Offset(0, 10), const Offset(0, -16), _stroke(const Color(0xFFFFE4E6), 1.4));
          c.restore();
        }
        // Copa verde inferior del cáliz abrazando la corola
        final copaCaliz = Path()
          ..moveTo(50, 74)
          ..quadraticBezierTo(26, 68, 22, 46)
          ..quadraticBezierTo(36, 56, 50, 58)
          ..quadraticBezierTo(64, 56, 78, 46)
          ..quadraticBezierTo(74, 68, 50, 74)
          ..close();
        c.drawPath(copaCaliz, _fill(const Color(0xFF16A34A)));
        c.drawPath(copaCaliz, _stroke(const Color(0xFF14532D), 2.0));
        c.drawLine(const Offset(50, 74), const Offset(50, 86), _stroke(const Color(0xFF15803D), 4.5));
        break;

      case 'petalo-color':
      case 'petalos-colores':
        // Dos láminas de pétalos aterciopelados aislados con guías de néctar y gotitas aromáticas
        _sombraSuelo(c, 50, 84, 52, 8);
        for (final (cx, cy, ang, col1, col2) in [
          (38.0, 50.0, -0.28, const Color(0xFFF472B6), const Color(0xFFDB2777)),
          (60.0, 48.0, 0.24, const Color(0xFFFB7185), const Color(0xFFE11D48)),
        ]) {
          c.save();
          c.translate(cx, cy);
          c.rotate(ang);
          final lamina = Path()
            ..moveTo(0, 28)
            ..cubicTo(-24, 14, -26, -18, -8, -28)
            ..quadraticBezierTo(0, -22, 8, -28)
            ..cubicTo(26, -18, 24, 14, 0, 28)
            ..close();
          c.drawPath(
            lamina,
            _fillGrad(
              const Rect.fromLTWH(-26, -28, 52, 56),
              [col1, col2],
            ),
          );
          c.drawPath(lamina, _stroke(const Color(0xFF881337), 2.2));
          // Uña basal clara y venas guía de néctar
          c.drawOval(const Rect.fromLTWH(-6, 14, 12, 12), _fill(const Color(0xFFFEF08A)));
          for (final vx in [-10.0, -4.0, 0.0, 4.0, 10.0]) {
            c.drawLine(
              Offset(vx * 0.3, 18),
              Offset(vx, -14),
              _stroke(const Color(0xFFFFE4E6).withValues(alpha: 0.75), 1.6),
            );
          }
          c.restore();
        }
        // Ondas de aroma suave arriba
        c.drawArc(const Rect.fromLTWH(38, 10, 14, 10), math.pi, math.pi, false, _stroke(const Color(0xFFF472B6), 2.0));
        c.drawArc(const Rect.fromLTWH(54, 12, 14, 10), math.pi, math.pi, false, _stroke(const Color(0xFFF472B6), 2.0));
        break;

      case 'sepalo-verde':
      case 'sepalos-verdes':
        // Capullo floral arropado por las hojitas verdes (sépalos) con gotas de rocío
        _sombraSuelo(c, 50, 88, 36, 7);
        c.drawLine(const Offset(50, 64), const Offset(50, 88), _stroke(const Color(0xFF15803D), 6));
        // Receptáculo engrosado en la base
        c.drawOval(const Rect.fromLTWH(38, 58, 24, 12), _fill(const Color(0xFF166534)));
        // Capullo cerrado asomando apenas en la punta
        final capullo = Path()
          ..moveTo(50, 16)
          ..cubicTo(68, 26, 66, 52, 50, 62)
          ..cubicTo(34, 52, 32, 26, 50, 16)
          ..close();
        c.drawPath(capullo, _fill(const Color(0xFFFBCFE8)));
        c.drawPath(capullo, _stroke(const Color(0xFFBE185D), 2.0));
        // Sépalos verdes puntiagudos con nervios abrazando el capullo
        final sepIzq = Path()
          ..moveTo(50, 64)
          ..cubicTo(22, 58, 18, 32, 34, 18)
          ..quadraticBezierTo(40, 42, 50, 60)
          ..close();
        final sepDer = Path()
          ..moveTo(50, 64)
          ..cubicTo(78, 58, 82, 32, 66, 18)
          ..quadraticBezierTo(60, 42, 50, 60)
          ..close();
        final sepCen = Path()
          ..moveTo(50, 64)
          ..quadraticBezierTo(42, 44, 50, 24)
          ..quadraticBezierTo(58, 44, 50, 64)
          ..close();
        c.drawPath(sepIzq, _fill(const Color(0xFF16A34A)));
        c.drawPath(sepDer, _fill(const Color(0xFF16A34A)));
        c.drawPath(sepCen, _fill(const Color(0xFF22C55E)));
        c.drawPath(sepIzq, _stroke(const Color(0xFF14532D), 2.2));
        c.drawPath(sepDer, _stroke(const Color(0xFF14532D), 2.2));
        c.drawPath(sepCen, _stroke(const Color(0xFF14532D), 2.0));
        // Gotita de rocío resbalando por el sépalo exterior
        c.drawCircle(const Offset(26, 42), 3.5, _fill(const Color(0xFF38BDF8)));
        c.drawCircle(const Offset(25, 41), 1.2, _fill(Colors.white));
        break;

      case 'flor-estambres':
        // Emblema del androceo (órgano masculino): abanico de 3 estambres esbeltos
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF9C3)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFDE047), 2));
        for (final (xTop, yTop) in [(30.0, 34.0), (50.0, 26.0), (70.0, 34.0)]) {
          final fil = Path()
            ..moveTo(50, 78)
            ..quadraticBezierTo((50 + xTop) / 2, 56, xTop, yTop);
          c.drawPath(fil, _stroke(const Color(0xFF65A30D), 3.5));
          c.drawOval(Rect.fromCenter(center: Offset(xTop - 4, yTop), width: 10, height: 14), _fill(const Color(0xFFF59E0B)));
          c.drawOval(Rect.fromCenter(center: Offset(xTop + 4, yTop), width: 10, height: 14), _fill(const Color(0xFFF59E0B)));
          c.drawOval(Rect.fromCenter(center: Offset(xTop - 4, yTop), width: 10, height: 14), _stroke(const Color(0xFFB45309), 1.8));
          c.drawOval(Rect.fromCenter(center: Offset(xTop + 4, yTop), width: 10, height: 14), _stroke(const Color(0xFFB45309), 1.8));
        }
        break;

      case 'antena-polen':
      case 'filamento-antera':
        // Pareja de filamentos flexibles sosteniendo anteras bilobuladas con su surco central
        _sombraSuelo(c, 50, 86, 40, 7);
        for (final (bx, tx, ty) in [(44.0, 36.0, 30.0), (56.0, 62.0, 24.0)]) {
          final fil = Path()
            ..moveTo(bx, 84)
            ..quadraticBezierTo(bx + (tx - bx) * 0.4, 54, tx, ty);
          c.drawPath(fil, _stroke(const Color(0xFF84CC16), 4.5));
          c.drawPath(fil, _stroke(const Color(0xFF3F6212), 1.4));
          // Dos tecas (bolsitas) unidas en la punta
          c.drawOval(Rect.fromCenter(center: Offset(tx - 6, ty), width: 13, height: 20), _fill(const Color(0xFFFBBF24)));
          c.drawOval(Rect.fromCenter(center: Offset(tx + 6, ty), width: 13, height: 20), _fill(const Color(0xFFF59E0B)));
          c.drawOval(Rect.fromCenter(center: Offset(tx - 6, ty), width: 13, height: 20), _stroke(const Color(0xFF92400E), 2.0));
          c.drawOval(Rect.fromCenter(center: Offset(tx + 6, ty), width: 13, height: 20), _stroke(const Color(0xFF92400E), 2.0));
          c.drawLine(Offset(tx - 6, ty - 6), Offset(tx - 6, ty + 6), _stroke(const Color(0xFFB45309), 1.5));
          c.drawLine(Offset(tx + 6, ty - 6), Offset(tx + 6, ty + 6), _stroke(const Color(0xFFB45309), 1.5));
        }
        break;

      case 'saco-polinico':
      case 'granos-polen':
        // Corte de un saco polínico abierto soltando granos microscópicos de polen con relieve
        _sombraSuelo(c, 50, 86, 48, 7);
        // Saco abierto en dos valvas en la parte inferior
        final saco = Path()
          ..moveTo(20, 64)
          ..quadraticBezierTo(34, 82, 50, 74)
          ..quadraticBezierTo(66, 82, 80, 64)
          ..quadraticBezierTo(68, 48, 50, 56)
          ..quadraticBezierTo(32, 48, 20, 64)
          ..close();
        c.drawPath(saco, _fill(const Color(0xFFD97706)));
        c.drawPath(saco, _stroke(const Color(0xFF78350F), 2.4));
        c.drawOval(const Rect.fromLTWH(28, 56, 20, 12), _fill(const Color(0xFFFEF08A)));
        c.drawOval(const Rect.fromLTWH(52, 56, 20, 12), _fill(const Color(0xFFFEF08A)));
        // Granos de polen esféricos con textura microscópica flotando arriba
        for (final (gx, gy, r) in [
          (32.0, 36.0, 7.5),
          (50.0, 24.0, 9.0),
          (68.0, 34.0, 7.5),
          (44.0, 46.0, 6.0),
          (58.0, 48.0, 6.0),
        ]) {
          for (int i = 0; i < 8; i++) {
            final a = i * math.pi / 4;
            c.drawLine(
              Offset(gx + math.cos(a) * (r - 1), gy + math.sin(a) * (r - 1)),
              Offset(gx + math.cos(a) * (r + 2.5), gy + math.sin(a) * (r + 2.5)),
              _stroke(const Color(0xFFD97706), 1.8),
            );
          }
          c.drawCircle(Offset(gx, gy), r, _fill(const Color(0xFFFACC15)));
          c.drawCircle(Offset(gx, gy), r, _stroke(const Color(0xFFB45309), 1.8));
          c.drawCircle(Offset(gx - r * 0.3, gy - r * 0.3), r * 0.28, _fill(Colors.white.withValues(alpha: 0.7)));
        }
        break;

      case 'flor-pistilo':
        // Emblema del gineceo (órgano femenino central) con estigma trilobulado, estilo y ovario
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFF86EFAC), 2));
        final embPistilo = Path()
          ..moveTo(45, 24)
          ..lineTo(45, 44)
          ..cubicTo(28, 52, 28, 76, 50, 78)
          ..cubicTo(72, 76, 72, 52, 55, 44)
          ..lineTo(55, 24)
          ..close();
        c.drawPath(
          embPistilo,
          _fillGrad(
            const Rect.fromLTWH(28, 22, 44, 58),
            const [Color(0xFF4ADE80), Color(0xFF16A34A)],
          ),
        );
        c.drawPath(embPistilo, _stroke(const Color(0xFF14532D), 2.5));
        c.drawOval(const Rect.fromLTWH(38, 18, 24, 9), _fill(const Color(0xFF86EFAC)));
        c.drawOval(const Rect.fromLTWH(38, 18, 24, 9), _stroke(const Color(0xFF14532D), 2.0));
        break;

      case 'ovario-flor':
      case 'ovario-fruto':
        // Cámara basal abombada en corte longitudinal mostrando la placenta central y los óvulos perlados
        _sombraSuelo(c, 50, 88, 42, 7);
        c.drawLine(const Offset(50, 78), const Offset(50, 90), _stroke(const Color(0xFF15803D), 6));
        // Pared externa e interna de la cámara
        c.drawOval(const Rect.fromLTWH(22, 26, 56, 54), _fill(const Color(0xFF16A34A)));
        c.drawOval(const Rect.fromLTWH(22, 26, 56, 54), _stroke(const Color(0xFF14532D), 2.6));
        c.drawOval(const Rect.fromLTWH(30, 34, 40, 38), _fill(const Color(0xFFF0FDF4)));
        c.drawOval(const Rect.fromLTWH(30, 34, 40, 38), _stroke(const Color(0xFF86EFAC), 1.8));
        // Tabique central y 6 óvulos nacarados unidos por su funículo
        c.drawLine(const Offset(50, 35), const Offset(50, 71), _stroke(const Color(0xFF4ADE80), 3.0));
        for (final y in [43.0, 53.0, 63.0]) {
          c.drawLine(Offset(50, y), Offset(41, y), _stroke(const Color(0xFF22C55E), 1.8));
          c.drawLine(Offset(50, y), Offset(59, y), _stroke(const Color(0xFF22C55E), 1.8));
          c.drawOval(Rect.fromCenter(center: Offset(40, y), width: 10, height: 7), _fill(const Color(0xFFFEF9C3)));
          c.drawOval(Rect.fromCenter(center: Offset(60, y), width: 10, height: 7), _fill(const Color(0xFFFEF9C3)));
          c.drawOval(Rect.fromCenter(center: Offset(40, y), width: 10, height: 7), _stroke(const Color(0xFFD97706), 1.5));
          c.drawOval(Rect.fromCenter(center: Offset(60, y), width: 10, height: 7), _stroke(const Color(0xFFD97706), 1.5));
        }
        break;

      case 'estigma-cuello':
        // Cuello estilizado (estilo) y cabeza lobulada pegajosa (estigma) atrapando polen con tubo polínico
        _sombraSuelo(c, 50, 88, 34, 6);
        final cuello = Path()
          ..moveTo(41, 84)
          ..quadraticBezierTo(44, 56, 43, 30)
          ..lineTo(57, 30)
          ..quadraticBezierTo(56, 56, 59, 84)
          ..close();
        c.drawPath(
          cuello,
          _fillGrad(
            const Rect.fromLTWH(40, 30, 20, 54),
            const [Color(0xFF86EFAC), Color(0xFF22C55E)],
          ),
        );
        c.drawPath(cuello, _stroke(const Color(0xFF15803D), 2.4));
        // Tres lóbulos superiores del estigma con gotitas brillantes
        for (final (lx, ly) in [(36.0, 26.0), (64.0, 26.0), (50.0, 22.0)]) {
          c.drawOval(Rect.fromCenter(center: Offset(lx, ly), width: 22, height: 14), _fill(const Color(0xFF4ADE80)));
          c.drawOval(Rect.fromCenter(center: Offset(lx, ly), width: 22, height: 14), _stroke(const Color(0xFF14532D), 2.2));
        }
        // Tubo polínico dorado bajando por el interior del estilo desde un grano de polen
        c.drawLine(const Offset(50, 20), const Offset(50, 76), _stroke(const Color(0xFFFACC15), 2.5));
        for (final p in [const Offset(36, 21), const Offset(50, 17), const Offset(63, 22)]) {
          c.drawCircle(p, 4.2, _fill(const Color(0xFFFACC15)));
          c.drawCircle(p, 4.2, _stroke(const Color(0xFFB45309), 1.5));
        }
        break;

      case 'semilla-viajera':
      case 'viaje-viento':
        // Emblema de ráfagas de viento arremolinadas en el cielo
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFE0F2FE)));
        for (final y in [34.0, 50.0, 66.0]) {
          final rafaga = Path()
            ..moveTo(20, y)
            ..quadraticBezierTo(50, y - 8, 74, y)
            ..quadraticBezierTo(82, y + 4, 72, y + 8);
          c.drawPath(rafaga, _stroke(const Color(0xFF0284C7), 3.5));
        }
        break;

      case 'diente-leon':
        // Semilla de diente de león con paracaídas blanco
        c.drawCircle(const Offset(50, 50), 40, _fill(const Color(0xFFBAE6FD)));
        c.drawOval(const Rect.fromLTWH(46, 68, 8, 14), _fill(const Color(0xFF78350F)));
        c.drawLine(const Offset(50, 68), const Offset(50, 40), _stroke(const Color(0xFF64748B), 2.2));
        for (double a = -math.pi * 0.85; a <= -math.pi * 0.15; a += 0.22) {
          final dest = Offset(50 + math.cos(a) * 26, 40 + math.sin(a) * 24);
          c.drawLine(const Offset(50, 40), dest, _stroke(Colors.white, 2.2));
          c.drawCircle(dest, 2.5, _fill(Colors.white));
        }
        break;

      case 'samara-arce':
        // Sámara alada de arce (helicóptero)
        final alaArce = Path()
          ..moveTo(32, 64)
          ..quadraticBezierTo(44, 24, 82, 26)
          ..quadraticBezierTo(78, 54, 32, 64);
        c.drawPath(alaArce, _fill(const Color(0xFFF59E0B)));
        c.drawPath(alaArce, _stroke(const Color(0xFF92400E), 2.5));
        c.drawCircle(const Offset(30, 64), 8, _fill(const Color(0xFF78350F)));
        break;

      case 'viaje-agua':
        // Emblema de olas de río y mar en movimiento
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFE0F2FE)));
        for (final y in [38.0, 54.0, 70.0]) {
          final ola = Path()
            ..moveTo(18, y)
            ..quadraticBezierTo(34, y - 12, 50, y)
            ..quadraticBezierTo(66, y + 12, 82, y);
          c.drawPath(ola, _stroke(const Color(0xFF0284C7), 4));
        }
        break;

      case 'coco-costa':
      case 'coco-playa':
        // Coco fibroso marrón con sus tres poros germinativos
        c.drawCircle(const Offset(50, 50), 26, _fill(const Color(0xFF78350F)));
        c.drawCircle(const Offset(50, 50), 26, _stroke(const Color(0xFF451A03), 3));
        c.drawCircle(const Offset(43, 42), 3, _fill(const Color(0xFF292524)));
        c.drawCircle(const Offset(53, 40), 3, _fill(const Color(0xFF292524)));
        c.drawCircle(const Offset(48, 50), 3, _fill(const Color(0xFF292524)));
        break;

      case 'nenufar-semilla':
      case 'nenufar-charca':
        // Hoja flotante de nenúfar con semilla en el agua
        c.drawOval(const Rect.fromLTWH(16, 44, 68, 32), _fill(const Color(0xFF22C55E)));
        c.drawCircle(const Offset(50, 54), 9, _fill(const Color(0xFFFDE047)));
        break;

      case 'viaje-animal':
        // Emblema de ave y pelaje dispersando semillas (distinto de las cerezas)
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFFF1F2)));
        c.drawOval(const Rect.fromLTWH(24, 42, 34, 24), _fill(const Color(0xFFE11D48)));
        c.drawCircle(const Offset(58, 38), 11, _fill(const Color(0xFFE11D48)));
        final picoDisp = Path()
          ..moveTo(68, 35)
          ..lineTo(82, 39)
          ..lineTo(68, 43)
          ..close();
        c.drawPath(picoDisp, _fill(const Color(0xFFF59E0B)));
        c.drawCircle(const Offset(78, 46), 4, _fill(const Color(0xFF16A34A)));
        _ojo(c, 60, 36, 2.2);
        break;

      case 'cereza-pajaro':
      case 'cereza-ave':
        // Dos cerezas rojas brillantes con rabito y hoja
        c.drawLine(const Offset(36, 62), const Offset(52, 22), _stroke(const Color(0xFF15803D), 3));
        c.drawLine(const Offset(66, 62), const Offset(52, 22), _stroke(const Color(0xFF15803D), 3));
        c.drawCircle(const Offset(34, 66), 14, _fill(const Color(0xFFE11D48)));
        c.drawCircle(const Offset(66, 66), 14, _fill(const Color(0xFFE11D48)));
        c.drawCircle(const Offset(30, 62), 3, _fill(Colors.white.withValues(alpha: 0.7)));
        c.drawCircle(const Offset(62, 62), 3, _fill(Colors.white.withValues(alpha: 0.7)));
        break;

      case 'cadillo-pelo':
      case 'cadillo-gancho':
        // Cadillo espinoso con ganchitos tipo velcro
        c.drawCircle(const Offset(50, 52), 20, _fill(const Color(0xFF65A30D)));
        for (int i = 0; i < 12; i++) {
          final a = i * math.pi / 6;
          final p1 = Offset(50 + math.cos(a) * 20, 52 + math.sin(a) * 20);
          final p2 = Offset(50 + math.cos(a) * 32, 52 + math.sin(a) * 32);
          c.drawLine(p1, p2, _stroke(const Color(0xFF3F6212), 2.8));
          c.drawCircle(p2, 2.5, _fill(const Color(0xFF3F6212)));
        }
        break;

      case 'planta-angiosperma':
        // Emblema de flor vistosa + fruto protegiendo semillas
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFFF1F2)));
        c.drawCircle(const Offset(36, 46), 16, _fill(const Color(0xFFF43F5E)));
        c.drawCircle(const Offset(36, 46), 6, _fill(const Color(0xFFFACC15)));
        c.drawCircle(const Offset(64, 54), 16, _fill(const Color(0xFFEF4444)));
        c.drawOval(const Rect.fromLTWH(56, 46, 16, 16), _fill(const Color(0xFFFEF9C3)));
        c.drawCircle(const Offset(64, 54), 3, _fill(const Color(0xFF451A03)));
        break;

      case 'manzano-flor':
      case 'manzano-fruto':
        // Rama de manzano con hojas verdes y manzanas madurando
        c.drawLine(const Offset(16, 44), const Offset(84, 34), _stroke(const Color(0xFF78350F), 5));
        c.drawOval(const Rect.fromLTWH(24, 22, 22, 12), _fill(const Color(0xFF22C55E)));
        c.drawOval(const Rect.fromLTWH(58, 18, 22, 12), _fill(const Color(0xFF22C55E)));
        c.drawCircle(const Offset(46, 60), 20, _fill(const Color(0xFFEF4444)));
        c.drawCircle(const Offset(40, 54), 4, _fill(Colors.white.withValues(alpha: 0.5)));
        break;

      case 'planta-gimnosperma':
        // Emblema de escama leñosa con piñón alado desnudo (sin fruto)
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF3C7)));
        final escamaPina = Path()
          ..moveTo(24, 70)
          ..quadraticBezierTo(50, 20, 76, 70)
          ..close();
        c.drawPath(escamaPina, _fill(const Color(0xFF92400E)));
        c.drawOval(const Rect.fromLTWH(42, 46, 16, 20), _fill(const Color(0xFFFDE68A)));
        break;

      case 'pino-pina':
      case 'pino-pinonero':
        // Piña leñosa de escamas con agujas de pino
        c.drawLine(const Offset(50, 18), const Offset(22, 30), _stroke(const Color(0xFF15803D), 3));
        c.drawLine(const Offset(50, 18), const Offset(78, 30), _stroke(const Color(0xFF15803D), 3));
        c.drawOval(const Rect.fromLTWH(30, 26, 40, 56), _fill(const Color(0xFF92400E)));
        for (double y = 36; y <= 70; y += 11) {
          c.drawArc(Rect.fromLTWH(32, y - 6, 36, 12), 0, math.pi, false, _stroke(const Color(0xFF451A03), 2.5));
        }
        break;

      case 'abeto-cono':
      case 'abeto-montana':
        // Rama de abeto con cono erguido hacia arriba y acículas verdes
        c.drawLine(const Offset(18, 72), const Offset(82, 72), _stroke(const Color(0xFF15803D), 5));
        c.drawOval(const Rect.fromLTWH(34, 20, 32, 52), _fill(const Color(0xFF78350F)));
        for (double y = 30; y <= 60; y += 10) {
          c.drawLine(Offset(36, y), Offset(64, y), _stroke(const Color(0xFF451A03), 2.5));
        }
        break;

      case 'helecho-espora':
      case 'planta-esporas':
        // Emblema de cápsula esporangio liberando esporas microscópicas
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(38, 54), 14, _fill(const Color(0xFFD97706)));
        for (final p in [
          const Offset(58, 36),
          const Offset(70, 44),
          const Offset(64, 58),
          const Offset(74, 64),
        ]) {
          c.drawCircle(p, 4, _fill(const Color(0xFFF59E0B)));
        }
        break;

      case 'helecho-soros':
      case 'helecho-sombra':
        // Hoja de helecho con fila de soros naranjas de esporas
        c.drawLine(const Offset(24, 84), const Offset(76, 20), _stroke(const Color(0xFF15803D), 4));
        for (int i = 1; i <= 5; i++) {
          final t = i / 6.0;
          final cx = 24 + (76 - 24) * t;
          final cy = 84 + (20 - 84) * t;
          c.drawOval(Rect.fromCenter(center: Offset(cx - 12, cy - 4), width: 20, height: 9), _fill(const Color(0xFF22C55E)));
          c.drawOval(Rect.fromCenter(center: Offset(cx + 12, cy + 4), width: 20, height: 9), _fill(const Color(0xFF22C55E)));
          c.drawCircle(Offset(cx - 10, cy - 4), 2.3, _fill(const Color(0xFFD97706)));
          c.drawCircle(Offset(cx + 10, cy + 4), 2.3, _fill(const Color(0xFFD97706)));
        }
        break;

      case 'musgo-capsula':
      case 'musgo-roca':
        // Roca gris con alfombra de musgo verde y cápsulas de esporas
        c.drawOval(const Rect.fromLTWH(16, 56, 68, 28), _fill(const Color(0xFF64748B)));
        c.drawOval(const Rect.fromLTWH(20, 48, 60, 20), _fill(const Color(0xFF22C55E)));
        for (final x in [32.0, 50.0, 68.0]) {
          c.drawLine(Offset(x, 50), Offset(x, 24), _stroke(const Color(0xFF65A30D), 2.2));
          c.drawOval(Rect.fromCenter(center: Offset(x, 22), width: 8, height: 11), _fill(const Color(0xFFD97706)));
        }
        break;

      // ==================== ESTACIONES Y HUERTO ====================
      case 'hoja-caduca':
      case 'arbol-caduco':
      case 'arbol-caduca':
        // Emblema estacional de árbol caducifolio: mitad primavera verde, mitad otoño ocre con caída de hoja
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFFFBEB), const Color(0xFFFED7AA)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFEA580C), 2.2));
        final hojaCadIzq = Path()
          ..moveTo(50, 18)
          ..quadraticBezierTo(18, 36, 32, 70)
          ..lineTo(50, 70)
          ..close();
        final hojaCadDer = Path()
          ..moveTo(50, 18)
          ..quadraticBezierTo(82, 36, 68, 70)
          ..lineTo(50, 70)
          ..close();
        c.drawPath(hojaCadIzq, _fill(const Color(0xFF22C55E)));
        c.drawPath(hojaCadDer, _fill(const Color(0xFFEA580C)));
        c.drawPath(hojaCadIzq, _stroke(const Color(0xFF15803D), 2.0));
        c.drawPath(hojaCadDer, _stroke(const Color(0xFF9A3412), 2.0));
        c.drawLine(const Offset(50, 18), const Offset(50, 84), _stroke(const Color(0xFF78350F), 3.2));
        c.drawLine(const Offset(50, 44), const Offset(36, 34), _stroke(const Color(0xFF15803D), 1.8));
        c.drawLine(const Offset(50, 44), const Offset(64, 34), _stroke(const Color(0xFF9A3412), 1.8));
        break;

      case 'haya-otono':
      case 'haya-bosque':
      case 'hayedo-niebla':
        // Haya común: tronco esbelto gris plateado liso con lenticelas y copa ovalada frondosa en capas
        _sombraSuelo(c, 50, 86, 28, 5.5);
        final troncoHaya = Path()
          ..moveTo(43, 86)
          ..quadraticBezierTo(46, 68, 46, 48)
          ..lineTo(54, 48)
          ..quadraticBezierTo(54, 68, 57, 86)
          ..close();
        c.drawPath(
          troncoHaya,
          _grad(const Rect.fromLTWH(43, 48, 14, 38), const Color(0xFF94A3B8), const Color(0xFF64748B)),
        );
        c.drawPath(troncoHaya, _stroke(const Color(0xFF334155), 1.9));
        for (final y in [58.0, 66.0, 74.0]) {
          c.drawLine(Offset(46, y), Offset(52, y), _stroke(const Color(0xFFCBD5E1), 1.4));
        }
        for (final (cx, cy, r, col) in [
          (34.0, 42.0, 16.0, const Color(0xFF16A34A)),
          (66.0, 42.0, 16.0, const Color(0xFF16A34A)),
          (50.0, 32.0, 22.0, const Color(0xFF22C55E)),
          (42.0, 28.0, 13.0, const Color(0xFF4ADE80)),
          (58.0, 30.0, 12.0, const Color(0xFF4ADE80)),
        ]) {
          c.drawCircle(Offset(cx, cy), r, _fill(col));
        }
        c.drawArc(
          const Rect.fromLTWH(26, 12, 48, 42),
          math.pi * 0.9,
          math.pi * 1.2,
          false,
          _stroke(const Color(0xFF14532D), 2.2),
        );
        break;

      case 'roble-bosque':
      case 'roble-lobulada':
      case 'robledal-humedo':
        // Roble: tronco robusto agrietado con raíces marcadas, copa lobulada vigorosa y bellotas
        _sombraSuelo(c, 50, 86, 30, 6.0);
        final troncoRoble = Path()
          ..moveTo(39, 86)
          ..quadraticBezierTo(44, 72, 43, 48)
          ..lineTo(57, 48)
          ..quadraticBezierTo(56, 72, 61, 86)
          ..close();
        c.drawPath(
          troncoRoble,
          _grad(const Rect.fromLTWH(39, 48, 22, 38), const Color(0xFF78350F), const Color(0xFF451A03)),
        );
        c.drawPath(troncoRoble, _stroke(const Color(0xFF292524), 2.0));
        c.drawLine(const Offset(48, 54), const Offset(47, 82), _stroke(const Color(0xFF451A03), 1.6));
        for (final (cx, cy, r, col) in [
          (31.0, 43.0, 16.0, const Color(0xFF15803D)),
          (69.0, 43.0, 16.0, const Color(0xFF15803D)),
          (50.0, 34.0, 22.0, const Color(0xFF16A34A)),
          (38.0, 29.0, 14.0, const Color(0xFF22C55E)),
          (62.0, 29.0, 14.0, const Color(0xFF22C55E)),
        ]) {
          c.drawCircle(Offset(cx, cy), r, _fill(col));
          c.drawCircle(Offset(cx, cy), r, _stroke(const Color(0xFF14532D), 1.6));
        }
        for (final (bx, by) in [(35.0, 42.0), (60.0, 38.0)]) {
          c.drawOval(Rect.fromLTWH(bx, by, 6.5, 9.5), _fill(const Color(0xFFD97706)));
          c.drawOval(Rect.fromLTWH(bx, by, 6.5, 9.5), _stroke(const Color(0xFF451A03), 1.4));
          c.drawArc(Rect.fromLTWH(bx - 1, by - 3, 8.5, 6), math.pi, math.pi, true, _fill(const Color(0xFF78350F)));
        }
        break;

      case 'roble-otono':
        // Árbol caducifolio en otoño de copa cobriza/dorada con hojas desprendiéndose
        _sombraSuelo(c, 50, 86, 28, 5.5);
        c.drawRect(const Rect.fromLTWH(44, 52, 12, 34), _fill(const Color(0xFF78350F)));
        c.drawRect(const Rect.fromLTWH(44, 52, 12, 34), _stroke(const Color(0xFF451A03), 1.8));
        c.drawCircle(const Offset(34, 42), 16, _fill(const Color(0xFFD97706)));
        c.drawCircle(const Offset(66, 42), 16, _fill(const Color(0xFFEA580C)));
        c.drawCircle(const Offset(50, 34), 22, _fill(const Color(0xFFF59E0B)));
        c.drawOval(const Rect.fromLTWH(20, 68, 9, 5.5), _fill(const Color(0xFFEA580C)));
        c.drawOval(const Rect.fromLTWH(70, 72, 9, 5.5), _fill(const Color(0xFFF59E0B)));
        break;

      case 'cerezo-valle':
        // Cerezo en verano: tronco rojizo anillado, copa verde fresca y parejas de cerezas rojas
        _sombraSuelo(c, 50, 86, 28, 5.5);
        c.drawRect(const Rect.fromLTWH(44, 50, 12, 36), _fill(const Color(0xFF7C2D12)));
        c.drawRect(const Rect.fromLTWH(44, 50, 12, 36), _stroke(const Color(0xFF451A03), 1.9));
        for (final y in [58.0, 68.0, 76.0]) {
          c.drawLine(Offset(45, y), Offset(55, y), _stroke(const Color(0xFFB45309), 1.4));
        }
        for (final (cx, cy, r, col) in [
          (34.0, 42.0, 16.0, const Color(0xFF16A34A)),
          (66.0, 42.0, 16.0, const Color(0xFF16A34A)),
          (50.0, 32.0, 21.0, const Color(0xFF22C55E)),
        ]) {
          c.drawCircle(Offset(cx, cy), r, _fill(col));
          c.drawCircle(Offset(cx, cy), r, _stroke(const Color(0xFF14532D), 1.7));
        }
        for (final (px, py) in [(36.0, 36.0), (58.0, 34.0)]) {
          c.drawLine(Offset(px, py), Offset(px - 4, py + 8), _stroke(const Color(0xFF14532D), 1.5));
          c.drawLine(Offset(px, py), Offset(px + 4, py + 8), _stroke(const Color(0xFF14532D), 1.5));
          c.drawCircle(Offset(px - 4, py + 9), 3.6, _fill(const Color(0xFFE11D48)));
          c.drawCircle(Offset(px + 4, py + 9), 3.6, _fill(const Color(0xFFBE123C)));
        }
        break;

      case 'cerezo-flor':
        // Cerezo en floración primaveral: copa cubierta de flores rosadas y blancas
        _sombraSuelo(c, 50, 86, 28, 5.5);
        c.drawRect(const Rect.fromLTWH(44, 52, 12, 34), _fill(const Color(0xFF7C2D12)));
        c.drawCircle(const Offset(34, 42), 16, _fill(const Color(0xFFF9A8D4)));
        c.drawCircle(const Offset(66, 42), 16, _fill(const Color(0xFFF472B6)));
        c.drawCircle(const Offset(50, 34), 22, _fill(const Color(0xFFFBCFE8)));
        for (final (fx, fy) in [(38.0, 34.0), (52.0, 26.0), (62.0, 38.0), (44.0, 44.0)]) {
          c.drawCircle(Offset(fx, fy), 3.5, _fill(Colors.white));
          c.drawCircle(Offset(fx, fy), 1.5, _fill(const Color(0xFFE11D48)));
        }
        break;

      case 'arbol-perenne':
        // Emblema de árbol perenne: hoja verde constante durante las 4 estaciones junto a copo invernal
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFECFDF5), const Color(0xFFBBF7D0)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF16A34A), 2.2));
        final hojaPer = Path()
          ..moveTo(28, 72)
          ..quadraticBezierTo(28, 26, 74, 24)
          ..quadraticBezierTo(70, 68, 28, 72)
          ..close();
        c.drawPath(hojaPer, _fill(const Color(0xFF15803D)));
        c.drawPath(hojaPer, _stroke(const Color(0xFF14532D), 2.2));
        c.drawLine(const Offset(28, 72), const Offset(66, 30), _stroke(const Color(0xFF86EFAC), 2.2));
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          c.drawLine(
            Offset(32 + math.cos(a) * 9, 32 + math.sin(a) * 9),
            Offset(32 - math.cos(a) * 9, 32 - math.sin(a) * 9),
            _stroke(const Color(0xFF0284C7), 2.2),
          );
        }
        break;

      case 'pino-verde':
      case 'pino-acicula':
      case 'pinar-cumbre':
        // Pino de porte cónico/aparasolado en pisos de acículas verdes y piñas colgantes
        _sombraSuelo(c, 50, 86, 26, 5.5);
        c.drawRect(const Rect.fromLTWH(44, 58, 12, 28), _fill(const Color(0xFF78350F)));
        c.drawRect(const Rect.fromLTWH(44, 58, 12, 28), _stroke(const Color(0xFF451A03), 1.9));
        for (final (y, w) in [(48.0, 30.0), (35.0, 24.0), (22.0, 17.0)]) {
          final copa = Path()
            ..moveTo(50, y - 11)
            ..lineTo(50 - w, y + 15)
            ..quadraticBezierTo(50, y + 19, 50 + w, y + 15)
            ..close();
          c.drawPath(
            copa,
            _grad(Rect.fromLTWH(50 - w, y - 11, w * 2, 30), const Color(0xFF22C55E), const Color(0xFF15803D)),
          );
          c.drawPath(copa, _stroke(const Color(0xFF14532D), 1.9));
        }
        for (final (px, py) in [(34.0, 50.0), (62.0, 44.0)]) {
          c.drawOval(Rect.fromLTWH(px, py, 6.5, 10.5), _fill(const Color(0xFF92400E)));
          c.drawOval(Rect.fromLTWH(px, py, 6.5, 10.5), _stroke(const Color(0xFF451A03), 1.4));
        }
        break;

      case 'encina-dehesa':
      case 'encina-coriacea':
      case 'encinar-seco':
        // Encina mediterránea: tronco oscuro bifurcado y densa copa redondeada verde encina con bellotas
        _sombraSuelo(c, 50, 86, 30, 6.0);
        final troncoEncina = Path()
          ..moveTo(41, 86)
          ..quadraticBezierTo(44, 68, 42, 50)
          ..lineTo(58, 50)
          ..quadraticBezierTo(56, 68, 59, 86)
          ..close();
        c.drawPath(troncoEncina, _fill(const Color(0xFF44403C)));
        c.drawPath(troncoEncina, _stroke(const Color(0xFF1C1917), 2.0));
        c.drawOval(
          const Rect.fromLTWH(16, 20, 68, 38),
          _grad(const Rect.fromLTWH(16, 20, 68, 38), const Color(0xFF15803D), const Color(0xFF14532D)),
        );
        c.drawOval(const Rect.fromLTWH(16, 20, 68, 38), _stroke(const Color(0xFF052E16), 2.2));
        c.drawOval(const Rect.fromLTWH(26, 25, 46, 18), _fill(const Color(0xFF166534)));
        c.drawOval(const Rect.fromLTWH(47, 38, 6.5, 10), _fill(const Color(0xFF92400E)));
        c.drawArc(const Rect.fromLTWH(46, 35, 8.5, 6), math.pi, math.pi, true, _fill(const Color(0xFF57534E)));
        break;

      case 'olivo-campo':
      case 'olivo-lanceolada':
        // Olivo mediterráneo de tronco retorcido centenario y copa verde plateada con aceitunas
        _sombraSuelo(c, 50, 86, 29, 5.8);
        final troncoOlivo = Path()
          ..moveTo(38, 86)
          ..quadraticBezierTo(47, 68, 41, 50)
          ..lineTo(57, 50)
          ..quadraticBezierTo(53, 68, 62, 86)
          ..close();
        c.drawPath(
          troncoOlivo,
          _grad(const Rect.fromLTWH(38, 50, 24, 36), const Color(0xFF78716C), const Color(0xFF44403C)),
        );
        c.drawPath(troncoOlivo, _stroke(const Color(0xFF292524), 2.0));
        c.drawLine(const Offset(45, 82), const Offset(48, 56), _stroke(const Color(0xFF292524), 1.5));
        c.drawOval(
          const Rect.fromLTWH(18, 22, 64, 34),
          _grad(const Rect.fromLTWH(18, 22, 64, 34), const Color(0xFF84CC16), const Color(0xFF4D7C0F)),
        );
        c.drawOval(const Rect.fromLTWH(18, 22, 64, 34), _stroke(const Color(0xFF365314), 2.1));
        c.drawOval(const Rect.fromLTWH(28, 26, 44, 15), _fill(const Color(0xFFA3E635).withValues(alpha: 0.45)));
        for (final (ox, oy) in [(36.0, 36.0), (58.0, 38.0)]) {
          c.drawOval(Rect.fromLTWH(ox, oy, 5.5, 8), _fill(const Color(0xFF365314)));
          c.drawOval(Rect.fromLTWH(ox, oy, 5.5, 8), _stroke(const Color(0xFF1A2E05), 1.3));
        }
        break;

      case 'formas-hoja':
      case 'hoja-aguja':
        // Emblema conceptual de resistencia invernal: cristal de escarcha y gota de resina protectora (sin dibujar la hoja del reto)
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF0284C7), 2.2));
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          c.drawLine(
            Offset(38 + math.cos(a) * 16, 46 + math.sin(a) * 16),
            Offset(38 - math.cos(a) * 16, 46 - math.sin(a) * 16),
            _stroke(const Color(0xFF0284C7), 2.8),
          );
        }
        final gotaResina = Path()
          ..moveTo(68, 30)
          ..quadraticBezierTo(82, 52, 68, 70)
          ..quadraticBezierTo(54, 52, 68, 30)
          ..close();
        c.drawPath(
          gotaResina,
          _grad(const Rect.fromLTWH(54, 30, 28, 40), const Color(0xFFFACC15), const Color(0xFFD97706)),
        );
        c.drawPath(gotaResina, _stroke(const Color(0xFF78350F), 2.0));
        break;

      case 'hoja-lobulada-aserrada':
        // Emblema conceptual de reposo otoñal: ráfaga de viento de otoño y yema invernal protegida (sin dibujar la hoja del reto)
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFFEF3C7), const Color(0xFFFDE68A)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFFD97706), 2.2));
        for (final y in [34.0, 48.0]) {
          final rafa = Path()
            ..moveTo(18, y)
            ..quadraticBezierTo(42, y - 8, 62, y)
            ..quadraticBezierTo(74, y + 5, 78, y - 3);
          c.drawPath(rafa, _stroke(const Color(0xFFEA580C), 3.0));
        }
        c.drawLine(const Offset(24, 72), const Offset(58, 58), _stroke(const Color(0xFF78350F), 5.0));
        final yema = Path()
          ..moveTo(54, 58)
          ..quadraticBezierTo(68, 46, 76, 54)
          ..quadraticBezierTo(68, 66, 54, 58)
          ..close();
        c.drawPath(yema, _fill(const Color(0xFFB45309)));
        c.drawPath(yema, _stroke(const Color(0xFF451A03), 2.0));
        break;

      case 'hoja-entera-dura':
        // Emblema conceptual de resistencia a la sequía: sol estival y escudo ceroso reteniendo una gota de agua
        c.drawCircle(
          const Offset(50, 50),
          43,
          _grad(const Rect.fromLTWH(7, 7, 86, 86), const Color(0xFFECFDF5), const Color(0xFFA7F3D0)),
        );
        c.drawCircle(const Offset(50, 50), 43, _stroke(const Color(0xFF059669), 2.2));
        c.drawCircle(const Offset(30, 30), 9, _fill(const Color(0xFFF59E0B)));
        c.drawArc(
          const Rect.fromLTWH(28, 34, 46, 44),
          math.pi * 1.1,
          math.pi * 0.85,
          false,
          _stroke(const Color(0xFFD97706), 3.5),
        );
        final gotaAgua = Path()
          ..moveTo(56, 44)
          ..quadraticBezierTo(70, 62, 56, 74)
          ..quadraticBezierTo(42, 62, 56, 44)
          ..close();
        c.drawPath(gotaAgua, _fill(const Color(0xFF38BDF8)));
        c.drawPath(gotaAgua, _stroke(const Color(0xFF0284C7), 2.0));
        break;

      case 'cedro-aguja':
        // Cedro de porte piramidal escalonado en pisos horizontales con piñas erguidas en barril
        _sombraSuelo(c, 50, 86, 28, 5.5);
        c.drawRect(const Rect.fromLTWH(45, 58, 10, 28), _fill(const Color(0xFF57534E)));
        c.drawRect(const Rect.fromLTWH(45, 58, 10, 28), _stroke(const Color(0xFF292524), 1.9));
        for (final r in [
          const Rect.fromLTWH(18, 48, 64, 13),
          const Rect.fromLTWH(26, 34, 48, 13),
          const Rect.fromLTWH(34, 20, 32, 13),
        ]) {
          final rr = RRect.fromRectAndRadius(r, const Radius.circular(6.5));
          c.drawRRect(rr, _grad(r, const Color(0xFF14B8A6), const Color(0xFF0F766E)));
          c.drawRRect(rr, _stroke(const Color(0xFF115E59), 1.9));
        }
        c.drawOval(const Rect.fromLTWH(34, 41, 6.5, 9), _fill(const Color(0xFFB45309)));
        c.drawOval(const Rect.fromLTWH(59, 27, 6.5, 9), _fill(const Color(0xFFB45309)));
        break;

      case 'castano-aserrada':
        // Castaño de copa amplia con erizos espinosos de castaña
        _sombraSuelo(c, 50, 86, 30, 6.0);
        c.drawRect(const Rect.fromLTWH(43, 52, 14, 34), _fill(const Color(0xFF6B4226)));
        c.drawRect(const Rect.fromLTWH(43, 52, 14, 34), _stroke(const Color(0xFF451A03), 1.9));
        c.drawOval(
          const Rect.fromLTWH(16, 18, 68, 40),
          _grad(const Rect.fromLTWH(16, 18, 68, 40), const Color(0xFF22C55E), const Color(0xFF15803D)),
        );
        c.drawOval(const Rect.fromLTWH(16, 18, 68, 40), _stroke(const Color(0xFF14532D), 2.2));
        for (final cx in [36.0, 62.0]) {
          c.drawCircle(Offset(cx, 40), 7.5, _fill(const Color(0xFF84CC16)));
          c.drawCircle(Offset(cx, 40), 7.5, _stroke(const Color(0xFF365314), 1.5));
          c.drawCircle(Offset(cx, 40), 3.8, _fill(const Color(0xFF78350F)));
        }
        break;

      case 'bosque-clima':
      case 'bosque-atlantico':
        // Emblema de bosque atlántico húmedo: valle templado con lluvia constante todo el año
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFF16A34A), 2.2));
        c.drawOval(const Rect.fromLTWH(26, 20, 48, 20), _fill(const Color(0xFF93C5FD)));
        for (final x in [36.0, 50.0, 64.0]) {
          c.drawLine(Offset(x, 42), Offset(x - 3, 50), _stroke(const Color(0xFF0284C7), 2.5));
        }
        c.drawRect(const Rect.fromLTWH(46, 64, 8, 18), _fill(const Color(0xFF78350F)));
        c.drawCircle(const Offset(50, 58), 14, _fill(const Color(0xFF22C55E)));
        break;

      case 'bosque-mediterraneo':
        // Emblema de bosque mediterráneo soleado y seco con veranos calurosos
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFD97706), 2.2));
        c.drawCircle(const Offset(32, 30), 10, _fill(const Color(0xFFF59E0B)));
        c.drawArc(const Rect.fromLTWH(16, 66, 68, 24), math.pi, math.pi, true, _fill(const Color(0xFFD97706)));
        c.drawRect(const Rect.fromLTWH(52, 54, 8, 18), _fill(const Color(0xFF57534E)));
        c.drawOval(const Rect.fromLTWH(38, 38, 36, 22), _fill(const Color(0xFF166534)));
        break;

      case 'bosque-montana':
        // Emblema de bosque de alta montaña con cumbres frías y nevadas invernales
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFE0F2FE)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFF0284C7), 2.2));
        final cumbre = Path()
          ..moveTo(16, 76)
          ..lineTo(44, 26)
          ..lineTo(72, 76)
          ..close();
        c.drawPath(cumbre, _fill(const Color(0xFF94A3B8)));
        final nieveCumbre = Path()
          ..moveTo(35, 42)
          ..lineTo(44, 26)
          ..lineTo(53, 42)
          ..close();
        c.drawPath(nieveCumbre, _fill(Colors.white));
        final abeto = Path()
          ..moveTo(64, 36)
          ..lineTo(50, 74)
          ..lineTo(78, 74)
          ..close();
        c.drawPath(abeto, _fill(const Color(0xFF15803D)));
        break;

      case 'alcornocal-corcho':
        // Alcornoque: tronco con corcho rugoso gris arriba y saca rojiza de corcho abajo, sin suelo coloreado spoiler
        _sombraSuelo(c, 50, 86, 30, 6.0);
        c.drawRect(const Rect.fromLTWH(42, 48, 16, 16), _fill(const Color(0xFF78716C)));
        c.drawRect(const Rect.fromLTWH(42, 62, 16, 24), _fill(const Color(0xFFC2410C)));
        c.drawRect(const Rect.fromLTWH(42, 48, 16, 38), _stroke(const Color(0xFF431407), 2.0));
        c.drawLine(const Offset(42, 62), const Offset(58, 62), _stroke(const Color(0xFF431407), 1.8));
        c.drawOval(
          const Rect.fromLTWH(16, 20, 68, 34),
          _grad(const Rect.fromLTWH(16, 20, 68, 34), const Color(0xFF16A34A), const Color(0xFF166534)),
        );
        c.drawOval(const Rect.fromLTWH(16, 20, 68, 34), _stroke(const Color(0xFF14532D), 2.2));
        break;

      case 'abetal-nieve':
        // Abeto blanco piramidal de tronco recto grisáceo, agujas verde-azuladas y piñas erguidas hacia arriba (sin suelo spoiler)
        _sombraSuelo(c, 50, 86, 26, 5.5);
        c.drawRect(const Rect.fromLTWH(45, 60, 10, 26), _fill(const Color(0xFF64748B)));
        c.drawRect(const Rect.fromLTWH(45, 60, 10, 26), _stroke(const Color(0xFF334155), 1.9));
        for (final (y, w) in [(48.0, 26.0), (34.0, 20.0), (20.0, 14.0)]) {
          final piso = Path()
            ..moveTo(50, y - 9)
            ..lineTo(50 - w, y + 15)
            ..lineTo(50 + w, y + 15)
            ..close();
          c.drawPath(piso, _grad(Rect.fromLTWH(50 - w, y - 9, w * 2, 24), const Color(0xFF0D9488), const Color(0xFF115E59)));
          c.drawPath(piso, _stroke(const Color(0xFF134E4A), 1.8));
        }
        // Piñas cilíndricas erguidas (rasgo distintivo del abeto frente al pino)
        c.drawOval(const Rect.fromLTWH(38, 25, 4.5, 9), _fill(const Color(0xFFB45309)));
        c.drawOval(const Rect.fromLTWH(57, 38, 4.5, 9), _fill(const Color(0xFFB45309)));
        break;

      case 'huerta-organos':
      case 'huerta-raiz':
        // Emblema de suelo fértil del huerto con raíz pivotante, pelitos absorbentes y gotas de agua
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFCD34D), 2));
        c.drawArc(const Rect.fromLTWH(10, 14, 80, 74), 0, math.pi, true, _fill(const Color(0xFF78350F)));
        c.drawLine(const Offset(12, 50), const Offset(88, 50), _stroke(const Color(0xFF451A03), 2.5));
        // Brote verde superior y raíz ramificada bajo tierra
        c.drawLine(const Offset(50, 50), const Offset(42, 34), _stroke(const Color(0xFF16A34A), 3.2));
        c.drawLine(const Offset(50, 50), const Offset(58, 34), _stroke(const Color(0xFF16A34A), 3.2));
        final raizEmb = Path()
          ..moveTo(45, 50)
          ..lineTo(55, 50)
          ..lineTo(50, 82)
          ..close();
        c.drawPath(raizEmb, _fill(const Color(0xFFFDE68A)));
        c.drawPath(raizEmb, _stroke(const Color(0xFFD97706), 1.8));
        for (final (y, dx) in [(58.0, -14.0), (64.0, 14.0), (70.0, -10.0), (74.0, 10.0)]) {
          c.drawLine(Offset(50, y), Offset(50 + dx, y + 6), _stroke(const Color(0xFFFEF08A), 2.2));
        }
        c.drawCircle(const Offset(28, 64), 3.5, _fill(const Color(0xFF38BDF8)));
        c.drawCircle(const Offset(72, 66), 3.5, _fill(const Color(0xFF38BDF8)));
        break;

      case 'huerta-hoja':
        // Emblema de par de hojas frescas con nervadura al sol
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFF86EFAC), 2));
        c.drawCircle(const Offset(28, 28), 8, _fill(const Color(0xFFFACC15)));
        final hojaHuerto = Path()
          ..moveTo(28, 76)
          ..cubicTo(20, 42, 42, 22, 74, 24)
          ..cubicTo(74, 56, 54, 76, 28, 76)
          ..close();
        c.drawPath(
          hojaHuerto,
          _fillGrad(
            const Rect.fromLTWH(22, 22, 54, 56),
            const [Color(0xFF4ADE80), Color(0xFF16A34A)],
          ),
        );
        c.drawPath(hojaHuerto, _stroke(const Color(0xFF14532D), 2.4));
        c.drawLine(const Offset(26, 78), const Offset(66, 30), _stroke(const Color(0xFFDCFCE7), 2.6));
        for (final (x1, y1, x2, y2) in [
          (40.0, 62.0, 32.0, 46.0),
          (46.0, 54.0, 62.0, 56.0),
          (54.0, 44.0, 46.0, 32.0),
        ]) {
          c.drawLine(Offset(x1, y1), Offset(x2, y2), _stroke(const Color(0xFFDCFCE7), 1.8));
        }
        break;

      case 'huerta-fruto':
        // Emblema de flor fecundada transformándose en fruto jugoso con semillas
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFFE4E6)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFDA4AF), 2));
        for (int i = 0; i < 5; i++) {
          final a = i * 2 * math.pi / 5;
          c.drawCircle(Offset(28 + math.cos(a) * 7, 36 + math.sin(a) * 7), 5, _fill(Colors.white));
        }
        c.drawCircle(const Offset(28, 36), 4, _fill(const Color(0xFFFACC15)));
        c.drawLine(const Offset(40, 42), const Offset(50, 48), _stroke(const Color(0xFFE11D48), 2.8));
        c.drawCircle(const Offset(64, 58), 18, _fill(const Color(0xFFEF4444)));
        c.drawCircle(const Offset(64, 58), 18, _stroke(const Color(0xFF991B1B), 2.2));
        c.drawCircle(const Offset(64, 58), 12, _fill(const Color(0xFFFCA5A5)));
        for (final p in [const Offset(59, 54), const Offset(69, 54), const Offset(59, 63), const Offset(69, 63)]) {
          c.drawOval(Rect.fromCenter(center: p, width: 4, height: 6), _fill(const Color(0xFFFEF08A)));
        }
        break;

      case 'rabano-raiz':
        // Rábano rojo carmesí con punta inferior blanca, raíz fina con pelitos y hojas verdes anchas arriba
        _sombraSuelo(c, 50, 90, 36, 6);
        // Tres hojas espatuladas verdes en abanico con su nervio central
        for (final (dx, ang, col) in [
          (-14.0, -0.45, const Color(0xFF16A34A)),
          (14.0, 0.45, const Color(0xFF16A34A)),
          (0.0, 0.0, const Color(0xFF22C55E)),
        ]) {
          c.save();
          c.translate(50 + dx * 0.3, 32);
          c.rotate(ang);
          final hojaRab = Path()
            ..moveTo(0, 4)
            ..quadraticBezierTo(-11, -10, -7, -22)
            ..quadraticBezierTo(0, -28, 7, -22)
            ..quadraticBezierTo(11, -10, 0, 4)
            ..close();
          c.drawPath(hojaRab, _fill(col));
          c.drawPath(hojaRab, _stroke(const Color(0xFF14532D), 1.8));
          c.drawLine(const Offset(0, 4), const Offset(0, -20), _stroke(const Color(0xFFBBF7D0), 1.8));
          c.restore();
        }
        // Cuerpo globoso del rábano (rojo carmesí arriba y punta blanca abajo)
        final cuerpoRab = Path()
          ..moveTo(50, 28)
          ..cubicTo(76, 28, 78, 60, 56, 72)
          ..lineTo(50, 88)
          ..lineTo(44, 72)
          ..cubicTo(22, 60, 24, 28, 50, 28)
          ..close();
        c.drawPath(
          cuerpoRab,
          _fillGrad(
            const Rect.fromLTWH(24, 28, 52, 60),
            const [Color(0xFFFB7185), Color(0xFFE11D48), Color(0xFF9F1239)],
          ),
        );
        // Base blanca típica del rábano y raicillas absorbentes
        final puntaBlanca = Path()
          ..moveTo(35, 63)
          ..quadraticBezierTo(50, 58, 65, 63)
          ..lineTo(56, 72)
          ..lineTo(50, 88)
          ..lineTo(44, 72)
          ..close();
        c.drawPath(puntaBlanca, _fill(const Color(0xFFFFF1F2)));
        c.drawPath(cuerpoRab, _stroke(const Color(0xFF881337), 2.4));
        c.drawOval(const Rect.fromLTWH(35, 36, 9, 14), _fill(Colors.white.withValues(alpha: 0.45)));
        c.drawLine(const Offset(45, 74), const Offset(34, 80), _stroke(const Color(0xFFFDA4AF), 1.8));
        c.drawLine(const Offset(55, 76), const Offset(66, 82), _stroke(const Color(0xFFFDA4AF), 1.8));
        break;

      case 'espinaca-hoja':
        // Manojo atado de hojas tiernas y abullonadas de espinaca con peciolos claros y nervadura ramificada
        _sombraSuelo(c, 50, 88, 42, 7);
        for (final (dx, ang, col1, col2) in [
          (-14.0, -0.32, const Color(0xFF22C55E), const Color(0xFF15803D)),
          (14.0, 0.32, const Color(0xFF22C55E), const Color(0xFF15803D)),
          (0.0, 0.0, const Color(0xFF4ADE80), const Color(0xFF16A34A)),
        ]) {
          c.save();
          c.translate(50 + dx * 0.35, 74);
          c.rotate(ang);
          // Peciolo (rabillo) verde claro
          c.drawLine(const Offset(0, 10), const Offset(0, -10), _stroke(const Color(0xFF86EFAC), 5.0));
          final esp = Path()
            ..moveTo(0, -8)
            ..cubicTo(-22, -14, -24, -42, -10, -54)
            ..quadraticBezierTo(0, -62, 10, -54)
            ..cubicTo(24, -42, 22, -14, 0, -8)
            ..close();
          c.drawPath(
            esp,
            _fillGrad(const Rect.fromLTWH(-22, -60, 44, 54), [col1, col2]),
          );
          c.drawPath(esp, _stroke(const Color(0xFF14532D), 2.2));
          // Nervio central y nervios secundarios
          c.drawLine(const Offset(0, -8), const Offset(0, -50), _stroke(const Color(0xFFBBF7D0), 2.4));
          for (final y in [-20.0, -32.0, -42.0]) {
            c.drawLine(Offset(0, y), Offset(-10, y - 6), _stroke(const Color(0xFF86EFAC), 1.6));
            c.drawLine(Offset(0, y), Offset(10, y - 6), _stroke(const Color(0xFF86EFAC), 1.6));
          }
          c.restore();
        }
        // Cinta de rafia atando los peciolos abajo
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(41, 72, 18, 6), const Radius.circular(3)),
          _fill(const Color(0xFFD97706)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(41, 72, 18, 6), const Radius.circular(3)),
          _stroke(const Color(0xFF78350F), 1.5),
        );
        break;

      case 'fresa-fruto':
        // Fresa roja acorazonada con relieve 3D, cáliz frondoso arriba y aquenios dorados en hoyuelos
        _sombraSuelo(c, 50, 86, 40, 7);
        final fresa = Path()
          ..moveTo(50, 84)
          ..cubicTo(18, 66, 18, 34, 36, 28)
          ..quadraticBezierTo(50, 32, 64, 28)
          ..cubicTo(82, 34, 82, 66, 50, 84)
          ..close();
        c.drawPath(
          fresa,
          _fillGrad(
            const Rect.fromLTWH(20, 26, 60, 58),
            const [Color(0xFFFB7185), Color(0xFFE11D48), Color(0xFF9F1239)],
          ),
        );
        c.drawPath(fresa, _stroke(const Color(0xFF881337), 2.5));
        c.drawOval(const Rect.fromLTWH(31, 36, 9, 16), _fill(Colors.white.withValues(alpha: 0.38)));
        for (final p in [
          const Offset(36, 42),
          const Offset(50, 44),
          const Offset(64, 42),
          const Offset(32, 54),
          const Offset(44, 56),
          const Offset(56, 56),
          const Offset(68, 54),
          const Offset(42, 68),
          const Offset(58, 68),
          const Offset(50, 75),
        ]) {
          c.drawOval(Rect.fromCenter(center: Offset(p.dx, p.dy + 1), width: 4.5, height: 6), _fill(const Color(0xFF881337)));
          c.drawOval(Rect.fromCenter(center: p, width: 3.2, height: 4.8), _fill(const Color(0xFFFEF08A)));
        }
        // Pedúnculo y corona estrellada de sépalos verdes
        c.drawLine(const Offset(50, 12), const Offset(50, 26), _stroke(const Color(0xFF15803D), 4.5));
        for (final (dx, dy) in [(-18.0, 32.0), (-9.0, 35.0), (0.0, 36.0), (9.0, 35.0), (18.0, 32.0)]) {
          final sep = Path()
            ..moveTo(50, 23)
            ..quadraticBezierTo(50 + dx * 0.6, 23, 50 + dx, dy)
            ..quadraticBezierTo(50 + dx * 0.3, 30, 50, 27)
            ..close();
          c.drawPath(sep, _fill(const Color(0xFF22C55E)));
          c.drawPath(sep, _stroke(const Color(0xFF14532D), 1.5));
        }
        break;

      case 'recursos-plantas':
      case 'recurso-tuberculo-raiz':
        // Emblema de despensa subterránea: tubérculo de almidón y raíz azucarera bajo tierra
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFFE4E6)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFDA4AF), 2));
        c.drawArc(const Rect.fromLTWH(10, 14, 80, 74), 0, math.pi, true, _fill(const Color(0xFF78350F)));
        c.drawLine(const Offset(12, 48), const Offset(88, 48), _stroke(const Color(0xFF451A03), 2.5));
        c.drawOval(const Rect.fromLTWH(22, 54, 28, 20), _fill(const Color(0xFFFBBF24)));
        c.drawOval(const Rect.fromLTWH(22, 54, 28, 20), _stroke(const Color(0xFF92400E), 2.0));
        c.drawCircle(const Offset(66, 62), 11, _fill(const Color(0xFFBE123C)));
        c.drawCircle(const Offset(66, 62), 11, _stroke(const Color(0xFF4C0519), 2.0));
        c.drawLine(const Offset(36, 48), const Offset(36, 30), _stroke(const Color(0xFF16A34A), 3.2));
        c.drawLine(const Offset(66, 48), const Offset(66, 30), _stroke(const Color(0xFF16A34A), 3.2));
        break;

      case 'recurso-bulbo-cereal':
        // Emblema de bulbo laminado en capas y espiga dorada de cereal
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFCD34D), 2));
        c.drawCircle(const Offset(36, 56), 16, _fill(Colors.white));
        for (final r in [16.0, 11.0, 6.0]) {
          c.drawCircle(const Offset(36, 56), r, _stroke(const Color(0xFFD97706), 2.2));
        }
        c.drawLine(const Offset(66, 76), const Offset(66, 24), _stroke(const Color(0xFFB45309), 3.2));
        for (final y in [32.0, 42.0, 52.0, 62.0]) {
          c.drawOval(Rect.fromCenter(center: Offset(61, y), width: 9, height: 6), _fill(const Color(0xFFFACC15)));
          c.drawOval(Rect.fromCenter(center: Offset(71, y), width: 9, height: 6), _fill(const Color(0xFFFACC15)));
          c.drawOval(Rect.fromCenter(center: Offset(61, y), width: 9, height: 6), _stroke(const Color(0xFFB45309), 1.3));
          c.drawOval(Rect.fromCenter(center: Offset(71, y), width: 9, height: 6), _stroke(const Color(0xFFB45309), 1.3));
        }
        break;

      case 'recurso-fibra-aceite':
        // Emblema de bobina textil de algodón y gota dorada de aceite de oliva
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFF86EFAC), 2));
        // Bobina de madera e hilo blanco
        c.drawRect(const Rect.fromLTWH(22, 30, 24, 5), _fill(const Color(0xFF92400E)));
        c.drawRect(const Rect.fromLTWH(22, 65, 24, 5), _fill(const Color(0xFF92400E)));
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(24, 35, 20, 30), const Radius.circular(4)),
          _fill(Colors.white),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(24, 35, 20, 30), const Radius.circular(4)),
          _stroke(const Color(0xFF64748B), 2.0),
        );
        for (final y in [42.0, 50.0, 58.0]) {
          c.drawLine(Offset(25, y), Offset(43, y), _stroke(const Color(0xFFCBD5E1), 1.8));
        }
        final gotaAceite = Path()
          ..moveTo(68, 26)
          ..cubicTo(84, 48, 82, 70, 68, 72)
          ..cubicTo(54, 70, 52, 48, 68, 26)
          ..close();
        c.drawPath(
          gotaAceite,
          _fillGrad(const Rect.fromLTWH(52, 26, 32, 46), const [Color(0xFFFACC15), Color(0xFF84CC16)]),
        );
        c.drawPath(gotaAceite, _stroke(const Color(0xFF4D7C0F), 2.2));
        c.drawCircle(const Offset(63, 56), 3.5, _fill(Colors.white.withValues(alpha: 0.6)));
        break;

      case 'patata-tuberculo':
        // Patata arriñonada de piel ocre con sus yemas ("ojos") y media patata cortada delante mostrando el almidón
        _sombraSuelo(c, 50, 84, 62, 9);
        final patata = Path()
          ..moveTo(16, 52)
          ..cubicTo(14, 28, 42, 20, 62, 26)
          ..cubicTo(82, 30, 86, 56, 70, 68)
          ..cubicTo(52, 76, 18, 72, 16, 52)
          ..close();
        c.drawPath(
          patata,
          _fillGrad(
            const Rect.fromLTWH(14, 22, 72, 54),
            const [Color(0xFFFDE68A), Color(0xFFD97706), Color(0xFFB45309)],
          ),
        );
        c.drawPath(patata, _stroke(const Color(0xFF78350F), 2.6));
        c.drawOval(const Rect.fromLTWH(28, 30, 18, 9), _fill(Colors.white.withValues(alpha: 0.35)));
        // Ojos (yemas) del tubérculo con pequeño brote
        for (final (ox, oy) in [(32.0, 44.0), (54.0, 36.0), (44.0, 56.0), (66.0, 48.0)]) {
          c.drawArc(
            Rect.fromCenter(center: Offset(ox, oy), width: 9, height: 5),
            0,
            math.pi,
            false,
            _stroke(const Color(0xFF78350F), 2.2),
          );
          c.drawCircle(Offset(ox, oy - 1.5), 1.8, _fill(const Color(0xFFFEF08A)));
        }
        // Rodaja/mitad delantera mostrando la pulpa blanca amarillenta rica en almidón
        c.drawOval(const Rect.fromLTWH(48, 54, 34, 24), _fill(const Color(0xFF92400E)));
        c.drawOval(const Rect.fromLTWH(50, 55, 30, 21), _fill(const Color(0xFFFEF9C3)));
        c.drawOval(const Rect.fromLTWH(48, 54, 34, 24), _stroke(const Color(0xFF78350F), 2.2));
        break;

      case 'remolacha-raiz':
        // Remolacha morada con hojas verdes de nervios carmesí y rodaja mostrando sus anillos concéntricos
        _sombraSuelo(c, 50, 88, 52, 7);
        // Penacho de 3 hojas verdes con peciolos y venas de color rojo remolacha
        for (final (dx, ang) in [(-14.0, -0.4), (14.0, 0.4), (0.0, 0.0)]) {
          c.save();
          c.translate(46 + dx * 0.3, 32);
          c.rotate(ang);
          final hojaRem = Path()
            ..moveTo(0, 4)
            ..cubicTo(-12, -8, -12, -22, 0, -25)
            ..cubicTo(12, -22, 12, -8, 0, 4)
            ..close();
          c.drawPath(hojaRem, _fill(const Color(0xFF15803D)));
          c.drawPath(hojaRem, _stroke(const Color(0xFF14532D), 1.8));
          c.drawLine(const Offset(0, 6), const Offset(0, -21), _stroke(const Color(0xFFF43F5E), 2.4));
          c.restore();
        }
        // Raíz globosa morada terminada en cola fina
        final raizRem = Path()
          ..moveTo(46, 30)
          ..cubicTo(72, 30, 74, 62, 52, 72)
          ..lineTo(46, 88)
          ..lineTo(40, 72)
          ..cubicTo(18, 62, 20, 30, 46, 30)
          ..close();
        c.drawPath(
          raizRem,
          _fillGrad(
            const Rect.fromLTWH(20, 30, 52, 58),
            const [Color(0xFFBE123C), Color(0xFF881337), Color(0xFF4C0519)],
          ),
        );
        c.drawPath(raizRem, _stroke(const Color(0xFF4C0519), 2.5));
        c.drawOval(const Rect.fromLTWH(31, 38, 8, 12), _fill(Colors.white.withValues(alpha: 0.28)));
        // Rodaja cortada a la derecha mostrando los anillos concéntricos morados y rosas
        c.drawCircle(const Offset(68, 66), 15, _fill(const Color(0xFF881337)));
        c.drawCircle(const Offset(68, 66), 15, _stroke(const Color(0xFF4C0519), 2.2));
        c.drawCircle(const Offset(68, 66), 11, _stroke(const Color(0xFFFDA4AF), 2.0));
        c.drawCircle(const Offset(68, 66), 6, _stroke(const Color(0xFFFDA4AF), 1.8));
        c.drawCircle(const Offset(68, 66), 2, _fill(const Color(0xFFFDA4AF)));
        break;

      case 'cebolla-bulbo':
        // Bulbo de cebolla dorada con túnicas papiráceas, cuello seco, raicillas y corte en capas blancas
        _sombraSuelo(c, 50, 88, 52, 7);
        // Brotes tubulares verdes asomando del cuello superior
        c.drawLine(const Offset(46, 24), const Offset(40, 10), _stroke(const Color(0xFF16A34A), 3.8));
        c.drawLine(const Offset(48, 24), const Offset(52, 8), _stroke(const Color(0xFF22C55E), 4.0));
        final bulbo = Path()
          ..moveTo(46, 20)
          ..cubicTo(52, 30, 76, 40, 72, 66)
          ..quadraticBezierTo(62, 78, 46, 78)
          ..quadraticBezierTo(30, 78, 20, 66)
          ..cubicTo(16, 40, 40, 30, 46, 20)
          ..close();
        c.drawPath(
          bulbo,
          _fillGrad(
            const Rect.fromLTWH(18, 20, 56, 58),
            const [Color(0xFFFBBF24), Color(0xFFD97706), Color(0xFF92400E)],
          ),
        );
        c.drawPath(bulbo, _stroke(const Color(0xFF78350F), 2.5));
        // Líneas curvas meridianas de la túnica seca y cabellera de raíces en la base
        for (final dx in [-14.0, -6.0, 4.0, 12.0]) {
          final nerv = Path()
            ..moveTo(46, 23)
            ..quadraticBezierTo(46 + dx * 1.6, 52, 46 + dx * 0.5, 77);
          c.drawPath(nerv, _stroke(const Color(0xFF92400E), 1.6));
        }
        for (final dx in [-10.0, -5.0, 0.0, 5.0, 10.0]) {
          c.drawLine(Offset(46 + dx * 0.6, 78), Offset(46 + dx, 87), _stroke(const Color(0xFF78350F), 1.8));
        }
        // Media cebolla cortada delante enseñando las capas blancas concéntricas
        c.drawCircle(const Offset(68, 66), 15, _fill(const Color(0xFFD97706)));
        c.drawCircle(const Offset(68, 66), 13.5, _fill(const Color(0xFFFFFBEB)));
        c.drawCircle(const Offset(68, 66), 15, _stroke(const Color(0xFF78350F), 2.0));
        c.drawCircle(const Offset(68, 66), 9.5, _stroke(const Color(0xFFF59E0B), 1.8));
        c.drawCircle(const Offset(68, 66), 5.0, _stroke(const Color(0xFFF59E0B), 1.8));
        break;

      case 'trigo-harina':
        // Dos espigas doradas de trigo trenzado con aristas (barbillas) y montoncito de harina blanca en la base
        _sombraSuelo(c, 50, 88, 54, 7);
        for (final (bx, ang) in [(36.0, -0.16), (52.0, 0.05)]) {
          c.save();
          c.translate(bx, 84);
          c.rotate(ang);
          c.drawLine(const Offset(0, 0), const Offset(0, -64), _stroke(const Color(0xFFB45309), 3.4));
          // Hoja envainadora dorada en el tallo
          final hojaTrigo = Path()
            ..moveTo(0, -18)
            ..quadraticBezierTo(-16, -32, -18, -46)
            ..quadraticBezierTo(-8, -34, 0, -24);
          c.drawPath(hojaTrigo, _fill(const Color(0xFFF59E0B)));
          // Barbillas (aristas) superiores
          for (final y in [-60.0, -50.0, -40.0, -30.0]) {
            c.drawLine(Offset(-6, y), Offset(-14, y - 12), _stroke(const Color(0xFFD97706), 1.3));
            c.drawLine(Offset(6, y), Offset(14, y - 12), _stroke(const Color(0xFFD97706), 1.3));
            c.drawOval(Rect.fromCenter(center: Offset(-5, y), width: 11, height: 7), _fill(const Color(0xFFFACC15)));
            c.drawOval(Rect.fromCenter(center: Offset(5, y), width: 11, height: 7), _fill(const Color(0xFFFACC15)));
            c.drawOval(Rect.fromCenter(center: Offset(-5, y), width: 11, height: 7), _stroke(const Color(0xFF92400E), 1.4));
            c.drawOval(Rect.fromCenter(center: Offset(5, y), width: 11, height: 7), _stroke(const Color(0xFF92400E), 1.4));
          }
          c.drawOval(Rect.fromCenter(center: const Offset(0, -66), width: 8, height: 11), _fill(const Color(0xFFFACC15)));
          c.drawOval(Rect.fromCenter(center: const Offset(0, -66), width: 8, height: 11), _stroke(const Color(0xFF92400E), 1.4));
          c.restore();
        }
        // Cuenco/montón de harina blanca recién molida a la derecha
        final harina = Path()
          ..moveTo(52, 82)
          ..quadraticBezierTo(68, 58, 84, 82)
          ..close();
        c.drawPath(harina, _fill(const Color(0xFFFFFBEB)));
        c.drawPath(harina, _stroke(const Color(0xFFD97706), 2.0));
        break;

      case 'algodon-fibra':
        // Cápsula leñosa abierta en estrella sosteniendo un copo blanco esponjoso de algodón
        _sombraSuelo(c, 50, 88, 44, 7);
        c.drawLine(const Offset(50, 86), const Offset(50, 58), _stroke(const Color(0xFF57534E), 4.5));
        // Brácteas/valvas leñosas marrones abiertas en la base de la cápsula
        for (final (dx, dy) in [(-24.0, 52.0), (24.0, 52.0), (-14.0, 68.0), (14.0, 68.0)]) {
          final valva = Path()
            ..moveTo(50, 60)
            ..quadraticBezierTo(50 + dx * 0.5, 66, 50 + dx, dy)
            ..quadraticBezierTo(50 + dx * 0.6, 54, 50, 56)
            ..close();
          c.drawPath(valva, _fill(const Color(0xFF78350F)));
          c.drawPath(valva, _stroke(const Color(0xFF451A03), 1.8));
        }
        // Cuatro lóbulos blancos esponjosos de fibra de algodón con volumen suave
        for (final (cx, cy, r) in [
          (36.0, 44.0, 15.0),
          (64.0, 44.0, 15.0),
          (50.0, 30.0, 16.0),
          (50.0, 48.0, 15.0),
        ]) {
          c.drawCircle(Offset(cx, cy), r, _fill(Colors.white));
          c.drawArc(
            Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
            -math.pi * 0.8,
            math.pi * 1.3,
            false,
            _stroke(const Color(0xFF94A3B8), 2.2),
          );
          c.drawArc(
            Rect.fromCenter(center: Offset(cx, cy + 2), width: r * 1.4, height: r * 1.2),
            0.2,
            math.pi * 0.6,
            false,
            _stroke(const Color(0xFFE2E8F0), 2.5),
          );
        }
        break;

      case 'aceituna-aceite':
        // Rama de olivo con hojas verde-plateadas, aceitunas brillantes y gota de aceite de oliva
        _sombraSuelo(c, 50, 88, 54, 7);
        c.drawLine(const Offset(14, 28), const Offset(84, 38), _stroke(const Color(0xFF78350F), 4.2));
        // Hojas lanceoladas de olivo (haz verde y envés plateado)
        for (final (ox, oy, ang, col) in [
          (28.0, 22.0, -0.45, const Color(0xFF4D7C0F)),
          (52.0, 24.0, -0.35, const Color(0xFF65A30D)),
          (72.0, 28.0, -0.25, const Color(0xFF94A3B8)),
        ]) {
          c.save();
          c.translate(ox, oy);
          c.rotate(ang);
          c.drawOval(Rect.fromCenter(center: Offset.zero, width: 26, height: 9), _fill(col));
          c.drawOval(Rect.fromCenter(center: Offset.zero, width: 26, height: 9), _stroke(const Color(0xFF365314), 1.6));
          c.restore();
        }
        // Tres aceitunas colgando (dos verdes y una morada en envero)
        for (final (ax, ay, col1, col2) in [
          (30.0, 56.0, const Color(0xFF84CC16), const Color(0xFF4D7C0F)),
          (52.0, 60.0, const Color(0xFF65A30D), const Color(0xFF365314)),
          (72.0, 56.0, const Color(0xFF701A75), const Color(0xFF3B0764)),
        ]) {
          c.drawLine(Offset(ax, 33), Offset(ax, ay - 10), _stroke(const Color(0xFF65A30D), 2.2));
          final rectAc = Rect.fromCenter(center: Offset(ax, ay), width: 18, height: 24);
          c.drawOval(rectAc, _fillGrad(rectAc, [col1, col2]));
          c.drawOval(rectAc, _stroke(const Color(0xFF1A2E05), 2.2));
          c.drawOval(Rect.fromCenter(center: Offset(ax - 3.5, ay - 4), width: 4, height: 7), _fill(Colors.white.withValues(alpha: 0.45)));
        }
        // Gotita dorada de aceite bajo la aceituna central
        final gotaOliva = Path()
          ..moveTo(52, 74)
          ..quadraticBezierTo(58, 82, 52, 86)
          ..quadraticBezierTo(46, 82, 52, 74)
          ..close();
        c.drawPath(gotaOliva, _fill(const Color(0xFFFACC15)));
        c.drawPath(gotaOliva, _stroke(const Color(0xFFB45309), 1.5));
        break;

      case 'partes-comestibles':
      case 'huerto-raiz-tallo':
        // Emblema partido de raíz subterránea con pelos absorbentes y tallo aéreo con nudos
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFCD34D), 2));
        c.drawArc(const Rect.fromLTWH(10, 14, 80, 74), 0, math.pi, true, _fill(const Color(0xFF78350F)));
        c.drawLine(const Offset(12, 50), const Offset(88, 50), _stroke(const Color(0xFF451A03), 2.5));
        // Tallo verde con nudos arriba y raíz ramificada abajo
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(44, 18, 12, 32), const Radius.circular(4)),
          _fill(const Color(0xFF16A34A)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(44, 18, 12, 32), const Radius.circular(4)),
          _stroke(const Color(0xFF14532D), 2.0),
        );
        c.drawLine(const Offset(44, 30), const Offset(56, 30), _stroke(const Color(0xFF86EFAC), 2.0));
        c.drawLine(const Offset(44, 40), const Offset(56, 40), _stroke(const Color(0xFF86EFAC), 2.0));
        c.drawLine(const Offset(50, 50), const Offset(50, 80), _stroke(const Color(0xFFFDE68A), 4.5));
        c.drawLine(const Offset(50, 60), const Offset(34, 74), _stroke(const Color(0xFFFDE68A), 3.0));
        c.drawLine(const Offset(50, 64), const Offset(66, 76), _stroke(const Color(0xFFFDE68A), 3.0));
        break;

      case 'zanahoria-raiz':
        // Zanahoria naranja con hombros redondeados, hojas plumosas verdes arriba y pelitos absorbentes laterales
        _sombraSuelo(c, 50, 90, 34, 6);
        // Frondes verdes divididas (hojas plumosas típicas de la zanahoria)
        for (final (dx, dy) in [(-12.0, 10.0), (0.0, 6.0), (12.0, 10.0)]) {
          c.drawLine(const Offset(50, 28), Offset(50 + dx, dy), _stroke(const Color(0xFF15803D), 3.5));
          for (final t in [0.45, 0.75, 1.0]) {
            final px = 50 + dx * t;
            final py = 28 + (dy - 28) * t;
            c.drawOval(Rect.fromCenter(center: Offset(px - 4, py), width: 7, height: 4), _fill(const Color(0xFF22C55E)));
            c.drawOval(Rect.fromCenter(center: Offset(px + 4, py), width: 7, height: 4), _fill(const Color(0xFF22C55E)));
          }
        }
        // Raíz principal cónica redondeada con degradado naranja
        final zan = Path()
          ..moveTo(32, 32)
          ..quadraticBezierTo(50, 24, 68, 32)
          ..cubicTo(70, 44, 58, 72, 50, 88)
          ..cubicTo(42, 72, 30, 44, 32, 32)
          ..close();
        c.drawPath(
          zan,
          _fillGrad(
            const Rect.fromLTWH(30, 26, 40, 62),
            const [Color(0xFFFB923C), Color(0xFFEA580C), Color(0xFFC2410C)],
          ),
        );
        c.drawPath(zan, _stroke(const Color(0xFF9A3412), 2.5));
        // Brillo vertical, surcos transversales y pelitos absorbentes laterales
        c.drawLine(const Offset(39, 34), const Offset(46, 72), _stroke(const Color(0xFFFED7AA).withValues(alpha: 0.65), 3.0));
        for (final (y, w) in [(42.0, 10.0), (54.0, 8.0), (66.0, 6.0), (76.0, 4.0)]) {
          c.drawLine(Offset(50 - w, y), Offset(50 + w * 0.6, y), _stroke(const Color(0xFF9A3412), 1.8));
        }
        c.drawLine(const Offset(35, 48), const Offset(25, 52), _stroke(const Color(0xFFFDBA74), 1.8));
        c.drawLine(const Offset(63, 56), const Offset(73, 60), _stroke(const Color(0xFFFDBA74), 1.8));
        c.drawLine(const Offset(40, 68), const Offset(30, 73), _stroke(const Color(0xFFFDBA74), 1.8));
        break;

      case 'esparrago-tallo':
        // Manojo de 3 espárragos verdes (turiones) con nudos escamosos, yema apical imbricada y cinta de rafia
        _sombraSuelo(c, 50, 88, 46, 7);
        for (final (x, yTop, h) in [(35.0, 22.0, 62.0), (65.0, 22.0, 62.0), (50.0, 14.0, 70.0)]) {
          final rectTallo = Rect.fromLTWH(x - 6.5, yTop + 12, 13, h - 12);
          c.drawRRect(
            RRect.fromRectAndRadius(rectTallo, const Radius.circular(5)),
            _fillGrad(rectTallo, const [Color(0xFF4ADE80), Color(0xFF16A34A), Color(0xFF15803D)]),
          );
          // Base blanquecina tierna del corte inferior
          c.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x - 6, yTop + h - 8, 12, 8), const Radius.circular(3)),
            _fill(const Color(0xFFDCFCE7)),
          );
          c.drawRRect(
            RRect.fromRectAndRadius(rectTallo, const Radius.circular(5)),
            _stroke(const Color(0xFF14532D), 2.0),
          );
          // Escamitas triangulares en los nudos del tallo
          for (final ny in [yTop + 26, yTop + 42]) {
            final escama = Path()
              ..moveTo(x - 6, ny)
              ..lineTo(x, ny - 6)
              ..lineTo(x + 6, ny)
              ..close();
            c.drawPath(escama, _fill(const Color(0xFF166534)));
          }
          // Yema apical en punta con escamas superpuestas verde-moradas
          final yema = Path()
            ..moveTo(x, yTop)
            ..cubicTo(x + 10, yTop + 6, x + 9, yTop + 16, x + 6.5, yTop + 16)
            ..lineTo(x - 6.5, yTop + 16)
            ..cubicTo(x - 9, yTop + 16, x - 10, yTop + 6, x, yTop)
            ..close();
          c.drawPath(yema, _fill(const Color(0xFF14532D)));
          c.drawPath(yema, _stroke(const Color(0xFF052E16), 2.0));
          for (final sy in [yTop + 5, yTop + 10, yTop + 14]) {
            c.drawLine(Offset(x - 5, sy), Offset(x, sy - 4), _stroke(const Color(0xFF86EFAC), 1.5));
            c.drawLine(Offset(x + 5, sy), Offset(x, sy - 4), _stroke(const Color(0xFF86EFAC), 1.5));
          }
        }
        // Cinta de rafia ocre atando el manojo por la mitad
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(26, 56, 48, 7), const Radius.circular(3.5)),
          _fill(const Color(0xFFF59E0B)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(26, 56, 48, 7), const Radius.circular(3.5)),
          _stroke(const Color(0xFF92400E), 1.8),
        );
        c.drawOval(const Rect.fromLTWH(44, 54, 12, 11), _fill(const Color(0xFFD97706)));
        c.drawOval(const Rect.fromLTWH(44, 54, 12, 11), _stroke(const Color(0xFF78350F), 1.6));
        break;

      case 'huerto-hoja-flor':
        // Emblema de lámina foliar con nervios y capullo floral cerrado de brácteas
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFF86EFAC), 2));
        final lamHoja = Path()
          ..moveTo(20, 72)
          ..cubicTo(16, 40, 32, 24, 54, 28)
          ..cubicTo(52, 54, 40, 70, 20, 72)
          ..close();
        c.drawPath(lamHoja, _fill(const Color(0xFF22C55E)));
        c.drawPath(lamHoja, _stroke(const Color(0xFF14532D), 2.0));
        c.drawLine(const Offset(20, 72), const Offset(48, 32), _stroke(const Color(0xFFDCFCE7), 2.0));
        // Capullo floral escamoso a la derecha
        c.drawLine(const Offset(68, 62), const Offset(68, 76), _stroke(const Color(0xFF15803D), 4.0));
        for (final (dx, dy) in [(-8.0, 50.0), (8.0, 50.0), (0.0, 42.0)]) {
          final brac = Path()
            ..moveTo(68 + dx, dy - 12)
            ..quadraticBezierTo(68 + dx + 8, dy, 68 + dx, dy + 10)
            ..quadraticBezierTo(68 + dx - 8, dy, 68 + dx, dy - 12)
            ..close();
          c.drawPath(brac, _fill(const Color(0xFF16A34A)));
          c.drawPath(brac, _stroke(const Color(0xFF14532D), 1.6));
        }
        break;

      case 'lechuga-hoja':
        // Cogollo fresco de lechuga con hojas exteriores rizadas y nervios blancos crujientes desde el tronco
        _sombraSuelo(c, 50, 86, 58, 8);
        // Corona exterior de hojas anchas y onduladas verde intenso
        for (final (cx, cy, r) in [
          (28.0, 48.0, 18.0),
          (72.0, 48.0, 18.0),
          (36.0, 32.0, 17.0),
          (64.0, 32.0, 17.0),
          (50.0, 26.0, 18.0),
          (26.0, 64.0, 16.0),
          (74.0, 64.0, 16.0),
        ]) {
          c.drawCircle(Offset(cx, cy), r, _fill(const Color(0xFF16A34A)));
          c.drawCircle(Offset(cx, cy), r, _stroke(const Color(0xFF14532D), 2.0));
        }
        // Capa intermedia de hojas rizadas verde vivo
        for (final (cx, cy, r) in [
          (36.0, 48.0, 16.0),
          (64.0, 48.0, 16.0),
          (50.0, 36.0, 17.0),
          (38.0, 64.0, 15.0),
          (62.0, 64.0, 15.0),
        ]) {
          c.drawCircle(Offset(cx, cy), r, _fill(const Color(0xFF4ADE80)));
          c.drawCircle(Offset(cx, cy), r, _stroke(const Color(0xFF15803D), 1.8));
        }
        // Cogollo tierno central verde claro con pencas/nervios blancos ramificados
        final cogollo = Path()
          ..moveTo(50, 82)
          ..cubicTo(28, 78, 28, 40, 50, 34)
          ..cubicTo(72, 40, 72, 78, 50, 82)
          ..close();
        c.drawPath(cogollo, _fill(const Color(0xFF86EFAC)));
        c.drawPath(cogollo, _stroke(const Color(0xFF15803D), 2.0));
        // Troncho blanco en la base y nervios blancos en abanico
        final penca = Path()
          ..moveTo(43, 82)
          ..lineTo(47, 42)
          ..lineTo(53, 42)
          ..lineTo(57, 82)
          ..close();
        c.drawPath(penca, _fill(const Color(0xFFF0FDF4)));
        for (final (x2, y2) in [(32.0, 48.0), (68.0, 48.0), (36.0, 34.0), (64.0, 34.0), (26.0, 62.0), (74.0, 62.0)]) {
          c.drawLine(const Offset(50, 74), Offset(x2, y2), _stroke(const Color(0xFFDCFCE7), 2.6));
        }
        break;

      case 'alcachofa-flor':
        // Alcachofa reconocible con tallo estriado, hojas arqueadas en la base y filas de brácteas puntiagudas superpuestas
        _sombraSuelo(c, 50, 88, 42, 7);
        // Tallo grueso estriado y dos hojas lobuladas en la base
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(44, 62, 12, 26), const Radius.circular(4)),
          _fill(const Color(0xFF15803D)),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(44, 62, 12, 26), const Radius.circular(4)),
          _stroke(const Color(0xFF14532D), 2.0),
        );
        final hojaIzq = Path()
          ..moveTo(45, 76)
          ..quadraticBezierTo(20, 72, 16, 56)
          ..quadraticBezierTo(28, 62, 45, 68)
          ..close();
        final hojaDer = Path()
          ..moveTo(55, 76)
          ..quadraticBezierTo(80, 72, 84, 56)
          ..quadraticBezierTo(72, 62, 55, 68)
          ..close();
        c.drawPath(hojaIzq, _fill(const Color(0xFF16A34A)));
        c.drawPath(hojaDer, _fill(const Color(0xFF16A34A)));
        c.drawPath(hojaIzq, _stroke(const Color(0xFF14532D), 1.8));
        c.drawPath(hojaDer, _stroke(const Color(0xFF14532D), 1.8));

        // Función local para dibujar cada bráctea (escama puntiaguda de la alcachofa)
        void dibujarBractea(double cx, double cy, double w, double h, Color col, {double ang = 0}) {
          c.save();
          c.translate(cx, cy);
          c.rotate(ang);
          final b = Path()
            ..moveTo(0, -h * 0.55)
            ..cubicTo(w * 0.65, -h * 0.15, w * 0.6, h * 0.45, 0, h * 0.5)
            ..cubicTo(-w * 0.6, h * 0.45, -w * 0.65, -h * 0.15, 0, -h * 0.55)
            ..close();
          c.drawPath(b, _fill(col));
          // Toque morado suave en la puntita superior típico de muchas alcachofas
          final puntaMorada = Path()
            ..moveTo(0, -h * 0.55)
            ..quadraticBezierTo(w * 0.22, -h * 0.3, 0, -h * 0.25)
            ..quadraticBezierTo(-w * 0.22, -h * 0.3, 0, -h * 0.55)
            ..close();
          c.drawPath(puntaMorada, _fill(const Color(0xFF7E22CE).withValues(alpha: 0.45)));
          c.drawPath(b, _stroke(const Color(0xFF14532D), 2.0));
          c.restore();
        }

        // Corona superior (punta cerrada del capullo)
        dibujarBractea(42, 26, 16, 22, const Color(0xFF86EFAC), ang: -0.18);
        dibujarBractea(58, 26, 16, 22, const Color(0xFF86EFAC), ang: 0.18);
        dibujarBractea(50, 22, 18, 24, const Color(0xFF4ADE80));
        // Fila media-alta de brácteas imbricadas
        dibujarBractea(32, 36, 18, 24, const Color(0xFF22C55E), ang: -0.28);
        dibujarBractea(68, 36, 18, 24, const Color(0xFF22C55E), ang: 0.28);
        dibujarBractea(41, 36, 19, 25, const Color(0xFF4ADE80), ang: -0.10);
        dibujarBractea(59, 36, 19, 25, const Color(0xFF4ADE80), ang: 0.10);
        // Fila media-baja
        dibujarBractea(28, 48, 19, 24, const Color(0xFF16A34A), ang: -0.35);
        dibujarBractea(72, 48, 19, 24, const Color(0xFF16A34A), ang: 0.35);
        dibujarBractea(39, 49, 20, 25, const Color(0xFF22C55E), ang: -0.14);
        dibujarBractea(61, 49, 20, 25, const Color(0xFF22C55E), ang: 0.14);
        dibujarBractea(50, 46, 21, 26, const Color(0xFF4ADE80));
        // Fila basal de brácteas exteriores abrazando el receptáculo
        dibujarBractea(34, 58, 18, 20, const Color(0xFF15803D), ang: -0.32);
        dibujarBractea(66, 58, 18, 20, const Color(0xFF15803D), ang: 0.32);
        dibujarBractea(44, 60, 18, 20, const Color(0xFF16A34A), ang: -0.1);
        dibujarBractea(56, 60, 18, 20, const Color(0xFF16A34A), ang: 0.1);
        break;

      case 'huerto-fruto-semilla':
        // Emblema de gajo de fruto jugoso y vaina con semillas redondas
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFFE4E6)));
        c.drawCircle(const Offset(50, 50), 42, _stroke(const Color(0xFFFDA4AF), 2));
        c.drawArc(const Rect.fromLTWH(16, 20, 44, 38), 0, math.pi, true, _fill(const Color(0xFFEF4444)));
        c.drawArc(const Rect.fromLTWH(16, 20, 44, 38), 0, math.pi, true, _stroke(const Color(0xFF991B1B), 2.0));
        c.drawCircle(const Offset(32, 46), 3, _fill(const Color(0xFFFEF08A)));
        c.drawCircle(const Offset(44, 46), 3, _fill(const Color(0xFFFEF08A)));
        final miniVaina = Path()
          ..moveTo(36, 72)
          ..quadraticBezierTo(58, 50, 82, 58)
          ..quadraticBezierTo(62, 82, 36, 72)
          ..close();
        c.drawPath(miniVaina, _fill(const Color(0xFF16A34A)));
        c.drawPath(miniVaina, _stroke(const Color(0xFF14532D), 2.0));
        for (final (px, py) in [(50.0, 67.0), (60.0, 64.0), (70.0, 61.0)]) {
          c.drawCircle(Offset(px, py), 4.5, _fill(const Color(0xFF86EFAC)));
        }
        break;

      case 'tomate-fruto':
        // Tomate rojo acharolado con gajos suaves, brillo y cáliz estrellado verde con rabillo
        _sombraSuelo(c, 50, 86, 52, 8);
        final rectTom = const Rect.fromLTWH(18, 28, 64, 54);
        c.drawOval(
          rectTom,
          _fillGrad(
            rectTom,
            const [Color(0xFFF87171), Color(0xFFEF4444), Color(0xFFB91C1C)],
          ),
        );
        c.drawOval(rectTom, _stroke(const Color(0xFF7F1D1D), 2.6));
        // Surcos suaves de los gajos y brillo especular blanco
        c.drawArc(const Rect.fromLTWH(32, 30, 36, 50), -math.pi * 0.4, math.pi * 0.8, false, _stroke(const Color(0xFFDC2626), 1.8));
        c.drawOval(const Rect.fromLTWH(27, 38, 12, 18), _fill(Colors.white.withValues(alpha: 0.45)));
        // Pedúnculo verde curvado y cáliz estrellado de 5 sépalos largos
        c.drawPath(
          Path()
            ..moveTo(50, 31)
            ..quadraticBezierTo(52, 18, 58, 14),
          _stroke(const Color(0xFF15803D), 4.5),
        );
        for (final (dx, dy) in [(-22.0, 36.0), (-12.0, 42.0), (0.0, 44.0), (12.0, 42.0), (22.0, 36.0)]) {
          final sepTom = Path()
            ..moveTo(50, 28)
            ..quadraticBezierTo(50 + dx * 0.5, 26, 50 + dx, dy)
            ..quadraticBezierTo(50 + dx * 0.4, 34, 50, 32)
            ..close();
          c.drawPath(sepTom, _fill(const Color(0xFF16A34A)));
          c.drawPath(sepTom, _stroke(const Color(0xFF14532D), 1.6));
        }
        break;

      case 'guisante-vaina':
      case 'guisante-semilla':
        // Vaina verde curvada con su cáliz y rabillo, abierta mostrando 5 semillas esféricas brillantes
        _sombraSuelo(c, 50, 84, 60, 8);
        // Rabillo y pequeño cáliz en el extremo izquierdo
        c.drawLine(const Offset(10, 56), const Offset(18, 60), _stroke(const Color(0xFF15803D), 4.0));
        // Valva trasera e interior de la vaina abierta
        final vainaFondo = Path()
          ..moveTo(16, 60)
          ..cubicTo(36, 22, 66, 18, 88, 32)
          ..cubicTo(72, 68, 44, 78, 16, 60)
          ..close();
        c.drawPath(vainaFondo, _fill(const Color(0xFF15803D)));
        c.drawPath(vainaFondo, _stroke(const Color(0xFF14532D), 2.5));
        final cavidad = Path()
          ..moveTo(22, 58)
          ..cubicTo(38, 30, 64, 26, 82, 35)
          ..cubicTo(68, 60, 44, 68, 22, 58)
          ..close();
        c.drawPath(cavidad, _fill(const Color(0xFFDCFCE7)));
        // Fila de 5 guisantes redondos en 3D dentro de la vaina
        for (final (gx, gy, r) in [
          (30.0, 54.0, 6.8),
          (41.0, 50.0, 7.6),
          (53.0, 46.0, 8.0),
          (65.0, 42.0, 7.4),
          (75.0, 38.0, 6.2),
        ]) {
          final rectG = Rect.fromCircle(center: Offset(gx, gy), radius: r);
          c.drawCircle(Offset(gx, gy), r, _fillGrad(rectG, const [Color(0xFF86EFAC), Color(0xFF16A34A)]));
          c.drawCircle(Offset(gx, gy), r, _stroke(const Color(0xFF14532D), 1.8));
          c.drawCircle(Offset(gx - r * 0.3, gy - r * 0.3), r * 0.28, _fill(Colors.white.withValues(alpha: 0.65)));
        }
        // Borde inferior de la valva delantera abrazando los guisantes
        final valvaDelantera = Path()
          ..moveTo(16, 60)
          ..quadraticBezierTo(48, 60, 88, 32)
          ..cubicTo(72, 72, 44, 80, 16, 60)
          ..close();
        c.drawPath(
          valvaDelantera,
          _fillGrad(
            const Rect.fromLTWH(16, 32, 72, 48),
            const [Color(0xFF4ADE80), Color(0xFF16A34A)],
          ),
        );
        c.drawPath(valvaDelantera, _stroke(const Color(0xFF14532D), 2.4));
        break;

      case 'savia-planta':
      case 'proceso-savia-bruta':
      case 'savia-bruta':
        // Emblema de gota azul con sales minerales y flecha ascendente
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFE0F2FE)));
        final gotaBruta = Path()
          ..moveTo(50, 22)
          ..quadraticBezierTo(72, 50, 66, 70)
          ..quadraticBezierTo(50, 84, 34, 70)
          ..quadraticBezierTo(28, 50, 50, 22);
        c.drawPath(gotaBruta, _fill(const Color(0xFF38BDF8)));
        c.drawLine(const Offset(50, 68), const Offset(50, 38), _stroke(Colors.white, 3.5));
        break;

      case 'absorcion-raiz':
        // Pelos absorbentes de la raíz tomando agua bajo tierra
        c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(16, 36, 68, 48), const Radius.circular(12)),
          _fill(const Color(0xFF78350F)),
        );
        c.drawLine(const Offset(50, 18), const Offset(50, 74), _stroke(const Color(0xFFFDE68A), 6));
        c.drawLine(const Offset(50, 48), const Offset(28, 64), _stroke(const Color(0xFFFDE68A), 3.5));
        c.drawLine(const Offset(50, 54), const Offset(72, 70), _stroke(const Color(0xFFFDE68A), 3.5));
        c.drawCircle(const Offset(26, 52), 4.5, _fill(const Color(0xFF38BDF8)));
        c.drawCircle(const Offset(72, 54), 4.5, _fill(const Color(0xFF38BDF8)));
        break;

      case 'subida-xilema':
      case 'ascenso-tallo':
        // Tallo verde cortado mostrando los conductos azules del xilema subiendo
        c.drawRect(const Rect.fromLTWH(34, 18, 32, 66), _fill(const Color(0xFF16A34A)));
        c.drawLine(const Offset(44, 78), const Offset(44, 24), _stroke(const Color(0xFF38BDF8), 4));
        c.drawLine(const Offset(56, 78), const Offset(56, 24), _stroke(const Color(0xFF38BDF8), 4));
        break;

      case 'proceso-fotosintesis':
      case 'fotosintesis-hoja':
        // Emblema de fábrica solar en la hoja
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF9C3)));
        c.drawCircle(const Offset(32, 32), 11, _fill(const Color(0xFFFACC15)));
        c.drawOval(const Rect.fromLTWH(38, 44, 38, 24), _fill(const Color(0xFF22C55E)));
        break;

      case 'captura-luz-sol':
      case 'clorofila-sol':
        // Rayos de sol incidiendo sobre los cloroplastos verdes de la hoja
        c.drawCircle(const Offset(26, 26), 12, _fill(const Color(0xFFFACC15)));
        c.drawLine(const Offset(38, 38), const Offset(56, 54), _stroke(const Color(0xFFF59E0B), 3));
        final hojaFoto = Path()
          ..moveTo(32, 76)
          ..quadraticBezierTo(38, 36, 82, 34)
          ..quadraticBezierTo(74, 76, 32, 76);
        c.drawPath(hojaFoto, _fill(const Color(0xFF22C55E)));
        c.drawPath(hojaFoto, _stroke(const Color(0xFF15803D), 2.5));
        break;

      case 'entrada-co2-hoja':
      case 'estomas-aire':
        // Poros microscópicos (estomas) abriéndose en el envés de la hoja
        c.drawCircle(const Offset(50, 50), 36, _fill(const Color(0xFF4ADE80)));
        c.drawArc(const Rect.fromLTWH(30, 34, 40, 32), math.pi * 0.5, math.pi, false, _stroke(const Color(0xFF15803D), 6));
        c.drawArc(const Rect.fromLTWH(30, 34, 40, 32), -math.pi * 0.5, math.pi, false, _stroke(const Color(0xFF15803D), 6));
        c.drawOval(const Rect.fromLTWH(42, 40, 16, 20), _fill(const Color(0xFFE0F2FE)));
        break;

      case 'proceso-savia-elaborada':
      case 'savia-elaborada':
        // Emblema de gota dorada nutritiva con flechas de reparto
        c.drawCircle(const Offset(50, 50), 42, _fill(const Color(0xFFFEF3C7)));
        c.drawCircle(const Offset(50, 50), 16, _fill(const Color(0xFFF59E0B)));
        c.drawLine(const Offset(50, 20), const Offset(50, 80), _stroke(const Color(0xFFB45309), 3.5));
        break;

      case 'reparto-floema':
      case 'reparto-planta':
        // Vasos del floema repartiendo gotas doradas de alimento por el tallo
        c.drawRect(const Rect.fromLTWH(40, 18, 20, 66), _fill(const Color(0xFF16A34A)));
        c.drawCircle(const Offset(50, 32), 6.5, _fill(const Color(0xFFF59E0B)));
        c.drawCircle(const Offset(50, 52), 6.5, _fill(const Color(0xFFF59E0B)));
        c.drawCircle(const Offset(50, 72), 6.5, _fill(const Color(0xFFF59E0B)));
        break;

      default:
        c.drawCircle(const Offset(50, 50), 36, _fill(const Color(0xFFDCFCE7)));
        c.drawCircle(const Offset(50, 50), 36, _stroke(const Color(0xFF16A34A), 3));
    }
  }

  @override
  bool shouldRepaint(covariant _PintorNuevoJuego oldDelegate) =>
      oldDelegate.id != id;
}


class _HerramientaLab {
  const _HerramientaLab({
    required this.icono,
    required this.etiqueta,
    required this.color,
  });

  final IconData icono;
  final String etiqueta;
  final Color color;
}

class InspectorInteractivoNuevoJuego extends StatefulWidget {
  const InspectorInteractivoNuevoJuego({
    super.key,
    required this.actividadId,
    required this.nivel,
    required this.opciones,
    required this.retos,
    required this.respuestas,
    required this.seleccionado,
    this.sitioElegido,
    required this.lugarAcertado,
    this.bloqueado = false,
    required this.alSeleccionar,
    required this.alAsignar,
  });

  final String actividadId;
  final String nivel;
  final List<Opcion> opciones;
  final List<Reto> retos;
  final Map<String, String> respuestas;
  final String seleccionado;
  final String? sitioElegido;
  final bool lugarAcertado;
  final bool bloqueado;
  final ValueChanged<String> alSeleccionar;
  final void Function(String retoId, String sitioId) alAsignar;

  @override
  State<InspectorInteractivoNuevoJuego> createState() =>
      _InspectorInteractivoNuevoJuegoState();
}

class _InspectorInteractivoNuevoJuegoState
    extends State<InspectorInteractivoNuevoJuego> {
  int _modoHerramienta = 0;

  @override
  void didUpdateWidget(covariant InspectorInteractivoNuevoJuego oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actividadId != widget.actividadId ||
        oldWidget.nivel != widget.nivel) {
      _modoHerramienta = 0;
    }
  }

  List<_HerramientaLab> _herramientas() {
    switch (widget.actividadId) {
      case 'dieta':
        if (widget.nivel == 'dificil') {
          return const [
            _HerramientaLab(
              icono: Icons.pets_rounded,
              etiqueta: 'Molde de barro',
              color: Color(0xFFD97706),
            ),
            _HerramientaLab(
              icono: Icons.search_rounded,
              etiqueta: 'Lupa de dedos',
              color: Color(0xFF0284C7),
            ),
            _HerramientaLab(
              icono: Icons.terrain_rounded,
              etiqueta: 'Terreno y paso',
              color: Color(0xFF16A34A),
            ),
          ];
        }
        return const [
          _HerramientaLab(
            icono: Icons.visibility_rounded,
            etiqueta: 'Rayos X dentadura',
            color: Color(0xFF0284C7),
          ),
          _HerramientaLab(
            icono: Icons.restaurant_rounded,
            etiqueta: 'Probar menú',
            color: Color(0xFF16A34A),
          ),
          _HerramientaLab(
            icono: Icons.architecture_rounded,
            etiqueta: 'Forma del pico/boca',
            color: Color(0xFFD97706),
          ),
        ];

      case 'grupos':
        return const [
          _HerramientaLab(
            icono: Icons.flourescent_rounded,
            etiqueta: 'Rayos X esqueleto',
            color: Color(0xFF0284C7),
          ),
          _HerramientaLab(
            icono: Icons.shield_outlined,
            etiqueta: 'Lupa de piel/coraza',
            color: Color(0xFFD97706),
          ),
          _HerramientaLab(
            icono: Icons.pin_rounded,
            etiqueta: 'Contar patas y alas',
            color: Color(0xFF7C3AED),
          ),
        ];

      case 'polinizacion':
        if (widget.nivel == 'facil') {
          return const [
            _HerramientaLab(
              icono: Icons.place_rounded,
              etiqueta: 'Posición en la flor',
              color: Color(0xFF0284C7),
            ),
            _HerramientaLab(
              icono: Icons.emoji_nature_rounded,
              etiqueta: 'Capullo y abeja',
              color: Color(0xFFD97706),
            ),
            _HerramientaLab(
              icono: Icons.auto_awesome_rounded,
              etiqueta: 'De la flor al fruto',
              color: Color(0xFF16A34A),
            ),
          ];
        }
        if (widget.nivel == 'medio') {
          return const [
            _HerramientaLab(
              icono: Icons.air_rounded,
              etiqueta: 'Soplar viento',
              color: Color(0xFF0284C7),
            ),
            _HerramientaLab(
              icono: Icons.water_rounded,
              etiqueta: 'Soltar en el agua',
              color: Color(0xFF0891B2),
            ),
            _HerramientaLab(
              icono: Icons.pets_rounded,
              etiqueta: 'Probar con animal',
              color: Color(0xFFD97706),
            ),
          ];
        }
        return const [
          _HerramientaLab(
            icono: Icons.cut_rounded,
            etiqueta: 'Cortar y ver interior',
            color: Color(0xFFE11D48),
          ),
          _HerramientaLab(
            icono: Icons.zoom_in_rounded,
            etiqueta: 'Lupa de semillas/soros',
            color: Color(0xFFD97706),
          ),
          _HerramientaLab(
            icono: Icons.water_drop_rounded,
            etiqueta: 'Humedad y hábitat',
            color: Color(0xFF16A34A),
          ),
        ];

      case 'estaciones':
        if (widget.nivel == 'facil') {
          return const [
            _HerramientaLab(
              icono: Icons.local_florist_rounded,
              etiqueta: 'Primavera y verano',
              color: Color(0xFF16A34A),
            ),
            _HerramientaLab(
              icono: Icons.air_rounded,
              etiqueta: 'Otoño (viento)',
              color: Color(0xFFD97706),
            ),
            _HerramientaLab(
              icono: Icons.ac_unit_rounded,
              etiqueta: 'Invierno (frío)',
              color: Color(0xFF0284C7),
            ),
          ];
        }
        if (widget.nivel == 'medio') {
          return const [
            _HerramientaLab(
              icono: Icons.zoom_in_rounded,
              etiqueta: 'Lupa: hoja y fruto',
              color: Color(0xFF16A34A),
            ),
            _HerramientaLab(
              icono: Icons.wb_sunny_rounded,
              etiqueta: 'Calor de verano',
              color: Color(0xFFD97706),
            ),
            _HerramientaLab(
              icono: Icons.ac_unit_rounded,
              etiqueta: 'Frío de invierno',
              color: Color(0xFF0284C7),
            ),
          ];
        }
        return const [
          _HerramientaLab(
            icono: Icons.bar_chart_rounded,
            etiqueta: 'Climograma anual',
            color: Color(0xFF0284C7),
          ),
          _HerramientaLab(
            icono: Icons.eco_rounded,
            etiqueta: 'Hoja y corteza',
            color: Color(0xFF16A34A),
          ),
          _HerramientaLab(
            icono: Icons.shield_rounded,
            etiqueta: 'Estación crítica',
            color: Color(0xFFD97706),
          ),
        ];

      case 'huerta':
        if (widget.nivel == 'dificil') {
          return const [
            _HerramientaLab(
              icono: Icons.agriculture_rounded,
              etiqueta: 'Planta en campo',
              color: Color(0xFF16A34A),
            ),
            _HerramientaLab(
              icono: Icons.zoom_in_rounded,
              etiqueta: 'Interior y reserva',
              color: Color(0xFFD97706),
            ),
            _HerramientaLab(
              icono: Icons.inventory_2_rounded,
              etiqueta: 'Recurso obtenido',
              color: Color(0xFF0284C7),
            ),
          ];
        }
        return const [
          _HerramientaLab(
            icono: Icons.layers_rounded,
            etiqueta: 'Surco del huerto',
            color: Color(0xFF92400E),
          ),
          _HerramientaLab(
            icono: Icons.content_cut_rounded,
            etiqueta: 'Cuchillo de corte',
            color: Color(0xFFE11D48),
          ),
          _HerramientaLab(
            icono: Icons.wb_sunny_rounded,
            etiqueta: 'Función en la planta',
            color: Color(0xFF16A34A),
          ),
        ];

      default:
        return const [
          _HerramientaLab(
            icono: Icons.search_rounded,
            etiqueta: 'Observar',
            color: Color(0xFF0284C7),
          ),
        ];
    }
  }

  String _observacionHerramienta(Reto reto) {
    final id = reto.id;
    final resp = reto.respuesta;

    if (widget.actividadId == 'dieta') {
      if (widget.nivel == 'dificil') {
        if (_modoHerramienta == 0) {
          return resp == 'huella-pezuna'
              ? 'En el barro quedan marcados estuches córneos duros sin uñas sueltas.'
              : resp == 'huella-garra'
              ? 'En el barro aparecen 4 almohadillas redondas delante de un cojinete plantar.'
              : 'En la orilla húmeda se ve el abanico de piel que une los dedos entre sí.';
        }
        if (_modoHerramienta == 1) {
          return id == 'lince-huella'
              ? '¡Detalle clave! Sus uñas son retráctiles: las esconde al caminar para no hacer ruido.'
              : id == 'lobo-huella'
              ? 'Sus uñas no se esconden: quedan 4 puntitos marcados delante de las almohadillas.'
              : resp == 'huella-pezuna'
              ? 'Pezuña de queratina muy resistente: protege la punta de los dedos.'
              : 'Membrana interdigital flexible estirada entre los dedos de la pata.';
        }
        return resp == 'huella-pezuna'
            ? 'Le sirve para trepar por riscos de piedra o galopar sin desgastarse los dedos.'
            : resp == 'huella-garra'
            ? 'Camina en silencio sobre las almohadillas y usa las garras para sujetar.'
            : 'Funciona como un remo natural para impulsarse dentro del agua.';
      }

      // facil & medio de dieta
      if (_modoHerramienta == 0) {
        if (resp == 'dieta-herbivoro' ||
            resp == 'boca-herbivoro' ||
            resp == 'adaptacion-triturar-roer') {
          return 'Rayos X: incisivos delanteros como cinceles o tijeras y muelas anchas y planas para moler.';
        }
        if (resp == 'dieta-carnivoro' ||
            resp == 'boca-carnivoro' ||
            resp == 'adaptacion-desgarrar') {
          return 'Rayos X: grandes colmillos puntiagudos o pico ganchudo afilado para desgarrar.';
        }
        if (resp == 'adaptacion-filtrar-pescar') {
          return 'Rayos X: pico largo como pinza de pesca o con laminillas finas para colar el agua.';
        }
        return 'Rayos X: dentadura mixta o pico versátil que combina corte y trituración.';
      }
      if (_modoHerramienta == 1) {
        if (resp == 'dieta-herbivoro' ||
            resp == 'boca-herbivoro' ||
            resp == 'adaptacion-triturar-roer') {
          return 'Menú en el plato: hojas tiernas, hierba, cortezas, piñones, semillas y frutos del campo.';
        }
        if (resp == 'dieta-carnivoro' ||
            resp == 'boca-carnivoro' ||
            resp == 'adaptacion-desgarrar') {
          return 'Menú en el plato: caza otros animales (roedores, peces, insectos o presas).';
        }
        if (resp == 'adaptacion-filtrar-pescar') {
          return 'Menú en el plato: peces escurridizos, ranas o diminutos crustáceos y algas del agua.';
        }
        return 'Menú en el plato: aprovecha tanto semillas, raíces y bellotas como insectos o lombrices.';
      }
      return pistaRetoNuevoJuego(id, widget.actividadId);
    }

    if (widget.actividadId == 'grupos') {
      if (_modoHerramienta == 0) {
        if (resp == 'grupo-vertebrado' || resp.startsWith('vert-')) {
          return 'Escáner de Rayos X: ¡Brilla una columna vertebral con cráneo y huesos internos!';
        }
        return 'Escáner de Rayos X: NO hay columna vertebral ni huesos dentro de su cuerpo.';
      }
      if (_modoHerramienta == 1) {
        if (resp == 'vert-mamifero' || resp == 'vert-mamifero-ave') {
          return 'Lupa de piel: cuerpo cubierto de pelo (mamífero) o plumas ligeras (ave); mantienen su calor.';
        }
        if (resp == 'vert-ave') {
          return 'Lupa de piel: cuerpo cubierto de plumas ligeras y pico córneo sin dientes.';
        }
        if (resp == 'vert-reptil' || resp == 'vert-reptil-anfibio') {
          return 'Lupa de piel: escamas duras e impermeables (reptil) o piel desnuda y húmeda (anfibio).';
        }
        if (resp == 'vert-anfibio') {
          return 'Lupa de piel: piel desnuda, fina y siempre húmeda; sufre metamorfosis.';
        }
        if (resp == 'vert-pez') {
          return 'Lupa de piel: escamas brillantes para nadar y branquias para respirar en el agua.';
        }
        if (resp == 'inv-artropodo') {
          return 'Lupa de cubierta: exoesqueleto rígido como una armadura articulada con bisagras.';
        }
        if (resp == 'inv-molusco') {
          return 'Lupa de cubierta: cuerpo blando musculoso (con concha calcárea o tentáculos).';
        }
        if (resp == 'inv-anelido-cnidario') {
          return 'Lupa de cubierta: cuerpo blando y húmedo (dividido en anillos o gelatinoso).';
        }
        return pistaRetoNuevoJuego(id, widget.actividadId);
      }
      // Modo 2: Contar patas y alas
      if (id == 'arana-tela') {
        return 'Contador: 8 patas articuladas y 0 antenas (arácnido dentro de los artrópodos).';
      }
      if (id == 'cangrejo-playa' || id == 'cangrejo-rio') {
        return 'Contador: 10 patas articuladas (las 2 primeras son pinzas: crustáceo artrópodo).';
      }
      if (id == 'abeja-colmena' ||
          id == 'mariposa-flor' ||
          id == 'escarabajo-corteza') {
        return 'Contador: 6 patas articuladas, 2 antenas y alas (insecto artrópodo).';
      }
      if (id == 'murcielago-noche' || id == 'murcielago-cueva') {
        return 'Contador: sus alas son dedos largos de hueso unidos por piel; tiene pelo y orejas.';
      }
      return pistaRetoNuevoJuego(id, widget.actividadId);
    }

    if (widget.actividadId == 'polinizacion') {
      if (widget.nivel == 'facil') {
        if (_modoHerramienta == 0) {
          return id == 'sepalo-verde'
              ? 'Mapa floral: estas hojitas verdes brotan en la base más externa, justo debajo del resto de la flor.'
              : id == 'petalo-color'
              ? 'Mapa floral: forman un abanico coloreado que rodea y resguarda los órganos internos.'
              : id == 'antena-polen'
              ? 'Mapa floral: son hilitos finos dispuestos en anillo alrededor del centro, con dos bolsitas arriba.'
              : id == 'saco-polinico'
              ? 'Mapa floral: estas bolsitas cargadas de polvillo amarillo se abren en la punta de los filamentos.'
              : id == 'estigma-cuello'
              ? 'Mapa floral: asoma justo en el eje central de la flor como un cuello alto con la punta húmeda.'
              : 'Mapa floral: se esconde en el fondo central de la flor y guarda diminutos óvulos en su interior.';
        }
        if (_modoHerramienta == 1) {
          return id == 'sepalo-verde'
              ? 'Función: abriga el capullo cerrado frente a la lluvia y el frío, y al abrirse sostiene la flor.'
              : id == 'petalo-color'
              ? 'Función: sus colores vivos, su aroma y sus líneas guía atraen a la abeja como una pista de aterrizaje.'
              : id == 'antena-polen'
              ? 'Función: el filamento acerca las bolsitas hacia arriba para que rocen el lomo de la abeja al entrar.'
              : id == 'saco-polinico'
              ? 'Función: al abrirse las bolsitas, los granos de polen se pegan al pelaje de la abeja para viajar.'
              : id == 'estigma-cuello'
              ? 'Función: su punta pegajosa atrapa el polen que trae la abeja y lo guía por el cuello hacia abajo.'
              : 'Función: recibe el polen que baja desde la entrada central para fecundar los óvulos de su interior.';
        }
        return id == 'sepalo-verde'
            ? 'Al formarse el fruto: tras proteger el capullo, suele quedar como la estrellita verde junto al rabillo.'
            : id == 'petalo-color'
            ? 'Al formarse el fruto: una vez atraídos los insectos, se marchita y cae dejando paso al fruto.'
            : (id == 'antena-polen' || id == 'saco-polinico')
            ? 'Al formarse el fruto: tras vaciarse todas las bolsitas de polen, se seca y acaba cayendo.'
            : id == 'estigma-cuello'
            ? 'Al formarse el fruto: cuando el polen ya ha bajado hasta la cámara inferior, su punta se seca.'
            : 'Al formarse el fruto: ¡se hincha y engorda poco a poco hasta transformarse en el fruto con semillas!';
      }
      if (widget.nivel == 'medio') {
        if (_modoHerramienta == 0) {
          return resp == 'viaje-viento'
              ? '¡Vuela! Como pesa poquísimo y tiene pelitos o alas, la brisa la lleva planeando.'
              : 'Con el viento apenas se mueve porque es demasiado pesada o necesita otro transporte.';
        }
        if (_modoHerramienta == 1) {
          return resp == 'viaje-agua'
              ? '¡Flota sin hundirse! Tiene cámaras de aire o fibras impermeables para viajar por el agua.'
              : 'En el agua no es su medio principal: prefiere viajar por el aire o con animales.';
        }
        return resp == 'viaje-animal'
            ? '¡Viaja con animales! O bien se engancha al pelo como velcro o es un fruto carnoso.'
            : pistaRetoNuevoJuego(id, widget.actividadId);
      }
      // dificil de polinizacion
      if (_modoHerramienta == 0) {
        return resp == 'planta-angiosperma'
            ? 'Al cortarlo vemos un fruto cerrado y jugoso que guarda las semillas protegidas dentro.'
            : resp == 'planta-gimnosperma'
            ? 'No hay fruto carnoso: las semillas (piñones) están apoyadas entre escamas de madera.'
            : 'No tiene flores ni semillas: se reproduce mediante diminutas esporas.';
      }
      return pistaRetoNuevoJuego(id, widget.actividadId);
    }

    if (widget.actividadId == 'estaciones') {
      if (widget.nivel == 'facil') {
        if (_modoHerramienta == 0) {
          return id == 'cerezo-valle'
              ? 'En primavera el cerezo se llena de flores y en verano luce su copa verde con cerezas.'
              : 'En primavera y verano el árbol mantiene su copa verde fabricando alimento con el sol.';
        }
        if (_modoHerramienta == 1) {
          return (resp == 'arbol-caduca' || resp == 'arbol-caduco')
              ? 'En otoño sus hojas pierden la clorofila verde, se vuelven doradas o cobrizas y caen.'
              : 'En otoño sus hojas resistentes continúan verdes en la copa sin desprenderse.';
        }
        return (resp == 'arbol-caduca' || resp == 'arbol-caduco')
            ? 'En invierno descansa con las ramas desnudas y las yemas cerradas para resistir el hielo.'
            : 'En invierno conserva toda su copa verde aguantando el frío sin quedarse desnudo.';
      }
      if (widget.nivel == 'medio') {
        if (_modoHerramienta == 0) {
          return id == 'roble-lobulada'
              ? 'Lupa botánica: hoja ancha y blanda con lóbulos redondeados junto a una bellota.'
              : id == 'castano-aserrada'
              ? 'Lupa botánica: hoja grande y fina con borde en dientes de sierra y erizo de castaña.'
              : id == 'encina-coriacea'
              ? 'Lupa botánica: hoja pequeña, gruesa como el cuero y con pelillos blancos en el envés.'
              : id == 'olivo-lanceolada'
              ? 'Lupa botánica: hoja alargada de haz verde y envés plateado junto a las aceitunas.'
              : id == 'pino-acicula'
              ? 'Lupa botánica: agujas largas unidas de dos en dos en la base junto a una piña leñosa.'
              : 'Lupa botánica: ramilletes de agujas cortas y rígidas junto a una piña erguida en barril.';
        }
        if (_modoHerramienta == 1) {
          return resp == 'hoja-lobulada-aserrada'
              ? 'Calor de verano (38 °C): al ser tan ancha y fina, evapora mucha agua si el aire está seco.'
              : resp == 'hoja-entera-dura'
              ? 'Calor de verano (38 °C): su cubierta de cera refleja el sol y cierra los poros para retener el agua.'
              : 'Calor de verano (38 °C): al tener forma de aguja muy estrecha, apenas pierde humedad.';
        }
        return resp == 'hoja-lobulada-aserrada'
            ? 'Frío de invierno: tira todas sus hojas en otoño para no helarse y deja las yemas protegidas.'
            : resp == 'hoja-entera-dura'
            ? 'Frío de invierno: conserva sus hojas duras en la copa durante todo el año.'
            : 'Frío de invierno: su resina anticongelante impide que el hielo rompa sus agujas bajo la nieve.';
      }
      // dificil de estaciones (bosques y clima)
      if (_modoHerramienta == 0) {
        return resp == 'bosque-atlantico'
            ? 'Climograma: barras azules altas en las 4 estaciones (llueve todo el año) y temperaturas suaves.'
            : resp == 'bosque-mediterraneo'
            ? 'Climograma: pico de calor en verano con barra de lluvia casi nula (fuerte sequía estival).'
            : 'Climograma: temperaturas invernales bajo 0 °C con precipitaciones en forma de nieve.';
      }
      if (_modoHerramienta == 1) {
        return id == 'hayedo-niebla'
            ? 'Corteza lisa gris plateada y hoja ovalada muy fina y tierna que necesita sombra húmeda.'
            : id == 'robledal-humedo'
            ? 'Corteza parda fisurada y hoja ancha lobulada que se renueva cada primavera.'
            : id == 'alcornocal-corcho'
            ? 'Gruesa corteza esponjosa de corcho que aísla del calor y hoja pequeña y dura.'
            : id == 'encinar-seco'
            ? 'Corteza oscura agrietada y hoja coriácea con envés blanquecino que frena la evaporación.'
            : id == 'pinar-cumbre'
            ? 'Corteza escamosa rojiza y agujas rígidas en parejas cargadas de resina protectora.'
            : 'Corteza gris con ampollas de resina, agujas planas con dos bandas blancas y piña erguida.';
      }
      return resp == 'bosque-atlantico'
          ? 'Estación crítica (invierno): el árbol queda desnudo y sus hojas caídas forman un mantillo fértil.'
          : resp == 'bosque-mediterraneo'
          ? 'Estación crítica (verano seco): sus raíces profundas buscan agua subterránea mientras cierra sus poros.'
          : 'Estación crítica (nevadas): sus ramas elásticas en cono se inclinan para dejar resbalar la nieve.';
    }

    if (widget.actividadId == 'huerta') {
      if (widget.nivel == 'dificil') {
        if (_modoHerramienta == 0) {
          return resp == 'recurso-tuberculo-raiz'
              ? 'En el campo: el órgano engrosado crece enterrado bajo el suelo acumulando nutrientes.'
              : id == 'cebolla-bulbo'
              ? 'En el campo: el bulbo redondo se forma bajo tierra en la base de las hojas verdes.'
              : id == 'trigo-harina'
              ? 'En el campo: planta herbácea de tallo fino rematada en una espiga dorada al sol.'
              : id == 'algodon-fibra'
              ? 'En el campo: arbusto cuyas cápsulas maduras se abren mostrando copos blancos.'
              : 'En el campo: fruto del olivo que madura en las ramas durante el otoño.';
        }
        if (_modoHerramienta == 1) {
          return id == 'patata-tuberculo'
              ? 'Lupa interior: es un tallo subterráneo (tubérculo) con yemas ("ojos") rico en almidón.'
              : id == 'remolacha-raiz'
              ? 'Lupa interior: es una raíz carnosa de color morado muy rica en sacarosa (azúcar).'
              : id == 'cebolla-bulbo'
              ? 'Lupa interior: formado por capas (túnicas) carnosas superpuestas que guardan reservas.'
              : id == 'trigo-harina'
              ? 'Lupa interior: granos secos de cereal ricos en hidratos de carbono.'
              : id == 'algodon-fibra'
              ? 'Lupa interior: largas hebras blancas de celulosa vegetal que envuelven las semillas.'
              : 'Lupa interior: pulpa carnosa rica en gotitas de aceite vegetal y hueso central.';
        }
        return resp == 'recurso-tuberculo-raiz'
            ? 'Recurso: alimento energético directo y obtención de almidón o azúcar.'
            : resp == 'recurso-bulbo-cereal'
            ? 'Recurso: hortaliza de bulbo para cocina o molienda del grano para hacer harina y pan.'
            : 'Recurso: hilado de fibras para fabricar tejidos de ropa o prensado para aceite de oliva.';
      }
      // facil y medio de huerta
      if (_modoHerramienta == 0) {
        if (resp == 'huerta-raiz' || id == 'zanahoria-raiz' || id == 'rabano-raiz') {
          return 'Surco del huerto: crece bajo tierra con pelitos absorbentes y asoma el penacho de hojas.';
        }
        if (id == 'esparrago-tallo') {
          return 'Surco del huerto: es un tallo tierno vertical que brota recto desde la tierra.';
        }
        if (resp == 'huerta-hoja' || id == 'lechuga-hoja' || id == 'espinaca-hoja') {
          return 'Surco del huerto: son las láminas verdes abiertas a la luz del sol sobre el suelo.';
        }
        if (id == 'alcachofa-flor') {
          return 'Surco del huerto: crece en lo alto del tallo como un capullo floral antes de abrirse.';
        }
        return 'Surco del huerto: cuelga de las ramas aéreas tras transformarse la flor fecundada.';
      }
      if (_modoHerramienta == 1) {
        if (resp == 'huerta-fruto' || resp == 'huerto-fruto-semilla') {
          return id == 'guisante-vaina'
              ? 'Al abrir la vaina encontramos la fila de semillas redondas (guisantes) listas para germinar.'
              : 'Al cortarlo por la mitad vemos la pulpa jugosa que protege las semillas (pepitas).';
        }
        if (resp == 'huerta-hoja' || resp == 'huerto-hoja-flor') {
          return id == 'alcachofa-flor'
              ? 'Al cortarla vemos las hojitas tiernas (brácteas) del capullo floral, sin semillas.'
              : 'Al cortarla vemos láminas verdes con nervios y sin semillas en su interior.';
        }
        return 'Al cortarlo vemos anillos macizos y crujientes de raíz o tallo, sin semillas dentro.';
      }
      return pistaRetoNuevoJuego(id, widget.actividadId);
    }

    return pistaRetoNuevoJuego(id, widget.actividadId);
  }

  String _tituloLaboratorio() {
    switch (widget.actividadId) {
      case 'dieta':
        return widget.nivel == 'dificil'
            ? 'Mesa de rastreo de huellas'
            : 'Laboratorio de picos y dentaduras';
      case 'grupos':
        return 'Escáner anatómico de animales';
      case 'polinizacion':
        return widget.nivel == 'facil'
            ? 'Mesa de disección de la flor'
            : widget.nivel == 'medio'
            ? 'Túnel de vuelo, agua y animales'
            : 'Comparador de frutos, piñas y esporas';
      case 'estaciones':
        return widget.nivel == 'facil'
            ? 'Simulador de las 4 estaciones'
            : widget.nivel == 'medio'
            ? 'Herbario interactivo de hojas'
            : 'Estación meteorológica del bosque';
      case 'huerta':
        return widget.nivel == 'dificil'
            ? 'Laboratorio de cultivos y recursos'
            : 'Mesa de corte y surco del huerto';
      default:
        return 'Laboratorio interactivo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final retoActual = widget.retos.firstWhere(
      (r) => r.id == widget.seleccionado,
      orElse: () => widget.retos.first,
    );
    final herramientas = _herramientas();
    final modoSeguro = _modoHerramienta.clamp(0, herramientas.length - 1);
    final herramientaActiva = herramientas[modoSeguro];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Selector compacto de muestras del nivel
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          ),
          child: Row(
            children: [
              Text(
                context.traducir('Muestras:'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final r in widget.retos)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            key: Key('pieza-${r.id}'),
                            borderRadius: BorderRadius.circular(99),
                            onTap: widget.bloqueado
                                ? null
                                : () => widget.alSeleccionar(r.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: r.id == retoActual.id
                                    ? const Color(0xFF0284C7)
                                    : widget.respuestas.containsKey(r.id)
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: r.id == retoActual.id
                                      ? const Color(0xFF0369A1)
                                      : widget.respuestas.containsKey(r.id)
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.respuestas.containsKey(r.id)) ...[
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 13,
                                      color: r.id == retoActual.id
                                          ? Colors.white
                                          : const Color(0xFF16A34A),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    context.traducir(r.nombre),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: r.id == retoActual.id
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Laboratorio visual interactivo (centro)
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF0F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFBAE6FD), width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Visor gráfico interactivo a la izquierda
                Expanded(
                  flex: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _modoHerramienta =
                            (_modoHerramienta + 1) % herramientas.length;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: herramientaActiva.color.withValues(alpha: 0.55),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 26, 10, 24),
                              child: CustomPaint(
                                painter: _PintorLaboratorioInteractivo(
                                  actividadId: widget.actividadId,
                                  nivel: widget.nivel,
                                  retoId: retoActual.id,
                                  respuestaId: retoActual.respuesta,
                                  modo: modoSeguro,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            left: 8,
                            right: 8,
                            child: Row(
                              children: [
                                Icon(
                                  herramientaActiva.icono,
                                  size: 14,
                                  color: herramientaActiva.color,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    context.traducir(_tituloLaboratorio()),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: herramientaActiva.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 8,
                            right: 8,
                            child: Text(
                              context.traducir(
                                'Toca el visor o las herramientas para investigar',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Panel derecho: herramientas de prueba + observación científica
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (int i = 0; i < herramientas.length; i++)
                            InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() => _modoHerramienta = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: modoSeguro == i
                                      ? herramientas[i].color
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: herramientas[i].color,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      herramientas[i].icono,
                                      size: 13,
                                      color: modoSeguro == i
                                          ? Colors.white
                                          : herramientas[i].color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.traducir(herramientas[i].etiqueta),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: modoSeguro == i
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.biotech_rounded,
                                      size: 16,
                                      color: Color(0xFF0284C7),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        context.traducir(retoActual.nombre),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.traducir(
                                    _observacionHerramienta(retoActual),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    height: 1.28,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
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
        const SizedBox(height: 8),

        // 3. Tarjetas de clasificación inferior
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < widget.opciones.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _TarjetaDestinoNuevoJuego(
                    opcion: widget.opciones[i],
                    retoActualId: retoActual.id,
                    elegido: widget.sitioElegido == widget.opciones[i].id,
                    acertado:
                        widget.sitioElegido == widget.opciones[i].id &&
                        widget.lugarAcertado,
                    bloqueado: widget.bloqueado,
                    alElegir: () =>
                        widget.alAsignar(retoActual.id, widget.opciones[i].id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaDestinoNuevoJuego extends StatelessWidget {
  const _TarjetaDestinoNuevoJuego({
    required this.opcion,
    required this.retoActualId,
    required this.elegido,
    required this.acertado,
    required this.bloqueado,
    required this.alElegir,
  });

  final Opcion opcion;
  final String retoActualId;
  final bool elegido;
  final bool acertado;
  final bool bloqueado;
  final VoidCallback alElegir;

  @override
  Widget build(BuildContext context) {
    final fondoBase = colorSitioNuevoJuego(opcion.id);
    final bordeBase = bordeSitioNuevoJuego(opcion.id);
    final subtitulo = subtituloSitioNuevoJuego(opcion.id);

    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !bloqueado,
      onAcceptWithDetails: (_) => alElegir(),
      builder: (context, candidatos, _) {
        final encima = candidatos.isNotEmpty;
        return TarjetaJuego(
          claveAccion: Key('sitio-${opcion.id}'),
          onTap: bloqueado ? null : alElegir,
          radio: 16,
          destacada: acertado || elegido || encima,
          fondo: acertado
              ? const Color(0xFFDCFCE7)
              : elegido
              ? const Color(0xFFFEF3C7)
              : encima
              ? const Color(0xFFE0F2FE)
              : fondoBase,
          borde: acertado
              ? const Color(0xFF16A34A)
              : elegido
              ? const Color(0xFFD97706)
              : encima
              ? const Color(0xFF0284C7)
              : bordeBase,
          child: Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DibujoNuevoJuego(id: opcion.id, tamano: 36),
                  const SizedBox(height: 4),
                  Text(
                    context.traducir(opcion.nombre),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitulo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      context.traducir(subtitulo),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PintorLaboratorioInteractivo extends CustomPainter {
  const _PintorLaboratorioInteractivo({
    required this.actividadId,
    required this.nivel,
    required this.retoId,
    required this.respuestaId,
    required this.modo,
  });

  final String actividadId;
  final String nivel;
  final String retoId;
  final String respuestaId;
  final int modo;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 220;
    final sy = size.height / 120;
    final s = math.min(sx, sy);
    canvas.save();
    canvas.translate(
      (size.width - 220 * s) / 2,
      (size.height - 120 * s) / 2,
    );
    canvas.scale(s, s);

    // 1. Muestra principal a la izquierda del lienzo (0..100, 10..110)
    canvas.save();
    canvas.translate(8, 10);
    const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
    canvas.restore();

    // Flecha conectora hacia la simulación derecha
    final lapizFlecha = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(108, 60), const Offset(124, 60), lapizFlecha);

    // 2. Resultado interactivo a la derecha (125..212, 12..108)
    final cajaDer = RRect.fromRectAndRadius(
      const Rect.fromLTWH(124, 12, 88, 96),
      const Radius.circular(14),
    );
    canvas.drawRRect(
      cajaDer,
      Paint()
        ..color = (actividadId == 'grupos' && modo == 0)
            ? const Color(0xFF0F172A)
            : const Color(0xFFF1F5F9),
    );

    canvas.save();
    canvas.translate(128, 20);
    canvas.scale(0.8, 0.8);

    Paint fill(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.fill;
    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (actividadId == 'dieta') {
      if (nivel == 'facil') {
        if (modo == 0) {
          final idBoca = respuestaId == 'dieta-herbivoro'
              ? 'boca-herbivoro'
              : respuestaId == 'dieta-carnivoro'
                  ? 'boca-carnivoro'
                  : 'boca-omnivoro';
          const _PintorNuevoJuego()._dibujarIcono(canvas, idBoca);
        } else if (modo == 1) {
          final bandeja = RRect.fromRectAndRadius(
            const Rect.fromLTWH(10, 18, 80, 64),
            const Radius.circular(12),
          );
          canvas.drawRRect(bandeja, fill(const Color(0xFFFEFCE8)));
          canvas.drawRRect(bandeja, stroke(const Color(0xFFD97706), 2.0));
          if (respuestaId == 'dieta-herbivoro') {
            for (final (ox, oy, ang) in [(28.0, 50.0, -0.35), (48.0, 42.0, 0.25)]) {
              canvas.save();
              canvas.translate(ox, oy);
              canvas.rotate(ang);
              final h = Rect.fromCenter(center: Offset.zero, width: 26, height: 14);
              canvas.drawOval(h, fill(const Color(0xFF22C55E)));
              canvas.drawOval(h, stroke(const Color(0xFF14532D), 1.8));
              canvas.drawLine(const Offset(-10, 0), const Offset(10, 0), stroke(const Color(0xFFBBF7D0), 1.4));
              canvas.restore();
            }
            const bel = Rect.fromLTWH(56, 42, 18, 22);
            canvas.drawOval(bel, fill(const Color(0xFFB45309)));
            canvas.drawOval(bel, stroke(const Color(0xFF451A03), 1.8));
            canvas.drawArc(const Rect.fromLTWH(54, 36, 22, 14), math.pi, math.pi, true, fill(const Color(0xFF78350F)));
          } else if (respuestaId == 'dieta-carnivoro') {
            canvas.drawLine(const Offset(24, 52), const Offset(76, 52), stroke(const Color(0xFF475569), 10));
            canvas.drawLine(const Offset(24, 52), const Offset(76, 52), stroke(Colors.white, 6.5));
            for (final o in [const Offset(22, 48), const Offset(22, 56), const Offset(78, 48), const Offset(78, 56)]) {
              canvas.drawCircle(o, 5, fill(Colors.white));
              canvas.drawCircle(o, 5, stroke(const Color(0xFF475569), 1.5));
            }
            const corte = Rect.fromLTWH(32, 34, 36, 34);
            canvas.drawOval(corte, fill(const Color(0xFFEF4444)));
            canvas.drawOval(corte, stroke(const Color(0xFF7F1D1D), 2.0));
            canvas.drawCircle(const Offset(50, 51), 7, fill(const Color(0xFFFEE2E2)));
            canvas.drawCircle(const Offset(50, 51), 7, stroke(const Color(0xFF991B1B), 1.5));
          } else {
            for (final o in [const Offset(26, 42), const Offset(38, 38), const Offset(32, 48)]) {
              canvas.drawCircle(o, 6.5, fill(const Color(0xFFE11D48)));
              canvas.drawCircle(o, 6.5, stroke(const Color(0xFF881337), 1.5));
            }
            const raiz = Rect.fromLTWH(20, 58, 28, 12);
            canvas.drawOval(raiz, fill(const Color(0xFFD97706)));
            canvas.drawOval(raiz, stroke(const Color(0xFF78350F), 1.6));
            const pez = Rect.fromLTWH(48, 42, 32, 16);
            canvas.drawOval(pez, fill(const Color(0xFF38BDF8)));
            canvas.drawOval(pez, stroke(const Color(0xFF0C4A6E), 1.8));
          }
        } else {
          final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 80, 68), const Radius.circular(12));
          canvas.drawRRect(marco, fill(const Color(0xFFF8FAFC)));
          canvas.drawRRect(marco, stroke(const Color(0xFF64748B), 2.0));
          if (respuestaId == 'dieta-herbivoro') {
            for (double x = 26; x <= 62; x += 12) {
              final r1 = RRect.fromRectAndRadius(Rect.fromLTWH(x, 26, 11, 14), const Radius.circular(3));
              final r2 = RRect.fromRectAndRadius(Rect.fromLTWH(x, 60, 11, 14), const Radius.circular(3));
              canvas.drawRRect(r1, fill(const Color(0xFFFEFCE8)));
              canvas.drawRRect(r1, stroke(const Color(0xFF475569), 1.6));
              canvas.drawRRect(r2, fill(const Color(0xFFFEFCE8)));
              canvas.drawRRect(r2, stroke(const Color(0xFF475569), 1.6));
            }
            canvas.drawLine(const Offset(22, 50), const Offset(78, 50), stroke(const Color(0xFF16A34A), 3.5));
            canvas.drawCircle(const Offset(22, 50), 4, fill(const Color(0xFF16A34A)));
            canvas.drawCircle(const Offset(78, 50), 4, fill(const Color(0xFF16A34A)));
          } else if (respuestaId == 'dieta-carnivoro') {
            final tijSup = Path()..moveTo(28, 22)..lineTo(44, 56)..lineTo(58, 22)..close();
            final tijInf = Path()..moveTo(42, 78)..lineTo(56, 44)..lineTo(72, 78)..close();
            canvas.drawPath(tijSup, fill(Colors.white));
            canvas.drawPath(tijSup, stroke(const Color(0xFF334155), 2.0));
            canvas.drawPath(tijInf, fill(Colors.white));
            canvas.drawPath(tijInf, stroke(const Color(0xFF334155), 2.0));
            canvas.drawLine(const Offset(22, 26), const Offset(22, 74), stroke(const Color(0xFFE11D48), 3.5));
          } else {
            canvas.drawCircle(const Offset(50, 50), 22, stroke(const Color(0xFFD97706), 3.5));
            canvas.drawLine(const Offset(50, 22), const Offset(50, 78), stroke(const Color(0xFF0284C7), 3.0));
          }
        }
      } else if (nivel == 'medio') {
        final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 80, 68), const Radius.circular(12));
        if (modo == 0) {
          canvas.drawRRect(marco, fill(const Color(0xFFFEF3C7)));
          canvas.drawRRect(marco, stroke(const Color(0xFFD97706), 2.0));
          if (respuestaId == 'adaptacion-desgarrar') {
            final gancho = Path()
              ..moveTo(24, 30)
              ..quadraticBezierTo(72, 24, 74, 68)
              ..quadraticBezierTo(52, 50, 24, 52)
              ..close();
            canvas.drawPath(gancho, fill(const Color(0xFFF59E0B)));
            canvas.drawPath(gancho, stroke(const Color(0xFF78350F), 2.2));
            canvas.drawLine(const Offset(68, 58), const Offset(78, 76), stroke(const Color(0xFFDC2626), 3.5));
          } else if (respuestaId == 'adaptacion-filtrar-pescar') {
            canvas.drawLine(const Offset(20, 44), const Offset(80, 44), stroke(const Color(0xFF78350F), 8));
            canvas.drawLine(const Offset(20, 44), const Offset(80, 44), stroke(const Color(0xFFF59E0B), 5));
            canvas.drawLine(const Offset(20, 56), const Offset(80, 52), stroke(const Color(0xFF78350F), 6));
            for (double x = 28; x <= 72; x += 8) {
              canvas.drawLine(Offset(x, 45), Offset(x, 53), stroke(const Color(0xFFFEF08A), 1.8));
            }
          } else {
            for (final x in [34.0, 52.0]) {
              final inc = RRect.fromRectAndRadius(Rect.fromLTWH(x, 20, 14, 30), const Radius.circular(3));
              canvas.drawRRect(inc, fill(const Color(0xFFFB923C)));
              canvas.drawRRect(inc, stroke(const Color(0xFF7C2D12), 2.0));
            }
            final tronco = RRect.fromRectAndRadius(const Rect.fromLTWH(20, 56, 60, 18), const Radius.circular(4));
            canvas.drawRRect(tronco, fill(const Color(0xFF78350F)));
            canvas.drawRRect(tronco, stroke(const Color(0xFF451A03), 2.0));
          }
        } else if (modo == 1) {
          // Simulación en charca: pesca/filtrado en el agua vs pico/dientes secos fuera del agua
          canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
          canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 2.0));
          canvas.drawRect(const Rect.fromLTWH(12, 54, 76, 28), fill(const Color(0xFFBAE6FD)));
          canvas.drawArc(const Rect.fromLTWH(14, 48, 72, 12), 0, math.pi, false, stroke(const Color(0xFF0284C7), 2.8));
          if (respuestaId == 'adaptacion-filtrar-pescar') {
            const pez = Rect.fromLTWH(34, 58, 30, 13);
            canvas.drawOval(pez, fill(const Color(0xFF0284C7)));
            canvas.drawOval(pez, stroke(const Color(0xFF0C4A6E), 1.8));
            canvas.drawLine(const Offset(50, 20), const Offset(50, 62), stroke(const Color(0xFFF59E0B), 5.0));
            canvas.drawCircle(const Offset(50, 62), 6, stroke(Colors.white, 2.0));
          } else {
            // El agua escurre sin lamelas filtradoras; los peces nadan al fondo
            const pezFondo = Rect.fromLTWH(42, 66, 24, 10);
            canvas.drawOval(pezFondo, fill(const Color(0xFF64748B)));
            for (final dx in [36.0, 50.0, 64.0]) {
              canvas.drawCircle(Offset(dx, 38), 3.2, fill(const Color(0xFF38BDF8)));
              canvas.drawLine(Offset(dx, 26), Offset(dx, 34), stroke(const Color(0xFF38BDF8), 2.0));
            }
          }
        } else {
          // Simulación con semilla blindada / madera dura
          canvas.drawRRect(marco, fill(const Color(0xFFDCFCE7)));
          canvas.drawRRect(marco, stroke(const Color(0xFF16A34A), 2.0));
          const nuez = Rect.fromLTWH(32, 36, 36, 36);
          canvas.drawOval(nuez, fill(const Color(0xFF78350F)));
          canvas.drawOval(nuez, stroke(const Color(0xFF451A03), 2.2));
          if (respuestaId == 'adaptacion-triturar-roer') {
            // Incisivos abriendo la cáscara dura con grieta brillante
            canvas.drawRect(const Rect.fromLTWH(43, 18, 6, 16), fill(const Color(0xFFFB923C)));
            canvas.drawRect(const Rect.fromLTWH(51, 18, 6, 16), fill(const Color(0xFFFB923C)));
            canvas.drawLine(const Offset(50, 34), const Offset(44, 54), stroke(const Color(0xFFFEF08A), 3.8));
            canvas.drawLine(const Offset(44, 54), const Offset(54, 72), stroke(const Color(0xFFFEF08A), 3.8));
          } else {
            // La cáscara permanece intacta y cerrada (flechas rebotando en la superficie dura)
            canvas.drawOval(const Rect.fromLTWH(40, 42, 12, 7), fill(Colors.white.withValues(alpha: 0.25)));
            canvas.drawArc(const Rect.fromLTWH(26, 24, 48, 20), math.pi * 1.15, math.pi * 0.7, false, stroke(const Color(0xFF64748B), 2.5));
          }
        }
      } else {
        if (modo == 0) {
          final ext = RRect.fromRectAndRadius(const Rect.fromLTWH(12, 14, 76, 72), const Radius.circular(10));
          canvas.drawRRect(ext, fill(const Color(0xFFD6D3D1)));
          canvas.drawRRect(ext, stroke(const Color(0xFF57534E), 2.2));
          canvas.drawRect(const Rect.fromLTWH(18, 20, 64, 60), fill(const Color(0xFFA8A29E)));
          if (retoId == 'lobo-huella') {
            canvas.drawOval(const Rect.fromLTWH(36, 52, 28, 18), fill(const Color(0xFF292524)));
            for (final (dx, dy) in [(-16.0, 42.0), (-6.0, 36.0), (6.0, 36.0), (16.0, 42.0)]) {
              canvas.drawOval(Rect.fromCenter(center: Offset(50 + dx, dy), width: 8, height: 11), fill(const Color(0xFF292524)));
              canvas.drawCircle(Offset(50 + dx, dy - 8), 2.2, fill(const Color(0xFF0C0A09)));
            }
          } else if (retoId == 'lince-huella') {
            canvas.drawOval(const Rect.fromLTWH(34, 52, 32, 18), fill(const Color(0xFF44403C)));
            for (final (dx, dy) in [(-16.0, 42.0), (-6.0, 36.0), (6.0, 36.0), (16.0, 42.0)]) {
              canvas.drawCircle(Offset(50 + dx, dy), 5.2, fill(const Color(0xFF44403C)));
            }
          } else if (retoId == 'nutria-huella') {
            final fan = Path()..moveTo(50, 70)..lineTo(24, 36)..quadraticBezierTo(50, 28, 76, 36)..close();
            canvas.drawPath(fan, fill(const Color(0xFF57534E)));
            for (final dx in [-18.0, -9.0, 0.0, 9.0, 18.0]) {
              canvas.drawLine(const Offset(50, 68), Offset(50 + dx, 34), stroke(const Color(0xFF292524), 2.5));
            }
          } else if (retoId == 'cabra-montes') {
            canvas.drawOval(const Rect.fromLTWH(28, 28, 17, 42), fill(const Color(0xFF1C1917)));
            canvas.drawOval(const Rect.fromLTWH(55, 28, 17, 42), fill(const Color(0xFF1C1917)));
          } else {
            canvas.drawArc(const Rect.fromLTWH(26, 26, 48, 48), math.pi * 0.82, math.pi * 1.36, false, stroke(const Color(0xFF1C1917), 11));
          }
        } else if (modo == 1) {
          canvas.drawCircle(const Offset(50, 50), 36, fill(const Color(0xFFFFFBEB)));
          canvas.drawCircle(const Offset(50, 50), 36, stroke(const Color(0xFF0284C7), 3));
          if (retoId == 'lobo-huella') {
            const dedo = Rect.fromLTWH(22, 38, 36, 24);
            canvas.drawOval(dedo, fill(const Color(0xFF64748B)));
            canvas.drawOval(dedo, stroke(const Color(0xFF1E293B), 2.0));
            final garra = Path()..moveTo(54, 41)..quadraticBezierTo(74, 44, 78, 54)..quadraticBezierTo(64, 56, 54, 57)..close();
            canvas.drawPath(garra, fill(const Color(0xFF0F172A)));
          } else if (retoId == 'lince-huella') {
            const dedo = Rect.fromLTWH(24, 36, 48, 28);
            canvas.drawOval(dedo, fill(const Color(0xFFF59E0B)));
            canvas.drawOval(dedo, stroke(const Color(0xFF78350F), 2.0));
            canvas.drawOval(const Rect.fromLTWH(38, 44, 22, 12), stroke(const Color(0xFF78350F), 2.2));
          } else if (retoId == 'nutria-huella') {
            final memb = Path()..moveTo(28, 70)..lineTo(32, 28)..quadraticBezierTo(50, 42, 68, 28)..lineTo(72, 70)..close();
            canvas.drawPath(memb, fill(const Color(0xFF7DD3FC)));
            canvas.drawPath(memb, stroke(const Color(0xFF0284C7), 1.8));
            canvas.drawLine(const Offset(30, 68), const Offset(32, 28), stroke(const Color(0xFF78350F), 5.5));
            canvas.drawLine(const Offset(70, 68), const Offset(68, 28), stroke(const Color(0xFF78350F), 5.5));
          } else {
            final casco = RRect.fromRectAndRadius(const Rect.fromLTWH(28, 26, 44, 46), const Radius.circular(6));
            canvas.drawRRect(casco, fill(const Color(0xFF44403C)));
            canvas.drawRRect(casco, stroke(const Color(0xFF1C1917), 2.4));
          }
        } else {
          final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 80, 68), const Radius.circular(12));
          if (retoId == 'nutria-huella') {
            canvas.drawRRect(marco, fill(const Color(0xFFBAE6FD)));
            canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 2.0));
            canvas.drawArc(const Rect.fromLTWH(18, 36, 64, 18), 0, math.pi, false, stroke(const Color(0xFF0284C7), 3.5));
            canvas.drawArc(const Rect.fromLTWH(18, 56, 64, 18), 0, math.pi, false, stroke(const Color(0xFF0284C7), 3.5));
          } else if (retoId == 'cabra-montes' || retoId == 'caballo-galope') {
            canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
            canvas.drawRRect(marco, stroke(const Color(0xFF64748B), 2.0));
            final cumbre = Path()..moveTo(14, 80)..lineTo(46, 24)..lineTo(86, 80)..close();
            canvas.drawPath(cumbre, fill(const Color(0xFF94A3B8)));
            canvas.drawPath(cumbre, stroke(const Color(0xFF334155), 2.0));
          } else {
            canvas.drawRRect(marco, fill(const Color(0xFFFEF3C7)));
            canvas.drawRRect(marco, stroke(const Color(0xFFD97706), 2.0));
            for (final (x, y) in [(26.0, 56.0), (50.0, 44.0), (74.0, 54.0)]) {
              canvas.drawCircle(Offset(x, y), 5.5, fill(const Color(0xFF78350F)));
            }
          }
        }
      }
    } else if (actividadId == 'grupos') {
      final esVertebrado =
          respuestaId == 'grupo-vertebrado' || respuestaId.startsWith('vert-');
      if (modo == 0) {
        // Escáner de Rayos X específico para cada especie (sin tachones ni círculos vacíos)
        // Esquinas de visor radiográfico
        for (final (cx, cy, dx, dy) in [
          (12.0, 14.0, 10.0, 10.0),
          (88.0, 14.0, -10.0, 10.0),
          (12.0, 86.0, 10.0, -10.0),
          (88.0, 86.0, -10.0, -10.0),
        ]) {
          canvas.drawLine(Offset(cx, cy), Offset(cx + dx, cy), stroke(const Color(0xFF38BDF8), 2.0));
          canvas.drawLine(Offset(cx, cy), Offset(cx, cy + dy), stroke(const Color(0xFF38BDF8), 2.0));
        }
        if (retoId == 'caballito-mar') {
          // Radiografía de caballito de mar: columna vertebral curvada en S y anillos óseos
          final sil = Path()
            ..moveTo(52, 18)
            ..quadraticBezierTo(34, 42, 52, 64)
            ..quadraticBezierTo(58, 78, 42, 82);
          canvas.drawPath(sil, stroke(const Color(0xFF0284C7).withValues(alpha: 0.35), 14.0));
          canvas.drawPath(sil, stroke(const Color(0xFF38BDF8), 3.2));
          for (final y in [30.0, 38.0, 46.0, 54.0, 62.0]) {
            canvas.drawLine(Offset(38, y), Offset(54, y), stroke(const Color(0xFFBAE6FD), 2.0));
            canvas.drawCircle(Offset(46, y), 2.2, fill(Colors.white));
          }
          canvas.drawCircle(const Offset(54, 20), 6.5, fill(const Color(0xFFE0F2FE)));
          canvas.drawRect(const Rect.fromLTWH(58, 18, 12, 4), fill(const Color(0xFFE0F2FE)));
        } else if (retoId == 'sardina-banco' || retoId == 'atun-oceano') {
          // Radiografía de pez: silueta fusiforme, espina dorsal central, espinas en V y cráneo
          canvas.drawOval(const Rect.fromLTWH(18, 32, 64, 36), fill(const Color(0xFF0284C7).withValues(alpha: 0.25)));
          canvas.drawLine(const Offset(16, 50), const Offset(72, 50), stroke(const Color(0xFF38BDF8), 3.6));
          for (double x = 26; x <= 62; x += 9) {
            canvas.drawLine(Offset(x, 50), Offset(x - 5, 36), stroke(const Color(0xFFBAE6FD), 2.0));
            canvas.drawLine(Offset(x, 50), Offset(x - 5, 64), stroke(const Color(0xFFBAE6FD), 2.0));
            canvas.drawCircle(Offset(x, 50), 2.2, fill(Colors.white));
          }
          canvas.drawOval(const Rect.fromLTWH(64, 40, 16, 20), fill(const Color(0xFFE0F2FE)));
          canvas.drawCircle(const Offset(74, 47), 2.5, fill(const Color(0xFF0F172A)));
        } else if (retoId == 'murcielago-cueva') {
          // Radiografía de murciélago: cráneo, caja torácica y los 5 huesos largos de los dedos en las alas
          canvas.drawOval(const Rect.fromLTWH(38, 36, 24, 32), fill(const Color(0xFF0284C7).withValues(alpha: 0.28)));
          canvas.drawLine(const Offset(50, 32), const Offset(50, 70), stroke(const Color(0xFF38BDF8), 3.2));
          for (final y in [42.0, 49.0, 56.0]) {
            canvas.drawOval(Rect.fromCenter(center: Offset(50, y), width: 16, height: 5), stroke(const Color(0xFFBAE6FD), 1.8));
          }
          for (final sign in [-1.0, 1.0]) {
            canvas.drawLine(Offset(50 + sign * 8, 42), Offset(50 + sign * 24, 28), stroke(Colors.white, 2.5));
            for (final (dx, dy) in [(38.0, 34.0), (36.0, 48.0), (28.0, 60.0)]) {
              canvas.drawLine(Offset(50 + sign * 24, 28), Offset(50 + sign * dx, dy), stroke(const Color(0xFFBAE6FD), 1.8));
            }
          }
          canvas.drawCircle(const Offset(50, 28), 6.5, fill(const Color(0xFFE0F2FE)));
        } else if (esVertebrado) {
          // Radiografía de vertebrado tetrápodo / ave: cráneo, columna vertebral, costillas y huesos de las extremidades
          canvas.drawOval(const Rect.fromLTWH(20, 34, 48, 28), fill(const Color(0xFF0284C7).withValues(alpha: 0.25)));
          canvas.drawLine(const Offset(16, 46), const Offset(68, 36), stroke(const Color(0xFF38BDF8), 3.8));
          for (double x = 26; x <= 56; x += 9.5) {
            canvas.drawOval(Rect.fromCenter(center: Offset(x, 46), width: 5.5, height: 22), stroke(const Color(0xFFBAE6FD), 2.0));
            canvas.drawCircle(Offset(x, 44), 2.3, fill(Colors.white));
          }
          canvas.drawLine(const Offset(26, 54), const Offset(24, 78), stroke(Colors.white, 2.8));
          canvas.drawLine(const Offset(56, 52), const Offset(58, 78), stroke(Colors.white, 2.8));
          canvas.drawOval(const Rect.fromLTWH(62, 26, 18, 16), fill(const Color(0xFFE0F2FE)));
          canvas.drawCircle(const Offset(73, 32), 2.4, fill(const Color(0xFF0F172A)));
        } else if (retoId == 'caracol-huerta') {
          // Radiografía de caracol: concha calcárea espiral brillante por fuera, pie blando translúcido sin un solo hueso dentro
          canvas.drawOval(const Rect.fromLTWH(16, 62, 68, 14), fill(const Color(0xFF38BDF8).withValues(alpha: 0.28)));
          canvas.drawCircle(const Offset(44, 44), 20, stroke(const Color(0xFFBAE6FD), 3.2));
          canvas.drawCircle(const Offset(44, 44), 12, stroke(const Color(0xFF38BDF8), 2.4));
          canvas.drawCircle(const Offset(44, 44), 5, stroke(const Color(0xFF38BDF8), 2.0));
        } else if (retoId == 'pulpo-roca') {
          // Radiografía de pulpo: silueta translúcida de manto blando y tentáculos sin ningún hueso interno
          canvas.drawOval(const Rect.fromLTWH(32, 20, 36, 32), fill(const Color(0xFF38BDF8).withValues(alpha: 0.25)));
          canvas.drawOval(const Rect.fromLTWH(32, 20, 36, 32), stroke(const Color(0xFF38BDF8), 2.2));
          for (final dx in [-22.0, -10.0, 2.0, 14.0, 24.0]) {
            final t = Path()..moveTo(50 + dx * 0.5, 50)..quadraticBezierTo(50 + dx, 66, 50 + dx * 0.8, 80);
            canvas.drawPath(t, stroke(const Color(0xFF38BDF8).withValues(alpha: 0.55), 4.0));
          }
        } else if (retoId == 'medusa-costa') {
          // Radiografía de medusa: campana gelatinosa transparente de agua sin esqueleto
          final camp = Path()
            ..moveTo(22, 48)
            ..quadraticBezierTo(22, 20, 50, 20)
            ..quadraticBezierTo(78, 20, 78, 48)
            ..close();
          canvas.drawPath(camp, fill(const Color(0xFF38BDF8).withValues(alpha: 0.22)));
          canvas.drawPath(camp, stroke(const Color(0xFF7DD3FC), 2.2));
          for (final x in [32.0, 44.0, 56.0, 68.0]) {
            canvas.drawLine(Offset(x, 48), Offset(x - 3, 78), stroke(const Color(0xFF38BDF8).withValues(alpha: 0.5), 2.4));
          }
        } else if (retoId == 'lombriz-humeda') {
          // Radiografía de lombriz: tubo blando segmentado en anillos hidrostáticos sin columna ni huesos
          final lom = Path()
            ..moveTo(20, 68)
            ..cubicTo(24, 34, 52, 64, 62, 34)
            ..quadraticBezierTo(70, 22, 80, 30);
          canvas.drawPath(lom, stroke(const Color(0xFF38BDF8).withValues(alpha: 0.35), 14.0));
          canvas.drawPath(lom, stroke(const Color(0xFF7DD3FC), 2.0));
        } else {
          // Radiografía de artrópodo (escarabajo, cangrejo, abeja, araña): coraza exterior de quitina brillante y hueco interior sin huesos
          canvas.drawOval(const Rect.fromLTWH(28, 26, 44, 48), fill(const Color(0xFF38BDF8).withValues(alpha: 0.18)));
          canvas.drawOval(const Rect.fromLTWH(28, 26, 44, 48), stroke(const Color(0xFFBAE6FD), 3.0));
          canvas.drawLine(const Offset(30, 42), const Offset(70, 42), stroke(const Color(0xFF38BDF8), 2.0));
          canvas.drawLine(const Offset(30, 56), const Offset(70, 56), stroke(const Color(0xFF38BDF8), 2.0));
          for (final sign in [-1.0, 1.0]) {
            for (final y in [38.0, 50.0, 62.0]) {
              canvas.drawLine(Offset(50 + sign * 22, y), Offset(50 + sign * 36, y - 5), stroke(const Color(0xFF7DD3FC), 2.4));
              canvas.drawLine(Offset(50 + sign * 36, y - 5), Offset(50 + sign * 40, y + 7), stroke(const Color(0xFF7DD3FC), 2.4));
            }
          }
        }
      } else if (modo == 1) {
        // Lupa de piel / coraza / concha
        canvas.drawCircle(const Offset(50, 50), 38, fill(Colors.white));
        canvas.drawCircle(const Offset(50, 50), 38, stroke(const Color(0xFFD97706), 3.2));
        if (respuestaId.contains('mamifero') || retoId == 'caballo-prado' || retoId == 'murcielago-cueva') {
          canvas.drawArc(const Rect.fromLTWH(20, 54, 60, 24), 0, math.pi, true, fill(const Color(0xFFFDE68A)));
          for (double x = 26; x <= 74; x += 8) {
            canvas.drawLine(Offset(x, 68), Offset(x + 6, 26), stroke(const Color(0xFF78350F), 3.2));
          }
        } else if (respuestaId == 'vert-ave' || retoId == 'ciguena-nido' || retoId == 'gorrion-rama') {
          canvas.drawLine(const Offset(24, 72), const Offset(76, 28), stroke(const Color(0xFF0369A1), 4));
          for (double t = 0.2; t <= 0.8; t += 0.15) {
            final px = 24 + 52 * t;
            final py = 72 - 44 * t;
            canvas.drawLine(Offset(px, py), Offset(px - 12, py - 8), stroke(const Color(0xFF38BDF8), 2.4));
            canvas.drawLine(Offset(px, py), Offset(px + 8, py + 12), stroke(const Color(0xFF38BDF8), 2.4));
          }
        } else if (respuestaId.contains('pez') ||
            retoId == 'sardina-banco' ||
            retoId == 'atun-oceano' ||
            retoId == 'caballito-mar' ||
            retoId == 'lagartija-sol' ||
            retoId == 'lagartija-muro') {
          for (final y in [36.0, 52.0, 68.0]) {
            for (final x in [32.0, 50.0, 68.0]) {
              final esc = Rect.fromCenter(center: Offset(x, y), width: 18, height: 16);
              canvas.drawArc(esc, 0, math.pi, true, fill(const Color(0xFF86EFAC)));
              canvas.drawArc(esc, 0, math.pi, false, stroke(const Color(0xFF14532D), 2.2));
            }
          }
        } else if (respuestaId.contains('anfibio') || retoId == 'triton-charca' || retoId == 'salamandra-musgo') {
          canvas.drawCircle(const Offset(50, 50), 28, fill(const Color(0xFF334155)));
          canvas.drawCircle(const Offset(42, 46), 7, fill(const Color(0xFFFACC15)));
          canvas.drawCircle(const Offset(60, 56), 6, fill(const Color(0xFFFACC15)));
          for (final o in [const Offset(36, 38), const Offset(56, 38), const Offset(48, 62)]) {
            canvas.drawCircle(o, 5.0, fill(const Color(0xFF38BDF8)));
            canvas.drawCircle(o.translate(-1.5, -1.5), 1.6, fill(Colors.white));
          }
        } else if (respuestaId == 'inv-artropodo' ||
            retoId == 'cangrejo-rio' ||
            retoId == 'escarabajo-corteza' ||
            retoId == 'abeja-colmena' ||
            retoId == 'arana-tela') {
          final p1 = RRect.fromRectAndRadius(const Rect.fromLTWH(20, 34, 27, 32), const Radius.circular(5));
          final p2 = RRect.fromRectAndRadius(const Rect.fromLTWH(53, 34, 27, 32), const Radius.circular(5));
          canvas.drawRRect(p1, fill(const Color(0xFFEA580C)));
          canvas.drawRRect(p1, stroke(const Color(0xFF7C2D12), 2.0));
          canvas.drawRRect(p2, fill(const Color(0xFFD97706)));
          canvas.drawRRect(p2, stroke(const Color(0xFF7C2D12), 2.0));
          canvas.drawCircle(const Offset(50, 50), 5.5, fill(const Color(0xFFFACC15)));
          canvas.drawCircle(const Offset(50, 50), 5.5, stroke(const Color(0xFF78350F), 1.8));
        } else if (respuestaId == 'inv-molusco' || retoId == 'pulpo-roca' || retoId == 'caracol-huerta') {
          if (retoId == 'pulpo-roca') {
            final tent = Path()..moveTo(22, 66)..quadraticBezierTo(50, 26, 78, 42);
            canvas.drawPath(tent, stroke(const Color(0xFFDB2777), 14.0));
            for (final (vx, vy) in [(34.0, 54.0), (48.0, 44.0), (64.0, 42.0)]) {
              canvas.drawCircle(Offset(vx, vy), 4.5, fill(const Color(0xFFFBCFE8)));
              canvas.drawCircle(Offset(vx, vy), 4.5, stroke(const Color(0xFF831843), 1.6));
            }
          } else {
            canvas.drawCircle(const Offset(50, 50), 24, fill(const Color(0xFFFDE68A)));
            canvas.drawCircle(const Offset(50, 50), 24, stroke(const Color(0xFF92400E), 3.0));
            canvas.drawCircle(const Offset(50, 50), 14, stroke(const Color(0xFFB45309), 2.5));
            canvas.drawCircle(const Offset(50, 50), 6, stroke(const Color(0xFF78350F), 2.2));
          }
        } else {
          for (double y = 32; y <= 68; y += 12) {
            final seg = RRect.fromRectAndRadius(Rect.fromLTWH(24, y - 5, 52, 10), const Radius.circular(5));
            canvas.drawRRect(seg, fill(const Color(0xFFFDA4AF)));
            canvas.drawRRect(seg, stroke(const Color(0xFF9F1239), 1.8));
          }
        }
      } else {
        // Modo 2: Contar patas, alas, aletas o tentáculos según la anatomía real del animal
        final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 80, 68), const Radius.circular(12));
        canvas.drawRRect(marco, fill(const Color(0xFFF5F3FF)));
        canvas.drawRRect(marco, stroke(const Color(0xFF7C3AED), 2.0));
        if (retoId == 'abeja-colmena' || retoId == 'escarabajo-corteza') {
          // Insecto: 6 patas articuladas (3 pares) + 2 antenas + alas
          canvas.drawOval(const Rect.fromLTWH(38, 30, 24, 42), fill(const Color(0xFFF59E0B)));
          canvas.drawOval(const Rect.fromLTWH(38, 30, 24, 42), stroke(const Color(0xFF78350F), 2.0));
          for (final sign in [-1.0, 1.0]) {
            for (final y in [38.0, 50.0, 62.0]) {
              canvas.drawLine(Offset(50 + sign * 12, y), Offset(50 + sign * 30, y - 4), stroke(const Color(0xFF1E293B), 3.0));
              canvas.drawCircle(Offset(50 + sign * 30, y - 4), 3.2, fill(const Color(0xFF7C3AED)));
            }
          }
        } else if (retoId == 'arana-tela') {
          // Arácnido: 8 patas articuladas (4 pares), 0 alas y 0 antenas
          canvas.drawCircle(const Offset(50, 52), 13, fill(const Color(0xFF475569)));
          for (final sign in [-1.0, 1.0]) {
            for (final y in [32.0, 44.0, 56.0, 68.0]) {
              canvas.drawLine(Offset(50 + sign * 10, 50), Offset(50 + sign * 32, y), stroke(const Color(0xFF1E293B), 2.8));
              canvas.drawCircle(Offset(50 + sign * 32, y), 3.0, fill(const Color(0xFF7C3AED)));
            }
          }
        } else if (retoId == 'cangrejo-rio') {
          // Crustáceo: 10 patas (2 pinzas + 8 marchadoras)
          canvas.drawOval(const Rect.fromLTWH(32, 38, 36, 28), fill(const Color(0xFFEF4444)));
          for (final sign in [-1.0, 1.0]) {
            canvas.drawCircle(Offset(50 + sign * 24, 28), 6, fill(const Color(0xFFDC2626)));
            for (final y in [42.0, 50.0, 58.0, 66.0]) {
              canvas.drawLine(Offset(50 + sign * 16, y), Offset(50 + sign * 32, y + 4), stroke(const Color(0xFF991B1B), 2.6));
            }
          }
        } else if (retoId == 'caracol-huerta') {
          // Gasterópodo: 1 único pie musculoso ventral (0 patas)
          final pieU = Path()..moveTo(18, 62)..quadraticBezierTo(50, 50, 82, 62)..quadraticBezierTo(50, 72, 18, 62)..close();
          canvas.drawPath(pieU, fill(const Color(0xFF84CC16)));
          canvas.drawPath(pieU, stroke(const Color(0xFF365314), 2.2));
          canvas.drawLine(const Offset(24, 74), const Offset(76, 74), stroke(const Color(0xFF38BDF8), 3.0));
        } else if (retoId == 'pulpo-roca' || retoId == 'medusa-costa') {
          // Tentáculos flexibles con ventosas o células urticantes (0 patas articuladas)
          for (final x in [26.0, 38.0, 50.0, 62.0, 74.0]) {
            final t = Path()..moveTo(x, 26)..quadraticBezierTo(x - 6, 50, x + 5, 74);
            canvas.drawPath(t, stroke(const Color(0xFFDB2777), 3.5));
          }
        } else if (retoId == 'lombriz-humeda') {
          // Anélido: anillos musculares con diminutas quetas laterales (0 patas)
          for (final y in [32.0, 46.0, 60.0]) {
            final seg = RRect.fromRectAndRadius(Rect.fromLTWH(28, y, 44, 10), const Radius.circular(5));
            canvas.drawRRect(seg, fill(const Color(0xFFFB7185)));
            canvas.drawRRect(seg, stroke(const Color(0xFF881337), 1.8));
            canvas.drawLine(Offset(22, y + 5), Offset(28, y + 5), stroke(const Color(0xFF881337), 2.2));
            canvas.drawLine(Offset(72, y + 5), Offset(78, y + 5), stroke(const Color(0xFF881337), 2.2));
          }
        } else if (respuestaId == 'vert-pez' || retoId == 'sardina-banco' || retoId == 'atun-oceano' || retoId == 'caballito-mar') {
          // Peces: aletas natatorias con radios (0 patas)
          final aleta = Path()..moveTo(26, 66)..quadraticBezierTo(34, 26, 74, 34)..quadraticBezierTo(62, 62, 26, 66)..close();
          canvas.drawPath(aleta, fill(const Color(0xFF38BDF8)));
          canvas.drawPath(aleta, stroke(const Color(0xFF0369A1), 2.2));
          for (final (x2, y2) in [(48.0, 34.0), (60.0, 40.0), (64.0, 50.0)]) {
            canvas.drawLine(const Offset(30, 62), Offset(x2, y2), stroke(const Color(0xFFE0F2FE), 2.0));
          }
        } else if (retoId == 'ciguena-nido' || retoId == 'gorrion-rama' || retoId == 'murcielago-cueva') {
          // Aves y murciélago: 2 alas + 2 patas
          for (final sign in [-1.0, 1.0]) {
            final ala = Path()
              ..moveTo(50 + sign * 8, 42)
              ..quadraticBezierTo(50 + sign * 36, 22, 50 + sign * 34, 52)
              ..close();
            canvas.drawPath(ala, fill(retoId == 'murcielago-cueva' ? const Color(0xFF475569) : const Color(0xFF38BDF8)));
            canvas.drawPath(ala, stroke(const Color(0xFF1E293B), 2.0));
            canvas.drawLine(Offset(50 + sign * 6, 54), Offset(50 + sign * 8, 76), stroke(const Color(0xFFD97706), 3.0));
          }
        } else {
          // Tetrápodos (caballo, lagartija, tritón, salamandra): 4 patas marchadoras
          canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 34, 52, 18), const Radius.circular(9)), fill(const Color(0xFF64748B)));
          for (final x in [30.0, 42.0, 58.0, 70.0]) {
            canvas.drawLine(Offset(x, 50), Offset(x, 74), stroke(const Color(0xFF334155), 4.0));
            canvas.drawCircle(Offset(x, 74), 3.2, fill(const Color(0xFF7C3AED)));
          }
        }
      }
    } else if (actividadId == 'polinizacion') {
      if (nivel == 'facil') {
        final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(12));
        if (modo == 0) {
          // Mapa anatómico completo de la flor en corte natural con lupa marcando exactamente dónde se sitúa la pieza
          canvas.drawRRect(marco, fill(const Color(0xFFF8FAFC)));
          canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
          // Pedúnculo y receptáculo
          canvas.drawLine(const Offset(50, 70), const Offset(50, 86), stroke(const Color(0xFF15803D), 5.0));
          // Pétalos laterales abiertos en abanico (corola)
          final petIzq = Path()
            ..moveTo(42, 66)
            ..cubicTo(12, 60, 10, 26, 32, 22)
            ..cubicTo(42, 24, 44, 48, 44, 62)
            ..close();
          final petDer = Path()
            ..moveTo(58, 66)
            ..cubicTo(88, 60, 90, 26, 68, 22)
            ..cubicTo(58, 24, 56, 48, 56, 62)
            ..close();
          canvas.drawPath(petIzq, fill(const Color(0xFFFBCFE8)));
          canvas.drawPath(petDer, fill(const Color(0xFFFBCFE8)));
          canvas.drawPath(petIzq, stroke(const Color(0xFFDB2777), 1.8));
          canvas.drawPath(petDer, stroke(const Color(0xFFDB2777), 1.8));
          // Sépalos verdes en la base exterior (cáliz)
          final sepI = Path()
            ..moveTo(46, 68)
            ..quadraticBezierTo(24, 72, 18, 56)
            ..quadraticBezierTo(32, 60, 44, 64)
            ..close();
          final sepD = Path()
            ..moveTo(54, 68)
            ..quadraticBezierTo(76, 72, 82, 56)
            ..quadraticBezierTo(68, 60, 56, 64)
            ..close();
          canvas.drawPath(sepI, fill(const Color(0xFF22C55E)));
          canvas.drawPath(sepD, fill(const Color(0xFF22C55E)));
          canvas.drawPath(sepI, stroke(const Color(0xFF14532D), 1.6));
          canvas.drawPath(sepD, stroke(const Color(0xFF14532D), 1.6));
          // Filamentos y anteras en anillo intermedio
          for (final (bx, tx, ty) in [(43.0, 35.0, 30.0), (57.0, 65.0, 30.0)]) {
            canvas.drawLine(Offset(bx, 64), Offset(tx, ty), stroke(const Color(0xFF65A30D), 2.6));
            canvas.drawOval(Rect.fromCenter(center: Offset(tx, ty), width: 9, height: 6), fill(const Color(0xFFF59E0B)));
            canvas.drawOval(Rect.fromCenter(center: Offset(tx, ty), width: 9, height: 6), stroke(const Color(0xFF92400E), 1.4));
          }
          // Órgano central (cámara basal con óvulos, cuello y entrada superior)
          final organoCentral = Path()
            ..moveTo(46, 26)
            ..lineTo(46, 46)
            ..cubicTo(36, 52, 36, 68, 50, 70)
            ..cubicTo(64, 68, 64, 52, 54, 46)
            ..lineTo(54, 26)
            ..close();
          canvas.drawPath(organoCentral, fill(const Color(0xFF86EFAC)));
          canvas.drawPath(organoCentral, stroke(const Color(0xFF15803D), 1.8));
          canvas.drawOval(const Rect.fromLTWH(43, 22, 14, 6), fill(const Color(0xFF4ADE80)));
          canvas.drawOval(const Rect.fromLTWH(43, 22, 14, 6), stroke(const Color(0xFF15803D), 1.5));
          canvas.drawCircle(const Offset(47, 58), 2.5, fill(const Color(0xFFFEF9C3)));
          canvas.drawCircle(const Offset(53, 58), 2.5, fill(const Color(0xFFFEF9C3)));

          // Marcador circular azul de enfoque + flecha señalando la pieza exacta que se está investigando
          final foco = switch (retoId) {
            'sepalo-verde' => const Offset(27, 63),
            'petalo-color' => const Offset(24, 38),
            'antena-polen' => const Offset(38, 45),
            'saco-polinico' => const Offset(65, 29),
            'estigma-cuello' => const Offset(50, 27),
            _ => const Offset(50, 58),
          };
          canvas.drawCircle(foco, 12, fill(const Color(0xFF38BDF8).withValues(alpha: 0.28)));
          canvas.drawCircle(foco, 12, stroke(const Color(0xFF0284C7), 2.6));
          canvas.drawLine(
            Offset(foco.dx + (foco.dx < 50 ? -16 : 16), foco.dy - 10),
            Offset(foco.dx + (foco.dx < 50 ? -8 : 8), foco.dy - 4),
            stroke(const Color(0xFF0284C7), 2.5),
          );
        } else if (modo == 1) {
          // Simulación interactiva de qué hace esa pieza concreta con el capullo y la visita de la abeja
          canvas.drawRRect(marco, fill(const Color(0xFFFFFBEB)));
          canvas.drawRRect(marco, stroke(const Color(0xFFD97706), 1.8));
          if (retoId == 'sepalo-verde') {
            // Izquierda: capullo cerrado protegido de la lluvia por los sépalos; Derecha: sépalos abiertos sosteniendo la flor
            for (final (gx, gy) in [(22.0, 20.0), (34.0, 18.0), (28.0, 28.0)]) {
              canvas.drawLine(Offset(gx, gy), Offset(gx - 3, gy + 7), stroke(const Color(0xFF0284C7), 2.0));
            }
            canvas.drawLine(const Offset(28, 62), const Offset(28, 80), stroke(const Color(0xFF15803D), 4.0));
            canvas.drawOval(const Rect.fromLTWH(18, 36, 20, 28), fill(const Color(0xFF16A34A)));
            canvas.drawOval(const Rect.fromLTWH(18, 36, 20, 28), stroke(const Color(0xFF14532D), 2.0));
            // Flecha hacia la flor abierta apoyada sobre la copa verde de sépalos
            canvas.drawLine(const Offset(42, 52), const Offset(54, 52), stroke(const Color(0xFFD97706), 2.5));
            canvas.drawLine(const Offset(68, 62), const Offset(68, 80), stroke(const Color(0xFF15803D), 4.0));
            canvas.drawCircle(const Offset(60, 46), 10, fill(const Color(0xFFF43F5E)));
            canvas.drawCircle(const Offset(76, 46), 10, fill(const Color(0xFFF43F5E)));
            canvas.drawArc(const Rect.fromLTWH(52, 50, 32, 18), 0, math.pi, true, fill(const Color(0xFF16A34A)));
            canvas.drawArc(const Rect.fromLTWH(52, 50, 32, 18), 0, math.pi, true, stroke(const Color(0xFF14532D), 2.0));
          } else if (retoId == 'petalo-color') {
            // Pétalo desplegado como pista de aterrizaje con líneas guía y ondas de aroma atrayendo a la abeja
            final pista = Path()
              ..moveTo(16, 74)
              ..cubicTo(14, 42, 46, 36, 56, 56)
              ..cubicTo(48, 76, 24, 80, 16, 74)
              ..close();
            canvas.drawPath(pista, fill(const Color(0xFFF43F5E)));
            canvas.drawPath(pista, stroke(const Color(0xFF9F1239), 2.2));
            for (final dy in [-6.0, 0.0, 6.0]) {
              canvas.drawLine(Offset(22, 66 + dy * 0.5), Offset(48, 56 + dy), stroke(const Color(0xFFFEF08A), 2.0));
            }
            // Abeja volando guiada por el aroma hacia el pétalo
            canvas.drawArc(const Rect.fromLTWH(44, 24, 18, 12), math.pi, math.pi, false, stroke(const Color(0xFFF472B6), 2.0));
            canvas.drawOval(const Rect.fromLTWH(58, 22, 22, 14), fill(const Color(0xFFFACC15)));
            canvas.drawOval(const Rect.fromLTWH(58, 22, 22, 14), stroke(const Color(0xFF1E293B), 1.8));
            canvas.drawLine(const Offset(66, 22), const Offset(66, 36), stroke(const Color(0xFF1E293B), 2.5));
            canvas.drawLine(const Offset(72, 22), const Offset(72, 36), stroke(const Color(0xFF1E293B), 2.5));
            canvas.drawOval(const Rect.fromLTWH(64, 13, 12, 10), fill(Colors.white.withValues(alpha: 0.85)));
          } else if (retoId == 'antena-polen' || retoId == 'saco-polinico') {
            // Los filamentos se doblan cuando entra la abeja y las bolsitas espolvorean polen sobre su lomo
            for (final bx in [26.0, 38.0]) {
              final fil = Path()
                ..moveTo(bx, 80)
                ..quadraticBezierTo(bx + 4, 42, bx + 20, 36);
              canvas.drawPath(fil, stroke(const Color(0xFF65A30D), 3.5));
              canvas.drawOval(Rect.fromCenter(center: Offset(bx + 22, 36), width: 12, height: 8), fill(const Color(0xFFF59E0B)));
              canvas.drawOval(Rect.fromCenter(center: Offset(bx + 22, 36), width: 12, height: 8), stroke(const Color(0xFF92400E), 1.6));
            }
            // Abeja debajo recibiendo la lluvia de granos de polen dorados
            canvas.drawOval(const Rect.fromLTWH(44, 52, 28, 18), fill(const Color(0xFFFACC15)));
            canvas.drawOval(const Rect.fromLTWH(44, 52, 28, 18), stroke(const Color(0xFF1E293B), 2.0));
            canvas.drawLine(const Offset(54, 52), const Offset(54, 70), stroke(const Color(0xFF1E293B), 3.0));
            canvas.drawLine(const Offset(62, 52), const Offset(62, 70), stroke(const Color(0xFF1E293B), 3.0));
            canvas.drawOval(const Rect.fromLTWH(52, 42, 14, 12), fill(Colors.white.withValues(alpha: 0.85)));
            for (final (px, py) in [(48.0, 44.0), (58.0, 42.0), (66.0, 46.0), (52.0, 50.0), (62.0, 50.0)]) {
              canvas.drawCircle(Offset(px, py), 3.0, fill(const Color(0xFFF59E0B)));
            }
          } else {
            // La abeja roza la punta pegajosa del cuello central y el tubo polínico baja hasta los óvulos de la cámara
            final cuello = Path()
              ..moveTo(45, 30)
              ..lineTo(45, 50)
              ..cubicTo(32, 56, 32, 78, 50, 80)
              ..cubicTo(68, 78, 68, 56, 55, 50)
              ..lineTo(55, 30)
              ..close();
            canvas.drawPath(cuello, fill(const Color(0xFF86EFAC)));
            canvas.drawPath(cuello, stroke(const Color(0xFF15803D), 2.2));
            canvas.drawOval(const Rect.fromLTWH(38, 24, 24, 9), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(38, 24, 24, 9), stroke(const Color(0xFF14532D), 2.0));
            // Granos de polen en la entrada y tubo dorado bajando hasta los óvulos
            canvas.drawCircle(const Offset(46, 26), 3.2, fill(const Color(0xFFFACC15)));
            canvas.drawCircle(const Offset(54, 26), 3.2, fill(const Color(0xFFFACC15)));
            canvas.drawLine(const Offset(50, 27), const Offset(50, 66), stroke(const Color(0xFFF59E0B), 2.8));
            canvas.drawCircle(const Offset(45, 66), 4.0, fill(const Color(0xFFFEF08A)));
            canvas.drawCircle(const Offset(55, 66), 4.0, fill(const Color(0xFFFEF08A)));
            canvas.drawCircle(const Offset(45, 66), 4.0, stroke(const Color(0xFFD97706), 1.5));
            canvas.drawCircle(const Offset(55, 66), 4.0, stroke(const Color(0xFFD97706), 1.5));
          }
        } else {
          // Modo 2: ¿Qué ocurre con esta pieza cuando la flor se transforma en fruto?
          canvas.drawRRect(marco, fill(const Color(0xFFF0FDF4)));
          canvas.drawRRect(marco, stroke(const Color(0xFF16A34A), 1.8));
          if (retoId == 'sepalo-verde') {
            // Fruto maduro mostrando cómo los sépalos verdes permanecen arriba formando la estrellita del rabillo
            canvas.drawCircle(const Offset(50, 56), 22, fill(const Color(0xFFEF4444)));
            canvas.drawCircle(const Offset(50, 56), 22, stroke(const Color(0xFF991B1B), 2.2));
            canvas.drawLine(const Offset(50, 20), const Offset(50, 34), stroke(const Color(0xFF15803D), 4.0));
            for (final dx in [-16.0, -7.0, 0.0, 7.0, 16.0]) {
              canvas.drawLine(const Offset(50, 32), Offset(50 + dx, 40), stroke(const Color(0xFF16A34A), 3.8));
            }
            // Círculo resaltando el cáliz persistente sobre el fruto
            canvas.drawOval(const Rect.fromLTWH(28, 22, 44, 24), stroke(const Color(0xFF0284C7), 2.2));
          } else if (retoId == 'petalo-color') {
            // Los pétalos coloreados se desprenden y caen al suelo cuando el centro empieza a engordar
            canvas.drawLine(const Offset(50, 56), const Offset(50, 82), stroke(const Color(0xFF15803D), 4.5));
            canvas.drawOval(const Rect.fromLTWH(40, 38, 20, 22), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(40, 38, 20, 22), stroke(const Color(0xFF15803D), 2.0));
            for (final (px, py, ang) in [(24.0, 48.0, -0.5), (74.0, 52.0, 0.6), (30.0, 72.0, -1.1), (68.0, 74.0, 1.2)]) {
              canvas.save();
              canvas.translate(px, py);
              canvas.rotate(ang);
              canvas.drawOval(const Rect.fromLTWH(-8, -5, 16, 10), fill(const Color(0xFFFDA4AF)));
              canvas.drawOval(const Rect.fromLTWH(-8, -5, 16, 10), stroke(const Color(0xFFBE185D), 1.5));
              canvas.restore();
            }
          } else if (retoId == 'antena-polen' || retoId == 'saco-polinico') {
            // Los filamentos y bolsitas vacías se secan y encogen alrededor del fruto incipiente
            canvas.drawLine(const Offset(50, 62), const Offset(50, 82), stroke(const Color(0xFF15803D), 4.5));
            canvas.drawOval(const Rect.fromLTWH(38, 36, 24, 28), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(38, 36, 24, 28), stroke(const Color(0xFF15803D), 2.0));
            for (final (x1, x2) in [(38.0, 24.0), (62.0, 76.0), (42.0, 28.0), (58.0, 72.0)]) {
              canvas.drawLine(Offset(x1, 62), Offset(x2, 48), stroke(const Color(0xFF92400E), 2.2));
              canvas.drawCircle(Offset(x2, 48), 3.0, fill(const Color(0xFF78350F)));
            }
          } else if (retoId == 'estigma-cuello') {
            // El cuello superior se cierra y seca en la punta mientras la base inferior empieza a crecer
            canvas.drawLine(const Offset(50, 68), const Offset(50, 82), stroke(const Color(0xFF15803D), 4.5));
            canvas.drawOval(const Rect.fromLTWH(34, 42, 32, 30), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(34, 42, 32, 30), stroke(const Color(0xFF15803D), 2.2));
            canvas.drawRect(const Rect.fromLTWH(47, 24, 6, 18), fill(const Color(0xFFA16207)));
            canvas.drawOval(const Rect.fromLTWH(43, 20, 14, 6), fill(const Color(0xFF78350F)));
            canvas.drawCircle(const Offset(50, 26), 11, stroke(const Color(0xFFD97706), 2.2));
          } else {
            // Secuencia de transformación de la cámara basal con óvulos -> fruto maduro abierto con semillas
            canvas.drawOval(const Rect.fromLTWH(16, 40, 22, 26), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(16, 40, 22, 26), stroke(const Color(0xFF15803D), 2.0));
            canvas.drawCircle(const Offset(24, 53), 2.5, fill(const Color(0xFFFEF08A)));
            canvas.drawCircle(const Offset(30, 53), 2.5, fill(const Color(0xFFFEF08A)));
            canvas.drawLine(const Offset(41, 53), const Offset(51, 53), stroke(const Color(0xFF16A34A), 3.0));
            canvas.drawCircle(const Offset(68, 52), 18, fill(const Color(0xFFEF4444)));
            canvas.drawCircle(const Offset(68, 52), 18, stroke(const Color(0xFF991B1B), 2.2));
            canvas.drawCircle(const Offset(68, 52), 12, fill(const Color(0xFFFEF9C3)));
            canvas.drawOval(const Rect.fromLTWH(63, 48, 4, 7), fill(const Color(0xFF451A03)));
            canvas.drawOval(const Rect.fromLTWH(70, 48, 4, 7), fill(const Color(0xFF451A03)));
          }
        }
      } else if (nivel == 'medio') {
        if (modo == 0) {
          // Túnel de viento: corrientes de aire y comportamiento de la semilla
          canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(8, 16, 84, 68), const Radius.circular(12)),
            fill(const Color(0xFFE0F2FE)),
          );
          for (final y in [28.0, 46.0, 64.0]) {
            final viento = Path()
              ..moveTo(14, y)
              ..cubicTo(34, y - 5, 56, y + 5, 84, y);
            canvas.drawPath(viento, stroke(const Color(0xFF38BDF8), 2.5));
          }
          if (respuestaId == 'viaje-viento') {
            // Planeando alto en la corriente con su paracaídas o hélice alada
            canvas.save();
            canvas.translate(62, 34);
            canvas.scale(0.38, 0.38);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          } else {
            // Semilla pesada posada en el suelo del túnel sin elevarse
            canvas.drawLine(const Offset(14, 76), const Offset(86, 76), stroke(const Color(0xFF94A3B8), 3));
            canvas.save();
            canvas.translate(34, 64);
            canvas.scale(0.34, 0.34);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          }
        } else if (modo == 1) {
          // Canal de agua: flotabilidad frente a inmersión
          canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(8, 16, 84, 68), const Radius.circular(12)),
            fill(const Color(0xFFE0F2FE)),
          );
          final agua = Path()
            ..moveTo(8, 48)
            ..cubicTo(30, 43, 46, 53, 68, 48)
            ..cubicTo(78, 45, 86, 50, 92, 48)
            ..lineTo(92, 84)
            ..lineTo(8, 84)
            ..close();
          canvas.drawPath(agua, fill(const Color(0xFF7DD3FC)));
          canvas.drawPath(
            Path()
              ..moveTo(10, 48)
              ..cubicTo(30, 43, 46, 53, 68, 48)
              ..cubicTo(78, 45, 86, 50, 90, 48),
            stroke(const Color(0xFF0284C7), 3),
          );
          if (respuestaId == 'viaje-agua') {
            // Flotando sobre las olas gracias a su cubierta fibrosa con aire
            canvas.save();
            canvas.translate(52, 44);
            canvas.scale(0.38, 0.38);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          } else {
            // En la orilla seca fuera del cauce acuático
            canvas.drawRRect(
              RRect.fromRectAndRadius(const Rect.fromLTWH(10, 34, 28, 16), const Radius.circular(6)),
              fill(const Color(0xFFD97706)),
            );
            canvas.save();
            canvas.translate(24, 30);
            canvas.scale(0.32, 0.32);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          }
        } else {
          // Paso de fauna: pelaje de mamífero y aves frugívoras
          canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(8, 16, 84, 68), const Radius.circular(12)),
            fill(const Color(0xFFFEF3C7)),
          );
          for (double x = 18; x <= 82; x += 9) {
            final hebra = Path()
              ..moveTo(x, 20)
              ..quadraticBezierTo(x - 6, 44, x - 2, 72);
            canvas.drawPath(hebra, stroke(const Color(0xFF92400E), 3.5));
          }
          if (respuestaId == 'viaje-animal') {
            canvas.save();
            canvas.translate(52, 48);
            canvas.scale(0.42, 0.42);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          } else {
            // Resbala sin engancharse ni atraer al animal
            canvas.save();
            canvas.translate(52, 72);
            canvas.scale(0.3, 0.3);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          }
        }
      } else {
        // Nivel difícil: Lupa reproductora, corte de semilla y ciclo de humedad
        if (modo == 0) {
          canvas.drawCircle(const Offset(50, 50), 38, fill(const Color(0xFFF8FAFC)));
          canvas.drawCircle(const Offset(50, 50), 38, stroke(const Color(0xFF16A34A), 2.5));
          if (respuestaId == 'planta-angiosperma') {
            // Disección floral con pistilo central transformándose en fruto incipiente
            for (final (dx, dy) in [(-16.0, -8.0), (16.0, -8.0), (-12.0, 10.0), (12.0, 10.0)]) {
              canvas.drawCircle(Offset(50 + dx, 46 + dy), 11, fill(const Color(0xFFFBCFE8)));
              canvas.drawCircle(Offset(50 + dx, 46 + dy), 11, stroke(const Color(0xFFDB2777), 1.5));
            }
            canvas.drawOval(const Rect.fromLTWH(41, 44, 18, 22), fill(const Color(0xFF22C55E)));
            canvas.drawOval(const Rect.fromLTWH(41, 44, 18, 22), stroke(const Color(0xFF14532D), 2.0));
            canvas.drawCircle(const Offset(47, 55), 2.5, fill(const Color(0xFFFEF08A)));
            canvas.drawCircle(const Offset(53, 55), 2.5, fill(const Color(0xFFFEF08A)));
            canvas.drawLine(const Offset(50, 44), const Offset(50, 28), stroke(const Color(0xFF15803D), 3.2));
          } else if (respuestaId == 'planta-gimnosperma') {
            // Cono leñoso en abanico abriendo sus escamas rígidas sin ovario ni pétalos
            for (final (y, w) in [(58.0, 22.0), (46.0, 20.0), (34.0, 15.0)]) {
              canvas.drawOval(
                Rect.fromCenter(center: Offset(50, y), width: w * 2, height: 12),
                fill(retoId == 'abeto-cono' ? const Color(0xFFB45309) : const Color(0xFF78350F)),
              );
              canvas.drawOval(
                Rect.fromCenter(center: Offset(50, y), width: w * 2, height: 12),
                stroke(const Color(0xFF451A03), 1.8),
              );
            }
            canvas.drawOval(const Rect.fromLTWH(60, 24, 14, 7), fill(const Color(0xFFFDE68A)));
            canvas.drawCircle(const Offset(58, 28), 3.5, fill(const Color(0xFF451A03)));
          } else if (retoId == 'musgo-capsula') {
            // Filamento (seta) y cápsula de musgo soltando nube de esporas al abrir el opérculo
            canvas.drawLine(const Offset(42, 78), const Offset(48, 36), stroke(const Color(0xFF15803D), 3.2));
            canvas.drawOval(const Rect.fromLTWH(42, 26, 18, 13), fill(const Color(0xFFD97706)));
            canvas.drawOval(const Rect.fromLTWH(42, 26, 18, 13), stroke(const Color(0xFF78350F), 1.8));
            for (final p in [const Offset(66, 28), const Offset(72, 35), const Offset(65, 42)]) {
              canvas.drawCircle(p, 2.5, fill(const Color(0xFFF59E0B)));
            }
          } else {
            // Envés de fronde de helecho con fila doble de soros pardos
            final fronde = Path()
              ..moveTo(26, 72)
              ..quadraticBezierTo(30, 24, 74, 24)
              ..quadraticBezierTo(68, 68, 26, 72)
              ..close();
            canvas.drawPath(fronde, fill(const Color(0xFF4ADE80)));
            canvas.drawPath(fronde, stroke(const Color(0xFF15803D), 2.0));
            for (final (sx, sy) in [(40.0, 56.0), (48.0, 46.0), (58.0, 38.0), (52.0, 58.0), (60.0, 48.0)]) {
              canvas.drawCircle(Offset(sx, sy), 3.8, fill(const Color(0xFF92400E)));
            }
          }
        } else if (modo == 1) {
          // Corte interior: ¿semilla encerrada en fruto, piñón desnudo o sin semilla (esporas)?
          canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 80, 68), const Radius.circular(12)),
            fill(const Color(0xFFFFFBEB)),
          );
          if (respuestaId == 'planta-angiosperma') {
            // Fruto carnoso cortado por la mitad protegiendo las semillas centrales
            canvas.drawCircle(const Offset(50, 52), 25, fill(const Color(0xFFEF4444)));
            canvas.drawCircle(const Offset(50, 52), 25, stroke(const Color(0xFF991B1B), 2.5));
            canvas.drawCircle(const Offset(50, 52), 16, fill(const Color(0xFFFEF08A)));
            canvas.drawOval(const Rect.fromLTWH(42, 47, 5, 9), fill(const Color(0xFF451A03)));
            canvas.drawOval(const Rect.fromLTWH(53, 47, 5, 9), fill(const Color(0xFF451A03)));
            canvas.drawLine(const Offset(50, 27), const Offset(50, 19), stroke(const Color(0xFF78350F), 3.5));
          } else if (respuestaId == 'planta-gimnosperma') {
            // Escama leñosa de piña abierta con dos piñones alados desnudos encima
            final escama = Path()
              ..moveTo(18, 68)
              ..quadraticBezierTo(48, 72, 82, 52)
              ..quadraticBezierTo(52, 56, 18, 68)
              ..close();
            canvas.drawPath(escama, fill(const Color(0xFF78350F)));
            canvas.drawPath(escama, stroke(const Color(0xFF451A03), 2));
            canvas.drawOval(const Rect.fromLTWH(44, 30, 28, 14), fill(const Color(0xFFFDE68A)));
            canvas.drawOval(const Rect.fromLTWH(44, 30, 28, 14), stroke(const Color(0xFFD97706), 1.8));
            canvas.drawOval(const Rect.fromLTWH(32, 36, 16, 11), fill(const Color(0xFF451A03)));
          } else {
            // Soros abriéndose en el envés de la hoja y liberando esporas microscópicas
            canvas.drawArc(
              const Rect.fromLTWH(20, 48, 60, 28),
              math.pi,
              math.pi,
              true,
              fill(const Color(0xFF92400E)),
            );
            for (final p in [
              const Offset(30, 34),
              const Offset(44, 26),
              const Offset(58, 30),
              const Offset(70, 38),
              const Offset(38, 42),
              const Offset(54, 40),
            ]) {
              canvas.drawCircle(p, 4, fill(const Color(0xFFD97706)));
              canvas.drawCircle(p, 4, stroke(const Color(0xFF78350F), 1.2));
            }
          }
        } else {
          // Ciclo ambiental (flor al sol con polinizador vs cono al viento vs rocío de umbría)
          canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 80, 68), const Radius.circular(12)),
            fill(const Color(0xFFE0F2FE)),
          );
          if (respuestaId == 'planta-esporas') {
            // Umbría húmeda con gotas de rocío sobre musgo/helecho
            canvas.drawArc(const Rect.fromLTWH(14, 62, 72, 24), math.pi, math.pi, true, fill(const Color(0xFF15803D)));
            for (final x in [32.0, 50.0, 68.0]) {
              final gota = Path()
                ..moveTo(x, 28)
                ..quadraticBezierTo(x + 9, 42, x, 50)
                ..quadraticBezierTo(x - 9, 42, x, 28)
                ..close();
              canvas.drawPath(gota, fill(const Color(0xFF0284C7)));
              canvas.drawCircle(Offset(x - 2, 42), 2, fill(Colors.white));
            }
          } else if (respuestaId == 'planta-gimnosperma') {
            // Viento de montaña meciendo las agujas y conos del pino
            canvas.drawCircle(const Offset(72, 30), 10, fill(const Color(0xFFFACC15)));
            for (final y in [38.0, 52.0, 66.0]) {
              canvas.drawLine(Offset(18, y), Offset(62, y), stroke(const Color(0xFF0284C7), 2.5));
            }
            for (final p in [const Offset(66, 44), const Offset(76, 54), const Offset(68, 64)]) {
              canvas.drawCircle(p, 3, fill(const Color(0xFFFACC15)));
            }
          } else {
            // Sol radiante de primavera e insectos visitando las flores
            canvas.drawCircle(const Offset(34, 34), 12, fill(const Color(0xFFFACC15)));
            for (int i = 0; i < 8; i++) {
              final a = i * math.pi / 4;
              canvas.drawLine(
                Offset(34 + math.cos(a) * 14, 34 + math.sin(a) * 14),
                Offset(34 + math.cos(a) * 19, 34 + math.sin(a) * 19),
                stroke(const Color(0xFFF59E0B), 2.2),
              );
            }
            canvas.drawCircle(const Offset(64, 58), 10, fill(const Color(0xFFF43F5E)));
            canvas.drawCircle(const Offset(64, 58), 4.5, fill(const Color(0xFFFACC15)));
          }
        }
      }
    } else if (actividadId == 'estaciones') {
      if (nivel == 'facil') {
        final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(12));
        if (modo == 0) {
          // Primavera y verano: el propio árbol seleccionado (retoId) en su plenitud estival o floral
          canvas.drawRRect(marco, fill(const Color(0xFFF0FDF4)));
          canvas.drawRRect(marco, stroke(const Color(0xFF16A34A), 1.8));
          canvas.drawCircle(const Offset(22, 24), 7.5, fill(const Color(0xFFFACC15)));
          const _PintorNuevoJuego()._dibujarIcono(
            canvas,
            retoId == 'cerezo-valle' ? 'cerezo-flor' : retoId,
          );
        } else if (modo == 1) {
          // Otoño: viento otoñal; cada especie mantiene su silueta real (caducos en tonos cobrizos/dorados, perennes verdes)
          canvas.drawRRect(marco, fill(const Color(0xFFFFFBEB)));
          canvas.drawRRect(marco, stroke(const Color(0xFFD97706), 1.8));
          for (final y in [22.0, 32.0]) {
            canvas.drawLine(Offset(14, y), Offset(32, y), stroke(const Color(0xFFD97706), 2.0));
          }
          if (respuestaId == 'arbol-perenne') {
            // Dibuja el árbol perenne real (pino-verde, encina-dehesa u olivo-campo), NUNCA cambia una encina por un pino
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
          } else {
            // Dibuja el haya, roble o cerezo con su propio tronco y copa otoñal dorada/rojiza soltando hojas
            final colorTronco = retoId == 'haya-otono'
                ? const Color(0xFF64748B)
                : (retoId == 'cerezo-valle' ? const Color(0xFF7C2D12) : const Color(0xFF78350F));
            canvas.drawRect(const Rect.fromLTWH(44, 50, 12, 34), fill(colorTronco));
            canvas.drawCircle(
              const Offset(34, 42),
              15,
              fill(retoId == 'cerezo-valle' ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
            );
            canvas.drawCircle(const Offset(66, 42), 15, fill(const Color(0xFFEA580C)));
            canvas.drawCircle(const Offset(50, 33), 20, fill(const Color(0xFFF59E0B)));
            for (final (hx, hy) in [(22.0, 62.0), (30.0, 74.0), (68.0, 66.0), (74.0, 76.0)]) {
              canvas.drawOval(Rect.fromLTWH(hx, hy, 8, 5), fill(const Color(0xFFEA580C)));
            }
          }
        } else {
          // Invierno: nieve y helada; los perennes conservan su propia copa verde y los caducos quedan con ramas desnudas
          canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
          canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
          canvas.drawArc(const Rect.fromLTWH(12, 72, 76, 18), math.pi, math.pi, true, fill(Colors.white));
          for (final (nx, ny) in [(20.0, 24.0), (78.0, 26.0), (24.0, 48.0)]) {
            canvas.drawCircle(Offset(nx, ny), 2.5, fill(Colors.white));
          }
          if (respuestaId == 'arbol-perenne') {
            // El pino, la encina o el olivo real conserva su copa verde bajo la escarcha
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
          } else {
            final colorTronco = retoId == 'haya-otono'
                ? const Color(0xFF64748B)
                : (retoId == 'cerezo-valle' ? const Color(0xFF7C2D12) : const Color(0xFF78350F));
            canvas.drawRect(const Rect.fromLTWH(45, 48, 10, 34), fill(colorTronco));
            for (final (x2, y2) in [(26.0, 26.0), (36.0, 20.0), (50.0, 18.0), (64.0, 20.0), (74.0, 26.0)]) {
              canvas.drawLine(const Offset(50, 50), Offset(x2, y2), stroke(colorTronco, 3.2));
              canvas.drawCircle(Offset(x2, y2), 2.3, fill(const Color(0xFFB45309)));
            }
          }
        }
      } else if (nivel == 'medio') {
        final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(12));
        if (modo == 0) {
          // Lupa botánica: muestra la hoja y el fruto reales de cada especie (distintos de los emblemas de respuesta)
          canvas.drawCircle(const Offset(50, 50), 37, fill(const Color(0xFFF0FDF4)));
          canvas.drawCircle(const Offset(50, 50), 37, stroke(const Color(0xFF16A34A), 2.5));
          if (retoId == 'pino-acicula') {
            // Parejas de agujas largas unidas por una vaina basal + piña leñosa
            canvas.drawLine(const Offset(22, 68), const Offset(48, 52), stroke(const Color(0xFF78350F), 3.8));
            for (final (ox, oy) in [(34.0, 60.0), (44.0, 54.0)]) {
              canvas.drawRect(Rect.fromLTWH(ox - 2, oy - 3, 5, 5), fill(const Color(0xFF92400E)));
              canvas.drawLine(Offset(ox, oy), Offset(ox - 8, oy - 30), stroke(const Color(0xFF15803D), 2.4));
              canvas.drawLine(Offset(ox, oy), Offset(ox + 6, oy - 32), stroke(const Color(0xFF16A34A), 2.4));
            }
            canvas.drawOval(const Rect.fromLTWH(54, 42, 18, 26), fill(const Color(0xFF92400E)));
            canvas.drawOval(const Rect.fromLTWH(54, 42, 18, 26), stroke(const Color(0xFF451A03), 1.8));
          } else if (retoId == 'cedro-aguja') {
            // Rosetas estrelladas de agujas cortas verde-azuladas + cono en barril erguido
            canvas.drawLine(const Offset(20, 64), const Offset(76, 56), stroke(const Color(0xFF57534E), 3.8));
            for (final cx in [34.0, 52.0]) {
              for (final a in [-1.1, -0.6, -0.1, 0.4, 0.9]) {
                canvas.drawLine(
                  Offset(cx, 60),
                  Offset(cx + math.sin(a) * 18, 60 - math.cos(a) * 18),
                  stroke(const Color(0xFF0F766E), 2.3),
                );
              }
            }
            canvas.drawRRect(
              RRect.fromRectAndRadius(const Rect.fromLTWH(58, 28, 16, 24), const Radius.circular(6)),
              fill(const Color(0xFFB45309)),
            );
            canvas.drawRRect(
              RRect.fromRectAndRadius(const Rect.fromLTWH(58, 28, 16, 24), const Radius.circular(6)),
              stroke(const Color(0xFF451A03), 1.8),
            );
          } else if (retoId == 'roble-lobulada') {
            // Hoja ancha lobulada fina + bellota con cúpula
            final lob = Path()
              ..moveTo(26, 70)
              ..quadraticBezierTo(18, 52, 28, 44)
              ..quadraticBezierTo(20, 30, 36, 28)
              ..quadraticBezierTo(44, 18, 52, 28)
              ..quadraticBezierTo(64, 32, 54, 46)
              ..quadraticBezierTo(60, 58, 42, 64)
              ..close();
            canvas.drawPath(lob, fill(const Color(0xFF22C55E)));
            canvas.drawPath(lob, stroke(const Color(0xFF15803D), 2.0));
            canvas.drawLine(const Offset(26, 72), const Offset(46, 26), stroke(const Color(0xFF14532D), 2.0));
            canvas.drawOval(const Rect.fromLTWH(58, 46, 14, 20), fill(const Color(0xFFD97706)));
            canvas.drawOval(const Rect.fromLTWH(58, 46, 14, 20), stroke(const Color(0xFF451A03), 1.8));
            canvas.drawArc(const Rect.fromLTWH(56, 40, 18, 12), math.pi, math.pi, true, fill(const Color(0xFF78350F)));
          } else if (retoId == 'castano-aserrada') {
            // Hoja alargada con dientes de sierra + erizo espinoso con castaña
            final aserr = Path()
              ..moveTo(22, 68)
              ..lineTo(24, 52)
              ..lineTo(20, 48)
              ..lineTo(28, 36)
              ..lineTo(24, 32)
              ..lineTo(42, 22)
              ..lineTo(52, 34)
              ..lineTo(48, 38)
              ..lineTo(52, 50)
              ..lineTo(44, 54)
              ..lineTo(42, 66)
              ..close();
            canvas.drawPath(aserr, fill(const Color(0xFF22C55E)));
            canvas.drawPath(aserr, stroke(const Color(0xFF15803D), 2.0));
            canvas.drawLine(const Offset(22, 70), const Offset(42, 24), stroke(const Color(0xFF14532D), 2.0));
            canvas.drawCircle(const Offset(64, 54), 13, fill(const Color(0xFF84CC16)));
            canvas.drawCircle(const Offset(64, 54), 13, stroke(const Color(0xFF365314), 1.8));
            canvas.drawCircle(const Offset(64, 54), 7, fill(const Color(0xFF78350F)));
          } else if (retoId == 'encina-coriacea') {
            // Hoja pequeña dura mostrando el haz verde oscuro y el envés blanquecino + bellota
            canvas.drawOval(const Rect.fromLTWH(22, 30, 26, 38), fill(const Color(0xFF166534)));
            canvas.drawOval(const Rect.fromLTWH(22, 30, 26, 38), stroke(const Color(0xFF052E16), 2.2));
            canvas.drawOval(const Rect.fromLTWH(40, 36, 22, 32), fill(const Color(0xFFD6D3D1)));
            canvas.drawOval(const Rect.fromLTWH(40, 36, 22, 32), stroke(const Color(0xFF57534E), 1.8));
            canvas.drawOval(const Rect.fromLTWH(64, 44, 12, 18), fill(const Color(0xFF92400E)));
            canvas.drawArc(const Rect.fromLTWH(62, 39, 16, 10), math.pi, math.pi, true, fill(const Color(0xFF57534E)));
          } else {
            // Olivo: par de hojas lanceoladas (haz verde, envés plateado) + aceitunas
            final h1 = Path()..moveTo(26, 68)..quadraticBezierTo(18, 42, 42, 24)..quadraticBezierTo(46, 50, 26, 68)..close();
            final h2 = Path()..moveTo(38, 70)..quadraticBezierTo(44, 44, 68, 30)..quadraticBezierTo(60, 56, 38, 70)..close();
            canvas.drawPath(h1, fill(const Color(0xFF65A30D)));
            canvas.drawPath(h1, stroke(const Color(0xFF365314), 1.9));
            canvas.drawPath(h2, fill(const Color(0xFFCBD5E1)));
            canvas.drawPath(h2, stroke(const Color(0xFF475569), 1.9));
            canvas.drawOval(const Rect.fromLTWH(62, 52, 12, 16), fill(const Color(0xFF365314)));
            canvas.drawOval(const Rect.fromLTWH(62, 52, 12, 16), stroke(const Color(0xFF1A2E05), 1.6));
          }
        } else if (modo == 1) {
          // Simulador de calor de verano (38 °C): transpiración de agua en la hoja
          canvas.drawRRect(marco, fill(const Color(0xFFFFFBEB)));
          canvas.drawRRect(marco, stroke(const Color(0xFFD97706), 1.8));
          canvas.drawCircle(const Offset(24, 26), 9, fill(const Color(0xFFF59E0B)));
          if (respuestaId == 'hoja-lobulada-aserrada') {
            // Hoja ancha y fina: pierde mucho vapor de agua hacia arriba por su gran superficie
            canvas.drawOval(const Rect.fromLTWH(24, 54, 54, 20), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(24, 54, 54, 20), stroke(const Color(0xFF15803D), 2.0));
            for (final x in [34.0, 50.0, 66.0]) {
              canvas.drawLine(Offset(x, 52), Offset(x, 30), stroke(const Color(0xFF0284C7), 2.6));
              canvas.drawLine(Offset(x, 30), Offset(x - 4, 36), stroke(const Color(0xFF0284C7), 2.2));
              canvas.drawLine(Offset(x, 30), Offset(x + 4, 36), stroke(const Color(0xFF0284C7), 2.2));
            }
          } else if (respuestaId == 'hoja-entera-dura') {
            // Hoja coriácea con capa gruesa de cera dorada: el sol rebota y las gotas de agua quedan encerradas dentro
            final capsula = RRect.fromRectAndRadius(const Rect.fromLTWH(26, 46, 50, 28), const Radius.circular(14));
            canvas.drawRRect(capsula, fill(const Color(0xFF166534)));
            canvas.drawRRect(capsula, stroke(const Color(0xFFF59E0B), 4.0));
            for (final x in [38.0, 51.0, 64.0]) {
              canvas.drawCircle(Offset(x, 60), 4.2, fill(const Color(0xFF38BDF8)));
            }
            canvas.drawLine(const Offset(32, 32), const Offset(46, 43), stroke(const Color(0xFFF59E0B), 2.2));
            canvas.drawLine(const Offset(46, 43), const Offset(58, 30), stroke(const Color(0xFFF59E0B), 2.2));
          } else {
            // Acícula en aguja: sección muy estrecha con resina ámbar y mínima superficie expuesta al sol
            final aguja = RRect.fromRectAndRadius(const Rect.fromLTWH(38, 48, 28, 22), const Radius.circular(11));
            canvas.drawRRect(aguja, fill(const Color(0xFF15803D)));
            canvas.drawRRect(aguja, stroke(const Color(0xFF0F766E), 3.0));
            canvas.drawCircle(const Offset(46, 59), 4.0, fill(const Color(0xFFF59E0B)));
            canvas.drawCircle(const Offset(58, 59), 4.0, fill(const Color(0xFF38BDF8)));
          }
        } else {
          // Simulador de frío de invierno (-5 °C): muestra el árbol real (retoId) en invierno
          canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
          canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
          canvas.drawArc(const Rect.fromLTWH(12, 72, 76, 18), math.pi, math.pi, true, fill(Colors.white));
          if (respuestaId == 'hoja-lobulada-aserrada') {
            // El roble o castaño tira sus hojas anchas y pasa el invierno con las ramas desnudas y yemas cerradas
            canvas.drawRect(const Rect.fromLTWH(44, 48, 12, 34), fill(const Color(0xFF78350F)));
            for (final (x2, y2) in [(26.0, 28.0), (38.0, 20.0), (50.0, 18.0), (62.0, 20.0), (74.0, 28.0)]) {
              canvas.drawLine(const Offset(50, 50), Offset(x2, y2), stroke(const Color(0xFF78350F), 3.2));
              canvas.drawCircle(Offset(x2, y2), 2.4, fill(const Color(0xFFD97706)));
            }
          } else {
            // Dibuja el pino, cedro, encina u olivo real conservando su copa verde en invierno
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            for (final (nx, ny) in [(22.0, 24.0), (76.0, 26.0), (20.0, 48.0), (80.0, 46.0)]) {
              canvas.drawCircle(Offset(nx, ny), 2.5, fill(Colors.white));
            }
          }
        }
      } else {
        // Nivel difícil: Climograma anual, Hoja y corteza, y Estación crítica de cada especie
        final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(12));
        if (modo == 0) {
          // Climograma de las 4 estaciones (barras azules de lluvia + curva roja/naranja de temperatura)
          canvas.drawRRect(marco, fill(const Color(0xFFF8FAFC)));
          canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
          // Ejes del gráfico
          canvas.drawLine(const Offset(18, 20), const Offset(18, 74), stroke(const Color(0xFF64748B), 1.8));
          canvas.drawLine(const Offset(18, 74), const Offset(84, 74), stroke(const Color(0xFF64748B), 1.8));
          final barras = respuestaId == 'bosque-atlantico'
              ? [38.0, 30.0, 42.0, 44.0]
              : respuestaId == 'bosque-mediterraneo'
              ? [28.0, 4.0, 30.0, 24.0]
              : [32.0, 22.0, 34.0, 38.0];
          final tempsY = respuestaId == 'bosque-atlantico'
              ? [46.0, 38.0, 44.0, 52.0]
              : respuestaId == 'bosque-mediterraneo'
              ? [42.0, 20.0, 40.0, 48.0]
              : [54.0, 42.0, 56.0, 68.0];
          final xs = [26.0, 42.0, 58.0, 74.0];
          for (var i = 0; i < 4; i++) {
            final h = barras[i];
            final r = RRect.fromRectAndRadius(
              Rect.fromLTWH(xs[i] - 5, 74 - h, 10, h),
              const Radius.circular(2.5),
            );
            canvas.drawRRect(r, fill(const Color(0xFF38BDF8)));
            canvas.drawRRect(r, stroke(const Color(0xFF0284C7), 1.3));
          }
          if (respuestaId == 'bosque-montana') {
            // Línea de congelación (0 °C) y cristales de nieve en otoño/invierno
            canvas.drawLine(const Offset(18, 58), const Offset(82, 58), stroke(const Color(0xFF94A3B8), 1.4));
            canvas.drawCircle(const Offset(74, 28), 3.0, fill(const Color(0xFF0284C7)));
          }
          final curva = Path()..moveTo(xs[0], tempsY[0]);
          for (var i = 1; i < 4; i++) {
            curva.lineTo(xs[i], tempsY[i]);
          }
          canvas.drawPath(curva, stroke(const Color(0xFFEA580C), 2.8));
          for (var i = 0; i < 4; i++) {
            canvas.drawCircle(Offset(xs[i], tempsY[i]), 3.2, fill(const Color(0xFFDC2626)));
          }
        } else if (modo == 1) {
          // Panel botánico doble: corteza del tronco a la izquierda + hoja característica a la derecha
          canvas.drawRRect(marco, fill(const Color(0xFFF0FDF4)));
          canvas.drawRRect(marco, stroke(const Color(0xFF16A34A), 1.8));
          if (retoId == 'hayedo-niebla') {
            // Corteza lisa gris plateada + hoja ovalada tierna de haya
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 22, 56), const Radius.circular(4)), fill(const Color(0xFF94A3B8)));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 22, 56), const Radius.circular(4)), stroke(const Color(0xFF475569), 1.8));
            for (final y in [34.0, 48.0, 62.0]) {
              canvas.drawLine(Offset(20, y), Offset(34, y), stroke(const Color(0xFFE2E8F0), 1.6));
            }
            canvas.drawOval(const Rect.fromLTWH(48, 28, 30, 42), fill(const Color(0xFF4ADE80)));
            canvas.drawOval(const Rect.fromLTWH(48, 28, 30, 42), stroke(const Color(0xFF15803D), 2.0));
            canvas.drawLine(const Offset(63, 72), const Offset(63, 30), stroke(const Color(0xFF166534), 1.8));
          } else if (retoId == 'robledal-humedo') {
            // Corteza parda agrietada + hoja lobulada y bellota de roble
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 22, 56), const Radius.circular(4)), fill(const Color(0xFF78350F)));
            for (final y in [28.0, 46.0, 62.0]) {
              canvas.drawLine(Offset(23, y), Offset(23, y + 10), stroke(const Color(0xFF292524), 2.0));
              canvas.drawLine(Offset(31, y - 2), Offset(31, y + 8), stroke(const Color(0xFF292524), 2.0));
            }
            for (final y in [34.0, 46.0, 58.0]) {
              canvas.drawCircle(Offset(56, y), 7.5, fill(const Color(0xFF22C55E)));
              canvas.drawCircle(Offset(70, y), 7.5, fill(const Color(0xFF22C55E)));
            }
            canvas.drawLine(const Offset(63, 70), const Offset(63, 28), stroke(const Color(0xFF14532D), 2.0));
          } else if (retoId == 'alcornocal-corcho') {
            // Corteza muy gruesa y esponjosa de corcho + hoja coriácea
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 22, 26, 56), const Radius.circular(5)), fill(const Color(0xFFC2410C)));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 22, 20, 56), const Radius.circular(5)), fill(const Color(0xFFD97706)));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 22, 26, 56), const Radius.circular(5)), stroke(const Color(0xFF431407), 2.0));
            for (final (px, py) in [(20.0, 32.0), (26.0, 46.0), (20.0, 62.0)]) {
              canvas.drawCircle(Offset(px, py), 2.2, fill(const Color(0xFF78350F)));
            }
            canvas.drawOval(const Rect.fromLTWH(50, 32, 26, 36), fill(const Color(0xFF166534)));
            canvas.drawOval(const Rect.fromLTWH(50, 32, 26, 36), stroke(const Color(0xFF052E16), 2.0));
          } else if (retoId == 'encinar-seco') {
            // Corteza oscura cuarteada + hoja pequeña dura con envés blanquecino
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 22, 56), const Radius.circular(4)), fill(const Color(0xFF44403C)));
            canvas.drawOval(const Rect.fromLTWH(46, 30, 22, 34), fill(const Color(0xFF166534)));
            canvas.drawOval(const Rect.fromLTWH(60, 36, 20, 30), fill(const Color(0xFFD6D3D1)));
            canvas.drawOval(const Rect.fromLTWH(60, 36, 20, 30), stroke(const Color(0xFF57534E), 1.6));
          } else if (retoId == 'pinar-cumbre') {
            // Corteza escamosa rojiza + par de acículas con gota de resina
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 22, 56), const Radius.circular(4)), fill(const Color(0xFF9A3412)));
            canvas.drawLine(const Offset(56, 68), const Offset(48, 28), stroke(const Color(0xFF15803D), 3.0));
            canvas.drawLine(const Offset(56, 68), const Offset(68, 28), stroke(const Color(0xFF15803D), 3.0));
            canvas.drawCircle(const Offset(72, 56), 5.5, fill(const Color(0xFFF59E0B)));
          } else {
            // Abeto blanco: corteza gris con ampollas + aguja plana con dos líneas blancas y piña erguida
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 22, 56), const Radius.circular(4)), fill(const Color(0xFF64748B)));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(48, 26, 12, 46), const Radius.circular(6)), fill(const Color(0xFF0F766E)));
            canvas.drawLine(const Offset(52, 30), const Offset(52, 68), stroke(Colors.white, 1.8));
            canvas.drawLine(const Offset(56, 30), const Offset(56, 68), stroke(Colors.white, 1.8));
            canvas.drawOval(const Rect.fromLTWH(66, 34, 14, 28), fill(const Color(0xFFB45309)));
          }
        } else {
          // Estación crítica: reposo invernal con mantillo, raíces profundas en verano seco o ramas flexibles bajo nieve
          if (respuestaId == 'bosque-atlantico') {
            canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
            canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
            // Mantillo marrón de hojas caídas abrigando el suelo en invierno
            canvas.drawArc(const Rect.fromLTWH(12, 68, 76, 22), math.pi, math.pi, true, fill(const Color(0xFF92400E)));
            final colTr = retoId == 'hayedo-niebla' ? const Color(0xFF64748B) : const Color(0xFF78350F);
            canvas.drawRect(const Rect.fromLTWH(45, 44, 10, 32), fill(colTr));
            for (final (x2, y2) in [(28.0, 26.0), (50.0, 20.0), (72.0, 26.0)]) {
              canvas.drawLine(const Offset(50, 46), Offset(x2, y2), stroke(colTr, 3.2));
            }
          } else if (respuestaId == 'bosque-mediterraneo') {
            canvas.drawRRect(marco, fill(const Color(0xFFFEF3C7)));
            canvas.drawRRect(marco, stroke(const Color(0xFFD97706), 1.8));
            // Corte del suelo mostrando las raíces profundas alcanzando el agua subterránea en pleno agosto
            canvas.drawRect(const Rect.fromLTWH(10, 50, 80, 36), fill(const Color(0xFFB45309)));
            canvas.drawRect(const Rect.fromLTWH(10, 74, 80, 12), fill(const Color(0xFF0284C7)));
            canvas.drawOval(const Rect.fromLTWH(28, 20, 44, 22), fill(const Color(0xFF166534)));
            canvas.drawRect(
              const Rect.fromLTWH(46, 38, 8, 14),
              fill(retoId == 'alcornocal-corcho' ? const Color(0xFFC2410C) : const Color(0xFF44403C)),
            );
            for (final dx in [-18.0, -6.0, 6.0, 18.0]) {
              canvas.drawLine(const Offset(50, 50), Offset(50 + dx, 78), stroke(const Color(0xFFFEF08A), 2.2));
            }
          } else {
            canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
            canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            // Flechas de nieve resbalando por la pendiente cónica de las ramas flexibles
            canvas.drawLine(const Offset(44, 22), const Offset(20, 58), stroke(Colors.white, 3.5));
            canvas.drawLine(const Offset(56, 22), const Offset(80, 58), stroke(Colors.white, 3.5));
            canvas.drawCircle(const Offset(20, 62), 4.5, fill(Colors.white));
            canvas.drawCircle(const Offset(80, 62), 4.5, fill(Colors.white));
          }
        }
      }
    } else if (actividadId == 'huerta') {
      final marco = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 12, 84, 76), const Radius.circular(12));
      if (nivel == 'facil' || nivel == 'medio') {
        final esRaizOTallo =
            respuestaId == 'huerta-raiz' || respuestaId == 'huerto-raiz-tallo';
        final esHojaOFlor =
            respuestaId == 'huerta-hoja' || respuestaId == 'huerto-hoja-flor';
        if (modo == 0) {
          // Surco del huerto: muestra exactamente cómo crece cada hortaliza en la tierra o sobre el suelo
          canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              const Rect.fromLTWH(8, 52, 84, 36),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
            fill(const Color(0xFF78350F)),
          );
          canvas.drawLine(const Offset(8, 52), const Offset(92, 52), stroke(const Color(0xFF451A03), 2.5));
          canvas.drawRRect(marco, stroke(const Color(0xFF92400E), 1.8));

          if (retoId == 'zanahoria-raiz') {
            // Zanahoria cónica larga enterrada bajo el surco y hojas plumosas fuera
            for (final dx in [-10.0, 0.0, 10.0]) {
              canvas.drawLine(const Offset(50, 52), Offset(50 + dx, 24), stroke(const Color(0xFF16A34A), 3.5));
            }
            final zan = Path()
              ..moveTo(40, 52)
              ..lineTo(60, 52)
              ..lineTo(50, 84)
              ..close();
            canvas.drawPath(zan, fill(const Color(0xFFEA580C)));
            canvas.drawPath(zan, stroke(const Color(0xFF9A3412), 2.0));
            canvas.drawLine(const Offset(43, 62), const Offset(33, 66), stroke(const Color(0xFFFDE68A), 1.6));
            canvas.drawLine(const Offset(57, 68), const Offset(67, 72), stroke(const Color(0xFFFDE68A), 1.6));
          } else if (retoId == 'rabano-raiz') {
            // Rábano redondo carmesí con punta blanca enterrado bajo el suelo y hojas anchas arriba
            for (final dx in [-12.0, 0.0, 12.0]) {
              canvas.drawOval(Rect.fromCenter(center: Offset(50 + dx * 0.6, 34), width: 10, height: 22), fill(const Color(0xFF22C55E)));
              canvas.drawOval(Rect.fromCenter(center: Offset(50 + dx * 0.6, 34), width: 10, height: 22), stroke(const Color(0xFF14532D), 1.5));
            }
            canvas.drawCircle(const Offset(50, 64), 12, fill(const Color(0xFFE11D48)));
            canvas.drawCircle(const Offset(50, 64), 12, stroke(const Color(0xFF881337), 2.0));
            canvas.drawLine(const Offset(50, 76), const Offset(50, 85), stroke(const Color(0xFFFFF1F2), 3.0));
          } else if (retoId == 'esparrago-tallo') {
            // Rizoma y raíces bajo tierra de donde brotan rectos hacia arriba los tallos tiernos (espárragos)
            canvas.drawLine(const Offset(34, 62), const Offset(66, 62), stroke(const Color(0xFFD97706), 4.0));
            for (final rx in [38.0, 50.0, 62.0]) {
              canvas.drawLine(Offset(rx, 62), Offset(rx - 4, 80), stroke(const Color(0xFFFDE68A), 2.0));
              canvas.drawRRect(
                RRect.fromRectAndRadius(Rect.fromLTWH(rx - 4, 22, 8, 32), const Radius.circular(4)),
                fill(const Color(0xFF16A34A)),
              );
              canvas.drawRRect(
                RRect.fromRectAndRadius(Rect.fromLTWH(rx - 4, 22, 8, 32), const Radius.circular(4)),
                stroke(const Color(0xFF14532D), 1.6),
              );
            }
          } else if (retoId == 'lechuga-hoja' || retoId == 'espinaca-hoja') {
            // Raíces finas bajo tierra y roseta de hojas verdes desplegada justo sobre el suelo al sol
            canvas.drawLine(const Offset(50, 52), const Offset(38, 74), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.drawLine(const Offset(50, 52), const Offset(50, 78), stroke(const Color(0xFFFDE68A), 2.5));
            canvas.drawLine(const Offset(50, 52), const Offset(62, 74), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.save();
            canvas.translate(50, 35);
            canvas.scale(0.42, 0.42);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          } else if (retoId == 'alcachofa-flor') {
            // Tallo alto erguido con hojas laterales y el capullo de alcachofa coronando la cima
            canvas.drawLine(const Offset(50, 52), const Offset(42, 76), stroke(const Color(0xFFFDE68A), 2.4));
            canvas.drawLine(const Offset(50, 52), const Offset(58, 76), stroke(const Color(0xFFFDE68A), 2.4));
            canvas.drawLine(const Offset(50, 52), const Offset(50, 34), stroke(const Color(0xFF15803D), 5.0));
            canvas.save();
            canvas.translate(50, 28);
            canvas.scale(0.38, 0.38);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, 'alcachofa-flor');
            canvas.restore();
          } else {
            // Mata de tomatera, fresal o guisante con raíces abajo y frutos/vainas colgando de las ramas aéreas
            canvas.drawLine(const Offset(50, 52), const Offset(40, 76), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.drawLine(const Offset(50, 52), const Offset(60, 76), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.drawLine(const Offset(36, 52), const Offset(36, 20), stroke(const Color(0xFF92400E), 3.0));
            canvas.drawLine(const Offset(36, 48), const Offset(52, 26), stroke(const Color(0xFF15803D), 3.5));
            canvas.drawLine(const Offset(52, 26), const Offset(66, 34), stroke(const Color(0xFF15803D), 3.0));
            canvas.save();
            canvas.translate(64, 38);
            canvas.scale(0.36, 0.36);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          }
        } else if (modo == 1) {
          // Corte interior en tabla de cocina: muestra el interior real de cada hortaliza
          canvas.drawCircle(const Offset(50, 50), 36, fill(const Color(0xFFF8FAFC)));
          canvas.drawCircle(const Offset(50, 50), 36, stroke(const Color(0xFFE11D48), 2.2));
          if (!esRaizOTallo && !esHojaOFlor) {
            if (retoId == 'guisante-vaina') {
              // Vaina abierta mostrando los guisantes unidos por su funículo a la sutura placentaria
              final vainaC = Path()
                ..moveTo(18, 56)
                ..quadraticBezierTo(50, 28, 82, 42)
                ..quadraticBezierTo(52, 74, 18, 56)
                ..close();
              canvas.drawPath(vainaC, fill(const Color(0xFF16A34A)));
              canvas.drawPath(vainaC, stroke(const Color(0xFF14532D), 2.2));
              for (final (gx, gy) in [(34.0, 52.0), (46.0, 48.0), (58.0, 45.0), (70.0, 42.0)]) {
                canvas.drawCircle(Offset(gx, gy), 6.0, fill(const Color(0xFF86EFAC)));
                canvas.drawCircle(Offset(gx, gy), 6.0, stroke(const Color(0xFF14532D), 1.6));
              }
            } else if (retoId == 'fresa-fruto') {
              // Fresa cortada por la mitad mostrando su corazón blanco-rosado y aquenios exteriores
              final mitadFresa = Path()
                ..moveTo(50, 74)
                ..cubicTo(24, 60, 24, 32, 40, 28)
                ..quadraticBezierTo(50, 32, 60, 28)
                ..cubicTo(76, 32, 76, 60, 50, 74)
                ..close();
              canvas.drawPath(mitadFresa, fill(const Color(0xFFE11D48)));
              canvas.drawPath(mitadFresa, stroke(const Color(0xFF881337), 2.2));
              final centroFresa = Path()
                ..moveTo(50, 66)
                ..cubicTo(34, 56, 34, 38, 50, 34)
                ..cubicTo(66, 38, 66, 56, 50, 66)
                ..close();
              canvas.drawPath(centroFresa, fill(const Color(0xFFFFE4E6)));
            } else {
              // Tomate cortado transversalmente con sus lóculos jugosos llenos de pepitas amarillas
              canvas.drawCircle(const Offset(50, 50), 25, fill(const Color(0xFFEF4444)));
              canvas.drawCircle(const Offset(50, 50), 25, stroke(const Color(0xFF991B1B), 2.5));
              for (final p in [
                const Offset(40, 40),
                const Offset(60, 40),
                const Offset(40, 60),
                const Offset(60, 60),
              ]) {
                canvas.drawCircle(p, 6.5, fill(const Color(0xFFB91C1C)));
                canvas.drawOval(Rect.fromCenter(center: p, width: 4, height: 6), fill(const Color(0xFFFEF08A)));
              }
            }
          } else if (retoId == 'alcachofa-flor') {
            // Corte longitudinal del corazón de la alcachofa mostrando el receptáculo y las brácteas imbricadas sin semillas
            canvas.drawRect(const Rect.fromLTWH(45, 64, 10, 14), fill(const Color(0xFF86EFAC)));
            canvas.drawArc(const Rect.fromLTWH(30, 46, 40, 24), 0, math.pi, true, fill(const Color(0xFFDCFCE7)));
            for (final (dx, col) in [(-16.0, const Color(0xFF16A34A)), (16.0, const Color(0xFF16A34A)), (-8.0, const Color(0xFF4ADE80)), (8.0, const Color(0xFF4ADE80))]) {
              final b = Path()
                ..moveTo(50 + dx, 56)
                ..quadraticBezierTo(50 + dx * 1.3, 34, 50 + dx * 0.4, 24)
                ..quadraticBezierTo(50 + dx * 0.5, 42, 50, 54)
                ..close();
              canvas.drawPath(b, fill(col));
              canvas.drawPath(b, stroke(const Color(0xFF14532D), 1.6));
            }
          } else if (esHojaOFlor) {
            // Corte de cogollo de hojas verdes mostrando láminas superpuestas y nervios blancos sin semillas
            for (final (r, col) in [(24.0, const Color(0xFF16A34A)), (18.0, const Color(0xFF4ADE80)), (12.0, const Color(0xFFBBF7D0))]) {
              canvas.drawCircle(const Offset(50, 50), r, fill(col));
              canvas.drawCircle(const Offset(50, 50), r, stroke(const Color(0xFF14532D), 1.8));
            }
            canvas.drawLine(const Offset(50, 74), const Offset(50, 30), stroke(Colors.white, 3.5));
          } else if (retoId == 'rabano-raiz') {
            // Rodaja de rábano: piel exterior carmesí y pulpa interior blanca crujiente
            canvas.drawCircle(const Offset(50, 50), 23, fill(const Color(0xFFE11D48)));
            canvas.drawCircle(const Offset(50, 50), 19, fill(Colors.white));
            canvas.drawCircle(const Offset(50, 50), 23, stroke(const Color(0xFF881337), 2.2));
          } else if (retoId == 'esparrago-tallo') {
            // Corte transversal del tallo de espárrago mostrando los haces vasculares en anillo, sin semillas
            canvas.drawCircle(const Offset(50, 50), 22, fill(const Color(0xFF22C55E)));
            canvas.drawCircle(const Offset(50, 50), 16, fill(const Color(0xFFDCFCE7)));
            canvas.drawCircle(const Offset(50, 50), 22, stroke(const Color(0xFF14532D), 2.2));
            for (int i = 0; i < 8; i++) {
              final a = i * math.pi / 4;
              canvas.drawCircle(Offset(50 + math.cos(a) * 11, 50 + math.sin(a) * 11), 2.2, fill(const Color(0xFF15803D)));
            }
          } else {
            // Rodaja de zanahoria: corteza naranja intensa y cilindro central (xilema/floema) más claro
            canvas.drawCircle(const Offset(50, 50), 23, fill(const Color(0xFFEA580C)));
            canvas.drawCircle(const Offset(50, 50), 23, stroke(const Color(0xFF9A3412), 2.2));
            canvas.drawCircle(const Offset(50, 50), 11, fill(const Color(0xFFFDBA74)));
            canvas.drawCircle(const Offset(50, 50), 11, stroke(const Color(0xFFC2410C), 1.8));
          }
        } else {
          // Función vital en la planta (absorción/transporte, fotosíntesis/floración o protección de semillas/germinación)
          canvas.drawRRect(marco, fill(const Color(0xFFFEFCE8)));
          canvas.drawRRect(marco, stroke(const Color(0xFF16A34A), 1.8));
          if (esRaizOTallo) {
            // Absorción de agua y sales o conducción vertical por el tallo hacia arriba
            canvas.drawRect(const Rect.fromLTWH(10, 58, 80, 28), fill(const Color(0xFF78350F)));
            canvas.drawLine(const Offset(50, 78), const Offset(50, 22), stroke(const Color(0xFF0284C7), 5.0));
            canvas.drawLine(const Offset(50, 22), const Offset(40, 34), stroke(const Color(0xFF0284C7), 4.0));
            canvas.drawLine(const Offset(50, 22), const Offset(60, 34), stroke(const Color(0xFF0284C7), 4.0));
            canvas.drawCircle(const Offset(32, 70), 3.5, fill(const Color(0xFF38BDF8)));
            canvas.drawCircle(const Offset(68, 70), 3.5, fill(const Color(0xFF38BDF8)));
          } else if (esHojaOFlor) {
            // Captación de luz solar en la hoja o preparación de la futura reproducción en el capullo floral
            canvas.drawCircle(const Offset(26, 28), 10, fill(const Color(0xFFFACC15)));
            canvas.drawLine(const Offset(36, 36), const Offset(48, 46), stroke(const Color(0xFFF59E0B), 2.5));
            canvas.save();
            canvas.translate(62, 54);
            canvas.scale(0.45, 0.45);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
          } else {
            // Germinación de una nueva plantita a partir de las semillas guardadas en el fruto o la vaina
            canvas.drawLine(const Offset(20, 74), const Offset(80, 74), stroke(const Color(0xFF78350F), 4.0));
            canvas.drawOval(const Rect.fromLTWH(44, 64, 12, 9), fill(const Color(0xFF86EFAC)));
            canvas.drawOval(const Rect.fromLTWH(44, 64, 12, 9), stroke(const Color(0xFF14532D), 1.8));
            canvas.drawLine(const Offset(50, 64), const Offset(50, 30), stroke(const Color(0xFF16A34A), 4.0));
            canvas.drawOval(const Rect.fromLTWH(32, 26, 18, 10), fill(const Color(0xFF22C55E)));
            canvas.drawOval(const Rect.fromLTWH(50, 26, 18, 10), fill(const Color(0xFF22C55E)));
          }
        }
      } else {
        // Nivel difícil: Planta en el campo, Interior/reserva microscópica y Recurso obtenido
        if (modo == 0) {
          // Planta en el campo: muestra cada cultivo real en su terreno (bajo tierra o aéreo)
          canvas.drawRRect(marco, fill(const Color(0xFFE0F2FE)));
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              const Rect.fromLTWH(8, 52, 84, 36),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
            fill(const Color(0xFF78350F)),
          );
          canvas.drawLine(const Offset(8, 52), const Offset(92, 52), stroke(const Color(0xFF451A03), 2.5));
          canvas.drawRRect(marco, stroke(const Color(0xFF16A34A), 1.8));

          if (retoId == 'patata-tuberculo') {
            // Mata verde arriba y estolones subterráneos con tubérculos de patata bajo tierra
            canvas.drawLine(const Offset(50, 52), const Offset(50, 24), stroke(const Color(0xFF15803D), 4.0));
            canvas.drawOval(const Rect.fromLTWH(34, 24, 14, 9), fill(const Color(0xFF22C55E)));
            canvas.drawOval(const Rect.fromLTWH(52, 24, 14, 9), fill(const Color(0xFF22C55E)));
            canvas.drawLine(const Offset(50, 52), const Offset(34, 68), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.drawLine(const Offset(50, 52), const Offset(66, 68), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.drawOval(const Rect.fromLTWH(22, 62, 20, 14), fill(const Color(0xFFFBBF24)));
            canvas.drawOval(const Rect.fromLTWH(56, 62, 20, 14), fill(const Color(0xFFFBBF24)));
            canvas.drawOval(const Rect.fromLTWH(22, 62, 20, 14), stroke(const Color(0xFF92400E), 1.8));
            canvas.drawOval(const Rect.fromLTWH(56, 62, 20, 14), stroke(const Color(0xFF92400E), 1.8));
          } else if (retoId == 'remolacha-raiz') {
            // Hojas de nervio rojo fuera y gruesa raíz morada enterrada
            for (final dx in [-10.0, 0.0, 10.0]) {
              canvas.drawLine(const Offset(50, 52), Offset(50 + dx, 24), stroke(const Color(0xFFBE123C), 3.0));
              canvas.drawOval(Rect.fromCenter(center: Offset(50 + dx, 26), width: 10, height: 14), fill(const Color(0xFF15803D)));
            }
            canvas.drawCircle(const Offset(50, 66), 13, fill(const Color(0xFF881337)));
            canvas.drawCircle(const Offset(50, 66), 13, stroke(const Color(0xFF4C0519), 2.0));
          } else if (retoId == 'cebolla-bulbo') {
            // Bulbo dorado enterrado con hojas tubulares verdes asomando arriba
            canvas.drawLine(const Offset(46, 52), const Offset(40, 20), stroke(const Color(0xFF16A34A), 3.8));
            canvas.drawLine(const Offset(50, 52), const Offset(50, 18), stroke(const Color(0xFF22C55E), 4.0));
            canvas.drawLine(const Offset(54, 52), const Offset(60, 20), stroke(const Color(0xFF16A34A), 3.8));
            canvas.drawCircle(const Offset(50, 66), 13, fill(const Color(0xFFD97706)));
            canvas.drawCircle(const Offset(50, 66), 13, stroke(const Color(0xFF78350F), 2.0));
          } else {
            // Cultivos de parte aérea (espigas de trigo, arbusto de algodón o rama de olivo)
            canvas.save();
            canvas.translate(50, 34);
            canvas.scale(0.46, 0.46);
            canvas.translate(-50, -50);
            const _PintorNuevoJuego()._dibujarIcono(canvas, retoId);
            canvas.restore();
            canvas.drawLine(const Offset(50, 52), const Offset(40, 74), stroke(const Color(0xFFFDE68A), 2.2));
            canvas.drawLine(const Offset(50, 52), const Offset(60, 74), stroke(const Color(0xFFFDE68A), 2.2));
          }
        } else if (modo == 1) {
          // Lupa de interior y reserva específica de cada planta
          canvas.drawCircle(const Offset(50, 50), 36, fill(Colors.white));
          canvas.drawCircle(const Offset(50, 50), 36, stroke(const Color(0xFFD97706), 2.5));
          if (retoId == 'patata-tuberculo') {
            // Gránulos ovalados de almidón con anillos de crecimiento dentro de las células de la patata
            for (final (gx, gy) in [(36.0, 42.0), (62.0, 40.0), (48.0, 60.0)]) {
              canvas.drawOval(Rect.fromCenter(center: Offset(gx, gy), width: 20, height: 14), fill(const Color(0xFFFEF9C3)));
              canvas.drawOval(Rect.fromCenter(center: Offset(gx, gy), width: 20, height: 14), stroke(const Color(0xFFD97706), 2.0));
              canvas.drawOval(Rect.fromCenter(center: Offset(gx - 2, gy), width: 10, height: 7), stroke(const Color(0xFFF59E0B), 1.4));
            }
          } else if (retoId == 'remolacha-raiz') {
            // Corte transversal morado con anillos concéntricos y cristales brillantes de sacarosa (azúcar)
            canvas.drawCircle(const Offset(50, 50), 24, fill(const Color(0xFF881337)));
            for (final r in [18.0, 12.0, 6.0]) {
              canvas.drawCircle(const Offset(50, 50), r, stroke(const Color(0xFFFDA4AF), 2.0));
            }
          } else if (retoId == 'cebolla-bulbo') {
            // Túnicas carnosas concéntricas blancas del bulbo de cebolla
            canvas.drawCircle(const Offset(50, 50), 25, fill(const Color(0xFFD97706)));
            canvas.drawCircle(const Offset(50, 50), 22, fill(const Color(0xFFFFFBEB)));
            for (final r in [17.0, 12.0, 6.0]) {
              canvas.drawCircle(const Offset(50, 50), r, stroke(const Color(0xFFF59E0B), 2.2));
            }
          } else if (retoId == 'trigo-harina') {
            // Grano de trigo en sección mostrando el endospermo blanco harinoso y el germen dorado
            final grano = Path()
              ..moveTo(50, 24)
              ..cubicTo(72, 30, 72, 70, 50, 76)
              ..cubicTo(28, 70, 28, 30, 50, 24)
              ..close();
            canvas.drawPath(grano, fill(const Color(0xFFD97706)));
            canvas.drawPath(grano, stroke(const Color(0xFF78350F), 2.2));
            canvas.drawOval(const Rect.fromLTWH(37, 30, 26, 38), fill(const Color(0xFFFFFBEB)));
            canvas.drawOval(const Rect.fromLTWH(44, 56, 12, 12), fill(const Color(0xFFFACC15)));
          } else if (retoId == 'algodon-fibra') {
            // Semilla central rodeada de larguísimas hebras blancas de celulosa bajo la lupa
            for (int i = 0; i < 16; i++) {
              final a = i * math.pi / 8;
              canvas.drawLine(
                Offset(50 + math.cos(a) * 6, 50 + math.sin(a) * 6),
                Offset(50 + math.cos(a) * 26, 50 + math.sin(a) * 26),
                stroke(const Color(0xFF94A3B8), 2.0),
              );
            }
            canvas.drawCircle(const Offset(50, 50), 8, fill(const Color(0xFF451A03)));
          } else {
            // Aceituna cortada mostrando la pulpa verde cargada de gotitas de aceite y el hueso leñoso central
            canvas.drawOval(const Rect.fromLTWH(28, 24, 44, 52), fill(const Color(0xFF65A30D)));
            canvas.drawOval(const Rect.fromLTWH(28, 24, 44, 52), stroke(const Color(0xFF365314), 2.2));
            canvas.drawOval(const Rect.fromLTWH(42, 34, 16, 32), fill(const Color(0xFF78350F)));
            for (final (ox, oy) in [(35.0, 42.0), (35.0, 54.0), (65.0, 44.0), (64.0, 56.0)]) {
              canvas.drawCircle(Offset(ox, oy), 3.2, fill(const Color(0xFFFACC15)));
            }
          }
        } else {
          // Modo 2: Recurso obtenido en la despensa o taller a partir de esa planta
          canvas.drawRRect(marco, fill(const Color(0xFFF8FAFC)));
          canvas.drawRRect(marco, stroke(const Color(0xFF0284C7), 1.8));
          if (retoId == 'patata-tuberculo') {
            // Plato con patatas asadas/cocidas ricas en energía y almidón
            canvas.drawOval(const Rect.fromLTWH(18, 52, 64, 24), fill(const Color(0xFFE2E8F0)));
            canvas.drawOval(const Rect.fromLTWH(18, 52, 64, 24), stroke(const Color(0xFF64748B), 2.0));
            canvas.drawOval(const Rect.fromLTWH(28, 40, 24, 18), fill(const Color(0xFFFBBF24)));
            canvas.drawOval(const Rect.fromLTWH(48, 42, 24, 18), fill(const Color(0xFFFDE047)));
            canvas.drawOval(const Rect.fromLTWH(28, 40, 24, 18), stroke(const Color(0xFF92400E), 1.8));
            canvas.drawOval(const Rect.fromLTWH(48, 42, 24, 18), stroke(const Color(0xFF92400E), 1.8));
          } else if (retoId == 'remolacha-raiz') {
            // Azucarero y terrones blancos de azúcar obtenidos de la remolacha azucarera
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 48, 22, 22), const Radius.circular(4)), fill(Colors.white));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(24, 48, 22, 22), const Radius.circular(4)), stroke(const Color(0xFF94A3B8), 2.0));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50, 48, 22, 22), const Radius.circular(4)), fill(Colors.white));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(50, 48, 22, 22), const Radius.circular(4)), stroke(const Color(0xFF94A3B8), 2.0));
            canvas.drawCircle(const Offset(50, 32), 10, fill(const Color(0xFF881337)));
          } else if (retoId == 'cebolla-bulbo') {
            // Aros blancos y dorados de cebolla listos para cocinar en la sartén/mesa
            for (final (cx, cy, r) in [(38.0, 52.0, 14.0), (60.0, 48.0, 14.0), (50.0, 62.0, 12.0)]) {
              canvas.drawCircle(Offset(cx, cy), r, stroke(const Color(0xFFD97706), 4.0));
              canvas.drawCircle(Offset(cx, cy), r - 2.5, stroke(const Color(0xFFFFFBEB), 2.5));
            }
          } else if (retoId == 'trigo-harina') {
            // Saco de harina blanca y hogaza dorada de pan crujiente con greña
            canvas.drawOval(const Rect.fromLTWH(24, 38, 52, 34), fill(const Color(0xFFD97706)));
            canvas.drawOval(const Rect.fromLTWH(24, 38, 52, 34), stroke(const Color(0xFF78350F), 2.2));
            for (final x in [38.0, 50.0, 62.0]) {
              canvas.drawLine(Offset(x - 4, 44), Offset(x + 4, 58), stroke(const Color(0xFFFEF3C7), 2.4));
            }
          } else if (retoId == 'algodon-fibra') {
            // Camiseta tejida con hilo de algodón 100 % vegetal
            final camiseta = Path()
              ..moveTo(36, 26)
              ..lineTo(44, 30)
              ..lineTo(56, 30)
              ..lineTo(64, 26)
              ..lineTo(80, 38)
              ..lineTo(72, 48)
              ..lineTo(64, 42)
              ..lineTo(64, 74)
              ..lineTo(36, 74)
              ..lineTo(36, 42)
              ..lineTo(28, 48)
              ..lineTo(20, 38)
              ..close();
            canvas.drawPath(camiseta, fill(Colors.white));
            canvas.drawPath(camiseta, stroke(const Color(0xFF0284C7), 2.2));
          } else {
            // Botella de cristal con aceite de oliva virgen dorado-verdoso
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(45, 20, 10, 16), const Radius.circular(3)), fill(const Color(0xFF84CC16)));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, 34, 32, 44), const Radius.circular(8)), fill(const Color(0xFFFACC15)));
            canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, 34, 32, 44), const Radius.circular(8)), stroke(const Color(0xFF4D7C0F), 2.2));
            canvas.drawOval(const Rect.fromLTWH(44, 48, 12, 16), fill(const Color(0xFF4D7C0F)));
          }
        }
      }
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PintorLaboratorioInteractivo oldDelegate) =>
      oldDelegate.actividadId != actividadId ||
      oldDelegate.nivel != nivel ||
      oldDelegate.retoId != retoId ||
      oldDelegate.respuestaId != respuestaId ||
      oldDelegate.modo != modo;
}
