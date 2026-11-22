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

## Archivos de `assets/`

| Archivo | Añadido | Procedencia y licencia |
| --- | --- | --- |
| `assets/icono/icono.png` | 23 de octubre de 2026 (Iván) | Pendiente de confirmar origen y licencia |
| `assets/mundos/*.webp` | 22 de noviembre de 2026 | Ilustraciones de OpenAI ImageGen. El paisaje de La reserva, los botones de pestaña y cuatro portadas se recortaron de los bocetos seleccionados. Los otros paisajes y portadas se generaron con la misma referencia visual. |
| `assets/sonidos/*.mp3` (acierto, celebracion, descubrimiento, musica, paso1 a paso6, pista, quitar, seleccion, toque) | 23 y 26 de octubre de 2026 (Iván) | Pendiente de confirmar origen y licencia |
| `assets/inicio/*.webp` | 18 de noviembre de 2026 | Ilustraciones creadas con OpenAI ImageGen a partir del boceto aprobado de NaturalMente, incluida la llama de racha. Siluetas recortadas y exportadas a WebP con transparencia para ambos temas. |
| `assets/fuentes/Nunito-*.ttf` | 18 de noviembre de 2026 | Nunito, descargada del repositorio Google Fonts y convertida en pesos estáticos 600 y 900 para el inicio. SIL Open Font License 1.1, incluida en [Nunito-OFL.txt](../assets/fuentes/Nunito-OFL.txt). |

Antes de subir la app a las tiendas hay que completar las dos filas pendientes: de dónde salen el icono y los sonidos, con qué licencia y si piden atribución.

Las imágenes `assets/imagenes/brote_*.png` que citaba la versión anterior de este archivo se retiraron el 23 de octubre de 2026, al rediseñar a Natu con código.
