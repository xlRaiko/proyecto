import 'package:path/path.dart';
import 'package:proyecto/database/config.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DatabaseConfig.dbName);
    return await openDatabase(
      path,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConfig.tablaUsuarios}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correo TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL,
        nombre TEXT NOT NULL,
        telefono TEXT,
        rol INTEGER DEFAULT ${DatabaseConfig.rolUsuario},
        fecha_creacion TEXT NOT NULL
      )
    ''');
  }

  // Insertar usuario
  Future<int> insertarUsuario(Usuario usuario) async {
    try {
      final db = await database;
      return await db.insert(
        DatabaseConfig.tablaUsuarios, 
        usuario.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
      );
    } catch (e) {
      print('Error insertando usuario en BD local: $e');
      return -1;
    }
  }

  // Obtener usuario por email
  Future<Usuario?> obtenerUsuarioPorEmail(String correo) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConfig.tablaUsuarios,
        where: 'correo = ?',
        whereArgs: [correo],
      );

      if (maps.isNotEmpty) {
        return Usuario.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario por email: $e');
      return null;
    }
  }

  // Obtener usuario por ID
  Future<Usuario?> obtenerUsuarioPorId(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConfig.tablaUsuarios,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Usuario.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  // Verificar si existe un usuario
  Future<bool> usuarioExiste(String correo) async {
    final usuario = await obtenerUsuarioPorEmail(correo);
    return usuario != null;
  }

  // Actualizar usuario
  Future<int> actualizarUsuario(Usuario usuario) async {
    try {
      final db = await database;
      return await db.update(
        DatabaseConfig.tablaUsuarios,
        usuario.toMap(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
    } catch (e) {
      print('Error actualizando usuario: $e');
      return -1;
    }
  }

  // Eliminar usuario
  Future<int> eliminarUsuario(int id) async {
    try {
      final db = await database;
      return await db.delete(
        DatabaseConfig.tablaUsuarios,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error eliminando usuario: $e');
      return -1;
    }
  }

  // Obtener todos los usuarios (útil para administradores)
  Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(DatabaseConfig.tablaUsuarios);
      return List.generate(maps.length, (i) {
        return Usuario.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error obteniendo todos los usuarios: $e');
      return [];
    }
  }

  // Cerrar la base de datos
  Future<void> cerrar() async {
    final db = await database;
    await db.close();
  }
}