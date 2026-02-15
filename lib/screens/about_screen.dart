import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de Reparaciones RK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.build_circle_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 25),
            
            const Text(
              'Reparaciones RK',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Tu solución confiable en reparaciones',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 40),
            
            _buildSection(
              title: 'Sobre Nosotros',
              content: 'Reparaciones RK es una empresa líder en el sector de '
                  'reparación y mantenimiento de dispositivos electrónicos. '
                  'Con más de 10 años de experiencia en el mercado, nos '
                  'especializamos en proporcionar soluciones rápidas y efectivas '
                  'para todo tipo de dispositivos tecnológicos.',
            ),
            
            const SizedBox(height: 20),
            
            _buildSection(
              title: 'Nuestra Misión',
              content: 'Proporcionar servicios de reparación de alta calidad '
                  'con atención personalizada, utilizando tecnología de punta '
                  'y componentes originales. Nos comprometemos a devolver '
                  'la funcionalidad a tus dispositivos en el menor tiempo '
                  'posible y con garantía incluida.',
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Servicios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceItem('📱 Reparación de smartphones y tablets'),
                      _buildServiceItem('💻 Mantenimiento de computadoras y laptops'),
                      _buildServiceItem('💾 Recuperación de datos'),
                      _buildServiceItem('🖥️ Instalación de software y sistemas operativos'),
                      _buildServiceItem('🔧 Asesoría técnica personalizada'),
                      _buildServiceItem('⚡ Reparación de consolas de videojuegos'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de Contacto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildContactItem(
                    context,
                    Icons.location_on,
                    'Av. Raiko, 3, Madrid, España',
                    Colors.black,
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    context,
                    Icons.access_time,
                    'Lunes a Viernes: 9:00 AM - 7:00 PM\nSábados: 10:00 AM - 2:00 PM',
                    Colors.black,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información de la Aplicación',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildAppInfoItem('Versión', '1.0.0'),
                  const Divider(height: 20, color: Color.fromARGB(255, 231, 227, 227)),
                  _buildAppInfoItem('Desarrollador', 'Reparaciones RK Team'),
                  const Divider(height: 20, color: Color.fromARGB(255, 243, 241, 241)),
                  _buildAppInfoItem('Última actualización', 'Diciembre 2025'),
                  const Divider(height: 20, color: Color.fromARGB(255, 235, 231, 231)),
                  _buildAppInfoItem('Plataforma', 'Flutter / FacturaScripts'),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showPrivacyPolicy(context),
                icon: const Icon(Icons.privacy_tip, color: Colors.black),
                label: const Text(
                  'Política de Privacidad',
                  style: TextStyle(color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              '© 2025 Reparaciones RK. Todos los derechos reservados.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Política de Privacidad',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reparaciones RK se compromete a proteger tu privacidad. '
                'Esta aplicación recopila y utiliza información personal '
                'únicamente para los siguientes propósitos:',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              _buildPrivacyItem('• Proporcionar y mejorar nuestros servicios'),
              _buildPrivacyItem('• Gestionar citas y reparaciones'),
              _buildPrivacyItem('• Comunicarnos contigo sobre tu dispositivo'),
              _buildPrivacyItem('• Cumplir con obligaciones legales'),
              const SizedBox(height: 15),
              const Text(
                'Tus datos están protegidos y no serán compartidos con '
                'terceros sin tu consentimiento, excepto cuando sea '
                'requerido por ley.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}