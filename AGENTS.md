# Instrucciones para agentes

Estas instrucciones se aplican a todo el repositorio. Para el contexto del producto, consulta [docs/contexto.md](docs/contexto.md), [docs/decisiones.md](docs/decisiones.md) y [CONTRIBUTING.md](CONTRIBUTING.md).

## Obligatorio al crear o modificar juegos

Todos los juegos deben integrar el feedback y el cierre comunes en cada nivel. La guía de implementación está en [docs/feedback-y-cierre.md](docs/feedback-y-cierre.md).

- Usa el mixin `FeedbackAcierto` de `lib/ui/feedback_acierto.dart`.
- En un acierto evaluado de una sección, llama a `mostrarAcierto()`. El check verde, el sonido y la vibración se coordinan desde ese componente. Seleccionar o mover una pieza todavía no comprobada no es un acierto.
- Solo cuando el nivel esté realmente completo, incluidas sus preguntas finales, llama a `mostrarAcierto(finalDeNivel: true)`.
- Implementa `construirFinJuego()` devolviendo `DatosFinJuego` para que, al terminar la animación, aparezca la pantalla común `FinJuego` con las acciones disponibles. No dejes el final únicamente en botones al pie del ejercicio.
- Registra la persistencia con `registrarGuardadoFinal(...)` inmediatamente después de iniciar la victoria, antes de cualquier `await`. Su callback debe guardar y devolver si lo consiguió; no debe evaluar respuestas, sumar puntos ni reproducir feedback.
- Al repetir o cambiar de nivel, llama a `ocultarAcierto()` antes de reiniciar el estado. Si sobrescribes `didChangeDependencies()` o `dispose()`, llama a `super` para conservar la preparación y la limpieza del feedback.
- Respeta los ajustes independientes de sonido y vibración, el movimiento reducido y las traducciones ES/EN. No dupliques audio, vibraciones, temporizadores ni diálogos de victoria por juego.
- El reto diario usa el mismo cierre, pero mantiene su límite diario: ofrece volver al mapa y abrir el armario, sin repetir ni cambiar de nivel después de completarlo.

## Comprobación

Si cambias código de juegos, añade o adapta su recorrido en `test/ui/cierres_juegos_test.dart` y ejecuta las comprobaciones indicadas en la guía. Verifica también las preguntas finales, la repetición, la navegación y el guardado fallido sin duplicar recompensas.

Si solo cambias documentación, comprueba sus enlaces, nombres de API y correspondencia con el código; no hace falta recompilar la app.
