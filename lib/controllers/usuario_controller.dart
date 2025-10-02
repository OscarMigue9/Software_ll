import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario.dart';
import '../models/rol.dart';
import '../services/usuario_service.dart';

// Estado de usuarios
class UsuarioState {
  final List<Usuario> usuarios;
  final List<Rol> roles;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final Map<String, int>? estadisticas;

  UsuarioState({
    this.usuarios = const [],
    this.roles = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.estadisticas,
  });

  UsuarioState copyWith({
    List<Usuario>? usuarios,
    List<Rol>? roles,
    bool? isLoading,
    String? error,
    String? searchQuery,
    Map<String, int>? estadisticas,
  }) {
    return UsuarioState(
      usuarios: usuarios ?? this.usuarios,
      roles: roles ?? this.roles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      estadisticas: estadisticas ?? this.estadisticas,
    );
  }

  List<Usuario> get administradores => 
      usuarios.where((u) => u.idRol == 1).toList();
  
  List<Usuario> get vendedores => 
      usuarios.where((u) => u.idRol == 2).toList();
  
  List<Usuario> get clientes => 
      usuarios.where((u) => u.idRol == 3).toList();
}

// Controller de usuarios
class UsuarioController extends StateNotifier<UsuarioState> {
  final UsuarioService _usuarioService;

  UsuarioController(this._usuarioService) : super(UsuarioState());

  Future<void> cargarUsuarios() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usuarios = await _usuarioService.obtenerUsuarios();
      final roles = await _usuarioService.obtenerRoles();
      final estadisticas = await _usuarioService.obtenerEstadisticasUsuarios();
      
      state = state.copyWith(
        usuarios: usuarios,
        roles: roles,
        estadisticas: estadisticas,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> buscarUsuarios(String query) async {
    state = state.copyWith(isLoading: true, searchQuery: query);
    try {
      final usuarios = query.isEmpty
          ? await _usuarioService.obtenerUsuarios()
          : await _usuarioService.buscarUsuarios(query);
      
      state = state.copyWith(
        usuarios: usuarios,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> crearUsuario(Usuario usuario) async {
    try {
      final nuevoUsuario = await _usuarioService.crearUsuario(usuario);
      final usuariosActuales = [...state.usuarios, nuevoUsuario];
      state = state.copyWith(usuarios: usuariosActuales);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> actualizarUsuario(Usuario usuario) async {
    try {
      final usuarioActualizado = await _usuarioService.actualizarUsuario(usuario);
      final usuariosActuales = state.usuarios.map((u) {
        return u.idUsuario == usuarioActualizado.idUsuario 
            ? usuarioActualizado 
            : u;
      }).toList();
      state = state.copyWith(usuarios: usuariosActuales);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> eliminarUsuario(int idUsuario) async {
    try {
      await _usuarioService.eliminarUsuario(idUsuario);
      final usuariosActuales = state.usuarios
          .where((u) => u.idUsuario != idUsuario)
          .toList();
      state = state.copyWith(usuarios: usuariosActuales);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> cambiarContrasena(int idUsuario, String nuevaContrasena) async {
    try {
      await _usuarioService.cambiarContrasena(idUsuario, nuevaContrasena);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final usuarioServiceProvider = Provider<UsuarioService>((ref) => UsuarioService());

final usuarioControllerProvider = StateNotifierProvider<UsuarioController, UsuarioState>((ref) {
  final usuarioService = ref.watch(usuarioServiceProvider);
  return UsuarioController(usuarioService);
});

final rolesProvider = FutureProvider<List<Rol>>((ref) async {
  final usuarioService = ref.watch(usuarioServiceProvider);
  return await usuarioService.obtenerRoles();
});