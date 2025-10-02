class Producto {
  final int? idProducto;
  final String sku;
  final String nombre;
  final String categoria;
  final String? dimensiones;
  final String? material;
  final String? color;
  final double precio;
  final double? costo;
  final int stock;

  Producto({
    this.idProducto,
    required this.sku,
    required this.nombre,
    required this.categoria,
    this.dimensiones,
    this.material,
    this.color,
    required this.precio,
    this.costo,
    required this.stock,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['id_producto'] as int?,
      sku: json['sku'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String,
      dimensiones: json['dimensiones'] as String?,
      material: json['material'] as String?,
      color: json['color'] as String?,
      precio: (json['precio'] as num).toDouble(),
      costo: json['costo'] != null ? (json['costo'] as num).toDouble() : null,
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_producto': idProducto,
      'sku': sku,
      'nombre': nombre,
      'categoria': categoria,
      'dimensiones': dimensiones,
      'material': material,
      'color': color,
      'precio': precio,
      'costo': costo,
      'stock': stock,
    };
  }

  bool get tieneStock => stock > 0;
  bool get stockBajo => stock <= 5;
  
  String get descripcionCompleta {
    List<String> detalles = [];
    if (material != null) detalles.add('Material: $material');
    if (color != null) detalles.add('Color: $color');
    if (dimensiones != null) detalles.add('Dimensiones: $dimensiones');
    return detalles.join(' • ');
  }
}