-- INSERTS PARA POBLAR LA BASE DE DATOS CON DATOS DE PRUEBA
-- Ejecuta estos comandos en el SQL Editor de Supabase

-- 1. Estados de pedido
INSERT INTO estado_pedido (id_estado, nombre_estado) VALUES 
(1, 'pendiente'),
(2, 'confirmado'),
(3, 'en_proceso'),
(4, 'enviado'),
(5, 'entregado'),
(6, 'cancelado');

-- 2. Roles (si no existen)
INSERT INTO rol (id_rol, nombre_rol) VALUES 
(1, 'Administrador General'),
(2, 'Vendedor'),
(3, 'Cliente')
ON CONFLICT (id_rol) DO NOTHING;

-- 3. Usuarios de prueba
INSERT INTO usuario (nombre, apellido, contrasena, id_rol) VALUES 
('Samuel', 'Admin', 'admin123', 1),
('María', 'González', 'vendedor123', 2),
('Carlos', 'López', 'vendedor456', 2),
('Ana', 'Martínez', 'cliente123', 3),
('Luis', 'Rodríguez', 'cliente456', 3),
('Carmen', 'Fernández', 'cliente789', 3),
('José', 'García', 'cliente101', 3),
('Laura', 'Sánchez', 'cliente202', 3),
('Miguel', 'Torres', 'vendedor789', 2),
('Sofia', 'Ruiz', 'cliente303', 3);

-- 4. Productos de ejemplo
INSERT INTO producto (sku, nombre, categoria, dimensiones, material, color, precio, costo, stock) VALUES 
-- Muebles
('MES-ROB-001', 'Mesa de Roble Clásica', 'Muebles', '150x90x75cm', 'Madera de Roble', 'Natural', 299.99, 150.00, 25),
('SIL-ERG-001', 'Silla Ergonómica Oficina', 'Muebles', '60x60x120cm', 'Tela y Metal', 'Negro', 89.99, 45.00, 40),
('SOF-MOD-001', 'Sofá Moderno 3 Plazas', 'Muebles', '200x90x85cm', 'Cuero Sintético', 'Gris', 599.99, 300.00, 8),
('EST-LIB-001', 'Estantería para Libros', 'Muebles', '80x30x180cm', 'Madera MDF', 'Blanco', 159.99, 80.00, 15),
('MES-NOC-001', 'Mesa de Noche Moderna', 'Muebles', '40x30x60cm', 'Madera Pino', 'Natural', 79.99, 40.00, 30),

-- Decoración
('LAM-LED-001', 'Lámpara LED de Mesa', 'Decoración', '25x25x45cm', 'Metal y Vidrio', 'Dorado', 45.99, 22.50, 50),
('CUA-ART-001', 'Cuadro Artístico Abstracto', 'Decoración', '60x40x3cm', 'Lienzo y Marco', 'Multicolor', 35.99, 18.00, 20),
('JAR-CER-001', 'Jarrón Cerámico Grande', 'Decoración', '20x20x35cm', 'Cerámica', 'Azul', 28.99, 14.50, 25),
('ESP-DEC-001', 'Espejo Decorativo Redondo', 'Decoración', '50x50x3cm', 'Cristal y Marco Dorado', 'Dorado', 89.99, 45.00, 12),
('ALF-PER-001', 'Alfombra Persa Pequeña', 'Decoración', '120x80x1cm', 'Algodón', 'Rojo', 129.99, 65.00, 18),

-- Cocina
('OLL-PRE-001', 'Olla a Presión 6 Litros', 'Cocina', '25x25x20cm', 'Acero Inoxidable', 'Plateado', 75.99, 38.00, 22),
('SAR-ANT-001', 'Sartén Antiadherente 28cm', 'Cocina', '28x28x5cm', 'Aluminio con Recubrimiento', 'Negro', 32.99, 16.50, 35),
('CUC-CER-001', 'Cuchillo de Cerámica Chef', 'Cocina', '30x3x2cm', 'Cerámica y Mango ABS', 'Blanco', 24.99, 12.50, 40),
('LIC-VIT-001', 'Licuadora de Vidrio 1.5L', 'Cocina', '20x20x35cm', 'Vidrio y Motor', 'Transparente', 89.99, 45.00, 15),
('TAB-COR-001', 'Tabla de Cortar Bambú', 'Cocina', '35x25x2cm', 'Bambú Natural', 'Natural', 19.99, 10.00, 60),

-- Dormitorio
('ALM-MEM-001', 'Almohada Memory Foam', 'Dormitorio', '70x40x12cm', 'Espuma Viscoelástica', 'Blanco', 49.99, 25.00, 45),
('COB-ALG-001', 'Cobertor de Algodón Queen', 'Dormitorio', '220x240x5cm', 'Algodón 100%', 'Azul Marino', 79.99, 40.00, 20),
('LAM-NOC-001', 'Lámpara de Noche LED', 'Dormitorio', '15x15x30cm', 'Metal y Tela', 'Blanco', 39.99, 20.00, 30),
('GAV-ROP-001', 'Gaveta Organizadora Ropa', 'Dormitorio', '40x30x15cm', 'Tela No Tejida', 'Gris', 15.99, 8.00, 50),
('REL-DES-001', 'Reloj Despertador Digital', 'Dormitorio', '10x8x5cm', 'Plástico ABS', 'Negro', 22.99, 11.50, 40);

-- 5. Pedidos de ejemplo (últimos 30 días)
-- Pedidos de hace 1 semana
INSERT INTO pedido (id_cliente, fecha_creacion, id_estado, total) VALUES 
(4, '2025-09-24 10:30:00', 5, 299.99), -- Ana Martínez - Mesa de Roble
(5, '2025-09-24 14:15:00', 5, 175.98), -- Luis Rodríguez - 2 Sillas Ergonómicas  
(6, '2025-09-25 09:45:00', 4, 89.99),   -- Carmen Fernández - Espejo Decorativo
(7, '2025-09-25 16:20:00', 4, 108.98),  -- José García - Olla + Sartén
(8, '2025-09-26 11:10:00', 3, 45.99);   -- Laura Sánchez - Lámpara LED

-- Pedidos de hace 3 días
INSERT INTO pedido (id_cliente, fecha_creacion, id_estado, total) VALUES 
(4, '2025-09-28 08:30:00', 3, 599.99),  -- Ana Martínez - Sofá Moderno
(10, '2025-09-28 13:45:00', 2, 159.99), -- Sofia Ruiz - Estantería
(5, '2025-09-29 10:15:00', 2, 129.98),  -- Luis Rodríguez - Alfombra + Jarrón
(6, '2025-09-29 15:30:00', 1, 79.99);   -- Carmen Fernández - Mesa de Noche

-- Pedidos de hoy
INSERT INTO pedido (id_cliente, fecha_creacion, id_estado, total) VALUES 
(7, CURRENT_TIMESTAMP - INTERVAL '2 hours', 1, 89.99),  -- José García - Licuadora
(8, CURRENT_TIMESTAMP - INTERVAL '1 hour', 1, 149.98), -- Laura Sánchez - Almohada + Cobertor  
(10, CURRENT_TIMESTAMP - INTERVAL '30 minutes', 1, 75.99); -- Sofia Ruiz - Olla a Presión

-- 6. Detalles de pedidos
-- Para pedido 1 (Mesa de Roble)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(1, 1, 1, 299.99);

-- Para pedido 2 (2 Sillas)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(2, 2, 2, 89.99);

-- Para pedido 3 (Espejo)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(3, 9, 1, 89.99);

-- Para pedido 4 (Olla + Sartén)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(4, 11, 1, 75.99),
(4, 12, 1, 32.99);

-- Para pedido 5 (Lámpara LED)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(5, 6, 1, 45.99);

-- Para pedido 6 (Sofá)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(6, 3, 1, 599.99);

-- Para pedido 7 (Estantería)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(7, 4, 1, 159.99);

-- Para pedido 8 (Alfombra + Jarrón)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(8, 10, 1, 129.99),
(8, 8, 1, 28.99);

-- Para pedido 9 (Mesa de Noche)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(9, 5, 1, 79.99);

-- Para pedido 10 (Licuadora)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(10, 14, 1, 89.99);

-- Para pedido 11 (Almohada + Cobertor)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(11, 16, 1, 49.99),
(11, 17, 1, 79.99);

-- Para pedido 12 (Olla a Presión)
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES 
(12, 11, 1, 75.99);

-- Actualizar stock después de las ventas
UPDATE producto SET stock = stock - 1 WHERE id_producto = 1; -- Mesa de Roble
UPDATE producto SET stock = stock - 2 WHERE id_producto = 2; -- Sillas (2 unidades)
UPDATE producto SET stock = stock - 1 WHERE id_producto = 9; -- Espejo
UPDATE producto SET stock = stock - 2 WHERE id_producto = 11; -- Olla (2 pedidos)
UPDATE producto SET stock = stock - 1 WHERE id_producto = 12; -- Sartén
UPDATE producto SET stock = stock - 1 WHERE id_producto = 6; -- Lámpara LED
UPDATE producto SET stock = stock - 1 WHERE id_producto = 3; -- Sofá
UPDATE producto SET stock = stock - 1 WHERE id_producto = 4; -- Estantería
UPDATE producto SET stock = stock - 1 WHERE id_producto = 10; -- Alfombra
UPDATE producto SET stock = stock - 1 WHERE id_producto = 8; -- Jarrón
UPDATE producto SET stock = stock - 1 WHERE id_producto = 5; -- Mesa de Noche
UPDATE producto SET stock = stock - 1 WHERE id_producto = 14; -- Licuadora
UPDATE producto SET stock = stock - 1 WHERE id_producto = 16; -- Almohada
UPDATE producto SET stock = stock - 1 WHERE id_producto = 17; -- Cobertor

-- CONSULTAS ÚTILES PARA VERIFICAR LOS DATOS:

-- Ver todos los usuarios y sus roles
-- SELECT u.nombre, u.apellido, r.nombre_rol FROM usuario u JOIN rol r ON u.id_rol = r.id_rol;

-- Ver productos con stock bajo
-- SELECT nombre, stock FROM producto WHERE stock <= 10 ORDER BY stock;

-- Ver ventas del mes actual
-- SELECT COUNT(*) as total_pedidos, SUM(total) as total_ventas FROM pedido WHERE DATE_TRUNC('month', fecha_creacion) = DATE_TRUNC('month', CURRENT_DATE);

-- Ver actividad reciente
-- SELECT 'Pedido' as tipo, CONCAT('Pedido #', p.id_pedido, ' por $', p.total) as descripcion, p.fecha_creacion FROM pedido p ORDER BY fecha_creacion DESC LIMIT 5;