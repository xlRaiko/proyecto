class DatabaseConfig {
  // Configuración de conexión
  static const String host = 'localhost';
  static const int port = 3306;
  static const String dbName = 'sistema_citas_reparaciones';
  static const String user = 'root'; // Cambiado a root para desarrollo
  static const String password = ''; // Contraseña vacía para desarrollo
  
  // Nombres de tablas
  static const String tablaUsuarios = 'usuarios';
  static const String tablaCitas = 'citas';
  static const String tablaDispositivos = 'dispositivos';
  static const String tablaServicios = 'servicios';
  
  // Roles del sistema
  static const int rolUsuario = 1;
  static const int rolTecnico = 2;
  static const int rolAdministrador = 3;
  
  static String get connectionString =>
      'mysql://$user:$password@$host:$port/$dbName';
}