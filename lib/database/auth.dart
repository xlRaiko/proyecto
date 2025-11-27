import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/database/config.dart';
import 'package:proyecto/database/database_helper.dart';
import 'package:proyecto/database/modelos/usuario_modelo.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Registrar usuario
  Future<User?> registrarConEmailYContrasena(
      String email, String contrasena, String nombre, String telefono) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential credencial = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: contrasena);

      // Guardar usuario en base de datos local
      if (credencial.user != null) {
        final usuario = Usuario(
          id: 0, // Se autoincrementa en la BD
          correo: email,
          contrasena: contrasena, // En una app real, debería estar encriptada
          nombre: nombre,
          telefono: telefono,
          rol: DatabaseConfig.rolUsuario, // Rol por defecto
          fechaCreacion: DateTime.now(),
        );

        final usuarioId = await _databaseHelper.insertarUsuario(usuario);
        if (usuarioId > 0) {
          print('Usuario guardado en BD local con ID: $usuarioId');
        } else {
          print('Error al guardar usuario en BD local');
        }
      }

      return credencial.user;
    } on FirebaseAuthException catch (e) {
      print('Error en registro Firebase: ${e.message}');
      return null;
    } catch (e) {
      print('Error general en registro: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<User?> iniciarSesionConEmailYContrasena(
      String email, String contrasena) async {
    try {
      UserCredential credencial = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: contrasena);
      
      // Verificar si el usuario existe en la BD local, si no existe, crearlo
      if (credencial.user != null) {
        final usuarioExistente = await _databaseHelper.obtenerUsuarioPorEmail(email);
        if (usuarioExistente == null) {
          // Crear usuario en BD local si no existe
          final usuario = Usuario(
            id: 0,
            correo: email,
            contrasena: contrasena,
            nombre: credencial.user?.displayName ?? 'Usuario',
            telefono: credencial.user?.phoneNumber ?? '',
            rol: DatabaseConfig.rolUsuario,
            fechaCreacion: DateTime.now(),
          );
          await _databaseHelper.insertarUsuario(usuario);
          print('Usuario creado en BD local durante el login');
        }
      }
      
      return credencial.user;
    } on FirebaseAuthException catch (e) {
      print('Error en login: ${e.message}');
      return null;
    }
  }

  // Obtener usuario local por email
  Future<Usuario?> obtenerUsuarioLocal(String correo) async {
    return await _databaseHelper.obtenerUsuarioPorEmail(correo);
  }

  // Obtener usuario local actual
  Future<Usuario?> obtenerUsuarioActual() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return await _databaseHelper.obtenerUsuarioPorEmail(user.email!);
    }
    return null;
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _firebaseAuth.signOut();
  }

  // Verificar estado de autenticación
  Stream<User?> get cambiosEstadoAuth {
    return _firebaseAuth.authStateChanges();
  }
}