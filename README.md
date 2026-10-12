# NaturalMente

App para niños de primaria, en español, sobre animales, plantas y el cuerpo humano. Se juega en cualquier orden. Si la respuesta no encaja, el juego explica qué pasa, no dice solo que está mal.

Se hace en **Flutter**: un código para Android e iOS. No hay servidor ni cuentas. La entrega de diciembre es la app **publicada** en las dos tiendas, no un prototipo.

El plan completo está en [docs/plan.md](docs/plan.md). Este archivo solo dice por dónde se entra.

## Decisiones que ya no se discuten

- Flutter, no otra tecnología.
- Tres bloques igual de importantes: animales, plantas y cuerpo humano.
- La Tierra y el universo no salen. La tierra del suelo, la de una maceta, sí.
- Materia, energía y fuerzas no son un bloque. Como mucho, una frase dentro de otro juego.
- El curso (1º-2º, 3º-4º, 5º-6º) es una etiqueta. Nadie se queda sin poder abrir una actividad.
- La reproducción humana entra, dentro del cuerpo, con lenguaje de primaria.
- No es una app de un solo colegio. Tiene que servir a cualquier niño de primaria en España.
- No se copia el libro de la editorial. Las guías solo nos dicen qué temas existen.
- Somos cinco. No hay tutoría intermedia. La fecha es diciembre de 2026.

## Quién hace qué

| Persona | Se ocupa de | Primera tarea, esta semana |
| --- | --- | --- |
| David | Pantallas, aspecto y animación | Proponer colores y un personaje original, sin copiar el libro |
| Iván | Reglas de los juegos y frases de las pistas | Revisar los tres juegos principales en `docs/plan.md` y anotar si falta alguno |
| Alejandro | Proyecto Flutter, Android, iOS y tiendas | Crear el proyecto Flutter en este repo y empezar las cuentas de Google Play y Apple |
| Alfredo | Fichas y textos | Completar la lista de [content/cobertura.md](content/cobertura.md) con títulos propios |
| Diego | Pruebas | Leer la lista de pruebas del plan y dejarla como guion cuando exista el proyecto |

Unas 70 horas cada uno hasta el 7 de diciembre. El reparto semana a semana está en el plan.

## Cuando exista el proyecto Flutter

```bash
flutter pub get
flutter test
flutter run
```

Android de prueba: `flutter build apk`. Para la tienda: `flutter build appbundle`. iOS: `flutter build ipa`, y hace falta un Mac.
