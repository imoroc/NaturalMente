# Cómo trabajamos

El plan vive en `docs/plan.md`. Si una tarea contradice ese archivo, primero se cambia el plan en la misma PR o en una PR corta anterior. No se construye una pantalla que el plan no contempla.

## Ramas

Una rama por tarea, desde `main`: `david/mapa`, `alfredo/fichas-animales`, `alejandro/android`. El nombre dice quién y qué.

## Qué tiene que cumplir una tarea para poder unirse a main

- El texto nuevo es nuestro. No hay frases ni dibujos del libro de SM.
- Si el niño no acierta, la respuesta le hace pensar. No vale «error», «incorrecto», «has fallado» ni «mal hecho».
- La actividad dice para qué curso está pensada, y se puede abrir igual desde cualquier curso.
- No aparece la Tierra como planeta, ni el universo, ni la Luna, ni el relieve, ni las rocas. El suelo de una planta no cuenta como eso.
- Hay una prueba automática o, si es solo visual, el guion manual de `docs/plan.md` hecho en un teléfono.
- La pantalla no enseña la solución antes de que el niño la construya.

## Quién revisa

| Si tocas… | Te revisa |
| --- | --- |
| Pantallas o aspecto | David |
| Reglas o pistas | Iván |
| Fichas o `content/` | Alfredo |
| Android, iOS o tiendas | Alejandro |
| Pruebas | Diego |

Hace falta una revisión. Iván une a `main` porque el repositorio es suyo, no porque decida el contenido de los demás.

## Cómo se llama el commit

Una frase en español que diga qué queda hecho, por ejemplo: `Añade el juego del hábitat y sus pistas.`
