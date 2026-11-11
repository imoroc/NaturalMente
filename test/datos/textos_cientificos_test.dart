import 'package:flutter_test/flutter_test.dart';
import 'package:naturalmente/ui/dibujos_natu.dart';

void main() {
  test('la ficha del pulpo habla de ocho brazos, no de tentáculos', () {
    final pulpo = DatosEnciclopedicosFicha.de('pulpo');
    expect(pulpo.locomocionOFuncion, contains('ocho brazos'));
    expect(pulpo.locomocionOFuncion, isNot(contains('tentáculos')));
  });

  test('la flor distingue el polen, el pistilo y el desarrollo del ovario', () {
    final flor = DatosEnciclopedicosFicha.de('flor');
    expect(flor.alimentacionOProceso, contains('estambres'));
    expect(flor.alimentacionOProceso, contains('fecundación'));
    expect(flor.alimentacionOProceso, contains('ovario'));
    expect(flor.alimentacionOProceso, isNot(contains('el pistilo se transforma')));
  });

  test('la fotosíntesis no se atribuye exclusivamente a las plantas terrestres', () {
    final fotosintesis = DatosEnciclopedicosFicha.de('fotosintesis');
    expect(fotosintesis.locomocionOFuncion, contains('dióxido de carbono'));
    expect(fotosintesis.locomocionOFuncion, contains('azúcares'));
    expect(fotosintesis.datoCientifico, isNot(contains('únicos seres vivos terrestres')));
  });

  test('la ficha de la raíz no afirma que todas crecen siempre hacia abajo', () {
    final raiz = DatosEnciclopedicosFicha.de('raiz');
    expect(raiz.datoCientifico, contains('responden a la gravedad'));
    expect(raiz.datoCientifico, contains('agua y nutrientes'));
    expect(raiz.datoCientifico, isNot(contains('siempre hacia abajo')));
  });

  test('los anillos de crecimiento se describen con el matiz correcto', () {
    final tallo = DatosEnciclopedicosFicha.de('tallo');
    expect(tallo.datoCientifico, contains('muchas especies'));
    expect(tallo.datoCientifico, contains('suele representar'));
  });

  test('los estomas se describen por el intercambio de gases', () {
    final hoja = DatosEnciclopedicosFicha.de('hoja');
    expect(hoja.locomocionOFuncion, contains('intercambio de gases'));
    expect(hoja.locomocionOFuncion, contains('vapor de agua'));
  });

  test('la ficha digestiva diferencia el intestino delgado y el grueso', () {
    final intestinos = DatosEnciclopedicosFicha.de('intestinos');
    expect(intestinos.alimentacionOProceso, contains('intestino delgado'));
    expect(intestinos.alimentacionOProceso, contains('intestino grueso'));
  });
}
