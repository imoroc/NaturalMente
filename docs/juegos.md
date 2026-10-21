# Juegos

Banco de ideas de minijuegos y actividades para todo el proyecto. No es una lista de cosas que haya que hacer todas: de aquí se eligen las que entran, y en qué orden lo marca la prioridad.

Las reglas de alcance están en `docs/decisiones.md`. Los temas que cada juego tiene que cubrir están en `content/cobertura.md`. Si un juego de aquí choca con alguno de esos dos archivos, mandan ellos.

## Cómo leer cada ficha

- **Prioridad**: **Obligatorio** (tiene que estar en diciembre, ya lo dice `docs/contexto.md`), **MVP** (entra con el MVP, por orden), **Extra** (tema del MVP, pero solo si sobra tiempo) o **Ampliación** (fuera del MVP, ver `docs/decisiones.md`).
- **Mecánica**: qué hace el niño con el dedo.
- **Niveles**: qué cambia entre Fácil, Medio y Difícil. Si no se dice nada, el nivel solo cambia las preguntas.
- **Si no acierta**: quién habla y qué tipo de frase dice. Nunca «error», «incorrecto», «has fallado» ni «mal hecho». La frase explica qué pasa y la segunda vez da una pista sin regalar la respuesta.

## Reglas para todos los juegos

1. Antes de empezar se elige nivel: Fácil, Medio o Difícil. Se recuerda el último que eligió el niño.
2. Ningún juego castiga con vidas ni quitando lo ganado. Como mucho, un medidor de tiempo en Difícil, y siempre se puede apagar.
3. Botones grandes, poco texto en Fácil, y un botón de altavoz que lee el enunciado en voz alta.
4. Cada pregunta o reto del catálogo lleva su `nivel` y su `bloque`. Un mismo juego vale para los tres niveles filtrando.
5. Las mecánicas se repiten a propósito: arrastrar a un sitio, ordenar, elegir entre opciones y mover controles. Así una sola pantalla sirve para varios juegos, como ya hace `lib/ui/juego.dart`.
6. Fotos, dibujos y sonidos son nuestros o tienen una licencia que permita publicarlos en una tienda, y cada uno se apunta en `content/licencias.md`. Nada del libro del colegio.

## La reserva (animales)

### Cada uno a su hogar
- **Prioridad**: Obligatorio.
- **Mecánica**: arrastrar el animal a su hábitat.
- **Niveles**: Fácil, cuatro hábitats muy distintos (desierto, mar, polo, bosque) y animales muy claros. Medio, se añaden selva, río y sabana. Difícil, animales que despistan (oso polar y oso pardo, foca y delfín) y varios a la vez.
- **Si no acierta**: habla el animal. «¡Aquí paso mucho frío!». A la segunda, pista sobre el sitio: «Busco un sitio seco y con poca agua».

### Enciclopedia de cartas
- **Prioridad**: MVP.
- **Mecánica**: álbum de cartas coleccionables, una por animal, agrupadas en mamíferos, aves, reptiles, anfibios, peces e invertebrados. Empiezan como silueta y se desbloquean al jugar con ese animal en cualquier juego. Al tocar una carta, se gira.
- **Qué trae la carta**: dibujo, hábitat, icono de alimentación (carnívoro, herbívoro u omnívoro), una frase, una curiosidad y un botón grande de sonido.
- **Niveles**: no tiene selector. La carta enseña más líneas según el último nivel jugado (en Difícil sale también si es vertebrado y cómo nace).
- **Por qué**: da sentido a jugar varias veces y hace de fichas de la zona sin una pantalla de lectura.

### Radar sonoro
- **Prioridad**: Extra.
- **Mecánica**: suena un animal y hay que elegir quién es entre varias opciones con dibujo.
- **Niveles**: Fácil, 3 opciones y sin tiempo. Medio, 4 opciones. Difícil, 4 opciones parecidas (búho y lechuza, rana y sapo) y una barra de tiempo que se puede apagar.
- **Si no acierta**: suena el animal que ha elegido, para comparar. «Así suena el lobo. Escucha otra vez».
- **Ojo**: depende de conseguir sonidos con licencia. Si no los hay, se queda fuera.

### Clasificar
- **Prioridad**: MVP.
- **Mecánica**: arrastrar animales a cajas.
- **Niveles**: Fácil, «¿vuela, nada o anda?». Medio, mamífero, ave, pez, reptil o anfibio. Difícil, vertebrado o invertebrado, y dentro de los invertebrados, insecto, arácnido o molusco.
- **Si no acierta**: la caja explica qué tienen los suyos. «En esta caja todos tienen plumas. ¿Tiene plumas el murciélago?».

### Qué come cada uno
- **Prioridad**: MVP.
- **Mecánica**: Fácil y Medio, dar de comer al animal eligiendo entre tres platos. Difícil, ordenar una cadena de comida (planta, herbívoro, carnívoro).
- **Si no acierta**: el animal rechaza la comida con una razón. «Yo no como carne. Mis dientes son para masticar hierba».

### Así se mueve
- **Prioridad**: Extra.
- **Mecánica**: unir cada animal con su forma de moverse (vuela, nada, repta, salta, anda). En Difícil, unir la parte del cuerpo con el movimiento (aletas, alas, patas palmeadas).
- **Si no acierta**: una animación corta del animal intentándolo. «La serpiente no tiene patas para saltar. Mira cómo se mueve».

### ¿Huevo o barriga?
- **Prioridad**: MVP.
- **Estado**: implementado (`nacimiento`) con los tres niveles, toque o arrastre, cromos por nivel (Huevo o barriga, Renacuajo y Mariposa) y textos en español e inglés. Modelo en `lib/modelo/nacimiento.dart`, reglas sin widgets en `lib/reglas/nacimiento.dart`, pantalla en `lib/ui/nacimiento.dart` y dibujos propios en `lib/ui/dibujos_nacimiento.dart`. No cuenta para la medalla.
- **Mecánica**: Fácil, separar los animales que nacen de un huevo de los que nacen de la madre. Medio y Difícil, ordenar un ciclo de vida (rana: huevo, renacuajo, rana pequeña, adulta; mariposa: huevo, oruga, crisálida, mariposa).
- **Niveles**: Fácil, seis animales de la reserva (pingüino, tucán y rana; camello, delfín y oso) en dos destinos. Medio, los ciclos de la rana y la mariposa en cuatro pasos y una pregunta de comprensión por ciclo. Difícil, la rana en cinco fases (puesta, renacuajo, patas, ranita y adulta) y la mariposa con larva, pupa y adulto, y una pregunta de razonamiento por ciclo (anfibio, en qué se parecen).
- **Si no acierta**: «Antes de tener patas, la rana vive en el agua como un pez». En Fácil explica por qué ese animal no nace así y a la segunda da una pista; en los ciclos, la frase habla del primer paso que no encaja, el hueco se marca en naranja y a la segunda se añade la pista del ciclo.

### Picos y patas
- **Prioridad**: Extra.
- **Mecánica**: cada ave tiene un pico o unas patas, y hay que llevarla a la comida o al sitio que le encaja (pico fuerte para semillas, largo para el néctar, ganchudo para la carne; patas palmeadas para nadar).
- **Niveles**: Fácil, solo picos y 3 aves. Difícil, picos y patas, y por qué.
- **Por qué**: sale de una idea de taller del material del colegio, con dibujos y frases nuestras.

### Cuida la reserva
- **Prioridad**: Extra.
- **Mecánica**: una escena con basura, plásticos y animales en apuros. Se toca lo que hace daño y se elige qué hacer (recoger, reciclar, no tocar el nido).
- **Niveles**: Fácil, solo recoger. Medio y Difícil, decidir entre dos acciones y ver qué pasa.
- **Si no acierta**: «Si nos llevamos los huevos, el pájaro no tendrá crías».

## El invernadero (plantas)

### Laboratorio de germinación
- **Prioridad**: Obligatorio.
- **Mecánica**: controles de agua, luz y suelo, y un botón de avanzar el tiempo. La judía brota o no.
- **Niveles**: Fácil, solo agua y luz, con dos opciones cada uno. Medio, los tres controles con tres opciones (lo que hay ahora). Difícil, se añade la temperatura y hay que llegar a la flor, no solo al brote.
- **Si no acierta**: habla la planta. «Tengo tanta agua que no puedo respirar». La segunda vez, la pista dice qué control mirar.

### Herbario desmontable
- **Prioridad**: MVP.
- **Estado**: implementado con los tres niveles, arrastre y alternativa mediante toques. Las partes colocadas permiten consultar función y curiosidad; en Difícil se desbloquean al acertar su función. El progreso se guarda por nivel y no cuenta para la medalla. Ver `docs/plan-herbario.md` para validación y pendientes.
- **Mecánica**: arrastrar las partes (raíz, tallo, hoja, flor, fruto) o sus rótulos sobre la silueta de una planta. Al acertar, se toca la parte y sale su ficha con una curiosidad: «La raíz toma el agua del suelo, como una pajita».
- **Niveles**: Fácil, tres partes con dibujo. Medio, las cinco partes. Difícil, rótulos sin dibujo y una pregunta de para qué sirve cada parte.
- **Si no acierta**: la parte explica dónde está. «Yo estoy bajo tierra, no en lo alto del tallo».

### Árbol, arbusto o hierba
- **Prioridad**: MVP.
- **Mecánica**: llegan plantas del entorno (encina, romero, césped, amapola, chopo) y se colocan en su grupo.
- **Niveles**: Fácil, árbol o hierba. Medio, árbol, arbusto o hierba. Difícil, además, cultivada o silvestre.
- **Si no acierta**: «El romero tiene muchos tallos leñosos desde abajo. Un árbol tiene un solo tronco».

### De semilla a semilla
- **Prioridad**: MVP.
- **Mecánica**: ordenar el ciclo de una planta (semilla, brote, planta, flor, fruto con semillas).
- **Niveles**: Fácil, 3 pasos. Medio, 5 pasos. Difícil, se añade quién lleva el polen (abeja o viento).
- **Si no acierta**: «Antes del fruto tiene que haber una flor».

### Mi huerto
- **Prioridad**: Extra.
- **Mecánica**: plantar semillas, regar y esperar varias rondas. Cada planta dice qué necesita. Al final se cosecha.
- **Niveles**: Fácil, una planta y riego. Medio, varias plantas con necesidades distintas. Difícil, elegir qué plantar según la estación.
- **Por qué**: une el huerto de 2º y 3º con la germinación y reutiliza su regla.

### Hoja a hoja
- **Prioridad**: Extra.
- **Mecánica**: Fácil, memoria de parejas de hojas. Difícil, unir cada hoja con su árbol.

### La planta a oscuras
- **Prioridad**: Extra.
- **Mecánica**: dos macetas, una con luz y otra en un armario. Se avanza el tiempo y se comparan.
- **Niveles**: Fácil, mirar qué pasa. Difícil, predecirlo antes y explicar que la hoja fabrica alimento con la luz.

## Seres vivos y ecosistemas

«Monta el ecosistema» se integra en La reserva. La ubicación de futuros juegos de este bloque se decidirá por actividad (ver `docs/decisiones.md`).

### ¿Vivo o no vivo?
- **Prioridad**: MVP.
- **Mecánica**: separar lo vivo de lo que no lo está (piedra, seta, árbol, agua, gato, nube).
- **Niveles**: Fácil, ejemplos claros. Medio, casos que despistan (semilla, seta, fuego). Difícil, colocar los seres vivos en su reino: animales, plantas, hongos y seres muy pequeños.
- **Si no acierta**: «El fuego se mueve y crece, pero no nace ni se alimenta. ¿Está vivo?».

### Monta el ecosistema
- **Prioridad**: MVP.
- **Estado**: implementado en La reserva; plan, validación y pendientes en `docs/plan-ecosistemas.md`.
- **Mecánica**: llenar un claro del bosque con hierba, conejo y zorro, mediante arrastre o toques. Una acción cada vez, explicada por Natu.
- **Niveles**: Fácil, tres colocaciones; Medio, además dos relaciones de alimento; Difícil, además predecir qué cambia cuando hay menos hierba o menos conejos y comparar un ejemplo antes/después. Las flechas van del alimento a quien lo consume.
- **Si no acierta**: observación contextual; en el segundo intento, pista y ayuda visual. Sin vidas ni tiempo límite.
- **Progreso**: una estrella por nivel y el cromo «Un bosque conectado» al completar cualquiera. La medalla conserva sus requisitos.
- **Presentación**: ilustraciones vectoriales propias, controles compartidos, animaciones breves y alternativa con movimiento reducido. Español e inglés, sin conexión.

### Cadena de comida
- **Prioridad**: Extra.
- **Mecánica**: unir con flechas quién se come a quién.
- **Niveles**: Medio, cadenas de tres. Difícil, una red pequeña con varias flechas.

### Detective de biodiversidad
- **Prioridad**: Extra.
- **Mecánica**: una escena del entorno con seres vivos escondidos. Se buscan con una lupa y se apuntan en un cuaderno.
- **Niveles**: Fácil, pocos y grandes. Difícil, pequeños y camuflados (insectos, líquenes).
- **Por qué**: buscar engancha a los pequeños, y desbloquea cartas de la enciclopedia.

### ¿Qué pasa si...?
- **Prioridad**: Extra.
- **Mecánica**: tarjetas con una acción de las personas (talar, plantar, ensuciar el río, poner un nido) que hay que separar en si ayuda o daña.
- **Niveles**: en Difícil, además, elegir la consecuencia entre varias.

## Dentro de mí (cuerpo humano)

### Cada pieza en su sitio
- **Prioridad**: Obligatorio.
- **Mecánica**: arrastrar órganos a su sitio en una silueta.
- **Niveles**: Fácil, partes grandes del cuerpo y órganos de los sentidos (ojo, oído, nariz, lengua, piel). Medio, corazón, pulmones, estómago e intestinos. Difícil, cerebro, hígado y riñones, y a qué aparato pertenece cada uno.
- **Si no acierta**: habla el órgano. «Si me quedo en la barriga, ¿quién empuja la sangre desde el pecho?».

### Así empieza una vida
- **Prioridad**: Obligatorio.
- **Mecánica**: ordenar cuatro pasos, con la ficha de que el cuerpo de cada persona es suyo.
- **Niveles**: va etiquetado como Difícil, pero se abre desde cualquier nivel y su contenido no cambia. Los límites están en `docs/contexto.md`.

### El viaje de la comida
- **Prioridad**: MVP.
- **Estado**: implementado (`digestion`, tipo `viaje`) con los tres niveles, cromos por nivel (Dientes, Aparato digestivo y Nutrientes) y textos en español e inglés. Modelo en `lib/modelo/digestion.dart`, reglas sin widgets en `lib/reglas/digestion.dart`, pantalla en `lib/ui/digestion.dart` y dibujo propio del cuerpo en `lib/ui/dibujos_digestion.dart`. No cuenta para la medalla.
- **Mecánica**: llevar un bocado por el aparato digestivo, en orden (boca, esófago, estómago, intestino). Se toca la parada en el dibujo o en su botón, o se arrastra la manzana. Las partes ya recorridas se iluminan y el bocado cambia: entero, masticado, papilla y nutrientes.
- **Niveles**: Fácil, solo boca y barriga, con el pulmón como despiste y tres mordiscos para masticar antes de tragar. Medio, los cuatro pasos con pulmones y corazón como despistes, masticar y una pregunta final de para qué sirve el viaje. Difícil, cinco partes (intestino delgado y grueso por separado) y una pregunta de qué pasa en cada parada (bolo, movimientos del esófago, quimo, absorción y heces) antes de seguir.
- **Si no acierta**: el bocado se atasca y dice «Todavía no me han masticado». Si se salta una parada explica cuál falta, si va a un despiste dice para qué sirve ese órgano, y a la segunda añade la pista de la parada.

### Los cinco sentidos
- **Prioridad**: MVP.
- **Estado**: implementado (`sentidos`) en Dentro de mí con el motor de «Cada uno a su hogar» (tipo `lugar`). Fácil une ojos, orejas, nariz, lengua y piel con su sentido; Medio, seis situaciones de aviso; Difícil, cinco avisos con una pregunta sobre nervios, cerebro, receptores y actos reflejos. Dibujos en `lib/ui/dibujos_sentidos.dart`. Cromos por nivel: Los cinco sentidos, Los sentidos nos avisan y Acto reflejo. No cuenta para la medalla.
- **Mecánica**: Fácil, unir el órgano con su sentido. Medio, situaciones («huele a quemado», «el agua está fría») en las que hay que elegir qué sentido avisa. Difícil, por qué el aviso llega al cerebro y qué es un reflejo.
- **Si no acierta**: «Con los ojos cerrados también sabrías que el agua está fría. ¿Qué parte de ti lo nota?».

### Un plato que cuida
- **Prioridad**: MVP.
- **Mecánica**: montar un plato o una merienda arrastrando alimentos. El plato reacciona según lo equilibrado que esté.
- **Niveles**: Fácil, elegir entre dos meriendas. Medio, llenar el plato por partes (verdura, proteína, cereal). Difícil, leer una etiqueta inventada y comparar dos productos.
- **Si no acierta**: «Este plato da mucha energía, pero no tiene verdura. ¿Qué le falta?».

### Un día sano
- **Prioridad**: MVP.
- **Mecánica**: ordenar el día de un personaje (dormir, desayunar, lavarse los dientes, jugar, comer) y elegir entre dos opciones en cada momento.
- **Niveles**: Fácil, higiene y comida. Medio, también descanso y ejercicio. Difícil, hábitos que cuidan el cuerpo a largo plazo.
- **Por qué**: cubre la higiene, el descanso y el movimiento de 1º y 4º con una sola mecánica.

### Arma el esqueleto
- **Prioridad**: Extra.
- **Mecánica**: puzzle de huesos sobre una silueta. Después, tocar un músculo y ver qué mueve.
- **Niveles**: Fácil, cráneo, costillas, brazos y piernas. Difícil, nombres de huesos grandes y qué articulación se dobla.

### ¿Cómo me siento?
- **Prioridad**: Extra.
- **Mecánica**: el personaje vive una situación y hay que elegir la cara que le encaja. Luego, qué le ayudaría.
- **Niveles**: Fácil, alegría, tristeza, enfado y miedo. Difícil, emociones más finas y cómo ayudar a un compañero.
- **Ojo**: algunas situaciones no tienen una sola respuesta. Ahí vale cualquier respuesta con sentido y el juego solo comenta.

### Corazón en marcha
- **Prioridad**: Extra.
- **Mecánica**: elegir qué hace el personaje (dormir, andar, correr) y ver cómo cambian el latido y la respiración. Se puede seguir el ritmo tocando la pantalla.
- **Niveles**: Medio y Difícil.

### Zoom: de la célula al cuerpo
- **Prioridad**: Extra.
- **Mecánica**: pellizcando la pantalla se pasa de célula a tejido, órgano, aparato y cuerpo. Después, ordenar esos niveles.
- **Niveles**: solo Difícil.

## Juegos generales

Mezclan bloques. Pueden tener nivel fijo o el mismo selector.

### ¿Quién soy?
- **Prioridad**: MVP.
- **Mecánica**: salen pistas una a una («Tengo plumas», «No vuelo», «Vivo donde hace mucho frío») y hay que acertar con las menos posibles. Animales, plantas u órganos.
- **Niveles**: Fácil, 3 opciones con dibujo. Difícil, elegir de una lista larga.

### Repaso relámpago
- **Prioridad**: MVP.
- **Mecánica**: tanda de 10 preguntas de todos los bloques, con dibujo. Al final, lo que se ha aprendido.
- **Niveles**: según el selector. En Difícil, barra de tiempo opcional.
- **Por qué**: reutiliza todas las preguntas del catálogo y sirve para enseñar la app en una presentación.

### Memoria
- **Prioridad**: Extra.
- **Mecánica**: parejas de cartas: animal y hábitat, órgano y función, planta y parte.
- **Niveles**: Fácil, 6 cartas. Difícil, 16.

### Verdadero o falso
- **Prioridad**: Extra.
- **Mecánica**: una frase y dos botones grandes. Al contestar sale la explicación.

### Expedición del día
- **Prioridad**: Extra.
- **Mecánica**: cada día propone tres retos cortos de zonas distintas. Se eligen con la fecha del teléfono, sin conexión.
- **Por qué**: da un motivo para volver sin cuentas ni servidor.

## Medalla y progreso

- La medalla Explorador NaturalMente sigue como dice `docs/contexto.md`: hábitat, germinación y piezas del cuerpo.
- Cada zona podría tener una insignia al completar sus juegos MVP en cualquier nivel.
- La enciclopedia de cartas es el progreso que se ve: cuántas cartas hay desbloqueadas.
- Todo se guarda en el teléfono, sin cuentas.

## Ampliación (fuera del MVP)

Solo si el MVP está terminado (ver `docs/decisiones.md`):

- **Flota o se hunde**: predecir si un objeto flota y comprobarlo. Materia.
- **¿De qué está hecho?**: llevar cada objeto a su material y elegir una de las 5R. Materia.
- **Detective de la energía**: encontrar en una casa lo que gasta energía sin necesidad y apagarlo. Energía.
- **Máquinas simples**: usar una palanca o una polea para levantar una caja con menos fuerza. Fuerzas y máquinas.
- **Imanes**: pasar un imán por la escena y ver qué se pega. Fuerzas.

## Descartado

**Observatorio espacial** (planetario, dial de día y noche, fases de la Luna, quiz de la Tierra y el universo). Se pensó al principio, pero no entra: la Tierra y el universo no tienen bloque propio porque el material del colegio no lo trabaja (decisión del 8 de octubre en `docs/decisiones.md`). Si un día se cambia esa decisión, las ideas están aquí.

## Orden propuesto

1. Los cuatro obligatorios.
2. La enciclopedia de cartas, porque los demás juegos la alimentan.
3. Un juego MVP por zona que reutilice las pantallas que ya hay: Clasificar y Herbario (arrastrar), ¿Vivo o no vivo? (arrastrar), El viaje de la comida (ordenar).
4. Los generales ¿Quién soy? y Repaso relámpago.
5. El resto de MVP y después los Extra, según el tiempo que quede antes del 27 de noviembre.
