import 'package:proyecto/database/config.dart';
import 'package:proyecto/database/modelos/cita_modelo.dart';
import 'package:proyecto/database/modelos/dispositivo_modelo.dart';
import 'package:proyecto/database/modelos/servicio_modelo.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Datos de ejemplo para desarrollo
  final List<Usuario> _usuarios = [
    Usuario(
      id: 1,
      correo: 'cliente@ejemplo.com',
      contrasena: '123456',
      nombre: 'Juan Pérez',
      telefono: '+1234567890',
      rol: DatabaseConfig.rolUsuario,
      fechaCreacion: DateTime.now(),
    ),
    Usuario(
      id: 2,
      correo: 'tecnico@ejemplo.com',
      contrasena: '123456',
      nombre: 'María García',
      telefono: '+0987654321',
      rol: DatabaseConfig.rolTecnico,
      fechaCreacion: DateTime.now(),
    ),
    Usuario(
      id: 3,
      correo: 'admin@ejemplo.com',
      contrasena: '123456',
      nombre: 'Administrador Sistema',
      telefono: '+1112223333',
      rol: DatabaseConfig.rolAdministrador,
      fechaCreacion: DateTime.now(),
    ),
  ];

  final List<Cita> _citas = [
    Cita(
      id: 1,
      usuarioId: 1,
      dispositivoId: 1,
      servicioId: 1,
      fechaCita: DateTime(2024, 1, 15),
      horario: '10:00 - 11:00',
      estado: 'confirmada',
      descripcion: 'Pantalla rota necesita reemplazo completo',
      costoEstimado: 120.0,
      costoFinal: 0.0,
      fechaCreacion: DateTime.now(),
    ),
  ];

  final List<Dispositivo> _dispositivos = [
    Dispositivo(
      id: 1,
      usuarioId: 1,
      nombre: 'Mi Teléfono Principal',
      tipo: 'movil',
      marca: 'Samsung',
      modelo: 'Galaxy S21',
      descripcionProblema: 'Pantalla con grietas después de caída',
    ),
  ];

  final List<Servicio> _servicios = [
    Servicio(
      id: 1,
      nombre: 'Cambio de pantalla',
      descripcion: 'Reemplazo completo de pantalla rota o dañada',
      precioBase: 100.0,
      tipoDispositivo: 'movil',
      tiempoEstimado: 60,
      activo: true,
    ),
  ];

  // Método de login
  Future<Usuario?> login(String correo, String contrasena) async {
    await Future.delayed(Duration(milliseconds: 1000)); // Simular latencia
    
    try {
      final usuario = _usuarios.firstWhere(
        (user) => user.correo == correo && user.contrasena == contrasena,
      );
      return usuario;
    } catch (e) {
      return null;
    }
  }

  // Registrar nuevo usuario
  Future<bool> registerUser(Usuario usuario) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    try {
      // Verificar si el correo ya existe
      bool correoExiste = _usuarios.any((user) => user.correo == usuario.correo);
      if (correoExiste) {
        throw Exception('El correo ya está registrado');
      }
      
      // Agregar nuevo usuario
      _usuarios.add(usuario);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Obtener citas del usuario
  Future<List<Cita>> getUserAppointments(int usuarioId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _citas.where((cita) => cita.usuarioId == usuarioId).toList();
  }

  // Obtener todas las citas (para técnicos)
  Future<List<Cita>> getAllAppointments() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _citas;
  }

  // Obtener dispositivos del usuario
  Future<List<Dispositivo>> getUserDevices(int usuarioId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _dispositivos.where((device) => device.usuarioId == usuarioId).toList();
  }

  // Obtener servicios
  Future<List<Servicio>> getServices() async {
    await Future.delayed(Duration(milliseconds: 500));
    return _servicios;
  }

  // Crear nueva cita
  Future<bool> createAppointment(Cita cita) async {
    await Future.delayed(Duration(milliseconds: 500));
    _citas.add(cita);
    return true;
  }

  // Actualizar cita
  Future<bool> updateAppointment(Cita cita) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _citas.indexWhere((c) => c.id == cita.id);
    if (index != -1) {
      _citas[index] = cita;
      return true;
    }
    return false;
  }

  // Eliminar cita
  Future<bool> deleteAppointment(int citaId) async {
    await Future.delayed(Duration(milliseconds: 500));
    _citas.removeWhere((cita) => cita.id == citaId);
    return true;
  }

  // Verificar conexión
  Future<bool> testConnection() async {
    await Future.delayed(Duration(milliseconds: 1000));
    return true; // Simular conexión exitosa
  }
}