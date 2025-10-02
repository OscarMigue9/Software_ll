import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';
import 'supabase_service.dart';

class ProductoService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // REQ-002: CRUD sobre tabla producto
  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await _client
          .from('producto')
          .select()
          .order('nombre');

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  Future<Producto?> obtenerProductoPorId(int id) async {
    try {
      final response = await _client
          .from('producto')
          .select()
          .eq('id_producto', id)
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  Future<List<Producto>> buscarProductos(String query) async {
    try {
      final response = await _client
          .from('producto')
          .select()
          .or('nombre.ilike.%$query%,sku.ilike.%$query%,categoria.ilike.%$query%')
          .order('nombre');

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }

  Future<List<Producto>> obtenerProductosPorCategoria(String categoria) async {
    try {
      final response = await _client
          .from('producto')
          .select()
          .eq('categoria', categoria)
          .order('nombre');

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  Future<Producto> crearProducto(Producto producto) async {
    try {
      // Validar SKU único
      final existingSku = await _client
          .from('producto')
          .select('sku')
          .eq('sku', producto.sku);

      if (existingSku.isNotEmpty) {
        throw Exception('El SKU ${producto.sku} ya existe');
      }

      final response = await _client
          .from('producto')
          .insert(producto.toJson())
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      if (e.toString().contains('ya existe')) {
        rethrow;
      }
      throw Exception('Error al crear producto: $e');
    }
  }

  Future<Producto> actualizarProducto(Producto producto) async {
    try {
      if (producto.idProducto == null) {
        throw Exception('ID de producto requerido para actualizar');
      }

      // Validar SKU único (excluyendo el producto actual)
      final existingSku = await _client
          .from('producto')
          .select('id_producto, sku')
          .eq('sku', producto.sku)
          .neq('id_producto', producto.idProducto!);

      if (existingSku.isNotEmpty) {
        throw Exception('El SKU ${producto.sku} ya existe en otro producto');
      }

      final response = await _client
          .from('producto')
          .update(producto.toJson())
          .eq('id_producto', producto.idProducto!)
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      if (e.toString().contains('ya existe')) {
        rethrow;
      }
      throw Exception('Error al actualizar producto: $e');
    }
  }

  Future<void> eliminarProducto(int idProducto) async {
    try {
      // Verificar si el producto tiene pedidos asociados
      final pedidosAsociados = await _client
          .from('detalle_pedido')
          .select('id_detalle')
          .eq('id_producto', idProducto);

      if (pedidosAsociados.isNotEmpty) {
        throw Exception('No se puede eliminar el producto porque tiene pedidos asociados');
      }

      await _client
          .from('producto')
          .delete()
          .eq('id_producto', idProducto);
    } catch (e) {
      if (e.toString().contains('pedidos asociados')) {
        rethrow;
      }
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // REQ-003: Gestión de stock
  Future<List<Producto>> obtenerProductosConStockBajo({int limite = 5}) async {
    try {
      final response = await _client
          .from('producto')
          .select()
          .lte('stock', limite)
          .order('stock');

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos con stock bajo: $e');
    }
  }

  Future<bool> actualizarStock(int idProducto, int nuevoStock) async {
    try {
      await _client
          .from('producto')
          .update({'stock': nuevoStock})
          .eq('id_producto', idProducto);
      
      return true;
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }

  Future<bool> reducirStock(int idProducto, int cantidad) async {
    try {
      // Obtener stock actual
      final producto = await obtenerProductoPorId(idProducto);
      if (producto == null) {
        throw Exception('Producto no encontrado');
      }

      if (producto.stock < cantidad) {
        throw Exception('Stock insuficiente. Disponible: ${producto.stock}');
      }

      final nuevoStock = producto.stock - cantidad;
      return await actualizarStock(idProducto, nuevoStock);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> obtenerCategorias() async {
    try {
      final response = await _client
          .from('producto')
          .select('categoria')
          .order('categoria');

      final categorias = <String>{};
      for (final item in response) {
        categorias.add(item['categoria'] as String);
      }

      return categorias.toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }
}