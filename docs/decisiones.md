# Decisiones

Aquí van las decisiones de alcance que ya están tomadas, con la fecha. Si una choca con otro documento, manda esta. Si alguien cambia una, añade una línea nueva con la fecha en vez de borrar la anterior.

## 8 de octubre de 2026

**El contenido lo marca el material del colegio.** Es Ciencias de la Naturaleza de 1º a 6º (resumido en `docs/contexto.md`). Encima añadimos un bloque nuestro del cuerpo humano. La idea 9 del colegio (animales, plantas, Tierra y universo) se adapta a ese material, no al revés.

**La Tierra y el universo no tienen bloque propio.** No preparamos sistema solar, Sol, Luna, movimientos ni fases lunares, aunque la idea 9 los pidiera. Del tema solo podría salir lo que trae el material, que es relieve y rocas, y de momento tampoco hacemos ficha de eso (ver `content/cobertura.md`).

**El cuerpo humano sigue la misma progresión que el material.** Cada curso ve en la app lo que ya trabaja en clase:

| Nivel | Contenido |
| --- | --- |
| Fácil | Partes del cuerpo, sentidos, emociones, higiene y hábitos, de dónde salen los alimentos |
| Medio | Funciones vitales, aparatos digestivo, respiratorio y circulatorio, esqueleto y músculos |
| Difícil | La célula, sistema nervioso, reproducción y salud afectiva, nutrientes y etiquetas |

La reproducción hay que validarla con el colegio antes de publicarla.

## 13 de octubre de 2026

**MVP.** Lo que entra seguro es:

- Animales.
- Plantas.
- Seres vivos y ecosistemas.
- Cuerpo humano y salud.

**Ampliación, solo si da tiempo.** Materia, energía, fuerzas, máquinas y el resto del material del colegio. Se empieza cuando el MVP esté terminado. Todavía no está decidido si serían frases dentro de otros juegos o una zona nueva.

**Cada juego tiene selector de nivel.** Antes de empezar, el niño elige el nivel, y las preguntas y la mecánica cambian según lo que elija. Hay tres niveles:

| Nivel | Pensado para | Qué cambia |
| --- | --- | --- |
| Fácil | 1º-2º | 2 o 3 opciones, mucha imagen y poco texto, enunciado leído en voz alta, palabras sencillas |
| Medio | 3º-4º | Más opciones, categorías de ciencias (vertebrado o invertebrado, partes de la planta, aparatos del cuerpo), algo de lectura |
| Difícil | 5º-6º | Clasificaciones más finas, conceptos abstractos (célula, ecosistema, funciones vitales), más texto, tiempo límite opcional |

- En pantalla los niveles se llaman Fácil, Medio y Difícil, no por curso. Así un niño puede subir o bajar sin sentirse etiquetado.
- Cada pregunta o elemento de juego lleva su nivel y su bloque (animales, plantas, seres vivos, cuerpo). Un mismo juego vale para todos los cursos filtrando por nivel.
- El nivel puede cambiar la mecánica, no solo el texto: número de opciones, pistas, tiempo o cuántas cosas hay que arrastrar.
- Ningún nivel está cerrado: se puede jugar a cualquiera.

**Juegos generales.** Además de los juegos de cada zona habrá juegos que mezclan bloques, por ejemplo un repaso o un «¿quién soy?». Pueden tener dificultad fija o el mismo selector de nivel.

## Pendiente

- El catálogo guarda ahora un `curso` por ficha y por actividad. Para el selector hará falta un campo de nivel en cada pregunta o reto. Lo cambia quien lo implemente, avisando a quien lleva `content/`.
- Cómo encaja «seres vivos y ecosistemas» en el mapa: dentro de La reserva y El invernadero, o como sitio aparte.
- Confirmar con el colegio el curso de las guías que no lo dicen.

## 19 de octubre de 2026

**Español e inglés en toda la app.** El idioma inicial es español y un botón ES/EN permite elegir Español o English desde el mapa y las pantallas de zona, juego y álbum. La elección se guarda en el dispositivo y se aplica también a los controles de Material. Cambiar de idioma conserva la partida abierta, las estrellas, los cromos y la medalla.

Los textos originales siguen en español en el catálogo y en las reglas; sus traducciones propias se guardan en `content/en.json`. Se traducen al presentarlos, sin cambiar identificadores ni respuestas. Se mantiene el diseño de Natu y el tono de las pistas en ambos idiomas.
