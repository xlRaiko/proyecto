import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PaginaConfiguracion extends StatefulWidget {
  const PaginaConfiguracion({super.key});

  @override
  State<PaginaConfiguracion> createState() => _PaginaConfiguracionState();
}

class _PaginaConfiguracionState extends State<PaginaConfiguracion> {
  final TextEditingController _controladorNombre = TextEditingController();
  final TextEditingController _controladorCorreo = TextEditingController();
  final TextEditingController _controladorTelefono = TextEditingController();
  final TextEditingController _controladorContrasena = TextEditingController();
  
  String? _avatarBase64;
  bool _estaCargando = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() {
    // Aquí cargarías los datos actuales del usuario desde tu base de datos
    _controladorNombre.text = 'Usuario Ejemplo';
    _controladorCorreo.text = 'usuario@ejemplo.com';
    _controladorTelefono.text = '+1234567890';
  }

  Future<void> _seleccionarImagen() async {
    try {
      final ImagePicker selector = ImagePicker();
      final XFile? imagen = await selector.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (imagen != null) {
        setState(() {
          _estaCargando = true;
        });

        final bytes = await File(imagen.path).readAsBytes();
        final cadenaBase64 = base64Encode(bytes);
        
        setState(() {
          _avatarBase64 = cadenaBase64;
          _estaCargando = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar actualizado correctamente')),
        );
      }
    } catch (error) {
      setState(() {
        _estaCargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir imagen: $error')),
      );
    }
  }

  void _actualizarPerfil() {
    if (_controladorNombre.text.isEmpty || _controladorCorreo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y correo son obligatorios')),
      );
      return;
    }

    // Aquí implementarías la actualización en tu backend
    final datosNuevos = {
      'nombre': _controladorNombre.text,
      'correo': _controladorCorreo.text,
      'telefono': _controladorTelefono.text,
      'avatar': _avatarBase64,
    };
    
    print('Datos a actualizar: $datosNuevos');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado correctamente')),
    );
  }

  void _cambiarContrasena() {
    if (_controladorContrasena.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa una nueva contraseña')),
      );
      return;
    }

    if (_controladorContrasena.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    // Aquí implementarías el cambio de contraseña en tu backend
    print('Nueva contraseña: ${_controladorContrasena.text}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña actualizada correctamente')),
    );
    
    _controladorContrasena.clear();
  }

  Widget _construirSeccionAvatar() {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _avatarBase64 != null
                  ? MemoryImage(base64Decode(_avatarBase64!))
                  : null,
              child: _avatarBase64 == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            if (_estaCargando)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _seleccionarImagen,
          icon: const Icon(Icons.camera_alt),
          label: Text(_avatarBase64 == null ? 'Agregar Avatar' : 'Cambiar Avatar'),
        ),
      ],
    );
  }

  Widget _construirCampoTexto({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    bool obscureText = false,
    TextInputType tipoTeclado = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controlador,
        obscureText: obscureText,
        keyboardType: tipoTeclado,
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: Icon(icono),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Sección Avatar
            Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: _construirSeccionAvatar(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sección Información Personal
            Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _construirCampoTexto(
                      controlador: _controladorNombre,
                      etiqueta: 'Nombre Completo',
                      icono: Icons.person,
                    ),
                    _construirCampoTexto(
                      controlador: _controladorCorreo,
                      etiqueta: 'Correo Electrónico',
                      icono: Icons.email,
                      tipoTeclado: TextInputType.emailAddress,
                    ),
                    _construirCampoTexto(
                      controlador: _controladorTelefono,
                      etiqueta: 'Número de Teléfono',
                      icono: Icons.phone,
                      tipoTeclado: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _actualizarPerfil,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sección Seguridad
            Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seguridad',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _construirCampoTexto(
                      controlador: _controladorContrasena,
                      etiqueta: 'Nueva Contraseña',
                      icono: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La contraseña debe tener al menos 6 caracteres',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _cambiarContrasena,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Cambiar Contraseña'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCorreo.dispose();
    _controladorTelefono.dispose();
    _controladorContrasena.dispose();
    super.dispose();
  }
}