import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/datos/catalogo.dart';
import 'package:naturalmente/datos/progreso.dart';
import 'package:naturalmente/modelo/actividad.dart';
import 'package:naturalmente/reglas/resolver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Catalogo catalogo;

  setUpAll(() {
    catalogo = Catalogo.desdeTexto(File('content/catalog.json').readAsStringSync());
  });

  test('cada actividad tiene tipo, curso y frases', () {
    expect(catalogo.actividades, isNotEmpty);
    for (final actividad in catalogo.actividades) {
      expect(actividad.tipo, isNotEmpty);
      expect(actividad.curso, isNotEmpty);
      expect(actividad.tieneFrases, isTrue);
    }
  });

  test('un animal nuevo del catálogo se resuelve sin una pantalla nueva', () {
    const reto = Reto(
      id: 'lince',
      nombre: 'El lince',
      pregunta: '¿Dónde vive?',
      respuesta: 'bosque',
      pista: 'Entre árboles.',
      frases: {
        'bosque': 'Sí, el bosque.',
        'desierto': 'Aquí no hay sombra.',
      },
    );
    final mal = resolverLugar(reto: reto, eleccion: 'desierto', intento: 2);
    expect(mal.acierto, isFalse);
    expect(mal.frase, contains('Entre árboles'));
    expect(mal.frase.toLowerCase(), isNot(contains('error')));
  });

  test('el camello en el polo habla de frío y a la segunda da la pista', () {
    final hogar = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final camello = hogar.retos.first;
    final primera = resolverLugar(reto: camello, eleccion: 'polo', intento: 1);
    final segunda = resolverLugar(reto: camello, eleccion: 'polo', intento: 2);
    expect(primera.frase, contains('frío'));
    expect(primera.frase, isNot(contains('poca agua')));
    expect(primera.gesto, 'pensando');
    expect(segunda.frase, contains('poca agua'));
    expect(segunda.gesto, 'pista');
    expect(primera.acierto, isFalse);
  });

  test('la judía progresa día a día por varios caminos (tierra, algodón, arena y oscuridad)', () {
    final juego = catalogo.actividades.firstWhere((a) => a.id == 'germinacion');
    expect(
      resolverControles(actividad: juego, valores: {'agua': 'mucha', 'luz': 'justa', 'suelo': 'huerto'}).estado,
      'ahogada',
    );
    expect(
      resolverControles(actividad: juego, valores: {'agua': 'justa', 'luz': 'poca', 'suelo': 'huerto'}).estado,
      'palida',
    );
    final brote = resolverControles(
      actividad: juego,
      valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'huerto'},
    );
    expect(brote.acierto, isTrue);
    expect(brote.estado, 'brote');

    final broteAlgodon = resolverControles(
      actividad: juego,
      valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'algodon'},
    );
    expect(broteAlgodon.acierto, isTrue);
    expect(broteAlgodon.estado, 'broteAlgodon');

    final facil = juego.nivelesLugar[0];
    final medio = juego.nivelesLugar[1];
    final dificil = juego.nivelesLugar[2];
    expect(facil.controles.length, 3);
    expect(medio.controles.length, 3);
    expect(dificil.controles.length, 4);
    expect(dificil.controles.last.id, 'temperatura');

    // En arena: en Día 1 saca la raíz (pasa a etapa 2), pero en Día 3 se queda en etapa 2 (sedienta)
    final arenaDia1 = resolverPasoGerminacion(
      actividad: juego,
      nivel: medio,
      etapaActual: 1,
      valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'arena'},
    );
    expect(arenaDia1.avanzaEtapa, isTrue);
    expect(arenaDia1.etapaAlcanzada, 2);

    final arenaDia3 = resolverPasoGerminacion(
      actividad: juego,
      nivel: medio,
      etapaActual: 2,
      valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'arena'},
    );
    expect(arenaDia3.avanzaEtapa, isFalse);
    expect(arenaDia3.etapaAlcanzada, 2);
    expect(arenaDia3.estado, 'sedienta');

    // En algodón húmedo con sol: avanza Día 1 -> Día 3 -> Día 5 -> Día 7 (broteAlgodon)
    final algodonDia7 = resolverPasoGerminacion(
      actividad: juego,
      nivel: facil,
      etapaActual: 3,
      valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'algodon'},
    );
    expect(algodonDia7.etapaAlcanzada, 4);
    expect(algodonDia7.experimentoCompletado, isTrue);
    expect(algodonDia7.estado, 'broteAlgodon');

    expect(
      resolverControles(
        actividad: juego,
        nivel: dificil,
        valores: {'agua': 'justa', 'luz': 'justa', 'suelo': 'huerto'},
      ).estado,
      'falta',
    );
    expect(
      resolverControles(
        actividad: juego,
        nivel: dificil,
        valores: {
          'agua': 'justa',
          'luz': 'justa',
          'suelo': 'huerto',
          'temperatura': 'fria',
        },
      ).estado,
      'helada',
    );
    expect(
      resolverControles(
        actividad: juego,
        nivel: dificil,
        valores: {
          'agua': 'justa',
          'luz': 'excesiva',
          'suelo': 'huerto',
          'temperatura': 'templada',
        },
      ).estado,
      'achicharrada',
    );
    expect(
      resolverControles(
        actividad: juego,
        nivel: dificil,
        valores: {
          'agua': 'justa',
          'luz': 'justa',
          'suelo': 'huerto',
          'temperatura': 'templada',
        },
      ).acierto,
      isTrue,
    );
  });

  test('la vida no suelta el orden si faltan pasos', () {
    final vida = catalogo.actividades.firstWhere((a) => a.id == 'vida');
    final aMedias = resolverOrden(actividad: vida, orden: const ['nace']);
    expect(aMedias.acierto, isFalse);
    expect(aMedias.frase, contains('cuatro pasos'));
    expect(aMedias.frase, isNot(contains('crece')));
    final bien = resolverOrden(
      actividad: vida,
      orden: const ['celulas', 'utero', 'nace', 'cuidados'],
    );
    expect(bien.acierto, isTrue);
  });

  test('Natu guía todas las actividades y todas tienen tres niveles', () {
    for (final actividad in catalogo.actividades) {
      expect(actividad.quien, 'Natu dice');
      if (actividad.tipo == 'herbario') {
        expect(
          actividad.herbario!.niveles.map((n) => n.id).toList(),
          ['facil', 'medio', 'dificil'],
        );

      } else if (actividad.ecosistema != null) {
        expect(actividad.ecosistema!.niveles.map((n) => n.id), ['facil', 'medio', 'dificil']);

      } else if (actividad.tipo == 'nacimiento') {
        expect(
          actividad.nacimiento!.niveles.map((n) => n.id).toList(),
          ['facil', 'medio', 'dificil'],
        );

      } else {
        expect(
          actividad.nivelesLugar.map((n) => n.id).toList(),
          ['facil', 'medio', 'dificil'],
        );
      }
    }
    final hogar = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final facil = hogar.nivelesLugar[0];
    final medio = hogar.nivelesLugar[1];
    final dificil = hogar.nivelesLugar[2];
    expect(facil.opciones.length, 4);
    expect(facil.retos.length, 4);
    expect(facil.preguntaAdaptacion, isFalse);
    expect(medio.opciones.length, 6);
    expect(medio.retos.length, 6);
    expect(medio.preguntaAdaptacion, isTrue);
    expect(dificil.opciones.length, 6);
    expect(dificil.retos.length, 7);
    expect(dificil.preguntaAdaptacion, isTrue);

    final camelloMedio = medio.retos.first;
    final malAdaptacion = resolverAdaptacion(reto: camelloMedio, eleccion: 'branquias');
    expect(malAdaptacion.acierto, isFalse);
    expect(malAdaptacion.gesto, 'pista');
    final bienAdaptacion = resolverAdaptacion(reto: camelloMedio, eleccion: 'joroba');
    expect(bienAdaptacion.acierto, isTrue);
    expect(bienAdaptacion.gesto, 'feliz');
  });

  test('BarajadorOpciones aleatoriza sin repetir la posición correcta consecutiva', () {
    BarajadorOpciones.reiniciarMemoria();
    final hogar = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final opciones = hogar.nivelesLugar[1].retos.first.adaptacion!.opciones;
    int? anterior;
    for (var i = 0; i < 15; i++) {
      final barajadas = BarajadorOpciones.barajarConRespuesta(
        clave: 'test-adaptacion',
        opciones: opciones,
        idDe: (o) => o.id,
        respuestaCorrecta: 'joroba',
      );
      final pos = barajadas.indexWhere((o) => o.id == 'joroba');
      if (anterior != null) {
        expect(pos, isNot(equals(anterior)));
      }
      anterior = pos;
    }

    final vida = catalogo.actividades.firstWhere((a) => a.id == 'vida');
    for (var i = 0; i < 10; i++) {
      final pasos = BarajadorOpciones.barajarPasos(
        clave: 'test-vida',
        pasos: vida.pasos,
        ordenCorrecto: vida.respuesta,
      );
      expect(
        pasos.map((p) => p.id).toList(),
        isNot(equals(vida.respuesta)),
      );
    }
  });






  test('el álbum tiene 28 cromos y cada dificultad de cada juego desbloquea los suyos', () async {
    expect(catalogo.fichas.length, 28);
    expect(catalogo.fichasDe('reserva').length, 11);

    expect(catalogo.fichasDe('invernadero').length, 8);
    expect(catalogo.fichasDe('cuerpo').length, 9);

    SharedPreferences.setMockInitialValues({});
    final progreso = await Progreso.abrir();
    final hogar = catalogo.actividades.firstWhere((a) => a.id == 'hogar');
    final herbario = catalogo.actividades.firstWhere((a) => a.id == 'herbario');
    final germinacion = catalogo.actividades.firstWhere((a) => a.id == 'germinacion');
    final vida = catalogo.actividades.firstWhere((a) => a.id == 'vida');

    expect(progreso.fichaDesbloqueada('camello'), isFalse);
    await progreso.marcarNivelLugar(hogar, 'facil');
    expect(progreso.fichaDesbloqueada('camello'), isTrue);
    expect(progreso.fichaDesbloqueada('rana'), isFalse);
    expect(progreso.fichaDesbloqueada('pulpo'), isFalse);

    await progreso.marcarNivelLugar(hogar, 'medio');
    expect(progreso.fichaDesbloqueada('rana'), isTrue);
    expect(progreso.fichaDesbloqueada('tucan'), isTrue);
    expect(progreso.fichaDesbloqueada('pulpo'), isFalse);

    await progreso.marcarNivelLugar(hogar, 'dificil');
    expect(progreso.fichaDesbloqueada('pulpo'), isTrue);

    await progreso.marcarNivelHerbario(herbario, 'facil');
    expect(progreso.fichaDesbloqueada('raiz'), isTrue);
    expect(progreso.fichaDesbloqueada('flor'), isFalse);
    expect(progreso.fichaDesbloqueada('fruto'), isFalse);

    await progreso.marcarNivelHerbario(herbario, 'medio');
    expect(progreso.fichaDesbloqueada('flor'), isTrue);
    expect(progreso.fichaDesbloqueada('fruto'), isFalse);

    await progreso.marcarNivelHerbario(herbario, 'dificil');
    expect(progreso.fichaDesbloqueada('fruto'), isTrue);

    final piezas = catalogo.actividades.firstWhere((a) => a.id == 'piezas');

    await progreso.marcarNivelLugar(germinacion, 'facil');
    expect(progreso.fichaDesbloqueada('semilla'), isTrue);
    expect(progreso.fichaDesbloqueada('huerto'), isFalse);
    expect(progreso.fichaDesbloqueada('fotosintesis'), isFalse);

    await progreso.marcarNivelLugar(germinacion, 'medio');
    expect(progreso.fichaDesbloqueada('huerto'), isTrue);
    expect(progreso.fichaDesbloqueada('fotosintesis'), isFalse);

    await progreso.marcarNivelLugar(germinacion, 'dificil');
    expect(progreso.fichaDesbloqueada('fotosintesis'), isTrue);

    await progreso.marcarNivelLugar(piezas, 'facil');
    expect(progreso.fichaDesbloqueada('corazon'), isTrue);
    expect(progreso.fichaDesbloqueada('cerebro'), isTrue);
    expect(progreso.fichaDesbloqueada('pulmones'), isFalse);
    expect(progreso.fichaDesbloqueada('intestinos'), isFalse);

    await progreso.marcarNivelLugar(piezas, 'medio');
    expect(progreso.fichaDesbloqueada('pulmones'), isTrue);
    expect(progreso.fichaDesbloqueada('esqueleto'), isTrue);
    expect(progreso.fichaDesbloqueada('intestinos'), isFalse);

    await progreso.marcarNivelLugar(piezas, 'dificil');
    expect(progreso.fichaDesbloqueada('intestinos'), isTrue);

    await progreso.marcarNivelLugar(vida, 'facil');
    expect(progreso.fichaDesbloqueada('una-vida'), isTrue);
    expect(progreso.fichaDesbloqueada('etapas-vida'), isFalse);
    expect(progreso.fichaDesbloqueada('celula'), isFalse);

    await progreso.marcarNivelLugar(vida, 'medio');
    expect(progreso.fichaDesbloqueada('etapas-vida'), isTrue);
    expect(progreso.fichaDesbloqueada('celula'), isFalse);

    await progreso.marcarNivelLugar(vida, 'dificil');
    expect(progreso.fichaDesbloqueada('celula'), isTrue);

    final nacimiento = catalogo.actividades.firstWhere((a) => a.id == 'nacimiento');
    await progreso.marcarNivelNacimiento(nacimiento, 'facil');
    expect(progreso.fichaDesbloqueada('huevo'), isTrue);
    expect(progreso.fichaDesbloqueada('renacuajo'), isFalse);
    expect(progreso.fichaDesbloqueada('mariposa'), isFalse);

    await progreso.marcarNivelNacimiento(nacimiento, 'medio');
    expect(progreso.fichaDesbloqueada('renacuajo'), isTrue);
    expect(progreso.fichaDesbloqueada('mariposa'), isFalse);

    await progreso.marcarNivelNacimiento(nacimiento, 'dificil');
    expect(progreso.fichaDesbloqueada('mariposa'), isTrue); final ecosistemas = catalogo.actividades.firstWhere((a) => a.id == 'ecosistemas'); await progreso.marcarNivelEcosistema(ecosistemas, 'facil'); expect(progreso.fichaDesbloqueada('claro-bosque'), isTrue);
    expect(
      catalogo.fichas.every((f) => progreso.fichaDesbloqueada(f.id)),
      isTrue,
    );
  });

  test('ningún texto del catálogo usa palabras prohibidas ni temas fuera de alcance', () {
    final textoCrudo = File('content/catalog.json').readAsStringSync().toLowerCase();
    for (final prohibida in ['error', 'incorrecto', 'has fallado', 'mal hecho']) {
      expect(textoCrudo, isNot(contains(prohibida)));
    }
    for (final fueraDeAlcance in ['universo', 'terremoto', 'volcán', 'volcanes']) {
      expect(textoCrudo, isNot(contains(fueraDeAlcance)));
    }
  });
}

