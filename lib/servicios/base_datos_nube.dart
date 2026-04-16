import '../modelos/gasto.dart';

class BaseDatosNube {
  static final BaseDatosNube _instancia = BaseDatosNube._interno();

  factory BaseDatosNube() => _instancia;

  BaseDatosNube._interno();

  final Map<String, List<Map<String, dynamic>>> _ticketsPorUsuario = {};

  Future<void> guardarTicket({
    required String userId,
    required Gasto gasto,
  }) async {
    final tickets = _ticketsPorUsuario.putIfAbsent(userId, () => []);
    final existe = tickets.any((t) => t['id'] == gasto.id);
    if (existe) return;

    tickets.insert(0, gasto.toMap());
  }

  Future<void> eliminarTicket({
    required String userId,
    required String gastoId,
  }) async {
    final tickets = _ticketsPorUsuario[userId];
    if (tickets == null) return;
    tickets.removeWhere((t) => t['id'] == gastoId);
  }

  Future<List<Map<String, dynamic>>> obtenerTickets(String userId) async {
    final tickets = _ticketsPorUsuario[userId] ?? [];
    return List<Map<String, dynamic>>.from(tickets);
  }
}

