import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/modelo/aula/juego_aula.dart';

/// Resuelve bien un reto de Aula con las claves de la pantalla del juego.
/// [tocar] debe hacer visible la clave, tocarla y esperar.
Future<void> resolverReto(
  WidgetTester tester,
  RetoAula reto,
  Future<void> Function(String clave) tocar,
) async {
  switch (reto) {
    case PreguntaAula(:final correcta):
      await tocar('opcion-aula-$correcta');
    case ClasificarAula(:final elementos):
      for (var i = 0; i < elementos.length; i++) {
        await tocar('clasificar-elemento-$i');
        await tocar('clasificar-grupo-${elementos[i].grupo}');
      }
      await tocar('comprobar-aula');
    case OrdenarAula(:final pasos):
      for (var i = 0; i < pasos.length; i++) {
        await tocar('ordenar-paso-$i');
      }
      await tocar('comprobar-aula');
    case ParejasAula(:final parejas):
      for (var i = 0; i < parejas.length; i++) {
        await tocar('pareja-a-$i');
        await tocar('pareja-b-$i');
      }
    case HuecosAula(:final respuestas):
      for (var j = 0; j < respuestas.length; j++) {
        await tocar('hueco-palabra-$j');
      }
      await tocar('comprobar-aula');
    case BuscarAula(:final zonas):
      final imagen = find.byKey(const Key('buscar-imagen'));
      await tester.ensureVisible(imagen);
      await tester.pumpAndSettle();
      final rect = tester.getRect(imagen);
      await tester.tapAt(rect.topLeft + Offset(zonas.first.x * rect.width, zonas.first.y * rect.height));
      await tester.pumpAndSettle();
    case NumeroAula(:final respuesta):
      for (final cifra in '$respuesta'.split('')) {
        await tocar('numero-tecla-$cifra');
      }
      await tocar('comprobar-aula');
    case PalabraAula(:final letras):
      for (var i = 0; i < letras.length; i++) {
        await tocar('letra-$i');
      }
      await tocar('comprobar-aula');
    case LecturaAula():
      await tocar('lectura-continuar');
  }
}

/// Un juego con un reto de cada tipo, con pista y explicación en algunos.
JuegoAula juegoConTodosLosTipos({String id = 'juego-todos', int version = 1}) =>
    JuegoAula(
      id: id,
      titulo: 'El cuerpo humano',
      plantilla: PlantillaAula.libre,
      version: version,
      cursos: const [5],
      fondo: const ImagenEscena('selva'),
      preguntas: const [
        LecturaAula(
          enunciado: 'El esqueleto',
          texto: 'Los huesos nos sostienen y protegen los órganos.',
        ),
        PreguntaAula(
          enunciado: '¿Qué órgano bombea la sangre?',
          opciones: [OpcionAula(texto: 'Corazón'), OpcionAula(texto: 'Pulmón')],
          correcta: 0,
          explicacion: 'El corazón es un músculo que nunca descansa.',
        ),
        PreguntaAula(
          tipo: TipoReto.verdaderoFalso,
          enunciado: 'Los pulmones sirven para respirar.',
          opciones: [OpcionAula(texto: 'Verdadero'), OpcionAula(texto: 'Falso')],
          correcta: 0,
        ),
        ClasificarAula(
          enunciado: '¿Hueso u órgano?',
          grupos: [OpcionAula(texto: 'Hueso'), OpcionAula(texto: 'Órgano')],
          elementos: [
            ElementoGrupo(OpcionAula(texto: 'Fémur'), 0),
            ElementoGrupo(OpcionAula(texto: 'Hígado'), 1),
            ElementoGrupo(OpcionAula(texto: 'Cráneo'), 0),
          ],
          pista: 'Los huesos son duros.',
        ),
        OrdenarAula(
          enunciado: 'Ordena el camino de la comida',
          pasos: [
            OpcionAula(texto: 'Boca'),
            OpcionAula(texto: 'Esófago'),
            OpcionAula(texto: 'Estómago'),
            OpcionAula(texto: 'Intestino'),
          ],
        ),
        ParejasAula(
          enunciado: 'Cada órgano con su función',
          parejas: [
            (OpcionAula(texto: 'Pulmones'), OpcionAula(texto: 'Respirar')),
            (OpcionAula(texto: 'Estómago'), OpcionAula(texto: 'Digerir')),
            (OpcionAula(texto: 'Ojos'), OpcionAula(texto: 'Ver')),
          ],
        ),
        HuecosAula(
          enunciado: 'Completa la frase',
          frase: 'El [corazón] bombea la [sangre] por el cuerpo.',
          distractores: ['agua', 'pulmón'],
        ),
        BuscarAula(
          enunciado: 'Toca la planta',
          imagen: ImagenGaleria('plantas'),
          zonas: [ZonaAula(0.5, 0.5, 0.2)],
        ),
        NumeroAula(enunciado: '¿Cuántos pulmones tenemos?', respuesta: 2),
        PalabraAula(enunciado: 'Órgano que piensa', respuesta: 'cerebro'),
      ],
    );
