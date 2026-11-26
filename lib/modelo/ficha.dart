enum AcabadoCromo { laton, nacar }

enum EtiquetaDatoCromo {
  grupo('Grupo'),
  habitat('Hábitat'),
  tipo('Tipo'),
  parte('Parte'),
  proceso('Proceso'),
  sistema('Sistema'),
  lugar('Lugar'),
  funcion('Función'),
  ejemplo('Ejemplo'),
  accion('Acción');

  const EtiquetaDatoCromo(this.texto);
  final String texto;
}

class DatoCromo {
  const DatoCromo({required this.etiqueta, required this.valor});

  final EtiquetaDatoCromo etiqueta;
  final String valor;

  factory DatoCromo.desdeMapa(Map<String, dynamic> mapa) {
    final etiqueta = EtiquetaDatoCromo.values
        .where((etiqueta) => etiqueta.texto == mapa['etiqueta'])
        .firstOrNull;
    final valor = mapa['valor'];
    if (etiqueta == null || valor is! String || valor.trim().isEmpty) {
      throw FormatException('Dato de cromo inválido', mapa);
    }
    return DatoCromo(etiqueta: etiqueta, valor: valor);
  }
}

class Ficha {
  const Ficha({
    required this.id,
    required this.zona,
    required this.curso,
    required this.titulo,
    required this.frase,
    required this.curiosidad,
    this.juego = '',
    this.acabado = AcabadoCromo.laton,
    this.arteCromo = false,
    this.resumenCromo = const [],
  });

  final String id;
  final String zona;
  final String curso;
  final String titulo;
  final String frase;
  final String curiosidad;
  final String juego;
  final AcabadoCromo acabado;
  final bool arteCromo;
  final List<DatoCromo> resumenCromo;

  factory Ficha.desdeMapa(Map<String, dynamic> mapa) {
    final resumen = mapa['resumenCromo'] as List<dynamic>? ?? const [];
    if (resumen.length > 2) {
      throw FormatException('El resumen admite hasta dos datos', mapa['id']);
    }
    return Ficha(
      id: mapa['id'] as String,
      zona: mapa['zona'] as String,
      curso: mapa['curso'] as String,
      titulo: mapa['titulo'] as String,
      frase: mapa['frase'] as String,
      curiosidad: mapa['curiosidad'] as String,
      juego: (mapa['juego'] as String?) ?? '',
      acabado: switch (mapa['acabado']) {
        null || 'laton' => AcabadoCromo.laton,
        'nacar' => AcabadoCromo.nacar,
        final valor => throw FormatException(
          'Acabado de cromo inválido',
          valor,
        ),
      },
      arteCromo: (mapa['arteCromo'] as bool?) ?? false,
      resumenCromo: List.unmodifiable(
        resumen.cast<Map<String, dynamic>>().map(DatoCromo.desdeMapa),
      ),
    );
  }
}
