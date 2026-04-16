import 'package:flutter_test/flutter_test.dart';
import 'package:split_bill_app/modelos/gasto.dart';
import 'package:split_bill_app/modelos/historial.dart';
import 'package:split_bill_app/modelos/participante.dart';
import 'package:split_bill_app/modelos/producto.dart';
import 'package:split_bill_app/servicios/autenticacion.dart';

void main() {
  group('ServicioHistorial tendencias', () {
    final historial = ServicioHistorial();

    setUp(() async {
      final auth = ServicioAutenticacion();
      auth.cerrarSesion();
      await auth.iniciarSesion(email: 'user@gmail.com', password: '12345678');

      for (final gasto in historial.obtenerGastos()) {
        historial.eliminarGasto(gasto.id);
      }
    });

    test('calcula gasto medio, restaurantes frecuentes y producto top', () {
      final participante = Participante(id: 'p1', nombre: 'Ana');

      historial.agregarGasto(
        Gasto(
          id: 'g1',
          restaurante: 'Sushi Go',
          fecha: DateTime.now().subtract(const Duration(days: 1)),
          productos: [
            Producto(id: 'pr1', nombre: 'Ramen', precio: 12, cantidad: 1),
            Producto(id: 'pr2', nombre: 'Gyoza', precio: 6, cantidad: 2),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      historial.agregarGasto(
        Gasto(
          id: 'g2',
          restaurante: 'Sushi Go',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr3', nombre: 'Ramen', precio: 12, cantidad: 2),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      final gastoMedio = historial.obtenerGastoMedioPorVisita();
      final frecuentes = historial.obtenerRestaurantesFrecuentes(limite: 1);
      final productoTop = historial.obtenerProductoMasConsumido();

      expect(gastoMedio, 24.0);
      expect(frecuentes.first.restaurante, 'Sushi Go');
      expect(frecuentes.first.visitas, 2);
      expect(productoTop?.nombre, 'Ramen');
      expect(productoTop?.unidades, 3);
    });

    test('sincroniza tickets con la nube del usuario actual', () async {
      final participante = Participante(id: 'p1', nombre: 'Ana');

      historial.agregarGasto(
        Gasto(
          id: 'nube-1',
          restaurante: 'Casa Pepe',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr1', nombre: 'Menu', precio: 15, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      await Future<void>.delayed(Duration.zero);
      final ticketsNube = await historial.obtenerTicketsNubeUsuarioActual();

      expect(ticketsNube.any((t) => t['id'] == 'nube-1'), isTrue);
    });

    test('agrupa correctamente la evolucion semanal por rango lunes-domingo', () {
      final participante = Participante(id: 'p1', nombre: 'Ana');

      historial.agregarGasto(
        Gasto(
          id: 'sem-1',
          restaurante: 'A',
          fecha: DateTime(2025, 12, 31, 23, 30),
          productos: [
            Producto(id: 'pr1', nombre: 'P1', precio: 40, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      historial.agregarGasto(
        Gasto(
          id: 'sem-2',
          restaurante: 'B',
          fecha: DateTime(2026, 1, 5, 0, 5),
          productos: [
            Producto(id: 'pr2', nombre: 'P2', precio: 10, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      historial.agregarGasto(
        Gasto(
          id: 'sem-3',
          restaurante: 'C',
          fecha: DateTime(2026, 1, 11, 22, 0),
          productos: [
            Producto(id: 'pr3', nombre: 'P3', precio: 20, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      historial.agregarGasto(
        Gasto(
          id: 'sem-4',
          restaurante: 'D',
          fecha: DateTime(2026, 1, 12, 10, 0),
          productos: [
            Producto(id: 'pr4', nombre: 'P4', precio: 30, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
        ),
      );

      final evolucion = historial.obtenerEvolucionSemanal(
        semanas: 2,
        fechaReferencia: DateTime(2026, 1, 7, 12, 0),
      );

      expect(evolucion, hasLength(2));
      expect(evolucion[0].etiqueta, 'Semana 1 mes 1');
      expect(evolucion[0].total, 40.0);
      expect(evolucion[1].etiqueta, 'Semana 2 mes 1');
      expect(evolucion[1].total, 30.0);
    });
  });
}

