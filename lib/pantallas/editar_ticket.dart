import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
  final ImagePicker _imagePicker = ImagePicker();

  List<Producto> _productos = [];
  List<Participante> _participantes = [];
  File? _imagenTicket;
  bool _analizando = false;

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
            // Zona de foto GRANDE
            GestureDetector(
              onTap: _mostrarOpcionesImagen,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 2,
                  ),
                ),
                child: _imagenTicket != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _imagenTicket!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          if (_analizando)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 56,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Sube la foto del ticket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'La app analizará automáticamente',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

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
            const SizedBox(height: 20),

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

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarDelGaleria();
              },
            ),
            if (_imagenTicket != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto'),
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imagenTicket = null;
                    _productos.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? foto =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (foto != null) {
        setState(() {
          _imagenTicket = File(foto.path);
          _analizando = true;
        });

        // Simular análisis OCR
        await Future.delayed(const Duration(seconds: 2));
        _analizarTicket();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _seleccionarDelGaleria() async {
    try {
      final XFile? foto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (foto != null) {
        setState(() {
          _imagenTicket = File(foto.path);
          _analizando = true;
        });

        // Simular análisis OCR
        await Future.delayed(const Duration(seconds: 2));
        _analizarTicket();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _analizarTicket() {
    // Simulación de OCR - En una app real usarías un servicio como Google Vision
    final productosDetectados = [
      {'nombre': 'Hamburguesa Clásica', 'precio': 12.50},
      {'nombre': 'Papas Fritas', 'precio': 5.00},
      {'nombre': 'Bebida Grande', 'precio': 3.50},
      {'nombre': 'Postre', 'precio': 7.00},
    ];

    setState(() {
      _productos.clear();
      for (var item in productosDetectados) {
        _productos.add(
          Producto(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            nombre: item['nombre'] as String,
            precio: item['precio'] as double,
          ),
        );
      }
      _analizando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✓ Ticket analizado: 4 productos detectados',
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
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
