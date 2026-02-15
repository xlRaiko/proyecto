import 'package:flutter/material.dart';
import 'package:proyecto/providers/auth_provider.dart';
import 'package:proyecto/screens/profile_screen.dart';
import 'package:proyecto/screens/appointments_screen.dart';
import 'package:proyecto/screens/about_screen.dart';

class MenuLateral extends StatelessWidget {
  final AuthProvider authProvider;
  
  const MenuLateral({
    super.key,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          
          _buildMenuItem(
            context: context,
            icon: Icons.person,
            title: 'Perfil',
            subtitle: 'Actualiza tu información personal',
            onTap: () => _navigateToScreen(context, const ProfileScreen()),
          ),
          
          const Divider(),
          
          _buildMenuItem(
            context: context,
            icon: Icons.calendar_today,
            title: 'Citas',
            subtitle: 'Ver tus citas pendientes',
            onTap: () => _navigateToScreen(context, const AppointmentsScreen()),
          ),
          
          _buildMenuItem(
            context: context,
            icon: Icons.notifications,
            title: 'Notificaciones',
            subtitle: 'Ver notificaciones del sistema',
            onTap: () => _showComingSoon(context, 'Notificaciones'),
          ),
          
          const Divider(),
          
          _buildMenuItem(
            context: context,
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Información de la aplicación',
            onTap: () => _navigateToScreen(context, const AboutScreen()),
          ),
          
          _buildMenuItem(
            context: context,
            icon: Icons.settings,
            title: 'Configuración',
            subtitle: 'Ajustes de la aplicación',
            onTap: () => _showComingSoon(context, 'Configuración'),
          ),
          
          const Divider(),
          
          _buildMenuItem(
            context: context,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: null,
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: Text(
              authProvider.userName?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            authProvider.userName ?? 'Usuario',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            authProvider.userEmail ?? '',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null 
          ? Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7)))
          : null,
      onTap: onTap,
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}