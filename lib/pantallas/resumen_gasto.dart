import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../modelos/gasto.dart';
import '../modelos/historial.dart';

class PantallaResumenGasto extends StatefulWidget {
  final Gasto gasto;
  final Function() onVolver;

  const PantallaResumenGasto({
    Key? key,
    required this.gasto,
    required this.onVolver,
  }) : super(key: key);

  @override
  State<PantallaResumenGasto> createState() => _PantallaResumenGastoState();
}

class _PantallaResumenGastoState extends State<PantallaResumenGasto> {
  @override
  void initState() {
    super.initState();
    // Guardar el gasto en el historial cuando se abre la pantalla de resumen
    final historial = ServicioHistorial();
    historial.agregarGasto(widget.gasto);
  }

  @override
  Widget build(BuildContext context) {
    final productosPorParticipante = widget.gasto.obtenerProductosPorParticipante();

    return WillPopScope(
      onWillPop: () async {
        widget.onVolver();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resumen'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurante
              Text(
                widget.gasto.restaurante,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${widget.gasto.totalGasto.toStringAsFixed(2)}€',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Qué consumió cada uno
              const Text(
                'Qué se comió',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...widget.gasto.participantes.map((participante) {
                final productos = productosPorParticipante[participante.id] ?? [];
                final totalParticipante = productos.fold<double>(
                  0,
                  (sum, p) => sum + (p.precioTotal / p.participantesSeleccionados.length),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _getColorForIndex(
                              widget.gasto.participantes.indexOf(participante),
                            ),
                            child: Text(
                              participante.nombre[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  participante.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Total: ${totalParticipante.toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    color: Colors.blue.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (productos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Consumió:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...productos.map((producto) {
                          final precioPersona = producto.precioTotal /
                              producto.participantesSeleccionados.length;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${producto.nombre}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '${precioPersona.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Botón Compartir WhatsApp
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _compartirPorWhatsApp(),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir por WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Botón Guardar e Ir al Historial
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // El gasto ya se guardó en initState
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Gasto guardado en historial'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Guardar Gasto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _compartirPorWhatsApp() async {
    final productosPorParticipante =
        widget.gasto.obtenerProductosPorParticipante();

    String mensaje = '🍽️ *${widget.gasto.restaurante}*\n\n';
    mensaje += '💰 *Total: ${widget.gasto.totalGasto.toStringAsFixed(2)}€*\n\n';
    mensaje += '━━━━━━━━━━━━━━━━━\n\n';

    for (var participante in widget.gasto.participantes) {
      final productos =
          productosPorParticipante[participante.id] ?? [];
      final totalParticipante = productos.fold<double>(
        0,
        (sum, p) => sum + (p.precioTotal / p.participantesSeleccionados.length),
      );

      mensaje += '👤 *${participante.nombre}*\n';
      mensaje += '_Total: ${totalParticipante.toStringAsFixed(2)}€_\n\n';

      for (var producto in productos) {
        final precioPersona = producto.precioTotal /
            producto.participantesSeleccionados.length;
        mensaje += '  • ${producto.nombre}: ${precioPersona.toStringAsFixed(2)}€\n';
      }
      mensaje += '\n';
    }

    mensaje += '━━━━━━━━━━━━━━━━━';

    await Share.share(
      mensaje,
      subject: '${widget.gasto.restaurante} - Resumen de gastos',
    );
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
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
