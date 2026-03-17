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
  final _controladorRestaurante = TextEditingController();
  final _controladorProducto = TextEditingController();
  final _controladorPrecio = TextEditingController();

  List<Producto> _productos = [];
  List<Participante> _participantes = [];

  @override
  void dispose() {
    _controladorRestaurante.dispose();
    _controladorProducto.dispose();
    _controladorPrecio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ticket'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre del restaurante
            TextField(
              controller: _controladorRestaurante,
              decoration: InputDecoration(
                labelText: 'Restaurante',
                hintText: 'Ej: La Paella de María',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.restaurant),
              ),
            ),
            const SizedBox(height: 24),

            // Título Items
            const Text(
              'Elementos del Ticket',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Formulario agregar producto
            TextField(
              controller: _controladorProducto,
              decoration: InputDecoration(
                labelText: 'Producto',
                hintText: 'Ej: Paella mixta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.fastfood),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _controladorPrecio,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Precio',
                hintText: '0.00€',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.euro),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _agregarProducto,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Producto'),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de productos
            if (_productos.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos agregados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productos.length,
                    itemBuilder: (context, index) {
                      final producto = _productos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.fastfood, color: Colors.orange),
                          title: Text(producto.nombre),
                          subtitle: Text('${producto.precio.toStringAsFixed(2)}€'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () => _eliminarProducto(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),

            // Título Participantes
            const Text(
              'Participantes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Botón agregar participante
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _mostrarDialogoAgregarParticipante,
                icon: const Icon(Icons.person_add),
                label: const Text('Agregar Participante'),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de participantes
            if (_participantes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Participantes agregados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _participantes.length,
                    itemBuilder: (context, index) {
                      final participante = _participantes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text(participante.nombre),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () => _eliminarParticipante(index),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Botón continuar DESTACADO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _crearGasto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

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
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controlador.text.isNotEmpty) {
                setState(() {
                  _participantes.add(
                    Participante(
                      id: DateTime.now().toString(),
                      nombre: controlador.text,
                    ),
                  );
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

  void _eliminarParticipante(int index) {
    setState(() {
      _participantes.removeAt(index);
    });
  }

  void _agregarProducto() {
    if (_controladorProducto.text.isEmpty || _controladorPrecio.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    final precio = double.tryParse(_controladorPrecio.text);
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precio inválido')),
      );
      return;
    }

    setState(() {
      _productos.add(
        Producto(
          id: DateTime.now().toString(),
          nombre: _controladorProducto.text,
          precio: precio,
        ),
      );
      _controladorProducto.clear();
      _controladorPrecio.clear();
    });
  }

  void _eliminarProducto(int index) {
    setState(() {
      _productos.removeAt(index);
    });
  }

  void _crearGasto() {
    if (_controladorRestaurante.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el nombre del restaurante')),
      );
      return;
    }

    if (_productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un producto')),
      );
      return;
    }

    if (_participantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos un participante')),
      );
      return;
    }

    final gasto = Gasto(
      id: DateTime.now().toString(),
      restaurante: _controladorRestaurante.text,
      fecha: DateTime.now(),
      productos: _productos,
      participantes: _participantes,
      modo: ModoGasto.equitativo,
    );

    widget.onGastoCreado(gasto);
  }
}
