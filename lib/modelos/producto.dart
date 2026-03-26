class Producto {
  final String id;
  final String nombre;
  final double precio;
  int cantidad;

  // Mapa para rastrear cuánto consumió cada uno: {'ID_USER': CANTIDAD}
  Map<String, double> asignacionesProporcionales;

  // GETTER: Ahora es de solo lectura.
  // Si intentas hacer producto.participantesSeleccionados = ... te dará error.
  List<String> get participantesSeleccionados => asignacionesProporcionales.keys.toList();

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.cantidad = 1,
    Map<String, double>? asignacionesProporcionales,
  }) : this.asignacionesProporcionales = asignacionesProporcionales ?? {};

  // Precio de una unidad x cuántas unidades se compraron
  double get precioTotal => precio * cantidad;

  // Suma de todas las porciones repartidas entre amigos
  double get totalAsignado =>
      asignacionesProporcionales.values.fold(0.0, (sum, val) => sum + val);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      // Guardamos el mapa de proporciones directamente
      'asignacionesProporcionales': asignacionesProporcionales,
    };
  }

  // Método para actualizar quién come cuánto sin romper la lógica interna
  void actualizarAsignacion(String participanteId, double nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      asignacionesProporcionales.remove(participanteId);
    } else {
      asignacionesProporcionales[participanteId] = nuevaCantidad;
    }
  }
}