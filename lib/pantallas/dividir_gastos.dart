import 'package:flutter/material.dart';
import '../modelos/gasto.dart';
import '../modelos/producto.dart';
import '../modelos/historial.dart';
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
    widget.gasto.calcularDeudas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dividir Gastos'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Contenido scrolleable
          Expanded(
            child: SingleChildScrollView(
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sección Participantes
                  const Text(
                    'Participantes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _construirParticipantes(),
                  const SizedBox(height: 28),

                  // Sección Platos
                  const Text(
                    'Platos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _construirPlatos(),
                  const SizedBox(height: 28),

                  // Sección Opciones
                  const Text(
                    'Opciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _construirSelectorModo(),
                  const SizedBox(height: 16),

                  // Área de asignación (si es proporcional)
                  if (_modoSeleccionado == ModoGasto.proporcional) ...[
                    const Divider(height: 28),
                    const Text(
                      'Asignar Productos a Participantes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _construirListaProductosAsignable(),
                    const SizedBox(height: 16),
                  ],

                  // Resumen de deudas
                  const Divider(height: 28),
                  _construirResumenDeudas(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Botón Dividir pegado al fondo
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            color: Colors.white,
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                participante.nombre.substring(0, participante.nombre.length > 4 ? 3 : participante.nombre.length),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
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
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${producto.precio.toStringAsFixed(2)}€',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (_modoSeleccionado == ModoGasto.proporcional)
                Wrap(
                  spacing: 4,
                  children: widget.gasto.participantes.map((p) {
                    final seleccionado = producto.participantesSeleccionados.contains(p.id);
                    return Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: seleccionado ? Colors.blue.shade400 : Colors.grey[300],
                      ),
                      child: seleccionado
                          ? const Center(
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _construirSelectorModo() {
    return Row(
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
                widget.gasto.calcularDeudas();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _construirResumenDeudas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total: ${widget.gasto.totalGasto.toStringAsFixed(2)}€',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.gasto.participantes.map((p) {
          final deuda = widget.gasto.deudas[p.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  p.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${deuda.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaResumenGasto(
          gasto: widget.gasto,
          onVolver: () {
            // Retroceder a dividir_gastos
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _guardarGasto(BuildContext context) {
    widget.gasto.modo = _modoSeleccionado;
    widget.gasto.calcularDeudas();
    
    final historial = ServicioHistorial();
    historial.agregarGasto(widget.gasto);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Gasto dividido y guardado'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      widget.onGastoFinalizado();
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.producto.precio.toStringAsFixed(2)}€',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Quién lo consumió:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.participantes.map((participante) {
              final seleccionado = widget.producto.participantesSeleccionados
                  .contains(participante.id);
              return FilterChip(
                label: Text(participante.nombre),
                selected: seleccionado,
                backgroundColor: Colors.grey[200],
                selectedColor: Colors.blue.shade400,
                labelStyle: TextStyle(
                  color: seleccionado ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
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
    );
  }
}
