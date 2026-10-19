# Organización

Organización para todo el proyecto.

Los ficheros de dentro crecerán. La versión actual tiene tres zonas, fichas, cinco actividades y progreso local. Herbario desmontable incorpora los tres niveles; faltan las variantes de los otros juegos y el resto del contenido previsto.

## Carpetas

```
naturalmente/
  lib/
    ui/            pantallas
    reglas/        qué respuesta vale y qué frase se devuelve. Sin widgets
    datos/         leer content/catalog.json y guardar el progreso en el teléfono
    idiomas/       preferencia local y traducción de textos
    modelo/        clases: zona, ficha, juego, curso orientativo
    main.dart      arranque
  content/         textos. catalog.json es el que lee la app. cobertura.md es la lista de temas
  assets/
    imagenes/      dibujos nuestros
    icono/         icono de la app, cuando lo tengamos
  test/
    reglas/        pruebas de lib/reglas
    ui/            pruebas de pantallas
  android/         identificador, icono, firma. No se reescribe aquí la app
  ios/             igual, para Apple
  web/             solo para abrirla en Chrome. No se publica
  docs/
    contexto.md    de qué va, la asignatura y el material de ciencias
    organizacion.md
    decisiones.md  decisiones de alcance, con fecha
    juegos.md      banco de ideas de juegos por zona y nivel
```

`lib/ui` es de David. `lib/reglas` es de Iván. `content/` es de Alfredo. `test/` es de Diego. `android/`, `ios/` y la publicación son de Alejandro. `lib/datos` y `lib/modelo` los toca quien necesite un campo nuevo, y se lo dice al dueño del contenido si cambia el JSON.

Identificador de la app: `com.naturalmente.naturalmente`. Nombre en el móvil: NaturalMente.

## Quién hace qué, de octubre a diciembre

| Persona | Durante todo el proyecto | Horas |
| --- | --- | --- |
| David | Pantallas, colores, movimiento, que se entienda en un móvil y en una tablet | unas 70 |
| Iván | Reglas de los juegos y las frases que oye el niño cuando no acierta | unas 70 |
| Alejandro | Proyecto Flutter, Android, iOS, cuentas de las tiendas, envío del 7 de diciembre | unas 70 |
| Alfredo | Fichas, `catalog.json`, que no falte un tema de `content/cobertura.md` ni sobre uno prohibido | unas 70 |
| Diego | `flutter test`, el guion en un teléfono real, y la pasada de antes de enviar | unas 70 |


## Fechas

No es un cambio de rol. Es cuándo tiene que estar lista cada parte, para no llegar al 7 de diciembre con la tienda sin pedir.

| Fecha | Qué está listo |
| --- | --- |
| Semana del 13 oct | Proyecto Flutter en el repo. Cuentas de Play y de Apple pedidas. Sabemos de qué Mac hay. Colores y personaje. Títulos de las fichas |
| 26 oct | Mapa con los tres sitios, navegable |
| 2 nov | Catálogo con fichas de verdad y curso orientativo |
| 9 nov | Reglas de hábitat, germinación, piezas del cuerpo y «Así empieza una vida», con test |
| 16 nov | Esos juegos se pueden jugar |
| 23 nov | APK instalado en un Android. Compilado al menos una vez en un Mac |
| 27 nov | Textos y reglas quietos. A partir de aquí solo fallos |
| 7 dic | Enviada a Play y a App Store |
| 8–16 dic | Arreglos |

Si nos atrasamos, se mantiene el mapa, las fichas justas, el hábitat, la germinación, las piezas, «Así empieza una vida», la medalla y el envío. Se deja para otra versión lo demás: más animales, etiquetas de alimentos, sonidos, esqueleto, animaciones que no expliquen nada, y las tres frases de energía y palanca.

## Versión que hay ahora

Los juegos salen de `content/catalog.json`. Una pantalla compartida pinta ubicación, controles y ordenación. Herbario tiene su propia pantalla y dibujo. Lo ya hecho se guarda en el dispositivo.

- La reserva: se arrastra el animal a desierto, mar, polo o bosque.
- El invernadero y el cuerpo usan esa misma pantalla, cada uno con su tipo de juego.
- La medalla sigue ahí al cerrar y volver a abrir.
- Herbario desmontable: Fácil con raíz, tallo y hoja; Medio con cinco partes; Difícil con cinco rótulos y preguntas de función. Se puede arrastrar o jugar mediante toques, consultar las partes y repetir.
- Herbario guarda qué niveles se han superado; completar cualquiera marca la actividad. No cambia los requisitos de la medalla. Salir de una partida incompleta la reinicia al volver.

La implementación y sus comprobaciones se describen en `docs/plan-herbario.md`. Los roles orientan las revisiones y permiten coordinarse; cualquiera puede implementar una tarea.

## Idiomas

El selector ES/EN está en el mapa y en las barras de las pantallas. `lib/idiomas/idioma.dart` lee `content/en.json` y guarda la preferencia `idioma` mediante SharedPreferences, aparte del progreso. Español es el idioma inicial. No necesita conexión.

`Texto` presenta los textos traducidos y conserva los estilos existentes. Las etiquetas de accesibilidad y ayudas usan `context.traducir`. El catálogo y las reglas conservan sus textos originales e identificadores: al cambiar de idioma se actualiza la presentación de las rutas abiertas sin reiniciar las partidas.

Al añadir un texto visible, añade su traducción a `content/en.json`. Las claves son las frases originales completas; para textos variables se usan `{0}`, `{1}`, etc., en el mismo orden que los valores del original. Las frases más específicas se resuelven antes que sus prefijos. Los contadores, listas, títulos en mayúsculas y respuestas con pista se componen con las mismas traducciones. Los nombres de idioma se muestran siempre como Español y English.

Comprobaciones: `flutter analyze`, `flutter test` y `flutter build web`. `test/datos/idioma_test.dart` comprueba la persistencia, las composiciones y la cobertura del catálogo; `test/ui/idioma_test.dart` recorre los cinco juegos, el álbum y los cambios de idioma durante una partida en tamaño móvil. La revisión final en teléfono o Chrome por Diego sigue formando parte de la revisión del equipo.
