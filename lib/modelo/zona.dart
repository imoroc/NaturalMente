class Zona {
  const Zona({
    required this.id,
    required this.nombre,
    required this.bloque,
    required this.resumen,
  });

  final String id;
  final String nombre;
  final String bloque;
  final String resumen;

  factory Zona.desdeMapa(Map<String, dynamic> mapa) {
    return Zona(
      id: mapa['id'] as String,
      nombre: mapa['nombre'] as String,
      bloque: mapa['bloque'] as String,
      resumen: mapa['resumen'] as String,
    );
  }
}
