import 'gasto.dart';
import '../servicios/autenticacion.dart';
import '../servicios/base_datos_nube.dart';
import 'dart:async';

class PuntoEvolucion {
  final String etiqueta;
  final double total;

  const PuntoEvolucion({
    required this.etiqueta,
    required this.total,
  });
}

class RestauranteFrecuencia {
  final String restaurante;
  final int visitas;
  final double gastoTotal;

  const RestauranteFrecuencia({
    required this.restaurante,
    required this.visitas,
    required this.gastoTotal,
  });
}

class ProductoFrecuencia {
  final String nombre;
  final int unidades;

  const ProductoFrecuencia({
    required this.nombre,
    required this.unidades,
  });
}

class ServicioHistorial {
  static final ServicioHistorial _instancia = ServicioHistorial._interno();
  
  final List<Gasto> _gastos = [];
  final List<String> _favoritos = [];
  final BaseDatosNube _nube = BaseDatosNube();
  final ServicioAutenticacion _auth = ServicioAutenticacion();

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

  List<double> obtenerGastoPorDiaSemana({DateTime? fechaReferencia}) {
    final referencia = _normalizarFecha(fechaReferencia ?? DateTime.now());
    final inicioSemana = _inicioDeSemana(referencia);
    final finSemanaExclusivo = inicioSemana.add(const Duration(days: 7));
    final totales = List<double>.filled(7, 0.0);

    for (final gasto in _gastos) {
      final fecha = _normalizarFecha(gasto.fecha);
      if (fecha.isBefore(inicioSemana) || !fecha.isBefore(finSemanaExclusivo)) {
        continue;
      }

      final indice = fecha.weekday - 1; // 0=lunes, 6=domingo
      totales[indice] += gasto.totalGasto;
    }

    return totales;
  }

  void agregarGasto(Gasto gasto) {
    final yaExiste = _gastos.any((g) => g.id == gasto.id);
    if (yaExiste) return;
    _gastos.insert(0, gasto); // Insertar al inicio para orden descendente
    unawaited(_nube.guardarTicket(userId: _usuarioActualId, gasto: gasto));
  }

  void eliminarGasto(String id) {
    _gastos.removeWhere((g) => g.id == id);
    unawaited(_nube.eliminarTicket(userId: _usuarioActualId, gastoId: id));
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
    final stats = <String, double>{};
    for (var gasto in _gastos) {
      stats[gasto.restaurante] = (stats[gasto.restaurante] ?? 0) + gasto.totalGasto;
    }
    return stats;
  }

  List<PuntoEvolucion> obtenerEvolucionSemanal({
    int semanas = 8,
    DateTime? fechaReferencia,
  }) {
    final referencia = _normalizarFecha(fechaReferencia ?? DateTime.now());
    final inicioSemanaActual = _inicioDeSemana(referencia);
    final puntos = <PuntoEvolucion>[];

    final totalesPorSemana = <String, double>{};
    for (final gasto in _gastos) {
      final inicioSemanaGasto = _inicioDeSemana(_normalizarFecha(gasto.fecha));
      final clave = _claveSemana(inicioSemanaGasto);
      totalesPorSemana[clave] = (totalesPorSemana[clave] ?? 0.0) + gasto.totalGasto;
    }

    for (var i = semanas - 1; i >= 0; i--) {
      final inicio = inicioSemanaActual.subtract(Duration(days: i * 7));
      final clave = _claveSemana(inicio);
      final total = totalesPorSemana[clave] ?? 0.0;

      puntos.add(PuntoEvolucion(
        etiqueta: _etiquetaRangoSemana(inicio),
        total: total,
      ));
    }

    return puntos;
  }

  List<PuntoEvolucion> obtenerEvolucionMensual({int meses = 6}) {
    final hoy = DateTime.now();
    final puntos = <PuntoEvolucion>[];

    for (var i = meses - 1; i >= 0; i--) {
      final mesBase = DateTime(hoy.year, hoy.month - i, 1);
      final inicio = DateTime(mesBase.year, mesBase.month, 1);
      final fin = DateTime(mesBase.year, mesBase.month + 1, 1);

      final total = _gastos
          .where((g) => !g.fecha.isBefore(inicio) && g.fecha.isBefore(fin))
          .fold(0.0, (sum, g) => sum + g.totalGasto);

      puntos.add(PuntoEvolucion(
        etiqueta: '${inicio.month.toString().padLeft(2, '0')}/${inicio.year.toString().substring(2)}',
        total: total,
      ));
    }

    return puntos;
  }

  List<RestauranteFrecuencia> obtenerRestaurantesFrecuentes({int limite = 5}) {
    final mapaFrecuencia = <String, int>{};
    final mapaGasto = <String, double>{};

    for (final gasto in _gastos) {
      mapaFrecuencia[gasto.restaurante] = (mapaFrecuencia[gasto.restaurante] ?? 0) + 1;
      mapaGasto[gasto.restaurante] = (mapaGasto[gasto.restaurante] ?? 0) + gasto.totalGasto;
    }

    final lista = mapaFrecuencia.entries
        .map((entry) => RestauranteFrecuencia(
              restaurante: entry.key,
              visitas: entry.value,
              gastoTotal: mapaGasto[entry.key] ?? 0.0,
            ))
        .toList();

    lista.sort((a, b) {
      final porVisitas = b.visitas.compareTo(a.visitas);
      if (porVisitas != 0) return porVisitas;
      return b.gastoTotal.compareTo(a.gastoTotal);
    });

    return lista.take(limite).toList();
  }

  double obtenerGastoMedioPorVisita() {
    if (_gastos.isEmpty) return 0;
    return obtenerGastoTotal() / _gastos.length;
  }

  ProductoFrecuencia? obtenerProductoMasConsumido() {
    if (_gastos.isEmpty) return null;

    final mapaUnidades = <String, int>{};
    for (final gasto in _gastos) {
      for (final producto in gasto.productos) {
        mapaUnidades[producto.nombre] =
            (mapaUnidades[producto.nombre] ?? 0) + producto.cantidad;
      }
    }

    if (mapaUnidades.isEmpty) return null;

    final masConsumido = mapaUnidades.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    return ProductoFrecuencia(
      nombre: masConsumido.key,
      unidades: masConsumido.value,
    );
  }

  Future<List<Map<String, dynamic>>> obtenerTicketsNubeUsuarioActual() {
    return _nube.obtenerTickets(_usuarioActualId);
  }

  String get _usuarioActualId => _auth.usuarioActual?.email ?? 'anonimo';

  DateTime _inicioDeSemana(DateTime fecha) {
    final dia = fecha.weekday;
    return DateTime(fecha.year, fecha.month, fecha.day).subtract(Duration(days: dia - 1));
  }

  DateTime _normalizarFecha(DateTime fecha) {
    final local = fecha.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  String _claveSemana(DateTime inicioSemana) {
    return '${inicioSemana.year}-${inicioSemana.month.toString().padLeft(2, '0')}-${inicioSemana.day.toString().padLeft(2, '0')}';
  }

  String _etiquetaRangoSemana(DateTime inicioSemana) {
    final finSemana = inicioSemana.add(const Duration(days: 6));
    final mesEtiqueta = finSemana.month;
    final primerDiaMes = DateTime(finSemana.year, finSemana.month, 1);
    final inicioPrimeraSemanaDelMes = _inicioDeSemana(primerDiaMes);
    final semanaDelMes =
        (inicioSemana.difference(inicioPrimeraSemanaDelMes).inDays ~/ 7) + 1;
    return 'Semana $semanaDelMes mes $mesEtiqueta';
  }
}
