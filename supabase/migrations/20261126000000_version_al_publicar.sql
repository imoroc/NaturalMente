-- La versión de un juego solo sube cuando cambia lo que los niños ya han
-- visto publicado. Los autoguardados de un borrador no crean versiones, y
-- volver a publicar el mismo contenido tampoco: una versión nueva vuelve a
-- dar semillas a quien ya lo había completado.

alter table public.juegos add column contenido_publicado jsonb;

-- Los juegos ya publicados toman su contenido actual como el publicado.
update public.juegos
set contenido_publicado = contenido
where estado = 'publicado';

drop trigger versionar_juego on public.juegos;

create or replace function private.versionar_juego()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    new.version := 1;
    new.contenido_publicado :=
      case when new.estado = 'publicado' then new.contenido end;
    return new;
  end if;

  new.actualizado := now();
  new.profesor_id := old.profesor_id;
  new.creado := old.creado;
  new.version := old.version;
  new.contenido_publicado := old.contenido_publicado;

  if new.estado = 'publicado'
     and new.contenido is distinct from old.contenido_publicado then
    -- La primera publicación es la versión 1; cada cambio después, una más.
    if old.contenido_publicado is not null then
      new.version := old.version + 1;
    end if;
    new.contenido_publicado := new.contenido;
  end if;
  return new;
end;
$$;

create trigger versionar_juego
  before insert or update on public.juegos
  for each row execute function private.versionar_juego();
