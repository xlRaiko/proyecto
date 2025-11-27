import 'package:flutter/material.dart';
import 'package:proyecto/database/servicio_db.dart';
import 'package:proyecto/screens/home_screen.dart';
import 'package:proyecto/screens/register_screen.dart';
import 'package:proyecto/widgets/formulario_login.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _conectando = false;

  @override
  void initState() {
    super.initState();
    _verificarConexionBD();
  }

  Future<void> _verificarConexionBD() async {
    setState(() => _conectando = true);
    try {
      bool conectado = await _databaseService.testConnection();
      if (!conectado) {
        _mostrarError('Error de conexión', 'No se pudo conectar a la base de datos');
      }
    } catch (e) {
      _mostrarError('Error de conexión', 'Error: $e');
    } finally {
      setState(() => _conectando = false);
    }
  }

  Future<void> _manejarLogin(String correo, String contrasena) async {
    try {
      final usuario = await _databaseService.login(correo, contrasena);
      
      if (usuario != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaPrincipal(usuario: usuario),
          ),
        );
      } else {
        _mostrarError('Login fallido', 'Correo o contrasena incorrectos');
      }
    } catch (e) {
      _mostrarError('Error', 'Error al conectar con el servidor: $e');
    }
  }

  void _irARegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaRegistro()),
    );
  }

  void _mostrarError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo, style: TextStyle(color: Colors.red)),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK', style: TextStyle(color: Color(0xFF2E7D32))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              // Encabezado
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 80,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'TechRepair',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sistema de Citas para Reparaciones',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Formulario
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    if (_conectando) ...[
                      CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      SizedBox(height: 16),
                      Text(
                        'Conectando con la base de datos...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 32),
                    ] else ...[
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Accede a tu cuenta para gestionar tus citas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),
                      FormularioLogin(
                        onLogin: _manejarLogin,
                        onRegistrar: _irARegistro,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}