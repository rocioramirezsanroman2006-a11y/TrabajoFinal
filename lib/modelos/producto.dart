class Producto {
  final String id;
  final String nombre;
  final double precio;
  int cantidad;
  List<String> participantesSeleccionados; // IDs de participantes que consumieron

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
    this.participantesSeleccionados = const [],
  });

  double get precioTotal => precio * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'participantesSeleccionados': participantesSeleccionados,
    };
  }
}
