import 'producto.dart';
import 'participante.dart';

enum ModoGasto { equitativo, proporcional }

class ValoracionRestaurante {
  final int precio;
  final int comida;
  final int local;

  const ValoracionRestaurante({
    required this.precio,
    required this.comida,
    required this.local,
  });

  double get media => (precio + comida + local) / 3;

  Map<String, dynamic> toMap() {
    return {
      'precio': precio,
      'comida': comida,
      'local': local,
      'media': media,
    };
  }

  static ValoracionRestaurante? fromMap(Map<String, dynamic>? mapa) {
    if (mapa == null) return null;
    final precio = (mapa['precio'] is num)
        ? (mapa['precio'] as num).toInt()
        : int.tryParse('${mapa['precio']}') ?? 0;
    final comida = (mapa['comida'] is num)
        ? (mapa['comida'] as num).toInt()
        : int.tryParse('${mapa['comida']}') ?? 0;
    final local = (mapa['local'] is num)
        ? (mapa['local'] as num).toInt()
        : int.tryParse('${mapa['local']}') ?? 0;

    return ValoracionRestaurante(
      precio: precio,
      comida: comida,
      local: local,
    );
  }
}

class Gasto {
  final String id;
  final String restaurante;
  final String restauranteId;
  final DateTime fecha;
  final List<Producto> productos;
  final List<Participante> participantes;
  ModoGasto modo;
  final String? notas;
  ValoracionRestaurante? valoracion;
  late Map<String, double> deudas;

  Gasto({
    required this.id,
    required String restaurante,
    String? restauranteId,
    required this.fecha,
    required this.productos,
    required this.participantes,
    required this.modo,
    this.notas,
    this.valoracion,
  })  : restaurante = restaurante.trim(),
        restauranteId = normalizarRestauranteId(
          (restauranteId == null || restauranteId.trim().isEmpty)
              ? restaurante
              : restauranteId,
        ) {
    calcularDeudas();
  }

  static String normalizarRestauranteId(String valor) {
    return valor.trim().toLowerCase();
  }

  static ModoGasto _modoDesde(dynamic valor) {
    final texto = valor?.toString().toLowerCase() ?? '';
    if (texto.contains('proporcional')) {
      return ModoGasto.proporcional;
    }
    return ModoGasto.equitativo;
  }

  static DateTime _fechaDesde(dynamic valor) {
    if (valor is DateTime) return valor;
    if (valor is String) {
      return DateTime.tryParse(valor) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static Gasto fromMap(Map<String, dynamic> mapa) {
    final productos = (mapa['productos'] as List?)
            ?.whereType<Map>()
            .map((p) => Producto.fromMap(Map<String, dynamic>.from(p)))
            .toList() ??
        [];
    final participantes = (mapa['participantes'] as List?)
            ?.whereType<Map>()
            .map((p) => Participante.fromMap(Map<String, dynamic>.from(p)))
            .toList() ??
        [];

    final valoracion = mapa['valoracion'] is Map
        ? ValoracionRestaurante.fromMap(
            Map<String, dynamic>.from(mapa['valoracion'] as Map),
          )
        : null;

    final gasto = Gasto(
      id: mapa['id']?.toString() ?? '',
      restaurante: mapa['restaurante']?.toString() ?? '',
      restauranteId: mapa['restauranteId']?.toString(),
      fecha: _fechaDesde(mapa['fecha']),
      productos: productos,
      participantes: participantes,
      modo: _modoDesde(mapa['modo']),
      notas: mapa['notas']?.toString(),
      valoracion: valoracion,
    );

    final deudasRaw = mapa['deudas'];
    if (deudasRaw is Map) {
      gasto.deudas = deudasRaw.map((key, value) {
        final cantidad = value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0;
        return MapEntry(key.toString(), cantidad);
      });
    }

    return gasto;
  }

  double get totalGasto => productos.fold(0, (sum, p) => sum + p.precioTotal);

  bool get puedeConfirmarDivision {
    if (modo != ModoGasto.proporcional) {
      return true;
    }

    return productos.every((producto) => producto.estaCompletamenteAsignado());
  }

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
        producto.normalizarAsignacionesAlMaximo();

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
      'restauranteId': restauranteId,
      'fecha': fecha.toIso8601String(),
      'totalGasto': totalGasto,
      'productos': productos.map((p) => p.toMap()).toList(),
      'participantes': participantes.map((p) => p.toMap()).toList(),
      'modo': modo.toString(),
      'notas': notas,
      'valoracion': valoracion?.toMap(),
      'deudas': deudas,
    };
  }
}
