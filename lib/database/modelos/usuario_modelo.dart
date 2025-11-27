import 'package:proyecto/database/config.dart';

class Usuario {
  final int id;
  final String correo;
  final String contrasena;
  final String nombre;
  final String telefono;
  final int rol;
  final DateTime fechaCreacion;

  Usuario({
    required this.id,
    required this.correo,
    required this.contrasena,
    required this.nombre,
    required this.telefono,
    required this.rol,
    required this.fechaCreacion,
  });

  factory Usuario.fromMap(Map<String, dynamic> mapa) {
    return Usuario(
      id: mapa['id'],
      correo: mapa['correo'],
      contrasena: mapa['contrasena'],
      nombre: mapa['nombre'],
      telefono: mapa['telefono'],
      rol: mapa['rol'],
      fechaCreacion: DateTime.parse(mapa['fecha_creacion']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'correo': correo,
      'contrasena': contrasena,
      'nombre': nombre,
      'telefono': telefono,
      'rol': rol,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  bool get esTecnico => rol >= DatabaseConfig.rolTecnico;
  bool get esAdministrador => rol == DatabaseConfig.rolAdministrador;
  bool get esUsuarioNormal => rol == DatabaseConfig.rolUsuario;

  String get nombreRol {
    switch (rol) {
      case DatabaseConfig.rolAdministrador:
        return 'Administrador';
      case DatabaseConfig.rolTecnico:
        return 'Técnico';
      default:
        return 'Usuario';
    }
  }
}