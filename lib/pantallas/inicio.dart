import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../modelos/historial.dart';
import '../modelos/gasto.dart';
import 'ajustes.dart';
import 'resumen.dart';

class PantallaInicio extends StatefulWidget {
  final Function(Gasto)? onNuevoGasto;

  const PantallaInicio({
    Key? key,
    this.onNuevoGasto,
  }) : super(key: key);

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late ServicioHistorial _historial;

  @override
  void initState() {
    super.initState();
    _historial = ServicioHistorial();
  }

  // Método para refrescar la pantalla cuando volvemos de ver un detalle
  void _refrescar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gastoSemanal = _historial.obtenerGastoSemanalTotal();
    final gastosRecientes = _historial.obtenerGastos().take(4).toList();

    // Simulación de datos de gasto semanal para el gráfico
    final List<double> datosGastoSemana = _historial.obtenerGastoPorDiaSemana();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PantallaAjustes(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta de gasto semanal con gráfico
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gasto esta semana',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${gastoSemanal.toStringAsFixed(2)}\u20ac',
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                datosGastoSemana.length,
                                (i) => FlSpot(i.toDouble(), datosGastoSemana[i]),
                              ),
                              isCurved: true,
                              color: Colors.white,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${gastosRecientes.length} pagos registrados',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Actividad Reciente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (gastosRecientes.isEmpty)
                const Center(child: Text('No hay gastos registrados'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gastosRecientes.length,
                  itemBuilder: (context, index) {
                    final gasto = gastosRecientes[index];
                    return _TarjetaGasto(
                      gasto: gasto,
                      onTap: () {
                        // NAVEGACIÓN CORREGIDA:
                        // Usamos esSoloLectura: true para que no se duplique al abrir
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PantallaResumen(
                              gasto: gasto,
                              onGastoFinalizado: _refrescar,
                              esSoloLectura: true,
                            ),
                          ),
                        ).then((_) => setState(() {})); // Refrescar al volver
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaGasto extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback onTap; // Añadimos el callback para el click

  const _TarjetaGasto({
    Key? key,
    required this.gasto,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fecha = gasto.fecha;
    final fechaFormato = '${fecha.day}/${fecha.month}/${fecha.year}';
    final hora = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // Conectamos el click
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orange.shade200, Colors.orange.shade400]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gasto.restaurante, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('$fechaFormato a las $hora', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${gasto.totalGasto.toStringAsFixed(2)}€',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                  ),
                  Text('${gasto.productos.length} ítems', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}