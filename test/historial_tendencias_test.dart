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

    test('calcula top restaurantes por puntuacion media', () {
      final participante = Participante(id: 'p1', nombre: 'Ana');

      historial.agregarGasto(
        Gasto(
          id: 'rat-1',
          restaurante: 'R1',
          restauranteId: 'R1',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr1', nombre: 'P1', precio: 10, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
          valoracion: const ValoracionRestaurante(precio: 5, comida: 5, local: 4),
        ),
      );

      historial.agregarGasto(
        Gasto(
          id: 'rat-2',
          restaurante: 'R2',
          restauranteId: 'R2',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr2', nombre: 'P2', precio: 12, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
          valoracion: const ValoracionRestaurante(precio: 3, comida: 3, local: 3),
        ),
      );

      final top = historial.obtenerTopRestaurantesPorPuntuacion(limite: 5);

      expect(top, isNotEmpty);
      expect(top.first.restauranteId, 'r1');
      expect(top.first.puntuacionMedia, closeTo(4.666, 0.01));
      expect(top[1].restauranteId, 'r2');

      final topPrecio = historial.obtenerTopRestaurantesPorPuntuacion(
        limite: 5,
        criterio: CriterioRankingValoracion.precio,
      );
      final topComida = historial.obtenerTopRestaurantesPorPuntuacion(
        limite: 5,
        criterio: CriterioRankingValoracion.comida,
      );
      final topLocal = historial.obtenerTopRestaurantesPorPuntuacion(
        limite: 5,
        criterio: CriterioRankingValoracion.local,
      );

      expect(topPrecio.first.restauranteId, 'r1');
      expect(topComida.first.restauranteId, 'r1');
      expect(topLocal.first.restauranteId, 'r1');

      final topGastado = historial.obtenerTopRestaurantesPorGasto(limite: 3);
      expect(topGastado, hasLength(2));
      expect(topGastado.first.restaurante, 'R2');
      expect(topGastado.first.gastoTotal, 12.0);
    });

    test('normaliza restauranteId para evitar duplicados por formato', () {
      final participante = Participante(id: 'p1', nombre: 'Ana');

      historial.agregarGasto(
        Gasto(
          id: 'norm-1',
          restaurante: 'La Plaza',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr1', nombre: 'P1', precio: 10, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
          valoracion: const ValoracionRestaurante(precio: 4, comida: 4, local: 4),
        ),
      );

      historial.agregarGasto(
        Gasto(
          id: 'norm-2',
          restaurante: ' la plaza ',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr2', nombre: 'P2', precio: 15, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
          valoracion: const ValoracionRestaurante(precio: 5, comida: 5, local: 5),
        ),
      );

      final top = historial.obtenerTopRestaurantesPorPuntuacion();

      expect(top, hasLength(1));
      expect(top.first.restauranteId, 'la plaza');
      expect(top.first.valoraciones, 2);
    });

    test('permite editar valoracion de ticket guardado', () {
      final participante = Participante(id: 'p1', nombre: 'Ana');

      historial.agregarGasto(
        Gasto(
          id: 'edit-1',
          restaurante: 'La Bodega',
          fecha: DateTime.now(),
          productos: [
            Producto(id: 'pr1', nombre: 'Menu', precio: 20, cantidad: 1),
          ],
          participantes: [participante],
          modo: ModoGasto.equitativo,
          valoracion: const ValoracionRestaurante(precio: 2, comida: 2, local: 2),
        ),
      );

      final actualizado = historial.actualizarValoracionGasto(
        gastoId: 'edit-1',
        valoracion: const ValoracionRestaurante(precio: 5, comida: 4, local: 5),
      );

      final gastoActualizado = historial.obtenerGastos().firstWhere((g) => g.id == 'edit-1');

      expect(actualizado, isTrue);
      expect(gastoActualizado.valoracion, isNotNull);
      expect(gastoActualizado.valoracion!.media, closeTo(4.666, 0.01));
    });
  });
}

