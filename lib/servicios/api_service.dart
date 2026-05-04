import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/gasto.dart';

class ApiService {
  // IP para el emulador de Android (conecta con el localhost de tu PC)
  static const String baseUrl = 'https://backend-tickets-ooxo.onrender.com';

  Future<bool> guardarGastoEnNube({
    required String userId,
    required Gasto gasto,
  }) async {
    final url = Uri.parse('$baseUrl/tickets');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'userId': userId,
              'ticket': gasto.toMap(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerTickets({
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/tickets?userId=$userId');

    try {
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> eliminarTicket({
    required String userId,
    required String gastoId,
  }) async {
    final url = Uri.parse('$baseUrl/tickets/$gastoId?userId=$userId');

    try {
      final response = await http
          .delete(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> registrarUsuario({
    required String email,
    required String password,
    String? nombre,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              if (nombre != null) 'nombre': nombre.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['user'] is Map) {
        return Map<String, dynamic>.from(decoded['user'] as Map);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['user'] is Map) {
        return Map<String, dynamic>.from(decoded['user'] as Map);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}