# Plan de mejora visual del Herbario desmontable

Fecha: 14 de octubre de 2026.
Estado: implementación completada; revisión en dispositivos pendiente.
Rama de continuación: `david/herbario-desmontable`.
Rama de revisión en GitHub: `david/mejora-visual-herbario` (publicada mediante la conexión de GitHub; Git local no tenía credenciales de escritura).
PR funcional: https://github.com/imoroc/NaturalMente/pull/3 (integrada en `main`).
La mejora visual se entrega en una PR de continuación, desde la misma rama.

## Objetivo y punto de partida

Integrar el herbario en el estilo de los otros juegos: tarjetas con volumen para seleccionar y colocar piezas, botones rellenos para responder y una jerarquía clara para las acciones secundarias.

La funcionalidad del juego ya está implementada. El plan funcional y las verificaciones anteriores están en `docs/plan-herbario.md`. Esta continuación se centra en la presentación y en comunicar mejor los estados de interacción.

El diagnóstico que origina este plan procede del código. En la última comparación no se pudieron obtener capturas nuevas porque la vista previa integrada no estaba disponible. Al retomar, capturar los estados actuales antes de decidir los ajustes visuales finales.

## Referencias del proyecto

| Referencia | Patrón que se debe aprovechar |
| --- | --- |
| `lib/ui/juego.dart`, `_Sitio` | Tarjetas con radio de 22, borde de 2,5 y sombra inferior de 4 sin desenfoque. Bordes de 3,5 al seleccionar o arrastrar. |
| `lib/ui/juego.dart`, `_OpcionControl` y `_Orden` | Botones rellenos y tonales para respuestas y selecciones. |
| `lib/ui/zona.dart`, `_BotonMision` | Tarjetas blancas con borde de color, sombra inferior y etiqueta de actividad superada. |
| `lib/ui/burbuja.dart` | Respuestas con Brote y gestos de acierto, pensamiento y pista; componente ya compartido. |
| `lib/main.dart` | Fondo crema, verde principal, naranja secundario y estilos de texto del tema. |
| `assets/imagenes/` | Ilustraciones propias existentes para tomar como referencia de acabado y paleta. |

Los juegos existentes combinan tarjetas personalizadas y botones de Material. Conservar esas dos familias según su función; no convertir todos los controles en una única forma.

## Alcance

- Selector de dificultad, piezas, destinos sobre la planta y preguntas de función.
- Indicadores de selección, arrastre, fallo y acierto.
- Presentación del progreso, instrucciones y acciones de finalización.
- Componentes visuales compartidos que eviten duplicar los estilos de referencia.
- Revisión del dibujo y de su integración con los destinos, una vez alineados los controles.

Conservar los tres niveles, las reglas educativas, la alternativa mediante toques, las fichas, las claves de progreso y los requisitos de la medalla. Audio, nuevos juegos y nuevas dificultades siguen fuera de esta tarea.

## Fase 1. Capturar y comparar

- [x] Abrir hábitat, germinación, reproducción y herbario con el mismo tamaño de pantalla.
- [x] Capturar entrada, opción seleccionada, fallo, acierto y finalización donde existan. En herbario, incluir selector y pregunta de Difícil.
- [x] Comparar móvil de 390 × 844 y tablet de 1024 × 768; guardar las capturas en una carpeta de trabajo sin añadir automáticamente archivos de pruebas al repositorio.
- [x] Revisar cada captura y confirmar diferencias de bordes, sombras, formas, tipografía y posición de las acciones.

Entrega: referencias actuales y una comparación que permita comprobar después si el herbario pertenece a la misma familia visual.

## Fase 2. Extraer los estilos compartidos

- [x] Crear `lib/ui/estilos_juego.dart` para los valores compartidos de tarjetas, espaciado y estados, tomando como fuente los widgets existentes.
- [x] Crear `lib/ui/componentes_juego.dart` con una tarjeta interactiva y estilos o componentes ligeros para respuestas y acciones. Separar la decoración de la validación del juego.
- [x] Extraer el patrón de una tarjeta existente y usarlo también en el herbario. Mantener el aspecto del juego de referencia durante la extracción.
- [x] Usar el tema para colores generales y textos. Centralizar los colores de selección, acierto y fallo que deban repetirse.
- [x] Conservar las formas propias de los botones de Material y distinguir acciones principales, secundarias y enlaces de consulta.

Entrega: componentes realmente compartidos por el herbario y al menos una referencia existente, con una API pequeña. Evitar un motor visual configurable para juegos que todavía no existen.

## Fase 3. Alinear los controles del herbario

- [x] Selector: sustituir las tarjetas de contorno fino por el patrón de las misiones, manteniendo nivel, curso, descripción y estado superado.
- [x] Piezas: añadir borde, sombra inferior y etiquetas con el peso de las tarjetas existentes. Mantener la selección visible mediante marca y texto, además del color.
- [x] Arrastre: usar la misma tarjeta para la pieza y su representación mientras se mueve; conservar el hueco atenuado sin cambiar bruscamente el tamaño.
- [x] Destinos: aplicar borde y volumen coherentes con `_Sitio`, adaptándolos al espacio del dibujo. No aumentar su tamaño hasta solapar flor, fruto u otros destinos.
- [x] Preguntas de función: usar botones rellenos o tonales siguiendo germinación y reproducción, con alineación y altura consistentes.
- [x] Acciones: aplicar la misma altura a «Otra vez» y a las acciones principales de los juegos actuales. Reservar contorno o texto para «Cambiar nivel», volver y consultas.

Los botones de respuesta y piezas deben conservar un área táctil de al menos 48 píxeles lógicos. No copiar las alturas menores de algunos controles antiguos si eso empeora su uso táctil.

## Fase 4. Comunicar los estados y ordenar la pantalla

- [x] Añadir al estado de partida el último destino válido intentado, si es necesario para pintarlo. Ahora `PlantaHerbario` recibe colocadas y selección, pero no el resultado del intento.
- [x] Comunicar destino disponible, arrastre encima, último fallo y acierto con el patrón existente: naranja para reintentar y verde para acierto, acompañados de icono o texto.
- [x] Al reintentar, seleccionar otra pieza o cambiar de nivel, retirar el estado anterior según corresponda. Una pieza ya colocada debe conservar su marca de acierto.
- [x] Mantener las explicaciones educativas y los gestos de Brote; no introducir frases genéricas de fallo.
- [x] Hacer que el curso sea un texto secundario y que la instrucción principal tenga más peso. Evitar repetir instrucciones largas alrededor de la planta.
- [x] Incorporar una barra de progreso además del contador. En Fácil y Medio contar colocaciones; en Difícil contar colocaciones y funciones como dos fases para evitar mostrar el juego como terminado antes de responder.
- [x] Mantener visibles las preguntas y sus explicaciones al avanzar de fase. Revisar el desplazamiento cuando una respuesta añade contenido debajo del dibujo.
- [x] Dar una jerarquía clara a la finalización y a las acciones para repetir, cambiar nivel o volver.

Entrega: el usuario distingue qué puede tocar, qué está seleccionado, dónde se ha equivocado y qué falta por completar.

## Fase 5. Revisar la ilustración

- [x] Comparar la planta y sus piezas con las ilustraciones existentes después de armonizar los controles.
- [x] Revisar que los destinos no oculten precisamente los rasgos necesarios para reconocer cada parte. Ajustar la opacidad y el indicador de destino vacío.
- [ ] Si las formas actuales siguen destacando por su acabado, preparar ilustraciones propias coherentes con los recursos existentes, con fondo transparente y dimensiones adecuadas a sus huecos.
- [ ] Si se incorporan archivos nuevos, declararlos en `pubspec.yaml`, documentar su procedencia y comprobar que su recorte y escala funcionan en ambos tamaños de pantalla.

Esta fase puede entregarse después de los botones. No bloquear la primera mejora de coherencia visual esperando un conjunto nuevo de ilustraciones.

## Fase 6. Validar y registrar el resultado

- [x] Comparar las capturas anteriores y posteriores en los mismos tamaños y estados.
- [x] Ejecutar `flutter analyze` y `flutter test`; el punto de partida tenía 23 pruebas superadas.
- [x] Añadir o adaptar solo pruebas de comportamiento necesarias: destino marcado tras un fallo, cambio de selección, limpieza de estado al repetir y progreso de las dos fases de Difícil.
- [x] Verificar arrastre y toques, fichas, finalización, persistencia y medalla después de reutilizar componentes.
- [x] Revisar 320 × 568, 700 × 360 y 1024 × 768 con texto ampliado al doble. Evitar que el ajuste visual fuerce alturas que recorten el contenido.
- [ ] Comprobar foco visible, etiquetas y orden de navegación; el color no debe ser el único indicador de estado.
- [ ] Probar en navegador y en Android real cuando esté disponible. Anotar las comprobaciones de iOS pendientes.
- [x] Actualizar este documento y la descripción de la PR con el resultado, la evidencia y los pendientes reales.

## Orden de commits propuesto

1. `Comparte los estilos de tarjetas y respuestas entre los juegos.`
2. `Alinea los controles del herbario con los juegos existentes.`
3. `Mejora los estados y el progreso visual del herbario.`
4. `Ajusta las ilustraciones y documenta la revisión visual del herbario.` — si se completa la fase de ilustración.

Cada commit debe dejar la app utilizable. La PR #3 ya está integrada; continuar en esta rama y abrir una PR de continuación para la mejora visual. Su integración en `main` requiere revisión.

## Criterios de aceptación

- [x] Selector, piezas y destinos comparten el estilo de tarjetas del proyecto.
- [x] Las respuestas y acciones mantienen una jerarquía coherente con los otros juegos.
- [x] Selección, arrastre, fallo y acierto se distinguen sin depender solo del color.
- [x] El progreso de Difícil no se presenta como completo al terminar únicamente las colocaciones.
- [x] Los componentes extraídos también se usan en una pantalla existente sin cambiar su comportamiento.
- [x] Todos los niveles conservan sus interacciones, contenido y progreso guardado.
- [x] La comparación con capturas confirma coherencia en móvil y tablet.
- [x] No hay recortes ni desbordamientos en los tamaños y escalas revisados.
- [x] Análisis y pruebas pasan; verificaciones y pendientes están documentados.

## Cómo retomar

La implementación visual está terminada en `david/herbario-desmontable`. Para retomar la validación manual, leer el resultado siguiente y revisar los pendientes. Comprobar primero el estado del repositorio y si hay cambios nuevos del equipo en `main`. Preparar Flutter y el navegador disponibles en ese momento: las rutas bajo `/tmp` utilizadas durante la implementación anterior eran temporales.


## Resultado de la ejecución — 14 de octubre de 2026

- Se incorporó `origin/main` antes de continuar; la PR #3 ya estaba integrada.
- `EstilosJuego` y `TarjetaJuego` comparten la decoración de hábitat, las misiones y el herbario. Hábitat conserva radio 22, bordes 2,5/3,5 y sombra inferior de 4; las misiones conservan radio 20 y sus colores. La validación sigue en las reglas.
- El selector muestra tarjetas con volumen. Las piezas usan la misma tarjeta para toque, arrastre y hueco atenuado. Se distribuyen en dos columnas en móvil y tres en tablet; el texto grande usa tarjetas más anchas. No se fijan alturas de texto.
- Los destinos miden 56 × 56, dejan ver más de la silueta y muestran suma, flecha de arrastre, reintento o marca de acierto. El último fallo se limpia al seleccionar o reintentar; una parte colocada conserva su marca. Las etiquetas accesibles describen los estados y distinguen las fichas disponibles.
- Las preguntas usan botones tonales con altura mínima 56; «Otra vez» y «Cambiar nivel» comparten altura mínima 52. El curso es secundario y la instrucción principal tiene más peso.
- El progreso de Difícil cuenta diez pasos: cinco colocaciones y cinco funciones. Al terminar las colocaciones indica 50 %. Las preguntas y su explicación se desplazan a la vista al avanzar o reintentar.
- Se conserva el dibujo vectorial propio. Los huecos son menores y más transparentes; el suelo respeta el recorte redondeado. No se necesitan ilustraciones nuevas, declaraciones de assets ni cambios de dependencias. Los dos pasos condicionales de generación de imágenes quedan sin aplicar.

### Evidencia y comprobaciones

Flutter 3.47.7 y Dart 3.13.5, preparados fuera del repositorio:

- `flutter analyze`: sin incidencias.
- `flutter test`: 25 pruebas superadas. Incluyen fallo, cambio de selección, repetición, arrastre, fichas, guardado, medalla y progreso de las dos fases; se añadió acceso al selector con teclado.
- `flutter build web --no-web-resources-cdn`: compilación correcta.
- 320 × 568, 700 × 360 y 1024 × 768 con texto al doble: selector, Medio, ficha, todas las colocaciones y funciones de Difícil, finalización y repetición sin desbordamientos.
- Comparación de 38 imágenes anteriores y 38 posteriores a 390 × 844 y 1024 × 768. Incluyen entrada, selección donde existe, fallo y acierto de hábitat, germinación y reproducción; selector, colocación, selección, fallo, acierto, finalización y preguntas del herbario. Las referencias conservan sus píxeles al extraer las tarjetas. Los estados de acierto de germinación y reproducción también representan su finalización; no existe una selección separada del intento en hábitat.
- Las imágenes comparativas proceden de renderizado de widgets Flutter, con fuentes e iconos cargados y sombras activadas. Se guardaron en `/tmp/naturalmente-revision/{antes,despues}/`; el guion temporal está en `/tmp/naturalmente-captura_test.dart`. No se añaden capturas ni pruebas visuales temporales al repositorio. El renderizado de widgets conserva la fuente de prueba en algunos títulos: la revisión de tipografía de esos títulos usa las capturas del navegador.
- La vista previa integrada permitió capturar el selector, entrada y selección del herbario en móvil y las misiones. Las capturas del navegador están en `/home/david/.t3/userdata/browser-artifacts/`. La sesión sufrió tiempos de espera e interrupciones por interacción humana, y terminó perdiendo la conexión de automatización; no se considera validado un recorrido completo del navegador.

### Pendientes reales

- Repetir el recorrido completo en navegador y revisar foco visible y orden de navegación de piezas/destinos. El selector sí está comprobado con Tab y Enter; todos los controles conservan `InkWell` o botones Material y un color de foco explícito en las tarjetas.
- Validar arrastre y lectura en Android real: `adb devices` no mostró dispositivos conectados.
- Comprobar iOS en un equipo y dispositivo compatibles.
- Revisar y aprobar la PR de continuación antes de integrar en `main`.
