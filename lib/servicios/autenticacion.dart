import 'api_service.dart';

class UsuarioAutenticado {
  final String email;
  final String nombre;
  final bool esAdmin;

  const UsuarioAutenticado({
    required this.email,
    required this.nombre,
    required this.esAdmin,
  });
}

class ServicioAutenticacion {
  static final ServicioAutenticacion _instancia = ServicioAutenticacion._interno();

  factory ServicioAutenticacion() => _instancia;

  ServicioAutenticacion._interno();

  UsuarioAutenticado? _usuarioActual;
  final ApiService _api = ApiService();

  UsuarioAutenticado? get usuarioActual => _usuarioActual;

  bool get estaAutenticado => _usuarioActual != null;

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final data = await _api.iniciarSesion(
      email: emailNormalizado,
      password: password,
    );

    if (data == null) {
      return false;
    }

    _usuarioActual = UsuarioAutenticado(
      email: (data['email']?.toString() ?? emailNormalizado).trim().toLowerCase(),
      nombre: data['nombre']?.toString() ?? 'Usuario',
      esAdmin: data['esAdmin'] == true,
    );

    return true;
  }

  Future<bool> registrarUsuario({
    required String email,
    required String password,
    String? nombre,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final data = await _api.registrarUsuario(
      email: emailNormalizado,
      password: password,
      nombre: nombre,
    );

    return data != null;
  }

  void cerrarSesion() {
    _usuarioActual = null;
  }
}
