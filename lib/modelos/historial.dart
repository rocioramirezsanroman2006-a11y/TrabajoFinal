import 'gasto.dart';

class ServicioHistorial {
    /// Devuelve una lista de 7 valores con el gasto total de cada día de la semana (Lunes a Domingo)
    List<double> obtenerGastoPorDiaSemana() {
      final hoy = DateTime.now();
      // Día de la semana actual (1=lunes, 7=domingo)
      final diaHoy = hoy.weekday;
      // Calcula el lunes de esta semana
      final lunes = hoy.subtract(Duration(days: diaHoy - 1));
      // Inicializa lista de 7 días
      List<double> gastos = List.filled(7, 0.0);
      for (var gasto in _gastos) {
        // Solo cuenta los gastos de esta semana
        final diferencia = gasto.fecha.difference(lunes).inDays;
        if (diferencia >= 0 && diferencia < 7) {
          gastos[diferencia] += gasto.totalGasto;
        }
      }
      return gastos;
    }
  static final ServicioHistorial _instancia = ServicioHistorial._interno();
  
  final List<Gasto> _gastos = [];
  final List<String> _favoritos = [];

  factory ServicioHistorial() {
    return _instancia;
  }

  ServicioHistorial._interno();

  List<Gasto> obtenerGastos() => List.from(_gastos);
  
  List<Gasto> obtenerGastosDeEstaSemana() {
    final hoy = DateTime.now();
    final hace7Dias = hoy.subtract(Duration(days: 7));
    
    return _gastos.where((g) => g.fecha.isAfter(hace7Dias)).toList();
  }

  double obtenerGastoTotal() {
    return _gastos.fold(0, (sum, gasto) => sum + gasto.totalGasto);
  }

  double obtenerGastoSemanalTotal() {
    return obtenerGastosDeEstaSemana().fold(0, (sum, gasto) => sum + gasto.totalGasto);
  }

  void agregarGasto(Gasto gasto) {
    _gastos.insert(0, gasto); // Insertar al inicio para orden descendente
  }

  void eliminarGasto(String id) {
    _gastos.removeWhere((g) => g.id == id);
  }

  List<String> obtenerFavoritos() => List.from(_favoritos);

  void agregarFavorito(String restaurante) {
    if (!_favoritos.contains(restaurante)) {
      _favoritos.add(restaurante);
    }
  }

  void eliminarFavorito(String restaurante) {
    _favoritos.remove(restaurante);
  }

  bool esFavorito(String restaurante) {
    return _favoritos.contains(restaurante);
  }

  List<String> obtenerRestaurantesUnicos() {
    final nicos = <String>{};
    for (var gasto in _gastos) {
      nicos.add(gasto.restaurante);
    }
    return nicos.toList();
  }

  Map<String, double> obtenerEstadisticas() {
    Map<String, double> stats = {};
    for (var gasto in _gastos) {
      stats[gasto.restaurante] = (stats[gasto.restaurante] ?? 0) + gasto.totalGasto;
    }
    return stats;
  }
}
