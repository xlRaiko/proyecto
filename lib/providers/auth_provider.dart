import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto/api/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _userName;
  int? _userId;
  int? _userRole;
  String? _userEmail;
  String? _userApiKey;
  String? _errorMessage;
  Map<String, dynamic>? _userRawData;
  String? _userDni;
  String? _codCliente;
  bool _isLoading = false;
  
  bool get isAuthenticated => _userApiKey != null && _userApiKey!.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get userName => _userName;
  int? get userId => _userId;
  int? get userRole => _userRole;
  String? get userEmail => _userEmail;
  String? get apiKey => _userApiKey;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userRawData => _userRawData;
  String? get userDni => _userDni;
  String? get codCliente => _codCliente;
  
  AuthProvider() {
    _loadSavedAuth();
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final apiKeyData = await _findApiKeyByEmail(email);
      
      if (apiKeyData == null) {
        _setError('No existe API Key registrada para este email');
        _setLoading(false);
        return false;
      }
      
      final storedApiKey = apiKeyData['apikey']?.toString() ?? '';
      if (storedApiKey.isEmpty || password != storedApiKey) {
        _setError('API Key incorrecta');
        _setLoading(false);
        return false;
      }
      
      final userData = await _getUserDataWithApiKey(storedApiKey, apiKeyData);
      
      if (userData == null) {
        _createUserDataFromApiKey(apiKeyData, email);
      } else {
        _processUserData(userData);
      }
      
      _userDni = apiKeyData['dni']?.toString();
      _codCliente = apiKeyData['codcliente']?.toString();
      _userApiKey = storedApiKey;
      
      try {
        await _loadClienteName();
      } catch (e) {
      }
      
      await _saveSession();
      
      _setLoading(false);
      return true;
      
    } catch (error) {
      _setError('Error de conexión: $error');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register(String email, String password, String name, String phone, String dni) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      if (!_isValidDniFormat(dni)) {
        _setError('Formato de DNI/NIF no válido. Ejemplo: 12345678A');
        _setLoading(false);
        return false;
      }
      
      final dniUpper = dni.toUpperCase().trim();
      
      final clienteExistente = await _getClienteByDni(dniUpper);
      if (clienteExistente != null) {
        _setError('Ya existe un cliente registrado con ese DNI: $dniUpper');
        _setLoading(false);
        return false;
      }
      
      final apiKeyExistente = await _findApiKeyByEmail(email);
      if (apiKeyExistente != null) {
        _setError('Ya existe una API Key registrada para ese email: $email');
        _setLoading(false);
        return false;
      }
      
      final codCliente = _generateClienteCode(name, dniUpper);
      
      final clienteCreado = await _createCliente(name, email, phone, dniUpper, codCliente, password);
      
      if (!clienteCreado) {
        _setLoading(false);
        return false;
      }
      
      await Future.delayed(const Duration(seconds: 2));
      
      final apiKeyAutoCreada = await _findApiKeyByEmail(email);
      
      if (apiKeyAutoCreada != null) {
        final apiKeyAuto = apiKeyAutoCreada['apikey']?.toString() ?? '';
        if (apiKeyAuto != password) {
          await _updateApiKey(apiKeyAutoCreada['id'], password, dni: dniUpper, codCliente: codCliente);
        } else {
          final dniActual = apiKeyAutoCreada['dni']?.toString();
          final codClienteActual = apiKeyAutoCreada['codcliente']?.toString();
          
          if ((dniActual == null || dniActual.isEmpty) || 
              (codClienteActual == null || codClienteActual.isEmpty)) {
            await _updateApiKey(apiKeyAutoCreada['id'], password, dni: dniUpper, codCliente: codCliente);
          }
        }
      } else {
        final apiKeyCreada = await _createApiKeyForCliente(email, password, dniUpper, codCliente, name);
        
        if (!apiKeyCreada) {
          _setError('Cliente creado pero falló la creación de API Key. Contacta al administrador.');
          _setLoading(false);
          return false;
        }
      }
      
      final loginExitoso = await login(email, password);
      
      if (!loginExitoso) {
        _setError('Registro completado. Ahora puedes iniciar sesión manualmente.');
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return true;
      
    } catch (error) {
      _setError('Error en el proceso de registro: $error');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> logout() async {
    await _clearSession();
    notifyListeners();
  }
  
  Future<bool> checkApiConnection() async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl(''));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }
  
  Future<void> _loadSavedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _userApiKey = prefs.getString('apiKey');
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
      _userId = prefs.getInt('userId');
      _userRole = prefs.getInt('userRole');
      _userDni = prefs.getString('userDni');
      _codCliente = prefs.getString('codCliente');
      
      final userDataStr = prefs.getString('userRawData');
      if (userDataStr != null) {
        _userRawData = json.decode(userDataStr);
      }
      
      if (_userApiKey != null && _codCliente != null) {
        try {
          await _loadClienteName();
        } catch (e) {
        }
      }
      
    } catch (error) {
    }
  }
  
  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('apiKey', _userApiKey ?? '');
      await prefs.setString('userName', _userName ?? '');
      await prefs.setString('userEmail', _userEmail ?? '');
      await prefs.setInt('userId', _userId ?? 0);
      await prefs.setInt('userRole', _userRole ?? 1);
      await prefs.setString('userDni', _userDni ?? '');
      await prefs.setString('codCliente', _codCliente ?? '');
      
      if (_userRawData != null) {
        await prefs.setString('userRawData', json.encode(_userRawData!));
      }
      
    } catch (error) {
    }
  }
  
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('apiKey');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('userId');
    await prefs.remove('userRole');
    await prefs.remove('userDni');
    await prefs.remove('codCliente');
    await prefs.remove('userRawData');
    
    _userApiKey = null;
    _userName = null;
    _userEmail = null;
    _userId = null;
    _userRole = null;
    _userDni = null;
    _codCliente = null;
    _userRawData = null;
    _errorMessage = null;
  }
  
  Future<Map<String, dynamic>?> _findApiKeyByEmail(String email) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/apikeyes'));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          final emailBuscado = email.toLowerCase().trim();
          
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final description = item['description']?.toString().toLowerCase().trim();
              
              if (description == emailBuscado) {
                return item;
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          final description = data['description']?.toString().toLowerCase().trim();
          if (description == email.toLowerCase().trim()) {
            return data;
          }
        }
        
        return null;
        
      } else {
        return null;
      }
      
    } catch (error) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> _getUserDataWithApiKey(String apiKey, Map<String, dynamic> apiKeyData) async {
    try {
      final nick = apiKeyData['nick']?.toString();
      final email = apiKeyData['description']?.toString();
      
      if (nick != null && nick.isNotEmpty) {
        final data = await _fetchUserDataByNick(nick, apiKey);
        if (data != null) {
          return data;
        }
      }
      
      if (email != null && email.isNotEmpty) {
        final data = await _fetchUserDataByEmail(email, apiKey);
        if (data != null) {
          return data;
        }
      }
      
      return null;
      
    } catch (error) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> _fetchUserDataByNick(String nick, String apiKey) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/users'));
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(userApiKey: apiKey),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          for (var user in data) {
            if (user is Map<String, dynamic>) {
              final userNick = user['nick']?.toString();
              if (userNick == nick) {
                return user;
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          final userNick = data['nick']?.toString();
          if (userNick == nick) {
            return data;
          }
        }
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> _fetchUserDataByEmail(String email, String apiKey) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/users'));
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(userApiKey: apiKey),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          for (var user in data) {
            if (user is Map<String, dynamic>) {
              final userEmail = user['email']?.toString();
              if (userEmail?.toLowerCase() == email.toLowerCase()) {
                return user;
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          final userEmail = data['email']?.toString();
          if (userEmail?.toLowerCase() == email.toLowerCase()) {
            return data;
          }
        }
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }
  
  void _processUserData(Map<String, dynamic> data) {
    _userRawData = data;
    _userName = data['nombre'] ?? data['nick'] ?? data['email']?.split('@').first ?? 'Usuario';
    _userEmail = data['email']?.toString() ?? '';
    _userId = int.tryParse(data['id']?.toString() ?? '0') ?? 0;
    
    final level = int.tryParse(data['level']?.toString() ?? '1') ?? 1;
    final isAdmin = data['admin'] == true || data['admin'] == 'true' || level == 99;
    
    if (isAdmin) {
      _userRole = 3;
    } else if (data['employee'] == true || level >= 50) {
      _userRole = 2;
    } else {
      _userRole = 1;
    }
  }
  
  void _createUserDataFromApiKey(Map<String, dynamic> apiKeyData, String email) {
    _userName = apiKeyData['nombre']?.toString() ?? apiKeyData['nick']?.toString() ?? email.split('@').first;
    _userEmail = email;
    _userId = 0;
    _userRole = 1;
    _userRawData = {
      'email': email,
      'nick': _userName,
      'nombre': apiKeyData['nombre'],
      'dni': apiKeyData['dni'],
      'codcliente': apiKeyData['codcliente'],
    };
  }
  
  Future<void> _loadClienteName() async {
    try {
      if (_codCliente != null && _codCliente!.isNotEmpty) {
        final url = Uri.parse(ApiConfig.getApiUrl('/clientes/$_codCliente'));
        
        final response = await http.get(
          url,
          headers: ApiConfig.getHeaders(userApiKey: _userApiKey),
        ).timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final clienteData = json.decode(response.body);
          if (clienteData is Map<String, dynamic>) {
            final nombreCliente = clienteData['nombre']?.toString();
            if (nombreCliente != null && nombreCliente.isNotEmpty) {
              _userName = nombreCliente;
              if (_userRawData != null) {
                _userRawData!['nombre'] = nombreCliente;
              }
            }
          }
        }
      }
    } catch (error) {
    }
  }
  
  Future<bool> _createCliente(String name, String email, String phone, String dni, String codCliente, String password) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/clientes'));
      
      final clienteData = {
        'codcliente': codCliente,
        'nombre': name,
        'razonsocial': name,
        'cifnif': dni,
        'tipoidfiscal': 'NIF',
        'email': email,
        'telefono1': phone,
        'personafisica': 'true',
        'fechaalta': DateTime.now().toIso8601String().split('T')[0],
        'debaja': 'false',
        'regimeniva': '01',
        'password': password,
      };
      
      final response = await http.post(
        url,
        headers: ApiConfig.getFormHeaders(),
        body: ApiConfig.encodeFormData(clienteData),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (response.body.contains('ya existe')) {
          _setError('Ya existe un cliente con ese código o DNI');
        } else {
          _setError('Error ${response.statusCode} al crear cliente');
        }
        
        return false;
      }
    } catch (error) {
      _setError('Error de conexión al crear cliente: $error');
      return false;
    }
  }
  
  Future<bool> _createApiKeyForCliente(String email, String apiKeyValue, String dni, String codCliente, String name) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/apikeyes'));
      
      final apiKeyData = {
        'apikey': apiKeyValue,
        'description': email,
        'nick': email.split('@').first,
        'dni': dni,
        'codcliente': codCliente,
        'creationdate': DateTime.now().toIso8601String().split('T')[0],
        'fullaccess': '0',
      };
      
      final response = await http.post(
        url,
        headers: ApiConfig.getFormHeaders(),
        body: ApiConfig.encodeFormData(apiKeyData),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  Future<bool> _updateApiKey(dynamic id, String newApiKey, {String? dni, String? codCliente}) async {
    try {
      final url = Uri.parse('${ApiConfig.getApiUrl('/apikeyes')}/$id');
      
      final apiKeyData = {
        'apikey': newApiKey,
      };
      
      if (dni != null && dni.isNotEmpty) {
        apiKeyData['dni'] = dni;
      }
      
      if (codCliente != null && codCliente.isNotEmpty) {
        apiKeyData['codcliente'] = codCliente;
      }
      
      final response = await http.put(
        url,
        headers: ApiConfig.getFormHeaders(),
        body: ApiConfig.encodeFormData(apiKeyData),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> _getClienteByDni(String dni) async {
    try {
      final url = Uri.parse(ApiConfig.getApiUrl('/clientes'));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          for (var cliente in data) {
            if (cliente is Map<String, dynamic>) {
              final clienteDni = cliente['cifnif']?.toString().toUpperCase();
              if (clienteDni == dni) {
                return cliente;
              }
            }
          }
        } else if (data is Map<String, dynamic>) {
          final clienteDni = data['cifnif']?.toString().toUpperCase();
          if (clienteDni == dni) {
            return data;
          }
        }
      }
      
      return null;
    } catch (error) {
      return null;
    }
  }
  
  String _generateClienteCode(String name, String dni) {
    final nombreLimpio = name.replaceAll(RegExp(r'[^A-Za-z]'), '').toUpperCase();
    final iniciales = nombreLimpio.length >= 2 
        ? nombreLimpio.substring(0, 2) 
        : nombreLimpio.padRight(2, 'X');
    
    final digitosDni = dni.replaceAll(RegExp(r'[^0-9]'), '');
    final ultimosDigitos = digitosDni.length >= 3 
        ? digitosDni.substring(digitosDni.length - 3) 
        : digitosDni.padLeft(3, '0');
    
    return 'CLI${iniciales}${ultimosDigitos}';
  }
  
  bool _isValidDniFormat(String dni) {
    final dniUpper = dni.toUpperCase().trim();
    
    final dniPattern = RegExp(r'^[0-9]{8}[A-Z]$');
    final nifPattern = RegExp(r'^[A-Z][0-9]{7,8}[A-Z]$');
    final cifPattern = RegExp(r'^[ABCDEFGHJNPQRSUVW][0-9]{7}[0-9A-J]$');
    final pasaportePattern = RegExp(r'^[A-Z][0-9]{7,8}$');
    
    return dniPattern.hasMatch(dniUpper) || 
           nifPattern.hasMatch(dniUpper) || 
           cifPattern.hasMatch(dniUpper) ||
           pasaportePattern.hasMatch(dniUpper);
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
  }
  
  Map<String, String> getAuthHeaders() {
    return ApiConfig.getHeaders(userApiKey: _userApiKey);
  }
  
  Map<String, String> getAuthFormHeaders() {
    return ApiConfig.getFormHeaders(userApiKey: _userApiKey);
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<void> refreshUserData() async {
    if (_userApiKey == null || _userEmail == null) return;
    
    try {
      _setLoading(true);
      final userData = await _getUserDataWithApiKey(_userApiKey!, {
        'description': _userEmail,
        'nick': _userName,
      });
      
      if (userData != null) {
        _processUserData(userData);
        try {
          await _loadClienteName();
        } catch (e) {
        }
        await _saveSession();
        notifyListeners();
      }
    } catch (error) {
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> verifyApiKeyStatus(String email, String apiKey) async {
    try {
      final apiKeyData = await _findApiKeyByEmail(email);
      
      if (apiKeyData == null) return false;
      
      final storedApiKey = apiKeyData['apikey']?.toString() ?? '';
      
      return storedApiKey == apiKey;
    } catch (error) {
      return false;
    }
  }
}