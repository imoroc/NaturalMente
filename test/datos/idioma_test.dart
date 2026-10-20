import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/idiomas/idioma.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('español inicial, selección persistente e idioma desconocido', () async {
    final idioma = await Idioma.abrir();
    expect(idioma.codigo, 'es');
    expect(idioma.traducir('La reserva'), 'La reserva');
    expect(await idioma.elegir('en'), isTrue);
    expect((await Idioma.abrir()).codigo, 'en');
    expect(await idioma.elegir('fr'), isFalse);
    expect(idioma.codigo, 'en');
    expect(await idioma.elegir('es'), isTrue);
    expect((await Idioma.abrir()).codigo, 'es');
  });

  test('una preferencia desconocida utiliza español', () async {
    SharedPreferences.setMockInitialValues({'idioma': 'fr'});
    expect((await Idioma.abrir()).codigo, 'es');
  });

  test('traduce composiciones, pistas, mayúsculas y parámetros', () async {
    final idioma = await Idioma.abrir();
    await idioma.elegir('en');
    expect(
      idioma.traducir('Fácil · Pensado para 1º-2º. Puedes jugarlo igual.'),
      'Easy · Suggested for Years 1–2. Everyone can play.',
    );
    expect(
      idioma.traducir('Pensado para 1º-2º. Puedes jugarlo igual.'),
      'Suggested for Years 1–2. Everyone can play.',
    );
    expect(
      idioma.traducir('CROMO DESBLOQUEADO · 3º-4º'),
      'STICKER UNLOCKED · Years 3–4',
    );
    expect(idioma.traducir('LA RESERVA · ANIMALES'), 'THE RESERVE · ANIMALS');
    expect(
      idioma.traducir('Seleccionada: Raíz. Toca su sitio.'),
      'Selected: Root. Tap its place.',
    );
    expect(
      idioma.traducir('Falta preparar Riego, Ventana.'),
      'Still to prepare: Watering, Window.',
    );
    expect(idioma.traducir('1. Se unen dos células'), '1. Two cells join');
    expect(idioma.traducir('Consultar raíz'), 'Explore root');
    expect(
      idioma.traducir(
        'La raíz se extiende bajo el suelo; aquí no puede sujetar la planta. Busca la parte de la planta que queda bajo el suelo.',
      ),
      'The root spreads below the soil; it cannot anchor the plant here. Look for the plant part that is below the soil.',
    );
    expect(idioma.traducir('12/24'), '12/24');
    expect(idioma.traducir('NaturalMente'), 'NaturalMente');
  });

  test('todo el texto educativo del catálogo tiene traducción', () {
    final catalogo = jsonDecode(
      File('content/catalog.json').readAsStringSync(),
    );
    final ingles =
        jsonDecode(File('content/en.json').readAsStringSync()) as Map;
    const camposTecnicos = {
      'id',
      'zona',
      'tipo',
      'respuesta',
      'partes',
      'animales',
    };
    void comprobar(Object? valor, [String campo = '']) {
      if (valor is Map) {
        for (final entrada in valor.entries) {
          comprobar(entrada.value, entrada.key as String);
        }
      } else if (valor is List) {
        for (final elemento in valor) {
          comprobar(elemento, campo);
        }
      } else if (valor is String && !camposTecnicos.contains(campo)) {
        expect(ingles[valor], isA<String>(), reason: 'Falta traducir: $valor');
        expect((ingles[valor] as String).trim(), isNotEmpty);
      }
    }

    comprobar(catalogo);
  });
}
