# Cromos con diseño de ficha de campo

**Estado.** Implementación y verificación completas en la vista previa y la celebración. Las 97 fichas tienen un resumen en español e inglés. Las 85 cartas del rediseño usan sus ilustraciones WebP y las 12 incorporadas después usan sus dibujos de Flutter. La primera maqueta es la referencia para la cabecera, los contornos y la banda inferior. [Maqueta elegida del Pulpo](prototipos/cromo-ficha-de-campo.webp).

## Diseño del cromo

1. **Marco.** Conservar la proporción 5:7. La vista previa y la celebración muestran la carta con un ancho de hasta 304 puntos lógicos, frente a los 232 iniciales. El ancho se adapta a la pantalla y reserva espacio para que se vea el canto durante la inclinación. Mantener el borde de Latón o Nácar y el filete fino con esquinas recortadas sobre el papel interior.
2. **Cabecera.** Colocar el mundo en pequeño, encima de un separador corto, y el nombre del cromo debajo en Nunito. Alinear los tres elementos a la izquierda. Reservar hasta dos líneas para el nombre en el tamaño habitual y ajustar el tamaño de las palabras largas al ancho real.
3. **Ilustración.** Centrar el WebP original en la zona de mayor tamaño, encajado completo y con aire alrededor. Probar la composición con una silueta ancha, otra vertical y una que tenga varios elementos. Reutilizar el recurso del álbum por ID.
4. **Decoración.** Dibujar contornos finos en la esquina superior derecha y la inferior izquierda, como en la maqueta. Mantener despejadas las zonas de lectura y limitar la textura al papel. Empezar por el mismo motivo en los tres mundos, con un acento tenue verde azulado en La reserva, verde hoja en El invernadero y ciruela suave en Dentro de mí. El material del borde indica el acabado coleccionable.
5. **Banda de datos.** Usar un recuadro ligeramente geométrico, con etiqueta pequeña y valor destacado. Con dos datos, colocar un separador vertical si ambos caben con hasta dos líneas. Si necesitan más ancho, apilarlos. Con un solo dato, ocupar el ancho completo. Con texto ampliado por encima del 150 %, trasladar la banda bajo la carta.

La vista previa enmarca el paisaje en un panel redondeado. Comparte la cabecera fija y la flecha enmarcada con las pantallas de los mundos. «Sobre este cromo», «Ir al juego» y «Ver en mi álbum» usan las acciones con relieve del cierre de partida. La carta sigue arrancando con el giro suave que deja ver el canto. [Ruta y celebración del álbum](../lib/ui/cromos_zona.dart).

## Contenido de los campos

| Cromo | Primer campo | Segundo campo |
| --- | --- | --- |
| Pulpo | Grupo · Molusco | Hábitat · Mar |
| Camello | Grupo · Mamífero | Hábitat · Desierto |
| Romero | Tipo · Arbusto | Hábitat · Matorral |
| Intestinos | Sistema · Digestivo | Función · Absorber nutrientes |

Los campos se eligen según el tema de cada ficha. «Grupo» y «Hábitat» sirven para muchos animales. En plantas, «Tipo», «Parte» o «Proceso» permiten explicar tanto una especie como una función. En cuerpo humano, «Sistema», «Lugar» y «Función» se adaptan a órganos y procesos. Para temas generales, como las emociones, usar un único dato si aporta algo al título. La banda se omite si la ficha carece de datos adecuados.

Añadir a [Ficha](../lib/modelo/ficha.dart) una lista opcional `resumenCromo` de hasta dos pares etiqueta–valor. Guardarla en [el catálogo](../content/catalog.json) por ID. Las etiquetas salen de un conjunto pequeño de claves traducibles y los valores se redactan en una a tres palabras siempre que resulte claro. Revisar cada resumen con el catálogo y [los datos enciclopédicos](../lib/ui/dibujos_natu.dart), y traducirlo en [content/en.json](../content/en.json). La ficha que abre «Sobre este cromo» conserva el contenido detallado y la curiosidad de Natu. [Detalle educativo](../lib/ui/zona.dart).

## Implementación en Flutter

1. **Probar el Pulpo en Nácar.** Implementar la cabecera, el encuadre y la banda inferior en `_ContenidoCromo`. Construir el filete y los contornos como trazos de Flutter en una capa estática del papel, con el mismo trazado para todos los acabados. Comparar posición, proporciones y lectura con la maqueta a 390 × 844.
2. **Comprobar la reutilización.** Probar el Camello en Latón, el Romero en El invernadero e Intestinos en Dentro de mí. Ajustar los márgenes con esos cuatro casos antes de completar los resúmenes del catálogo. Usar la misma cara en la vista previa y la celebración. La cuadrícula muestra la ilustración y el nombre en sus miniaturas.
3. **Mantener el gesto fluido.** Conservar `CromoColeccionable`, sus límites de giro y su retorno al reposo. Mantener decoración, ilustración y texto en capas que puedan reutilizarse al inclinar la carta. Dejar que el reflejo dinámico recorra solo el borde. Con movimiento reducido, la composición permanece frontal y la banda es igualmente legible. [Marco y contenido compartidos](../lib/ui/cromo_coleccionable.dart).
4. **Cubrir estados y accesibilidad.** Antes del desbloqueo, usar el papel neutro, el candado y la pista existente. La cabecera, la ilustración y los datos de una ficha conseguida se anuncian en un orden coherente, evitando repetir el nombre. Por encima del 150 % de escala, colocar nombre, mundo y campos debajo de la carta, en un bloque con ancho suficiente. El desplazamiento vertical da acceso a los datos y al botón. La celebración aplica el mismo criterio.
5. **Completar y revisar el catálogo.** Revisar los 85 IDs por mundo, con atención a valores largos en inglés, títulos de más de una línea y fichas que usan un solo campo. Validar tipos de etiquetas, traducciones y un máximo de dos campos por ficha. Reutilizar el acabado asociado a cada ID y el progreso de desbloqueo existente. Mantener el acceso desde el cierre tras el guardado confirmado. [Pruebas del catálogo](../test/datos/catalogo_test.dart) y [guía de cierre](feedback-y-cierre.md).

## Criterios de aceptación

| Área | Comprobación |
| --- | --- |
| Fidelidad visual | El Pulpo presenta las formas del boceto, mantiene visible el canto y usa el WebP original sin recortes. Los contornos se perciben en ambos acabados con buena lectura del texto. |
| Contenido | El Pulpo muestra «Grupo · Molusco» y «Hábitat · Mar». Una ficha con un solo campo aprovecha el ancho. La vista de un cromo pendiente presenta el candado en la carta y la pista debajo. |
| Diseño adaptable | Revisar 360 × 700 y 390 × 844, claro y oscuro, ES y EN. Comprobar un nombre largo, texto al 200 %, lectura asistida, teclado y movimiento reducido. |
| Rendimiento | Medir los dos acabados en el mismo Android y con el mismo procedimiento del rediseño anterior. Comparar el p95 del tiempo total con la referencia de 7,62 ms en Latón y 8,14 ms en Nácar a 120 Hz. Revisar cualquier retroceso antes de cerrar el cambio. |
| Navegación y cierre | Probar el retorno al álbum, el detalle educativo, la pista de un cromo pendiente y la misma cara en la celebración. Verificar que un guardado fallido y su reintento respetan el flujo común de recompensas. |

Ejecutar `dart analyze --fatal-infos` y `flutter test` tras implementar. Ampliar los recorridos de [Mis cromos](../test/ui/cromos_zona_test.dart) y [cierres de juegos](../test/ui/cierres_juegos_test.dart). [Medición anterior y referencia de comportamiento](plan-vista-previa-cromos.md).

## Verificación

- Pasaron las 307 pruebas y el análisis estático de Dart.
- Se revisaron 16 casos renderizados en Flutter con los tamaños, temas e idiomas previstos. Incluyeron los cromos piloto de los tres mundos, un cromo bloqueado, texto al 200 %, movimiento reducido y la celebración.
- Se comprobó que los campos de las 85 fichas se leen completos al 150 % en ambos idiomas. A esa escala, la banda conserva dos columnas cuando los valores caben y pasa a filas cuando necesitan más ancho.
- La primera versión de la ficha de campo se midió en el mismo Android físico con Flutter en modo perfil a 120 Hz. El tiempo total p95 fue de **5,16 ms en Latón** y **4,54 ms en Nácar**, con 306 fotogramas por acabado tras el primer gesto de calentamiento.
- La ampliación posterior se revisó en Flutter a 360 × 700 y 390 × 844. Se comprobó que el marco cabe en el panel, la cabecera permanece fija al desplazar y las acciones se pueden alcanzar con texto al 200 %. Las capturas de referencia de la ficha educativa se actualizaron para ambos temas.

## Icono de Sobre este cromo

**Propuesta pendiente de implementación.** El botón mostraría una miniatura vertical del cromo que se acaba de abrir. Un marco fino identificará Latón o Nácar y la ilustración original irá centrada, a tamaño de icono. El Pulpo se reconocerá por su silueta y el Romero por sus ramas. El título y la banda de datos seguirán en la carta grande, donde tienen espacio para leerse.

1. Dar a [AccionNatu](../lib/ui/accion_natu.dart) una opción para recibir una miniatura en el hueco que ya ocupa el icono. Centrar una carta de proporción 5:7 y unos 29 × 41 puntos en ese espacio, con el mismo relieve y separación del texto del botón actual.
2. Crear una miniatura estática que reutilice [IlustracionCromo](../lib/ui/carta_cromo.dart), el acabado de la ficha y su margen interior. Usar el arte alternativo existente cuando el catálogo carezca de un WebP. La miniatura se trata como decorativa para que el lector de pantalla anuncie el botón una sola vez.
3. Integrarla en «Sobre este cromo» y comprobar Camello, Pulpo y Romero en claro y oscuro. Revisar que las siluetas se distingan a tamaño real y que el botón mantenga su altura, su foco y la apertura del detalle con texto al 200 %.
