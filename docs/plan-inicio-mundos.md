# Plan de simplificación del inicio

Referencia aprobada: la tercera propuesta con bordes de color. Este plan cubre la pantalla de inicio de NaturalMente.

## Qué verá el niño

- Una cabecera corta con Natu, el nombre de la app y la llama de racha, que indica los días consecutivos y abre el reto diario. El botón **Ajustes** va debajo de Mis cromos y Vestir a Natu. Abre el panel de idioma, apariencia, sonido, música y vibración.
- Bajo «¿A qué jugamos?», tres tarjetas de la misma importancia: **Animales**, **Plantas** y **Mi cuerpo**. Las tres deben verse completas al abrir en un móvil de 360 × 700 píxeles lógicos con texto al tamaño normal. Cada tarjeta tiene una ilustración fácil de reconocer, una frase corta y una flecha. Se puede tocar toda la tarjeta, incluido el dibujo. Las pantallas de destino conservan los nombres La reserva, El invernadero y Dentro de mí.
- Conservar los bordes redondeados y el relieve inferior del mapa actual: verde para Animales, naranja para Plantas y azul para Mi cuerpo. Por debajo, **Reto de hoy**, **Mis cromos** y **Vestir a Natu** llevan bordes más finos, sus propios dibujos y un nombre que explica su función.
- Las semillas se consultan en el armario, los cromos en el álbum y las estrellas y misiones en cada mundo. Si una cifra de progreso aún no se muestra en su destino, incorporarla allí con los datos existentes. El estado diario se consulta en su acceso o dentro del reto, sin duplicarlo en la cabecera.

## Ilustraciones definitivas

**La calidad de las ilustraciones es un criterio de aceptación.** Reproducir las formas, paleta, contornos y estilo del boceto aprobado con un conjunto nuevo de ilustraciones rasterizadas para el inicio. Usar fondos transparentes para que funcionen en ambos temas. Mantener el Natu vectorial cuando el niño haya equipado una pose o un traje, para que su personalización se vea en la cabecera. Registra la procedencia del arte definitivo en el inventario.

Los seis accesos se reconocen por su silueta antes de leer: animal, planta que brota, figura humana con corazón, calendario, álbum con cromos y Natu con ropa. Unificar grosor de línea, detalle, proporciones, escala óptica y paleta con el arte actual. Revisar en claro y oscuro a tamaño real de móvil. Si una pieza tiene texturas que ensucian, sombras incoherentes, trazos borrosos, formas deformadas o una silueta que cuesta reconocer, redibujarla aunque en grande se vea bien. Registrar cualquier recurso nuevo y su procedencia en [licencias.md](../content/licencias.md).

## Implementación y comprobación

1. Simplificar [MapaPage](../lib/ui/mapa.dart). Reutilizar la paleta por zona y los destinos actuales. Mantener las claves de los tres mundos y de los accesos que se conservan. Usar el [panel de ajustes existente](../lib/ui/selector_idioma.dart) y sus preferencias, con la etiqueta visible «Ajustes» traducida.
2. Incorporar los textos ES/EN con el mecanismo actual. Ajustar primero la altura de la cabecera, los márgenes y las ilustraciones para que quepan las tres tarjetas. Con texto ampliado o una ventana más baja, permitir desplazar y partir líneas sin cortar texto ni reducir las zonas de toque. Los dibujos y los nombres permiten identificar cada acceso sin depender del color.
3. Verificar en móvil, claro y oscuro, ES/EN y con texto ampliado. Comprobar que cada mundo abre su destino y vuelve al inicio, que ajustes conserva idioma y preferencias, que el armario enseña semillas y el álbum conserva los cromos. Revisar el acceso al reto pendiente y completado con progreso existente. Mantener las reglas, guardado y [cierre común](feedback-y-cierre.md) del reto.
4. Adaptar [las pruebas del mapa](../test/ui/mapa_test.dart) a las nuevas ubicaciones de los contadores. Comprobar que los tres mundos se pueden pulsar sin desplazar en el tamaño de referencia. Actualizar las [capturas de apariencia](../test/ui/apariencia_test.dart) tras revisar ambos temas y ejecutar `flutter analyze` y `flutter test` al implementar.
