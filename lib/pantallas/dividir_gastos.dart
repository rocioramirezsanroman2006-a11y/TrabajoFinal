import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import '../modelos/producto.dart';
import 'resumen_gasto.dart';

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
    _inicializarProductos();
    widget.gasto.calcularDeudas();
  }

  void _inicializarProductos() {
    // CORRECCIÓN: Ahora inicializamos el MAPA, no la lista.
    if (_modoSeleccionado == ModoGasto.equitativo) {
      for (var producto in widget.gasto.productos) {
        if (producto.asignacionesProporcionales.isEmpty) {
          for (var p in widget.gasto.participantes) {
            // Asignamos 1.0 por defecto a cada uno en modo equitativo
            producto.asignacionesProporcionales[p.id] = 1.0;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dividir Gastos'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.gasto.restaurante,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Participantes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _construirParticipantes(),
                  const SizedBox(height: 28),

                  const Text(
                    'Platos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _construirPlatos(),
                  const SizedBox(height: 28),

                  const Text(
                    'Opciones de División',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _construirSelectorModo(),
                  const SizedBox(height: 16),

                  if (_modoSeleccionado == ModoGasto.proporcional) ...[
                    const Divider(height: 28),
                    const Text(
                      'Reparto de cantidades por plato',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Indica cuánto consumió cada persona de cada plato.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _construirListaProductosAsignable(),
                  ],

                  const Divider(height: 28),
                  _construirResumenDeudas(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _irAResumen(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Dividir',
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
    );
  }

  Widget _construirParticipantes() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.gasto.participantes.asMap().entries.map((e) {
        final index = e.key;
        final participante = e.value;
        return CircleAvatar(
          radius: 32,
          backgroundColor: _getColorForIndex(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                participante.nombre[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 2),
              Text(
                participante.nombre.length > 5 ? '${participante.nombre.substring(0, 4)}.' : participante.nombre,
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _construirPlatos() {
    return Column(
      children: widget.gasto.productos.map((producto) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${producto.cantidad}x ${(producto.precio).toStringAsFixed(2)}€',
                style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _construirSelectorModo() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ModoGasto>(
        segments: const [
          ButtonSegment(value: ModoGasto.equitativo, label: Text('Equitativo'), icon: Icon(Icons.balance)),
          ButtonSegment(value: ModoGasto.proporcional, label: Text('Proporcional'), icon: Icon(Icons.pie_chart)),
        ],
        selected: {_modoSeleccionado},
        onSelectionChanged: (newSelection) {
          setState(() {
            _modoSeleccionado = newSelection.first;

            // CORRECCIÓN: Al cambiar a equitativo, reiniciamos el mapa
            if (_modoSeleccionado == ModoGasto.equitativo) {
              for (var producto in widget.gasto.productos) {
                producto.asignacionesProporcionales.clear();
                for (var p in widget.gasto.participantes) {
                  producto.asignacionesProporcionales[p.id] = 1.0;
                }
              }
            } else {
              for (var producto in widget.gasto.productos) {
                producto.normalizarAsignacionesAlMaximo();
              }
            }

            widget.gasto.modo = _modoSeleccionado;
            widget.gasto.calcularDeudas();
          });
        },
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
        return _TarjetaProductoProporcional(
          producto: producto,
          participantes: widget.gasto.participantes,
          onCambio: () => setState(() => widget.gasto.calcularDeudas()),
        );
      },
    );
  }

  Widget _construirResumenDeudas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${widget.gasto.totalGasto.toStringAsFixed(2)}€',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.gasto.participantes.map((p) {
          final deuda = widget.gasto.deudas[p.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.nombre),
                Text('${deuda.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  void _irAResumen(BuildContext context) {
    widget.gasto.calcularDeudas();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaResumenGasto(
          gasto: widget.gasto,
          onVolver: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, Colors.teal];
    return colors[index % colors.length];
  }
}

class _TarjetaProductoProporcional extends StatelessWidget {
  final Producto producto;
  final List<dynamic> participantes;
  final VoidCallback onCambio;

  const _TarjetaProductoProporcional({
    required this.producto,
    required this.participantes,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    final restanteTotal = (producto.cantidad - producto.totalAsignado).clamp(0, producto.cantidad.toDouble());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Total Comprado: ${producto.cantidad}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Asignado: ${producto.totalAsignado.toStringAsFixed(1)} / ${producto.cantidad.toDouble().toStringAsFixed(1)} · Restante: ${restanteTotal.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(),
          ...participantes.map((p) {
            double valorActual = producto.asignacionesProporcionales[p.id] ?? 0.0;
            final maximo = producto.maximoAsignablePara(p.id);
            final puedeSumar = valorActual + 0.5 <= maximo + 0.0001;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(p.nombre)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: valorActual > 0
                        ? () {
                            producto.actualizarAsignacion(p.id, valorActual - 0.5);
                            onCambio();
                          }
                        : null,
                  ),
                  Container(
                    width: 45,
                    alignment: Alignment.center,
                    child: Text(
                      valorActual.toString().replaceAll('.0', ''),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    onPressed: puedeSumar
                        ? () {
                            producto.actualizarAsignacion(p.id, valorActual + 0.5);
                            onCambio();
                          }
                        : null,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}