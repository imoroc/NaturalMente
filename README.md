<div align="center">

<img src="assets/icono/icono.png" alt="Natu, guía de NaturalMente" width="110" />

# NaturalMente

**Ciencias de la Naturaleza interactivas para Educación Primaria (1.º a 6.º curso)**

[![Flutter](https://img.shields.io/badge/Flutter-Stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Plataformas](https://img.shields.io/badge/Plataformas-Android%20%7C%20iOS%20%7C%20Web-2E7D32)](#comandos-de-desarrollo-y-compilación)
[![Modo](https://img.shields.io/badge/Arquitectura-100%25%20Offline%20%C2%B7%20Sin%20cuentas-15803D)](#arquitectura-del-proyecto)

</div>

---

## Descripción general

**NaturalMente** es una aplicación educativa de Ciencias de la Naturaleza para niños y niñas de Educación Primaria (**6 a 12 años**), desarrollada en **Flutter** con una única base de código para **Android** e **iOS** (y soporte en navegador para desarrollo). Funciona **100 % en local**, sin servidores, sin cuentas de usuario, sin anuncios y sin recogida de datos personales.

Guiados por **Natu**, los alumnos exploran **3 mundos**, superan **17 juegos interactivos** con **3 niveles de dificultad adaptados por ciclo** (`Fácil · 1.º-2.º`, `Medio · 3.º-4.º` y `Difícil · 5.º-6.º`, sumando **51 misiones**) y coleccionan **58 cromos** con curiosidades científicas en su álbum personal.

### Principios de diseño pedagógico y técnico

- **Aprendizaje sin frustración**: cuando el alumno se equivoca, la app nunca utiliza palabras punitivas (*«error»*, *«incorrecto»*, *«has fallado»*, *«mal hecho»*). En el primer intento fallido ofrece una observación razonada sobre lo elegido; en el segundo intento aporta una pista directa para guiar hacia la respuesta.
- **Progresión real por ciclo escolar**:
  - **Fácil (1.º-2.º)**: identificación visual directa, vocabulario cercano y mecánicas accesibles.
  - **Medio (3.º-4.º)**: ampliación de elementos y preguntas de comprensión tras resolver cada reto.
  - **Difícil (5.º-6.º)**: vocabulario científico de tercer ciclo (vertebrados e invertebrados, fotosíntesis, aparatos y sistemas, cigoto y multiplicación celular) y retos de razonamiento.
- **Catálogo desacoplado de la interfaz**: todo el contenido didáctico, pistas, curiosidades y preguntas reside en [`content/catalog.json`](content/catalog.json), separado de las reglas de evaluación (`lib/reglas/`) y de los componentes visuales (`lib/ui/`).
- **Ilustración vectorial e interactividad propia**: escenarios, laboratorio de germinación, modelo anatómico con colocación por arrastre o toque (*drag & drop* + *tap*) y visor de etapas de la vida renderizados mediante `CustomPainter` en Flutter.

---

## Mundos, actividades y niveles

| Mundo | Actividad | Mecánica principal | Fácil (1.º-2.º) | Medio (3.º-4.º) | Difícil (5.º-6.º) | Cromos (58) |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **La reserva**<br>*(Animales)* | **Cada uno a su hogar** (`hogar`) | Clasificación de animales en su hábitat y adaptaciones al medio | 4 hábitats y 4 animales (*camello, delfín, pingüino, oso*) | 6 hábitats (+ *selva, río*) y 6 animales (+ *rana, tucán*) con pregunta de adaptación | 6 ecosistemas y 7 animales (+ *pulpo*, invertebrado marino) con preguntas de clasificación científica | 7 |
| **La reserva**<br>*(Animales)* | **¿Huevo o barriga?** (`nacimiento`) | Separar animales por cómo nacen y ordenar ciclos de vida, por arrastre o toque | 6 animales al *huevo* o a la *barriga de su madre* (*pingüino, tucán, rana · camello, delfín, oso*) | Ciclos de la *rana* y la *mariposa* en 4 pasos + pregunta de comprensión por ciclo | Metamorfosis de la *rana* en 5 fases y de la *mariposa* (larva, pupa, adulto) + preguntas de razonamiento (anfibio, en qué se parecen) | 3 |
| **La reserva**<br>*(Animales)* | **Picos, dientes y huellas** (`dieta`) | Investigar cada animal con lupa dental, probador de picos y molde de huellas | Herbívoro, carnívoro u omnívoro (*ciervo, lobo, jabalí, conejo, lince, oso pardo*) | Cómo consigue el alimento según pico, dientes y patas (*águila, garza, ardilla, búho, pato cuchara, castor*) | Cómo se desplaza según la huella y la pata + pregunta extra | 3 |
| **La reserva**<br>*(Animales)* | **¿Huesos o caparazón?** (`grupos`) | Clasificar con visor de rayos X, lupa de piel y contador de patas | Vertebrado o invertebrado (6 animales) | Grupos de vertebrados (*mamíferos y aves, reptiles y anfibios, peces*) | Artrópodos, moluscos y anélidos o cnidarios + pregunta extra | 3 |
| **La reserva**<br>*(Ecosistemas)* | **Monta el ecosistema** (`ecosistemas`) | Dar vida a un claro del bosque y descubrir conexiones | Hierba, conejo y zorro por arrastre o toque | Dos relaciones alimentarias con flechas explicadas | Dos predicciones y comparación antes/después | 1 |
| **La reserva**<br>*(Seres vivos)* | **¿Vivo o no vivo?** (`vivo`) | Separar lo vivo de lo que no lo está, por arrastre o toque | 6 cosas del entorno (*gato, piedra, árbol, agua, nube, mariquita*) | 6 casos que despistan (*semilla, seta, fuego, robot, musgo, cristal de sal*) + pregunta «¿por qué?» | 6 seres vivos en su reino (*animales, plantas, hongos, seres muy pequeños*) | 3 |
| **El invernadero**<br>*(Plantas)* | **Haz crecer la semilla** (`germinacion`) | Simulación experimental día a día (Días 1, 3, 5 y 7) en bote transparente | 3 variables (*sustrato, agua, luz*) hasta lograr el brote en tierra o algodón | Experimento de 4 etapas + pregunta final sobre el papel de las sales minerales del suelo | 4 variables (+ *temperatura en °C*) + pregunta científica sobre fotosíntesis y germinación | 3 |
| **El invernadero**<br>*(Plantas)* | **Herbario desmontable** (`herbario`) | Montaje interactivo de las partes de la planta por arrastre o toque | 3 partes (*raíz, tallo, hoja*) sobre el modelo botánico | 5 partes (+ *flor, fruto*) con sus funciones y curiosidades | 5 partes + cuestionario sobre la función de cada órgano vegetal | 5 |
| **El invernadero**<br>*(Plantas)* | **Árbol, arbusto o hierba** (`plantas`) | Llevar plantas del entorno a su grupo | Árbol o hierba (*encina, chopo, césped, amapola*) | Árbol, arbusto o hierba | Además, cultivada o silvestre | 3 |
| **El invernadero**<br>*(Plantas)* | **Polen y semillas viajeras** (`polinizacion`) | Lupa floral, túnel de viento y agua y vuelo de la abeja | Partes de la flor (*cáliz y corola, estambres, pistilo*) | Cómo viaja cada semilla (*viento, agua, animales*) | Con fruto, con piñas o con esporas + pregunta extra | 3 |
| **El invernadero**<br>*(Plantas)* | **Los árboles y las estaciones** (`estaciones`) | Rueda de estaciones, lupa de hojas y climograma | Hoja caduca o perenne (6 árboles) | Forma y textura de la hoja (ancha, dura con cera, aguja) | A qué bosque pertenece cada árbol según el clima + pregunta extra | 3 |
| **El invernadero**<br>*(Plantas)* | **Del huerto a la mesa** (`huerta`) | Corte de la huerta para ver qué parte de la planta comemos | Raíz, hoja o fruto (6 alimentos) | Raíz o tallo, hoja o flor, fruto o semilla | Reservas, cereales, fibras y aceites + pregunta extra | 3 |
| **El cuerpo**<br>*(Cuerpo humano)* | **Cada pieza en su sitio** (`piezas`) | Atlas anatómico interactivo: arrastrar o tocar órganos hacia su cavidad | 3 órganos en 3 zonas: *cerebro* (Cabeza), *corazón* (Pecho) y *estómago* (Abdomen) | 5 piezas en 4 zonas (+ *pulmones* en Pecho y *músculos y huesos* en Extremidades) + reto de función | 6 piezas (+ *intestinos* en Abdomen) + preguntas sobre aparatos y sistemas del cuerpo humano | 6 |
| **El cuerpo**<br>*(Cuerpo humano)* | **El viaje de la comida** (`digestion`) | Llevar un bocado por el aparato digestivo tocando el cuerpo, los botones o arrastrándolo | *Boca* y *barriga*, con tres mordiscos para masticar y el pulmón como despiste | 4 paradas (*boca, esófago, estómago, intestino*) con pulmones y corazón como despistes + pregunta final | 5 partes (+ *intestino delgado y grueso*) + qué pasa en cada parada (*bolo, quimo, absorción, heces*) | 3 |
| **El cuerpo**<br>*(Cuerpo humano)* | **Así empieza una vida** (`vida`) | Línea temporal interactiva con visor de subetapas y explicación biológica | 4 viñetas: *unión de dos células, crecimiento en el útero, nacimiento y cuidados* | 5 fases (*fecundación, embrión con latido, feto con cordón, nacimiento y bebé*) + pregunta vivíparos | 6 fases (*cigoto, multiplicación celular, tejidos y órganos, placenta, parto y crecimiento por etapas*) | 3 |
| **El cuerpo**<br>*(Cuerpo humano)* | **Los cinco sentidos** (`sentidos`) | Unir órganos y situaciones con su sentido | Ojos, orejas, nariz, lengua y piel con su sentido | 6 situaciones de aviso | 5 avisos + pregunta sobre nervios, cerebro y actos reflejos | 3 |
| **El cuerpo**<br>*(Cuerpo humano)* | **¿Me cuida o no?** (`habitos`) | Separar costumbres en «Me cuida» o «No me cuida» | Higiene, merienda y juego | Sueño, pantallas, actividad física y calma | Oído, vista, postura y descanso + qué parte se cuida | 3 |

---

## Arquitectura del proyecto

El proyecto separa estrictamente los **datos curriculares**, el **modelo de dominio**, las **reglas de negocio puras** (testeables sin necesidad de montar widgets) y la **capa de presentación**.

```mermaid
flowchart LR
  subgraph Datos["1. Contenido y Persistencia"]
    JSON["content/catalog.json"]
    PREFS["SharedPreferences\n(Progreso local)"]
  end

  subgraph Dominio["2. Modelo y Acceso a Datos"]
    CAT["lib/datos/catalogo.dart"]
    PROG["lib/datos/progreso.dart"]
    MOD["lib/modelo/\n(Zona, Actividad, Ficha, Herbario)"]
  end

  subgraph Reglas["3. Lógica Pura (Sin Widgets)"]
    RES["lib/reglas/resolver.dart\n(Evaluación, pistas, barajado)"]
  end

  subgraph Interfaz["4. Interfaz Gráfica (Flutter UI)"]
    MAPA["lib/ui/mapa.dart\n(Mundos y Álbum de 31 cromos)"]
    ZONA["lib/ui/zona.dart\n(Misiones del mundo)"]
    JUEGO["lib/ui/juego.dart · herbario.dart · nacimiento.dart · ecosistema.dart · digestion.dart\n(17 juegos · 51 niveles)"]
    DIB["lib/ui/dibujos.dart · planta.dart\n(CustomPainters e ilustraciones)"]
  end

  JSON --> CAT
  PREFS <--> PROG
  CAT --> MOD
  MOD --> RES
  MOD --> Interfaz
  PROG --> Interfaz
  RES --> JUEGO
  DIB --> JUEGO
  DIB --> MAPA
```

### Flujo de navegación y aprendizaje

```mermaid
flowchart TD
  A["Mapa principal (MapaPage)\nProgreso global · Estrellas (24) · Álbum (31 cromos)"] --> B["Pantalla de Mundo (ZonaPage)\nLa reserva · El invernadero · El cuerpo"]
  A --> C["Álbum de Cromos\nFiltro por mundo · Estado bloqueado/desbloqueado · Curiosidades"]
  B --> D["Selector de dificultad\nFácil (1.º-2.º) · Medio (3.º-4.º) · Difícil (5.º-6.º)"]
  D --> E["Actividad interactiva\nArrastrar / Tocar / Experimentar / Ordenar"]
  E -->|1.º fallo| F["Observación contextual razonada"]
  E -->|2.º fallo| G["Pista pedagógica directa de Natu"]
  F --> E
  G --> E
  E -->|Acierto| H["Pregunta de comprensión (Medio/Difícil)\ny Cuaderno de Natu"]
  H --> I["Nivel superado\nSe guarda estrella y se desbloquean cromos del nivel"]
  I --> C
```

---

## Estructura de carpetas y responsabilidades

| Ruta | Propósito | Responsable |
| :--- | :--- | :--- |
| [`lib/ui/`](lib/ui/) | Pantallas, navegación, animaciones e ilustraciones vectoriales (`CustomPainter`) | David |
| [`lib/reglas/`](lib/reglas/) | Evaluación de respuestas, progresión de pistas y barajado sin repetir posición (sin widgets) | Iván |
| [`lib/datos/`](lib/datos/) y [`lib/modelo/`](lib/modelo/) | Carga de `catalog.json`, modelos inmutables y persistencia local de estrellas y cromos | Alfredo / Equipo |
| [`content/`](content/) | Catálogo de juegos, textos pedagógicos (`catalog.json`) y mapa de cobertura (`cobertura.md`) | Alfredo |
| [`lib/ui/dibujos.dart`](lib/ui/dibujos.dart) y [`assets/icono/`](assets/icono/) | Ilustraciones vectoriales de personajes (`Natu`, animales) e icono de la aplicación | David |
| [`test/`](test/) | Pruebas unitarias de catálogo/reglas (`test/datos/`) y pruebas de integración de UI (`test/ui/`) | Diego |
| [`android/`](android/) e [`ios/`](ios/) | Configuración nativa, identificador (`com.naturalmente.naturalmente`), iconos y firmas | Alejandro |
| [`web/`](web/) | Soporte de ejecución local en Chrome durante el desarrollo | Equipo |
| [`docs/`](docs/) | Documentación de contexto, organización, decisiones de alcance y diseño de juegos | Todos |

### Documentación adicional en `docs/`

- **[`docs/contexto.md`](docs/contexto.md)**: objetivos de la asignatura, adecuación curricular y criterios pedagógicos.
- **[`docs/organizacion.md`](docs/organizacion.md)**: reparto detallado de tareas, estructura del proyecto e hitos del calendario.
- **[`docs/decisiones.md`](docs/decisiones.md)**: registro de decisiones de alcance, niveles de dificultad y qué contenidos quedan fuera.
- **[`docs/juegos.md`](docs/juegos.md)**: diseño detallado de las mecánicas de cada actividad por mundo y ciclo.
- **[`docs/plan-herbario.md`](docs/plan-herbario.md)**: especificación técnica y validación de la actividad *Herbario desmontable*.

---

## Requisitos previos e instalación

No es necesario configurar ninguna base de datos ni servidor externo. Basta con disponer de **Flutter** y, según dónde se quiera ejecutar, **Google Chrome** o el **SDK de Android**.

1. **Git** instalado en el sistema.
2. **Flutter SDK** (canal `stable`, con Dart `^3.13.5`). Guía oficial: [docs.flutter.dev/install](https://docs.flutter.dev/install).
3. Añadir la carpeta `bin` de Flutter al `PATH` del usuario. En PowerShell para la sesión actual:

   ```powershell
   $env:Path = "C:\Users\TU_USUARIO\flutter\bin;" + $env:Path
   ```

4. **Google Chrome** (para depuración rápida en web) o **Android Studio / Android SDK** (para emulador Android o generación de APK/AAB). En macOS, **Xcode** para compilar en iOS.

Verifica el entorno ejecutando:

```powershell
flutter doctor
```

Si es la primera vez que usas el SDK de Android en el equipo, acepta las licencias:

```powershell
flutter doctor --android-licenses
```

---

## Comandos de desarrollo y compilación

Desde la raíz del repositorio:

### 1. Instalar dependencias, analizar código y ejecutar tests

```powershell
flutter pub get
dart analyze
flutter test
```

- `flutter pub get`: descarga las dependencias declaradas en [`pubspec.yaml`](pubspec.yaml).
- `dart analyze` / `flutter analyze`: comprueba el tipado estático y las reglas de estilo (`flutter_lints`).
- `flutter test`: ejecuta la batería de pruebas unitarias (catálogo, reglas de los 17 juegos, barajador sin repetición, desbloqueo de los 58 cromos) y pruebas de widgets/flujos completos en pantalla.

### 2. Ejecutar la aplicación en local

Para lanzarla rápidamente en **Chrome** durante el desarrollo:

```powershell
flutter run -d chrome
```

*(Con la app en marcha: pulsa `r` para recarga rápida, `R` para reinicio completo y `q` para salir).*

Para lanzarla en un **emulador de Android** o dispositivo conectado por USB:

```powershell
flutter emulators
flutter emulators --launch <id_emulador>
flutter devices
flutter run -d android
```

### 3. Generar paquetes de distribución (Release)

Para compilar, instalar y abrir una versión optimizada en el Android conectado,
desde Bash (Linux/macOS, con Flutter y el SDK de Android):

```bash
./run-android-release.sh
# Si hay varios dispositivos:
./run-android-release.sh ID_DEL_DISPOSITIVO
```

El [script](run-android-release.sh) usa `--release`, compila solo para la
arquitectura del dispositivo, elimina iconos sin usar, ofusca Dart y separa sus
símbolos. Flutter activa R8 y la reducción de recursos en release. Permite
configurar `FLUTTER_BIN`, `ANDROID_HOME` (o `ANDROID_SDK_ROOT`) y `ANDROID_DEVICE`.
Instala mediante `adb install -r`, conservando el progreso; si falla por firma o
versión, termina sin desinstalar ni borrar datos.

Cada ejecución guarda el APK, los símbolos Dart y los mapas R8 disponibles en
una carpeta propia bajo `build/android-release/`. Conserva esa carpeta para
interpretar errores de esa compilación; `flutter clean` elimina `build/`.
La configuración actual de Gradle firma release con la clave de desarrollo.
Esta versión permite probar las optimizaciones de producción, pero publicar en
Google Play requiere configurar la firma de producción y generar un AAB.

- **APK de Android** (para instalar directamente en un dispositivo o compartir el archivo):

  ```powershell
  flutter build apk
  ```
  *(Salida generada en `build/app/outputs/flutter-apk/app-release.apk`).*

- **Android App Bundle** (formato oficial para publicar en Google Play):

  ```powershell
  flutter build appbundle
  ```

- **Archivo IPA para iOS** (requiere macOS con Xcode):

  ```powershell
  flutter build ipa
  ```

---

<div align="center">
  <sub>Identificador de paquete: <code>com.naturalmente.naturalmente</code> · Nombre de la aplicación: <strong>NaturalMente</strong></sub>
</div>

### Idioma de la app

El botón ES/EN permite elegir **Español** o **English** solo en el mapa principal, debajo de la cabecera de NaturalMente y antes de «Mundos para explorar». Traduce también las fichas, las pistas, los juegos y el álbum. La elección se conserva al cerrar y volver a abrir, y se aplica a toda la app sin borrar el progreso. Español es el idioma inicial.

### Monta el ecosistema

Nueva misión de La reserva con ilustración vectorial propia, tres niveles y un cromo del bosque. Su [plan y validación](docs/plan-ecosistemas.md) describen el recorrido, las comprobaciones y los pendientes en dispositivos. Funciona en ambos idiomas y conserva los requisitos de la medalla.

### Cierre de los juegos

Este comportamiento es obligatorio para todos los juegos y niveles, incluidos los nuevos. Los agentes deben consultar [AGENTS.md](AGENTS.md) y la [guía de implementación de feedback y cierre](docs/feedback-y-cierre.md).

Al superar un nivel, la animación del check verde, el sonido y la vibración dan paso automáticamente a una pantalla de resultado. Muestra el resumen y mantiene visibles las opciones **Cambiar nivel**, **Otra vez** y **Volver al mundo**. El botón de cerrar permite seguir explorando las explicaciones y curiosidades del ejercicio.

Las acciones esperan al guardado; si falla, se ofrece **Guardar de nuevo** sin repetir respuestas ni recompensas. El reto diario conserva su límite de una misión por día y ofrece **Volver al mapa** y **Armario de Natu**. Las pruebas recorren los tres niveles de los 17 juegos y del reto diario, además del guardado, la repetición y la accesibilidad del cierre.
