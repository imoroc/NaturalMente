# Plan: Aula (juegos del profesor), panel web, perfiles, progreso en la nube y ranking

## Contexto

El cliente es un único profesor. Quiere crear tests y minijuegos a partir de plantillas, sin tocar código, desde una web con usuario y contraseña. Quiere poder elegir fondos e imágenes y asignar cada juego a un curso. Los niños los juegan en una sección nueva de la app, **Aula**, donde solo aparece lo que el profesor publicó para el curso elegido.

Además queremos:

- progreso en la nube, para cambiar de dispositivo y para que varios niños compartan uno;
- un ranking que no sature la app;
- que la app siga abierta a cualquiera, sea del colegio o no.

**Situación actual:**

- La app es 100 % local: todo va en SharedPreferences dentro de `Progreso` ([lib/datos/progreso.dart](lib/datos/progreso.dart)), el contenido sale de `content/catalog.json` y no hay código de red.
- El curso (1º-6º) ya existe en `Progreso.curso` / `perfil/curso`, y se elige con `mostrarSelectorCurso` ([lib/ui/selector_idioma.dart](lib/ui/selector_idioma.dart)).
- La documentación dice "sin servidor ni cuentas" ([docs/contexto.md](docs/contexto.md)).

**Nueva decisión:** la app sigue funcionando sin conexión y la nube es opcional. Los niños no tienen cuentas ni dan datos personales.

## Enfoque (lo que verá cada uno)

**Profesor (web):**

- **Puede entrar con lo que le resulte más cómodo:**
  - **nombre de usuario** (p. ej. `profe.luis`);
  - **correo**;
  - **"Entrar con Microsoft"**, con su cuenta Educacyl, o **"Entrar con Google"**, en un clic.
- **La contraseña se la damos nosotros:**
  - Se genera para que sea fácil de recordar y a la vez robusta: 4 palabras de naturaleza y un número, p. ej. `pino-nube-zorro-rio-27` (unos 35 bits: con el límite de intentos de Supabase, adivinarla probando llevaría miles de años).
  - No hay pantalla para cambiarla. Si la olvida, se la regeneramos con un script de administración.
- **Casi nunca tendrá que escribirla:** la sesión se queda abierta en su navegador y hay un botón "Mostrar contraseña" al escribirla.
- **Seguridad:**
  - No hay registro abierto: su cuenta la creamos nosotros.
  - Supabase limita los intentos de login.
  - El CAPTCHA de Supabase se activa solo si vemos abusos.
- **Cómo funciona el nombre de usuario por dentro:** Supabase Auth necesita un correo, así que el usuario se guarda internamente como `profe.luis@profes.naturalmente.app`. El panel acepta las dos formas, nombre de usuario o correo, y las traduce.
- Crea un juego en 3 pasos:
  1. Elige plantilla.
  2. Rellena el contenido, con vista previa en vivo idéntica a la app.
  3. Lo publica para uno o varios cursos.
- No gestiona alumnos, clases ni códigos.

**Niño (app):**

1. Abre la app. Funciona igual que hoy, sin cuenta.
2. En el inicio aparece **"¿Quién juega?"**, con la **Natu de cada niño** vestida como la tenga. Si es nuevo, pulsa "+":
   - elige el **color de su Natu** (unos 8 tonos), para distinguirla de las demás desde el primer día;
   - la app le propone un **mote generado** ("Zorro Veloz", "Pino Sabio"…), que puede regenerar.

   **Avatar = mascota:** no hay un avatar aparte. Cada perfil tiene su propia Natu, y su color, trajes, pose, semillas y armario son de ese perfil.
   - Lo que ya existe (armario, trajes por logro, poses) se convierte en la forma de personalizar el perfil.
   - Esa misma Natu aparece en "¿Quién juega?", en la cabecera del inicio y en el ranking.
   - El color hay que añadirlo como parámetro a `DibujoMascota`.
3. Pulsa **Aula** y ve los juegos que el profesor publicó para su curso. El curso es el que ya eligió en la app y se puede cambiar como ahora.
4. **Para jugar en otro dispositivo**, su perfil tiene una **llave mágica**: 3 dibujos y un número (🦊🌲☁️ 7). Al introducirla en otra tablet o en casa se recupera todo su progreso.
5. **Opcional:** "Guardar con la cuenta de papá o mamá" (Google, Apple o Microsoft), detrás de una puerta parental. Sirve para no depender de recordar la llave.

**Por qué es así:**

- **Los motes son generados y no libres.** Así no hay nombres reales ni palabrotas, ni nada que moderar en el ranking.
- **La llave sustituye a correo y contraseña.** No hay que recuperar nada, y si se pierde solo se pierde la sincronización, porque el progreso local sigue.
- **Riesgos de la llave y cómo los cubrimos:**
  - **Fuerza bruta.** 3 dibujos de 16 y un número de 0 a 99 dan unas 400.000 combinaciones, que solas serían pocas. Por eso:
    - se canjea con **mote + llave**: hay que acertar ambas para un niño concreto;
    - la Edge Function limita a 5 intentos por hora por dispositivo e IP;
    - la llave se genera en el servidor y es única.
  - **Olvido.** La llave se puede ver siempre en "Mi perfil", con un botón para enseñarla en grande y que los padres le hagan una foto.
  - **Si alguien la conoce,** "Cambiar llave" genera otra y desvincula los demás dispositivos.
  - **Qué se arriesga:** solo progreso de juego, sin datos personales.
  - **Varios niños con el mismo mote:** no es un problema, porque se distinguen por la llave y el color de Natu.
- **Público ajeno al colegio.** Juega igual a todos los minijuegos y, si elige curso, ve también los juegos del profesor. Es contenido educativo, así que no hay problema.
- **Si en el futuro hay más profesores,** se añade un código de clase opcional. El modelo de datos ya trae `profesor_id` y `clase_id` (nullable), así que no hay que migrar nada.

## Arquitectura

- **Backend: Supabase**, en la región UE (Frankfurt):
  - Postgres con RLS.
  - Auth: el profesor con usuario o correo y contraseña, o con Microsoft o Google; cada dispositivo con una sesión anónima invisible, y OAuth opcional para los padres.
  - Storage para las imágenes.
  - Edge Function para canjear la llave mágica.
- **Panel del profesor: Flutter Web en el mismo paquete**, con un segundo punto de entrada `lib/main_panel.dart` (`flutter build web -t lib/main_panel.dart`).
  - Comparte modelos, validación y **los mismos widgets de juego**, así que la vista previa es exacta.
  - Se aloja gratis en Cloudflare Pages o Vercel.
- **Configuración** con `--dart-define=SUPABASE_URL/SUPABASE_ANON_KEY`. La clave anónima es pública y lo que protege los datos es la RLS.
- **Carpeta `supabase/`** en el repo, con `migrations/*.sql`, `seed.sql`, `tests/*.sql` (pgTAP) y `functions/`.
- **Dependencias:**
  - `supabase_flutter`.
  - `file_picker` e `image`, para comprimir en el panel.
  - Una caché de imágenes de red.
- **Android:** permiso `INTERNET` en el manifiesto principal.

### Modelo de datos (resumen)
- `profesores(id = auth.uid, usuario único, nombre)`, que se crean con el script `supabase/scripts/crear_profesor` (genera la contraseña de palabras).
- `perfiles(id, mote, color_natu, curso, llave_hash, familia_id?, clase_id? (futuro), creado)`. Trajes y pose viajan en el progreso sincronizado.
- `dispositivo_perfil(dispositivo_id = auth.uid anónimo, perfil_id)`: un dispositivo solo ve y escribe los perfiles que tiene vinculados.
- `juegos(id, profesor_id, titulo, plantilla, version, cursos int[], contenido jsonb, tema jsonb, estado borrador|publicado, disponible_desde/hasta)`
- `resultados(perfil_id, juego_id, version, aciertos, total, puntos, respuestas jsonb, creado)`
- `progreso_perfil(perfil_id, hechos text[], estado jsonb, actualizado)` y `contadores_dispositivo(perfil_id, dispositivo_id, ganadas, gastadas)`
- **Filtrado por curso en la RLS:** solo los juegos `publicado` cuyo `cursos` contenga el curso pedido. Los borradores nunca salen del panel.

### Sincronización sin conflictos
Se puede jugar sin conexión en varios dispositivos sin perder ni duplicar nada:

- `hechos`, cromos, trajes y días de racha: **unión**.
- Semillas: cada dispositivo lleva sus propios totales de ganadas y gastadas, que solo crecen. El saldo es Σganadas − Σgastadas.
- `mejor-combo`: el **máximo**.
- Traje y pose equipados: **gana el último cambio**.
- La fusión vive en dos sitios:
  - una función Dart pura, con tests;
  - el RPC `fusionar_progreso`.
- `Progreso` pasa a leer a través de un `AlmacenPerfil` que antepone `perfil/<id>/`. El primer perfil sigue usando las claves actuales, así que el progreso existente no se migra.

## Plantillas del editor

Todas usan `FeedbackAcierto`, `DatosFinJuego` y `FinJuego` ([lib/ui/feedback_acierto.dart](lib/ui/feedback_acierto.dart), [lib/ui/fin_juego.dart](lib/ui/fin_juego.dart)) y reutilizan las mecánicas que ya existen:

1. **Test de opción múltiple**, con texto o imagen y una explicación. Base: `PreguntaExtra` y la pantalla del reto diario ([lib/ui/expedicion_diaria.dart](lib/ui/expedicion_diaria.dart)).
2. **Verdadero o falso.**
3. **Clasificar en grupos** (2-4 cajas). Base: la mecánica `lugar` de [lib/ui/juego.dart](lib/ui/juego.dart).
4. **Ordenar pasos.** Base: `orden`.
5. **Parejas.** Base: `MemoriaPage` / `JuegoPropio` ([lib/ui/juego_propio.dart](lib/ui/juego_propio.dart)).
6. Más adelante: **adivinanza por pistas** y **señalar en una imagen**.

**Opciones para el profesor:**

- **Fondo:** de una galería que ya viene con la app (los 29 de `assets/mundos` y los 8 de `assets/inicio`), sin gastar cuota, o una imagen subida.
- Color, si aparece o no Natu, y una pista por pregunta.

**Ayudas en el editor:**

- Autoguardado.
- Duplicar un juego.
- "Empezar desde el catálogo", que copia preguntas que ya tiene la app.

**Cómo se guarda:**

- El contenido es JSON con versión, y el mismo código Dart lo valida en el panel y en la app.

**Imágenes subidas:**

- El navegador las comprime a WebP de 1600 px como máximo, unos 150 KB.
- La app las guarda en caché.
- La cuota gratuita (1 GB, unas 6.000 imágenes) sobra para un profesor.
- Si algún día no basta, se pasa a Cloudflare R2.

## En la app

- **Inicio** ([lib/ui/mapa.dart](lib/ui/mapa.dart)):
  - una única tarjeta nueva, **Aula**;
  - el avatar del perfil en la cabecera, junto a `_AccesoCurso` y `_AccesoRacha`. Al pulsarlo se abre "¿Quién juega?", la llave mágica y la cuenta familiar.
- **Aula** (`lib/ui/aula/`):
  - la lista de juegos del curso, con su estado: nuevo, hecho y puntuación;
  - la pestaña de ranking.
- **Sin conexión:**
  - los juegos ya descargados se pueden jugar;
  - el resultado se guarda en local y entra en una cola de envío (outbox).
- **Guardado al terminar:** el callback de `registrarGuardadoFinal` guarda en local, encola el envío y devuelve `true`. Cumple el contrato de [AGENTS.md](AGENTS.md).
- **Semillas:** solo la **primera vez** que se completa cada juego (y versión), para que no se puedan acumular repitiendo.
- **Textos:** los nuevos de la interfaz van a `content/en.json`. Los textos del profesor se muestran tal cual.

## Ranking

- **Por curso**, con dos pestañas: **"Esta semana"** (se reinicia los lunes) y **"Siempre"**.
- Muestra el mote y la Natu vestida de cada niño, el **top 10 + tu posición**, y vive **dentro de Aula**, así que no carga el inicio.
- **Puntúa solo los juegos de Aula:** el mejor intento de cada juego más un pequeño extra por participar. No entra el progreso general de la app.
- **El profesor puede desactivarlo** desde el panel.
- **Comprobación en el servidor:** `aciertos ≤ total`.
- **Para el profesor**, un panel de resultados con el % de aciertos por pregunta y los juegos más y menos jugados.

## Privacidad (antes de tiendas)
- **Documentación:** nueva entrada fechada en [docs/decisiones.md](docs/decisiones.md) y actualizar `contexto.md`, `README.md` y `organizacion.md`.
- **Política de privacidad:**
  - del niño solo se guardan el mote generado, el avatar y el curso;
  - los datos se guardan en la UE;
  - borrar un perfil lo borra todo;
  - no hay analítica de terceros.
- **Tiendas:**
  - puerta parental antes del login de los padres y de enlaces externos;
  - Data Safety y etiquetas de privacidad de Apple;
  - "Iniciar sesión con Apple" si se ofrece login social en iOS.
- **Supabase gratis se pausa tras 7 días sin uso:** cron diario en GitHub Actions y volcado semanal cifrado, porque el plan gratis no hace copias.

## Fases (cada una publicable por separado)
1. **Cimientos:** decisión y privacidad, proyecto de Supabase con migraciones y pgTAP, y CI.
2. **Perfiles locales:** "¿Quién juega?", motes generados y `AlmacenPerfil`. Sin red; ya resuelve el dispositivo compartido.
3. **Panel MVP y Aula:**
   - login del profesor;
   - plantillas de opción múltiple y verdadero/falso con fondos de la galería;
   - publicar por curso;
   - Aula en la app con outbox y resultados.
4. **Progreso en la nube:** sesión anónima por dispositivo, llave mágica y `fusionar_progreso`.
5. **Más plantillas, subida de imágenes y panel de resultados.**
6. **Ranking por curso.**
7. **Opcionales:**
   - cuenta familiar con OAuth;
   - código de clase si llegan más profesores;
   - modo en directo tipo Kahoot (Realtime);
   - generar preguntas con IA a partir de un texto, siempre revisadas por el profesor.

## Archivos críticos
- **Se modifican:**
  - [lib/datos/progreso.dart](lib/datos/progreso.dart)
  - [lib/main.dart](lib/main.dart), donde se inicializa Supabase y un `SesionScope` junto a `Alcance`
  - [lib/ui/mapa.dart](lib/ui/mapa.dart)
  - [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml)
  - `pubspec.yaml`
  - `content/en.json`
  - [.github/workflows/ci.yml](.github/workflows/ci.yml)
- **Se crean:**
  - `lib/datos/{sesion,sincronizacion,repositorio_aula}.dart`, con una interfaz y una versión falsa para tests
  - `lib/modelo/aula/*`
  - `lib/ui/aula/*`
  - `lib/ui/perfiles/*`
  - `lib/main_panel.dart` y `lib/panel/**`
  - `supabase/**`
- **Se reutilizan:**
  - `FeedbackAcierto`, `FinJuego`, `DatosFinJuego` y `ResumenPrecisionFinal`
  - `guardarPrecisionPaso`
  - `JuegoPropio`
  - `Progreso.curso` / `mostrarSelectorCurso`
  - `PreferenciasControladas`

## Verificación
- **Tests unitarios:**
  - validación de plantillas;
  - fusión del progreso: idempotencia, orden y dispositivos sin conexión;
  - outbox;
  - generador de motes y llave.
- **Tests de widgets:**
  - cada plantilla en [test/ui/cierres_juegos_test.dart](test/ui/cierres_juegos_test.dart) con un `RepositorioAula` falso;
  - preguntas finales, repetición, navegación y guardado fallido sin duplicar semillas;
  - ES/EN, modo claro y oscuro, y movimiento reducido.
- **pgTAP sobre Supabase local** (`supabase start` + `supabase test db`):
  - un dispositivo no ve perfiles ajenos;
  - los borradores son invisibles;
  - el filtro por curso funciona;
  - solo el profesor escribe juegos;
  - el ranking expone solo mote y avatar;
  - el canje de la llave se bloquea al pasar de 5 intentos;
  - el login del panel funciona con usuario y con correo.
- **Prueba completa:**
  1. Panel en Chrome (`flutter run -d chrome -t lib/main_panel.dart`): publicar un juego para 3º.
  2. App en el emulador con curso 3º: el juego aparece en Aula; con 4º no aparece.
  3. Jugarlo sin conexión y reconectar: el resultado llega al panel y al ranking.
  4. Introducir la llave en otro emulador: se recupera el progreso, con el saldo de semillas correcto.
- **CI:**
  - `dart analyze --fatal-infos` y `flutter test`
  - `supabase test db`
  - `flutter build web -t lib/main_panel.dart`
  - `flutter build apk`
