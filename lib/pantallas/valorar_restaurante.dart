import 'package:flutter/material.dart';
import '../modelos/gasto.dart';

class PantallaValorarRestaurante extends StatefulWidget {
  final String nombreRestaurante;
  final ValoracionRestaurante? valoracionInicial;
  final String textoBoton;

  const PantallaValorarRestaurante({
    super.key,
    required this.nombreRestaurante,
    this.valoracionInicial,
    this.textoBoton = 'Guardar valoracion',
  });

  @override
  State<PantallaValorarRestaurante> createState() => _PantallaValorarRestauranteState();
}

class _PantallaValorarRestauranteState extends State<PantallaValorarRestaurante> {
  late int _precio;
  late int _comida;
  late int _local;

  @override
  void initState() {
    super.initState();
    _precio = widget.valoracionInicial?.precio ?? 0;
    _comida = widget.valoracionInicial?.comida ?? 0;
    _local = widget.valoracionInicial?.local ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valorar establecimiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nombreRestaurante,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Puntua de 0 a 5 estrellas',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            _FilaValoracion(
              titulo: 'Precio',
              valor: _precio,
              onChanged: (nuevo) => setState(() => _precio = nuevo),
            ),
            const SizedBox(height: 18),
            _FilaValoracion(
              titulo: 'Comida',
              valor: _comida,
              onChanged: (nuevo) => setState(() => _comida = nuevo),
            ),
            const SizedBox(height: 18),
            _FilaValoracion(
              titulo: 'Local',
              valor: _local,
              onChanged: (nuevo) => setState(() => _local = nuevo),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    ValoracionRestaurante(
                      precio: _precio,
                      comida: _comida,
                      local: _local,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(widget.textoBoton),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaValoracion extends StatelessWidget {
  final String titulo;
  final int valor;
  final ValueChanged<int> onChanged;

  const _FilaValoracion({
    required this.titulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final estrella = index + 1;
          return IconButton(
            onPressed: () => onChanged(estrella),
            icon: Icon(
              estrella <= valor ? Icons.star : Icons.star_border,
              color: Colors.amber,
            ),
          );
        }),
      ],
    );
  }
}


