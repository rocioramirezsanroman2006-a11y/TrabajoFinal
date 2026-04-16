import 'package:flutter/material.dart';
import 'pantallas/inicio.dart';
import 'pantallas/editar_ticket.dart';
import 'pantallas/dividir_gastos.dart';
import 'pantallas/historial.dart';
import 'pantallas/perfil.dart';
import 'pantallas/login.dart';
import 'modelos/gasto.dart';
import 'servicios/autenticacion.dart';

void main() {
  runApp(const AplicacionDividirGastos());
}

class AplicacionDividirGastos extends StatelessWidget {
  const AplicacionDividirGastos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const colorBase = Color(0xFF2563EB);
    final colorScheme = ColorScheme.fromSeed(seedColor: colorBase);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dividir Gastos',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFF3F6FB),
          foregroundColor: Color(0xFF0F172A),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: colorBase,
          unselectedItemColor: Color(0xFF64748B),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  final ServicioAutenticacion _auth = ServicioAutenticacion();

  @override
  Widget build(BuildContext context) {
    if (_auth.estaAutenticado) {
      return PantallaNavegacionPrincipal(onCerrarSesion: _cerrarSesion);
    }

    return PantallaLogin(onLoginExitoso: _actualizarSesion);
  }

  void _actualizarSesion() {
    setState(() {});
  }

  void _cerrarSesion() {
    _auth.cerrarSesion();
    setState(() {});
  }
}

class PantallaNavegacionPrincipal extends StatefulWidget {
  final VoidCallback onCerrarSesion;

  const PantallaNavegacionPrincipal({
    Key? key,
    required this.onCerrarSesion,
  }) : super(key: key);

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
      PantallaPerfil(onCerrarSesion: widget.onCerrarSesion),
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
