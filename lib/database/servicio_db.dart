import 'package:mysql1/mysql1.dart';
import 'package:proyecto/database/config.dart';
import 'modelos/usuario_modelo.dart';
import 'modelos/cita_modelo.dart';
import 'modelos/dispositivo_modelo.dart';
import 'modelos/servicio_modelo.dart';

class ServicioBD {
  static final ServicioBD _instancia = ServicioBD._internal();
  factory ServicioBD() => _instancia;
  ServicioBD._internal();

  MySqlConnection? _conexion;

  Future<MySqlConnection> _obtenerConexion() async {
    if (_conexion == null) {
      final configuracion = ConnectionSettings(
        host: ConfiguracionBD.servidor,
        port: ConfiguracionBD.puerto,
        user: ConfiguracionBD.usuario,
        password: ConfiguracionBD.contrasena,
        db: ConfiguracionBD.nombreBD,
      );
      
      _conexion = await MySqlConnection.connect(configuracion);
    }
    return _conexion!;
  }

  // Iniciar sesión
  Future<Usuario?> iniciarSesion(String correo, String contrasena) async {
    try {
      final conexion = await _obtenerConexion();
      
      final resultados = await conexion.query(
        'SELECT * FROM usuarios WHERE correo = ? AND contrasena = ?',
        [correo, contrasena]
      );

      if (resultados.isNotEmpty) {
        final fila = resultados.first;
        return Usuario.fromMap(fila.fields);
      }
      return null;
    } catch (e) {
      print('Error en inicio de sesión: $e');
      return null;
    }
  }

  // Registrar nuevo usuario
  Future<bool> registrarUsuario(Usuario usuario) async {
    try {
      final conexion = await _obtenerConexion();
      
      // Verificar si el correo ya existe
      final verificar = await conexion.query(
        'SELECT id FROM usuarios WHERE correo = ?',
        [usuario.correo]
      );

      if (verificar.isNotEmpty) {
        throw Exception('El correo ya está registrado');
      }

      await conexion.query(
        '''INSERT INTO usuarios (correo, contrasena, nombre, telefono, rol) 
           VALUES (?, ?, ?, ?, ?)''',
        [
          usuario.correo,
          usuario.contrasena,
          usuario.nombre,
          usuario.telefono,
          usuario.rol
        ]
      );

      return true;
    } catch (e) {
      print('Error registrando usuario: $e');
      return false;
    }
  }

  // Obtener citas del usuario
  Future<List<Cita>> obtenerCitasUsuario(int usuarioId) async {
    try {
      final conexion = await _obtenerConexion();
      
      final resultados = await conexion.query(
        '''SELECT c.*, d.nombre as dispositivo_nombre, s.nombre as servicio_nombre 
           FROM citas c 
           JOIN dispositivos d ON c.dispositivo_id = d.id 
           JOIN servicios s ON c.servicio_id = s.id 
           WHERE c.usuario_id = ? 
           ORDER BY c.fecha_cita DESC''',
        [usuarioId]
      );

      return resultados.map((fila) => Cita.fromMap(fila.fields)).toList();
    } catch (e) {
      print('Error obteniendo citas: $e');
      return [];
    }
  }

  // Obtener todas las citas (para técnicos y administradores)
  Future<List<Cita>> obtenerTodasLasCitas() async {
    try {
      final conexion = await _obtenerConexion();
      
      final resultados = await conexion.query(
        '''SELECT c.*, u.nombre as cliente_nombre, d.nombre as dispositivo_nombre, 
                  s.nombre as servicio_nombre, t.nombre as tecnico_nombre
           FROM citas c 
           JOIN usuarios u ON c.usuario_id = u.id 
           JOIN dispositivos d ON c.dispositivo_id = d.id 
           JOIN servicios s ON c.servicio_id = s.id 
           LEFT JOIN usuarios t ON c.tecnico_asignado_id = t.id 
           ORDER BY c.fecha_cita DESC'''
      );

      return resultados.map((fila) => Cita.fromMap(fila.fields)).toList();
    } catch (e) {
      print('Error obteniendo todas las citas: $e');
      return [];
    }
  }

  // Obtener dispositivos del usuario
  Future<List<Dispositivo>> obtenerDispositivosUsuario(int usuarioId) async {
    try {
      final conexion = await _obtenerConexion();
      
      final resultados = await conexion.query(
        'SELECT * FROM dispositivos WHERE usuario_id = ? ORDER BY fecha_creacion DESC',
        [usuarioId]
      );

      return resultados.map((fila) => Dispositivo.fromMap(fila.fields)).toList();
    } catch (e) {
      print('Error obteniendo dispositivos: $e');
      return [];
    }
  }

  // Obtener servicios disponibles
  Future<List<Servicio>> obtenerServicios() async {
    try {
      final conexion = await _obtenerConexion();
      
      final resultados = await conexion.query(
        'SELECT * FROM servicios WHERE activo = TRUE ORDER BY nombre'
      );

      return resultados.map((fila) => Servicio.fromMap(fila.fields)).toList();
    } catch (e) {
      print('Error obteniendo servicios: $e');
      return [];
    }
  }

  // Crear nueva cita
  Future<bool> crearCita(Cita cita) async {
    try {
      final conexion = await _obtenerConexion();
      
      await conexion.query(
        '''INSERT INTO citas 
           (usuario_id, dispositivo_id, servicio_id, fecha_cita, horario, estado, descripcion, costo_estimado) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          cita.usuarioId,
          cita.dispositivoId,
          cita.servicioId,
          cita.fechaCita.toIso8601String().split('T')[0],
          cita.horario,
          cita.estado,
          cita.descripcion,
          cita.costoEstimado
        ]
      );

      return true;
    } catch (e) {
      print('Error creando cita: $e');
      return false;
    }
  }

  // Actualizar cita (para técnicos y administradores)
  Future<bool> actualizarCita(Cita cita) async {
    try {
      final conexion = await _obtenerConexion();
      
      await conexion.query(
        '''UPDATE citas SET 
           estado = ?, costo_final = ?, notas_tecnico = ?, tecnico_asignado_id = ?
           WHERE id = ?''',
        [
          cita.estado,
          cita.costoFinal,
          cita.notasTecnico,
          cita.tecnicoAsignadoId,
          cita.id
        ]
      );

      return true;
    } catch (e) {
      print('Error actualizando cita: $e');
      return false;
    }
  }

  // Eliminar cita (solo administradores)
  Future<bool> eliminarCita(int citaId) async {
    try {
      final conexion = await _obtenerConexion();
      
      await conexion.query(
        'DELETE FROM citas WHERE id = ?',
        [citaId]
      );

      return true;
    } catch (e) {
      print('Error eliminando cita: $e');
      return false;
    }
  }

  // Verificar conexión
  Future<bool> verificarConexion() async {
    try {
      final conexion = await _obtenerConexion();
      await conexion.query('SELECT 1');
      return true;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // Cerrar conexión
  Future<void> cerrarConexion() async {
    await _conexion?.close();
    _conexion = null;
  }
}