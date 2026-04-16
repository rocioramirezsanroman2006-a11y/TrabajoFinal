import 'package:flutter/material.dart';
import '../modelos/historial.dart';
import 'resumen_gasto.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({Key? key}) : super(key: key);

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> with TickerProviderStateMixin {
  late TabController _tabController;
  late ServicioHistorial _historial;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _historial = ServicioHistorial();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoy'),
            Tab(text: 'Favoritos'),
            Tab(text: 'Tendencias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirPantallaHistorial(),
          _construirPantallaFavoritos(),
          _construirPantallaTendencias(),
        ],
      ),
    );
  }

  Widget _construirPantallaTendencias() {
    final gastos = _historial.obtenerGastos();
    final semanal = _historial.obtenerEvolucionSemanal();
    final mensual = _historial.obtenerEvolucionMensual();
    final restaurantes = _historial.obtenerRestaurantesFrecuentes(limite: 5);
    final gastoMedio = _historial.obtenerGastoMedioPorVisita();
    final productoTop = _historial.obtenerProductoMasConsumido();

    if (gastos.isEmpty) {
      return Center(
        child: Text(
          'Escanea tickets para ver tus tendencias',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TarjetaEvolucion(
          titulo: 'Evolucion semanal',
          datos: semanal,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _TarjetaEvolucion(
          titulo: 'Evolucion mensual',
          datos: mensual,
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Restaurantes favoritos por visitas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (restaurantes.isEmpty)
                  const Text('Sin datos todavia')
                else
                  ...restaurantes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(item.restaurante),
                      subtitle: Text('${item.visitas} visita${item.visitas > 1 ? 's' : ''}'),
                      trailing: Text('${item.gastoTotal.toStringAsFixed(2)}€'),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estadisticas de consumo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ItemEstadistica(
                        titulo: 'Gasto medio',
                        valor: '${gastoMedio.toStringAsFixed(2)}€',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ItemEstadistica(
                        titulo: 'Producto top',
                        valor: productoTop == null ? 'N/D' : '${productoTop.nombre} (${productoTop.unidades})',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _historial.obtenerTicketsNubeUsuarioActual(),
                  builder: (context, snapshot) {
                    final totalNube = snapshot.data?.length ?? 0;
                    return Text(
                      'Tickets sincronizados en nube: $totalNube',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirPantallaHistorial() {
    final gastos = _historial.obtenerGastos();

    if (gastos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay historial',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: gastos.length,
      itemBuilder: (context, index) {
        final gasto = gastos[gastos.length - 1 - index];
        final esFavorito = _historial.obtenerFavoritos().contains(gasto.restaurante);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gasto.restaurante,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${gasto.fecha.day}/${gasto.fecha.month}/${gasto.fecha.year}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${gasto.totalGasto.toStringAsFixed(2)}€',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PantallaResumenGasto(
                              gasto: gasto,
                              esSoloLectura: true,
                              onVolver: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Ver'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _historial.eliminarGasto(gasto.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gasto eliminado'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        if (esFavorito) {
                          _historial.eliminarFavorito(gasto.restaurante);
                        } else {
                          _historial.agregarFavorito(gasto.restaurante);
                        }
                        setState(() {});
                      },
                      icon: Icon(esFavorito ? Icons.favorite : Icons.favorite_border),
                      label: Text(esFavorito ? '★' : '☆'),
                      style: TextButton.styleFrom(
                        foregroundColor: esFavorito ? Colors.red : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirPantallaFavoritos() {
    final favoritos = _historial.obtenerFavoritos();
    final estadisticas = _historial.obtenerEstadisticas();

    if (favoritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay favoritos',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final restaurante = favoritos[index];
        final gastado = estadisticas[restaurante] ?? 0;
        final gastosDelRestaurante = _historial.obtenerGastos().where((g) => g.restaurante == restaurante).length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.orange.shade600,
              ),
            ),
            title: Text(restaurante),
            subtitle: Text(
              '$gastosDelRestaurante gasto${gastosDelRestaurante > 1 ? 's' : ''} · Total: ${gastado.toStringAsFixed(2)}€',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  _historial.eliminarFavorito(restaurante);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Eliminado de favoritos')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaEvolucion extends StatelessWidget {
  final String titulo;
  final List<PuntoEvolucion> datos;
  final Color color;

  const _TarjetaEvolucion({
    required this.titulo,
    required this.datos,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final maximo = datos.fold<double>(0.0, (max, p) => p.total > max ? p.total : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...datos.map((p) {
              final progreso = maximo == 0 ? 0.0 : p.total / maximo;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(width: 86, child: Text(p.etiqueta, style: const TextStyle(fontSize: 12))),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progreso,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: color.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 72,
                      child: Text(
                        '${p.total.toStringAsFixed(2)}€',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ItemEstadistica extends StatelessWidget {
  final String titulo;
  final String valor;

  const _ItemEstadistica({
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 6),
          Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
