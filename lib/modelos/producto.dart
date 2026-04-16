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

  // Cantidad máxima que todavía se puede asignar a un participante concreto.
  double maximoAsignablePara(String participanteId) {
    final actual = asignacionesProporcionales[participanteId] ?? 0.0;
    final usadoSinActual = totalAsignado - actual;
    final restante = cantidad - usadoSinActual;
    return restante < 0 ? 0 : restante.toDouble();
  }

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
    final maximoPermitido = maximoAsignablePara(participanteId);
    final cantidadAjustada = nuevaCantidad.clamp(0, maximoPermitido).toDouble();

    if (cantidadAjustada <= 0) {
      asignacionesProporcionales.remove(participanteId);
    } else {
      asignacionesProporcionales[participanteId] = cantidadAjustada;
    }
  }

  // Corrige asignaciones existentes para que no excedan la cantidad comprada.
  void normalizarAsignacionesAlMaximo() {
    if (asignacionesProporcionales.isEmpty) return;

    double acumulado = 0.0;
    final ids = asignacionesProporcionales.keys.toList();

    for (final id in ids) {
      final valor = asignacionesProporcionales[id] ?? 0.0;
      if (valor <= 0) {
        asignacionesProporcionales.remove(id);
        continue;
      }

      final restante = cantidad - acumulado;
      if (restante <= 0) {
        asignacionesProporcionales.remove(id);
        continue;
      }

      final ajustado = valor > restante ? restante : valor;
      asignacionesProporcionales[id] = ajustado;
      acumulado += ajustado;
    }
  }
}