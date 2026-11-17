# Plan de implementación de los selectores visuales

Fecha: 16 de noviembre de 2026. Estado: planificación; pendiente de implementar.

## Objetivo y referencia elegida

Aplicar la mejora 3 de la revisión de usabilidad a las 26 actividades y al reto diario: **27 selectores y 81 presentaciones de nivel**. La referencia elegida es el segundo mock, «Aprender viendo»: tres tarjetas ilustradas, cada una con nombre del nivel, ejemplo de la actividad y una frase corta. Tocar cualquier punto de la tarjeta empieza ese nivel, sin confirmación adicional.

El ejemplo visual debe explicar la mecánica real de cada dificultad. No basta con cambiar de animal o añadir estrellas: hay actividades que pasan de clasificar a ordenar, investigar o explicar. Las tablas de este documento concretan los 81 casos y son el inventario de implementación.

Se mantienen las decisiones de [contexto](contexto.md), [decisiones](decisiones.md), [contribución](../CONTRIBUTING.md) y [feedback y cierre](feedback-y-cierre.md). Este trabajo modifica la entrada a los juegos; los ejercicios conservan sus preguntas, dificultad, contenido, puntuación, persistencia y cierre comunes. La validación pendiente con el colegio de la reproducción sigue vigente.

## Experiencia común

### Pantalla inicial

1. Cabecera con atrás y título completo del juego. Permitir dos líneas para títulos largos; no competir con la racha ni reproducir celebraciones en el selector.
2. Natu pequeño junto a **«¿Cómo quieres jugar?»**. Sin el párrafo introductorio sobre cursos y recompensas.
3. Tres tarjetas, siempre en orden Fácil, Medio, Difícil. Texto a la izquierda y escena ilustrada a la derecha, como en el mock elegido. Toda la superficie es un botón; la flecha es una señal visual de esa misma acción.
4. Nombre de nivel y una frase de acción. El texto de las tablas es la propuesta inicial ES/EN; ajustar solo por fidelidad o legibilidad, no añadir otro párrafo.
5. Si un nivel está completado, un check pequeño y la etiqueta accesible «Nivel superado». No sustituir su nombre ni bloquearlo. El estado no depende únicamente del verde.
6. Pie: **«Todos los niveles están abiertos.»** y enlace **«Sobre los niveles»**. No usar «abiertos» para implicar que el reto diario se puede repetir después de completarlo.

Las tarjetas tienen el mismo peso visual. No se selecciona ni recomienda automáticamente una dificultad. Eliminar de su superficie cursos, párrafos, estrellas de dificultad, listas de cromos y candados. Evitar que un ejemplo ilustrado parezca un cromo bloqueado o una recompensa por tocarlo.

### Información secundaria

«Sobre los niveles» abre una única hoja accesible y desplazable con los tres niveles. Cada bloque contiene nombre, curso orientativo, descripción pedagógica actual y cromos asociados con su estado. Obtener los cursos y descripciones de los modelos existentes y los cromos de `Progreso.fichasDeNivel`; no duplicar esa información en otro catálogo.

La hoja tiene título, cierre visible y soporte para atrás. No contiene selectores, pestañas ni submenús. Cerrar devuelve el foco al enlace que la abrió y conserva el desplazamiento del selector. Abrirla o cerrarla no inicia una partida, guarda un progreso ni concede recompensas. Los niveles pueden volver a jugarse aunque sus cromos ya estén conseguidos.

En el reto diario la hoja explica cursos, tipo de preguntas, límite de una expedición diaria y bonos actuales de 8/10/12 semillas. No inventar cromos por nivel diario. Las preguntas diarias concretas cambian: las ilustraciones son ejemplos del banco, no una promesa de lo que saldrá hoy.

### Entrada, regreso y movimiento

- Pulsar la tarjeta ofrece el feedback táctil/visual de botón que ya use el proyecto y ejecuta **una sola vez** el callback actual de inicio. No reproduce el check de acierto, fanfarria ni recompensa.
- Proteger un doble toque sincrónicamente mientras se inicia la partida. No añadir otro temporizador ni una segunda navegación a los callbacks existentes.
- Entrada de contenido con un único desvanecimiento breve, de 120–160 ms; sin entradas escalonadas, rebotes, parallax ni escenas animadas continuamente. No retrasar el inicio del juego para completar una animación.
- Movimiento reducido: aparición inmediata y estado de pulsación sin escala. No introducir sonidos o vibraciones nuevos para estas escenas decorativas.
- Atrás desde el selector vuelve al mundo de origen. «Cambiar nivel» del juego devuelve al mismo selector actualizado; restaura su desplazamiento si sigue siendo válido, sin elegir ni arrancar otro nivel.
- La repetición y las acciones de `FinJuego` siguen usando sus callbacks actuales. No migrar el coordinador de feedback ni cambiar cuándo se completa un nivel.

### Particularidades del reto diario

Antes de completar la expedición se muestran las mismas tres tarjetas y una frase corta visible: **«Una expedición al día.»** La racha diaria puede conservarse como información secundaria después de las tarjetas, sin su animación de celebración al elegir nivel. Este cambio no modifica el concepto ni el cálculo de racha.

Se conserva `_iniciarConDificultad` y el funcionamiento actual para cambiar de dificultad antes de terminar. No presentar el cambio como una forma de borrar errores o recuperar recompensas. Una expedición completada no muestra un selector disponible: presenta su resultado y las acciones permitidas. Un guardado pendiente recupera ese cierre y su reintento, no otra partida. Se aplican las mismas reglas si la fecha cambia, si se reabre la app o si se vuelve del armario.

## Arquitectura y puntos de integración

Los nombres siguientes son **componentes propuestos**, no APIs ya implementadas:

| Archivo propuesto | Responsabilidad |
| --- | --- |
| `lib/ui/selector_nivel.dart` | `SelectorNivelVisual`, `TarjetaNivelVisual` y hoja «Sobre los niveles»; layout, foco, semántica, estado de inicio y navegación de la hoja. |
| `lib/ui/presentacion_niveles.dart` | `PresentacionNivel`: clave actividad/nivel, frase ES traducible y receta tipada de escena. Registro explícito de los 81 casos, sin datos de puntuación ni guardado. |
| `lib/ui/escena_nivel.dart` | `EscenaNivel`: compone ilustraciones existentes y fondos locales simples a partir de las recetas. Representación estática, sin montar un juego real ni sus controladores. |

Cada pantalla adapta su modelo a datos de presentación: id, nombre, curso, resumen, completado, cromos y callback. No crear una clase nueva de reglas ni modificar los siete formatos de nivel del catálogo solo para compartir la tarjeta. Conservar los ids `facil`, `medio`, `dificil`, los modelos originales y las claves de almacenamiento. El registro visual contiene únicamente lo nuevo; los adaptadores leen lo demás de su fuente actual.

| Integración existente | Cobertura | Cambio previsto |
| --- | --- | --- |
| [`JuegoPage._selector`](../lib/ui/juego.dart) | 19 actividades: 17 `lugar`, germinación (`controles`) y vida (`orden`). | Sustituir el cuerpo del selector, reutilizar `_empezarNivel` y `nivelLugarHecho`. `nivelesLugar` también contiene los niveles de controles y orden. |
| [`NacimientoPage`](../lib/ui/nacimiento.dart) | `nacimiento` | Sustituir `_selector` / `_tarjetaNivel`; preservar `_empezar` y el cambio de mecánica según el nivel. |
| [`ViajePage`](../lib/ui/digestion.dart) | `digestion` | Sustituir `_selector` / `_tarjetaNivel`; conservar el inicio, las paradas y las preguntas. |
| [`HerbarioPage`](../lib/ui/herbario.dart) | `herbario` | Sustituir `_selector`; representar el número de partes y las funciones del nivel. |
| [`EcosistemaPage`](../lib/ui/ecosistema.dart) | `ecosistemas` | Sustituir `_selector`; preservar inicio, conexiones y comparación causal. |
| [`RescatePage`](../lib/ui/rescate.dart) | `cuida-reserva` | Sustituir `_selector` / `_tarjetaNivel`; dar una escena distinta a recoger, reciclar y proteger especies. |
| [`JuegoPropio._selector`](../lib/ui/juego_propio.dart) | `memoria-plantas`, `quien-soy` | Adaptar `nivelesJuego` y su estado a la tarjeta común; conservar `empezar`. Las `muestras` actuales se revisan y dejan de duplicar imágenes dentro de la nueva tarjeta. |
| [`ExpedicionDiariaPage._construirPantallaSeleccionDificultad`](../lib/ui/expedicion_diaria.dart) | Reto diario | Compartir tarjetas y hoja, manteniendo el flujo diario y sus estados completado/pendiente. |

Verificar los nombres privados al iniciar la implementación. Conservar las keys `nivel-$id` y `dificultad-reto-$id`, además de los callbacks de cambiar/repetir/volver. Añadir claves específicas para abrir y cerrar la hoja; no cambiar las existentes para hacer pasar pruebas.

## Ilustraciones y contenido

### Reglas para las escenas

- Una ilustración pequeña pero reconocible del **tipo de tarea**, no una reproducción completa del tablero ni otro juego interactivo.
- Reutilizar los dibujos de animales, plantas, sentidos, órganos, nacimiento, digestión, residuos y emociones del repositorio. Componer versiones estáticas para el selector; no reducir una captura del tablero hasta que sus textos sean ilegibles.
- Preparar 27 familias de escenas con tres configuraciones cada una. Compartir piezas cuando sea correcto, pero cada receta debe distinguir visualmente el nivel. Un mismo fondo con más estrellas no cumple.
- Inventariar primero qué piezas sirven, cuáles necesitan una variante y cuáles faltan. Las escenas propuestas en las tablas son objetivos, no una afirmación de que ya existan todos sus dibujos.
- Mantener el lenguaje del mock elegido, adaptando sus escenas nuevas a las ilustraciones de la app. No importar automáticamente el camello o la rana generados: el mock define la composición, no reemplaza todos los recursos actuales.
- Si falta una pieza, extender preferentemente el dibujo nativo correspondiente con una variante propia. Evitar 81 bitmaps y recursos remotos. Cualquier recurso nuevo debe quedar local, con autoría/licencia registrada en [licencias](../content/licencias.md).
- Las flechas científicas deben ser correctas: alimento hacia quien lo consume; agua desde las raíces; recorrido digestivo sin pasar por corazón/pulmones. No usar flechas decorativas que enseñen otra relación.
- No hacer depender la comprensión de texto diminuto dentro del dibujo. La frase de la tarjeta explica la acción; la escena es decorativa para el lector de pantalla y se excluye de su árbol semántico.

### Inventario por actividad

Las frases EN son propuestas de traducción para incorporar a [`content/en.json`](../content/en.json), junto con los textos comunes. Las escenas se identifican por la pareja estable actividad/nivel. Fácil, Medio y Difícil conservan sus traducciones actuales. El curso orientativo se conserva en la hoja secundaria.

| Texto común ES | Propuesta EN | Uso |
| --- | --- | --- |
| ¿Cómo quieres jugar? | How would you like to play? | Encabezado común. |
| Todos los niveles están abiertos. | All levels are available. | Selectores de actividades; en el diario solo antes de completar. |
| Sobre los niveles | About the levels | Enlace y título de la hoja secundaria. |
| Una expedición al día. | One expedition a day. | Regla visible del reto diario. |
| Nivel superado | Level completed | Estado accesible y discreto de actividad, reutilizando la traducción existente si está disponible. |

Los textos que ya tengan traducción se reutilizan. La hoja conserva el formato traducible del curso, nombres de cromos y resúmenes; no concatenar fragmentos ES en un párrafo EN.

### La reserva · 9 juegos

#### Cada uno a su hogar (`hogar`)

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Lleva al camello a casa. | Take the camel home. | Camello junto a dunas y un destino de desierto. |
| Medio | Relaciona su hogar y su cuerpo. | Match its home and body. | Rana en una charca, con detalle de su piel húmeda. |
| Difícil | Descubre cómo se adapta. | Discover how it adapts. | Pulpo junto a un refugio marino y detalle de sus ventosas. |

#### ¿Huevo o barriga? (`nacimiento`)

La progresión cambia de clasificación a secuenciación y comparación; no reutilizar huevo/barriga como único ejemplo en los tres niveles.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | ¿Nace de huevo o de barriga? | From an egg or a mother’s tummy? | Pingüino junto a huevo; camello junto a madre y cría. |
| Medio | Ordena cómo crecen. | Put their growth in order. | Huevo, renacuajo y rana; señales de secuencia, no contenedores. |
| Difícil | Compara sus metamorfosis. | Compare their metamorphoses. | Dos secuencias resumidas: rana y mariposa, conservando sus fases distintas. |

#### Picos, dientes y huellas (`dieta`)

Cada nivel tiene un laboratorio distinto: dieta, herramientas para conseguir alimento y huellas/desplazamiento.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Descubre qué come. | Find out what it eats. | Ciervo junto a hojas y detalle sencillo de muelas. |
| Medio | Investiga cómo consigue comida. | Explore how it gets food. | Garza con pico largo y pez; detalle de la forma del pico. |
| Difícil | Sigue las huellas. | Follow the tracks. | Cabra y huella hendida; acercamiento de su pezuña sobre una pendiente. |

#### ¿Huesos o caparazón? (`grupos`)

Cambiar de huesos internos a grupos de vertebrados y finalmente a invertebrados. Una concha no implica vertebración.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | ¿Tiene huesos por dentro? | Does it have bones inside? | Caballo con una zona de esqueleto visible y escarabajo sin columna. |
| Medio | Reconoce su grupo. | Recognise its group. | Lagartija, cigüeña y pez con detalle de escamas o plumas. |
| Difícil | Investiga los invertebrados. | Explore the invertebrates. | Araña y abeja; sus ocho y seis patas distinguibles, sin etiquetarlas como equivalentes. |

#### Monta el ecosistema (`ecosistemas`)

Fácil coloca seres vivos; Medio conecta alimento; Difícil conserva la comparación causal al cambiar el claro.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Da vida al claro. | Bring the clearing to life. | Claro con planta, conejo y zorro como piezas para colocar. |
| Medio | Conecta quién alimenta a quién. | Connect who feeds whom. | Hierba → conejo → zorro; dirección de alimento a consumidor. |
| Difícil | Explora qué pasa si algo cambia. | Explore what happens when things change. | Dos estados del mismo claro, uno con menos hierba y consecuencias en la cadena. |

#### ¿Vivo o no vivo? (`vivo`)

El ejemplo de objeto inerte reutiliza el catálogo; no se introduce un bloque de geología ni se usa movimiento como criterio único.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | ¿Está vivo o no? | Is it alive or not? | Gato y objeto inerte, sin añadir al juego un contenido nuevo. |
| Medio | Investiga los casos que despistan. | Explore the puzzling cases. | Semilla y seta junto a robot de juguete, sin usar solo movimiento como criterio de vida. |
| Difícil | Agrupa los seres vivos. | Group the living things. | Animal, planta, hongo y microbio con lupa; sin enseñar que los microbios son todos iguales. |

#### ¿Cómo respira? (`respiracion`)

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | ¿Respira aire o bajo el agua? | Does it breathe air or underwater? | Delfín que sube a superficie y pez con detalle de branquias. |
| Medio | Descubre con qué respira. | Discover what it breathes with. | Lombriz en suelo húmedo y renacuajo en agua; piel/branquias distinguibles. |
| Difícil | Explora otras formas de respirar. | Explore other ways of breathing. | Insecto con detalle de tráqueas y medusa con intercambio a través del cuerpo. |

#### Cuida la reserva (`cuida-reserva`)

Las tres mecánicas son distintas: limpiar, reciclar y proteger especies. Conservar preguntas de amenazas y soluciones.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Recoge la basura del entorno. | Pick up litter from nature. | Bosque y orilla con bolsa/botella, separados visualmente de hojas y setas vivas. |
| Medio | Lleva cada residuo a su contenedor. | Take each item to its recycling bin. | Botella, papel y contenedores con símbolos además de color. |
| Difícil | Ayuda a las especies en peligro. | Help endangered species. | Lince y un entorno protegido; amenaza/acción de cuidado, no más contenedores. |

#### ¿Quién soy? (`quien-soy`)

Las opciones pasan de 3 a 4 y 6. La ilustración no revela el animal de la próxima ronda ni depende de un barajado real.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Adivina con dibujos y pistas. | Guess with pictures and clues. | Orejas de conejo y tres candidatos ilustrados. |
| Medio | Adivina cómo vive cada animal. | Guess how each animal lives. | Búho de noche y cuatro candidatos; la escena muestra una pista de hábitos. |
| Difícil | Descubre su grupo con las pistas. | Use clues to find its group. | Murciélago y araña entre seis siluetas; indicios de vertebrado/invertebrado sin dar un ejemplo falso. |

### El invernadero · 8 juegos

#### Laboratorio de germinación (`germinacion`)

Entra por JuegoPage aunque sea de tipo controles. Los cambios de riego, sustrato y temperatura de la escena no son controles reales.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Siembra y cuida tu semilla. | Plant and care for your seed. | Semilla en algodón/tierra, gota de agua y brote junto a ventana. |
| Medio | Compara dónde crece mejor. | Compare where it grows best. | Dos recipientes con distintos sustratos y retención de agua; mismo momento de crecimiento. |
| Difícil | Ajusta agua, luz y temperatura. | Adjust water, light and temperature. | Brote con riego, ventana y termómetro sencillo; sin panel técnico completo. |

#### Polen y semillas viajeras (`polinizacion`)

Fácil estudia partes de la flor; Medio dispersión; Difícil grupos reproductivos. No prometer polinizar una flor en los tres.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Descubre las partes de la flor. | Explore the parts of a flower. | Flor abierta con pétalos, estambres y pistilo diferenciados. |
| Medio | Ayuda a viajar a las semillas. | Help seeds travel. | Semilla de arce al viento y coco flotando; dos mecanismos distintos. |
| Difícil | Compara cómo se reproducen las plantas. | Compare how plants reproduce. | Manzano con fruto, piña de pino y soros de helecho; sin atribuir flores al helecho. |

#### Los árboles y las estaciones (`estaciones`)

Distinguir caída de hojas, forma/adaptación y lectura del clima, sin añadir nuevos bosques o especies.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Observa qué hojas se caen. | See which leaves fall. | Mismo árbol caducifolio en otoño e invierno y un pino verde de referencia. |
| Medio | Investiga la forma de las hojas. | Explore the shape of leaves. | Hoja lobulada de roble y acículas de pino bajo lupa. |
| Difícil | Descubre el bosque por su clima. | Identify the forest by its climate. | Haya y pequeño patrón de lluvia/temperatura legible como ejemplo, no un gráfico con cifras minúsculas. |

#### Del huerto a la mesa (`huerta`)

Pasar de tres órganos comestibles a seis categorías y después a órganos de reserva/transformaciones.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | ¿Qué parte de la planta comemos? | Which part of the plant do we eat? | Zanahoria en suelo, lechuga y tomate en su planta. |
| Medio | Explora las partes comestibles. | Explore the edible parts. | Espárrago, alcachofa y guisantes con posición en planta reconocible. |
| Difícil | Descubre en qué se transforman. | Discover what plants become. | Espiga de trigo junto a harina; patata con detalle de tubérculo. |

#### Herbario desmontable (`herbario`)

Fácil: tres partes; Medio: cinco; Difícil: las cinco más sus funciones. No atribuir funciones evaluadas a Medio.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Monta raíz, tallo y hojas. | Build roots, stem and leaves. | Planta simple de tres partes y piezas próximas a su posición. |
| Medio | Añade la flor y el fruto. | Add the flower and fruit. | Misma planta con las cinco partes disponibles. |
| Difícil | Relaciona cada parte con su función. | Match each part to its job. | Raíz absorbiendo agua y hoja recibiendo luz, como ejemplos de función. |

#### Árbol, arbusto o hierba (`plantas`)

Fácil todavía no incluye arbusto; Difícil añade cultivada/silvestre sin eliminar árbol/arbusto/hierba.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Separa árboles y hierbas. | Sort trees and herbs. | Encina de tronco único y hierba de tallo blando. |
| Medio | Distingue árbol, arbusto y hierba. | Tell trees, shrubs and herbs apart. | Encina, romero con varios tallos leñosos y amapola. |
| Difícil | ¿Crece sola o la cultivamos? | Does it grow wild or do we grow it? | Amapola silvestre y tomatera de huerta, conservando la distinción de tipo de tallo. |

#### El viaje de la savia (`savia`)

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Sigue el agua por la planta. | Follow water through the plant. | Raíz absorbiendo agua y hoja a la luz; relación sencilla de nutrición. |
| Medio | Descubre dónde ocurre cada paso. | Discover where each step happens. | Raíz, tallo y hoja con rutas de agua, aire y alimento diferenciadas. |
| Difícil | Explora xilema, floema y estomas. | Explore xylem, phloem and stomata. | Acercamiento de vasos en tallo y poro de hoja; el alimento no se dibuja bajando siempre en una única dirección. |

#### Memoria de las plantas (`memoria-plantas`)

Las parejas relacionan partes y funciones, no dos imágenes idénticas. Distinguir 6, 10 y 12 cartas sin añadir contadores a la tarjeta.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Busca parejas de partes y funciones. | Match plant parts with their jobs. | Dos cartas de ejemplo: raíz y agua; pequeña pila que representa seis cartas. |
| Medio | Une dibujos con lo que hacen. | Match pictures with what they do. | Abeja con polen y flor/fruto, junto a más cartas; representa diez cartas, no parejas idénticas. |
| Difícil | Relaciona nutrición y reproducción. | Match nutrition and reproduction. | Hoja/fotosíntesis y estambres/polen en cartas; representa doce cartas. |

### Dentro de mí · 9 juegos

#### Cada pieza en su sitio (`piezas`)

Mantener la silueta corporal; no convertir el ejemplo en una tarea interactiva ni ocultar órganos debajo del texto.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Coloca cada órgano en su sitio. | Put each organ in its place. | Silueta sencilla con corazón, cerebro y estómago como piezas. |
| Medio | Coloca órganos y descubre su función. | Place organs and explore their jobs. | Silueta con pulmones y corazón, y pequeño indicio de respiración/latido. |
| Difícil | Relaciona órganos y sistemas. | Match organs and body systems. | Órganos relacionados con el aparato correspondiente, sin inventar una disección nueva. |

#### El viaje de la comida (`digestion`)

El detalle de absorción aparece en Difícil. La masticación del ejemplo no se ejecuta ni puntúa al elegir nivel.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Mastica y lleva la comida dentro. | Chew and take the food inside. | Manzana, boca y estómago; trayecto corto con masticación. |
| Medio | Recorre el aparato digestivo. | Follow the digestive journey. | Boca, esófago, estómago e intestinos en un recorrido continuo. |
| Difícil | Descubre cómo aprovechamos los nutrientes. | Discover how we use nutrients. | Detalle de intestino delgado y paso de nutrientes hacia la sangre. |

#### Los cinco sentidos (`sentidos`)

La progresión va de órgano/sentido a situación cotidiana y después a señal nerviosa/reflejos.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Une cada órgano con su sentido. | Match each organ to its sense. | Ojo y visión; oreja y sonido, como dos relaciones de ejemplo. |
| Medio | Descubre qué sentido te avisa. | Find out which sense alerts you. | Niño que oye un timbre y mano que nota agua fría. |
| Difícil | Sigue el mensaje hasta el cerebro. | Follow the message to the brain. | Piel, nervio y cerebro en una secuencia de señal sencilla; referencia a retirada refleja sin atribuirla toda al cerebro. |

#### Así empieza una vida (`vida`)

Ilustración educativa, neutral y coherente con el contenido existente. No añadir escenas explícitas ni alterar el contenido curricular.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Ordena la historia de un bebé. | Put a baby’s story in order. | Viñetas neutras de gestación, nacimiento y cuidados en familia. |
| Medio | Del comienzo a los primeros pasos. | From the beginning to first steps. | Primera célula, desarrollo en el útero y bebé que empieza a andar. |
| Difícil | De una célula al crecimiento. | From one cell to growing up. | Cigoto, división celular y etapas de crecimiento; representación científica sobria. |

#### Un plato que cuida (`plato`)

La tarjeta de Difícil representa comparar etiquetas, no seguir completando el plato. Los umbrales y respuestas no se cambian.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Prepara una merienda que te cuide. | Make a snack that cares for you. | Merienda con fruta, yogur y alimento ocasional; sin moralizar comida como buena/mala. |
| Medio | Completa un plato variado. | Build a varied plate. | Plato dividido con verduras/fruta, cereal y proteína. |
| Difícil | Compara las etiquetas. | Compare food labels. | Dos envases con etiquetas ficticias de azúcar/sal/grasa; sin cifras ilegibles en la miniatura. |

#### ¿Me cuida o no? (`habitos`)

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Elige lo que te cuida. | Choose what helps you stay well. | Manos con jabón, vaso de agua y juego al aire libre. |
| Medio | Cuida tu descanso y tus emociones. | Care for your rest and feelings. | Niño durmiendo y conversación tranquila, sin presentar emociones como errores. |
| Difícil | Protege tu cuerpo cada día. | Protect your body every day. | Postura con mochila y volumen moderado de auriculares, sin cambiar las decisiones del juego. |

#### ¿Qué parte cuido? (`cuidados`)

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | ¿Qué parte estás cuidando? | Which body part are you caring for? | Cepillo de dientes cerca de cabeza y manos lavándose junto a brazos. |
| Medio | Cuida también el corazón y los pulmones. | Care for your heart and lungs too. | Silueta del pecho, respiración tranquila y movimiento. |
| Difícil | Relaciona hábitos y órganos. | Match habits to organs. | Descanso junto a cerebro y agua junto a intestinos, como relaciones del nivel. |

#### Cada órgano, su trabajo (`organos`)

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Descubre el trabajo de cada órgano. | Discover each organ’s job. | Corazón, pulmones y estómago con indicios de latido, aire y comida. |
| Medio | ¿Quién manda y quién aprovecha la comida? | Who gives orders and who uses food? | Cerebro e intestinos, destacados entre órganos conocidos. |
| Difícil | Relaciona los órganos que trabajan juntos. | Connect the organs that work together. | Pulmones/corazón y estómago/intestinos en parejas funcionales del nivel. |

#### ¿Cómo me siento? (`emociones`)

En Difícil el foco cambia a acompañar a otra persona; no representar emociones que deban eliminarse o corregirse.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Pon nombre a lo que sientes. | Name what you feel. | Caras de alegría, tristeza, enfado y miedo con contexto sencillo. |
| Medio | Reconoce más emociones. | Recognise more feelings. | Niño antes de una función y otro con vergüenza; expresiones diferentes sin juicio. |
| Difícil | Descubre cómo ayudar a un compañero. | Find out how to help a classmate. | Dos compañeros, uno acompañando al que se queda solo; énfasis en empatía. |

### Reto diario · 1 selector

#### Expedición del Día con Natu (`reto-diario`)

Tres preguntas de la dificultad elegida. Las escenas representan el banco y los tres mundos, no un itinerario fijo ni el sorteo concreto del día.

| Nivel | Frase ES | Frase EN | Escena prevista |
| --- | --- | --- | --- |
| Fácil | Tres retos para observar y descubrir. | Three challenges to observe and discover. | Camello, raíz y corazón: ejemplos de los tres mundos del banco Fácil. |
| Medio | Relaciona pistas de los tres mundos. | Connect clues from all three worlds. | Rana y humedad, flor/fruto y pulmones: ejemplos del banco Medio. |
| Difícil | Razona cómo funciona la naturaleza. | Work out how nature works. | Cadena alimentaria, hoja/fotosíntesis e intestino/nutrientes: ejemplos del banco Difícil. |


## Layout, accesibilidad y apariencia

- Referencia de composición: móvil de 390 × 844, como el mock. Cabecera compacta, tres tarjetas de aproximadamente 150–165 px a escala normal, separaciones de 12–16 px y márgenes laterales de 16 px. El texto ocupa aproximadamente 45–50 % de la tarjeta, la ilustración el resto. No convertir estos valores en alturas rígidas.
- A 390 × 844 y texto normal deben verse las tres elecciones y el acceso a la información sin desplazarse. A 320 × 568, horizontal o texto ampliado se permite desplazamiento normal: jamás reducir tipografía para forzar todo en pantalla ni cortar Difícil.
- Nombres de nivel de 20–24 px; frase de al menos 16 px. Objetivo editorial de 3–9 palabras por frase ES, hasta dos líneas en tamaño normal; en accesibilidad se amplía la tarjeta. EN debe poder crecer sin elipsis.
- Comenzar con una columna también en tablet, con ancho máximo legible. No añadir una rejilla diferente antes de validar la composición común.
- Un único nodo de botón por tarjeta: «Medio. [Frase]. [Nivel superado, si corresponde]». Flecha, ilustración y check decorativo excluidos para evitar anuncios repetidos. Sin anuncios automáticos de las tres escenas.
- Recorrido de foco: atrás, las tres tarjetas, información secundaria. Soportar Enter/Espacio y lector de pantalla. Al abrir la hoja, el foco entra en su título y vuelve al enlace al cerrar. El título general es encabezado semántico.
- Usar [`tema.dart`](../lib/ui/tema.dart) y `context.coloresNaturales` para superficies, texto, bordes y foco en claro/oscuro/sistema. Conservar los colores científicos de las ilustraciones. Comprobar contraste de texto, botón y foco en ambos temas; no copiar colores claros fijos del bitmap.
- Mostrar el estado superado con forma y etiqueta, no solo borde verde. Todos los niveles mantienen área táctil de al menos 48 px y acceso aun con cero estrellas/cromos.
- Ninguna animación de racha o semillas en la cabecera del selector. El estado de completado se actualiza al regresar sin otra celebración.

## Secuencia de implementación

Cada fase termina con una comprobación concreta. La migración es gradual por familia, sin cambiar a la vez las reglas de los juegos.

| Fase | Trabajo y dependencias | Condición para avanzar |
| --- | --- | --- |
| 0. Preparar la rama | Partir de `main` actualizado en `david/selectores-visuales` después de comprobar el estado de la integración del feedback. Revisar este inventario contra el catálogo y registrar referencias visuales del selector actual. | Árbol limpio, base definida, 26 actividades y reto diario identificados. |
| 1. Cerrar contenido y recursos | Revisar las 81 frases/escenas, traducciones y piezas disponibles. Validar especialmente cambios de mecánica, cuerpo humano y flechas científicas. Crear registro tipado con cobertura exacta. | Cada pareja tiene frase, receta y fuente; no quedan escenas genéricas «por hacer». |
| 2. Construir la base | Tarjeta, selector, hoja de información y composición estática. Integrar como piloto `hogar`, `herbario` y `digestion` para probar clasificación, montaje y secuencia. | Pilotos correctos en ES/EN, claro/oscuro, texto ampliado y movimiento reducido. Se puede entrar y volver por todos sus niveles. |
| 3. Migrar JuegoPage | Aplicar el adaptador a las 19 actividades. Revisar individualmente las diferencias recogidas en las tablas, incluidos germinación y vida. | Los 57 niveles tienen su escena y frase correctas; la hoja muestra cursos/cromos reales. |
| 4. Migrar pantallas propias | Completar nacimiento, ecosistemas, rescate y JuegoPropio; consolidar los pilotos de herbario/digestión. | Las 26 actividades usan el mismo selector y conservan sus recorridos. Ninguna copia antigua de tarjeta queda activa. |
| 5. Adaptar reto diario | Migrar sus tres elecciones y la hoja, preservando el inicio por dificultad y los estados diario completado/guardado pendiente. | No se puede repetir ni cambiar de nivel después de completar; los reintentos no duplican bonos. |
| 6. Verificar y documentar | Pruebas, goldens deliberados, revisión manual de los 27 selectores y sus 81 entradas. Actualizar [organización](organizacion.md), decisiones y este plan con la implementación real. | Sin errores de layout ni regresiones de cierre; revisión visual y técnica del equipo. |

Orden dentro de la fase 3: `hogar` → `plantas`, `piezas` → resto de clasificaciones sencillas → escenas científicas (`dieta`, `grupos`, `polinizacion`, `estaciones`, `huerta`, `respiracion`, `savia`) → `germinacion`, `vida`. Cada actividad se marca terminada únicamente cuando sus tres niveles están adaptados. La fase 4 no deja memoria o adivinanzas fuera por compartir `JuegoPropio`.

Trabajar en commits revisables: base y pilotos; catálogo y escenas por zona; adaptadores de pantallas propias; reto diario; pruebas/documentación. No abrir una PR por cada nivel. Antes de fusionar, retirar los selectores antiguos y los imports/helpers que ya no se utilicen, sin modificar modelos de guardado ni reducir la cobertura existente.

## Verificación de la implementación

### Pruebas automatizadas previstas

Los nombres de archivos nuevos de esta sección son propuestas.

1. `test/ui/presentacion_niveles_test.dart`: construir el inventario desde el catálogo real, incluidos los niveles anidados y los bancos diarios. Exigir exactamente una presentación para cada pareja, sin duplicados, ids desconocidos, recetas vacías ni texto sin traducción. Comprobar 78 entradas de catálogo + 3 diarias. No conformarse con contar 81 si falta un juego y sobra otro.
2. `test/ui/selector_nivel_test.dart`: pulsación simple/doble, toda la tarjeta accionable, atrás, hoja informativa sin iniciar partidas, restauración del foco y desplazamiento, superado accesible, cero progreso y títulos largos. Probar los tres niveles del adaptador de cada una de las ocho entradas; para las 26 actividades comprobar además la correspondencia entre id pulsado y partida abierta.
3. Traducciones: ampliar [`test/datos/traducciones_test.dart`](../test/datos/traducciones_test.dart) y [`test/datos/idioma_test.dart`](../test/datos/idioma_test.dart) según su responsabilidad, para que también incluyan los textos del registro visual y de la hoja, que no proceden todos del JSON del catálogo. Recorrer el cambio ES/EN con la hoja abierta.
4. Apariencia/layout: adaptar [`test/ui/apariencia_test.dart`](../test/ui/apariencia_test.dart). Crear referencias del selector de hábitats y de una escena de planta/cuerpo en ambos temas; añadir el diario. Revisar cada cambio antes de actualizar `selector-oscuro.png`; no regenerar todos los goldens para ocultar diferencias no relacionadas.
5. Mantener y adaptar [`test/ui/cierres_juegos_test.dart`](../test/ui/cierres_juegos_test.dart): entrada desde cada selector y nivel, preguntas finales, cierre automático, repetir, cambiar y volver. La hoja no debe evaluar respuestas ni afectar el guardado. Mantener fallos de persistencia, salida durante feedback y doble toque.
6. Diario: probar selector disponible sin completar; cambio antes de terminar según comportamiento actual; completar en cada dificultad; resultado al reabrir; guardado lento/fallido/pendiente; cambio de fecha y vuelta del armario. Exigir una sola recompensa.
7. Matriz de layout del componente: 320 × 568, 390 × 844, 844 × 390 y tablet; texto 1,0/1,5/2,0; ES/EN; claro/oscuro; movimiento reducido. Usar casos representativos de frase larga y escena ancha para la matriz exhaustiva; recorrer las 81 presentaciones a tamaño normal y ampliar cualquier caso que falle. Afirmar ausencia de overflow y acceso real al último nivel/enlace, no solo que el widget existe fuera de pantalla.

Comprobaciones finales indicadas por el repositorio:

```bash
dart analyze --fatal-infos
flutter test test/ui/feedback_acierto_test.dart test/ui/fin_juego_test.dart test/ui/cierres_juegos_test.dart
flutter test
flutter build web
```

No se prevén cambios nativos; si aparecen, aplicar también la compilación de plataforma exigida por [la guía](feedback-y-cierre.md). Las pruebas locales no sustituyen la revisión visual ni el lector de pantalla en un dispositivo.

### Revisión manual y aceptación

- Revisar los 27 selectores con una lista de 81 entradas; confirmar que cada escena coincide con la tarea real, sin «imagen de reserva» genérica.
- Ver cada selector con progreso vacío, parcial y completo. Abrir «Sobre los niveles», comprobar cursos, descripciones y cromos correctos, cerrar y empezar cualquier nivel.
- Confirmar que el cambio desde el cierre vuelve al selector correcto y actualiza el check. Volver al mundo, reabrir y repetir un nivel completado.
- Validar en Android/iOS la legibilidad, el desplazamiento y TalkBack/VoiceOver, incluidos el foco y la hoja secundaria. Conservar los ajustes de sonido/vibración; elegir nivel no debe celebrar un acierto.
- Comparar capturas antes/después del mismo juego, idioma, tamaño y progreso. Elegir al menos un ejemplo de cada familia de selector y las excepciones de mecánica.
- Diego revisa las pantallas según [contribución](../CONTRIBUTING.md). La revisión de textos/ilustraciones científicos se hace con el responsable de contenido. La reproducción requiere la validación del colegio ya establecida.
- Hacer una prueba breve con niños de distintos cursos: pedir que elijan una actividad y expliquen qué creen que harán. Observar necesidad de leer los detalles, intentos de tocar solo la flecha e interpretación de niveles completados. No afirmar una mejora medida antes de realizarla.

El trabajo se considera terminado cuando hay cobertura real de las 81 presentaciones, las tres dificultades siguen accesibles, no se pierde información secundaria, los recorridos/guardados permanecen correctos y la revisión visual valida el resultado. Si falta una ilustración o un caso del diario, queda marcado pendiente; no se da por cubierto por compartir componente.

## Riesgos y resolución prevista

| Riesgo | Respuesta |
| --- | --- |
| El dibujo sugiere la misma tarea en los tres niveles aunque cambie la mecánica. | Seguir las tablas y revisar el nivel real. Especial atención a nacimiento, rescate, vida, dieta, grupos y polinización. |
| La escena solo adorna y no explica. | Mostrar objeto + relación/acción, sin miniaturas de texto. Validar qué entiende el niño antes de entrar. |
| El registro visual se queda desfasado respecto al catálogo. | Prueba de conjuntos exactos por actividad/nivel y revisión del contenido al cambiar un nivel. |
| «Todos abiertos» se interpreta como repetición diaria ilimitada. | Texto diario explícito y mostrar selector solo cuando el estado diario lo permite. |
| Ocultar cursos/cromos elimina información útil. | Una única hoja accesible obtiene datos vigentes; el estado superado sigue visible de forma discreta. |
| Tres tarjetas ilustradas no caben con texto ampliado. | Altura flexible y scroll accesible; no recortar ni reducir letra. |
| Se mezclan el cambio visual y las reglas de juego. | Adaptadores finos con callbacks originales y regresión de los cierres/persistencia. |
| Las imágenes nuevas aumentan peso o consumo. | Escenas estáticas con dibujos locales reutilizables, sin timers ni controladores de ejercicio. Medir el build si se añaden bitmaps. |

## Estado del plan

- [x] Inventario del catálogo real y sus ocho puntos de integración.
- [x] Frases ES/EN y escenas propuestas para los 81 niveles.
- [x] Flujo, información secundaria, accesibilidad, movimiento y validación definidos.
- [ ] Revisar recursos disponibles y producir las variantes que falten.
- [ ] Implementar componentes y pilotos.
- [ ] Migrar las 26 actividades y el reto diario.
- [ ] Ejecutar pruebas y revisión manual; registrar resultados reales.
