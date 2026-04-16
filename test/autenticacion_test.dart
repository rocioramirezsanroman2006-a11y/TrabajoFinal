import 'package:flutter_test/flutter_test.dart';
import 'package:split_bill_app/servicios/autenticacion.dart';

void main() {
  group('ServicioAutenticacion', () {
    final auth = ServicioAutenticacion();

    setUp(() {
      auth.cerrarSesion();
    });

    test('permite login de user@gmail.com', () async {
      final acceso = await auth.iniciarSesion(
        email: 'user@gmail.com',
        password: '12345678',
      );

      expect(acceso, isTrue);
      expect(auth.estaAutenticado, isTrue);
      expect(auth.usuarioActual?.esAdmin, isFalse);
    });

    test('permite login de admin@gmail.com', () async {
      final acceso = await auth.iniciarSesion(
        email: 'admin@gmail.com',
        password: '12345678',
      );

      expect(acceso, isTrue);
      expect(auth.usuarioActual?.esAdmin, isTrue);
    });

    test('rechaza credenciales incorrectas', () async {
      final acceso = await auth.iniciarSesion(
        email: 'user@gmail.com',
        password: 'incorrecta',
      );

      expect(acceso, isFalse);
      expect(auth.estaAutenticado, isFalse);
    });
  });
}


