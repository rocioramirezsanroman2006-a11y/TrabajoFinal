import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../modelos/gasto.dart';
import '../modelos/historial.dart';
import '../servicios/division.dart' show ServicioDivision, Pago;

class PantallaResumen extends StatefulWidget {
  final Gasto gasto;
  final Function() onGastoFinalizado;
  // 1. Añadimos este parámetro para saber si solo estamos consultando
  final bool esSoloLectura;

  const PantallaResumen({
    Key? key,
    required this.gasto,
    required this.onGastoFinalizado,
    this.esSoloLectura = false, // Por defecto es falso para que el flujo normal no cambie
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
        // Solo mostramos el snackbar si no es solo lectura
        if (!widget.esSoloLectura) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El gasto no se ha guardado')),
          );
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.esSoloLectura ? 'Detalle del Gasto' : 'Resumen'),
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
              // ... (Mantenemos la tarjeta de restaurante y total igual)
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
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.gasto.totalGasto.toStringAsFixed(2)}€',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dividido entre ${widget.gasto.participantes.length} personas',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ... (Mantenemos Deudas y Pagos Sugeridos igual)
              const Text('Deudas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      trailing: Text('${deuda.toStringAsFixed(2)}€', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Pagos sugeridos
              const Text('Pagos Sugeridos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pagos.isEmpty
                      ? [const Text('Los gastos están equilibrados ✓', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))]
                      : pagos.map((pago) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${pago.de} → ${pago.a}', style: const TextStyle(fontWeight: FontWeight.w500))),
                        Text('${pago.cantidad.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Opciones de compartir (Mantenemos igual)
              const Text('Compartir Resumen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => _compartirPorBizum(mapeoIdNombre, pagos), icon: const Icon(Icons.payment), label: const Text('Bizum'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: () => _compartirPorWhatsApp(mapeoIdNombre, pagos), icon: const Icon(Icons.chat), label: const Text('WhatsApp'))),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _compartirGeneral(mapeoIdNombre, pagos), icon: const Icon(Icons.share), label: const Text('Compartir'))),
              const SizedBox(height: 24),

              // 2. MODIFICACIÓN DEL BOTÓN FINALIZAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finalizarGasto,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: widget.esSoloLectura ? Colors.blue.shade600 : Colors.green.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.esSoloLectura ? Icons.arrow_back : Icons.check_circle, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        widget.esSoloLectura ? 'Volver al Historial' : 'Guardar y Finalizar',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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

  // ... (Funciones de compartir y favoritos se mantienen igual)

  void _finalizarGasto() {
    // 3. SOLO GUARDAMOS SI NO ES SOLO LECTURA
    if (!widget.esSoloLectura) {
      _historial.agregarGasto(widget.gasto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Gasto guardado exitosamente!'), duration: Duration(seconds: 2)),
      );

      Future.delayed(const Duration(seconds: 2), () {
        widget.onGastoFinalizado();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      });
    } else {
      // Si es solo lectura, simplemente cerramos la pantalla
      Navigator.of(context).pop();
    }
  }

  // (El resto de métodos se mantienen idénticos...)
  void _alternarFavorito() { /*...*/ }
  void _compartirPorBizum(Map<String, String> mapeoIdNombre, List<Pago> pagos) { /*...*/ }
  void _compartirPorWhatsApp(Map<String, String> mapeoIdNombre, List<Pago> pagos) { /*...*/ }
  void _compartirGeneral(Map<String, String> mapeoIdNombre, List<Pago> pagos) { /*...*/ }
  String _generarTextoResumen(Map<String, String> mapeoIdNombre, List<Pago> pagos, String metodo) {
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
}