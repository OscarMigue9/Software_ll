import 'detalle_pedido.dart';

class Pedido {
  final int? idPedido;
  final int idCliente;
  final DateTime fechaCreacion;
  final int idEstado;
  final double total;
  final String? nombreCliente;
  final String? nombreEstado;
  final List<DetallePedido>? detalles;

  Pedido({
    this.idPedido,
    required this.idCliente,
    required this.fechaCreacion,
    required this.idEstado,
    required this.total,
    this.nombreCliente,
    this.nombreEstado,
    this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      idPedido: json['id_pedido'] as int?,
      idCliente: json['id_cliente'] as int,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      idEstado: json['id_estado'] as int,
      total: (json['total'] as num).toDouble(),
      nombreCliente: json['nombre_cliente'] as String?,
      nombreEstado: json['nombre_estado'] as String?,
      detalles: json['detalles'] != null
          ? (json['detalles'] as List)
              .map((d) => DetallePedido.fromJson(d))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pedido': idPedido,
      'id_cliente': idCliente,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'id_estado': idEstado,
      'total': total,
    };
  }

  String get fechaFormateada {
    return '${fechaCreacion.day}/${fechaCreacion.month}/${fechaCreacion.year}';
  }
  
  bool get esPendiente => idEstado == 1;
  bool get esConfirmado => idEstado == 2;
  bool get esEnviado => idEstado == 3;
  bool get esEntregado => idEstado == 4;
  bool get esCancelado => idEstado == 5;
}