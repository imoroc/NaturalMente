import 'package:naturalmente/modelo/aula/juego_aula.dart';

/// Juegos de ejemplo para no empezar de cero. Al elegir uno se abre una copia
/// en borrador que el profe cambia a su gusto; el ejemplo no se toca.
const juegosDeEjemplo = <JuegoAula>[
  JuegoAula(
    id: '',
    titulo: 'Los animales vertebrados',
    plantilla: PlantillaAula.libre,
    version: 1,
    cursos: [3],
    fondo: ImagenEscena('pradera'),
    intro: '¡Vamos a repasar los animales con esqueleto!',
    preguntas: [
      LecturaAula(
        enunciado: '¿Qué es un vertebrado?',
        texto:
            'Los vertebrados son animales con esqueleto de huesos por dentro. Hay cinco grupos: mamíferos, aves, peces, reptiles y anfibios.',
      ),
      PreguntaAula(
        enunciado: '¿Cuál de estos animales es un mamífero?',
        opciones: [
          OpcionAula(texto: 'Delfín'),
          OpcionAula(texto: 'Tiburón'),
          OpcionAula(texto: 'Pulpo'),
        ],
        correcta: 0,
        pista: 'Piensa en cuál respira con pulmones y toma leche de pequeño.',
        explicacion: 'El delfín vive en el mar, pero es un mamífero.',
      ),
      ClasificarAula(
        enunciado: '¿Tiene plumas o tiene pelo?',
        grupos: [OpcionAula(texto: 'Plumas'), OpcionAula(texto: 'Pelo')],
        elementos: [
          ElementoGrupo(OpcionAula(texto: 'Gorrión'), 0),
          ElementoGrupo(OpcionAula(texto: 'Perro'), 1),
          ElementoGrupo(OpcionAula(texto: 'Pingüino'), 0),
          ElementoGrupo(OpcionAula(texto: 'Conejo'), 1),
        ],
      ),
      PreguntaAula(
        tipo: TipoReto.verdaderoFalso,
        enunciado: 'Las ranas son reptiles.',
        opciones: [OpcionAula(texto: 'Verdadero'), OpcionAula(texto: 'Falso')],
        correcta: 1,
        explicacion: 'Las ranas son anfibios: nacen en el agua y luego viven también en tierra.',
      ),
    ],
  ),
  JuegoAula(
    id: '',
    titulo: 'Así crece una planta',
    plantilla: PlantillaAula.libre,
    version: 1,
    cursos: [2],
    fondo: ImagenEscena('jardin'),
    preguntas: [
      OrdenarAula(
        enunciado: 'Ordena cómo crece una planta',
        pasos: [
          OpcionAula(texto: 'Semilla'),
          OpcionAula(texto: 'Brote'),
          OpcionAula(texto: 'Planta con hojas'),
          OpcionAula(texto: 'Planta con flores'),
        ],
        pista: 'Todo empieza con algo muy pequeño que se planta en la tierra.',
      ),
      ParejasAula(
        enunciado: 'Une cada parte con lo que hace',
        parejas: [
          (OpcionAula(texto: 'Raíz'), OpcionAula(texto: 'Toma agua del suelo')),
          (OpcionAula(texto: 'Hoja'), OpcionAula(texto: 'Fabrica el alimento')),
          (OpcionAula(texto: 'Flor'), OpcionAula(texto: 'Da las semillas')),
        ],
      ),
      HuecosAula(
        enunciado: 'Completa la frase',
        frase: 'Las plantas necesitan [agua], [luz] y aire para vivir.',
        distractores: ['chocolate', 'ruido'],
      ),
    ],
  ),
  JuegoAula(
    id: '',
    titulo: 'Nuestro cuerpo',
    plantilla: PlantillaAula.libre,
    version: 1,
    cursos: [5, 6],
    fondo: ImagenEscena('noche'),
    preguntas: [
      NumeroAula(
        enunciado: '¿Cuántos pulmones tenemos?',
        respuesta: 2,
        explicacion: 'Dos pulmones, a cada lado del corazón.',
      ),
      PalabraAula(
        enunciado: '¿Qué órgano bombea la sangre?',
        respuesta: 'corazón',
      ),
      PreguntaAula(
        enunciado: '¿Para qué sirve el esqueleto?',
        opciones: [
          OpcionAula(texto: 'Sostener el cuerpo y proteger los órganos'),
          OpcionAula(texto: 'Digerir la comida'),
          OpcionAula(texto: 'Respirar'),
        ],
        correcta: 0,
      ),
    ],
  ),
];
