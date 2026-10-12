# Contexto

Esto lo escribimos para no tener que contarnos el proyecto cada vez que alguien se pone. Con este archivo y con `docs/organizacion.md` te pones al día.

Los PDF y los Word del profesor no están en el repositorio. Aquí está resumido con nuestras palabras lo que hace falta para trabajar.

## Qué estamos haciendo

NaturalMente es la práctica de Sistemas Móviles. Es una app para niños de primaria, en español, sobre animales, plantas y el cuerpo humano.

Se publica en Google Play y en la App Store en diciembre de 2026. Una sola base de código, en Flutter. No hay servidor ni registro. Si el niño se equivoca, el juego le explica qué pasa. No le pone un cartel de error.

El curso (1º-2º, 3º-4º, 5º-6º) se dice antes de cada actividad, como orientación. No cierra nada: se puede abrir todo.

## Cómo llegamos aquí

El trabajo usa Flutter. El cuerpo humano es un bloque grande, al mismo nivel que animales y plantas. Materia, energía y fuerzas salen en el libro, pero en la app solo como una frase suelta dentro de otro juego, y solo si nos da tiempo. La reproducción sí entra, porque es parte del cuerpo. La entrega es en diciembre.

El producto no está cerrado al milímetro. Lo que hay escrito aquí es lo que vamos a construir.

## La asignatura

Sistemas Móviles, 4º de Ingeniería Informática. Tres bloques de diapositivas en la carpeta SMOV.

### Tema 1. Introducción

`Tema 1 - Introduccion.pdf`, 104 diapositivas.

Repasa qué es un dispositivo móvil (desde los antiguos handheld y PDA hasta el móvil, la tablet y los relojes) y en qué se diferencia de un ordenador: pantalla táctil, batería, sensores, conexión inestable.

Luego compara Android e iOS: cuota, dinero que mueve cada tienda, seguridad, fragmentación de Android, y que programar dos veces (Java o Kotlin, y Swift) sale caro. De ahí sale la idea de un framework que sirva para las dos.

También entra el marco legal, sobre todo en Europa, y los modelos de negocio: de pago, freemium, suscripción, anuncios, compras dentro de la app, afiliación. Para la nuestra no usamos ninguno de pago. Es gratis, sin anuncios y sin cuentas, porque va dirigida a niños. Eso hay que decirlo claro en la ficha de la tienda.

El final del tema es el camino de una app: pensarla, diseñar el negocio, diseñar pantallas, desarrollarla, y luego la tienda (textos, capturas, ficha, analítica, soporte). Nosotros nos saltamos el negocio de cobrar y la analítica que identifica usuarios. El resto del camino sí: pantallas, desarrollo y publicación.

En diseño, el tema recuerda que iOS se apoya en las guías de Apple y Android en Material. La nuestra es Material, que es lo que trae Flutter, con textos y botones grandes. En Android el atrás lo pone el sistema. En iOS hay que cuidar el gesto de volver.

### Tema 2. Flutter

`Tema 2- Framewrok de Flutter.pdf`, 65 diapositivas. 

Flutter pinta él mismo la interfaz, no usa los botones nativos de cada sistema. Por eso la misma pantalla vale en Android y en iOS. El motor de dibujo del que hablan las diapositivas nuevas es Impeller. El lenguaje es Dart. El ciclo rápido es el hot reload: cambias un texto o un color y se ve al momento. No recarga bien un cambio de `pubspec.yaml` ni pasar un widget de sin estado a con estado: ahí hace falta hot restart o parar y volver a lanzar.

Estructura que espera la asignatura, y la que usamos:

- La vista solo pinta y avisa de lo que han pulsado. No decide si el camello vive en el desierto.
- El viewmodel, cuando haga falta, guarda el estado de una pantalla. En la versión mínima todavía no hay uno separado: el estado está en la propia pantalla del juego, porque solo hay un juego. Cuando haya más, no se mete la lógica en `main.dart`.
- Las reglas de juego viven aparte, sin widgets, para poder probarlas solas.
- El catálogo es un archivo nuestro (`content/catalog.json`), no una API.
- El progreso de la medalla, cuando exista, se guarda en el teléfono.

`android/` e `ios/` no son otra app. Son el identificador, el icono, los permisos y la firma.

Comandos que salen en las diapositivas y que usamos de verdad:

- `flutter pub get` baja lo que pone `pubspec.yaml`.
- `flutter run` arranca. `r` recarga, `R` reinicia, `q` sale.
- `flutter test` lanza las pruebas.
- `flutter build apk` genera un APK para instalar a mano.
- `flutter build appbundle` es lo que se sube a Play. El APK no es el formato de la tienda.
- `flutter build ipa` genera la app de iOS. Hace falta un Mac con Xcode. En Windows no sale.
- `flutter build web` existe. Nosotros la web no la publicamos. Sirve para abrir la app en Chrome mientras programamos.

Para Play hay que firmar la versión release con una clave nuestra. La clave no se sube a git (está ignorada: `*.jks`, `android/key.properties`). El alta de la cuenta de Google se paga una vez. La de Apple, cada año, y a veces tardan días en activarla.

La revisión de la tienda puede tardar.

### Tema 3. Dart

`Tema 3 - Introduccion a Dart.pdf`, 100 diapositivas.

Lo que hay que tener fresco para no pelearse con el código:

- Null safety. Si algo puede no estar, es `String?` y se comprueba. No usar `dynamic` para ir rápido.
- Las listas se declaran y se recorren. En Flutter la lista de botones sale de un `for` dentro de los hijos del widget.
- Clases pequeñas, campos `final` si no cambian, constructores con nombre cuando haya varios modos de crear lo mismo.
- Los errores de una respuesta mal formada se lanzan en las reglas y los tests los cubren. En la pantalla, al niño no le enseñamos la excepción.
- La asincronía (`async` / `await`) hará falta para leer el catálogo del archivo. No hace falta isolates ni `compute` para este tamaño.
- El estilo es el de `flutter analyze`. Si el analizador se queja, se arregla antes de subir.

## El material de ciencias

Lo pasó el colegio a través del profesor. Es Ciencias de la Naturaleza de editorial SM, pensado para Castilla y León, de 1º a 6º. Cada unidad se llama situación de aprendizaje y dura entre 8 y 13 sesiones. Casi todas acaban en un reto (un mural, un experimento, una exposición). Esos retos nos dieron ideas de juego. No copiamos sus enunciados ni sus dibujos.

En la app el curso del libro no ata a nadie. La etiqueta que pongamos es la dificultad que nos parece a nosotros.

Hay dos tipos de archivo:

- Programación de aula (Word). Dice el curso en la portada. Son 1º y 2º.
- Guía del profesor (PDF). Trae objetivos, sesiones, talleres y el reto. En 3º, 5º y 6º la guía no escribe el curso en la portada. Lo hemos encajado por el título de las unidades y porque los códigos van en serie. En 4º sí aparece una frase dentro de «El bienestar»: habla de niños de 4º de primaria. Si alguien del colegio corrige un curso, se cambia la etiqueta y ya está.

### 1º. Programación, curso escrito en el archivo

Código `212116D`, cinco Word `pa_cyl`.

| Unidad | De qué va | Qué les piden al final en clase |
| --- | --- | --- |
| Cuido mi cuerpo | Partes del cuerpo, sentidos, emociones, higiene, que cada cuerpo es distinto | Un dibujo de sí mismo |
| Un menú de cuidado | De dónde salen los alimentos y qué es comer de una forma que cuide el cuerpo | Una lista de meriendas |
| ¿De qué están hechas las cosas? | Materiales, para qué sirven, mezclas, las 5R | Un objeto con material que iba a tirarse |
| Todos somos animales | Cómo son, cómo se mueven, cómo nacen, qué comen, cuidado | Ideas para usar menos plástico |
| Las plantas nos dan vida | Partes, qué necesitan, tamaños, que dan cobijo a otros seres vivos | Sembrar una semilla |

De aquí salen las actividades más sencillas: sentidos, plato, animales muy claros, partes de la planta.

### 2º. Programación, pone 2º EP

Código `214435D`. La unidad del cuerpo está en un `.doc` antiguo (`sa01`). El resto son `.docx`.

| Unidad | De qué va | Qué les piden al final en clase |
| --- | --- | --- |
| Mi cuerpo funciona | Nutrición, relación y, muy por encima, reproducción. Hábitos | Un plano de un patio donde se pueda jugar y estar bien |
| La materia que nos rodea | Masa, volumen, mezclas, máquinas del día a día | Algo hecho con material reutilizado |
| Un mundo de energía | Luz, sonido, no gastar energía de más, que las fuerzas mueven objetos | Carteles sobre el ruido del cole |
| Animales: una gran familia | Vertebrados e invertebrados. Mamíferos, aves, peces, reptiles, anfibios. Insectos | Una historia corta sobre cuidar insectos |
| Un entorno para cuidar | Plantas de huerto y silvestres, animales según dónde viven | El cuaderno de un huerto |

El juego de llevar cada animal a su sitio bebe de esta última y de la de 3º sobre hábitat. Las máquinas y la energía de 2º no tienen pantalla propia.

### 3º. Guías del profesor, código `212115D`

El curso no está escrito en el PDF. Los títulos coinciden con el índice que teníamos de 3º.

| Unidad | Sesiones | Reto de la guía | Qué se trabaja |
| --- | --- | --- | --- |
| Cómo son y dónde viven los seres vivos | 9 | Conviértete en biólogo: contar un ecosistema y cómo protegerlo | Reinos, ecosistemas, qué hace el ser humano, relieve y rocas |
| Cómo viven los animales | 10 | Conoce a los animales: un reportaje de animales de la zona | Comida, cómo se mueven, hábitat, cómo nacen, ciclo de vida. Hay un taller de picos de aves |
| Cómo viven las plantas | 10 | Protege las plantas: una guía para cuidar las de un espacio | Partes, luz, hojas, relación con el entorno, reproducción de la planta, ciclo |
| Cálida energía | 8 | Detectives en acción: mirar si el cole gasta energía con cabeza | Calor, cambios de estado, fuentes, ahorro |
| Un esfuerzo y una ayuda | 12 | Conoce la vida de las máquinas | Tipos de fuerza, imanes, para qué sirven las máquinas, inventos |

Relieve, rocas y el ejemplo de los polos de «Cálida energía» no pasan a la app. Del resto de seres vivos sí nos quedamos la idea: hábitat, ciclo, partes de la planta, luz.

### 4º. Guías, código `214570D`

En «El bienestar» la guía habla de niños de 4º. El resto de PDF van en la misma serie.

| Unidad | Sesiones | Reto de la guía | Qué se trabaja |
| --- | --- | --- | --- |
| Los ecosistemas | 10 | Un mural de un ecosistema | Tipos, seres vivos, biodiversidad, personas |
| El bienestar | 8 | Un cartel para animar a cuidarse | Comida, sueño, movimiento, emociones, relación con los demás |
| Rodeados de cambios | 9 | Dar otra vida a materiales | Propiedades, calor, mezclas, sustancias |
| Fuerzas y máquinas | 8 | Inventar una máquina y hacer la maqueta | Fuerzas, estructuras, máquinas simples y compuestas, seguridad, inventos |

A la app, de 4º, le importa sobre todo el bienestar: comida, descanso, emociones. Ecosistemas alimenta las fichas de animales y plantas. Fuerzas y materiales no son una zona. Como mucho, más adelante, una frase de que un brazo se mueve parecido a una palanca.

### 5º. Guías, código `212122D`

Tampoco imprimen el curso. El primer título es «Somos células», que encaja con 5º.

| Unidad | Sesiones | Reto de la guía | Qué se trabaja |
| --- | --- | --- | --- |
| Somos células | 13 | Montar un consultorio de hábitos | La célula, cómo se organiza un ser vivo, funciones vitales, emociones, comida, ejercicio |
| Los seres vivos | 11 | Un mural de la biodiversidad de alrededor | Clasificar, vertebrados, invertebrados, plantas, un huerto colgante |
| El hogar de los seres vivos | 10 | Unos documentales para cuidar el entorno | Qué es un ecosistema, tipos, qué hacemos las personas, relieve de España |
| La materia y la energía | 12 | Mirar ventajas e inconvenientes de la energía eléctrica | Masa, volumen, electricidad, fuentes, máquinas |

De aquí salen la célula, el paso de lo pequeño al cuerpo, y más fichas de seres vivos. El relieve de España no entra. Electricidad y máquinas tampoco, salvo la frase de la luz en el invernadero.

### 6º. Guías, código `214711D`

Los nombres de archivo van desordenados respecto al número de la unidad. No falta contenido: están las cinco. «Nos reproducimos» está en `bl01sa02` y dentro pone el número 3. «Nos alimentamos» está en `bl02sa04`.

| Unidad | Sesiones | Reto de la guía | Qué se trabaja |
| --- | --- | --- | --- |
| Seres vivos y ecosistemas | 9 | Un pódcast sobre cuidar la biodiversidad de la zona | Seres vivos y materia inerte, relaciones, biodiversidad, qué la amenaza |
| Nos relacionamos | 10 | Inventar un aparato que ayude a alguien con un sentido | Función de relación, sentidos, sistema nervioso, cuidados, relaciones |
| Nos reproducimos | 10 | Preparar una entrevista sobre el parto | Reproducción, aparatos, fecundación, embarazo, parto, respeto |
| Nos alimentamos | 11 | Un libro de recetas del grupo | Nutrientes, plato, etiquetas, alimentación y entorno |
| La materia y sus características | 10 | Un concurso de aparatos que vuelen | Propiedades, densidad, calor, flotar, forma y aire |

La unidad de reproducción es la que nos obliga a tener «Así empieza una vida». No copiamos la guía. En la app son cuatro pasos, con frases nuestras: se unen dos células muy pequeñas, el bebé crece en el útero, nace, y hay que cuidarlo. Al lado, una ficha de que el cuerpo de cada persona es suyo. Sin dibujos explícitos y sin explicar cómo se mantienen relaciones. Va etiquetada como 5º-6º y se puede abrir igual. Antes de mandar la build a las tiendas la leemos los cinco. En el formulario de edad de Google y de Apple se declara, no se esconde para que nos pongan una edad más baja.

La materia de 6º (volar, densidad) no entra.

### Lo que el libro trae y la app no convierte en zona

Queda dicho para que nadie lo rehaga dentro de dos meses: planeta, universo, Luna, Sol, estrellas, relieve, rocas, volcanes, terremotos, polos que se derriten como tema, electricidad, máquinas, fuerzas como bloque. La tierra de una maceta sí, porque es el suelo de la planta.

Si más adelante sobra tiempo, solo tres frases, y ninguna es obligatoria para la medalla:

- La luz es energía que la planta usa para fabricar su alimento.
- El agua es materia que la raíz toma del suelo.
- Un hueso y un músculo pueden mover el brazo de un modo parecido a una palanca.

## La app, en concreto

Al abrir se ve un mapa con tres sitios. El orden lo elige el niño.

| Sitio | Bloque | Quién habla si no encaja |
| --- | --- | --- |
| La reserva | Animales | El animal |
| El invernadero | Plantas | La planta |
| Dentro de mí | Cuerpo | El cuerpo |

En cada sitio habrá fichas (nombre, una frase, una curiosidad, curso orientativo) y juegos. Ahora mismo solo está el mapa y un juego, el del camello, para comprobar que el circuito funciona: pantalla, regla y test. El resto se añade en esas mismas carpetas.

Juegos que tienen que estar para diciembre:

1. Cada uno a su hogar. Llevar un animal a desierto, mar, polo o bosque. El camello en el polo dice que pasa mucho frío. A la segunda, la pista habla de un sitio seco y con poca agua, sin regalar la palabra desierto. También delfín, pingüino emperador y oso pardo. El pardo es de bosque. El del hielo es otro oso.
2. Laboratorio de germinación. Judía. Agua, luz y suelo, y avanzar el tiempo. Mucha agua la ahoga. Poca la seca. Piedras: no se agarra. Arena: el agua se va. Poca luz: se queda pálida. Agua justa, luz y tierra de huerto: brota.
3. Cada pieza en su sitio. Corazón, pulmones y estómago, o el camino de la comida, sin listar la solución. Para la etiqueta de 1º-2º: ojo, oído, piel y un plato que cuide. Para 5º-6º: célula y cerebro.
4. Así empieza una vida. Los cuatro pasos de arriba.

La medalla Explorador NaturalMente sale al superar el hábitat, la germinación y las piezas del cuerpo. Las fichas no cuentan. «Así empieza una vida» se entrega y se prueba siempre, pero no hace falta para la medalla.

Las frases de fallo no pueden contener: error, incorrecto, has fallado, mal hecho.

Dibujos: pocos colores, un personaje nuestro. Nada sacado del libro. Si usamos un icono de fuera, la licencia tiene que permitir publicarlo en una tienda, y se anota en `content/licencias.md` el día que se use. Ese archivo todavía no existe.

## Qué tiene que poder decir alguien que no ha abierto los PDF

- La app es de animales, plantas y cuerpo, para primaria, en español.
- El cuerpo incluye la reproducción, con cuatro pasos y sin detalles gráficos.
- Tierra y universo no se mencionan. El suelo de la planta sí.
- Materia, energía y fuerzas no son un mundo.
- Flutter, Android e iOS, sin servidor.
- Diciembre de 2026.
