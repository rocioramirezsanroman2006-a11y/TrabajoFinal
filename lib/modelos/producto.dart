class Producto {
  final String id;
  final String nombre;
  final double precio;
  int cantidad;
  Map<String, double> asignacionesProporcionales;

  List<String> get participantesSeleccionados =>
      asignacionesProporcionales.keys.toList();

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
    Map<String, double>? asignacionesProporcionales,
  }) : asignacionesProporcionales = asignacionesProporcionales ?? {};

  double get precioTotal => precio * cantidad;

  double get totalAsignado =>
      asignacionesProporcionales.values.fold(0.0, (sum, val) => sum + val);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'asignacionesProporcionales': asignacionesProporcionales,
    };
  }

  void actualizarAsignacion(String participanteId, double nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      asignacionesProporcionales.remove(participanteId);
    } else {
      asignacionesProporcionales[participanteId] = nuevaCantidad;
    }
  }
}
