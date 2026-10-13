# NaturalMente

App de animales, plantas y cuerpo humano para niños de primaria. Un código en Flutter, para Android y para iOS. No hay servidor ni cuentas.

Si no has visto el proyecto, lee primero [docs/contexto.md](docs/contexto.md). Ahí está la asignatura, el material de ciencias y lo que va a hacer la app. Las carpetas y el reparto están en [docs/organizacion.md](docs/organizacion.md). Las decisiones de alcance (MVP, niveles de dificultad, qué queda fuera) están en [docs/decisiones.md](docs/decisiones.md). Las ideas de juegos, por zona y nivel, están en [docs/juegos.md](docs/juegos.md).

Lo que hay ahora es poco a propósito: el mapa con los tres sitios y el juego del camello. Sirve para comprobar que Flutter, el catálogo y los tests van. El resto se añade en las mismas carpetas.

## Qué hay que tener instalado

No hay que arrancar ninguna base de datos ni ningún backend. Solo Flutter y, según dónde la quieras ver, Chrome o un emulador de Android.

1. Git.
2. Flutter del canal stable (en el ordenador donde se montó el repo está en `C:\Users\'usuario'\flutter`; cada uno puede instalarlo en otra ruta). La guía está en https://docs.flutter.dev/install/windows
3. La carpeta `bin` de Flutter en el PATH del usuario. En PowerShell, para la sesión actual:

```powershell
$env:Path = "C:\Users\'usuario'\flutter\bin;" + $env:Path
```

Cambia la ruta si el SDK está en otro sitio. Para dejarlo fijo, añádela en Variables de entorno de Windows, en Path del usuario, y abre una terminal nueva.

4. Chrome, si vas a verla en el navegador.
5. Android SDK, si vas a emulador o APK. Android Studio lo instala. La ruta habitual es `%LOCALAPPDATA%\Android\Sdk`.

Comprueba que no falta nada:

```powershell
flutter doctor
```

La primera vez en Android hace falta aceptar licencias:

```powershell
flutter doctor --android-licenses
```

iOS no se compila en Windows. Hace falta un Mac con Xcode. En este repo la carpeta `ios/` ya está, para abrirla allí.

## Comandos de cada día

Desde la carpeta del repositorio:

```powershell
flutter pub get
flutter analyze
flutter test
```

`pub get` baja lo que pone `pubspec.yaml`. Hay que lanzarlo al clonar y cuando cambie ese archivo. `analyze` mira el estilo. `test` ejecuta `test/reglas` y `test/ui` sin abrir la app en un móvil.

Verla en Chrome (no se publica; es para trabajar):

```powershell
flutter run -d chrome
```

Con la app en marcha, en esa terminal: `r` recarga cambios de código, `R` la reinicia, `q` la cierra. Un cambio en `pubspec.yaml` no entra con `r`: para y vuelve a lanzar.

Ver emuladores y dispositivos:

```powershell
flutter emulators
flutter devices
flutter emulators --launch 'vuestro_emulador'
flutter run -d android
```

APK para pasar al móvil por cable o por archivo:

```powershell
flutter build apk
```

Sale en `build\app\outputs\flutter-apk\app-release.apk`.

Lo que se sube a Google Play no es el APK, es el app bundle:

```powershell
flutter build appbundle
```

En un Mac, para la App Store:

```powershell
flutter build ipa
```

## Dónde se toca cada cosa

| Carpeta | Para qué | Quién |
| --- | --- | --- |
| `lib/ui/` | Pantallas | David |
| `lib/reglas/` | Frases y aciertos, sin widgets | Iván |
| `lib/datos/` y `lib/modelo/` | Leer el catálogo | Quien añada un campo | Alfredo |
| `content/` | Textos. `catalog.json` lo lee la app | Alfredo |
| `assets/imagenes/` y `assets/icono/` | Dibujos, cuando existan | David |
| `test/` | Pruebas | Diego |
| `android/` e `ios/` | Identificador, icono, firma | Alejandro |
| `web/` | Solo Chrome | No se publica |
| `docs/contexto.md` | Asignatura, ciencias y decisiones | Todos |
| `docs/organizacion.md` | Carpetas, personas y fechas | Todos |
| `docs/decisiones.md` | Decisiones de alcance, con fecha | Todos |
| `docs/juegos.md` | Banco de ideas de juegos, con prioridad y niveles | Todos |

El identificador es `com.naturalmente.naturalmente`. El nombre en el móvil es NaturalMente.
