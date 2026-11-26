-- 1. Los jugadores que llevan un año sin jugar se borran solos, con sus
--    resultados y su progreso (no se guardan datos más tiempo del necesario).
-- 2. Los dispositivos anónimos sin uso en un año también se borran.
-- 3. El panel puede consultar cuánto espacio queda y cuántos niños juegan.

alter table public.perfiles
  add column ultima_actividad timestamptz not null default now();

create index perfiles_ultima_actividad_idx on public.perfiles (ultima_actividad);

create function private.perfil_activo()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.perfiles set ultima_actividad = now()
  where id = new.perfil_id and ultima_actividad < now() - interval '1 hour';
  return new;
end;
$$;

create trigger perfil_activo_por_resultado
  after insert on public.resultados
  for each row execute function private.perfil_activo();

create trigger perfil_activo_por_progreso
  after insert or update on public.progreso_perfil
  for each row execute function private.perfil_activo();

create trigger perfil_activo_por_vinculo
  after insert on public.dispositivo_perfil
  for each row execute function private.perfil_activo();

-- Devuelve cuántos jugadores y dispositivos ha borrado.
create function private.borrar_inactivos(p_antes interval default interval '1 year')
returns table (perfiles integer, dispositivos integer)
language plpgsql
security definer
set search_path = ''
as $$
declare
  n_perfiles integer;
  n_dispositivos integer;
begin
  delete from public.perfiles where ultima_actividad < now() - p_antes;
  get diagnostics n_perfiles = row_count;

  -- Solo usuarios anónimos (dispositivos): nunca cuentas de profesorado.
  delete from auth.users u
  where u.is_anonymous
    and coalesce(u.last_sign_in_at, u.created_at) < now() - p_antes
    and not exists (select 1 from public.dispositivo_perfil d where d.dispositivo_id = u.id);
  get diagnostics n_dispositivos = row_count;

  return query select n_perfiles, n_dispositivos;
end;
$$;

revoke all on function private.borrar_inactivos(interval) from public;

-- Cada noche a las 3:30 (UTC). pg_cron viene con Supabase, también gratis.
create extension if not exists pg_cron with schema pg_catalog;
select cron.schedule(
  'borrar-jugadores-inactivos',
  '30 3 * * *',
  $$select private.borrar_inactivos()$$
);

-- Estado para el panel: espacio usado frente a los límites del plan gratuito.
create function public.estado_panel()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.es_profesor() then
    raise exception 'solo_profesorado' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'fotos_bytes', (
      select coalesce(sum((metadata ->> 'size')::bigint), 0)
      from storage.objects where bucket_id = 'imagenes'
    ),
    'fotos_numero', (select count(*) from storage.objects where bucket_id = 'imagenes'),
    'fotos_limite', 1073741824,
    'datos_bytes', pg_database_size(current_database()),
    'datos_limite', 524288000,
    'ninos_semana', (
      select count(distinct perfil_id) from public.resultados
      where jugado > now() - interval '7 days'
    ),
    'partidas_semana', (
      select count(*) from public.resultados where jugado > now() - interval '7 days'
    ),
    'ninos_total', (select count(*) from public.perfiles),
    'juegos_publicados', (select count(*) from public.juegos where estado = 'publicado'),
    'borrado_inactivos_dias', 365
  );
end;
$$;

revoke execute on function public.estado_panel() from public, anon;
grant execute on function public.estado_panel() to authenticated;
