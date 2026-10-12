class Ficha {
  const Ficha({
    required this.id,
    required this.zona,
    required this.curso,
    required this.titulo,
    required this.frase,
    required this.curiosidad,
  });

  final String id;
  final String zona;
  final String curso;
  final String titulo;
  final String frase;
  final String curiosidad;

  factory Ficha.desdeMapa(Map<String, dynamic> mapa) {
    return Ficha(
      id: mapa['id'] as String,
      zona: mapa['zona'] as String,
      curso: mapa['curso'] as String,
      titulo: mapa['titulo'] as String,
      frase: mapa['frase'] as String,
      curiosidad: mapa['curiosidad'] as String,
    );
  }
}
