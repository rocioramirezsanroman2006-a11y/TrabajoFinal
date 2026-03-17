import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import '../modelos/producto.dart';
import '../modelos/historial.dart';

class PantallaDividirGastos extends StatefulWidget {
  final Gasto gasto;
  final Function() onGastoFinalizado;

  const PantallaDividirGastos({
    Key? key,
    required this.gasto,
    required this.onGastoFinalizado,
  }) : super(key: key);

  @override
  State<PantallaDividirGastos> createState() => _PantallaDividirGastosState();
}

class _PantallaDividirGastosState extends State<PantallaDividirGastos> {
  late ModoGasto _modoSeleccionado;

  @override
  void initState() {
    super.initState();
    _modoSeleccionado = widget.gasto.modo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dividir Gastos'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de modo
            const Text(
              'Modo de División',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<ModoGasto>(
                    segments: const <ButtonSegment<ModoGasto>>[
                      ButtonSegment<ModoGasto>(
                        value: ModoGasto.equitativo,
                        label: Text('Equitativo'),
                      ),
                      ButtonSegment<ModoGasto>(
                        value: ModoGasto.proporcional,
                        label: Text('Proporcional'),
                      ),
                    ],
                    selected: <ModoGasto>{_modoSeleccionado},
                    onSelectionChanged: (Set<ModoGasto> newSelection) {
                      setState(() {
                        _modoSeleccionado = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Área de asignación (si es proporcional)
            if (_modoSeleccionado == ModoGasto.proporcional) ...[
              const Text(
                'Asignar Productos a Participantes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _construirListaProductosAsignable(),
              const SizedBox(height: 24),
            ],

            // Resumen
            const Text(
              'Resumen Actual',
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: ${widget.gasto.totalGasto.toStringAsFixed(2)}€',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...widget.gasto.participantes.map((p) {
                    final deuda = widget.gasto.deudas[p.id] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.nombre),
                          Text(
                            '${deuda.toStringAsFixed(2)}€',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _guardarGasto(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Guardar Gasto',
                      style: TextStyle(
                        fontSize: 16,
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
    );
  }

  Widget _construirListaProductosAsignable() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.gasto.productos.length,
      itemBuilder: (context, index) {
        final producto = widget.gasto.productos[index];
        return _TarjetaProductoAsignable(
          producto: producto,
          participantes: widget.gasto.participantes,
          onSeleccionCambiada: () {
            setState(() {
              widget.gasto.calcularDeudas();
            });
          },
        );
      },
    );
  }

  void _irAResumen(BuildContext context) {
    widget.gasto.modo = _modoSeleccionado;
    widget.gasto.calcularDeudas();
    
    final historial = ServicioHistorial();
    historial.agregarGasto(widget.gasto);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Gasto guardado exitosamente'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      widget.onGastoFinalizado();
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  void _guardarGasto(BuildContext context) {
    widget.gasto.modo = _modoSeleccionado;
    widget.gasto.calcularDeudas();
    
    final historial = ServicioHistorial();
    historial.agregarGasto(widget.gasto);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Gasto guardado exitosamente'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      widget.onGastoFinalizado();
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
}

class _TarjetaProductoAsignable extends StatefulWidget {
  final Producto producto;
  final List<dynamic> participantes;
  final Function() onSeleccionCambiada;

  const _TarjetaProductoAsignable({
    Key? key,
    required this.producto,
    required this.participantes,
    required this.onSeleccionCambiada,
  }) : super(key: key);

  @override
  State<_TarjetaProductoAsignable> createState() =>
      _TarjetaProductoAsignableState();
}

class _TarjetaProductoAsignableState extends State<_TarjetaProductoAsignable> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.producto.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.producto.precio.toStringAsFixed(2)}€',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Quién lo consumió:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.participantes.map((participante) {
                final seleccionado =
                    widget.producto.participantesSeleccionados.contains(participante.id);
                return FilterChip(
                  label: Text(participante.nombre),
                  selected: seleccionado,
                  onSelected: (valor) {
                    setState(() {
                      if (valor) {
                        widget.producto.participantesSeleccionados
                            .add(participante.id);
                      } else {
                        widget.producto.participantesSeleccionados
                            .remove(participante.id);
                      }
                      widget.onSeleccionCambiada();
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
