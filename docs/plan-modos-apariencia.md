# Plan de modos de apariencia para toda NaturalMente

Fecha: 13 de noviembre de 2026. Base revisada: `d6c17f6` de `main`.
Estado: implementado en la rama `david/modos-apariencia`. Las secciones de diseño conservan la propuesta original; el registro al final describe la implementación y su verificación.

## Resultado esperado

Toda la app ofrece **Claro**, **Oscuro** y **Según el teléfono** desde los ajustes de Natu. La elección se guarda localmente, funciona sin conexión y se mantiene al cerrar y abrir. La opción inicial propuesta es **Según el teléfono**, también al actualizar una instalación que todavía no tenga esta preferencia.

En modo automático, cambiar la apariencia del teléfono actualiza la app abierta y al volver del segundo plano. En Claro u Oscuro, la app mantiene la elección aunque cambie el teléfono. Cambiar la apariencia conserva la ruta abierta, la partida, las respuestas, las preguntas finales pendientes, el progreso y los ajustes independientes de idioma, sonido, música y vibración.

El alcance incluye carga y errores de arranque, mapa, tres zonas, fichas, álbum y cromos, medalla, ajustes, armario, reto diario, laboratorios, inspectores interactivos, los 26 juegos con sus tres niveles, ayudas, animaciones de acierto, resultados, menús, hojas modales, diálogos y mensajes de guardado.

## Punto de partida comprobado

- [`main.dart`](../lib/main.dart) crea un solo `ThemeData` claro. Tiene tres ramas con `MaterialApp`: carga, error y aplicación preparada; las tres deben recibir la apariencia adecuada.
- [`selector_idioma.dart`](../lib/ui/selector_idioma.dart) ya contiene los ajustes de idioma, sonido, música y vibración. Actualmente se monta desde el mapa. Es el punto de entrada para añadir Apariencia.
- [`Idioma`](../lib/idiomas/idioma.dart) guarda esos ajustes con `SharedPreferences` y notifica los cambios. [`Progreso`](../lib/datos/progreso.dart) guarda las partidas y recompensas por separado.
- Hay colores explícitos en casi todos los archivos de `lib/ui`, tanto en widgets como en `CustomPainter`. Añadir solamente `darkTheme` dejaría muchas tarjetas blancas, textos oscuros y fondos claros.
- Los archivos de dibujo también contienen widgets interactivos: especialmente [`dibujos_nuevos_juegos.dart`](../lib/ui/dibujos_nuevos_juegos.dart). No se puede excluir un archivo entero de la migración por llamarse «dibujos».
- Android ya tiene `values-night/styles.xml`, pero el fondo `fondo_natu` solo está definido para claro. El launch storyboard de iOS tiene fondo blanco fijo.

## Decisiones de implementación propuestas

### Preferencia y ciclo de vida

Crear `lib/datos/apariencia.dart` con un controlador `Apariencia`, basado en `ChangeNotifier`, y un `AparienciaScope`. Persistir una única clave `apariencia` con valores estables `sistema`, `claro` y `oscuro`. Una clave ausente o desconocida equivale a `sistema`. No guardar la luminosidad actual del teléfono: debe seguir siendo una elección automática.

Mapear la preferencia a `ThemeMode.system`, `ThemeMode.light` o `ThemeMode.dark`. Mantener este ajuste separado de `Idioma` y `Progreso`, reutilizando el patrón de persistencia existente sin ampliar la clase que sintetiza audio. Ante un guardado fallido, mantener la última elección confirmada, informar en ES/EN y permitir reintentar. Proteger la escritura ante pulsaciones sucesivas para que una operación anterior no sobrescriba la última elección.

Reorganizar el arranque para mantener un único `MaterialApp` estable, con `theme`, `darkTheme` y `themeMode`, y mostrar carga, error o mapa dentro de él. Leer la preferencia antes de presentar la primera pantalla Flutter; los fallos al leerla deben permitir abrir la app siguiendo el sistema. La carga del catálogo y del progreso conserva su tratamiento de error. No crear nuevos `Future`, controladores de progreso, claves de navegación o identidades de rutas al cambiar el tema. Definir la liberación del controlador en el dueño que lo crea.

El selector de apariencia mostrará las tres opciones y marcará la seleccionada, con etiquetas accesibles y traducciones en [`content/en.json`](../content/en.json). Reutilizar los ajustes existentes; comprobar que el menú sigue cabiendo con texto grande. Si necesita desplazamiento, mantener todas sus opciones accesibles en móvil pequeño.

### Temas y colores por función

Crear `lib/ui/tema.dart` con las factorías de tema claro y oscuro. Mantener la identidad verde, naranja y natural de la app, con superficies oscuras de matiz verde y jerarquía visible entre fondo, tarjeta y modal.

Usar `ColorScheme` para las funciones de Material: superficies, texto sobre superficies, acción principal/secundaria, contornos y estados deshabilitados. Configurar también tipografía, barras, botones, menús, hojas modales, diálogos, chips, controles, indicadores, tooltips, divisores y `SnackBar`. Evitar que `TextTheme` vuelva a fijar colores exclusivos del tema claro.

Añadir una `ThemeExtension` llamada `ColoresNaturales` para funciones propias: parejas fondo/texto/borde de acierto y pista, selección, destino de arrastre, tarjeta de zona, semilla y racha. Implementar `copyWith` y `lerp`. Cada color de fondo debe tener su color de contenido definido; cambiar solo el fondo produce combinaciones ilegibles.

Migrar [`EstilosJuego`](../lib/ui/estilos_juego.dart) para obtener los colores del tema en el contexto que lo usa. Mantener constantes los radios y espaciados. Conservar los colores puramente ilustrativos en paletas de ilustración identificadas, con una explicación para los valores que deban permanecer fijos. Evitar condiciones claro/oscuro dispersas por cada widget.

### Ilustraciones, escenas y repintado

Revisar cada uso de color para distinguir interfaz, información científica e ilustración decorativa. Conservar el reconocimiento de animales, órganos, alimentos, plantas, residuos y accesorios de Natu. Mantener diferencias de color que sean parte de una pregunta; acompañarlas de forma, texto o icono cuando corresponda.

Adaptar fondos de escena, marcos, rótulos, leyendas, conectores, resaltados, siluetas interactivas y zonas de colocación. Una escena con iluminación propia, como la linterna nocturna o los rayos X, puede conservarla en ambos temas, pero sus controles y textos deben funcionar dentro de esa escena. Registrar estas excepciones por componente y validar su contraste; una tarjeta blanca genérica no es una excepción artística.

Pasar la paleta necesaria a cada `CustomPainter` desde el widget, sin depender de un `BuildContext` dentro del pintor. Actualizar `shouldRepaint` para detectar cambios de paleta además de cambios de partida. Revisar también gradientes, sombras, transparencias, `TextPainter`, overlays y colores calculados o almacenados fuera de `build`.

### Arranque nativo y barras del sistema

Adaptar el fondo de lanzamiento Android con recursos nocturnos y el de iOS con un recurso de color que tenga variantes clara/oscura. Revisar las configuraciones de splash de las versiones Android soportadas, incluido Android 12 o superior. Ajustar iconos de barra de estado y navegación al fondo real mediante los temas y `SystemUiOverlayStyle`, respetando el comportamiento de pantalla de borde a borde de la versión objetivo.

El splash nativo aparece antes de leer `SharedPreferences`: seguirá inicialmente al sistema. Si se exige que también siga una elección manual distinta del teléfono desde el primer instante del proceso, hará falta persistencia y lectura nativas adicionales en ambas plataformas; no prometer esa capacidad con un ajuste exclusivamente Dart. La primera pantalla Flutter sí debe aplicar la elección guardada sin mostrar antes un tema incorrecto.

## Fases y entregables

Realizar las fases en este orden; cada una deja una parte revisable. La funcionalidad se considera completa cuando se cierra la matriz de cobertura, aunque las primeras fases ya permitan cambiar de tema.

| Fase | Trabajo concreto | Condición de cierre |
| --- | --- | --- |
| 1. Inventario | Registrar cada pantalla, modal, estado y pintor; clasificar colores y excepciones artísticas. Usar el catálogo como fuente de juegos. | Lista de cobertura completa, sin pantallas o interacciones sin asignar. |
| 2. Infraestructura | Controlador, persistencia, temas, extensión de colores, arranque estable y selector ES/EN. | Tres opciones operativas; guardado, errores y actualización automática probados sin reiniciar navegación. |
| 3. Componentes comunes | Migrar estilos, burbujas, tarjetas, precisión, racha, controles, feedback y cierre. | Componentes y estados normal, seleccionado, deshabilitado, pista, acierto y guardado legibles en ambos temas. |
| 4. Navegación y colección | Mapa, zonas, fichas, álbum, cromos, medalla, ajustes y armario. | Todos los accesos y modales revisados en claro y oscuro. |
| 5. Juegos | Migrar `JuegoPage`, pantallas propias, tableros, piezas y preguntas finales. | Los 26 juegos y sus tres niveles completan su recorrido en ambos temas. |
| 6. Escenas y experiencias | Migrar pintores, inspectores, tres laboratorios, evolución de zona y reto diario. | Cambios de tema repintan correctamente y conservan experimentos, selección y límite diario. |
| 7. Integración y revisión | Splash y barras Android/iOS, contraste, texto grande y revisión visual en dispositivos. | Matriz cerrada, pruebas y compilaciones indicadas aprobadas. |

Responsables orientativos según [`organizacion.md`](organizacion.md): David para temas e interfaz, Diego para pruebas y revisión visual, Alejandro para integración Android/iOS y Alfredo para revisar textos ES/EN. Cualquiera puede implementar una fase siguiendo las normas del repositorio.

## Matriz mínima de cobertura

Durante la implementación, convertir cada fila en casos concretos marcados como pendientes o verificados para claro y oscuro. En cada caso registrar el estado revisado, la prueba o captura y cualquier excepción artística. Los nombres siguientes son archivos existentes; los archivos de tema y preferencia indicados antes son propuestas nuevas.

| Área | Archivos principales | Estados que no pueden faltar |
| --- | --- | --- |
| Arranque | `lib/main.dart`, recursos Android/iOS | Primera instalación, preferencia guardada, carga, fallo de lectura y fallo de catálogo/progreso. |
| Ajustes | `lib/ui/selector_idioma.dart`, `content/en.json` | Tres modos, selección actual, error de guardado, menú completo con texto ampliado. |
| Mapa y zonas | `lib/ui/mapa.dart`, `lib/ui/zona.dart` | Tres zonas, resumen de progreso, fichas abiertas, medalla y hojas modales. |
| Colección | `lib/ui/zona.dart`, `lib/ui/cromos_zona.dart` | Álbum general y por zona, filtros, vacío, cromo desbloqueado y pendiente. |
| Componentes | `lib/ui/estilos_juego.dart`, `componentes_juego.dart`, `burbuja.dart`, `juego_propio.dart` | Pistas, rachas, estadísticas, selección de nivel y botones deshabilitados. |
| Finales | `lib/ui/feedback_acierto.dart`, `fin_juego.dart` | Acierto, victoria, guardando, guardado fallido, reintento y todas las acciones. |
| Pantalla compartida | `lib/ui/juego.dart` | Respuestas, arrastre y alternativa por toque, controles, ordenación, selección, pistas y preguntas finales. |
| Pantallas propias | `lib/ui/herbario.dart`, `nacimiento.dart`, `digestion.dart`, `ecosistema.dart`, `rescate.dart`, `memoria.dart`, `adivinanza.dart` | Partida inicial, intermedia, final y repetición; piezas, cartas y tableros. |
| Reto y armario | `lib/ui/expedicion_diaria.dart` | Reto disponible/completado, respuestas, cierre diario, accesorios disponibles/equipados y compra sin semillas suficientes. |
| Laboratorios | `lib/ui/laboratorio_zona.dart` | Reserva, fotosíntesis, rayos X, controles activos/inactivos, leyendas, evolución y recompensas. |
| Dibujos e inspectores | Todos los `lib/ui/dibujos*.dart`, `dibujo_savia.dart`, `planta.dart`, `escena_ecosistema.dart` | Fondos, rótulos, piezas, resaltados, inspector abierto y repintado tras cambiar el tema. |

Inventario del catálogo revisado, para comprobar que ninguna actividad queda fuera:

- Pantalla compartida: `hogar`, `dieta`, `grupos`, `germinacion`, `polinizacion`, `estaciones`, `huerta`, `piezas`, `sentidos`, `vida`, `plantas`, `vivo`, `plato`, `habitos`, `cuidados`, `respiracion`, `savia`, `organos`, `emociones`.
- Pantallas propias: `nacimiento`, `digestion`, `herbario`, `ecosistemas`, `cuida-reserva`, `memoria-plantas`, `quien-soy`.
- Además: expedición diaria, que no forma parte de estas 26 actividades.

## Pruebas y criterios de aceptación

### Automatizadas

- Crear `test/datos/apariencia_test.dart`: valor inicial, tres elecciones, restauración, valor desconocido, escritura fallida y elecciones rápidas. Comprobar que no se alteran las claves existentes de idioma o progreso.
- Crear `test/ui/apariencia_test.dart`: selector traducido, persistencia entre aperturas, modo automático con cambios de brillo del sistema, modos manuales independientes del sistema y cambio con una ruta secundaria abierta. Verificar que una partida empezada conserva respuestas, nivel y preguntas pendientes.
- Probar cambios de tema con un modal abierto, un inspector activo, animación de acierto en curso y guardado pendiente. Ninguno debe duplicar feedback, recompensas ni cierres.
- Parametrizar el arnés de [`cierres_juegos_test.dart`](../test/ui/cierres_juegos_test.dart) con los temas reales claro/oscuro: 26 actividades × 3 niveles × 2 temas. Conservar las comprobaciones de preguntas finales, repetición, selector, navegación, guardado lento y fallo con reintento sin recompensas duplicadas. Cubrir también las restricciones del reto diario.
- Adaptar las pruebas de `FinJuego` y `FeedbackAcierto` a ambos temas. Seguir íntegramente [`feedback-y-cierre.md`](feedback-y-cierre.md) al tocar cualquier juego; preservar el mixin, sus llamadas y el registro inmediato del guardado.
- Añadir pruebas visuales representativas de mapa, zona, ficha, ajustes, tablero, laboratorio, armario y resultado en ambos temas; fijar tamaño y detener animaciones para obtener capturas reproducibles. No reemplazan el recorrido funcional de todos los juegos.
- Comprobar contraste sobre colores compuestos reales: objetivo de al menos 4,5:1 para texto normal y 3:1 para texto grande y elementos de interacción. Cubrir parejas semánticas y revisar manualmente textos sobre escenas y gradientes. No comunicar selección o acierto únicamente mediante color.
- Repetir los casos críticos con ES/EN, texto ampliado, móvil pequeño, horizontal, movimiento reducido y ajustes independientes de audio/vibración. Evitar multiplicar toda la suite por combinaciones sin valor adicional; mantener siempre la cobertura de los 78 niveles en ambos temas.

### Comandos al implementar

```bash
dart analyze --fatal-infos
flutter test test/datos/apariencia_test.dart test/ui/apariencia_test.dart
flutter test test/ui/feedback_acierto_test.dart test/ui/fin_juego_test.dart test/ui/cierres_juegos_test.dart
flutter test
flutter build web
flutter build apk --debug
```

Los dos archivos `apariencia_test.dart` son entregables futuros. Para iOS, compilar en un Mac con Xcode y comprobar arranque y barras; registrar el resultado o la comprobación pendiente. Revisar en teléfono Android e iPhone el cambio del sistema en primer y segundo plano, navegación, teclado, splash y contraste de barras.

### Condición para darlo por terminado

Todas las filas de la matriz están verificadas en ambos temas, incluidos modales y estados transitorios. Los modos manuales prevalecen sobre el teléfono y el automático responde a sus cambios. La preferencia se conserva, los fallos de guardado se explican y ningún cambio de tema reinicia la sesión o duplica recompensas. Los matices originales de interfaz se resuelven mediante las funciones de la extensión de tema; los colores que evitan esa adaptación tienen una función ilustrativa justificada.

Actualizar [`organizacion.md`](organizacion.md) con los nuevos archivos y [`decisiones.md`](decisiones.md) con el comportamiento finalmente implementado, manteniendo la distinción entre esta propuesta y las decisiones ya vigentes.

## Referencias de Flutter

- [`MaterialApp.themeMode`](https://api.flutter.dev/flutter/material/MaterialApp/themeMode.html): selección entre tema claro, oscuro y luminosidad del sistema.
- [`ThemeExtension`](https://api.flutter.dev/flutter/material/ThemeExtension-class.html): colores propios y transición con `copyWith` y `lerp`.
- [`SystemUiOverlayStyle`](https://api.flutter.dev/flutter/services/SystemUiOverlayStyle-class.html): apariencia de las barras del sistema.


## Registro de implementación

- Preferencia y selector ES/EN implementados, con escritura serializada, reintento tras fallo y modo automático inicial.
- Un único `MaterialApp` con temas claro/oscuro, actualización por sistema, barras adaptables y transición que respeta el movimiento reducido.
- Migradas las superficies, textos, bordes, sombras y gradientes de pantallas, componentes compartidos e interfaces interactivas. `ColoresNaturales` mantiene los matices originales como entrada y centraliza su adaptación por función; no se aplican filtros de inversión sobre la app ni sobre dibujos.
- Adaptados los fondos de herbario, savia y ecosistema, la caja del inspector y las etiquetas del reactor. Sus pintores reciben la paleta y la incluyen en `shouldRepaint`.
- Conservadas como ilustración las paletas de Natu, fauna, órganos, alimentos y plantas; los cielos y suelos de los simuladores que enseñan iluminación o condiciones ambientales siguen el experimento. La escena de rayos X conserva su iluminación propia y el check común conserva su verde. Sus controles, leyendas externas y contenedores sí siguen el tema.
- Recursos nocturnos Android, splash de Android 12+ y color adaptable del launch storyboard iOS. El splash sigue al sistema; la elección manual se aplica al entrar en Flutter.
- Ajustes con desplazamiento y texto adaptable, comprobados a 360 × 640 con texto al 150 %. Corregidos el desbordamiento de leyendas del reactor y el `Material` del interruptor de savia, detectados al ampliar el recorrido.
- Pruebas nuevas de persistencia, fallos, pulsaciones rápidas, contraste, seguimiento del teléfono, selector traducido, partida y modal abiertos, simulación conservada y 16 capturas de referencia de las superficies principales, con estados fijos para evitar que el barajado de respuestas altere las imágenes. Los cierres cubren 26 actividades × 3 niveles × 2 temas, además del reto diario. El resultado se prueba también cambiando de tema durante la victoria y un guardado fallido, sin duplicar recompensas.

La revisión física de sonido/vibración y las barras/splash en Android e iPhone sigue siendo una comprobación de dispositivo. La compilación y ejecución iOS requieren un Mac con Xcode; no se han ejecutado en este equipo Linux.

### Comprobaciones ejecutadas

En Linux, con Flutter 3.47.9 y Dart 3.13.7:

- `dart analyze --fatal-infos`: sin incidencias.
- `flutter test --no-pub`: **241 pruebas aprobadas**, incluidas las 16 comparaciones visuales con sus referencias y los recorridos de cierre en ambos temas.
- `flutter build web --no-pub`: compilación correcta.
- `flutter build apk --debug --no-pub`: compilación correcta, incluidos los recursos de lanzamiento claros/oscuros de Android 12+.
- `git diff --check`, enlaces internos y sintaxis XML/JSON de los recursos añadidos: correctos.

No se ha compilado iOS ni se ha realizado una revisión en dispositivos físicos en este equipo. Esas comprobaciones siguen pendientes; las pruebas de widgets no validan la apariencia de las barras nativas ni la respuesta física de sonido y vibración.


### Revisión del panel de ajustes

El selector inicial se sustituye por un diálogo persistente, con cabecera de Natu, cierre y acción Listo. Los modos claro/oscuro/automático se presentan en una fila de tres botones con iconos, tamaño uniforme y check de selección. El idioma usa dos botones y los ajustes de sonido, música y vibración conservan controles independientes. Cambiar cualquier opción mantiene el panel y su estado; el idioma y el tema se actualizan también dentro de él.

Se revisan el espaciado, las áreas táctiles, el foco, las etiquetas accesibles, la pulsación y la entrada del panel. Las animaciones respetan el movimiento reducido. El contenido se desplaza cuando no cabe, y los errores de persistencia se presentan dentro del panel. Se añaden referencias visuales en claro y con texto ampliado, además de las existentes en oscuro.

Comprobación tras esta revisión: `dart analyze --fatal-infos` sin incidencias; `flutter test --no-pub` con **243 pruebas aprobadas** y **19 capturas de referencia**; `flutter build apk --debug --no-pub` correcto. Se verifican cambios consecutivos sin cerrar el panel, selección accesible, alineación de botones, controles independientes, preferencia conservada al reabrir, avisos visibles de guardado fallido y cierre mediante Listo, X, atrás o fuera del diálogo. La revisión visual adicional del panel se ha realizado con fuentes reales en claro y oscuro.
