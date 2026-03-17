import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../modelos/gasto.dart';
import '../modelos/historial.dart';
import '../servicios/division.dart' show ServicioDivision, Pago;

class PantallaResumen extends StatefulWidget {
  final Gasto gasto;
  final Function() onGastoFinalizado;

  const PantallaResumen({
    Key? key,
    required this.gasto,
    required this.onGastoFinalizado,
  }) : super(key: key);

  @override
  State<PantallaResumen> createState() => _PantallaResumenState();
}

class _PantallaResumenState extends State<PantallaResumen> {
  late ServicioDivision _servicioDivision;
  late ServicioHistorial _historial;
  late bool _esFavorito;

  @override
  void initState() {
    super.initState();
    _servicioDivision = ServicioDivision();
    _historial = ServicioHistorial();
    _esFavorito = _historial.esFavorito(widget.gasto.restaurante);
  }

  @override
  Widget build(BuildContext context) {
    widget.gasto.calcularDeudas();
    
    final mapeoIdNombre = <String, String>{
      for (var p in widget.gasto.participantes) p.id: p.nombre,
    };

    final pagos = _servicioDivision.calcularPagos(
      widget.gasto.deudas,
      mapeoIdNombre,
    );

    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El gasto no se ha guardado')),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resumen'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_esFavorito ? Icons.favorite : Icons.favorite_border),
              color: _esFavorito ? Colors.red : null,
              onPressed: _alternarFavorito,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de restaurante y total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.gasto.restaurante,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.gasto.totalGasto.toStringAsFixed(2)}€',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dividido entre ${widget.gasto.participantes.length} personas',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Deudas por persona
              const Text(
                'Deudas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.gasto.participantes.length,
                itemBuilder: (context, index) {
                  final participante = widget.gasto.participantes[index];
                  final deuda = widget.gasto.deudas[participante.id] ?? 0;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(participante.nombre),
                      trailing: Text(
                        '${deuda.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Pagos sugeridos
              const Text(
                'Pagos Sugeridos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pagos.isEmpty
                      ? [
                          const Text(
                            'Los gastos están equilibrados ✓',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ]
                      : pagos.map((pago) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${pago.de} → ${pago.a}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${pago.cantidad.toStringAsFixed(2)}€',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Opciones de compartir
              const Text(
                'Compartir Resumen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _compartirPorBizum(mapeoIdNombre, pagos),
                      icon: const Icon(Icons.payment),
                      label: const Text('Bizum'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _compartirPorWhatsApp(mapeoIdNombre, pagos),
                      icon: const Icon(Icons.chat),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _compartirGeneral(mapeoIdNombre, pagos),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                ),
              ),
              const SizedBox(height: 24),

              // Botón finalizar MUY DESTACADO
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finalizarGasto,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Guardar y Finalizar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _alternarFavorito() {
    setState(() {
      if (_esFavorito) {
        _historial.eliminarFavorito(widget.gasto.restaurante);
      } else {
        _historial.agregarFavorito(widget.gasto.restaurante);
      }
      _esFavorito = !_esFavorito;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _esFavorito
              ? '${widget.gasto.restaurante} agregado a favoritos'
              : 'Eliminado de favoritos',
        ),
      ),
    );
  }

  void _compartirPorBizum(Map<String, String> mapeoIdNombre, List<Pago> pagos) {
    final texto = _generarTextoResumen(mapeoIdNombre, pagos, 'Bizum');
    Share.share(texto);
  }

  void _compartirPorWhatsApp(Map<String, String> mapeoIdNombre, List<Pago> pagos) {
    final texto = _generarTextoResumen(mapeoIdNombre, pagos, 'WhatsApp');
    Share.share(texto);
  }

  void _compartirGeneral(Map<String, String> mapeoIdNombre, List<Pago> pagos) {
    final texto = _generarTextoResumen(mapeoIdNombre, pagos, 'General');
    Share.share(texto);
  }

  String _generarTextoResumen(
    Map<String, String> mapeoIdNombre,
    List<Pago> pagos,
    String metodo,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('📊 RESUMEN DEL GASTO');
    buffer.writeln('${widget.gasto.restaurante}');
    buffer.writeln('═════════════════════════════════');
    buffer.writeln('Total: ${widget.gasto.totalGasto.toStringAsFixed(2)}€');
    buffer.writeln('Fecha: ${widget.gasto.fecha.day}/${widget.gasto.fecha.month}/${widget.gasto.fecha.year}');
    buffer.writeln('');
    buffer.writeln('💳 DEUDAS:');
    for (var entry in widget.gasto.deudas.entries) {
      final nombre = mapeoIdNombre[entry.key] ?? 'Desconocido';
      buffer.writeln('  • $nombre: ${entry.value.toStringAsFixed(2)}€');
    }
    buffer.writeln('');
    buffer.writeln('💰 PAGOS SUGERIDOS:');
    if (pagos.isEmpty) {
      buffer.writeln('  • Todos pagaron lo mismo ✓');
    } else {
      for (var pago in pagos) {
        buffer.writeln('  • ${pago.de} → ${pago.a}: ${pago.cantidad.toStringAsFixed(2)}€');
      }
    }
    return buffer.toString();
  }

  void _finalizarGasto() {
    _historial.agregarGasto(widget.gasto);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Gasto guardado exitosamente!'),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      widget.onGastoFinalizado();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }
}
