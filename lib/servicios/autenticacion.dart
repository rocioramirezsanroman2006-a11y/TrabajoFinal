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

  UsuarioAutenticado? get usuarioActual => _usuarioActual;

  bool get estaAutenticado => _usuarioActual != null;

  final Map<String, String> _credenciales = const {
    'user@gmail.com': '12345678',
    'admin@gmail.com': '12345678',
  };

  Future<bool> iniciarSesion({
    required String email,
    required String password,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();
    final passwordGuardado = _credenciales[emailNormalizado];

    if (passwordGuardado == null || passwordGuardado != password) {
      return false;
    }

    _usuarioActual = UsuarioAutenticado(
      email: emailNormalizado,
      nombre: emailNormalizado == 'admin@gmail.com' ? 'Administrador' : 'Usuario',
      esAdmin: emailNormalizado == 'admin@gmail.com',
    );

    return true;
  }

  void cerrarSesion() {
    _usuarioActual = null;
  }
}

