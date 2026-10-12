# Organización

Organización para todo el proyecto.

Los ficheros de dentro crecerán. Muchos todavía no existen. La versión que hay ahora solo demuestra que arranca, que se ve el mapa y que una regla de juego se puede probar sola.

## Carpetas

```
naturalmente/
  lib/
    ui/            pantallas
    reglas/        qué respuesta vale y qué frase se devuelve. Sin widgets
    datos/         leer content/catalog.json y, más adelante, guardar la medalla en el teléfono
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

Sirve para ver que el circuito está bien antes de llenarlo.

- Abre el mapa con La reserva, El invernadero y Dentro de mí.
- En La reserva se puede jugar el camello. Polo responde con frío. A la segunda añade la pista del sitio seco.
- Los otros dos sitios dicen que el juego todavía no está.
- `flutter test` cubre la regla y que el mapa enseña los tres nombres.

El invernadero, las piezas del cuerpo y la reproducción no están programados. Están descritos en `docs/contexto.md` y en la lista de Alfredo.
