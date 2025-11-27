class ConfiguracionBD {
  // Configuración de conexión
  static const String servidor = 'localhost';
  static const int puerto = 3306;
  static const String nombreBD = 'sistema_citas_reparaciones';
  static const String usuario = 'usuario_app';
  static const String contrasena = 'contraseña_segura';
  
  // Nombres de tablas
  static const String tablaUsuarios = 'usuarios';
  static const String tablaCitas = 'citas';
  static const String tablaDispositivos = 'dispositivos';
  static const String tablaServicios = 'servicios';
  
  // Roles del sistema
  static const int rolUsuario = 1;
  static const int rolTecnico = 2;
  static const int rolAdministrador = 3;
  
  static String get cadenaConexion =>
      'mysql://$usuario:$contrasena@$servidor:$puerto/$nombreBD';
}