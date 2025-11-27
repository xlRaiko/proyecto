import 'package:flutter/material.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';

class MenuLateral extends StatelessWidget {
  final Usuario usuario;

  const MenuLateral({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext contexto) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    usuario.nombre[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  radius: 30,
                ),
                SizedBox(height: 8),
                Text(
                  usuario.nombre,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  usuario.nombreRol,
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Color(0xFF2E7D32)),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(contexto);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
            title: Text('Mis Citas'),
            onTap: () {
              Navigator.pop(contexto);
            },
          ),
          if (usuario.esTecnico) ...[
            Divider(),
            ListTile(
              leading: Icon(Icons.dashboard, color: Color(0xFF2E7D32)),
              title: Text('Panel de Control'),
              onTap: () {
                Navigator.pop(contexto);
                // TODO: Navegar al panel de control
              },
            ),
            ListTile(
              leading: Icon(Icons.engineering, color: Color(0xFF2E7D32)),
              title: Text('Gestionar Citas'),
              onTap: () {
                Navigator.pop(contexto);
                // TODO: Navegar a gestión de citas
              },
            ),
          ],
          if (usuario.esAdministrador) ...[
            ListTile(
              leading: Icon(Icons.people, color: Color(0xFF2E7D32)),
              title: Text('Gestionar Usuarios'),
              onTap: () {
                Navigator.pop(contexto);
                // TODO: Navegar a gestión de usuarios
              },
            ),
          ],
          Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: Color(0xFF2E7D32)),
            title: Text('Configuración'),
            onTap: () {
              Navigator.pop(contexto);
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: Color(0xFF2E7D32)),
            title: Text('Ayuda'),
            onTap: () {
              Navigator.pop(contexto);
            },
          ),
        ],
      ),
    );
  }
}