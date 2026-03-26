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
    // Nos aseguramos que las deudas estén calculadas antes de guardar
    widget.gasto.calcularDeudas();
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
              Text(
                widget.gasto.restaurante,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Ticket: ${widget.gasto.totalGasto.toStringAsFixed(2)}€',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Desglose por participante',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ...widget.gasto.participantes.map((participante) {
                final productos = productosPorParticipante[participante.id] ?? [];
                // CORRECCIÓN: Usamos la deuda ya calculada en el modelo Gasto
                final totalDeudaParticipante = widget.gasto.deudas[participante.id] ?? 0.0;

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
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  participante.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  'Debe pagar: ${totalDeudaParticipante.toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
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
                        const Text(
                          'Detalle de consumo:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...productos.map((producto) {
                          // CORRECCIÓN: Cálculo proporcional para el desglose visual
                          double precioItem;
                          if (widget.gasto.modo == ModoGasto.proporcional) {
                            double racionesP = producto.asignacionesProporcionales[participante.id] ?? 0;
                            double totalR = producto.totalAsignado;
                            precioItem = totalR > 0 ? (racionesP / totalR) * producto.precioTotal : 0;
                          } else {
                            precioItem = producto.precioTotal / producto.participantesSeleccionados.length;
                          }

                          if (precioItem <= 0) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '• ${producto.nombre} ${widget.gasto.modo == ModoGasto.proporcional ? "(${producto.asignacionesProporcionales[participante.id]?.toString().replaceAll(".0", "")} ración/es)" : ""}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '${precioItem.toStringAsFixed(2)}€',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _compartirPorWhatsApp(),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir por WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Gasto guardado correctamente'), backgroundColor: Colors.green),
                    );
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Finalizar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final productosPorParticipante = widget.gasto.obtenerProductosPorParticipante();

    String mensaje = '🍽️ *${widget.gasto.restaurante}*\n';
    mensaje += '💰 *Total Ticket: ${widget.gasto.totalGasto.toStringAsFixed(2)}€*\n\n';
    mensaje += '━━━━━━━━━━━━━━━━━\n\n';

    for (var participante in widget.gasto.participantes) {
      final totalP = widget.gasto.deudas[participante.id] ?? 0.0;
      if (totalP <= 0) continue;

      mensaje += '👤 *${participante.nombre.toUpperCase()}*\n';
      mensaje += '👉 *Debe pagar: ${totalP.toStringAsFixed(2)}€*\n';

      final productos = productosPorParticipante[participante.id] ?? [];
      for (var producto in productos) {
        double precioItem;
        String detalle = "";

        if (widget.gasto.modo == ModoGasto.proporcional) {
          double raciones = producto.asignacionesProporcionales[participante.id] ?? 0;
          double totalR = producto.totalAsignado;
          precioItem = totalR > 0 ? (raciones / totalR) * producto.precioTotal : 0;
          detalle = " (${raciones.toString().replaceAll(".0", "")} ración/es)";
        } else {
          precioItem = producto.precioTotal / producto.participantesSeleccionados.length;
        }

        if (precioItem > 0) {
          mensaje += '  • ${producto.nombre}$detalle: ${precioItem.toStringAsFixed(2)}€\n';
        }
      }
      mensaje += '\n';
    }

    mensaje += '━━━━━━━━━━━━━━━━━\n';
    mensaje += '_Generado con App de Gastos_';

    await Share.share(mensaje);
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, Colors.pink, Colors.teal, Colors.indigo];
    return colors[index % colors.length];
  }
}