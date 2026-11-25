-- Progreso en la nube para jugar con el mismo perfil en varios dispositivos.
--
-- Se puede jugar sin conexión en todos ellos: al sincronizar nada se pierde
-- ni se cuenta dos veces.
--   * Lo conseguido (niveles, cromos, trajes, retos): se suma (unión).
--   * Semillas: cada dispositivo lleva sus totales de ganadas y gastadas, que
--     solo crecen. El saldo es la suma de todos. Reenviar no duplica.
--   * Mejor combo: el máximo. Racha: la del día más reciente.
--   * Ropa, pose y curso: gana el último cambio que se envía.

-- Un niño puede llevar varios trajes a la vez ("gorro,gafas").
alter table public.perfiles drop constraint perfiles_traje_check;
alter table public.perfiles add constraint perfiles_traje_check
  check (traje ~ '^[a-z0-9_]{1,40}(,[a-z0-9_]{1,40}){0,4}$');

create table public.progreso_perfil (
  perfil_id uuid primary key references public.perfiles (id) on delete cascade,
  hechos text[] not null default '{}',
  mejor_combo integer not null default 0,
  racha_dias integer not null default 0,
  racha_ultima date,
  equipados text[] not null default '{}',
  pose text,
  actualizado timestamptz not null default now()
);

create table public.semillas_dispositivo (
  perfil_id uuid not null references public.perfiles (id) on delete cascade,
  dispositivo_id uuid not null,
  ganadas bigint not null default 0 check (ganadas >= 0),
  gastadas bigint not null default 0 check (gastadas >= 0),
  primary key (perfil_id, dispositivo_id)
);

-- Solo se tocan a través de sincronizar_progreso.
alter table public.progreso_perfil enable row level security;
alter table public.semillas_dispositivo enable row level security;
revoke all on public.progreso_perfil from anon, authenticated;
revoke all on public.semillas_dispositivo from anon, authenticated;

create function public.sincronizar_progreso(p_perfil uuid, p_local jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  guardado public.progreso_perfil;
  ultima_local date;
  dias_local integer;
begin
  if not public.perfil_vinculado(p_perfil) then
    raise exception 'perfil_ajeno' using errcode = '42501';
  end if;
  insert into public.progreso_perfil (perfil_id) values (p_perfil)
  on conflict do nothing;
  select * into guardado from public.progreso_perfil
  where perfil_id = p_perfil for update;

  begin
    ultima_local := (p_local -> 'racha' ->> 'ultima')::date;
  exception when others then
    ultima_local := null;
  end;
  dias_local := least(greatest(coalesce((p_local -> 'racha' ->> 'dias')::integer, 0), 0), 10000);

  update public.progreso_perfil set
    hechos = (
      select coalesce(array_agg(h order by h), '{}')
      from (
        select unnest(guardado.hechos) as h
        union
        select jsonb_array_elements_text(coalesce(p_local -> 'hechos', '[]'))
      ) todos
      where char_length(h) between 1 and 120
    ),
    mejor_combo = greatest(
      guardado.mejor_combo,
      least(coalesce((p_local ->> 'mejorCombo')::integer, 0), 10000)
    ),
    racha_dias = case
      when ultima_local is null then guardado.racha_dias
      when guardado.racha_ultima is null or ultima_local > guardado.racha_ultima then dias_local
      when ultima_local = guardado.racha_ultima then greatest(dias_local, guardado.racha_dias)
      else guardado.racha_dias
    end,
    racha_ultima = greatest(guardado.racha_ultima, ultima_local),
    equipados = case
      when p_local ? 'equipados' then array(
        select e from jsonb_array_elements_text(p_local -> 'equipados') e
        where e ~ '^[a-z0-9_]{1,40}$' limit 5
      )
      else guardado.equipados
    end,
    pose = case
      when p_local ->> 'pose' ~ '^[a-z0-9_]{1,40}$' then p_local ->> 'pose'
      else guardado.pose
    end,
    actualizado = now()
  where perfil_id = p_perfil;

  insert into public.semillas_dispositivo (perfil_id, dispositivo_id, ganadas, gastadas)
  values (
    p_perfil,
    auth.uid(),
    least(greatest(coalesce((p_local ->> 'ganadas')::bigint, 0), 0), 10000000),
    least(greatest(coalesce((p_local ->> 'gastadas')::bigint, 0), 0), 10000000)
  )
  on conflict (perfil_id, dispositivo_id) do update set
    ganadas = greatest(public.semillas_dispositivo.ganadas, excluded.ganadas),
    gastadas = greatest(public.semillas_dispositivo.gastadas, excluded.gastadas);

  if (p_local ->> 'curso') ~ '^[1-6]$' then
    update public.perfiles set curso = (p_local ->> 'curso')::smallint
    where id = p_perfil;
  end if;

  select * into guardado from public.progreso_perfil where perfil_id = p_perfil;
  return jsonb_build_object(
    'hechos', to_jsonb(guardado.hechos),
    'semillas', (
      select coalesce(sum(ganadas - gastadas), 0)
      from public.semillas_dispositivo where perfil_id = p_perfil
    ),
    'mejorCombo', guardado.mejor_combo,
    'racha', jsonb_build_object(
      'dias', guardado.racha_dias,
      'ultima', guardado.racha_ultima
    ),
    'equipados', to_jsonb(guardado.equipados),
    'pose', guardado.pose,
    'curso', (select curso from public.perfiles where id = p_perfil)
  );
end;
$$;

revoke execute on function public.sincronizar_progreso(uuid, jsonb) from public, anon;
grant execute on function public.sincronizar_progreso(uuid, jsonb) to authenticated;
