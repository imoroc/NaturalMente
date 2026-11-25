-- Pruebas de permisos y reglas de Aula. Se ejecutan con `supabase test db`.
begin;
create extension if not exists pgtap with schema extensions;
select plan(42);

-- Identidades de prueba ----------------------------------------------------
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-0000000000a1', 'luis@colegio.es'),     -- profesor
  ('00000000-0000-0000-0000-0000000000b1', 'curioso@ejemplo.com'), -- adulto sin permisos
  ('00000000-0000-0000-0000-0000000000d1', null),                  -- tablet del aula
  ('00000000-0000-0000-0000-0000000000d2', null),                  -- tablet de casa
  ('00000000-0000-0000-0000-0000000000d3', null);                  -- dispositivo ajeno
insert into public.profesores (id, usuario, nombre)
values ('00000000-0000-0000-0000-0000000000a1', 'profe.luis', 'Luis');

create temp table guardado (clave text primary key, valor text);
grant all on guardado to anon, authenticated;

create function pg_temp.como(usuario uuid) returns void language sql as $$
  select set_config('role', 'authenticated', true);
  select set_config('request.jwt.claims',
    json_build_object('sub', usuario, 'role', 'authenticated')::text, true);
$$;

-- Juegos -------------------------------------------------------------------
select pg_temp.como('00000000-0000-0000-0000-0000000000a1');

select lives_ok($$
  insert into public.juegos (id, titulo, plantilla, cursos, contenido, estado) values
    ('00000000-0000-0000-0000-00000000f001', 'Animales de 3º', 'opcion_multiple', '{3}', '{"preguntas": []}', 'publicado'),
    ('00000000-0000-0000-0000-00000000f002', 'Plantas de 4º', 'verdadero_falso', '{4}', '{"preguntas": []}', 'publicado'),
    ('00000000-0000-0000-0000-00000000f003', 'Borrador', 'opcion_multiple', '{3}', '{"preguntas": []}', 'borrador')
$$, 'el profesor crea juegos');

select is(
  (select count(*)::int from public.juegos), 3,
  'el profesor ve también sus borradores'
);

update public.juegos set contenido = '{"preguntas": [1]}'
where id = '00000000-0000-0000-0000-00000000f001';
select is(
  (select version from public.juegos where id = '00000000-0000-0000-0000-00000000f001'), 2,
  'cambiar el contenido crea una versión nueva'
);
update public.juegos set titulo = 'Animales de 3º A'
where id = '00000000-0000-0000-0000-00000000f001';
select is(
  (select version from public.juegos where id = '00000000-0000-0000-0000-00000000f001'), 2,
  'cambiar solo el título no cambia la versión'
);

-- Los autoguardados del borrador no crean versiones; publicar sí cuenta.
update public.juegos set contenido = '{"preguntas": [1]}'
where id = '00000000-0000-0000-0000-00000000f003';
update public.juegos set contenido = '{"preguntas": [1, 2]}'
where id = '00000000-0000-0000-0000-00000000f003';
select is(
  (select version from public.juegos where id = '00000000-0000-0000-0000-00000000f003'), 1,
  'editar un borrador no crea versiones'
);
update public.juegos set estado = 'publicado'
where id = '00000000-0000-0000-0000-00000000f003';
select is(
  (select version from public.juegos where id = '00000000-0000-0000-0000-00000000f003'), 1,
  'la primera publicación es la versión 1'
);
update public.juegos set estado = 'borrador'
where id = '00000000-0000-0000-0000-00000000f003';
update public.juegos set estado = 'publicado'
where id = '00000000-0000-0000-0000-00000000f003';
select is(
  (select version from public.juegos where id = '00000000-0000-0000-0000-00000000f003'), 1,
  'retirar y volver a publicar lo mismo no da semillas otra vez'
);
update public.juegos set estado = 'borrador', contenido = '{"preguntas": [3]}'
where id = '00000000-0000-0000-0000-00000000f003';
update public.juegos set estado = 'publicado'
where id = '00000000-0000-0000-0000-00000000f003';
select is(
  (select version from public.juegos where id = '00000000-0000-0000-0000-00000000f003'), 2,
  'publicar contenido nuevo tras retirarlo sí es una versión nueva'
);
update public.juegos set estado = 'borrador'
where id = '00000000-0000-0000-0000-00000000f003';

select throws_ok($$
  insert into public.juegos (titulo, plantilla, cursos, contenido)
  values ('Curso imposible', 'opcion_multiple', '{7}', '{}')
$$, '23514', null, 'los cursos van de 1º a 6º');

select pg_temp.como('00000000-0000-0000-0000-0000000000b1');
select throws_ok($$
  insert into public.juegos (titulo, plantilla, cursos, contenido)
  values ('Intruso', 'opcion_multiple', '{3}', '{}')
$$, '42501', null, 'quien no es profesor no crea juegos');
select is(
  (select count(*)::int from public.juegos), 2,
  'los demás solo ven juegos publicados'
);
select is_empty($$
  update public.juegos set titulo = 'Cambiado' returning id
$$, 'nadie más cambia los juegos del profesor');

select pg_temp.como('00000000-0000-0000-0000-0000000000d1');
select results_eq($$
  select titulo from public.juegos where cursos @> '{3}' order by titulo
$$, $$ values ('Animales de 3º A') $$, 'Aula filtra por curso y oculta borradores');

reset role;
set local role anon;
select is(
  (select count(*)::int from public.juegos), 2,
  'sin sesión también se ven los juegos publicados'
);
select throws_ok($$ select * from public.perfiles $$, '42501', null,
  'sin sesión no se leen perfiles');

-- Perfiles y llave mágica --------------------------------------------------
reset role;
select pg_temp.como('00000000-0000-0000-0000-0000000000d1');

insert into guardado
select 'perfil', id::text from public.crear_perfil('zorro', 'veloz', 'azul', 3::smallint);
select is(
  (select count(*)::int from public.perfiles), 1,
  'el dispositivo ve el perfil que acaba de crear'
);
select throws_ok($$ select llave_hash from public.perfiles $$, '42501', null,
  'la llave cifrada no se puede leer');
select throws_ok($$ update public.perfiles set llave_hash = 'x' $$, '42501', null,
  'la llave no se puede cambiar a mano');

-- La llave en claro solo se conoce al crearla: la regeneramos para la prueba.
insert into guardado
select 'llave', public.cambiar_llave((select valor::uuid from guardado where clave = 'perfil'));
select matches(
  (select valor from guardado where clave = 'llave'),
  '^[a-z]+-[a-z]+-[a-z]+-[0-9]{2}$',
  'la llave son tres dibujos y un número'
);

select pg_temp.como('00000000-0000-0000-0000-0000000000d2');
select is(
  (select count(*)::int from public.perfiles), 0,
  'otro dispositivo no ve perfiles ajenos'
);
select is_empty($$ select * from public.canjear_llave('zorro', 'veloz', 'sol-sol-sol-00') $$,
  'una llave equivocada no vincula nada');
select is_empty($$ select * from public.canjear_llave('lobo', 'veloz',
  (select valor from guardado where clave = 'llave')) $$,
  'hace falta el mote además de la llave');
select results_eq($$
  select animal, adjetivo, color, curso from public.canjear_llave('zorro', 'veloz',
    upper(' ' || (select valor from guardado where clave = 'llave') || ' '))
$$, $$ values ('zorro', 'veloz', 'azul', 3::smallint) $$,
  'con mote y llave se recupera el perfil, sin importar mayúsculas ni espacios');
select is(
  (select count(*)::int from public.perfiles), 1,
  'el segundo dispositivo ya ve el perfil'
);
update public.perfiles set color = 'rojo', traje = 'explorador';
select is(
  (select color from public.perfiles), 'rojo',
  'cualquier dispositivo vinculado cambia el color de Natu'
);

select pg_temp.como('00000000-0000-0000-0000-0000000000d3');
select lives_ok($$
  select public.canjear_llave('zorro', 'veloz', 'sol-sol-sol-0' || n) from generate_series(1, 4) n
$$, 'se permiten algunos intentos fallidos');
select is_empty($$ select * from public.canjear_llave('zorro', 'veloz', 'sol-sol-sol-05') $$,
  'el quinto intento todavía se atiende');
select throws_ok($$ select * from public.canjear_llave('zorro', 'veloz', 'sol-sol-sol-06') $$,
  'P0001', 'demasiados_intentos', 'a partir del sexto intento en una hora se bloquea');

-- Resultados ---------------------------------------------------------------
select pg_temp.como('00000000-0000-0000-0000-0000000000d1');

select lives_ok($$
  insert into public.resultados (perfil_id, juego_id, version, aciertos, total, id_local)
  values ((select valor::uuid from guardado where clave = 'perfil'),
          '00000000-0000-0000-0000-00000000f001', 2, 3, 4, 'partida-0001')
$$, 'el dispositivo envía el resultado de su perfil');
select lives_ok($$
  insert into public.resultados (perfil_id, juego_id, version, aciertos, total, id_local)
  values ((select valor::uuid from guardado where clave = 'perfil'),
          '00000000-0000-0000-0000-00000000f001', 2, 3, 4, 'partida-0001')
  on conflict (perfil_id, id_local) do nothing
$$, 'reenviar el mismo resultado no lo duplica');
select is(
  (select count(*)::int from public.resultados), 1,
  'el resultado reenviado cuenta una vez'
);
select throws_ok($$
  insert into public.resultados (perfil_id, juego_id, version, aciertos, total, id_local)
  values ((select valor::uuid from guardado where clave = 'perfil'),
          '00000000-0000-0000-0000-00000000f003', 1, 1, 1, 'partida-0002')
$$, '42501', null, 'no se envían resultados de borradores');
select throws_ok($$
  insert into public.resultados (perfil_id, juego_id, version, aciertos, total, id_local)
  values ((select valor::uuid from guardado where clave = 'perfil'),
          '00000000-0000-0000-0000-00000000f001', 3, 1, 1, 'partida-0003')
$$, '42501', null, 'no se envían resultados de versiones que no existen');
select throws_ok($$
  insert into public.resultados (perfil_id, juego_id, version, aciertos, total, id_local)
  values ((select valor::uuid from guardado where clave = 'perfil'),
          '00000000-0000-0000-0000-00000000f001', 2, 5, 4, 'partida-0004')
$$, '23514', null, 'no se aceptan más aciertos que preguntas');

select pg_temp.como('00000000-0000-0000-0000-0000000000d3');
select throws_ok($$
  insert into public.resultados (perfil_id, juego_id, version, aciertos, total, id_local)
  values ((select valor::uuid from guardado where clave = 'perfil'),
          '00000000-0000-0000-0000-00000000f001', 2, 4, 4, 'partida-0005')
$$, '42501', null, 'no se envían resultados en nombre de otro');

-- Ranking ------------------------------------------------------------------
select pg_temp.como('00000000-0000-0000-0000-0000000000d1');
select results_eq($$
  select posicion, animal, adjetivo, color, puntos, juegos, es_mio
  from public.ranking(3::smallint, 'siempre')
$$, $$ values (1, 'zorro', 'veloz', 'rojo', 85, 1, true) $$,
  'el ranking suma el mejor intento (75) y 10 por participar');

select pg_temp.como('00000000-0000-0000-0000-0000000000d3');
select results_eq($$ select es_mio from public.ranking(3::smallint, 'semana') $$,
  $$ values (false) $$, 'en el ranking de otro no aparece como suyo');

-- Panel del profesor -------------------------------------------------------
select pg_temp.como('00000000-0000-0000-0000-0000000000a1');
select is(
  (select count(*)::int from public.resultados), 1,
  'el profesor ve los resultados de sus juegos'
);
select results_eq($$ select animal, adjetivo from public.perfiles $$,
  $$ values ('zorro', 'veloz') $$, 'y el mote de quien los ha jugado');
update public.ajustes set ranking_activo = false;
select is_empty($$ select * from public.ranking(3::smallint, 'siempre') $$,
  'el profesor puede apagar el ranking');

reset role;
set local role anon;
select is(public.correo_profesor(' Profe.Luis '), 'luis@colegio.es',
  'el panel traduce el nombre de usuario a su correo');

-- Cambiar la llave expulsa a los demás dispositivos -------------------------
reset role;
select pg_temp.como('00000000-0000-0000-0000-0000000000d1');
select public.cambiar_llave((select valor::uuid from guardado where clave = 'perfil'));
select pg_temp.como('00000000-0000-0000-0000-0000000000d2');
select is(
  (select count(*)::int from public.perfiles), 0,
  'tras cambiar la llave, el otro dispositivo deja de tener el perfil'
);

select * from finish();
rollback;
