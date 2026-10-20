# Plan del juego «Monta el ecosistema»

Fecha: 20 de octubre de 2026.  
Rama: `david/juego-ecosistemas`, creada desde `main` actualizado.  
Estado: implementado; validación automatizada y recorridos de navegador realizados. Pendientes: dispositivos físicos y prueba acompañada con niños.

## Objetivo

Crear un juego para niños de 6 a 12 años en el que un claro del bosque se va llenando de vida y permite descubrir la relación entre plantas y animales. La escena ilustrada es el centro de la experiencia. La interfaz, Natu y las recompensas pertenecen a la misma familia que los cinco juegos actuales.

El resultado debe invitar a observar, probar y comprender. No habrá vidas, cuenta atrás, pérdida de premios ni representaciones de animales sufriendo. El acabado de dibujos, interacciones y transiciones forma parte de la entrega, no de una mejora posterior.

## Alcance de la primera versión

- Una escena bien terminada: un claro del bosque, con hierba, conejo y zorro como elementos jugables. Árboles y vegetación de fondo contextualizan la escena sin parecer piezas pendientes.
- Tres niveles abiertos: Fácil, Medio y Difícil. Cada uno añade una forma de pensar sobre la misma escena.
- Acceso desde La reserva como nueva misión. Es la ubicación propuesta para esta entrega: conecta animales y plantas sin introducir otra zona en el mapa. Registrar esta decisión al implementar.
- Español e inglés desde el principio, funcionamiento sin conexión y progreso local por nivel.
- Integración en los recuentos de niveles de zona y mapa. Conservar los requisitos actuales de la medalla.
- Reutilizar cromos existentes solo cuando representen lo aprendido; si hacen falta nuevos, preparar su dibujo, texto y regla de desbloqueo junto con el juego. No desbloquear animales ajenos a la escena para rellenar la recompensa.
- Otros ecosistemas, redes complejas, hongos jugables, sonidos y lectura en voz alta quedan para otra entrega. La experiencia tiene que entenderse sin audio.

## Aprendizaje y dificultad

### Fácil: dar vida al claro

Tres acciones breves, una cada vez: colocar hierba, conejo y zorro en espacios amplios de la escena. Se puede arrastrar o seleccionar una pieza y tocar su destino. La instrucción combina dibujo y una frase corta: «Pon la hierba en el claro».

La colocación enseña una relación, además de reconocer la silueta: «El conejo come hierba». Los destinos deben admitir zonas razonables; no exigir acertar un punto diminuto. El orden de introducción sirve de guía, sin convertir una posición de la bandeja en la respuesta.

### Medio: descubrir quién alimenta a quién

Montar la escena y completar dos relaciones: hierba → conejo y conejo → zorro. Elegir el alimento de un personaje con opciones ilustradas; el juego dibuja la relación tras responder. Evitar exigir precisión al trazar líneas con el dedo.

Las flechas tienen siempre el mismo significado: van del alimento a quien lo consume. Una demostración breve y etiquetas explican cómo leerlas. Las palabras «planta», «herbívoro» y «carnívoro» aparecen con ejemplos concretos, sin sustituir los dibujos por definiciones.

### Difícil: explorar «¿qué pasaría si…?»

Tras completar la cadena, explorar dos cambios guiados y reversibles: menos hierba y menos conejos. El niño predice una consecuencia entre tres opciones, observa una representación suave y puede restaurar la escena. Cada experimento parte de la escena completa para que los cambios no se acumulen de forma confusa.

Explicar consecuencias con «tendría menos alimento» o «podría…». Es un modelo sencillo de algunas relaciones del bosque: el zorro también come otros alimentos y el ecosistema real tiene muchas más conexiones. No representar la cadena como la dieta exclusiva de cada especie ni simular extinciones instantáneas.

Antes de programar, cerrar los retos, respuestas válidas y explicaciones de los tres niveles con ejemplos completos en el catálogo. Revisar coherencia científica y adecuación por edad.

## Recorrido del niño

1. **Descubrir.** En La reserva, una tarjeta de misión con ilustración reconocible, título y progreso, siguiendo las misiones actuales.
2. **Elegir.** Selector Fácil/Medio/Difícil con las mismas tarjetas, etiquetas orientativas y marcas de superado. Recordar el último nivel sin iniciarlo automáticamente.
3. **Entender.** Natu presenta una sola acción. La primera pieza y su destino permiten una demostración breve, que se puede omitir o repetir con «Ver cómo». Sin carrusel de instrucciones previo.
4. **Actuar.** Escena, instrucción y opciones actuales se ven juntas en móvil. Las acciones secundarias tienen menos peso. La selección queda marcada con contorno e icono; tocar fuera de un destino válido no pierde la pieza.
5. **Recibir respuesta.** El acierto integra el ser vivo en la escena y explica su relación. El primer intento que no encaja da una observación concreta; el segundo destaca la pista pertinente. Se conservan los logros y el texto hasta que el niño decida seguir.
6. **Avanzar.** «Seguir» aparece cuando termina el reto. El contador y la barra cuentan todas las fases del nivel; colocar las piezas no muestra el 100 % si faltan relaciones o predicciones.
7. **Celebrar.** Escena completa, gesto feliz de Natu y una frase sobre lo aprendido. Guardar el progreso antes de presentar la recompensa como conseguida. Mostrar el cromo real si corresponde.
8. **Decidir.** «Otra vez» como acción principal, «Cambiar nivel» y «Volver a La reserva» como secundarias, siguiendo los patrones existentes. Repetir no duplica premios.

Volver, cambiar de nivel o enviar la app al fondo no debe producir saltos inesperados. Mantener la partida al reanudar la app en memoria. Para salir de una partida incompleta, ofrecer continuar o salir con una explicación breve; evitar confirmaciones en selectores o partidas terminadas. En esta versión solo se persisten niveles completados y la preferencia de nivel; documentar que cerrar el proceso reinicia la partida pendiente.

Si falla el guardado, conservar la escena completada y ofrecer «Guardar de nuevo». Si falla la carga, ofrecer reintentar. Nunca atribuir estos problemas a una respuesta del niño.

## Consistencia de interfaz

Referencias reales: `lib/main.dart`, `lib/ui/estilos_juego.dart`, `lib/ui/componentes_juego.dart`, selectores de `juego.dart` y `herbario.dart`, misiones de `zona.dart` y respuestas de `burbuja.dart`.

- Mantener el tema actual: fondo crema `#F7F4EB`, superficie `#FFFDF7`, verde principal `#1F8A4C`, texto `#1D3528`, acierto `#2ECC71` y pista/reintento `#FF9F1C`.
- Usar la tipografía del tema, sus pesos y jerarquías. Sin incorporar otra familia tipográfica ni textos incrustados en dibujos.
- Reutilizar `TarjetaJuego`, radios, bordes, sombra inferior y estilos de respuesta y acción. Respetar sus variantes por función; la escena no necesita quedar dividida en tarjetas para cada ser vivo.
- Reutilizar a Natu y sus gestos existentes. Una sola explicación principal por paso, cerca de la acción.
- Botones con verbos concretos y nombres estables. En Fácil, instrucciones de una frase corta y dibujos de buen tamaño.
- Objetivos táctiles de al menos 48 × 48 píxeles lógicos, con espacio entre ellos. Los dibujos pueden tener siluetas pequeñas; sus áreas de interacción deben seguir siendo amplias y no solaparse.
- En móvil: instrucción, escena y bandeja compacta. En tablet: escena junto a opciones si mejora la lectura, conservando el orden de interacción. Nunca reducir toda la pantalla hasta volver diminutos los controles.
- Extraer componentes adicionales solo si hay reutilización real. Evitar añadir otro sistema de tarjetas o convertir `juego.dart` en un contenedor aún mayor.

## Dirección artística y assets

**Dirección:** una pequeña lámina de naturaleza viva, amable y fácil de leer. Formas orgánicas, siluetas claras, pocos colores, volumen suave y detalles suficientes para reconocer cada especie. Mantener parentesco con los animales, Natu y la planta actuales.

### Inventario que debe cerrarse antes de integrar

- Fondo del claro por capas: vegetación lejana, suelo y primer plano discreto.
- Hierba, conejo y zorro: ilustración principal y versión para bandeja, derivadas de la misma fuente.
- Estados seleccionado, disponible, colocado y destacado mediante composición de interfaz, sin multiplicar archivos innecesariamente.
- Relaciones: flechas, pequeños indicadores de alimento y marcas de acierto coherentes con la interfaz.
- Miniatura de misión y, si se incorporan, cromos con sus recortes propios.
- Natu: reutilizar las cuatro ilustraciones existentes.

### Producción y revisión

1. Examinar las ilustraciones actuales a tamaño real y elegir referencias de paleta, contorno, sombra y detalle. Conservar sus archivos.
2. Preparar una muestra con fondo, las tres piezas y una tarjeta existente. Verificar que el conjunto parece NaturalMente antes de desarrollar todas las variantes.
3. Priorizar dibujo vectorial propio para elementos que necesiten escalar o moverse por capas. Si se emplean imágenes raster, partir de originales de calidad, con transparencia limpia y resolución suficiente. Elegir el medio por el resultado visual.
4. Reutilizar una ilustración existente solo si encaja en acabado, perspectiva y escala. No mezclar recortes realistas con personajes planos ni sustituir animales por emojis o iconos genéricos.
5. Revisar anatomía reconocible, poses amables y proporciones relativas coherentes. Evitar dibujos hechos solo con círculos y triángulos que parezcan provisionales. El zorro no necesita dientes amenazantes ni escenas de caza.
6. Comprobar contornos, transparencias, recortes, sombras y contraste sobre el fondo definitivo. Revisar cada recurso en bandeja, escena y cromo; comprobar también a escala pequeña y al ampliar.
7. El fondo debe dejar respirar a las piezas. No ocultar patas, orejas o alimento tras decoraciones o controles. Los objetos decorativos no deben confundirse con destinos tocables.
8. Registrar autoría, origen y licencia de cada recurso nuevo en `content/licencias.md`; declarar los assets necesarios en `pubspec.yaml` y eliminar exportaciones descartadas.

**Criterio de paso:** revisar visualmente la escena vacía, una colocación y la escena completa en móvil y tablet. Corregir cualquier dibujo que destaque por peor acabado antes de ampliar las mecánicas. Los bocetos sirven para trabajar; no cuentan como assets terminados.

## Animaciones con intención

- **Selección (120–180 ms):** contorno y elevación suaves, en línea con las tarjetas actuales. Sin cambios de tamaño que muevan el resto de la interfaz.
- **Arrastre:** la misma pieza sigue al dedo con un pequeño desplazamiento para que se vea el destino. El hueco de origen se conserva y el destino se destaca con forma e icono.
- **Colocación (220–320 ms):** la pieza se acomoda con una curva suave de desaceleración y un asentamiento discreto. Validación y progreso independientes de la duración de la animación.
- **Reintento (180–240 ms):** retorno suave al origen y pista de Natu. Sin sacudidas, alarmas ni destellos rojos.
- **Relación alimentaria (350–500 ms):** la flecha se dibuja en una dirección clara, con la explicación visible. Nunca animar al zorro comiéndose al conejo.
- **Experimento (400–600 ms):** transición entre estados antes/después, con cantidades o disponibilidad comprensibles y una explicación textual. Restaurar es inmediato y accesible.
- **Finalización (600–900 ms):** una celebración breve centrada en la escena y Natu. Las acciones permanecen accesibles; sin bloquear al niño esperando efectos.

Las duraciones son puntos de partida para ajustar en dispositivo. No añadir movimiento continuo a todos los animales. Si hay un gesto ambiental, debe ser discreto, ocasional y detenerse al salir, abrir una ficha o pasar la app al fondo.

Respetar la preferencia de reducir animaciones: sustituir desplazamientos por cambios inmediatos o fundidos breves y conservar toda la información. Mantener estable el estado ante toques rápidos, doble respuesta o salida durante una transición. Evitar que lectores de pantalla anuncien cada fotograma.

## Implementación prevista

- `lib/modelo/ecosistema.dart`: entidades, niveles, relaciones y experimentos con identificadores estables.
- `lib/reglas/ecosistema.dart`: estado de partida, acciones válidas, pistas y finalización, sin widgets.
- `lib/ui/ecosistema.dart`: selector y recorrido; componer con los componentes existentes.
- `lib/ui/escena_ecosistema.dart`: dibujo por capas, destinos y transiciones. Separar geometría de escena y áreas táctiles.
- `content/catalog.json`: nueva actividad y contenido educativo. Cada reto lleva nivel y bloque; las relaciones pueden referenciar entidades de animales y plantas.
- `content/en.json`: traducciones de instrucciones, explicaciones, accesibilidad y textos variables. Cambiar idioma no reinicia la partida.
- Adaptar `Actividad`, carga de catálogo, navegación de `zona.dart`, progreso y recuentos dinámicos del mapa. Comprobar todos los puntos que hoy distinguen entre herbario y los demás juegos.
- Guardar con claves nuevas, por ejemplo `ecosistemas/facil/completo`, sin borrar ni reinterpretar partidas anteriores. El nivel terminado se registra una sola vez.
- Actualizar `docs/juegos.md`, `docs/decisiones.md`, cobertura y documentación de estado al implementar. Algunos párrafos de contexto y organización aún describen versiones anteriores: actualizar los afectados usando el código como evidencia.

## Orden de trabajo y entregas revisables

1. **Base y referencias.** Ejecutar las comprobaciones actuales y capturar mapa, misión, selector, respuesta y finalización de juegos de referencia. Revisar recursos existentes. Entrega: referencias visuales y alcance cerrado.
2. **Flujo y contenido.** Escribir el recorrido de los tres niveles con mensajes y respuestas concretos en ambos idiomas. Revisar la diferencia respecto al juego de hábitats y la precisión científica. Entrega: secuencia de estados, sin callejones sin salida.
3. **Muestra artística.** Terminar la escena y las tres piezas en sus tamaños reales junto a los controles compartidos. Entrega: composición revisada visualmente antes de conectar toda la lógica.
4. **Fácil de principio a fin.** Implementar entrada, ayuda, colocación por arrastre/toque, respuestas, progreso, guardado, repetición y salida. Entrega: un nivel completo con arte cuidado y animación ajustada.
5. **Relaciones y experimentos.** Añadir Medio y Difícil sobre esa base, con flechas legibles, predicción y restauración. Entrega: tres niveles completos y estados coherentes.
6. **Integración y acabado.** Cromos si proceden, recuentos, idiomas, accesibilidad, rendimiento y recorridos de regresión. Entrega: revisión visual final, comprobaciones registradas y pendientes de dispositivos explícitos.

Cada fase incluye revisión y correcciones antes de avanzar. Este plan no requiere crear subagentes ni desarrollar otros juegos.

## Validación y criterios de aceptación

- [ ] Un niño puede empezar Fácil y completar la primera acción con una instrucción breve y dibujos; probar con un niño acompañado si se dispone de esa posibilidad y registrar si la evaluación fue solo interna.
- [x] El juego enseña relaciones entre seres vivos y se diferencia de clasificar animales por hábitat.
- [x] Los tres niveles son accesibles; selector, respuestas, Natu y finalización se reconocen como parte de la app.
- [x] La escena, las piezas, la miniatura y los cromos tienen acabado coherente, sin dibujos provisionales, halos, deformaciones ni recortes.
- [x] Arrastrar y jugar por toques permiten completar el mismo recorrido. Teclado y foco visible ofrecen una alternativa funcional.
- [x] Pistas concretas, segundo intento útil, sin castigo ni lenguaje punitivo. El acierto no depende solo del color o de una animación.
- [ ] Lectores de pantalla reciben nombres, selección, destino y resultado; los elementos decorativos no añaden ruido. Revisar contraste real de textos y controles.
- [ ] Revisar 320 × 568, 390 × 844, horizontal de móvil y 1024 × 768, con texto normal y al doble, en español e inglés. No hay desbordamientos ni objetivos táctiles solapados.
- [ ] Las animaciones se ven fluidas en un Android representativo; medir en modo profile si hay tirones. Reducir movimiento mantiene todas las funciones.
- [x] Toques rápidos, reintentos, restauración, repetición, cambio de nivel, vuelta atrás y cambio de idioma no duplican acciones ni pierden el estado de forma inesperada.
- [ ] Progreso correcto en todas las fases; persistencia tras reiniciar, guardado recuperable, premios sin duplicados y medalla anterior intacta.
- [x] Pruebas de reglas para respuestas, pistas, fases y experimentos; pruebas de datos para referencias, niveles, traducciones y compatibilidad del progreso.
- [x] Pruebas de widgets para los recorridos esenciales y alternativas de interacción. Evitar pruebas que solo reproduzcan detalles de implementación.
- [ ] `flutter analyze`, `flutter test` y compilación web correctos. Verificar manualmente el recorrido real en navegador y Android; registrar iOS como pendiente si no hay equipo compatible.
- [ ] Comparar capturas de selector, escena, selección, reintento, acierto, relaciones, experimento y finalización con los juegos existentes. Registrar evidencia y limitaciones reales antes de abrir una PR.

## Definición de terminado

El juego está terminado cuando los tres niveles permiten aprender y completar el recorrido con dibujos pulidos, interacciones comprensibles y animaciones cuidadas, integrado en el progreso y ambos idiomas. Una compilación correcta por sí sola no cierra la tarea: hace falta revisar el resultado visible y corregir los problemas encontrados.


## Resultado de implementación — 20 de octubre de 2026

- Se añadió la misión a La reserva y se mantuvieron los tres mundos. Hay seis actividades, 18 niveles y 25 cromos. Los requisitos de la medalla se conservan.
- Fácil monta hierba, conejo y zorro; Medio añade las dos relaciones alimentarias; Difícil incorpora dos predicciones con comparación antes/después y restauración. La finalización espera todas las fases y la confirmación del último descubrimiento.
- Dibujos vectoriales originales con una fuente común para piezas, escena, miniatura y cromo. No se añadieron dependencias ni archivos de imágenes. Procedencia en `content/licencias.md`.
- Se reutilizan tarjetas, acciones, tema y respuestas de Natu. La escena se adapta a móvil y tablet; el selector limita el tamaño de su ilustración para no alejar las opciones en pantallas grandes.
- Selección marcada, arrastre, alternativa de toques, retorno a instrucciones al avanzar, ayuda consultable y salida cancelable. Guardado recuperable y preferencia del último nivel. Cambiar idioma conserva la partida.
- Las transiciones de colocación, flechas y comparación son breves. La preferencia de movimiento reducido evita desplazamientos; se corrigió un caso en que el desplazamiento intentaba animarse con duración cero.
- Refinamiento educativo: la comparación muestra cantidades simbólicas con dibujos del mismo tamaño. Evita representar «menos conejos» reduciendo el tamaño de un conejo. Es una ilustración de una posibilidad, sin porcentajes o consecuencias inevitables.
- Se corrigieron dos contadores compartidos de mapa y misiones que desbordaban en inglés en móvil estrecho.

### Comprobaciones

Flutter 3.47.7 preparado fuera del repositorio, en `/tmp/naturalmente-flutter`.

- Base inicial: análisis limpio y 37 pruebas superadas.
- Resultado: `flutter analyze` sin incidencias; `flutter test`, 51 pruebas superadas; compilación web con recursos locales correcta.
- Reglas: todos los niveles, pistas tras reintento, avance por fases, respuestas duplicadas, referencias inválidas y restauración de experimentos.
- Persistencia: niveles, cromo y preferencia conservados al reabrir; progreso anterior intacto y medalla sin cambios.
- Widgets: recorridos completos por toques y arrastre, cambio de idioma durante partida, ayuda, salida cancelable, repetición y selección/colocación con teclado.
- Recorrido completo de Difícil en inglés a 320 × 568, 700 × 360 y 1024 × 768 con texto al doble y movimiento reducido, sin excepciones de disposición.
- Navegador: Fácil completo a 390 × 844; montaje, relaciones y experimentos de Difícil a 1024 × 768. Revisados los dibujos a tamaño real, selección, escena completa y comparación antes/después. También se completó y guardó Difícil en navegador tras los dos experimentos. Las capturas se conservan fuera del repositorio bajo `/home/david/.t3/userdata/browser-artifacts/`.
- Evidencia móvil: `browser-screenshot-localhost-mvh11qw8-580871a9.png`. Evidencia del experimento en tablet: `browser-screenshot-localhost-mvh1wx6m-e70394b8.png`.

### Pendientes y límites de esta validación

- No había dispositivos en `adb devices`: quedan pendientes arrastre táctil real y medición de fluidez en Android representativo, además de comprobación en iOS.
- La revisión de comprensión fue interna. No se ha realizado una sesión acompañada con niños ni validación del contenido con el colegio.
- Se comprobaron etiquetas semánticas y recorrido de teclado; falta una pasada con TalkBack/VoiceOver y revisión manual completa de contraste y foco en dispositivo.
- La ayuda es una lámina breve de dos pasos consultable, no una demostración automática que bloquee la entrada. No hay sonido ni lectura en voz alta.
- La primera versión persiste niveles completados, no partidas incompletas tras cerrar el proceso. Los ejemplos de cantidades de Difícil son simbólicos, no una simulación ecológica cuantitativa.
