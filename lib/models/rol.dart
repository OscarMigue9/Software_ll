class Rol {
  final int idRol;
  final String nombreRol;

  Rol({
    required this.idRol,
    required this.nombreRol,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['id_rol'] as int,
      nombreRol: json['nombre_rol'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_rol': idRol,
      'nombre_rol': nombreRol,
    };
  }
}

// Constantes para roles
class RolConstants {
  static const int administrador = 1;
  static const int vendedor = 2;
  static const int cliente = 3;
  
  static const String administradorNombre = 'Administrador General';
  static const String vendedorNombre = 'Vendedor';
  static const String clienteNombre = 'Cliente';
}