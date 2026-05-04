class Participante {
  final String id;
  final String nombre;

  Participante({
    required this.id,
    required this.nombre,
  });

  static Participante fromMap(Map<String, dynamic> mapa) {
    return Participante(
      id: mapa['id']?.toString() ?? '',
      nombre: mapa['nombre']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}
