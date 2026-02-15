import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto/api/api_config.dart';

class ReparacionProvider with ChangeNotifier {
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _citas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get productos => _productos;
  List<Map<String, dynamic>> get citas => _citas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> cargarProductos() async {
    try {
      setLoading(true);
      _errorMessage = null;

      final prefs = await SharedPreferences.getInstance();
      final userApiKey = prefs.getString('apiKey');

      if (userApiKey == null || userApiKey.isEmpty) {
        throw Exception('Usuario no autenticado. API Key no encontrada.');
      }

      final baseUrl = ApiConfig.baseUrl;
      final url = Uri.parse('${baseUrl}/api/3/reparaciones');
      
      final response = await http.get(
        url,
        headers: {
          'token': '$userApiKey',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        _productos = data
            .where((producto) => producto['nombre'] != null)
            .map((producto) {
              final imagen64 = producto['imagen64']?.toString() ?? '';
              
              return {
                'id': producto['idproducto']?.toString() ?? '',
                'name': producto['nombre']?.toString() ?? 'Sin nombre',
                'description': producto['descripcion']?.toString() ?? '',
                'imageBase64': imagen64,
                'fechaAlta': producto['fechaalta']?.toString() ?? '',
                'estado': producto['estado']?.toString() ?? 'Activo',
                'precio': producto['precio']?.toString() ?? '',
              };
            })
            .toList();
        
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Verifica tu API Key.');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso prohibido. No tienes permisos.');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint no encontrado: /api/3/reparaciones');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando productos: $e';
      _productos = [];
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clear() {
    _productos = [];
    _citas = [];
    _errorMessage = null;
    notifyListeners();
  }

  Map<String, dynamic>? getProductoById(String id) {
    try {
      return _productos.firstWhere((producto) => producto['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> crearRkproducto({
    required String nombre,
    required String tipo,
    required String codcliente,
    required String idproducto_reparacion,
    required String observaciones,
  }) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final prefs = await SharedPreferences.getInstance();
      final userApiKey = prefs.getString('apiKey');

      if (userApiKey == null || userApiKey.isEmpty) {
        throw Exception('Usuario no autenticado. API Key no encontrada.');
      }

      final baseUrl = ApiConfig.baseUrl;
      final url = Uri.parse('${baseUrl}/api/3/rkproductos');

      final body = {
        'nombre': nombre,
        'tipo': tipo,
        'codcliente': codcliente,
        'idproducto_reparacion': idproducto_reparacion,
        'observaciones': observaciones,
      };

      final headers = {
        'token': userApiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Verifica tu API Key.');
      } else if (response.statusCode == 403) {
        throw Exception('Acceso prohibido. No tienes permisos.');
      } else if (response.statusCode == 400) {
        throw Exception('Petición incorrecta: ${response.body}');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error creando rkproducto: $e';
      notifyListeners();
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> cargarCitas(String codcliente) async {
    try {
      setLoading(true);
      _errorMessage = null;

      final prefs = await SharedPreferences.getInstance();
      final userApiKey = prefs.getString('apiKey');

      if (userApiKey == null || userApiKey.isEmpty) {
        throw Exception('Usuario no autenticado. API Key no encontrada.');
      }

      final baseUrl = ApiConfig.baseUrl;
      final url = Uri.parse('${baseUrl}/api/3/citas?filter[codcliente]=$codcliente');
      
      final response = await http.get(
        url,
        headers: {
          'token': userApiKey,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        _citas = data.map((cita) {
          return {
            'idcita': cita['idcita']?.toString() ?? '',
            'codcliente': cita['codcliente']?.toString() ?? '',
            'idproducto': cita['idproducto']?.toString() ?? '',
            'nombre_producto': cita['nombre_producto']?.toString() ?? 'Sin nombre',
            'fecha': cita['fecha']?.toString() ?? '',
            'hora': cita['hora']?.toString() ?? '',
            'estado': cita['estado']?.toString() ?? 'Pendiente',
            'descripcion': cita['descripcion']?.toString() ?? '',
            'observaciones': cita['observaciones']?.toString() ?? '',
            'tecnico_asignado': cita['tecnico_asignado']?.toString() ?? 'Sin asignar',
            'fecha_registro': cita['fecha_registro']?.toString() ?? '',
          };
        }).toList();
        
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado. Verifica tu API Key.');
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'Error cargando citas: $e';
      _citas = [];
      notifyListeners();
    } finally {
      setLoading(false);
    }
  }
}