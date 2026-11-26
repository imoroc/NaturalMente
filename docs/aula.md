# Aula, panel del profe y perfiles

La decisión y su alcance están en [decisiones.md](decisiones.md) (25 de noviembre de 2026). El plan completo, con las fases que faltan, está en [plan-aula.md](plan-aula.md).

## Qué hay

| Pieza | Dónde | Qué hace |
| --- | --- | --- |
| Perfiles | `lib/datos/perfiles.dart`, `lib/ui/perfiles/` | «¿Quién juega?» se abre tocando a Natu en el inicio. Cada niño tiene su Natu (color del pañuelo, trajes y pose), un mote generado y su propio progreso. El primer perfil usa las claves de siempre. |
| Aula en la app | `lib/datos/aula/`, `lib/ui/aula/` | Juegos que el profe publica para el curso elegido, con caché para jugar sin conexión, cola de resultados pendientes y ranking por curso. |
| Plantillas | `lib/modelo/aula/juego_aula.dart` | Opción múltiple y verdadero o falso. La validación es la misma en el panel y en la app. |
| Panel del profe | `lib/main_panel.dart`, `lib/panel/` | Web en Flutter: entrar, crear, publicar, ver resultados y apagar el ranking. La vista previa es la pantalla real del juego. |
| Base de datos | `supabase/migrations/` | Tablas, permisos (RLS), llave mágica y ranking. |
| Pruebas de la base | `supabase/tests/aula_test.sql` | 56 comprobaciones de permisos, versiones, fotos, vínculos y sincronización con pgTAP. |

Cada juego de Aula usa `FeedbackAcierto` y `FinJuego` como el resto. Las semillas se dan solo la primera vez que se completa cada versión del juego. La versión solo sube cuando el profe cambia el contenido de un juego ya publicado: los autoguardados de un borrador no cuentan. Su recorrido de cierre está en `test/ui/cierres_juegos_test.dart` (grupo `aula`).

## Tipos de reto

Un juego es una serie de **retos**, de cualquier tipo y en el orden que quiera el profe (`lib/modelo/aula/juego_aula.dart`, pantallas en `lib/ui/aula/retos_aula.dart`, editor en `lib/panel/editor_retos.dart`):

| Tipo | Qué hace el niño | Cómo se evalúa |
| --- | --- | --- |
| Elegir la respuesta | Toca una de 2 a 4 respuestas (texto o imagen) | Al tocar |
| Verdadero o falso | Decide si la frase es verdad | Al tocar |
| Clasificar en grupos | Lleva cada tarjeta (hasta 12) a su grupo (2 a 4) | Con «Comprobar» |
| Ordenar | Toca los pasos (3 a 8) en orden | Con «Comprobar» |
| Unir parejas | Une cada tarjeta con su pareja (2 a 8) | Cada pareja, al tocar |
| Completar la frase | Rellena los huecos `[así]` con palabras, algunas de más | Con «Comprobar» |
| Tocar en la imagen | Toca el sitio correcto de una foto (el profe marca hasta 5 zonas) | Al tocar |
| Adivinar el número | Escribe un número con el teclado | Con «Comprobar» |
| Formar la palabra | Ordena letras desordenadas | Con «Comprobar» |
| Tarjeta para leer | Lee un texto o una imagen | No se puntúa |

Todos usan `FeedbackAcierto`: mover piezas no es un acierto; fallar da la pista del profe sin avanzar; acertar muestra la explicación. Los juegos antiguos (opción múltiple o verdadero/falso) se leen igual.

## Jugadores en tablets compartidas

- Caben 30 jugadores por dispositivo.
- **Quitar de esta tablet** (si tiene llave): se quita solo de esa tablet; su progreso sigue en la nube y se recupera con la llave. Antes envía las partidas pendientes.
- **Borrar para siempre**: borra también sus datos de la nube.
- Si su llave se cambia en otra tablet, esta lo detecta, guarda sus partidas sin enviar y pide la llave nueva, sin crear otro perfil en la nube.

## Fondos, fotos, llave y progreso en varios dispositivos

- **Fondos**: hay 12 escenas dibujadas con código (`lib/ui/aula/escenas.dart`): pradera, bosque, selva, fondo del mar, playa, desierto, polo, montaña, otoño, granja, jardín y noche. Se adaptan a cualquier pantalla y no gastan datos. Además están las fotos de `assets/mundos` y las que suba el profe.
- **Fotos del profe**: el panel las reduce en el navegador a JPEG de 1600 px como máximo (unos 200 KB) y las sube a Supabase Storage, cada profe a su carpeta. La app las guarda en el dispositivo al abrir Aula, para jugar sin conexión. Al borrar un juego se borran sus fotos si ningún otro las usa. Con el plan gratuito (1 GB) caben unas 5.000.
- **Llave mágica**: en «¿Quién juega?» → «Cambiar mi Natu» → «Crear mi llave». En otra tablet: «Tengo una llave de otra tablet», se elige el mote y se tocan los tres dibujos y el número.
- **Sincronización**: al entrar en Aula se junta el progreso de todas las tablets del niño (`sincronizar_progreso`). Lo conseguido se suma y las semillas se cuentan por dispositivo, sin duplicar nada. La ropa y el curso siguen el último cambio. Las pruebas están en `test/datos/sincronizacion_test.dart` y en pgTAP.
- **Pantallas adaptables**: en tablets apaisadas y en web, el juego pone la pregunta a un lado y las respuestas al otro, y Aula muestra los juegos en dos o tres columnas.
- **Privacidad**: `web/privacidad.html`, publicada con el panel en `/privacidad.html`.

## Probarlo en local

Hace falta Docker en marcha.

```bash
npx supabase start          # levanta Postgres, Auth y Storage y aplica las migraciones
npx supabase test db        # pruebas de permisos
npx supabase status         # URL, clave publicable y clave de servicio locales
```

Crear al profesor de prueba. El script imprime su usuario y una contraseña de cuatro palabras:

```bash
SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_SERVICE_ROLE_KEY=<SERVICE_ROLE_KEY> \
  node supabase/scripts/crear_profesor.mjs --usuario profe.prueba --nombre "Profe de prueba"
```

Panel y app contra el Supabase local:

```bash
flutter run -d chrome --web-port 5800 -t lib/main_panel.dart \
  --dart-define=SUPABASE_URL=http://127.0.0.1:54321 --dart-define=SUPABASE_ANON_KEY=<PUBLISHABLE_KEY>

flutter run --dart-define=SUPABASE_URL=http://10.0.2.2:54321 --dart-define=SUPABASE_ANON_KEY=<PUBLISHABLE_KEY>
```

En el emulador de Android, `10.0.2.2` es el ordenador. Sin los `--dart-define`, la app funciona igual y Aula dice que no está disponible.

Prueba de la app contra la base real:

```bash
SUPABASE_PRUEBAS_URL=http://127.0.0.1:54321 SUPABASE_PRUEBAS_ANON=<ANON_KEY> \
SUPABASE_PRUEBAS_SERVICE=<SERVICE_ROLE_KEY> flutter test test/integracion
```

## Ponerlo en marcha de verdad (pendiente)

1. Crear un proyecto gratuito en supabase.com, en la región **Frankfurt (eu-central-1)**, y aplicar las migraciones con `npx supabase link` y `npx supabase db push`.
2. En Authentication:
   - Activar los inicios de sesión anónimos.
   - Para «Entrar con Microsoft» y «Entrar con Google», registrar las apps en Azure y en Google Cloud y añadir la URL del panel a las redirecciones.
3. Crear la cuenta del profesor con `crear_profesor.mjs`, usando la clave de servicio del proyecto. Esa clave no se sube nunca al repositorio.
4. Guardar `SUPABASE_URL` y `SUPABASE_ANON_KEY` (la clave publicable) como variables del repositorio. El CI ya compila el panel con ellas (job `panel`). Publicar `build/panel` en Cloudflare Pages o Vercel.
5. Compilar la app de las tiendas con los mismos `--dart-define`.
6. El plan gratuito de Supabase se pausa tras 7 días sin uso. El workflow `supabase-despierto.yml` lo consulta cada día si las variables existen.

Si el profesor olvida la contraseña: `node supabase/scripts/crear_profesor.mjs --usuario <usuario> --regenerar`.

## Qué datos se guardan

- **De cada niño:** el mote (animal y adjetivo), el color de su Natu, su traje y pose, su curso y sus resultados en Aula (aciertos por pregunta y fecha).
- **De cada dispositivo:** un usuario anónimo.
- **Nada más:** ni nombres, ni correos, ni fechas de nacimiento, ni fotos.
- **Al borrar un jugador** en «¿Quién juega?», se borra primero su perfil de la nube, con sus resultados en cascada, y después lo del dispositivo. Sin conexión no se borra nada y se avisa, para que no queden datos sin dueño.

La llave para recuperar un perfil se guarda cifrada (bcrypt) y no se puede leer desde la app. Antes de publicar en tiendas faltan la política de privacidad y actualizar las fichas de datos de Google Play y Apple.

## Capturas de referencia

Al añadir Aula y la Natu del perfil cambió el inicio, así que se regeneraron las capturas `mapa-*` en Linux con la misma versión de Flutter que el CI. En Windows las fuentes se pintan distinto y esas pruebas fallan siempre, también en `main`.
