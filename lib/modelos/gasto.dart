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
  late Map<String, double> deudas; // Quién debe a quién

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

  // Obtener qué consumió cada participante
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
    
    if (modo == ModoGasto.equitativo) {
      // División equitativa entre todos los participantes
      double porPersona = totalGasto / participantes.length;
      for (var participante in participantes) {
        deudas[participante.id] = porPersona;
      }
    } else {
      // División proporcional según qué consumieron
      for (var producto in productos) {
        if (producto.participantesSeleccionados.isNotEmpty) {
          double porPersona = producto.precioTotal / producto.participantesSeleccionados.length;
          for (var participanteId in producto.participantesSeleccionados) {
            deudas[participanteId] = (deudas[participanteId] ?? 0) + porPersona;
          }
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
