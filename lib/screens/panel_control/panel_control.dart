import 'package:flutter/material.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';

class PanelControl extends StatelessWidget {
  final Usuario usuario;

  const PanelControl({super.key, required this.usuario});

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Control'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel de ${usuario.nombreRol}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _TarjetaOpcion(
                  icono: Icons.calendar_today,
                  titulo: 'Gestionar Citas',
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Navegar a gestión de citas
                  },
                ),
                if (usuario.esAdministrador)
                  _TarjetaOpcion(
                    icono: Icons.people,
                    titulo: 'Gestionar Usuarios',
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navegar a gestión de usuarios
                    },
                  ),
                _TarjetaOpcion(
                  icono: Icons.analytics,
                  titulo: 'Estadísticas',
                  color: Colors.orange,
                  onTap: () {
                    // TODO: Navegar a estadísticas
                  },
                ),
                _TarjetaOpcion(
                  icono: Icons.report,
                  titulo: 'Reportes',
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Navegar a reportes
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaOpcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaOpcion({
    super.key,
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext contexto) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 40, color: color),
              SizedBox(height: 8),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}