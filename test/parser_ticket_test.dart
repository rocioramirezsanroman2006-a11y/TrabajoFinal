import 'package:flutter_test/flutter_test.dart';
import 'package:split_bill_app/servicios/parser_ticket.dart';

void main() {
  group('ParserTicket', () {
    test('extrae restaurante, productos y total desde texto OCR simple', () {
      const texto = '''
BAR LA PLAZA
1x Cafe 1,50
Tostada 2,20
TOTAL 3,70
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.restauranteDetectado, 'BAR LA PLAZA');
      expect(resultado.productos, hasLength(2));
      expect(resultado.productos.first.nombre, 'Cafe');
      expect(resultado.productos.first.cantidad, 1);
      expect(resultado.productos.first.precio, 1.50);
      expect(resultado.totalDetectado, 3.70);
    });

    test('ignora lineas no utiles de ticket', () {
      const texto = '''
SUPERMERCADO XYZ
FECHA 01/01/2026
NIF B12345678
Leche Entera 1,15
Subtotal 1,15
IVA 0,05
TOTAL 1,20
Gracias por su visita
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'Leche Entera');
      expect(resultado.totalDetectado, 1.20);
    });

    test('detecta producto cuando nombre y precio vienen en lineas separadas', () {
      const texto = '''
BAR CENTRAL
Paella mixta
12,50
TOTAL 12,50
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'Paella mixta');
      expect(resultado.productos.first.precio, 12.50);
    });

    test('detecta lineas con precio al inicio sin poner el precio como nombre', () {
      const texto = '''
RESTAURANTE COSTA
8,90 Ensalada Cesar
TOTAL 8,90
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'Ensalada Cesar');
      expect(resultado.productos.first.precio, 8.90);
    });

    test('corta el escaneo al detectar TOTAL e ignora lineas posteriores', () {
      const texto = '''
BAR CENTRO
Paella 12,50
TOTAL 12,50
Gracias por su visita
Promo siguiente compra 2,00
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'Paella');
      expect(resultado.productos.first.precio, 12.50);
      expect(resultado.totalDetectado, 12.50);
    });

    test('no incluye lineas de IVA como productos', () {
      const texto = '''
BAR NORTE
Cafe 1,50
IVA 10% 0,15
TOTAL 1,65
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'Cafe');
      expect(resultado.totalDetectado, 1.65);
    });

    test('parsea ticket de restaurante con cantidad descripcion precio importe', () {
      const texto = '''
RTE. VENTA SAN JOSE
UNID. DESCRIPCION PRECIO IMPORTE
3,000 COCA COLA 2,00 6,00
4,000 BARRITA DE PAN 1,10 4,40
2,000 PLATO COMBINADO N6 8,00 16,00
BASE 59,18
%IVA 10,00
IMP.1VA 5,92
TOTAL 65,10
TARJETA 65,10
GRACIAS POR SU VISITA
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.totalDetectado, 65.10);
      expect(resultado.productos, hasLength(3));
      expect(resultado.productos[0].nombre, 'COCA COLA');
      expect(resultado.productos[0].cantidad, 3);
      expect(resultado.productos[0].precio, 2.00);
      expect(resultado.productos[1].nombre, 'BARRITA DE PAN');
      expect(resultado.productos[1].cantidad, 4);
      expect(resultado.productos[1].precio, 1.10);
      expect(resultado.productos[2].nombre, 'PLATO COMBINADO N6');
      expect(resultado.productos[2].cantidad, 2);
      expect(resultado.productos[2].precio, 8.00);
    });

    test('ignora lineas numericas fuera del bloque de detalle del ticket', () {
      const texto = '''
RESTAURANTE PUERTO RICO
TLF. 91.521.98.34
N. TICKET: 18339
UNID. DESCRIPCION PRECIO IMPORTE
2 BARRITA PAN 0,60 1,20
2 AGUA MINERAL 1,50 3,00
TOTAL EUROS 19,95
GRACIAS POR SU VISITA
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(2));
      expect(resultado.productos[0].nombre, 'BARRITA PAN');
      expect(resultado.productos[1].nombre, 'AGUA MINERAL');
      expect(resultado.totalDetectado, 19.95);
    });

    test('corrige cantidad cuando OCR pone 0 al inicio pero hay precio e importe', () {
      const texto = '''
UNID. DESCRIPCION PRECIO IMPORTE
0 AGUARIUS LIMON 1,10 4,40
TOTAL 4,40
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'AGUARIUS LIMON');
      expect(resultado.productos.first.cantidad, 4);
      expect(resultado.productos.first.precio, closeTo(1.10, 0.01));
    });

    test('no convierte telefono ni comensal en producto aunque haya precios cerca', () {
      const texto = '''
RESTAURANTE X
TLF. 91.521.98.34
Comensals10
UNID. DESCRIPCION PRECIO IMPORTE
2 BARRITA PAN 0,60 1,20
TOTAL 1,20
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(1));
      expect(resultado.productos.first.nombre, 'BARRITA PAN');
    });

    test('detecta bloque detalle con cabecera en catalan', () {
      const texto = '''
SALAMANCA
Data: 11/03/2018  Hora: 16:30:00
Comensals:10
Descripcio Quant Preu Import
PAELLA DE MARISCO 8,00 17,95 143,60
COCA COLA 1,00 2,55 2,55
Total: 218,55
''';

      final resultado = ParserTicket.parsearTexto(texto);

      expect(resultado.productos, hasLength(2));
      expect(resultado.productos[0].nombre, 'PAELLA DE MARISCO');
      expect(resultado.productos[0].cantidad, 8);
      expect(resultado.productos[1].nombre, 'COCA COLA');
      expect(resultado.productos[1].cantidad, 1);
      expect(resultado.totalDetectado, 218.55);
    });
  });
}

