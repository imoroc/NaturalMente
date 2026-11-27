import 'package:flutter/widgets.dart';

/// Dibujos que ya existen como ilustración webp en `assets/cromos/`.
/// Cada pieza que aparece aquí se muestra con su webp; las que no, se siguen
/// dibujando en código hasta que haya imagen. Para pasar otra pieza a webp
/// basta con añadir su nombre a esta lista.
const _conWebp = <String>{
  // Animales
  'camello', 'delfin', 'pinguino', 'oso', 'rana', 'tucan', 'pulpo',
  // Órganos
  'corazon', 'pulmones', 'estomago', 'cerebro', 'esqueleto', 'intestinos',
  // Partes de la planta
  'raiz', 'tallo', 'hoja', 'flor', 'fruto',
  // Plantas
  'encina', 'romero', 'trigo',
};

bool hayArteWebp(String id) => _conWebp.contains(id);

/// Cromos que ya tienen su ilustración en `assets/cromos/` (los que en el
/// catálogo llevan `arteCromo: true`). Las pantallas de los juegos usan esta
/// lista para enseñar el mismo dibujo que el álbum.
const _cromosConWebp = <String>{
  'abeja-polen',
  'anfibio',
  'aparato-circulatorio',
  'aparato-digestivo',
  'aparato-respiratorio',
  'artropodo',
  'asi-vive-una-planta',
  'avisos',
  'bosque-clima',
  'branquias',
  'cada-parte-su-trabajo',
  'camello',
  'celula',
  'cerebro',
  'claro-bosque',
  'como-viven-animales',
  'corazon',
  'cuidar-sentidos',
  'delfin',
  'descanso',
  'dientes',
  'emociones',
  'empatia',
  'encina',
  'especies-amenazadas',
  'esqueleto',
  'estomago',
  'etapas-vida',
  'etiqueta',
  'flor',
  'formas-hoja',
  'fotosintesis',
  'fotosintesis-hoja',
  'fruta-verdura',
  'fruto',
  'funciones-vitales',
  'helecho-espora',
  'herbivoro',
  'higiene',
  'hoja',
  'hoja-caduca',
  'huerta-organos',
  'huerto',
  'huevo',
  'intestinos',
  'la-flor-por-dentro',
  'lombriz-galeria',
  'mariposa',
  'menos-plasticos',
  'merienda',
  'moverse-cada-dia',
  'nombrar-emociones',
  'nutrientes',
  'oso',
  'partes-comestibles',
  'pelo-plumas-escamas',
  'pico-garra',
  'pinguino',
  'plato-equilibrado',
  'pulmones',
  'pulpo',
  'raiz',
  'rana',
  'rana-charca',
  'recursos-plantas',
  'reflejo',
  'reinos',
  'renacuajo',
  'respirar-hondo',
  'romero',
  'savia-elaborada',
  'savia-planta',
  'semilla',
  'semilla-viajera',
  'sentidos',
  'separar-residuos',
  'ser-vivo',
  'sistema-nervioso',
  'tallo',
  'trigo',
  'trucha-arroyo',
  'tucan',
  'una-vida',
  'vertebrado',
  'vertebrados-invertebrados',
};

bool hayCromoWebp(String id) => _cromosConWebp.contains(id);

Widget arteWebp(String id, {double? ancho, double? alto}) => Image.asset(
  'assets/cromos/$id.webp',
  width: ancho,
  height: alto,
  fit: BoxFit.contain,
  filterQuality: FilterQuality.medium,
  excludeFromSemantics: true,
);
