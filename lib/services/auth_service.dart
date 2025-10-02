import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/usuario.dart';
import '../models/rol.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Login usando tu esquema (sin email, solo usuario/contraseña)
  Future<Usuario?> login(String nombreUsuario, String password) async {
    try {
      // Buscar usuario por nombre/apellido y validar contraseña
      final userData = await _client
          .from('usuario')
          .select('''
            *,
            rol:id_rol (
              id_rol,
              nombre_rol
            )
          ''')
          .or('nombre.ilike.%$nombreUsuario%,apellido.ilike.%$nombreUsuario%')
          .eq('contrasena', password)
          .maybeSingle();

      if (userData != null) {
        // Crear sesión simulada (ya que no usamos Supabase Auth)
        return Usuario.fromJson({
          ...userData,
          'nombre_rol': userData['rol']['nombre_rol'],
        });
      }
      return null;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // Registro usando tu esquema (sin email)
  Future<Usuario?> register({
    required String nombre,
    required String apellido,
    required String password,
    int? idRol,
  }) async {
    try {
      // Verificar si es el primer usuario (será admin automáticamente)
      final existingUsers = await _client.from('usuario').select('id_usuario').limit(1);
      final finalIdRol = idRol ?? (existingUsers.isEmpty ? RolConstants.administrador : RolConstants.cliente);
      
      // Crear usuario directamente en tu tabla
      final userData = await _client.from('usuario').insert({
        'nombre': nombre,
        'apellido': apellido,
        'contrasena': password,
        'id_rol': finalIdRol,
      }).select('''
        *,
        rol:id_rol (
          id_rol,
          nombre_rol
        )
      ''').single();

      return Usuario.fromJson({
        ...userData,
        'nombre_rol': userData['rol']['nombre_rol'],
      });
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  // Variables para mantener sesión local (sin Supabase Auth)
  static Usuario? _currentUser;
  
  Future<Usuario?> getCurrentUserData() async {
    return _currentUser;
  }

  Future<void> logout() async {
    try {
      // Cerrar sesión de Supabase si existe
      if (_client.auth.currentSession != null) {
        await _client.auth.signOut();
      }
    } catch (e) {
      // Ignorar errores ya que limpiaremos la sesión local de todos modos
      print('Error al cerrar sesión de Supabase: $e');
    } finally {
      // Siempre limpiar la sesión local
      _currentUser = null;
    }
  }

  // Método para establecer usuario actual después del login
  void setCurrentUser(Usuario usuario) {
    _currentUser = usuario;
  }

  // Método para cambiar contraseña (usando tu esquema)
  Future<bool> changePassword(int idUsuario, String newPassword) async {
    try {
      await _client
          .from('usuario')
          .update({'contrasena': newPassword})
          .eq('id_usuario', idUsuario);
      return true;
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }

  // Método para cambiar rol de usuario
  Future<bool> changeUserRole(int idUsuario, int newRol) async {
    try {
      await _client
          .from('usuario')
          .update({'id_rol': newRol})
          .eq('id_usuario', idUsuario);
      return true;
    } catch (e) {
      throw Exception('Error al cambiar rol: $e');
    }
  }

  // Método para obtener usuarios (solo para admin)
  Future<List<Usuario>> getAllUsers() async {
    try {
      final response = await _client
          .from('usuario')
          .select('''
            *,
            rol:id_rol (
              id_rol,
              nombre_rol
            )
          ''')
          .order('id_usuario');

      return (response as List).map((json) {
        return Usuario.fromJson({
          ...json,
          'nombre_rol': json['rol']['nombre_rol'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }
}