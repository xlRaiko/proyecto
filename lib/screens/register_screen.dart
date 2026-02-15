import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final dni = _dniController.text.trim().toUpperCase();
    if (!_isValidDNI(dni)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('DNI/NIF no válido. Ejemplo: 12345678A'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _phoneController.text.trim(),
      dni,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Registro exitoso'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else if (context.mounted) {
      final error = authProvider.errorMessage ?? 'Error en el registro';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidDNI(String dni) {
    if (dni.isEmpty) {
      return false;
    }
    
    final dniPattern = RegExp(r'^[0-9]{8}[A-Z]$');
    final nifPattern = RegExp(r'^[A-Z][0-9]{7,8}[A-Z]$');
    final cifPattern = RegExp(r'^[ABCDEFGHJNPQRSUVW][0-9]{7}[0-9A-J]$');
    
    return dniPattern.hasMatch(dni) || 
           nifPattern.hasMatch(dni) || 
           cifPattern.hasMatch(dni);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.build_circle_outlined,
              size: 60,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Crear nueva cuenta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Completa el formulario para registrarte',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo *',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: 'Juan Pérez García',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu nombre';
                      }
                      if (value.length < 3) {
                        return 'El nombre debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _dniController,
                    decoration: const InputDecoration(
                      labelText: 'DNI/NIF/CIF *',
                      prefixIcon: Icon(Icons.badge_outlined),
                      hintText: '12345678A o A12345678',
                      helperText: 'Ejemplo: 12345678A (DNI) o A12345678 (NIF)',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu DNI/NIF';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico *',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'ejemplo@correo.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Correo electrónico inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono *',
                      prefixIcon: Icon(Icons.phone_outlined),
                      hintText: '612345678',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu teléfono';
                      }
                      if (value.length < 9) {
                        return 'Teléfono inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      helperText: 'Mínimo 6 caracteres - También será tu API Key',
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor confirma tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('REGISTRARSE'),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Ya tienes una cuenta?',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}