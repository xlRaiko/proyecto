import 'package:flutter/material.dart';
import 'package:proyecto/database/auth.dart';
import 'package:proyecto/database/servicio_db.dart';
import 'package:proyecto/screens/login_screen.dart';

class PantallaRegistro extends StatefulWidget {
  @override
  _EstadoPantallaRegistro createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _servicioBD = DatabaseService();
  final _authService = AuthService(); // Servicio de autenticación
  
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();
  final _controladorNombre = TextEditingController();
  final _controladorTelefono = TextEditingController();
  
  bool _registrando = false;

  void _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      if (_controladorContrasena.text != _controladorConfirmarContrasena.text) {
        _mostrarError('Error', 'Las contraseñas no coinciden');
        return;
      }

      setState(() => _registrando = true);

      try {
        // Registrar en Firebase Authentication y base de datos local
        final user = await _authService.registrarConEmailYContrasena(
          _controladorCorreo.text.trim(),
          _controladorContrasena.text,
          _controladorNombre.text.trim(),
          _controladorTelefono.text.trim(),
        );
        
        if (user != null) {
          _mostrarExito();
        } else {
          _mostrarError('Error', 'No se pudo registrar el usuario. El correo puede estar en uso.');
        }
      } catch (e) {
        _mostrarError('Error', e.toString());
      } finally {
        setState(() => _registrando = false);
      }
    }
  }

  void _mostrarExito() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registro Exitoso', style: TextStyle(color: Color(0xFF2E7D32))),
        content: Text('Tu cuenta ha sido creada exitosamente. Ahora puedes iniciar sesión.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('OK', style: TextStyle(color: Color(0xFF2E7D32))),
          ),
        ],
      ),
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

  void _volverALogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Cuenta'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _volverALogin,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.person_add_alt_1,
                  size: 60,
                  color: Color(0xFF2E7D32),
                ),
                SizedBox(height: 20),
                Text(
                  'Crear Nueva Cuenta',
                  style: Theme.of(contexto).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Completa tus datos para registrarte',
                  style: Theme.of(contexto).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Campo Nombre
                TextFormField(
                  controller: _controladorNombre,
                  decoration: InputDecoration(
                    labelText: 'Nombre Completo',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    if (valor.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo Teléfono
                TextFormField(
                  controller: _controladorTelefono,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    if (valor.length < 8) {
                      return 'Ingresa un teléfono válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo Correo
                TextFormField(
                  controller: _controladorCorreo,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(valor)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo Contraseña
                TextFormField(
                  controller: _controladorContrasena,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor ingresa una contraseña';
                    }
                    if (valor.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo Confirmar Contraseña
                TextFormField(
                  controller: _controladorConfirmarContrasena,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (valor != _controladorContrasena.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Botón Registrar
                _registrando
                    ? CircularProgressIndicator(color: Color(0xFF2E7D32))
                    : ElevatedButton(
                        onPressed: _registrarUsuario,
                        child: Text(
                          'Registrarse',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                SizedBox(height: 20),
                TextButton(
                  onPressed: _volverALogin,
                  child: Text(
                    '¿Ya tienes cuenta? Inicia Sesión',
                    style: TextStyle(color: Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmarContrasena.dispose();
    _controladorNombre.dispose();
    _controladorTelefono.dispose();
    super.dispose();
  }
}