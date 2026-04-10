import 'producto.dart';
import 'participante.dart';

enum ModoGasto { equitativo, proporcional }

class Gasto {
  final String id;
  final String restaurante;
  final DateTime fecha;
  final List<Producto> productos;
  final List<Participante> participantes;
  ModoGasto modo;
  final String? notas;
  late Map<String, double> deudas;

  Gasto({
    required this.id,
    required this.restaurante,
    required this.fecha,
    required this.productos,
    required this.participantes,
    required this.modo,
    this.notas,
  }) {
    calcularDeudas();
  }


  double get totalGasto => productos.fold(0, (sum, p) => sum + p.precioTotal);

  Map<String, List<Producto>> obtenerProductosPorParticipante() {
    final mapa = <String, List<Producto>>{};
    for (var participante in participantes) {
      mapa[participante.id] = [];
    }
    for (var producto in productos) {
      for (var participanteId in producto.participantesSeleccionados) {
        if (mapa[participanteId] != null) {
          mapa[participanteId]!.add(producto);
        }
      }
    }
    return mapa;
  }

  void calcularDeudas() {
    deudas = {};

    // Inicializar deudas a cero para todos
    for (var p in participantes) {
      deudas[p.id] = 0.0;
    }

    if (modo == ModoGasto.equitativo) {
      // División equitativa total entre todos los participantes
      if (participantes.isNotEmpty) {
        double porPersona = totalGasto / participantes.length;
        for (var p in participantes) {
          deudas[p.id] = porPersona;
        }
      }
    } else {
      // División PROPORCIONAL basada en raciones
      for (var producto in productos) {
        // Obtenemos la suma de todas las raciones asignadas a este plato (ej: 5 + 0 + 0 = 5)
        double totalRacionesAsignadas = producto.totalAsignado;

        if (totalRacionesAsignadas > 0) {
          // Calculamos cuánto cuesta 1 ración de este plato específico
          double precioPorRacion = producto.precioTotal / totalRacionesAsignadas;

          // Repartimos el coste según las raciones de cada uno
          producto.asignacionesProporcionales.forEach((participanteId, raciones) {
            if (deudas.containsKey(participanteId)) {
              deudas[participanteId] = deudas[participanteId]! + (raciones * precioPorRacion);
            }
          });
        }
      }
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurante': restaurante,
      'fecha': fecha.toIso8601String(),
      'productos': productos.map((p) => p.toMap()).toList(),
      'participantes': participantes.map((p) => p.toMap()).toList(),
      'modo': modo.toString(),
      'notas': notas,
      'deudas': deudas,
    };
  }
 }
  
