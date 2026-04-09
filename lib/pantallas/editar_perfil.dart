import 'package:flutter/material.dart';

class EditarPerfilPage extends StatefulWidget {
  final String nombreInicial;
  final String emailInicial;
  final String? telefonoInicial;
  final String? fotoUrl;
  final void Function(String nombre, String email, String? telefono, String? fotoUrl, String? direccion, DateTime? fechaNacimiento, String? genero) onGuardar;

  const EditarPerfilPage({
    Key? key,
    required this.nombreInicial,
    required this.emailInicial,
    this.telefonoInicial,
    this.fotoUrl,
    required this.onGuardar,
  }) : super(key: key);

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
    late TextEditingController _direccionController;
    DateTime? _fechaNacimiento;
    String? _genero;
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombreInicial);
    _emailController = TextEditingController(text: widget.emailInicial);
    _telefonoController = TextEditingController(text: widget.telefonoInicial ?? '');
    _fotoUrl = widget.fotoUrl;
    _direccionController = TextEditingController();
    _fechaNacimiento = null;
    _genero = null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onGuardar(
                _nombreController.text,
                _emailController.text,
                _telefonoController.text.isEmpty ? null : _telefonoController.text,
                _fotoUrl,
                _direccionController.text.isEmpty ? null : _direccionController.text,
                _fechaNacimiento,
                _genero,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Aquí podrías implementar selección de imagen
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _fotoUrl != null && _fotoUrl!.isNotEmpty
                      ? NetworkImage(_fotoUrl!)
                      : null,
                  child: _fotoUrl == null || _fotoUrl!.isEmpty
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección (opcional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Fecha de nacimiento: '),
                  Text(_fechaNacimiento != null
                      ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
                      : 'No seleccionada'),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _fechaNacimiento = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _genero,
                items: const [
                  DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                  DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (valor) {
                  setState(() {
                    _genero = valor;
                  });
                },
                decoration: const InputDecoration(labelText: 'Género (opcional)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
