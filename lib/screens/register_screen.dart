import 'package:flutter/material.dart';
import 'package:proyecto/database/config.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';
import 'package:proyecto/database/servicio_db.dart';
import 'package:proyecto/screens/login_screen.dart';

class PantallaRegistro extends StatefulWidget {
  @override
  _EstadoPantallaRegistro createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final _servicioBD = ServicioBD();
  
  final _controladorCorreo = TextEditingController();
  final _controladorcontrasena = TextEditingController();
  final _controladorConfirmarcontrasena = TextEditingController();
  final _controladorNombre = TextEditingController();
  final _controladorTelefono = TextEditingController();
  
  bool _registrando = false;

  void _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      if (_controladorcontrasena.text != _controladorConfirmarcontrasena.text) {
        _mostrarError('Error', 'Las contrasenas no coinciden');
        return;
      }

      setState(() => _registrando = true);

      try {
        final nuevoUsuario = Usuario(
          id: 0,
          correo: _controladorCorreo.text.trim(),
          contrasena: _controladorcontrasena.text,
          nombre: _controladorNombre.text.trim(),
          telefono: _controladorTelefono.text.trim(),
          rol: ConfiguracionBD.rolUsuario,
          fechaCreacion: DateTime.now(),
        );

        final exito = await _servicioBD.registrarUsuario(nuevoUsuario);
        
        if (exito) {
          _mostrarExito();
        } else {
          _mostrarError('Error', 'No se pudo registrar el usuario');
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
                MaterialPageRoute(builder: (context) => PantallaLogin()),
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
      MaterialPageRoute(builder: (context) => PantallaLogin()),
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
                    if (!valor.contains('@')) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo contrasena
                TextFormField(
                  controller: _controladorcontrasena,
                  decoration: InputDecoration(
                    labelText: 'contrasena',
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor ingresa una contrasena';
                    }
                    if (valor.length < 6) {
                      return 'La contrasena debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Campo Confirmar contrasena
                TextFormField(
                  controller: _controladorConfirmarcontrasena,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contrasena',
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Por favor confirma tu contrasena';
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
                          minimumSize: Size(double.infinity, 50),
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
    _controladorcontrasena.dispose();
    _controladorConfirmarcontrasena.dispose();
    _controladorNombre.dispose();
    _controladorTelefono.dispose();
    super.dispose();
  }
}