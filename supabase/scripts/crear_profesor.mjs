#!/usr/bin/env node
// Crea la cuenta de un profesor, o le genera una contraseña nueva si la olvida.
//
//   SUPABASE_URL=https://xxxx.supabase.co \
//   SUPABASE_SERVICE_ROLE_KEY=... \
//   node supabase/scripts/crear_profesor.mjs --usuario profe.luis --nombre "Luis" [--correo luis@colegio.es]
//
//   node supabase/scripts/crear_profesor.mjs --usuario profe.luis --regenerar
//
// La clave de servicio salta todas las reglas de acceso: úsala solo en tu
// ordenador y nunca la subas al repositorio ni la pongas en la app.
//
// Sin --correo, la cuenta usa un correo interno (usuario@profes.naturalmente.app)
// y el profesor entra solo con su nombre de usuario. Con su correo real, puede
// entrar también con «Entrar con Microsoft» o «Entrar con Google» si usa esa
// misma dirección.

import { randomInt } from 'node:crypto';

// Palabras cortas de naturaleza, sin tildes, fáciles de leer y de dictar.
const PALABRAS = `
abeto abeja agua alga alondra arbol ardilla arena arroyo avena bambu baya
bellota bosque brisa buho cactus caracol castor cebra cedro cerezo ciervo
cigarra cisne coral cometa conejo cuervo delfin duna encina erizo espiga
estrella faro foca fresa gacela garza gavilan girasol golondrina gota grillo
haya helecho hiedra higo hoja hormiga huerto isla jara jilguero junco koala
lago lavanda lechuza libelula lince lirio lluvia lobo loro luna malva manzano
mar mariposa marmota menta mirlo montana musgo nido nieve nogal nube nutria
olivo ola oso pajaro paloma panda pino playa pluma pradera puma rana raiz
rio roble roca romero rosal salmon sapo sauce selva semilla seta sol tejon
tigre tilo tomillo topo trebol trigo trucha tulipan valle viento volcan zorro
`.trim().split(/\s+/);

const DOMINIO_INTERNO = 'profes.naturalmente.app';

function contrasena() {
  const palabras = Array.from({ length: 4 }, () => PALABRAS[randomInt(PALABRAS.length)]);
  return `${palabras.join('-')}-${String(randomInt(100)).padStart(2, '0')}`;
}

function argumentos(lista) {
  const resultado = {};
  for (let i = 0; i < lista.length; i++) {
    const actual = lista[i];
    if (!actual.startsWith('--')) continue;
    const siguiente = lista[i + 1];
    if (siguiente === undefined || siguiente.startsWith('--')) {
      resultado[actual.slice(2)] = true;
    } else {
      resultado[actual.slice(2)] = siguiente;
      i++;
    }
  }
  return resultado;
}

async function llamar(base, clave, ruta, opciones = {}) {
  const respuesta = await fetch(`${base}${ruta}`, {
    ...opciones,
    headers: {
      apikey: clave,
      Authorization: `Bearer ${clave}`,
      'Content-Type': 'application/json',
      ...(opciones.headers ?? {}),
    },
  });
  const texto = await respuesta.text();
  const datos = texto ? JSON.parse(texto) : null;
  if (!respuesta.ok) {
    throw new Error(`${opciones.method ?? 'GET'} ${ruta}: ${respuesta.status} ${texto}`);
  }
  return datos;
}

async function principal() {
  const args = argumentos(process.argv.slice(2));
  const base = process.env.SUPABASE_URL?.replace(/\/$/, '');
  const clave = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!base || !clave) {
    throw new Error('Faltan SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY en el entorno.');
  }
  const usuario = String(args.usuario ?? '').trim().toLowerCase();
  if (!/^[a-z0-9._-]{3,30}$/.test(usuario)) {
    throw new Error('--usuario debe tener de 3 a 30 letras, números, puntos o guiones.');
  }
  const clavePlana = contrasena();

  if (args.regenerar) {
    const filas = await llamar(base, clave, `/rest/v1/profesores?usuario=eq.${usuario}&select=id`);
    if (!filas.length) throw new Error(`No existe el usuario ${usuario}.`);
    await llamar(base, clave, `/auth/v1/admin/users/${filas[0].id}`, {
      method: 'PUT',
      body: JSON.stringify({ password: clavePlana }),
    });
    console.log(`Contraseña nueva para ${usuario}: ${clavePlana}`);
    return;
  }

  const nombre = String(args.nombre ?? '').trim();
  if (!nombre) throw new Error('Falta --nombre.');
  const correo = String(args.correo ?? `${usuario}@${DOMINIO_INTERNO}`).trim().toLowerCase();

  const creado = await llamar(base, clave, '/auth/v1/admin/users', {
    method: 'POST',
    body: JSON.stringify({ email: correo, password: clavePlana, email_confirm: true }),
  });
  try {
    await llamar(base, clave, '/rest/v1/profesores', {
      method: 'POST',
      headers: { Prefer: 'return=minimal' },
      body: JSON.stringify({ id: creado.id, usuario, nombre }),
    });
  } catch (error) {
    // Sin ficha de profesor la cuenta no sirve: se deshace.
    await llamar(base, clave, `/auth/v1/admin/users/${creado.id}`, { method: 'DELETE' });
    throw error;
  }

  console.log('Cuenta creada. Dale estos datos al profesor:');
  console.log(`  Usuario:    ${usuario}`);
  if (args.correo) console.log(`  Correo:     ${correo}`);
  console.log(`  Contraseña: ${clavePlana}`);
}

principal().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
