import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../servicios/parser_ticket.dart';
import '../servicios/api_service.dart';
import '../modelos/gasto.dart';
import '../modelos/producto.dart';

class ResultadoRevisionOcr {
  final ResultadoParseTicket? datosConfirmados;
  final ImageSource? repetirFuente;

  const ResultadoRevisionOcr._({
    this.datosConfirmados,
    this.repetirFuente,
  });

  factory ResultadoRevisionOcr.confirmar(ResultadoParseTicket datos) {
    return ResultadoRevisionOcr._(datosConfirmados: datos);
  }

  factory ResultadoRevisionOcr.repetir(ImageSource source) {
    return ResultadoRevisionOcr._(repetirFuente: source);
  }
}

class PantallaRevisionOcrTicket extends StatefulWidget {
  final ResultadoParseTicket resultado;

  const PantallaRevisionOcrTicket({
    super.key,
    required this.resultado,
  });

  @override
  State<PantallaRevisionOcrTicket> createState() => _PantallaRevisionOcrTicketState();
}

class _PantallaRevisionOcrTicketState extends State<PantallaRevisionOcrTicket> {
  late final TextEditingController _restauranteController;
  final List<_ProductoEditable> _productos = [];
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService(); // Instanciamos el servicio

  @override
  void initState() {
    super.initState();
    _restauranteController = TextEditingController(
      text: widget.resultado.restauranteDetectado ?? '',
    );
    for (final producto in widget.resultado.productos) {
      _productos.add(_ProductoEditable.fromDetectado(producto));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _restauranteController.dispose();
    for (final producto in _productos) {
      producto.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCalculado = _productos.fold<double>(
      0,
          (sum, p) => sum + (p.precioValor * p.cantidadValor),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisión OCR'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revisa y ajusta los datos detectados antes de usarlos.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _restauranteController,
                    decoration: const InputDecoration(
                      labelText: 'Restaurante detectado',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Productos detectados',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: _agregarProductoVacio,
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_productos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('No se detectaron productos. Puedes añadirlos manualmente.'),
                    )
                  else
                    ..._productos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return _tarjetaProducto(index, item);
                    }),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total OCR detectado: ${widget.resultado.totalDetectado?.toStringAsFixed(2) ?? '-'}€',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Total actual revisado: ${totalCalculado.toStringAsFixed(2)}€',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(
                              ResultadoRevisionOcr.repetir(ImageSource.camera),
                            );
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Repetir cámara'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(
                              ResultadoRevisionOcr.repetir(ImageSource.gallery),
                            );
                          },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Repetir galería'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmarYGuardar,
                      child: const Text('Usar y Guardar datos'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaProducto(int index, _ProductoEditable item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.nombre,
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _productos.removeAt(index).dispose();
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item.cantidad,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: item.precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Precio'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _agregarProductoVacio() {
    setState(() {
      _productos.add(_ProductoEditable.vacio());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _confirmarYGuardar() async {
    // 1. Esta lista usa la clase que acabas de pasarme del Parser
    final listaOcrConfirmada = <ProductoDetectadoTicket>[];

    // 2. Esta lista usa tu clase oficial para la base de datos
    final listaParaBaseDatos = <Producto>[];

    for (final item in _productos) {
      final nombreStr = item.nombre.text.trim();
      final cantidadInt = int.tryParse(item.cantidad.text.trim()) ?? 1;
      final precioDb = double.tryParse(item.precio.text.replaceAll(',', '.').trim());

      if (nombreStr.isEmpty || precioDb == null || precioDb <= 0) continue;

      // Guardamos para el resultado del OCR (lo que espera el Parser)
      listaOcrConfirmada.add(
        ProductoDetectadoTicket(
            nombre: nombreStr,
            precio: precioDb,
            cantidad: cantidadInt
        ),
      );

      // Guardamos para tu modelo Gasto (lo que va a MongoDB)
      listaParaBaseDatos.add(
        Producto(
          id: DateTime.now().microsecondsSinceEpoch.toString() + nombreStr,
          nombre: nombreStr,
          precio: precioDb,
          cantidad: cantidadInt,
          asignacionesProporcionales: {}, // Mapa vacío obligatorio
        ),
      );
    }

    if (listaOcrConfirmada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tener al menos un producto válido.')),
      );
      return;
    }

    // Mostrar rueda de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Creamos el Gasto oficial
      final nuevoGasto = Gasto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        restaurante: _restauranteController.text.trim().isEmpty
            ? "Restaurante Desconocido"
            : _restauranteController.text.trim(),
        fecha: DateTime.now(),
        productos: listaParaBaseDatos,
        participantes: [],
        modo: ModoGasto.equitativo,
      );

      // Enviar al Backend (Node.js)
      bool exito = await _apiService.guardarGastoEnNube(
        userId: "usuario_demo_1",
        gasto: nuevoGasto,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerramos el cargando

      if (exito) {
        final totalFinal = listaOcrConfirmada.fold<double>(0, (sum, p) => sum + (p.precio * p.cantidad));

        final resultadoFinal = ResultadoParseTicket(
          restauranteDetectado: nuevoGasto.restaurante,
          productos: listaOcrConfirmada,
          totalDetectado: totalFinal,
          lineas: widget.resultado.lineas,
        );

        // Volvemos a la pantalla anterior con el éxito
        Navigator.of(context).pop(ResultadoRevisionOcr.confirmar(resultadoFinal));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar en MongoDB. ¿Servidor encendido?')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      print("Error detallado: $e");
    }
  }
}

class _ProductoEditable {
  final TextEditingController nombre;
  final TextEditingController cantidad;
  final TextEditingController precio;

  _ProductoEditable({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });

  factory _ProductoEditable.fromDetectado(ProductoDetectadoTicket p) {
    return _ProductoEditable(
      nombre: TextEditingController(text: p.nombre),
      cantidad: TextEditingController(text: p.cantidad.toString()),
      precio: TextEditingController(text: p.precio.toStringAsFixed(2)),
    );
  }

  factory _ProductoEditable.vacio() {
    return _ProductoEditable(
      nombre: TextEditingController(),
      cantidad: TextEditingController(text: '1'),
      precio: TextEditingController(),
    );
  }

  void dispose() {
    nombre.dispose();
    cantidad.dispose();
    precio.dispose();
  }

  int get cantidadValor => int.tryParse(cantidad.text.trim()) ?? 1;
  double get precioValor => double.tryParse(precio.text.replaceAll(',', '.').trim()) ?? 0;
}