import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _connectionStatus = '';
  bool _testingConnection = false;
  
  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _checkInitialConnection() async {
    setState(() {
      _testingConnection = true;
      _connectionStatus = 'Verificando conexión...';
    });
    
    final authProvider = context.read<AuthProvider>();
    final connected = await authProvider.checkApiConnection();
    
    setState(() {
      _testingConnection = false;
      _connectionStatus = connected 
          ? '✅ Conectado al servidor' 
          : '❌ No se puede conectar al servidor';
    });
    
    if (!connected && mounted) {
      _showConnectionError();
    }
  }
  
  void _showConnectionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Conexión'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No se pudo conectar al servidor. Verifica:'),
            SizedBox(height: 10),
            Text('• Que FacturaScripts esté ejecutándose'),
            Text('• Que la URL sea correcta'),
            Text('• Tu conexión a internet'),
            Text('• Que no haya firewall bloqueando'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkInitialConnection();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(email, password);
    
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Inicio de sesión exitoso'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      final error = authProvider.errorMessage ?? 'Error desconocido';
      _showLoginError(error, email);
    }
  }
  
  void _showLoginError(String error, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Autenticación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 20),
            const Text('💡 ¿Qué hacer?'),
            const SizedBox(height: 10),
            const Text('1. Verifica tu email'),
            const Text('2. Asegúrate que tu API Key es correcta'),
            const Text('3. Contacta al administrador si olvidaste tu API Key'),
            const SizedBox(height: 10),
            const Text('Recuerda: Tu contraseña ES tu API Key'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _connectionStatus = 'Probando conexión...';
    });
    
    final authProvider = context.read<AuthProvider>();
    final connected = await authProvider.checkApiConnection();
    
    setState(() {
      _testingConnection = false;
      _connectionStatus = connected 
          ? '✅ Conexión exitosa' 
          : '❌ Error de conexión';
    });
    
    if (!connected) {
      _showConnectionError();
    }
  }
  
  bool _isValidEmail(String email) {
    final pattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return pattern.hasMatch(email);
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.build_circle_outlined,
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 16),
              Text(
                'Reparaciones RK',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sistema de gestión de reparaciones',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildConnectionStatus(),
              
              const SizedBox(height: 32),
              _buildLoginForm(authProvider),
              
              const SizedBox(height: 24),
              _buildAdditionalButtons(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _connectionStatus.contains('✅') 
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _connectionStatus.contains('✅')
              ? Colors.green
              : Colors.red,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_testingConnection)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_connectionStatus.contains('✅'))
            const Icon(Icons.check_circle, size: 16, color: Colors.green)
          else if (_connectionStatus.isNotEmpty)
            const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            _connectionStatus.isNotEmpty ? _connectionStatus : 'Sin conexión',
            style: TextStyle(
              color: _connectionStatus.contains('✅')
                  ? Colors.green[800]
                  : Colors.red[800],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
              hintText: 'ejemplo@email.com',
              helperText: 'Ingresa el email con el que te registraste',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!_isValidEmail(value)) {
                return 'Formato de email no válido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
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
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
            onFieldSubmitted: (_) => _login(),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalButtons() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: _testingConnection ? null : _testConnection,
          icon: _testingConnection
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.wifi, size: 16),
          label: const Text('Probar Conexión'),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes una cuenta?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text(
                'Regístrate aquí',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}