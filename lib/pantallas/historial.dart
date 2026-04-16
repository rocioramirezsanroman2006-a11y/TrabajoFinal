import 'package:flutter/material.dart';
import '../modelos/historial.dart';
import 'resumen_gasto.dart';

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
              // Header con info del gasto
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${gasto.fecha.day}/${gasto.fecha.month}/${gasto.fecha.year}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${gasto.totalGasto.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Botones de acción
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
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
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
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
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
                      icon: Icon(
                        esFavorito ? Icons.favorite : Icons.favorite_border,
                      ),
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
