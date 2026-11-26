# Plan de fin de partida y álbum de cromos

Estado: propuesta para revisar. El cierre común de los juegos celebra el nivel, ofrece un siguiente paso claro y enlaza con una sección nueva para los cromos recién conseguidos. El álbum pasa a organizarse por mundos. La carta dorada se comparte entre la celebración y el detalle del álbum.

## Referencias visuales

| Pantalla | Boceto elegido | Qué trasladar a Flutter |
| --- | --- | --- |
| Fin de partida | Fin de partida 3, «Elige tu siguiente paso» | Natu saludando, «¡Nivel superado!», nombre del nivel y tres tarjetas ilustradas con borde y relieve. |
| Cromo en grande | Fin de partida 2, «¡Nuevo cromo!» | Carta vertical con marco dorado, papel crema, arte grande, nombre legible y destellos discretos. |
| Portada del álbum | Mis cromos 1, «Un álbum por mundos» | Libro abierto con tres secciones ilustradas, colores por mundo y un contador por sección. |

## Fin de partida

1. Mantener la victoria automática al completar el nivel, incluidas sus preguntas finales. En la pantalla de resultado, mostrar a Natu, «¡Nivel superado!» y el nivel completado. Dejar el resumen de estrellas, semillas y otros detalles disponible en una sección breve y secundaria.
2. Usar tres tarjetas grandes como en el boceto: «Probar el siguiente nivel» con el nombre de destino, «Jugar otra vez» y «Volver al mundo». Al pulsar la primera se inicia directamente el nivel indicado mediante la lógica de inicio existente. Un enlace discreto «Elegir nivel» abre el selector completo. Si no hay un nivel superior disponible, «Elegir nivel» pasa a ocupar la primera tarjeta.
3. Tras confirmar el guardado, mostrar «Ver tu nuevo cromo» con una miniatura si se ha desbloqueado uno. Para varios, mostrar «Ver tus nuevos cromos» con dos cartas en abanico. Las miniaturas usan las ilustraciones y acabados de los cromos obtenidos. El botón abre la celebración con todos ellos. La pantalla de resultado pasa directamente a las acciones tras guardar y muestra avisos durante la espera o si se necesita reintentar. En el reto diario se conservan sus acciones de vuelta al mapa y armario.
4. Usar [FinJuego y DatosFinJuego](../lib/ui/fin_juego.dart) para todas las variantes. Ampliar los datos compartidos para identificar el siguiente nivel disponible y los cromos nuevos. No deducir el destino a partir del texto traducido. [FeedbackAcierto](../lib/ui/feedback_acierto.dart) sigue coordinando victoria, guardado y ejecución de acciones.

## Celebración y carta dorada

- **Recompensa recién conseguida.** Mostrar a Natu y la banda «¡Nuevo cromo!» encima del marco dorado. La ilustración ocupa la mayor parte de la carta y el nombre queda debajo. Si llegan varios cromos, mostrar uno cada vez con botones anterior y siguiente, y un indicador «1 de 3». «Ver en mi álbum» abre el mundo correspondiente y resalta la carta. Atrás devuelve al resultado.
- **Consulta desde el álbum.** Reutilizar la misma carta a pantalla completa, con el mismo marco, escala y textura. En lugar de anunciar una recompensa nueva, mostrar «Cromo conseguido» y permitir abrir «Sobre este cromo» para leer la ficha educativa actual. Atrás restaura el lugar del álbum desde el que se abrió.
- **Cromo pendiente.** Mantener el marco y mostrar una silueta o la presentación bloqueada que corresponda, con «Por descubrir» y una pista de cómo conseguirlo. Ofrecer «Ir al juego» solo cuando haya una actividad y un destino válidos en los datos. El texto de la ficha y las condiciones de desbloqueo se toman del catálogo y del progreso.
- **Artes y tipografía.** Crear un marco, banda y destellos comunes, y adaptar todas las ilustraciones del catálogo al mismo encuadre. Reutilizar el arte de cada especie, planta u órgano siempre que se lea bien en grande y en miniatura. Revisar los motivos de cada cromo con el catálogo antes de sustituir ningún dibujo. Mantener nombre, estado y botones como texto e interfaz reales.

## Álbum por mundos

1. «Mis cromos» abre un libro con tres secciones, **Animales**, **Plantas** y **Mi cuerpo**, con colores propios, ilustraciones representativas y el número real de cromos conseguidos en cada mundo. Las ilustraciones de portada identifican el mundo y no se presentan como cromos ya obtenidos.
2. Tocar una sección abre la cuadrícula de ese mundo. Los cromos conseguidos van primero y los pendientes quedan accesibles bajo «Por descubrir». Si un mundo está vacío, se muestra una pista y una actividad válida para empezar. Cada tarjeta abre su carta dorada.
3. El acceso a los cromos desde Explorar dentro de un mundo y «Ver en mi álbum» desde una celebración llevan a la misma cuadrícula. Reorganizar [AlbumPage y el detalle de ficha](../lib/ui/zona.dart) y [CromosZonaPage](../lib/ui/cromos_zona.dart) alrededor de una sola presentación, con el catálogo, las reglas y el progreso existentes.

## Guardado y movimiento

- Identificar las fichas que pertenecen a la partida e incluir tanto las que se descubren durante ella como las que se desbloquean al completar el nivel. Distinguir fichas previamente obtenidas, desbloqueos de otras partidas y desbloqueos indirectos, como los de niveles inferiores. Revisar las rutas de [Progreso](../lib/datos/progreso.dart) antes de registrar esas fichas y conservar una lista estable de identificadores sin repetidos por resultado.
- Mostrar la celebración solo cuando se confirme el guardado del cierre. El reintento escribe los datos ya aceptados. Si hubo una escritura parcial, conserva la misma lista de cromos pendientes de mostrar y evita una segunda recompensa. Si se cierra la app tras guardar, los cromos seguirán en el álbum al volver.
- El resultado aparece con un desvanecimiento breve. Al abrir una carta desde la cuadrícula, la miniatura se amplía hasta su posición final en unos 220 ms y el fondo se atenúa. En la celebración, los destellos aparecen una sola vez. El movimiento reducido usa la misma composición sin desplazamientos, escala ni destellos animados. Respetar los ajustes independientes de sonido y vibración y reutilizar el feedback común.

## Orden de implementación y comprobación

1. Probar el fin de partida con **Cada uno a su hogar** y el cromo del camello como primer caso visual. Comparar la captura del cierre y de la carta con los dos mocks en un móvil de referencia de 390 × 844.
2. Integrar el marco compartido y la portada del álbum, revisar una carta de cada mundo y un estado pendiente, y extenderlo a todas las fichas. Comprobar 360 × 700, claro y oscuro, ES y EN, texto ampliado, lectura con tecnología de asistencia y movimiento reducido.
3. Cubrir nivel siguiente, último nivel, repetición, retorno al mundo, ningún cromo nuevo, uno y varios, guardado lento, fallo y reintento. Verificar que cerrar la celebración conserva el progreso y que tocar un cromo antiguo no vuelve a celebrarlo.
4. Actualizar los recorridos de [cierres de juegos](../test/ui/cierres_juegos_test.dart) y [cromos por zona](../test/ui/cromos_zona_test.dart). Ejecutar las comprobaciones de la [guía de feedback y cierre](feedback-y-cierre.md), incluidas las del reto diario, antes de aprobar la integración.
