import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../modelos/producto.dart';
import '../modelos/participante.dart';
import '../modelos/gasto.dart';

class PantallaEditarTicket extends StatefulWidget {
  final Function(Gasto) onGastoCreado;

  const PantallaEditarTicket({
    Key? key,
    required this.onGastoCreado,
  }) : super(key: key);

  @override
  State<PantallaEditarTicket> createState() => _PantallaEditarTicketState();
}

class _PantallaEditarTicketState extends State<PantallaEditarTicket> {
    Future<void> _mostrarNotificacionGasto(String restaurante, double total) async {
      // Implementación básica: solo muestra un SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gasto guardado en $restaurante: €${total.toStringAsFixed(2)}')),
        );
      }
      // Aquí puedes agregar la lógica real de notificaciones si lo deseas
    }
  // Controladores para los campos de texto
  final TextEditingController _controladorRestaurante = TextEditingController();
  final TextEditingController _controladorProducto = TextEditingController();
  final TextEditingController _controladorPrecio = TextEditingController();
  final TextEditingController _controladorCantidad = TextEditingController(text: '1');

  // Listas para productos y participantes
  final List<Producto> _productos = [];
  final List<Participante> _participantes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ticket'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _controladorRestaurante,
                      decoration: InputDecoration(
                        labelText: 'Restaurante',
                        hintText: 'Ej: La Paella de María',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        prefixIcon: Icon(Icons.restaurant, color: Colors.blue.shade400),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Elementos del Ticket',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controladorProducto,
                            decoration: InputDecoration(
                              labelText: 'Producto',
                              hintText: 'Ej: Paella mixta',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controladorPrecio,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Precio',
                              hintText: '0.00€',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _controladorCantidad,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: 'Cant.',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade100)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _agregarProducto,
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir Plato'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blue.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (_productos.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Platos agregados',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _productos.length,
                            itemBuilder: (context, index) {
                              final producto = _productos[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue.shade100, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${producto.cantidad}x ${producto.nombre}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${producto.precio.toStringAsFixed(2)}€/ud',
                                            style: TextStyle(
                                              color: Colors.blue.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      color: Colors.red,
                                      onPressed: () => _eliminarProducto(index),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    const Text(
                      'Participantes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _mostrarDialogoAgregarParticipante,
                        icon: const Icon(Icons.person_add),
                        label: const Text('+ Añadir participante'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.blue.shade400, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_participantes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _participantes.asMap().entries.map((e) {
                              final index = e.key;
                              final participante = e.value;
                              return Chip(
                                avatar: CircleAvatar(
                                  backgroundColor: _getColorForIndex(index),
                                  child: Text(
                                    participante.nombre[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                label: Text(participante.nombre),
                                onDeleted: () => _eliminarParticipante(index),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _crearGasto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ...existing code...

  void _mostrarDialogoAgregarParticipante() {
    final controlador = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Participante'),
        content: TextField(
          controller: controlador,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Nombre', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (controlador.text.isNotEmpty) {
                setState(() {
                  _participantes.add(Participante(
                      id: DateTime.now().toString(), nombre: controlador.text));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _eliminarParticipante(int index) =>
      setState(() => _participantes.removeAt(index));

  void _agregarProducto() {
    if (_controladorProducto.text.isEmpty || _controladorPrecio.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    final precio = double.tryParse(_controladorPrecio.text);
    final cantidad = int.tryParse(_controladorCantidad.text) ?? 1;
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Precio inválido')));
      return;
    }
    setState(() {
      _productos.add(Producto(
        id: DateTime.now().toString(),
        nombre: _controladorProducto.text,
        precio: precio,
        cantidad: cantidad,
      ));
      _controladorProducto.clear();
      _controladorPrecio.clear();
      _controladorCantidad.text = '1';
    });
  }

  void _eliminarProducto(int index) =>
      setState(() => _productos.removeAt(index));

  void _crearGasto() async {
    if (_controladorRestaurante.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa el restaurante')));
      return;
    }
    if (_productos.isEmpty || _participantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faltan productos o participantes')));
      return;
    }

    // CORRECCIÓN: Inicializar el mapa de asignaciones para cada producto
    final productosConAsignaciones = _productos.map((producto) {
      // Creamos un nuevo mapa con 1.0 para cada participante actual
      Map<String, double> inicial = {};
      for (var p in _participantes) {
        inicial[p.id] = 1.0;
      }

      return Producto(
        id: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: producto.cantidad,
        asignacionesProporcionales: inicial, // Pasamos el mapa, no la lista
      );
    }).toList();

    final gasto = Gasto(
      id: DateTime.now().toString(),
      restaurante: _controladorRestaurante.text,
      fecha: DateTime.now(),
      productos: productosConAsignaciones,
      participantes: _participantes,
      modo: ModoGasto.equitativo,
    );

    await _mostrarNotificacionGasto(gasto.restaurante, gasto.totalGasto);
    widget.onGastoCreado(gasto);
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo
    ];
    return colors[index % colors.length];
  }
}
