import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

// Estado de productos
class ProductoState {
  final List<Producto> productos;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? categoriaSeleccionada;

  ProductoState({
    this.productos = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.categoriaSeleccionada,
  });

  ProductoState copyWith({
    List<Producto>? productos,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? categoriaSeleccionada,
  }) {
    return ProductoState(
      productos: productos ?? this.productos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
    );
  }

  List<Producto> get productosConStock => 
      productos.where((p) => p.tieneStock).toList();
      
  List<Producto> get productosStockBajo => 
      productos.where((p) => p.stockBajo).toList();
}

// Controller de productos
class ProductoController extends StateNotifier<ProductoState> {
  final ProductoService _productoService;

  ProductoController(this._productoService) : super(ProductoState());

  Future<void> cargarProductos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final productos = await _productoService.obtenerProductos();
      state = state.copyWith(
        productos: productos,
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

  Future<void> buscarProductos(String query) async {
    state = state.copyWith(isLoading: true, searchQuery: query);
    try {
      final productos = query.isEmpty
          ? await _productoService.obtenerProductos()
          : await _productoService.buscarProductos(query);
      state = state.copyWith(
        productos: productos,
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

  Future<void> filtrarPorCategoria(String? categoria) async {
    state = state.copyWith(isLoading: true, categoriaSeleccionada: categoria);
    try {
      final productos = categoria == null
          ? await _productoService.obtenerProductos()
          : await _productoService.obtenerProductosPorCategoria(categoria);
      state = state.copyWith(
        productos: productos,
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

  Future<bool> crearProducto(Producto producto) async {
    try {
      final nuevoProducto = await _productoService.crearProducto(producto);
      final productosActuales = [...state.productos, nuevoProducto];
      state = state.copyWith(productos: productosActuales);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> actualizarProducto(Producto producto) async {
    try {
      final productoActualizado = await _productoService.actualizarProducto(producto);
      final productosActuales = state.productos.map((p) {
        return p.idProducto == productoActualizado.idProducto 
            ? productoActualizado 
            : p;
      }).toList();
      state = state.copyWith(productos: productosActuales);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> eliminarProducto(int idProducto) async {
    try {
      await _productoService.eliminarProducto(idProducto);
      final productosActuales = state.productos
          .where((p) => p.idProducto != idProducto)
          .toList();
      state = state.copyWith(productos: productosActuales);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> cargarProductosStockBajo() async {
    state = state.copyWith(isLoading: true);
    try {
      final productos = await _productoService.obtenerProductosConStockBajo();
      state = state.copyWith(
        productos: productos,
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

  Future<bool> actualizarStock(int idProducto, int nuevoStock) async {
    try {
      await _productoService.actualizarStock(idProducto, nuevoStock);
      await cargarProductos(); // Recargar lista
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
final productoServiceProvider = Provider<ProductoService>((ref) => ProductoService());

final productoControllerProvider = StateNotifierProvider<ProductoController, ProductoState>((ref) {
  final productoService = ref.watch(productoServiceProvider);
  return ProductoController(productoService);
});

final categoriasProvider = FutureProvider<List<String>>((ref) async {
  final productoService = ref.watch(productoServiceProvider);
  return await productoService.obtenerCategorias();
});

final productosStockBajoProvider = FutureProvider<List<Producto>>((ref) async {
  final productoService = ref.watch(productoServiceProvider);
  return await productoService.obtenerProductosConStockBajo();
});