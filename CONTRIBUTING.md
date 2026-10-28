# Cómo subimos cambios

Una rama por tarea, desde `main`. El nombre lleva quién y qué: `david/mapa`, `alfredo/fichas-reserva`, `alejandro/android`.

Antes de abrir la PR:

- El texto nuevo es nuestro. Nada copiado de las guías de SM.
- Si el juego dice que no, la frase explica qué pasa. No vale «error», «incorrecto», «has fallado» ni «mal hecho».
- Si es una actividad nueva, se ve el curso orientativo y se puede abrir igual.
- Cada juego integra el check de acierto y la victoria con sonido/vibración mediante `FeedbackAcierto`, y presenta automáticamente `FinJuego` al terminar. Es obligatorio en todos sus niveles; sigue [la guía de feedback y cierre](docs/feedback-y-cierre.md) y las instrucciones de [AGENTS.md](AGENTS.md).
- Las preguntas finales cuentan para completar el nivel. El guardado se puede reintentar sin repetir puntuación ni recompensas, y las opciones de cierre funcionan en los tres niveles.
- No aparece la Tierra como planeta, ni el universo, ni la Luna, ni el relieve, ni las rocas. El suelo de una planta no cuenta.
- `flutter test` pasa. Si el cambio es solo visual, Diego lo ha mirado en un teléfono o en Chrome.
- Si el cambio no cabe en `docs/contexto.md` o en `docs/organizacion.md`, se actualizan en la misma PR.

Revisa el dueño de esa parte (pantallas David, reglas Iván, fichas Alfredo, Android e iOS Alejandro, pruebas Diego). Hace falta una revisión. Iván une a `main`.

El mensaje del commit es una frase en español: `Añade la pista del camello en el polo.`
