# Rediseño de la vista previa de Mis cromos

**Estado.** Implementación y verificación completas. La plantilla interactiva, el catálogo de acabados y la celebración compartida están integrados en Flutter. Las 85 fichas tienen su ilustración WebP. Se regeneraron 84 y se conservó el Camello original. En un Android físico se verificaron ambos acabados, el arrastre y la vuelta a la inclinación inicial, la ficha educativa y el regreso al álbum.

**Dirección visual.** Combinar la cabecera con flecha del boceto de Latón con la escena del boceto de Nácar. Dar a ambos acabados un papel en la colección. El cromo abierto ocupa el centro de la pantalla y responde a un arrastre corto. [Maqueta de la propuesta](prototipos/mis-cromos-propuesta.html).

## Cómo se verá

1. La pantalla conserva arriba la barra de la app con **‹ Mis cromos**. La flecha y el botón Atrás del sistema devuelven a la misma posición de la cuadrícula. La cabecera permanece visible si el contenido se desplaza.
2. El cromo se presenta sobre una escena oscurecida con arte del mundo correspondiente. En La reserva, por ejemplo, se distingue el paisaje detrás de la carta. El fondo permanece quieto y el oscurecimiento mantiene el contraste en los temas claro y oscuro.
3. En el centro hay una carta de proporción **5:7**, esquinas suavizadas y canto fino. En reposo aparece ligeramente girada: −4° en el plano, +3° sobre el eje horizontal y −5° sobre el vertical, para dejar ver el canto derecho. Para un móvil de 390 puntos, el punto de partida es **232 × 325**. La ilustración ocupa el área central, con un pequeño relieve. Abajo, una franja mate contiene el nombre y el mundo. La textura y el reflejo se concentran en el marco.
4. Debajo aparecen «Arrastra para inclinar» y una etiqueta breve del acabado, «Latón» o «Nácar especial». El botón **Sobre este cromo** abre la ficha educativa actual, con la descripción y la curiosidad de Natu. Al cerrar la ficha se vuelve a ver la carta.
5. Los cromos pendientes muestran el mismo formato con un marco neutro, candado y «Por descubrir». Debajo aparecen la pista de desbloqueo y «Ir al juego» cuando hay una actividad disponible. El arte y el acabado coleccionable se revelan al conseguirlo.

## Rareza y desbloqueo

| Acabado | Regla propuesta | Ejemplos iniciales |
| --- | --- | --- |
| **Latón** | Acabado de base para recompensas accesibles en Fácil o Medio, por completar un reto individual o disponibles en cualquier nivel. Metal cálido satinado, con reflejo dorado. | Camello, Semilla, Corazón. |
| **Nácar** | Acabado especial para una selección de cromos que actualmente exigen completar Difícil. Destellos perlados entre menta, rosa suave y champán. | Pulpo, La fotosíntesis, Intestinos. |

La rareza pertenece al cromo y se asigna en el catálogo según su requisito más accesible. Por ejemplo, el Camello sigue siendo Latón si se obtiene jugando en un nivel superior. Una ficha difícil de localizar en el álbum o pensada para un curso mayor no se convierte automáticamente en Nácar. Antes de ampliar la selección, contrastar las pistas con las rutas de obtención en [Progreso](../lib/datos/progreso.dart), incluidos los desbloqueos indirectos y los datos de instalaciones anteriores.

Añadir a [Ficha](../lib/modelo/ficha.dart) un enum `AcabadoCromo` con `laton` y `nacar` y leer un campo opcional `acabado` en [el catálogo](../content/catalog.json). Si el campo falta, aplicar Latón. Marcar explícitamente los Nácar en el catálogo y validar el campo en las pruebas de datos. Las fichas ya conseguidas adoptarán su acabado por ID al abrir el álbum. Sus claves guardadas, condiciones de desbloqueo, estrellas y semillas se conservan.

## Plantilla y movimiento en Flutter

- **Construir primero el marco vacío.** Crear un componente visual con cinco capas: canto, lámina metálica, papel interior, ilustración y franja de identificación. El marco comparte geometría y márgenes en ambos acabados. Los acabados varían en color, textura y reflejo. Usar gradientes de Flutter para construir el material y reservar cualquier textura raster para un recurso compartido si la revisión visual lo requiere.
- **Regenerar las ilustraciones del álbum.** Conservar el [WebP actual del Camello](../assets/cromos/camello.webp) tal cual y usarlo como referencia para regenerar el arte de todas las demás fichas del catálogo, también las pendientes y las que hoy dibuja Flutter. Crear una sola ilustración por ID con fondo transparente y encuadre común. Las capas de marco, acabado y texto las aporta Flutter. Mantener el estilo ilustrado del Camello, con un contorno claro y colores que funcionen sobre Latón y Nácar. Revisar los rasgos que identifican cada animal, planta u órgano y los detalles relevantes de la ficha educativa.
- **Superponer el contenido.** Usar el mismo archivo por ID en la vista previa, la celebración y la cuadrícula. Decodificarlo al tamaño de cada presentación para limitar la memoria que usa el álbum. `IlustracionFicha` conserva su uso en el resto de la app y sirve de respaldo a las fichas que carezcan de un recurso del álbum. Encajar las imágenes en una zona segura con `BoxFit.contain`. Ajustar el rótulo al ancho disponible con hasta dos líneas en el tamaño habitual. Con texto ampliado por encima del 150 %, mostrar el nombre completo y el mundo debajo de la carta y permitir que se desplace la pantalla. [Componente de carta](../lib/ui/cromo_coleccionable.dart) y [proveedor de ilustraciones](../lib/ui/dibujos.dart).
- **Limitar la inclinación.** Usar una transformación con perspectiva en dos ejes, con topes iniciales de ±8° en horizontal y ±6° en vertical. El arrastre se activa dentro del cromo con intención horizontal. Tras capturarlo, los dos ejes siguen el dedo y el reflejo acompaña el ángulo. Un gesto principalmente vertical desplaza la pantalla. Al soltar o cancelar, la carta vuelve a su ángulo de reposo en unos 180 ms con desaceleración suave. El canto y la sombra refuerzan el volumen.
- **Aislar el trabajo por fotograma.** Usar un controlador acotado a la carta y actualizar la transformación y la lámina. Mantener el fondo, la ilustración y el texto fuera de la reconstrucción por arrastre. Medir el gesto en un Android físico con el perfilador de Flutter y ajustar la textura si repercute en la fluidez.
- **Hacerlo accesible.** Respetar `MediaQuery.disableAnimationsOf(context)` al montar la ruta y durante cambios de preferencias. Con movimiento reducido se muestra el cromo frontal con el acabado visible y la indicación de arrastre se oculta. El lector de pantalla anuncia nombre, mundo y acabado en una sola descripción. Añadir un foco de teclado que permita inclinar el cromo con las flechas y volver al ángulo de reposo con Escape. Mantener un borde legible y una etiqueta textual para ambos acabados. Traducir los nuevos controles en [content/en.json](../content/en.json).

## Secuencia de implementación

1. **Validar la dirección visual.** Probar el marco vacío y el Camello en los dos materiales. Revisar a 390 × 844 la silueta, el canto, la legibilidad y el reflejo. Usar el Camello con ambos acabados solo para comparar el material. En el catálogo, el Camello es Latón.
2. **Conectar la ruta del álbum y sus estados.** Reusar la barra de `_VistaCromo` y la navegación existentes. Sustituir la carta del centro por la nueva composición y aprovechar `_PistaCromo` y `mostrarDetalleFicha`. Retirar el rótulo redundante «Cromo conseguido» cuando el acabado y el contenido ya identifican el estado. Usar el fundido breve de la ruta para abrir la carta y omitirlo con movimiento reducido. La carta adopta su inclinación inicial al aparecer. [Rutas, cuadrícula y vista previa](../lib/ui/cromos_zona.dart) y [detalle educativo](../lib/ui/zona.dart).
3. **Aplicar el catálogo.** Activar el Latón por defecto y marcar los primeros Nácar tras revisar sus requisitos. Probar Camello y Pulpo dentro de La reserva, luego La fotosíntesis e Intestinos para revisar los otros dos mundos. La cuadrícula conserva estructura y orden. Un borde estático del mismo material en las miniaturas conseguidas puede reforzar la continuidad sin añadir etiquetas ni brillo animado.
4. **Regenerar el arte por mundos.** Hacer un primer lote con Pulpo, La fotosíntesis e Intestinos junto al Camello original. Probar su encuadre sobre Latón y Nácar, en miniatura y a tamaño de vista previa. Tras fijar ese estilo, cubrir todos los IDs del catálogo por lotes de La reserva, El invernadero y Dentro de mí. Verificar que cada ficha tiene su arte asociado y registrar la procedencia de los recursos en [el inventario de licencias](../content/licencias.md).
5. **Compartir el marco con la celebración.** Reutilizar la misma presentación frontal y el acabado en `_CelebracionCromos`. Mantener el encabezado «¡Nuevo cromo!», la navegación entre recompensas y «Ver en mi álbum». Con texto ampliado, mostrar el encabezado sobre el fondo de la pantalla para conservar el contraste. La celebración sigue dependiendo del guardado confirmado de `FinJuego`, con el reintento y la deduplicación existentes. [Cierre común](../lib/ui/fin_juego.dart) y [guía de feedback y cierre](feedback-y-cierre.md).

## Criterios de aceptación

| Área | Verificación |
| --- | --- |
| Navegación | La flecha y Atrás regresan al mismo punto del álbum. «Sobre este cromo» abre el detalle original y cerrarlo conserva la carta. Un pendiente conserva su pista y el acceso al juego cuando corresponde. |
| Interacción | La carta aparece ligeramente girada y un toque conserva esa postura. Arrastrar inclina dentro de los límites, mueve el reflejo y vuelve al ángulo inicial al soltar o cancelar. Un arrastre vertical desde la carta permite bajar a la información. Validar también teclado y movimiento reducido. |
| Catálogo y progreso | Un cromo sin campo de acabado se presenta en Latón. Los marcados Nácar tienen el mismo acabado al volver a abrirlos o verlos en la celebración. Una partida en Difícil que entregue cromos de niveles inferiores mantiene el acabado de cada uno. Una instalación con progreso anterior conserva la colección. |
| Ilustraciones | El Camello usa su WebP original. Cada uno de los demás IDs del catálogo tiene una ilustración nueva. Verificar que funciona en ambos acabados, que se lee en miniatura y que representa el contenido de la ficha. |
| Apariencia | Revisar en 360 × 700 y 390 × 844, claro y oscuro, ES y EN, texto ampliado y lectura asistida. Verificar un nombre largo y una ilustración de cada mundo. Comprobar el gesto en dispositivo. |
| Cierre | Si se aplica el marco a la celebración, cubrir cero, uno y varios cromos nuevos y verificar que un fallo de guardado o un reintento no vuelve a conceder la recompensa. Verificar la vuelta al resultado de la partida. |

Para la implementación, ampliar [las pruebas del álbum](../test/ui/cromos_zona_test.dart), [del catálogo y progreso](../test/datos/catalogo_test.dart) y, al tocar la celebración, [de cierres](../test/ui/cierres_juegos_test.dart). Ejecutar `dart analyze --fatal-infos` y `flutter test`, además de la revisión visual en dispositivo.

## Verificación final

- Pasaron las 307 pruebas de la suite y el análisis estático de Dart.
- Se revisaron 15 casos renderizados por Flutter. Incluyeron las ocho combinaciones de 360 × 700 y 390 × 844, claro y oscuro y español e inglés, además de nombres largos con texto al 200 %, movimiento reducido, cromos bloqueados y celebración. Se comprobó que la carta presenta el nombre y el acabado en una sola etiqueta de accesibilidad y que se llega al botón inferior al desplazar la pantalla.
- Se midieron cinco arrastres por acabado en un Android físico en modo perfil. Flutter registró los tiempos con `FrameTiming`. El primer gesto sirve de calentamiento y se deja fuera de la tabla. El presupuesto nominal a 120 Hz es de 8,33 ms por fotograma.

| Acabado | Fotogramas medidos tras el calentamiento | Interfaz p95 | Rasterizado p95 | Tiempo total p95 | Fotogramas con alguna etapa por encima de 8,33 ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Latón | 304 | 1,21 ms | 5,65 ms | 7,62 ms | 4 |
| Nácar | 306 | 1,18 ms | 6,13 ms | 8,14 ms | 8 |

La veta del marco usa un degradado repetido. En Latón, el tiempo total p95 pasó de 10,31 a 7,62 ms y los fotogramas con alguna etapa por encima del presupuesto bajaron de 17 a 4 en esta medición.
