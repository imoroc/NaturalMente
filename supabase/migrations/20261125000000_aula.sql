-- Aula: juegos del profesor, perfiles de niños sin datos personales,
-- resultados y ranking por curso.
--
-- Quién es quién:
--   * Profesor: usuario de Auth con fila en `profesores` (la crea un script
--     de administración; no hay registro abierto que dé permisos).
--   * Dispositivo: cada app entra como usuario anónimo de Auth. Solo ve los
--     perfiles que tiene vinculados en `dispositivo_perfil`.
--   * Perfil: un niño. Mote generado, color de su Natu y curso. Nada más.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Profesorado
-- ---------------------------------------------------------------------------

create table public.profesores (
  id uuid primary key references auth.users (id) on delete cascade,
  usuario text not null unique check (usuario ~ '^[a-z0-9._-]{3,30}$'),
  nombre text not null check (char_length(nombre) between 1 and 80),
  creado timestamptz not null default now()
);

alter table public.profesores enable row level security;

create function public.es_profesor()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.profesores where id = auth.uid());
$$;

create policy "cada profesor ve su ficha"
  on public.profesores for select
  to authenticated
  using (id = auth.uid());

-- El panel acepta nombre de usuario o correo. Con el usuario, pide aquí el
-- correo con el que inicia sesión en Auth.
create function public.correo_profesor(p_usuario text)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select u.email
  from public.profesores p
  join auth.users u on u.id = p.id
  where p.usuario = lower(trim(p_usuario));
$$;

revoke execute on function public.correo_profesor(text) from public;
grant execute on function public.correo_profesor(text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Ajustes generales que el profesor cambia desde el panel
-- ---------------------------------------------------------------------------

create table public.ajustes (
  id boolean primary key default true check (id),
  ranking_activo boolean not null default true,
  actualizado timestamptz not null default now()
);

insert into public.ajustes default values;

alter table public.ajustes enable row level security;

create policy "todos leen los ajustes"
  on public.ajustes for select
  to anon, authenticated
  using (true);

create policy "el profesorado cambia los ajustes"
  on public.ajustes for update
  to authenticated
  using ((select public.es_profesor()))
  with check ((select public.es_profesor()));

-- ---------------------------------------------------------------------------
-- Juegos creados con plantillas
-- ---------------------------------------------------------------------------

create table public.juegos (
  id uuid primary key default gen_random_uuid(),
  profesor_id uuid not null default auth.uid()
    references public.profesores (id) on delete cascade,
  -- Para cuando haya más de un profesor y códigos de clase.
  clase_id uuid,
  titulo text not null check (char_length(trim(titulo)) between 1 and 120),
  plantilla text not null check (
    plantilla in (
      'opcion_multiple', 'verdadero_falso', 'clasificar', 'ordenar', 'parejas'
    )
  ),
  version integer not null default 1 check (version > 0),
  cursos smallint[] not null check (
    cardinality(cursos) between 1 and 6
    and cursos <@ array[1, 2, 3, 4, 5, 6]::smallint[]
  ),
  contenido jsonb not null check (jsonb_typeof(contenido) = 'object'),
  tema jsonb not null default '{}'::jsonb check (jsonb_typeof(tema) = 'object'),
  estado text not null default 'borrador'
    check (estado in ('borrador', 'publicado')),
  disponible_desde timestamptz,
  disponible_hasta timestamptz,
  creado timestamptz not null default now(),
  actualizado timestamptz not null default now(),
  check (
    disponible_desde is null or disponible_hasta is null
    or disponible_desde < disponible_hasta
  )
);

create index juegos_cursos_idx on public.juegos using gin (cursos);

-- Cada cambio de contenido es una versión nueva: los resultados guardan con
-- qué versión se jugó y las semillas se dan una vez por versión.
create function private.versionar_juego()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.actualizado := now();
  if new.contenido is distinct from old.contenido
     or new.plantilla is distinct from old.plantilla then
    new.version := old.version + 1;
  else
    new.version := old.version;
  end if;
  new.profesor_id := old.profesor_id;
  new.creado := old.creado;
  return new;
end;
$$;

create trigger versionar_juego
  before update on public.juegos
  for each row execute function private.versionar_juego();

alter table public.juegos enable row level security;

create policy "los juegos publicados y disponibles son públicos"
  on public.juegos for select
  to anon, authenticated
  using (
    estado = 'publicado'
    and (disponible_desde is null or disponible_desde <= now())
    and (disponible_hasta is null or disponible_hasta > now())
  );

create policy "el profesor ve todos sus juegos"
  on public.juegos for select
  to authenticated
  using (profesor_id = auth.uid());

create policy "el profesor crea juegos"
  on public.juegos for insert
  to authenticated
  with check ((select public.es_profesor()) and profesor_id = auth.uid());

create policy "el profesor cambia sus juegos"
  on public.juegos for update
  to authenticated
  using (profesor_id = auth.uid())
  with check (profesor_id = auth.uid());

create policy "el profesor borra sus juegos"
  on public.juegos for delete
  to authenticated
  using (profesor_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Perfiles de niños y dispositivos
-- ---------------------------------------------------------------------------

create table public.perfiles (
  id uuid primary key default gen_random_uuid(),
  animal text not null check (animal ~ '^[a-z]{2,20}$'),
  adjetivo text not null check (adjetivo ~ '^[a-z]{2,20}$'),
  color text not null check (color ~ '^[a-z]{2,20}$'),
  curso smallint check (curso between 1 and 6),
  traje text not null default 'ninguno' check (traje ~ '^[a-z0-9_]{1,40}$'),
  pose text not null default 'hola' check (pose ~ '^[a-z0-9_]{1,40}$'),
  llave_hash text not null,
  -- Para cuando haya códigos de clase.
  clase_id uuid,
  creado timestamptz not null default now()
);

create index perfiles_mote_idx on public.perfiles (animal, adjetivo);
create index perfiles_curso_idx on public.perfiles (curso);

create table public.dispositivo_perfil (
  dispositivo_id uuid not null references auth.users (id) on delete cascade,
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  desde timestamptz not null default now(),
  primary key (dispositivo_id, perfil_id)
);

create index dispositivo_perfil_perfil_idx on public.dispositivo_perfil (perfil_id);

create function public.perfil_vinculado(p_perfil uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.dispositivo_perfil
    where dispositivo_id = auth.uid() and perfil_id = p_perfil
  );
$$;

alter table public.perfiles enable row level security;
alter table public.dispositivo_perfil enable row level security;

-- La llave nunca sale de la base de datos, ni cifrada.
revoke all on public.perfiles from anon, authenticated;
grant select (id, animal, adjetivo, color, curso, traje, pose, clase_id, creado)
  on public.perfiles to authenticated;
grant update (animal, adjetivo, color, curso, traje, pose)
  on public.perfiles to authenticated;
grant delete on public.perfiles to authenticated;

create policy "el dispositivo ve sus perfiles"
  on public.perfiles for select
  to authenticated
  using ((select public.perfil_vinculado(id)));

create policy "el dispositivo cambia sus perfiles"
  on public.perfiles for update
  to authenticated
  using ((select public.perfil_vinculado(id)))
  with check ((select public.perfil_vinculado(id)));

-- Borrar el perfil borra en cascada sus resultados (derecho de supresión).
create policy "el dispositivo borra sus perfiles"
  on public.perfiles for delete
  to authenticated
  using ((select public.perfil_vinculado(id)));

revoke all on public.dispositivo_perfil from anon, authenticated;
grant select, delete on public.dispositivo_perfil to authenticated;

create policy "el dispositivo ve sus vínculos"
  on public.dispositivo_perfil for select
  to authenticated
  using (dispositivo_id = auth.uid());

create policy "el dispositivo se desvincula"
  on public.dispositivo_perfil for delete
  to authenticated
  using (dispositivo_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Llave mágica: 3 dibujos y un número para recuperar el perfil en otro
-- dispositivo.
-- ---------------------------------------------------------------------------

create table private.intentos_llave (
  dispositivo_id uuid not null,
  momento timestamptz not null default now()
);

create index intentos_llave_idx on private.intentos_llave (dispositivo_id, momento);

create function private.generar_llave()
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  dibujos constant text[] := array[
    'zorro', 'pino', 'nube', 'sol', 'luna', 'flor', 'hoja', 'pez',
    'rana', 'seta', 'estrella', 'gota', 'abeja', 'caracol', 'arcoiris', 'montana'
  ];
  azar bytea := extensions.gen_random_bytes(5);
begin
  -- 256 es múltiplo de 16: cada dibujo sale con la misma probabilidad.
  return dibujos[1 + get_byte(azar, 0) % 16] || '-'
    || dibujos[1 + get_byte(azar, 1) % 16] || '-'
    || dibujos[1 + get_byte(azar, 2) % 16] || '-'
    || lpad(((get_byte(azar, 3) * 256 + get_byte(azar, 4)) % 100)::text, 2, '0');
end;
$$;

create function private.normalizar_llave(p_llave text)
returns text
language sql
immutable
set search_path = ''
as $$
  select lower(regexp_replace(trim(p_llave), '\s+', '', 'g'));
$$;

-- Llave nueva que no coincide con la de otro perfil con el mismo mote.
create function private.llave_libre(p_animal text, p_adjetivo text)
returns text
language plpgsql
volatile
set search_path = ''
as $$
declare
  llave text;
begin
  for intento in 1..30 loop
    llave := private.generar_llave();
    if not exists (
      select 1 from public.perfiles
      where animal = p_animal and adjetivo = p_adjetivo
        and llave_hash = extensions.crypt(llave, llave_hash)
    ) then
      return llave;
    end if;
  end loop;
  raise exception 'sin_llave_libre';
end;
$$;

-- Crea el perfil en la nube, lo vincula a este dispositivo y devuelve la
-- llave en claro una sola vez para que la app la guarde y la enseñe.
create function public.crear_perfil(
  p_animal text,
  p_adjetivo text,
  p_color text,
  p_curso smallint default null
)
returns table (id uuid, llave text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  nueva text;
  perfil uuid;
begin
  if auth.uid() is null then
    raise exception 'sin_sesion' using errcode = '42501';
  end if;
  nueva := private.llave_libre(p_animal, p_adjetivo);
  insert into public.perfiles (animal, adjetivo, color, curso, llave_hash)
  values (
    p_animal, p_adjetivo, p_color, p_curso,
    extensions.crypt(nueva, extensions.gen_salt('bf', 8))
  )
  returning perfiles.id into perfil;
  insert into public.dispositivo_perfil (dispositivo_id, perfil_id)
  values (auth.uid(), perfil);
  return query select perfil, nueva;
end;
$$;

-- Vincula este dispositivo al perfil con ese mote y esa llave. Devuelve
-- vacío si no coincide. Como mucho 5 intentos por hora y dispositivo.
create function public.canjear_llave(
  p_animal text,
  p_adjetivo text,
  p_llave text
)
returns table (
  id uuid, animal text, adjetivo text, color text, curso smallint,
  traje text, pose text
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  limpia text := private.normalizar_llave(p_llave);
  encontrado uuid;
begin
  if auth.uid() is null then
    raise exception 'sin_sesion' using errcode = '42501';
  end if;
  if (
    select count(*) from private.intentos_llave
    where dispositivo_id = auth.uid() and momento > now() - interval '1 hour'
  ) >= 5 then
    raise exception 'demasiados_intentos' using errcode = 'P0001',
      hint = 'Espera una hora antes de volver a probar.';
  end if;
  insert into private.intentos_llave (dispositivo_id) values (auth.uid());

  select p.id into encontrado
  from public.perfiles p
  where p.animal = p_animal and p.adjetivo = p_adjetivo
    and p.llave_hash = extensions.crypt(limpia, p.llave_hash)
  limit 1;

  if encontrado is null then
    return;
  end if;

  insert into public.dispositivo_perfil (dispositivo_id, perfil_id)
  values (auth.uid(), encontrado)
  on conflict do nothing;
  -- Acertar no gasta intentos.
  delete from private.intentos_llave
  where ctid = (
    select ctid from private.intentos_llave
    where dispositivo_id = auth.uid()
    order by momento desc limit 1
  );
  return query
    select p.id, p.animal, p.adjetivo, p.color, p.curso, p.traje, p.pose
    from public.perfiles p where p.id = encontrado;
end;
$$;

-- Llave nueva para el perfil. Los demás dispositivos dejan de tenerlo.
create function public.cambiar_llave(p_perfil uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  p public.perfiles;
  nueva text;
begin
  if not public.perfil_vinculado(p_perfil) then
    raise exception 'perfil_ajeno' using errcode = '42501';
  end if;
  select * into p from public.perfiles where id = p_perfil;
  nueva := private.llave_libre(p.animal, p.adjetivo);
  update public.perfiles
  set llave_hash = extensions.crypt(nueva, extensions.gen_salt('bf', 8))
  where id = p_perfil;
  delete from public.dispositivo_perfil
  where perfil_id = p_perfil and dispositivo_id <> auth.uid();
  return nueva;
end;
$$;

revoke execute on function public.crear_perfil(text, text, text, smallint) from public, anon;
revoke execute on function public.canjear_llave(text, text, text) from public, anon;
revoke execute on function public.cambiar_llave(uuid) from public, anon;
grant execute on function public.crear_perfil(text, text, text, smallint) to authenticated;
grant execute on function public.canjear_llave(text, text, text) to authenticated;
grant execute on function public.cambiar_llave(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- Resultados
-- ---------------------------------------------------------------------------

create table public.resultados (
  id uuid primary key default gen_random_uuid(),
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  juego_id uuid not null references public.juegos (id) on delete cascade,
  version integer not null check (version > 0),
  aciertos integer not null check (aciertos >= 0),
  total integer not null check (total > 0 and total <= 200),
  respuestas jsonb not null default '[]'::jsonb
    check (jsonb_typeof(respuestas) = 'array'),
  jugado timestamptz not null default now(),
  -- La app reintenta los envíos pendientes: el mismo id no se cuenta dos veces.
  id_local text not null check (char_length(id_local) between 8 and 64),
  unique (perfil_id, id_local),
  check (aciertos <= total)
);

create index resultados_juego_idx on public.resultados (juego_id);
create index resultados_perfil_jugado_idx on public.resultados (perfil_id, jugado);

alter table public.resultados enable row level security;

revoke update on public.resultados from anon, authenticated;

create policy "el dispositivo envía resultados de sus perfiles"
  on public.resultados for insert
  to authenticated
  with check (
    (select public.perfil_vinculado(resultados.perfil_id))
    and resultados.jugado <= now() + interval '5 minutes'
    and exists (
      select 1 from public.juegos j
      where j.id = resultados.juego_id
        and j.estado = 'publicado'
        and resultados.version <= j.version
    )
  );

create policy "el dispositivo ve los resultados de sus perfiles"
  on public.resultados for select
  to authenticated
  using ((select public.perfil_vinculado(perfil_id)));

create policy "el profesor ve los resultados de sus juegos"
  on public.resultados for select
  to authenticated
  using (
    exists (
      select 1 from public.juegos j
      where j.id = resultados.juego_id and j.profesor_id = auth.uid()
    )
  );

-- El profesor ve el mote de quien ha jugado a sus juegos, nunca la llave.
create policy "el profesor ve quién juega a sus juegos"
  on public.perfiles for select
  to authenticated
  using (
    exists (
      select 1 from public.resultados r
      join public.juegos j on j.id = r.juego_id
      where r.perfil_id = perfiles.id and j.profesor_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- Ranking por curso: el mejor intento de cada juego (0-100) más 10 por
-- participar. "semana" empieza el lunes, hora de Madrid.
-- ---------------------------------------------------------------------------

create function public.ranking(p_curso smallint, p_periodo text default 'semana')
returns table (
  posicion integer,
  animal text,
  adjetivo text,
  color text,
  traje text,
  pose text,
  puntos integer,
  juegos integer,
  es_mio boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  with activo as (
    select ranking_activo from public.ajustes where id
  ),
  desde as (
    select case
      when p_periodo = 'siempre' then '-infinity'::timestamptz
      else date_trunc('week', now() at time zone 'Europe/Madrid')
        at time zone 'Europe/Madrid'
    end as momento
  ),
  mejores as (
    select r.perfil_id, r.juego_id, max(r.aciertos::numeric / r.total) as mejor
    from public.resultados r
    join public.perfiles p on p.id = r.perfil_id
    where p.curso = p_curso
      and r.jugado >= (select momento from desde)
    group by r.perfil_id, r.juego_id
  ),
  sumas as (
    select perfil_id,
      sum(round(mejor * 100) + 10)::integer as puntos,
      count(*)::integer as juegos
    from mejores
    group by perfil_id
  ),
  ordenados as (
    select s.*, rank() over (order by s.puntos desc)::integer as posicion,
      public.perfil_vinculado(s.perfil_id) as es_mio
    from sumas s
  )
  select o.posicion, p.animal, p.adjetivo, p.color, p.traje, p.pose,
    o.puntos, o.juegos, o.es_mio
  from ordenados o
  join public.perfiles p on p.id = o.perfil_id
  where (select ranking_activo from activo)
    and (o.posicion <= 10 or o.es_mio)
  order by o.posicion, p.animal, p.adjetivo;
$$;

revoke execute on function public.ranking(smallint, text) from public;
grant execute on function public.ranking(smallint, text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Imágenes que sube el profesor (fondos y preguntas). Lectura pública para
-- que la app las descargue y guarde en caché.
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'imagenes', 'imagenes', true, 2097152,
  array['image/webp', 'image/jpeg', 'image/png']
)
on conflict (id) do nothing;

create policy "el profesorado sube imágenes"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'imagenes' and (select public.es_profesor()));

create policy "el profesorado cambia sus imágenes"
  on storage.objects for update
  to authenticated
  using (bucket_id = 'imagenes' and owner_id = auth.uid()::text)
  with check (bucket_id = 'imagenes' and owner_id = auth.uid()::text);

create policy "el profesorado borra sus imágenes"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'imagenes' and owner_id = auth.uid()::text);
