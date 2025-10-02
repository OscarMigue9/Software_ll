import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido.dart';
import '../models/detalle_pedido.dart';
import '../models/estado_pedido.dart';
import 'supabase_service.dart';
import 'producto_service.dart';

class PedidoService {
  final SupabaseClient _client = SupabaseService.instance.client;
  final ProductoService _productoService = ProductoService();

  // REQ-004: Registro de pedidos
  Future<Pedido> crearPedido({
    required int idCliente,
    required List<DetallePedido> detalles,
  }) async {
    try {
      // Validar stock antes de confirmar
      for (final detalle in detalles) {
        final producto = await _productoService.obtenerProductoPorId(detalle.idProducto);
        if (producto == null) {
          throw Exception('Producto con ID ${detalle.idProducto} no encontrado');
        }
        if (producto.stock < detalle.cantidad) {
          throw Exception('Stock insuficiente para ${producto.nombre}. Disponible: ${producto.stock}');
        }
      }

      // Calcular total
      double total = 0;
      for (final detalle in detalles) {
        total += detalle.subtotal;
      }

      // Crear pedido
      final pedidoResponse = await _client
          .from('pedido')
          .insert({
            'id_cliente': idCliente,
            'fecha_creacion': DateTime.now().toIso8601String(),
            'id_estado': EstadoPedidoConstants.pendiente,
            'total': total,
          })
          .select()
          .single();

      final pedidoId = pedidoResponse['id_pedido'] as int;

      // Crear detalles del pedido
      final detallesData = detalles.map((detalle) => {
        'id_pedido': pedidoId,
        'id_producto': detalle.idProducto,
        'cantidad': detalle.cantidad,
        'precio_unitario': detalle.precioUnitario,
      }).toList();

      await _client.from('detalle_pedido').insert(detallesData);

      // Descontar stock automáticamente
      for (final detalle in detalles) {
        await _productoService.reducirStock(detalle.idProducto, detalle.cantidad);
      }

      // Obtener pedido completo
      return await obtenerPedidoPorId(pedidoId) ?? 
          Pedido.fromJson(pedidoResponse);
    } catch (e) {
      throw Exception('Error al crear pedido: $e');
    }
  }

  Future<List<Pedido>> obtenerPedidos({int? idCliente}) async {
    try {
      late final dynamic query;
      
      if (idCliente != null) {
        query = _client
            .from('pedido')
            .select('''
              *,
              usuario:id_cliente (nombre, apellido),
              estado_pedido:id_estado (nombre_estado)
            ''')
            .eq('id_cliente', idCliente)
            .order('fecha_creacion', ascending: false);
      } else {
        query = _client
            .from('pedido')
            .select('''
              *,
              usuario:id_cliente (nombre, apellido),
              estado_pedido:id_estado (nombre_estado)
            ''')
            .order('fecha_creacion', ascending: false);
      }

      final response = await query;

      return (response as List).map((json) {
        return Pedido.fromJson({
          ...json,
          'nombre_cliente': '${json['usuario']['nombre']} ${json['usuario']['apellido']}',
          'nombre_estado': json['estado_pedido']['nombre_estado'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  Future<Pedido?> obtenerPedidoPorId(int idPedido) async {
    try {
      final pedidoResponse = await _client
          .from('pedido')
          .select('''
            *,
            usuario:id_cliente (nombre, apellido),
            estado_pedido:id_estado (nombre_estado)
          ''')
          .eq('id_pedido', idPedido)
          .single();

      final detallesResponse = await _client
          .from('detalle_pedido')
          .select('''
            *,
            producto:id_producto (nombre, sku)
          ''')
          .eq('id_pedido', idPedido);

      final detalles = (detallesResponse as List).map((json) {
        return DetallePedido.fromJson({
          ...json,
          'nombre_producto': json['producto']['nombre'],
          'sku_producto': json['producto']['sku'],
        });
      }).toList();

      return Pedido.fromJson({
        ...pedidoResponse,
        'nombre_cliente': '${pedidoResponse['usuario']['nombre']} ${pedidoResponse['usuario']['apellido']}',
        'nombre_estado': pedidoResponse['estado_pedido']['nombre_estado'],
        'detalles': detalles.map((d) => d.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Error al obtener pedido: $e');
    }
  }

  Future<Pedido> actualizarEstadoPedido(int idPedido, int nuevoEstado) async {
    try {
      final response = await _client
          .from('pedido')
          .update({'id_estado': nuevoEstado})
          .eq('id_pedido', idPedido)
          .select()
          .single();

      return await obtenerPedidoPorId(idPedido) ?? 
          Pedido.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar estado del pedido: $e');
    }
  }

  Future<List<EstadoPedido>> obtenerEstados() async {
    try {
      final response = await _client
          .from('estado_pedido')
          .select()
          .order('id_estado');

      return (response as List)
          .map((json) => EstadoPedido.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener estados: $e');
    }
  }

  Future<void> cancelarPedido(int idPedido) async {
    try {
      // Obtener detalles del pedido para restaurar stock
      final pedido = await obtenerPedidoPorId(idPedido);
      if (pedido == null) {
        throw Exception('Pedido no encontrado');
      }

      if (pedido.esCancelado) {
        throw Exception('El pedido ya está cancelado');
      }

      if (pedido.esEntregado) {
        throw Exception('No se puede cancelar un pedido ya entregado');
      }

      // Restaurar stock si el pedido estaba confirmado
      if (pedido.esConfirmado || pedido.esEnviado) {
        for (final detalle in pedido.detalles ?? []) {
          final producto = await _productoService.obtenerProductoPorId(detalle.idProducto);
          if (producto != null) {
            await _productoService.actualizarStock(
              detalle.idProducto,
              (producto.stock + detalle.cantidad).toInt(),
            );
          }
        }
      }

      // Actualizar estado a cancelado
      await actualizarEstadoPedido(idPedido, EstadoPedidoConstants.cancelado);
    } catch (e) {
      rethrow;
    }
  }

  // Reportes
  Future<Map<String, dynamic>> obtenerReportePedidos({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      var query = _client
          .from('pedido')
          .select('*');

      if (fechaInicio != null) {
        query = query.gte('fecha_creacion', fechaInicio.toIso8601String());
      }
      if (fechaFin != null) {
        query = query.lte('fecha_creacion', fechaFin.toIso8601String());
      }

      final pedidos = await query;

      double totalVentas = 0;
      int totalPedidos = pedidos.length;
      int pedidosCompletados = 0;

      for (final pedido in pedidos) {
        totalVentas += (pedido['total'] as num).toDouble();
        if (pedido['id_estado'] == EstadoPedidoConstants.entregado) {
          pedidosCompletados++;
        }
      }

      return {
        'total_ventas': totalVentas,
        'total_pedidos': totalPedidos,
        'pedidos_completados': pedidosCompletados,
        'tasa_completado': totalPedidos > 0 ? (pedidosCompletados / totalPedidos) * 100 : 0,
      };
    } catch (e) {
      throw Exception('Error al generar reporte: $e');
    }
  }
}