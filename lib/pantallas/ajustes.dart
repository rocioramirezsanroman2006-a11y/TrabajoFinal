import 'package:flutter/material.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({Key? key}) : super(key: key);

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  bool _notificaciones = true;
  bool _historialAutomatico = true;
  String _moneda = '€';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección Notificaciones
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                title: const Text('Recordatorios de gastos'),
                subtitle: const Text('Recibir notificaciones de nuevos gastos'),
                trailing: Switch(
                  value: _notificaciones,
                  onChanged: (valor) {
                    setState(() {
                      _notificaciones = valor;
                    });
                  },
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: ListTile(
                title: const Text('Guardar automáticamente'),
                subtitle: const Text('Guardar gastos sin confirmación'),
                trailing: Switch(
                  value: _historialAutomatico,
                  onChanged: (valor) {
                    setState(() {
                      _historialAutomatico = valor;
                    });
                  },
                ),
              ),
            ),
            const Divider(),

            // Sección Preferencias
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Preferencias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                title: const Text('Moneda'),
                subtitle: Text('Actualmente: $_moneda'),
                trailing: DropdownButton<String>(
                  value: _moneda,
                  items: const ['€', '\$', '£', '¥'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        _moneda = valor;
                      });
                    }
                  },
                ),
              ),
            ),
            const Divider(),

            // Sección Ayuda
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Ayuda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: const ListTile(
                title: Text('Version de la aplicacion'),
                subtitle: Text('v1.0.0'),
                trailing: Icon(Icons.info_outline),
              ),
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: ListTile(
                title: const Text('Limpiar historial'),
                subtitle: const Text('Eliminar todos los gastos guardados'),
                trailing: const Icon(Icons.delete_outline, color: Colors.red),
                onTap: () {
                  _mostrarDialogoConfirmacion();
                },
              ),
            ),
            const SizedBox(height: 20),

            // Botón Guardar
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Ajustes guardados'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoConfirmacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Limpiar historial?'),
        content: const Text(
          'Esta acción no se puede deshacer. Se eliminarán todos los gastos guardados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Historial eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Limpiar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
