import 'package:flutter/material.dart';
import '../modelos/historial.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({Key? key}) : super(key: key);

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ServicioHistorial _historial;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirPantallaHistorial(),
          _construirPantallaFavoritos(),
        ],
      ),
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
        final gasto = gastos[gastos.length - 1 - index]; // Orden inverso

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(gasto.restaurante),
            subtitle: Text(
              '${gasto.fecha.day}/${gasto.fecha.month}/${gasto.fecha.year} · ${gasto.totalGasto.toStringAsFixed(2)}€',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productos:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...gasto.productos.map((p) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.nombre),
                            Text('${p.precioTotal.toStringAsFixed(2)}€'),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Participantes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...gasto.participantes.map((p) {
                      final deuda = gasto.deudas[p.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.nombre),
                            Text('${deuda.toStringAsFixed(2)}€'),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
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
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final restaurante = favoritos[index];
        final gastado = estadisticas[restaurante] ?? 0;
        final gastosDelRestaurante = _historial
            .obtenerGastos()
            .where((g) => g.restaurante == restaurante)
            .length;

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
              '${gastosDelRestaurante} gasto${gastosDelRestaurante > 1 ? 's' : ''} · Total: ${gastado.toStringAsFixed(2)}€',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  _historial.eliminarFavorito(restaurante);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Eliminado de favoritos'),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
