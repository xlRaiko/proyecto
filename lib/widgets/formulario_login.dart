import 'package:flutter/material.dart';

class FormularioLogin extends StatefulWidget {
  final Function(String, String) onLogin;
  final VoidCallback onRegistrar; // Cambiado a VoidCallback

  const FormularioLogin({
    super.key,
    required this.onLogin,
    required this.onRegistrar,
  });

  @override
  _EstadoFormularioLogin createState() => _EstadoFormularioLogin();
}

class _EstadoFormularioLogin extends State<FormularioLogin> {
  final _formKey = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorcontrasena = TextEditingController();
  
  bool _cargando = false;
  bool _mostrarcontrasena = false;

  void _enviar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);
      
      try {
        await widget.onLogin(
          _controladorCorreo.text.trim(),
          _controladorcontrasena.text,
        );
      } finally {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext contexto) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _controladorcontrasena,
            decoration: InputDecoration(
              labelText: 'contrasena',
              prefixIcon: Icon(Icons.lock, color: Color(0xFF2E7D32)),
              suffixIcon: IconButton(
                icon: Icon(
                  _mostrarcontrasena ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _mostrarcontrasena = !_mostrarcontrasena);
                },
              ),
              border: OutlineInputBorder(),
            ),
            obscureText: !_mostrarcontrasena,
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Por favor ingresa tu contrasena';
              }
              if (valor.length < 6) {
                return 'La contrasena debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 30),
          _cargando
              ? CircularProgressIndicator(color: Color(0xFF2E7D32))
              : ElevatedButton(
                  onPressed: _enviar,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onRegistrar, // Ahora funciona correctamente
                child: Text(
                  'Crear Cuenta',
                  style: TextStyle(color: Color(0xFF2E7D32)),
                ),
              ),
              TextButton(
                onPressed: () {
                  _mostrarDialogoRecuperacion();
                },
                child: Text(
                  '¿Olvidaste tu contrasena?',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Aviso',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Necesitarás registrarte para poder acceder a tus citas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Tus datos son privados y están cifrados, por lo que son seguros',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoRecuperacion() {
    showDialog(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text('Recuperar contrasena'),
        content: Text('Esta funcionalidad estará disponible pronto.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorcontrasena.dispose();
    super.dispose();
  }
}