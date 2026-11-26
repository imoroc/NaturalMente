# Procedencia de los recursos

Inventario de lo que la app muestra o hace sonar y de dónde sale. Actualizado el 18 de noviembre de 2026.

## Ilustraciones dibujadas con código

Las ilustraciones vectoriales de Natu, los juegos y las fichas se dibujaron expresamente para NaturalMente con código Flutter. No incorporan material de terceros. Las ilustraciones rasterizadas del inicio se registran aparte. El código de los dibujos vectoriales está en el repositorio:

| Archivo | Qué dibuja |
| --- | --- |
| `lib/ui/dibujos.dart` | Animales, hábitats, iconos de sitios y cromos generales |
| `lib/ui/dibujos_natu.dart` | La mascota Natu, sus gestos y la bandeja de «¿Me cuida o no?» |
| `lib/ui/dibujos_nuevos_juegos.dart` | Picos, dientes y huellas; ¿Huesos o caparazón?; Polen y semillas; Los árboles y las estaciones; Del huerto a la mesa |
| `lib/ui/dibujos_nacimiento.dart` | ¿Huevo o barriga? y los ciclos de vida |
| `lib/ui/dibujos_digestion.dart` | El viaje de la comida |
| `lib/ui/dibujos_sentidos.dart` | Los cinco sentidos |
| `lib/ui/dibujos_plantas.dart` y `lib/ui/planta.dart` | Herbario, germinación y grupos de plantas |
| `lib/ui/escena_ecosistema.dart` | Monta el ecosistema: claro del bosque, hierba, conejo y zorro |
| `lib/ui/dibujos_vivo.dart` | ¿Vivo o no vivo? |
| `lib/ui/dibujos_plato.dart` | Un plato que cuida: alimentos, etiquetas, plato y merienda |
| `lib/ui/dibujos_carrera.dart` | Carrera de relevos: fondos de los tramos y la lupa de Difícil |
| `lib/ui/dibujos_linterna.dart` | Linterna y microscopio: el niño, la cara, el esqueleto con rayos X, las células y la oscuridad con la luz |
| `lib/ui/dibujos_pelicula.dart` | La película de la planta: semillas, brotes, plantas, flores, frutos, la abeja, el viento, el pájaro y la ardilla |
| `lib/ui/dibujos_oscuras.dart` | La planta a oscuras: el cuarto con ventana y armario, la caja con agujero, la judía, la mariposa y la hoja |

## Archivos de `assets/`

| Archivo | Añadido | Procedencia y licencia |
| --- | --- | --- |
| `assets/icono/icono.png` | 23 de octubre de 2026 (Iván) | Pendiente de confirmar origen y licencia |
| `assets/mundos/*.webp` | 22 de noviembre de 2026 | Ilustraciones de OpenAI ImageGen. El paisaje de La reserva, los botones de pestaña y cuatro portadas se recortaron de los bocetos seleccionados. Los otros paisajes y portadas se generaron con la misma referencia visual. |
| `assets/mundos/carrera.webp` | 25 de noviembre de 2026 | Portada de «Carrera de relevos» montada a partir del libro abierto de `quien-soy.webp` (OpenAI ImageGen): se taparon las páginas y se pusieron el conejo y el gorrión de `lib/ui/dibujos_nuevos_juegos.dart` y una bandera de meta dibujada a mano. |
| `assets/mundos/linterna.webp` | 25 de noviembre de 2026 | Portada de «Linterna y microscopio» montada sobre el libro abierto de `carrera.webp`: se taparon las páginas y se pusieron dos escenas de `lib/ui/dibujos_linterna.dart` (el niño con la linterna y la célula con el microscopio). |
| `assets/mundos/pelicula.webp` | 26 de noviembre de 2026 | Portada de «La película de la planta» montada sobre el libro abierto de `linterna.webp`: se taparon las páginas con dos fotogramas del girasol de `lib/ui/dibujos_pelicula.dart`. |
| `assets/mundos/oscuras.webp` | 26 de noviembre de 2026 | Portada de «La planta a oscuras» montada sobre el libro abierto de `linterna.webp`: se taparon las páginas con el armario y la ventana de `lib/ui/dibujos_oscuras.dart`. |
| `assets/cromos/*.webp` | 23 de noviembre de 2026 | Arte de OpenAI ImageGen, generado o recortado de los bocetos seleccionados para el cierre, la portada del álbum y el cromo del camello. |
| `assets/sonidos/*.mp3` (acierto, celebracion, descubrimiento, musica, paso1 a paso6, pista, quitar, seleccion, toque) | 23 y 26 de octubre de 2026 (Iván) | Pendiente de confirmar origen y licencia |
| `assets/inicio/*.webp` | 18 de noviembre de 2026 | Ilustraciones creadas con OpenAI ImageGen a partir del boceto aprobado de NaturalMente, incluida la llama de racha. Siluetas recortadas y exportadas a WebP con transparencia para ambos temas. |
| `assets/fuentes/Nunito-*.ttf` | 18 de noviembre de 2026 | Nunito, descargada del repositorio Google Fonts y convertida en pesos estáticos 600 y 900 para el inicio. SIL Open Font License 1.1, incluida en [Nunito-OFL.txt](../assets/fuentes/Nunito-OFL.txt). |

Antes de subir la app a las tiendas hay que completar las dos filas pendientes: de dónde salen el icono y los sonidos, con qué licencia y si piden atribución.

Las imágenes `assets/imagenes/brote_*.png` que citaba la versión anterior de este archivo se retiraron el 23 de octubre de 2026, al rediseñar a Natu con código.
