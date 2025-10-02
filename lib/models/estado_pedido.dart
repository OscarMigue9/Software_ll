class EstadoPedido {
  final int idEstado;
  final String nombreEstado;

  EstadoPedido({
    required this.idEstado,
    required this.nombreEstado,
  });

  factory EstadoPedido.fromJson(Map<String, dynamic> json) {
    return EstadoPedido(
      idEstado: json['id_estado'] as int,
      nombreEstado: json['nombre_estado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_estado': idEstado,
      'nombre_estado': nombreEstado,
    };
  }
}

// Constantes para estados
class EstadoPedidoConstants {
  static const int pendiente = 1;
  static const int confirmado = 2;
  static const int enviado = 3;
  static const int entregado = 4;
  static const int cancelado = 5;
  
  static const String pendienteNombre = 'Pendiente';
  static const String confirmadoNombre = 'Confirmado';
  static const String enviadoNombre = 'Enviado';
  static const String entregadoNombre = 'Entregado';
  static const String canceladoNombre = 'Cancelado';
}