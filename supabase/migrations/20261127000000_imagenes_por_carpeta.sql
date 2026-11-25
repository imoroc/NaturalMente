-- Cada profesor sube sus fotos a su propia carpeta del bucket `imagenes`
-- (`<id del profesor>/<marca de tiempo>.jpg`). Así nadie puede pisar ni
-- borrar las fotos de otro, y el panel sabe cuáles puede limpiar.

drop policy "el profesorado sube imágenes" on storage.objects;

create policy "el profesorado sube imágenes a su carpeta"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'imagenes'
    and (select public.es_profesor())
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- Solo fotos JPEG: el panel siempre las comprime así antes de subirlas.
update storage.buckets
set allowed_mime_types = array['image/jpeg']
where id = 'imagenes';

-- Para borrar una foto, Storage necesita poder verla: cada profe ve las suyas.
-- (Los niños las descargan por la dirección pública del bucket, sin esto.)
create policy "el profesorado ve sus imágenes"
  on storage.objects for select
  to authenticated
  using (bucket_id = 'imagenes' and owner_id = auth.uid()::text);
