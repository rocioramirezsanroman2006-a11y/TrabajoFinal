import 'package:flutter/material.dart';
import 'pantallas/inicio.dart';
import 'pantallas/editar_ticket.dart';
import 'pantallas/dividir_gastos.dart';
import 'pantallas/historial.dart';
import 'pantallas/perfil.dart';
import 'modelos/gasto.dart';

void main() {
  runApp(const AplicacionDividirGastos());
}

class AplicacionDividirGastos extends StatelessWidget {
  const AplicacionDividirGastos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dividir Gastos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PantallaNavegacionPrincipal(),
    );
  }
}

class PantallaNavegacionPrincipal extends StatefulWidget {
  const PantallaNavegacionPrincipal({Key? key}) : super(key: key);

  @override
  State<PantallaNavegacionPrincipal> createState() =>
      _PantallaNavegacionPrincipalState();
}

class _PantallaNavegacionPrincipalState
    extends State<PantallaNavegacionPrincipal> {
  int _indiceSeleccionado = 0;

  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = [
      const PantallaInicio(),
      const PantallaHistorial(),
      const PantallaPerfil(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _indiceSeleccionado == 0
          ? PantallaInicio(
              onNuevoGasto: _procesarNuevoGasto,
            )
          : _pantallas[_indiceSeleccionado],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        onTap: (index) {
          setState(() {
            _indiceSeleccionado = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: _indiceSeleccionado == 0
          ? FloatingActionButton(
              onPressed: () => _iniciarNuevoGasto(context),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _iniciarNuevoGasto(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaEditarTicket(
          onGastoCreado: _procesarNuevoGasto,
        ),
      ),
    );
  }

  void _procesarNuevoGasto(Gasto gasto) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PantallaDividirGastos(
          gasto: gasto,
          onGastoFinalizado: _gastoFinalizado,
        ),
      ),
    );
  }

  void _gastoFinalizado() {
    setState(() {
      _indiceSeleccionado = 0;
    });
  }
}
