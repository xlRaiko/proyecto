import 'package:flutter/material.dart';
import 'package:proyecto/database/modelos/cita_modelo.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';
import 'package:proyecto/database/servicio_db.dart';
import 'package:proyecto/widgets/menu_lateral.dart';
import 'package:proyecto/widgets/tarjeta_cita.dart';
import 'panel_control/panel_control.dart';

class PantallaPrincipal extends StatefulWidget {
  final Usuario usuario;

  const PantallaPrincipal({Key? key, required this.usuario}) : super(key: key);

  @override
  _EstadoPantallaPrincipal createState() => _EstadoPantallaPrincipal();
}

class _EstadoPantallaPrincipal extends State<PantallaPrincipal> {
  final DatabaseService _servicioBD = DatabaseService();
  List<Cita> _citas = [];
  bool _cargando = true;
  int _indiceNavegacion = 0;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    try {
      List<Cita> citas;
      if (widget.usuario.esTecnico) {
        citas = await _servicioBD.getAllAppointments();
      } else {
        citas = await _servicioBD.getUserAppointments(widget.usuario.id);
      }
      setState(() {
        _citas = citas;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      _mostrarError('Error', 'No se pudieron cargar las citas: $e');
    }
  }

  void _mostrarError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void _onItemTapped(int indice) {
    setState(() {
      _indiceNavegacion = indice;
    });
  }

  Widget _construirListaCitas() {
    if (_cargando) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
    }

    if (_citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              'No hay citas programadas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.usuario.esUsuarioNormal 
                  ? 'Programa tu primera cita de reparación'
                  : 'No hay citas en el sistema',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _citas.length,
      itemBuilder: (contexto, indice) {
        return TarjetaCita(
          cita: _citas[indice],
          puedeEditar: widget.usuario.esTecnico,
          onActualizada: _cargarCitas,
        );
      },
    );
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TechRepair - Mis Citas'),
        actions: [
          if (widget.usuario.esTecnico)
            IconButton(
              icon: Icon(Icons.dashboard),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (contexto) => PanelControl(usuario: widget.usuario),
                  ),
                );
              },
              tooltip: 'Panel de Control',
            ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      drawer: MenuLateral(usuario: widget.usuario),
      body: _construirListaCitas(),
      floatingActionButton: widget.usuario.esUsuarioNormal
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navegar a pantalla de nueva cita
              },
              backgroundColor: Color(0xFF2E7D32),
              child: Icon(Icons.add, color: Colors.white),
              tooltip: 'Nueva Cita',
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceNavegacion,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Citas',
          ),
          if (widget.usuario.esTecnico)
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Panel',
            ),
        ],
      ),
    );
  }
}