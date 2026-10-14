# Plan de implementación: Herbario desmontable

Fecha: 14 de octubre de 2026. Estado: implementado y verificado; pendiente de revisión del equipo y prueba en dispositivos reales.

Este plan desarrolla el juego MVP descrito en `docs/juegos.md`. Los niveles siguen `docs/decisiones.md`. No depende del reparto de roles: una persona puede completar la tarea y pedir revisión al equipo.

## Resultado esperado

Desde El invernadero se abre «Herbario desmontable», se elige Fácil, Medio o Difícil y se colocan partes de una planta sobre una ilustración. Se puede responder arrastrando o seleccionando una pieza y tocando su destino. Los fallos explican dónde va la parte y permiten seguir intentándolo. Una parte colocada se puede tocar para consultar su función y una curiosidad.

| Nivel | Actividad | Condición para completarlo |
| --- | --- | --- |
| Fácil, 1º–2º | Raíz, tallo y hoja, con piezas dibujadas y nombres. | Colocar las tres partes. |
| Medio, 3º–4º | Raíz, tallo, hoja, flor y fruto, con piezas dibujadas y nombres. | Colocar las cinco partes. |
| Difícil, 5º–6º | Colocar los cinco rótulos y responder preguntas de función. | Colocar los cinco rótulos y acertar una pregunta por parte. |

Propuesta para acotar la entrega: una ilustración esquemática de planta con flor y fruto, sin tiempo límite ni sonido. La lectura en voz alta prevista para Fácil se mantiene como pendiente general del producto; este juego no resolverá por sí solo toda la infraestructura de audio.

## Recorrido y comportamiento

1. Entrar desde el botón del juego en El invernadero.
2. Elegir dificultad; ninguna está bloqueada. Mostrar las partes y el curso orientativo de cada nivel.
3. Ver la planta, las piezas pendientes y el contador de partes colocadas.
4. Arrastrar una pieza o seleccionarla y tocar una zona. Ambos caminos usan la misma validación.
5. Si no encaja, mantener la pieza disponible y mostrar una explicación. Desde el segundo fallo de esa pieza, añadir una pista.
6. Si encaja, fijar la pieza en su zona y permitir abrir su ficha. En Fácil y Medio, esta ficha enseña función y curiosidad.
7. En Difícil, tras colocar los rótulos, preguntar la función de cada parte con tres opciones. Mostrar la explicación completa de cada función al acertarla, sin adelantar la respuesta en la ficha durante ese reto.
8. Al terminar, guardar el nivel superado y mostrar «Otra vez», «Cambiar nivel» y «Volver al invernadero».

Salir a mitad no registra el nivel como completado. La partida en curso se mantiene solo mientras la pantalla siga abierta; al volver a entrar empieza de nuevo. Una dificultad completada puede repetirse desde el principio.

## Fase 1. Contenido y contrato del catálogo

- Añadir la actividad `herbario` en la zona `invernadero`, con tipo nuevo `herbario` y `medalla: false`. La medalla mantiene los tres juegos actuales.
- Añadir contenido propio para las cinco partes: nombre, función, curiosidad, pista y frases por destino. Revisar que flor y fruto tengan destinos visuales distintos y fáciles de tocar.
- Añadir variantes identificadas por `facil`, `medio` y `dificil`. Cada una declara el curso, las partes que participan y sus retos; Difícil añade las preguntas de función.
- Reutilizar `Reto` y `Opcion` para colocación donde encajen. Añadir un modelo específico en `lib/modelo/herbario.dart` para partes, variantes y preguntas de función; evitar cargar los juegos existentes con campos obligatorios que no usan.
- Extender `Actividad` con configuración opcional de herbario, obligatoria solo para el nuevo tipo. Actualizar el lector y la validación antes de introducir la nueva actividad en el JSON: ahora un tipo desconocido impide abrir todo el catálogo.
- Validar niveles, identificadores únicos, destinos y referencias a partes, respuestas existentes y explicaciones. Mantener la carga del catálogo actual sin cambios en su comportamiento.
- Completar las filas de cobertura correspondientes y añadir fichas de tallo, flor y fruto; revisar las existentes de raíz y hoja para mantener textos coherentes.

Entrega verificable: el catálogo acepta el juego nuevo y sigue aceptando los cuatro anteriores.

## Fase 2. Reglas y estado

- Reutilizar `resolverLugar` para comprobar pieza y destino y añadir la pista por intento. Sus reglas no dependen de animales y ya trabajan con `Reto`.
- Añadir una regla sin widgets para las preguntas de función y otra para determinar si el nivel está completo.
- Separar el estado de la partida de la ilustración: nivel elegido, pieza seleccionada, partes colocadas, intentos por parte, pregunta actual, funciones acertadas y último mensaje.
- Ignorar acciones sobre piezas ya colocadas y entradas ajenas al nivel activo; no permitir que sumen progreso.
- Reiniciar todo el estado de partida al repetir o cambiar de nivel, conservando el historial de niveles superados.

Entrega verificable: los fallos permiten reintentar y Difícil requiere también las preguntas de función.

## Fase 3. Pantalla y dibujo

- Crear `lib/ui/herbario.dart` con el selector inicial y la pantalla del juego; abrirla desde `ZonaPage` solo para el nuevo tipo.
- Mantener `JuegoPage` para los tres tipos actuales. Su rama por defecto interpreta actividades como ordenación, por lo que no debe recibir el herbario sin un tratamiento explícito.
- Dibujar la planta con formas y trazados propios en Flutter. Una ilustración nativa evita depender de recursos externos y se adapta al tamaño disponible.
- Implementar la ilustración y los destinos como componente separado, por ejemplo `lib/ui/planta.dart`, con posiciones relativas al área de dibujo.
- Dar a cada destino un área táctil de al menos 48 píxeles lógicos. Si el dibujo se reduce, conservar un tamaño mínimo con desplazamiento antes de solapar zonas.
- En Fácil, mostrar solo los tres destinos activos; flor y fruto pueden quedar como contexto visual, sin funcionar como respuestas.
- Permitir arrastre y selección por toque, con indicación visible de la pieza seleccionada y opción de cambiarla.
- Mostrar acierto, selección y progreso mediante texto y formas además del color. Añadir etiquetas semánticas a piezas y destinos.
- Usar la burbuja de explicación existente. Abrir las fichas de partes colocadas en un panel que se pueda cerrar sin perder la partida.
- Adaptar composición a móvil y tablet, orientación horizontal y texto ampliado, evitando que las explicaciones oculten las piezas.

Entrega verificable: completar Fácil mediante toques y Medio mediante arrastre en una pantalla pequeña, sin desbordamientos.

## Fase 4. Progreso e integración

- Extender `Progreso` con métodos para consultar y marcar un nivel de herbario. Usar claves nuevas como `herbario/facil/completo`, dentro del almacenamiento actual, conservando todas las claves existentes.
- Marcar `herbario` como actividad completada al superar cualquier nivel. Guardar también qué niveles se han completado para mostrarlos en el selector.
- Persistir al terminar el nivel, no al abrirlo ni al colocar solo una parte.
- Mostrar el estado de herbario en el botón de la zona y en el selector; escuchar los cambios de progreso donde sea necesario.
- Confirmar que completar herbario no obtiene ni bloquea la medalla existente.

Entrega verificable: cerrar y abrir la app conserva los niveles superados y los progresos anteriores.

## Fase 5. Verificación y documentación

Pruebas automatizadas necesarias:

- Catálogo: aceptar las tres variantes, detectar referencias rotas y seguir cargando las actividades anteriores.
- Reglas: un destino equivocado, pista en el segundo fallo, pregunta de función equivocada y condición de finalización en los tres niveles.
- Progreso: conservar datos anteriores, recuperar niveles superados y mantener el requisito actual de la medalla.
- Interfaz: selector, colocación por toque, una colocación por arrastre, consulta de ficha, fallo y reintento, finalización y reinicio. En Difícil, comprobar que colocar todas las partes aún no completa el nivel.

Ejecutar `flutter analyze` y `flutter test`. Revisar manualmente en Chrome y en un Android real: legibilidad, zonas de arrastre, volver atrás, tamaño de texto ampliado y orientación horizontal. Si Flutter no está disponible, registrar las verificaciones pendientes sin darlas por superadas.

Actualizar el estado real del juego en README y en la organización, y ajustar `docs/juegos.md` con el comportamiento finalmente entregado. Los cambios de alcance general deben registrarse en decisiones con fecha.

## Orden de trabajo y tareas para PR

| Orden | Tarea | Dependencia |
| --- | --- | --- |
| 1 | Modelos, validación y contenido de herbario. | Ninguna. |
| 2 | Reglas y estado de partida. | Contrato de datos de la tarea 1. |
| 3 | Pantalla, dibujo y recorrido Fácil. | Tareas 1 y 2. |
| 4 | Medio, Difícil y preguntas de función. | Recorrido Fácil funcional. |
| 5 | Persistencia, indicadores y repetición. | Condiciones de finalización de los tres niveles. |
| 6 | Verificación en dispositivos y documentación. | Integración completa. |

Estimación orientativa para una persona: entre 4 y 6 jornadas de trabajo efectivo, según el acabado del dibujo y los ajustes de interacción. Entregar Fácil primero como incremento jugable; terminar la tarea con los tres niveles. Los roles del repositorio sirven para coordinar revisiones, no como restricción de quién implementa.

## Criterios de aceptación final

- [x] Aparece en El invernadero y los tres niveles se pueden elegir libremente.
- [x] Fácil tiene tres partes; Medio y Difícil tienen cinco.
- [x] Todas las colocaciones se pueden hacer con arrastre y con toques.
- [x] Cada fallo explica qué pasa y permite continuar; la segunda equivocación de una pieza añade pista.
- [x] Las partes colocadas permiten consultar su contenido sin perder la partida.
- [x] Difícil necesita acertar las funciones además de colocar los rótulos.
- [x] La finalización persiste por nivel y se puede repetir desde cero.
- [x] Los juegos existentes, el progreso anterior y la medalla conservan su comportamiento.
- [x] La interfaz funciona con texto ampliado y en las pantallas revisadas.
- [x] Análisis, pruebas y revisión de las capturas del navegador realizados.
- [ ] Revisión en Android real e iOS antes de integrar y publicar.
- [x] Documentación y cobertura actualizadas; textos y dibujo propios.


## Validación de la implementación

Comprobado con Flutter 3.47.7 y Dart 3.13.5:

- `flutter analyze`: sin incidencias.
- `flutter test`: 23 pruebas superadas, incluidas las de las actividades anteriores.
- `flutter build web --no-web-resources-cdn`: compilación correcta.
- Recorrido en Chromium: completar los tres niveles, equivocarse, obtener la segunda pista y recuperar el nivel superado al recargar. Sin excepciones de JavaScript.
- Capturas revisadas en móvil de 390 × 844 y tablet de 1024 × 768.
- Pruebas de widgets en 320 × 568, 700 × 360 y 1024 × 768 con texto al doble de tamaño, incluida apertura de fichas, sin desbordamientos.

Se han incorporado los cambios de `main` que añaden Brote y la integración continua. Las burbujas del herbario usan sus gestos de acierto y pista.

Pendientes: revisión del equipo, comprobación en Android real e iOS y lectura en voz alta de Fácil como trabajo general del producto. No había dispositivos Android conectados durante esta implementación. El SDK y las herramientas de navegador se prepararon fuera del repositorio; no se añadieron dependencias nuevas a la app.
