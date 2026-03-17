class Pago {
  final String de; // Nombre de quien debe
  final String a;  // Nombre de quien recibe
  final double cantidad;

  Pago({
    required this.de,
    required this.a,
    required this.cantidad,
  });

  @override
  String toString() => '$de debe $cantidad€ a $a';
}

class ServicioDivision {
  static final ServicioDivision _instancia = ServicioDivision._interno();

  factory ServicioDivision() {
    return _instancia;
  }

  ServicioDivision._interno();

  /// Calcula los pagos necesarios basados en deudas
  /// Simplifica los pagos para que haya menos transacciones
  List<Pago> calcularPagos(Map<String, double> deudas, Map<String, String> idANombre) {
    final pagos = <Pago>[];

    // Separar deudores y acreedores
    List<MapEntry<String, double>> deudores = [];
    List<MapEntry<String, double>> acreedores = [];

    final montoPromedio = deudas.values.isEmpty ? 0 : 
      deudas.values.reduce((a, b) => a + b) / deudas.length;

    for (var entry in deudas.entries) {
      if (entry.value > montoPromedio) {
        acreedores.add(entry);
      } else if (entry.value < montoPromedio) {
        deudores.add(entry);
      }
    }

    // Ordenar
    deudores.sort((a, b) => a.value.compareTo(b.value));
    acreedores.sort((a, b) => b.value.compareTo(a.value));

    // Calcular pagos
    for (var deudor in deudores) {
      double deuda = montoPromedio - deudor.value;
      
      for (var acreedor in acreedores) {
        if (deuda <= 0.01) break;
        
        double pago = deuda.clamp(0, acreedor.value - montoPromedio);
        if (pago > 0.01) {
          pagos.add(Pago(
            de: idANombre[deudor.key] ?? 'Desconocido',
            a: idANombre[acreedor.key] ?? 'Desconocido',
            cantidad: double.parse(pago.toStringAsFixed(2)),
          ));
          deuda -= pago;
        }
      }
    }

    return pagos;
  }

  String generarResumen(
    Map<String, double> deudas,
    Map<String, String> idANombre,
    double totalGasto,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════');
    buffer.writeln('RESUMEN DEL GASTO: ${totalGasto.toStringAsFixed(2)}€');
    buffer.writeln('═══════════════════════════════\n');

    for (var entry in deudas.entries) {
      final nombre = idANombre[entry.key] ?? 'Desconocido';
      final cantidad = entry.value.toStringAsFixed(2);
      buffer.writeln('$nombre: $cantidad€');
    }

    buffer.writeln('\n═══════════════════════════════');
    buffer.writeln('PAGOS SUGERIDOS:');
    buffer.writeln('═══════════════════════════════\n');

    final pagos = calcularPagos(deudas, idANombre);
    for (var pago in pagos) {
      buffer.writeln('${pago.de} → ${pago.a}: ${pago.cantidad.toStringAsFixed(2)}€');
    }

    return buffer.toString();
  }
}
