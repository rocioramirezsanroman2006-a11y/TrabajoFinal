import 'package:flutter_test/flutter_test.dart';
import 'package:split_bill_app/modelos/producto.dart';

void main() {
  group('Producto asignaciones proporcionales', () {
    test('no permite superar la cantidad total del plato al actualizar', () {
      final producto = Producto(
        id: '1',
        nombre: 'Paella',
        precio: 10,
        cantidad: 2,
        asignacionesProporcionales: {
          'a': 1.5,
          'b': 0.5,
        },
      );

      producto.actualizarAsignacion('a', 2.0);

      expect(producto.asignacionesProporcionales['a'], 1.5);
      expect(producto.totalAsignado, 2.0);
    });

    test('normaliza asignaciones existentes si exceden el total comprado', () {
      final producto = Producto(
        id: '1',
        nombre: 'Croquetas',
        precio: 8,
        cantidad: 2,
        asignacionesProporcionales: {
          'a': 1.0,
          'b': 1.0,
          'c': 1.0,
        },
      );

      producto.normalizarAsignacionesAlMaximo();

      expect(producto.totalAsignado, 2.0);
      expect(producto.asignacionesProporcionales.containsKey('c'), isFalse);
    });
  });
}

