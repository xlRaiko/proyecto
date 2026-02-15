import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:proyecto/providers/auth_provider.dart';
import 'package:proyecto/api/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userRawData;

    if (userData != null) {
      final clienteData = await _findCliente(authProvider);
      
      _nameController.text =
          clienteData?['nombre']?.toString() ??
          userData['nombre']?.toString() ??
          userData['nick']?.toString() ??
          authProvider.userName ??
          '';
      _emailController.text =
          userData['email']?.toString() ?? authProvider.userEmail ?? '';

      if (clienteData != null && clienteData['telefono1'] != null) {
        _phoneController.text = clienteData['telefono1']?.toString() ?? '';
      } else {
        _phoneController.text =
            userData['telefono']?.toString() ??
            userData['phone']?.toString() ??
            userData['telefono1']?.toString() ??
            '';
      }
    } else {
      _loadBasicUserData();
    }
  }

  void _loadBasicUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.userName ?? '';
    _emailController.text = authProvider.userEmail ?? '';
  }

  Future<void> _refreshUserData() async {
    setState(() => _isRefreshing = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserData();
      await _loadUserData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando datos: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing && !_isChangingPassword)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          IconButton(
            icon: _isRefreshing
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshUserData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black,
                          child: Text(
                            authProvider.userName
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.userName ?? 'Usuario',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          authProvider.userEmail ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (authProvider.userRole != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Chip(
                              label: Text(
                                _getRoleName(authProvider.userRole!),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getRoleColor(
                                authProvider.userRole!,
                              ),
                            ),
                          ),
                        if (authProvider.userDni != null &&
                            authProvider.userDni!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'DNI: ${authProvider.userDni}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (authProvider.apiKey != null &&
                      authProvider.apiKey!.isNotEmpty)
                    if (!_isChangingPassword) _buildProfileForm(),
                  if (_isChangingPassword) _buildPasswordForm(),

                  const SizedBox(height: 20),

                  if (!_isEditing && !_isChangingPassword)
                    Column(
                      children: [
                        _buildActionButton(
                          text: 'Cambiar Contraseña',
                          icon: Icons.lock,
                          onPressed: () {
                            setState(() {
                              _isChangingPassword = true;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          text: 'Tus datos',
                          icon: Icons.code,
                          onPressed: () {
                            _showTechnicalDataDialog(context, authProvider);
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  String _obscureApiKey(String apiKey) {
    if (apiKey.length <= 10) return apiKey;
    return '${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 5)}';
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información Personal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            enabled: false,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 30),

          if (_isEditing)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Guardar Cambios',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                      _loadUserData();
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm() {
    final passwordFormKey = GlobalKey<FormState>();

    return Form(
      key: passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cambiar API Key/Contraseña',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Recuerda: Tu contraseña ES tu API Key',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _currentPasswordController,
            decoration: const InputDecoration(
              labelText: 'API Key actual',
              prefixIcon: Icon(Icons.vpn_key),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu API Key actual';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _newPasswordController,
            decoration: const InputDecoration(
              labelText: 'Nueva API Key',
              prefixIcon: Icon(Icons.lock_outline),
              border: OutlineInputBorder(),
              helperText:
                  'Mínimo 6 caracteres - Será tu nueva API Key y contraseña',
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa la nueva API Key';
              }
              if (value.length < 6) {
                return 'La API Key debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(
              labelText: 'Confirmar nueva API Key',
              prefixIcon: Icon(Icons.lock_reset),
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma la nueva API Key';
              }
              if (value != _newPasswordController.text) {
                return 'Las API Keys no coinciden';
              }
              return null;
            },
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _changeApiKey(passwordFormKey),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Cambiar API Key',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isChangingPassword = false;
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.apiKey == null) {
          throw Exception('No se encontró la API key del usuario');
        }

        final userEmail = authProvider.userEmail;
        if (userEmail == null) {
          throw Exception('No se encontró el email del usuario');
        }

        await _updateUserInUsersTable(authProvider);

        await _updateClientProfile(authProvider);

        await authProvider.refreshUserData();
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _isEditing = false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserInUsersTable(AuthProvider authProvider) async {
    try {
      final users = await _fetchUsers(authProvider);

      if (users.isNotEmpty) {
        final user = users.firstWhere(
          (u) =>
              u['email']?.toString().toLowerCase() ==
              authProvider.userEmail?.toLowerCase(),
          orElse: () => {},
        );

        if (user.isNotEmpty && user['id'] != null) {
          final userId = user['id'].toString();

          final updateData = {
            'nick': _nameController.text,
            'email': _emailController.text,
            if (_phoneController.text.isNotEmpty)
              'telefono1': _phoneController.text,
          };

          final url = Uri.parse(ApiConfig.getApiUrl('/users/$userId'));

          await http
              .put(
                url,
                headers: authProvider.getAuthFormHeaders(),
                body: ApiConfig.encodeFormData(updateData),
              )
              .timeout(const Duration(seconds: 15));
        }
      }
    } catch (error) {}
  }

  Future<List<Map<String, dynamic>>> _fetchUsers(
    AuthProvider authProvider,
  ) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/users'));

      final response = await http
          .get(url, headers: authProvider.getAuthHeaders())
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic>) {
          return [data];
        }
      }
      return [];
    } catch (error) {
      return [];
    }
  }

  Future<void> _updateClientProfile(AuthProvider authProvider) async {
    try {
      final client = await _findCliente(authProvider);

      if (client != null && client['codcliente'] != null) {
        final clientId = client['codcliente'].toString();

        final updateClientData = {
          'nombre': _nameController.text,
          'razonsocial': _nameController.text,
          'email': _emailController.text,
          if (_phoneController.text.isNotEmpty)
            'telefono1': _phoneController.text,
        };

        final updateUrl = Uri.parse(ApiConfig.getApiUrl('/clientes/$clientId'));

        await http
            .put(
              updateUrl,
              headers: authProvider.getAuthFormHeaders(),
              body: ApiConfig.encodeFormData(updateClientData),
            )
            .timeout(const Duration(seconds: 10));
      }
    } catch (error) {}
  }

  Future<Map<String, dynamic>?> _findCliente(AuthProvider authProvider) async {
    try {
      if (authProvider.codCliente != null && authProvider.codCliente!.isNotEmpty) {
        final directUrl = Uri.parse(ApiConfig.getApiUrl('/clientes/${authProvider.codCliente}'));
        
        final directResponse = await http
            .get(directUrl, headers: authProvider.getAuthHeaders())
            .timeout(const Duration(seconds: 10));
            
        if (directResponse.statusCode == 200) {
          final clienteData = json.decode(directResponse.body);
          if (clienteData is Map<String, dynamic>) {
            return clienteData;
          }
        }
      }
      
      if (authProvider.userEmail != null) {
        final url = Uri.parse(ApiConfig.getApiUrl('/clientes'));

        final response = await http
            .get(url, headers: authProvider.getAuthHeaders())
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data is List) {
            for (var cliente in data) {
              if (cliente is Map<String, dynamic>) {
                if (authProvider.codCliente != null) {
                  final clienteCod = cliente['codcliente']?.toString();
                  if (clienteCod == authProvider.codCliente) {
                    return cliente;
                  }
                }
                
                final clienteEmail = cliente['email']?.toString().toLowerCase();
                final userEmail = authProvider.userEmail?.toLowerCase();

                if (clienteEmail == userEmail) {
                  return cliente;
                }

                if (authProvider.userDni != null) {
                  final clienteDni = cliente['cifnif']
                      ?.toString()
                      .toUpperCase();
                  if (clienteDni == authProvider.userDni?.toUpperCase()) {
                    return cliente;
                  }
                }
              }
            }
          }
        }
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<void> _changeApiKey(GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las API Keys no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userEmail = authProvider.userEmail;

        if (userEmail == null) {
          throw Exception('No se encontró el email del usuario');
        }

        final isValidCurrent = await authProvider.verifyApiKeyStatus(
          userEmail,
          _currentPasswordController.text,
        );

        if (!isValidCurrent) {
          throw Exception('API Key actual incorrecta');
        }

        final passwordUpdated = await _updateClientPassword(
          authProvider,
          _newPasswordController.text,
        );

        if (!passwordUpdated) {
          throw Exception('No se pudo actualizar la contraseña');
        }

        final success = await authProvider.login(
          userEmail,
          _newPasswordController.text,
        );

        if (!success) {
          throw Exception(
            'No se pudo actualizar la sesión con la nueva API Key',
          );
        }

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key cambiada correctamente'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() => _isChangingPassword = false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _updateClientPassword(
    AuthProvider authProvider,
    String newPassword,
  ) async {
    try {
      final client = await _findCliente(authProvider);

      if (client == null || client['codcliente'] == null) {
        return false;
      }

      final clientId = client['codcliente'].toString();

      final updateUrl = Uri.parse(ApiConfig.getApiUrl('/clientes/$clientId'));

      final updateData = {'password': newPassword};

      final response = await http
          .put(
            updateUrl,
            headers: authProvider.getAuthFormHeaders(),
            body: ApiConfig.encodeFormData(updateData),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (error) {
      return false;
    }
  }

  String _getRoleName(int role) {
    switch (role) {
      case 1:
        return 'Cliente';
      case 2:
        return 'Técnico';
      case 3:
      case 99:
        return 'Administrador';
      default:
        return 'Usuario';
    }
  }

  Color _getRoleColor(int role) {
    switch (role) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
      case 99:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showTechnicalDataDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code, color: Colors.blue),
            SizedBox(width: 10),
            Text('Datos Técnicos'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTechnicalItem('Email', authProvider.userEmail ?? 'N/A'),
              _buildTechnicalItem('Nombre', authProvider.userName ?? 'N/A'),
              _buildTechnicalItem('DNI', authProvider.userDni ?? 'N/A'),
              _buildTechnicalItem(
                'Código Cliente',
                authProvider.codCliente ?? 'N/A',
              ),
              _buildTechnicalItem(
                'Rol',
                '${authProvider.userRole} (${_getRoleName(authProvider.userRole ?? 1)})',
              ),

              if (authProvider.apiKey != null)
                _buildTechnicalItem(
                  'API Key',
                  _obscureApiKey(authProvider.apiKey!),
                  isSensitive: true,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (authProvider.apiKey != null)
            TextButton(
              onPressed: () async {
                try {
                  await Clipboard.setData(
                    ClipboardData(text: authProvider.apiKey!),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key copiada al portapapeles'),
                    ),
                  );
                  Navigator.pop(context);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al copiar: $error')),
                  );
                }
              },
              child: const Text('Copiar API Key'),
            ),
        ],
      ),
    );
  }

  Widget _buildTechnicalItem(
    String label,
    String value, {
    bool isSensitive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: isSensitive ? 'monospace' : null,
                color: isSensitive ? Colors.blue : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
