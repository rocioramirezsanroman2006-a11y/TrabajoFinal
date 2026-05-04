import '../modelos/gasto.dart';
import 'api_service.dart';

class BaseDatosNube {
  static final BaseDatosNube _instancia = BaseDatosNube._interno();

  factory BaseDatosNube() => _instancia;

  BaseDatosNube._interno();

  final ApiService _api = ApiService();
  final Map<String, List<Map<String, dynamic>>> _cachePorUsuario = {};

  Future<void> guardarTicket({
    required String userId,
    required Gasto gasto,
  }) async {
    _guardarEnCache(userId, gasto.toMap());
    await _api.guardarGastoEnNube(userId: userId, gasto: gasto);
  }

  Future<void> eliminarTicket({
    required String userId,
    required String gastoId,
  }) async {
    _cachePorUsuario[userId]?.removeWhere((t) => t['id'] == gastoId);
    await _api.eliminarTicket(userId: userId, gastoId: gastoId);
  }

  Future<List<Map<String, dynamic>>> obtenerTickets(String userId) async {
    final ticketsNube = await _api.obtenerTickets(userId: userId);
    if (ticketsNube.isNotEmpty) {
      _cachePorUsuario[userId] = List<Map<String, dynamic>>.from(ticketsNube);
      return ticketsNube;
    }

    return List<Map<String, dynamic>>.from(_cachePorUsuario[userId] ?? []);
  }

  void _guardarEnCache(String userId, Map<String, dynamic> ticket) {
    final tickets = _cachePorUsuario.putIfAbsent(userId, () => []);
    final indiceExistente = tickets.indexWhere((t) => t['id'] == ticket['id']);
    if (indiceExistente != -1) {
      tickets[indiceExistente] = ticket;
      return;
    }

    tickets.insert(0, ticket);
  }
}
