import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todos los textos visibles del catálogo tienen traducción al inglés', () {
    final catalogo = jsonDecode(
      File('content/catalog.json').readAsStringSync(),
    );
    final traducciones = jsonDecode(
      File('content/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    // Estos campos almacenan identificadores, no texto que se muestre.
    const camposTecnicos = {
      'id',
      'zona',
      'tipo',
      'respuesta',
      'medalla',
      'preguntaAdaptacion',
      'correcta',
      'orden',
      'nivel',
      'dibujo',
      'icono',
      'clase',
      'color',
      'widget',
      'mecanica',
      'mecanicaId',
      'animales',
      'despistes',
      'partes',
      'contenedor',
      'candidatos',
    };

    final sinTraduccion = <String>{};

    void revisar(dynamic valor, [String campo = '']) {
      if (valor is String) {
        if (valor.isEmpty || camposTecnicos.contains(campo)) return;
        final existeExacta = traducciones.containsKey(valor);
        final existeSinMayusculas = traducciones.keys.any(
          (clave) => clave.toLowerCase() == valor.toLowerCase(),
        );
        if (!existeExacta && !existeSinMayusculas) {
          sinTraduccion.add(valor);
        }
        return;
      }
      if (valor is List) {
        for (final elemento in valor) {
          revisar(elemento, campo);
        }
        return;
      }
      if (valor is Map) {
        for (final entrada in valor.entries) {
          if (!camposTecnicos.contains(entrada.key)) {
            revisar(entrada.value, entrada.key.toString());
          }
        }
      }
    }

    revisar(catalogo);
    expect(
      sinTraduccion,
      isEmpty,
      reason: 'Faltan traducciones para: ${sinTraduccion.join(' | ')}',
    );
  });

  test('las plantillas de mensajes dinámicos del juego están traducidas', () {
    final traducciones = jsonDecode(
      File('content/en.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    const plantillas = [
      '¡Ñam! Mordisco {0} de {1}. Sigue masticando.',
      '{0} Semillas',
      'Racha: 1 día',
      'Racha: {0} días',
      '1 Semilla',
      'Bote: {0}',
      '• Tallo: {0}',
      '• Al viento: {0}',
      'Corazón ({0} latidos/min)',
      'Pulmones y árbol bronquial ({0} resp/min)',
      'Espécimen por descubrir · {0}',
      'Cómo conseguirlo: {0}',
      'O₂ {0} %',
      '⚡ Glucosa {0} mg/dL',
      '💧 Riñón {0} mL/h',
      '♥ {0} LPM',
      '≈ {0} RPM',
    ];

    for (final plantilla in plantillas) {
      expect(
        traducciones[plantilla],
        isA<String>(),
        reason: 'Falta la traducción de la plantilla: $plantilla',
      );
    }
  });
}
