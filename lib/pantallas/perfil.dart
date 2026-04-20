import 'package:flutter/material.dart';
import '../modelos/historial.dart';
import '../servicios/autenticacion.dart';

class PantallaPerfil extends StatefulWidget {
  final VoidCallback? onCerrarSesion;

  const PantallaPerfil({
    Key? key,
    this.onCerrarSesion,
  }) : super(key: key);

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  late ServicioHistorial _historial;
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  bool _enEdicion = false;
  CriterioRankingValoracion _criterioRanking = CriterioRankingValoracion.media;

  @override
  void initState() {
    super.initState();
    _historial = ServicioHistorial();
    final usuario = ServicioAutenticacion().usuarioActual;
    _nombreController = TextEditingController(text: usuario?.nombre ?? 'Usuario');
    _emailController = TextEditingController(text: usuario?.email ?? 'usuario@ejemplo.com');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gastoTotal = _historial.obtenerGastoTotal();
    final gastoSemanal = _historial.obtenerGastoSemanalTotal();
    final topPuntuados = _historial.obtenerTopRestaurantesPorPuntuacion(
      limite: 5,
      criterio: _criterioRanking,
    );
    final topGastados = _historial.obtenerTopRestaurantesPorGasto(limite: 3);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_enEdicion ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _enEdicion = !_enEdicion;
              });
              if (!_enEdicion) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Perfil actualizado'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del perfil - Editable
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: Colors.purple[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_enEdicion)
                    TextField(
                      controller: _nombreController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tu nombre',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    )
                  else
                    Text(
                      _nombreController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (_enEdicion)
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tu email',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    )
                  else
                    Text(
                      _emailController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Estadísticas
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Tarjetas de estadísticas
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Esta semana',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${gastoSemanal.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${gastoTotal.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Restaurantes favoritos por puntuacion
            Text(
              'Restaurantes favoritos por ${_etiquetaCriterio(_criterioRanking)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CriterioRankingValoracion.values.map((criterio) {
                return ChoiceChip(
                  label: Text(_etiquetaCriterio(criterio)),
                  selected: _criterioRanking == criterio,
                  onSelected: (_) {
                    setState(() {
                      _criterioRanking = criterio;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Ranking actual: ${_etiquetaCriterio(_criterioRanking)}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (topPuntuados.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                       Text(
                         'Aun no tienes valoraciones para este ranking. Finaliza un ticket para empezar.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                  itemCount: topPuntuados.length,
                itemBuilder: (context, index) {
                    final item = topPuntuados[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: Colors.amber.shade600,
                        ),
                      ),
                       title: Text(item.nombre),
                       trailing: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.amber.shade50,
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                           item.puntuacionMedia.toStringAsFixed(1),
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             color: Colors.amber.shade800,
                           ),
                         ),
                       ),
                       subtitle: Row(
                         children: [
                           _EstrellasValoracion(valor: item.puntuacionMedia, tamano: 14),
                           const SizedBox(width: 6),
                           Text(
                             '(${item.valoraciones} valoraciones)',
                             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                           ),
                         ],
                       ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            const Text(
              'Top 3 donde mas has gastado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (topGastados.isEmpty)
              Text(
                'Aun no hay datos de gasto. Crea y finaliza tickets para ver este top 3.',
                style: TextStyle(color: Colors.grey[600]),
              )
            else
              ...topGastados.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item.restaurante),
                    subtitle: Text('${item.visitas} visita${item.visitas == 1 ? '' : 's'}'),
                    trailing: Text(
                      '${item.gastoTotal.toStringAsFixed(2)}€',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            if (widget.onCerrarSesion != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    widget.onCerrarSesion!();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesion'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                    side: BorderSide(color: Colors.red.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _etiquetaCriterio(CriterioRankingValoracion criterio) {
    switch (criterio) {
      case CriterioRankingValoracion.media:
        return 'Media';
      case CriterioRankingValoracion.precio:
        return 'Precio';
      case CriterioRankingValoracion.comida:
        return 'Comida';
      case CriterioRankingValoracion.local:
        return 'Local';
    }
  }
}

class _EstrellasValoracion extends StatelessWidget {
  final double valor;
  final double tamano;

  const _EstrellasValoracion({
    required this.valor,
    this.tamano = 16,
  });

  @override
  Widget build(BuildContext context) {
    final estrellasLlenas = valor.round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < estrellasLlenas ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: tamano,
        );
      }),
    );
  }
}
