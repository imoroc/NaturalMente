// Regla del primer juego de la reserva.
// No pinta nada: el test la llama sin abrir la app.

const lugaresDelHogar = ['desierto', 'mar', 'polo', 'bosque'];

const _pista =
    'Piensa en un sitio seco, con mucho sol y poca agua.';

const _frases = {
  'desierto':
      'Sí. En el desierto aguanto el calor y puedo pasar con poca agua.',
  'mar': 'El agua del mar es salada y yo estoy hecho para la arena y el sol.',
  'polo': '¡Aquí paso mucho frío! Mi cuerpo aguanta mejor el calor.',
  'bosque': 'Hay sombra de más. Yo vivo donde el suelo es seco y abierto.',
};

bool lugarDelCamello(String lugar) => lugar == 'desierto';

String fraseDelCamello({required String lugar, required int intento}) {
  final frase = _frases[lugar];
  if (frase == null) {
    throw ArgumentError('Ese lugar no está en el juego.');
  }
  if (!lugarDelCamello(lugar) && intento >= 2) {
    return '$frase $_pista';
  }
  return frase;
}
