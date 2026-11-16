# Feedback y cierre obligatorios de todos los juegos

Este comportamiento forma parte de cada juego, tanto existente como nuevo, en Fácil, Medio y Difícil. También se aplica al reto diario, conservando sus restricciones. No es una mejora visual opcional.

## Comportamiento esperado

- Al resolver correctamente una sección evaluada, aparece brevemente un check verde sobre un círculo verde, centrado sobre todo el contenido. La entrada es suave y la salida se desvanece. Lo acompañan el sonido de acierto y la vibración, si están activados.
- Seleccionar, arrastrar o colocar provisionalmente una pieza sin comprobarla no activa un acierto. Tampoco lo activa una respuesta fallida.
- Al completar realmente el nivel, se usa la variante de victoria: mayor tamaño, destellos, fanfarria y vibración de final. Las preguntas de comprensión y la pregunta final forman parte del nivel: no se celebra su final antes de resolverlas.
- Cuando termina la animación de victoria, aparece automáticamente una pantalla de resultado con el resumen y las acciones **Cambiar nivel**, **Otra vez** y **Volver al mundo**. Las acciones permanecen visibles aunque el resumen necesite desplazamiento.
- Cerrar esa pantalla permite seguir explorando las explicaciones y curiosidades. Los botones que queden en el ejercicio pueden mantenerse, pero no sustituyen la presentación automática de las opciones.
- Mientras se guarda, las acciones de salida y reinicio esperan. Si guardar falla, se ofrece **Guardar de nuevo** sin volver a evaluar la respuesta ni sumar recompensas.
- El reto diario ofrece **Volver al mapa** y **Armario de Natu**. No permite repetir ni cambiar la dificultad de una misión diaria ya completada.

## Componentes que hay que reutilizar

| Componente | Responsabilidad |
| --- | --- |
| [`FeedbackAcierto`](../lib/ui/feedback_acierto.dart) | Insertar el overlay, coordinar el audio y la vibración con la animación, retirar el efecto y abrir el cierre. |
| `mostrarAcierto()` | Confirmar una sección acertada, sin cerrar el nivel. |
| `mostrarAcierto(finalDeNivel: true)` | Iniciar la victoria del nivel y presentar el cierre al acabar la animación. |
| `registrarGuardadoFinal(Future<bool> Function())` | Seguir la persistencia y conservar una operación que se pueda reintentar sin repetir la jugada. |
| `construirFinJuego()` | Proporcionar los datos y callbacks del cierre; devolver `null` si todavía no corresponde mostrarlo. |
| [`DatosFinJuego` y `FinJuego`](../lib/ui/fin_juego.dart) | Compartir la presentación del resultado y las acciones; gestionar la espera y el reintento del guardado. |
| [`ResumenPrecisionFinal`](../lib/ui/componentes_juego.dart) | Presentar las estadísticas de la partida terminada. |
| [`Idioma`](../lib/idiomas/idioma.dart) | Respetar los ajustes de sonido/vibración y traducir los textos. |

Si el juego usa `JuegoPage`, la integración ya está en la pantalla compartida. Una pantalla de juego propia debe incorporar el mismo mixin y los mismos contratos. No copies el pintor ni crees una animación o un diálogo de final alternativos.

## Coordinar un paso antes de presentar el siguiente

La coordinación descrita en [el plan de transiciones](plan-feedback-y-transiciones.md) se aplica a los 26 juegos y al reto diario. La clasificación sencilla avanza automáticamente; los montajes conservan el tablero; las adivinanzas, las explicaciones de especies y el reto diario esperan a **Continuar** cuando aún quedan pasos. El último paso conduce directamente al cierre automático.

El mismo mixin proporciona estas operaciones adicionales:

| API | Contrato |
| --- | --- |
| `iniciarPasoEvaluado()` | Adquiere el paso sincrónicamente. Devuelve `false` si ya se está evaluando, confirmando, observando o avanzando; el evento se descarta. Llamar antes del primer `await`. |
| `confirmarPaso(alContinuar: ..., esperarContinuar: false)` | Ejecuta `mostrarAcierto()` y conserva la escena evaluada hasta que termina el check. Después ejecuta el cambio de presentación dentro de `setState` e inicia un desvanecimiento de 160 ms. |
| `esperarContinuar: true` | Al terminar el check conserva el resultado sin límite de lectura y ofrece **Continuar**. No usar en el último paso, que conduce directamente al cierre obligatorio. |
| `conservarTablero: true` | Retira el check y devuelve el control sin desvanecer el tablero acumulativo. Se usa en las piezas del cuerpo, sentidos y montaje del plato. |
| `terminarIntentoConPista()` | Libera un intento evaluado que necesita una pista, sin check ni avance. |
| `construirContenidoPaso(widget)` | Envuelve el cuerpo del ejercicio, con altura disponible acotada. Bloquea acciones táctiles, semánticas y foco de teclado del tablero durante el paso, dejando fuera la navegación de la cabecera. También presenta la transición y Continuar. |
| `fasePaso` y `pasoBloqueado` | Permiten conservar en pantalla los datos del paso y proteger los manejadores frente a eventos que llegan antes de reconstruir los widgets. |
| `guardarPrecisionPaso(...)` | Aplica una única jugada a la precisión y encola su persistencia. Se llama después de adquirir el paso, fuera de los callbacks de guardado. Devuelve las semillas aceptadas para el resumen. |
| `registrarGuardadoIntermedio(id, guardar)` | Serializa una escritura del paso y conserva el callback original si falla. Un identificador se ejecuta una sola vez dentro de la sesión, salvo el reintento explícito. |
| `presentarCombo(actual)` | Conserva la cifra anterior durante el check; se utiliza con la variante `discreta` de la insignia para evitar celebraciones simultáneas. |
| `mostrarDestinoPaso(clave)` | Busca el destino después de presentar la pregunta, comprueba su visibilidad y respeta el movimiento reducido. No llamarlo al iniciar el check. |
| `mostrarCierrePendiente()` | Recupera exclusivamente un resultado ya aceptado cuyo guardado sigue pendiente. Se registra antes su persistencia; no repite la victoria ni las recompensas. |

`alContinuar` solo modifica la presentación: no evalúa, puntúa ni guarda. No debe llamar de nuevo a `setState`, pues el coordinador ya lo hace. Una pregunta de comprensión se abre desde este callback, después del check, y sigue siendo parte del nivel.

El guardado comienza al aceptar la respuesta, independientemente de la animación. En el último paso se sigue llamando a `mostrarAcierto(finalDeNivel: true)` y a `registrarGuardadoFinal(...)` inmediatamente después. No usar `confirmarPaso` para añadir un check normal antes de esa victoria.

`ocultarAcierto()` y la destrucción de la pantalla cancelan el callback pendiente, sin ejecutarlo. El reloj del check y de la transición se pausa al salir a segundo plano y se reanuda sin repetir los efectos iniciales. El modo de movimiento reducido conserva el tiempo de confirmación, pero omite el desvanecimiento del nuevo contenido.

Las llamadas antiguas a `mostrarAcierto()` siguen disponibles para compatibilidad y pruebas del componente. Los juegos coordinan todos sus aciertos intermedios mediante `confirmarPaso`: una llamada visual aislada no protege por sí sola el tablero.

`registrarGuardadoFinal` espera a las escrituras del paso y reintenta las que fallaron antes de persistir el cierre. La cancelación de una animación no cancela un guardado ya aceptado. Captura los datos y el objeto Progreso **antes** de registrar el callback; no busques `context` ni leas la partida nueva dentro de una escritura que puede terminar después de salir.

Los componentes [ProgresoPaso, AnuncioPaso y AsentamientoPaso](../lib/ui/atencion_paso.dart) comparten la atención del ejercicio: conservan el progreso bajo el check, animan el nuevo valor durante 160 ms, asientan localmente la elección confirmada y suspenden los anuncios del contenido mientras habla la confirmación. Los contadores siguen siendo accesibles, pero no compiten como regiones automáticas con la explicación.

El reto diario prepara un `GuardadoExpedicion` en [Progreso](../lib/datos/progreso.dart) antes de la victoria. Su callback solo llama a `guardarExpedicionDiaria(cierre)`. Un registro local conserva el destino del bono antes de escribir el saldo; si una escritura parcial falla, se recupera únicamente ese resultado para guardar de nuevo, sin reconstruir las preguntas ni conceder el bono otra vez.

## Integrar una pantalla propia

Importa los componentes y añade `with FeedbackAcierto<TuPagina>` al `State<TuPagina>`. Toma [`HerbarioPage`](../lib/ui/herbario.dart), [`ViajePage`](../lib/ui/digestion.dart) o [`NacimientoPage`](../lib/ui/nacimiento.dart) como referencias completas.

El siguiente fragmento ilustra el caso del herbario dentro de su `State`. Los campos de partida y estadísticas pertenecen a cada juego; los métodos de feedback son la API compartida:

```dart
final partida = _partida!;
final progreso = Alcance.of(context).progreso;
if (partida.resultado?.acierto == true) {
  if (partida.completa) {
    mostrarAcierto(finalDeNivel: true);
    await registrarGuardadoFinal(() async {
      await progreso.marcarNivelHerbario(
        widget.actividad,
        partida.nivel.id,
      );
      return true;
    });
  } else {
    mostrarAcierto();
  }
}
```

Inicia la victoria y registra el guardado en el mismo manejador, sin un `await` entre ambos. `mostrarAcierto(finalDeNivel: true)` prepara una nueva celebración y reinicia el registro anterior. El mixin convierte una excepción del guardado en un resultado fallido; si tu método ya captura las excepciones, devuelve su estado real de éxito, no `true` incondicionalmente.

Calcula los puntos y las recompensas una sola vez, fuera del callback de persistencia. Captura la partida o el nivel que se está guardando. Protege los guardados en curso para que un doble toque no sustituya su resultado por otro prematuro. El ejemplo completo del herbario conserva estas protecciones en `_guardarSiCompleta()`, que captura actividad, nivel y Progreso antes de cualquier espera.

Proporciona el cierre desde la pantalla del juego:

```dart
@override
DatosFinJuego? construirFinJuego() {
  final partida = _partida;
  if (partida == null || !partida.completa) return null;
  final nivel = partida.nivel;
  return DatosFinJuego(
    actividad: widget.actividad.titulo,
    nivel: nivel.nombre,
    resumen: ResumenPrecisionFinal(
      semillasGanadas: _semillasSesion,
      mejorComboSesion: _mejorComboSesion,
      sinPistas: _pistasSesion == 0,
    ),
    onRepetir: () => _empezar(nivel),
    onCambiarNivel: () {
      ocultarAcierto();
      setState(() => _partida = null);
    },
    onVolver: () => Navigator.of(context).pop(),
  );
}
```

`_empezar(nivel)` también debe llamar a `ocultarAcierto()` antes de limpiar la partida y sus estadísticas. Los callbacks se ejecutan después de cerrar el resultado; usa el contexto de la pantalla del juego para volver al mundo. Los callbacks opcionales permiten conservar restricciones como las del reto diario, sin inventar acciones que el juego no admite.

## Sincronización, accesibilidad y plataformas

El cierre se encadena al final real del `AnimationController`. No uses `Timer`, `Future.delayed`, `showDialog` o `Navigator.push` adicionales para calcular cuándo mostrarlo. Las duraciones se mantienen en `AnimacionAcierto`; no las copies en cada pantalla.

No reproduzcas además `context.sonidoAcierto()`, `context.sonidoCelebracion()` ni vibraciones manuales en el mismo acierto. `FeedbackAcierto` ya los coordina. Mantén los sonidos de selección, pasos y pistas donde correspondan.

El componente respeta `MediaQuery.disableAnimationsOf(context)` y conserva una confirmación legible sin los movimientos decorativos. Los ajustes de sonido y vibración son independientes: silenciar el audio no silencia automáticamente la vibración. Usa `Texto` o `context.tr(...)` y añade los textos nuevos a [`content/en.json`](../content/en.json).

Android tiene un canal nativo de vibración y el permiso `VIBRATE`; los demás casos conservan el feedback del sistema disponible. Si modificas el canal o el manifiesto Android, recompila y vuelve a lanzar la app: la recarga en caliente no actualiza esa parte.

## Verificación antes de dar un juego por terminado

1. Una sección acertada muestra el check normal; una selección sin evaluar y un fallo no lo muestran.
2. Las preguntas intermedias y finales pendientes impiden presentar el cierre de victoria.
3. El final encadena una sola celebración y una sola pantalla de resultado, también con toques rápidos.
4. Repetir limpia la partida y vuelve a ofrecer el cierre cuando se completa; cambiar de nivel abre el selector y volver regresa al mundo correcto.
5. Un guardado lento mantiene las acciones a la espera; uno fallido permite reintentar sin duplicar puntos, semillas, estrellas ni cromos.
6. Salir o reiniciar durante una celebración no deja overlays, relojes o pantallas pendientes.
7. Las opciones funcionan con texto ampliado, pantalla pequeña u horizontal, español e inglés, movimiento reducido y los ajustes independientes de audio/vibración.

Extiende [`test/ui/cierres_juegos_test.dart`](../test/ui/cierres_juegos_test.dart) con el recorrido del nuevo juego y de todos sus niveles. Ese archivo recorre las actividades del catálogo; si incorporas una mecánica nueva, añade su caso al ayudante `_jugar`.

Las pruebas del componente están en [`feedback_acierto_test.dart`](../test/ui/feedback_acierto_test.dart) y [`fin_juego_test.dart`](../test/ui/fin_juego_test.dart). Para las pruebas del contenido que continúan tras una victoria, [`soporte_cierre.dart`](../test/ui/soporte_cierre.dart) permite elegir seguir explorando; no lo uses para ocultar las comprobaciones específicas del cierre.

```bash
dart analyze --fatal-infos
flutter test test/ui/feedback_acierto_test.dart test/ui/fin_juego_test.dart test/ui/cierres_juegos_test.dart
flutter test
```

Si cambias la parte nativa de Android, comprueba también `flutter build apk --debug`. Comprueba la sensación de la vibración y el sonido en un teléfono: las pruebas de widgets validan las llamadas y los recorridos, no la respuesta física del dispositivo.
