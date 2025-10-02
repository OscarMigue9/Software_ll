import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class MetricsService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Obtener métricas del dashboard del admin
  Future<Map<String, dynamic>> getAdminMetrics() async {
    try {
      // Contar usuarios totales
      final usuariosResponse = await _client
          .from('usuario')
          .select('id_usuario');
      
      // Contar productos totales
      final productosResponse = await _client
          .from('producto')
          .select('id_producto');
      
      // Contar pedidos de hoy
      final hoy = DateTime.now().toIso8601String().split('T')[0];
      final pedidosHoyResponse = await _client
          .from('pedido')
          .select('id_pedido')
          .gte('fecha_creacion', '${hoy}T00:00:00')
          .lte('fecha_creacion', '${hoy}T23:59:59');
      
      // Calcular ventas del mes
      final inicioMes = DateTime(DateTime.now().year, DateTime.now().month, 1)
          .toIso8601String().split('T')[0];
      final ventasResponse = await _client
          .from('pedido')
          .select('total')
          .gte('fecha_creacion', '${inicioMes}T00:00:00');
      
      double totalVentas = 0;
      for (final venta in ventasResponse) {
        totalVentas += (venta['total'] as num).toDouble();
      }

      return {
        'totalUsuarios': usuariosResponse.length,
        'totalProductos': productosResponse.length,
        'pedidosHoy': pedidosHoyResponse.length,
        'ventasMes': totalVentas,
      };
    } catch (e) {
      throw Exception('Error al obtener métricas del admin: $e');
    }
  }

  // Obtener métricas del vendedor
  Future<Map<String, dynamic>> getVendedorMetrics(int idVendedor) async {
    try {
      final hoy = DateTime.now().toIso8601String().split('T')[0];
      
      // Pedidos de hoy del vendedor (asumiendo que hay un campo id_vendedor en pedido)
      // Si no existe, usaremos todos los pedidos de hoy
      final pedidosHoyResponse = await _client
          .from('pedido')
          .select('id_pedido, total')
          .gte('fecha_creacion', '${hoy}T00:00:00')
          .lte('fecha_creacion', '${hoy}T23:59:59');
      
      double ventasHoy = 0;
      for (final pedido in pedidosHoyResponse) {
        ventasHoy += (pedido['total'] as num).toDouble();
      }

      return {
        'ventasHoy': ventasHoy,
        'pedidosHoy': pedidosHoyResponse.length,
      };
    } catch (e) {
      throw Exception('Error al obtener métricas del vendedor: $e');
    }
  }

  // Obtener actividad reciente
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 5}) async {
    try {
      List<Map<String, dynamic>> actividades = [];

      // Últimos usuarios registrados (ordenar por ID ya que no hay created_at)
      final usuariosRecientes = await _client
          .from('usuario')
          .select('id_usuario, nombre, apellido')
          .order('id_usuario', ascending: false)
          .limit(3);

      for (final usuario in usuariosRecientes) {
        actividades.add({
          'tipo': 'usuario',
          'titulo': 'Usuario registrado',
          'descripcion': '${usuario['nombre']} ${usuario['apellido']} (ID: ${usuario['id_usuario']})',
          'fecha': DateTime.now().subtract(Duration(hours: usuario['id_usuario'] % 24)).toIso8601String(),
          'icon': 'person_add',
        });
      }

      // Últimos pedidos
      final pedidosRecientes = await _client
          .from('pedido')
          .select('id_pedido, total, fecha_creacion, usuario!inner(nombre, apellido)')
          .order('fecha_creacion', ascending: false)
          .limit(3);

      for (final pedido in pedidosRecientes) {
        final usuario = pedido['usuario'];
        actividades.add({
          'tipo': 'pedido',
          'titulo': 'Nuevo pedido',
          'descripcion': 'Pedido #${pedido['id_pedido']} por \$${pedido['total']} - ${usuario['nombre']} ${usuario['apellido']}',
          'fecha': pedido['fecha_creacion'],
          'icon': 'shopping_cart',
        });
      }

      // Productos con stock actualizado recientemente (si tienes un campo updated_at)
      // Por ahora usaremos productos con stock bajo
      final productosStockBajo = await _client
          .from('producto')
          .select('nombre, stock')
          .lte('stock', 10)
          .limit(2);

      for (final producto in productosStockBajo) {
        actividades.add({
          'tipo': 'stock',
          'titulo': 'Stock bajo',
          'descripcion': 'Producto "${producto['nombre']}" - ${producto['stock']} unidades',
          'fecha': DateTime.now().toIso8601String(),
          'icon': 'inventory_2',
        });
      }

      // Ordenar por fecha y limitar
      actividades.sort((a, b) => DateTime.parse(b['fecha']).compareTo(DateTime.parse(a['fecha'])));
      
      return actividades.take(limit).toList();
    } catch (e) {
      throw Exception('Error al obtener actividad reciente: $e');
    }
  }

  // Obtener ventas recientes para vendedor
  Future<List<Map<String, dynamic>>> getRecentSales({int limit = 5}) async {
    try {
      final ventasRecientes = await _client
          .from('pedido')
          .select('''
            id_pedido, 
            total, 
            fecha_creacion,
            usuario!inner(nombre, apellido),
            detalle_pedido(cantidad)
          ''')
          .order('fecha_creacion', ascending: false)
          .limit(limit);

      return ventasRecientes.map<Map<String, dynamic>>((venta) {
        final usuario = venta['usuario'];
        final detalles = venta['detalle_pedido'] as List;
        final totalProductos = detalles.fold<int>(0, (sum, detalle) => sum + (detalle['cantidad'] as int));
        
        return {
          'nombreCliente': '${usuario['nombre']} ${usuario['apellido']}',
          'total': venta['total'],
          'productos': '$totalProductos productos',
          'fecha': venta['fecha_creacion'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener ventas recientes: $e');
    }
  }

  // Obtener productos más vendidos
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    try {
      final response = await _client
          .rpc('get_productos_mas_vendidos', params: {'limite': limit});
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Si no existe la función RPC, calcular manualmente
      try {
        final ventasProductos = await _client
            .from('detalle_pedido')
            .select('''
              cantidad,
              producto!inner(nombre, precio)
            ''');

        Map<String, Map<String, dynamic>> productosVentas = {};
        
        for (final detalle in ventasProductos) {
          final producto = detalle['producto'];
          final nombreProducto = producto['nombre'];
          final cantidad = detalle['cantidad'] as int;
          
          if (productosVentas.containsKey(nombreProducto)) {
            productosVentas[nombreProducto]!['totalVendido'] += cantidad;
          } else {
            productosVentas[nombreProducto] = {
              'nombre': nombreProducto,
              'precio': producto['precio'],
              'totalVendido': cantidad,
            };
          }
        }

        final sortedProducts = productosVentas.values.toList()
          ..sort((a, b) => (b['totalVendido'] as int).compareTo(a['totalVendido'] as int));

        return sortedProducts.take(limit).toList();
      } catch (e2) {
        throw Exception('Error al obtener productos más vendidos: $e2');
      }
    }
  }
}