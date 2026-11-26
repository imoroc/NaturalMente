-- Juegos libres: cada reto puede ser de un tipo distinto (elegir, ordenar,
-- clasificar, unir parejas, completar, tocar en la imagen...). El tipo de cada
-- reto va dentro del contenido; la app valida su forma antes de publicarlo.
-- Los juegos anteriores siguen siendo de opción múltiple o verdadero o falso.

alter table public.juegos drop constraint juegos_plantilla_check;
alter table public.juegos add constraint juegos_plantilla_check
  check (plantilla in ('opcion_multiple', 'verdadero_falso', 'libre'));
