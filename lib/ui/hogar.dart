import 'package:flutter/material.dart';
import 'package:naturalmente/reglas/hogar.dart';

class HogarPage extends StatefulWidget {
  const HogarPage({super.key});

  @override
  State<HogarPage> createState() => _HogarPageState();
}

class _HogarPageState extends State<HogarPage> {
  int _intento = 1;
  String? _frase;

  void _elegir(String lugar) {
    final frase = fraseDelCamello(lugar: lugar, intento: _intento);
    setState(() {
      _frase = frase;
      if (!lugarDelCamello(lugar)) {
        _intento += 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cada uno a su hogar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text('Pensado para 1º y 2º. Puedes jugarlo igual.'),
          const SizedBox(height: 12),
          Text(
            'El camello busca su sitio. ¿Dónde puede vivir?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          for (final lugar in lugaresDelHogar) ...[
            FilledButton.tonal(
              key: Key('lugar-$lugar'),
              onPressed: () => _elegir(lugar),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(_nombre(lugar)),
            ),
            const SizedBox(height: 8),
          ],
          if (_frase != null) ...[
            const SizedBox(height: 8),
            Text('El animal dice', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(_frase!, key: const Key('frase-animal')),
          ],
        ],
      ),
    );
  }
}

String _nombre(String lugar) {
  switch (lugar) {
    case 'desierto':
      return 'Desierto';
    case 'mar':
      return 'Mar';
    case 'polo':
      return 'Polo';
    case 'bosque':
      return 'Bosque';
    default:
      return lugar;
  }
}
