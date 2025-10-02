-- SCRIPT SQL EXACTO DE TU ESQUEMA - InventarioApp
-- Ejecuta este script completo en el SQL Editor de Supabase

-- Roles
CREATE TABLE IF NOT EXISTS public.rol (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL
);

-- Insertar roles iniciales
INSERT INTO public.rol (nombre_rol) VALUES 
    ('Administrador General'),
    ('Vendedor'),
    ('Cliente')
ON CONFLICT (nombre_rol) DO NOTHING;

-- Usuarios (tu esquema exacto)
CREATE TABLE IF NOT EXISTS public.usuario (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL REFERENCES public.rol(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 3. Productos (tu esquema)
CREATE TABLE IF NOT EXISTS public.producto (
    id_producto SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    categoria VARCHAR(100),
    dimensiones VARCHAR(100),
    material VARCHAR(100),
    color VARCHAR(50),
    precio NUMERIC(12,2) CHECK (precio >= 0) NOT NULL,
    costo NUMERIC(12,2) CHECK (costo >= 0) NOT NULL,
    stock INT CHECK (stock >= 0) DEFAULT 0 NOT NULL
);

-- 4. Estados (todos los catálogos de tu esquema)
CREATE TABLE IF NOT EXISTS public.estado_pedido (
    id_estado SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.estado_soporte (
    id_estado SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS public.estado_notificacion (
    id_estado SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) UNIQUE NOT NULL
);

-- Insertar estados iniciales
INSERT INTO public.estado_pedido (nombre_estado) VALUES 
    ('Pendiente'),
    ('Confirmado'),
    ('Enviado'),
    ('Entregado'),
    ('Cancelado')
ON CONFLICT (nombre_estado) DO NOTHING;

INSERT INTO public.estado_soporte (nombre_estado) VALUES 
    ('Abierto'),
    ('En proceso'),
    ('Resuelto'),
    ('Cerrado')
ON CONFLICT (nombre_estado) DO NOTHING;

INSERT INTO public.estado_notificacion (nombre_estado) VALUES 
    ('No leída'),
    ('Leída'),
    ('Archivada')
ON CONFLICT (nombre_estado) DO NOTHING;

-- 5. Pedidos (tu esquema)
CREATE TABLE IF NOT EXISTS public.pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES public.usuario(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    fecha_creacion TIMESTAMP DEFAULT now() NOT NULL,
    id_estado INT NOT NULL REFERENCES public.estado_pedido(id_estado),
    total NUMERIC(14,2) CHECK (total >= 0) NOT NULL
);

-- 6. Detalles de pedidos (tu esquema)
CREATE TABLE IF NOT EXISTS public.detalle_pedido (
    id_detalle SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL REFERENCES public.pedido(id_pedido) ON DELETE CASCADE,
    id_producto INT NOT NULL REFERENCES public.producto(id_producto) ON DELETE RESTRICT,
    cantidad INT CHECK (cantidad > 0) NOT NULL,
    precio_unitario NUMERIC(12,2) CHECK (precio_unitario >= 0) NOT NULL
);

-- 7. Tablas adicionales de tu esquema
CREATE TABLE IF NOT EXISTS public.ajuste_inventario (
    id_ajuste SERIAL PRIMARY KEY,
    id_producto INT NOT NULL REFERENCES public.producto(id_producto) ON DELETE RESTRICT,
    id_responsable INT NOT NULL REFERENCES public.usuario(id_usuario) ON DELETE RESTRICT,
    fecha TIMESTAMP DEFAULT now() NOT NULL,
    motivo TEXT NOT NULL,
    cantidad_ajustada INT NOT NULL
);

CREATE TABLE IF NOT EXISTS public.notificacion (
    id_notificacion SERIAL PRIMARY KEY,
    tipo VARCHAR(100) NOT NULL,
    fecha TIMESTAMP DEFAULT now() NOT NULL,
    id_usuario_destino INT NOT NULL REFERENCES public.usuario(id_usuario) ON DELETE CASCADE,
    id_estado INT NOT NULL REFERENCES public.estado_notificacion(id_estado)
);

CREATE TABLE IF NOT EXISTS public.soporte (
    id_ticket SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES public.usuario(id_usuario) ON DELETE RESTRICT,
    id_pedido INT NOT NULL REFERENCES public.pedido(id_pedido) ON DELETE CASCADE,
    fecha TIMESTAMP DEFAULT now() NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('asistencia', 'reclamo')) NOT NULL,
    descripcion TEXT NOT NULL,
    id_estado INT NOT NULL REFERENCES public.estado_soporte(id_estado)
);

-- INDICES (tu esquema + algunos adicionales)
CREATE INDEX IF NOT EXISTS idx_pedido_cliente ON public.pedido(id_cliente);
CREATE INDEX IF NOT EXISTS idx_detalle_pedido_pedido ON public.detalle_pedido(id_pedido);
CREATE INDEX IF NOT EXISTS idx_detalle_pedido_producto ON public.detalle_pedido(id_producto);
CREATE INDEX IF NOT EXISTS idx_soporte_cliente ON public.soporte(id_cliente);
-- Índices adicionales útiles
CREATE INDEX IF NOT EXISTS idx_usuario_email ON public.usuario(email);
CREATE INDEX IF NOT EXISTS idx_producto_sku ON public.producto(sku);

-- TRIGGERS PARA ACTUALIZAR updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_usuario_updated_at BEFORE UPDATE ON public.usuario
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_producto_updated_at BEFORE UPDATE ON public.producto
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- POLITICAS RLS (Row Level Security)
-- Habilitar RLS en todas las tablas
ALTER TABLE public.usuario ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.producto ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedido ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_pedido ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios (los usuarios pueden ver y editar su propia información)
CREATE POLICY "Usuarios pueden ver su propia información" ON public.usuario
    FOR SELECT USING (auth.email() = email);

CREATE POLICY "Usuarios pueden actualizar su propia información" ON public.usuario
    FOR UPDATE USING (auth.email() = email);

-- Los administradores pueden ver todos los usuarios
CREATE POLICY "Administradores pueden ver todos los usuarios" ON public.usuario
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.usuario 
            WHERE email = auth.email() AND id_rol = 1
        )
    );

-- Políticas para productos (todos los usuarios autenticados pueden ver)
CREATE POLICY "Todos pueden ver productos" ON public.producto
    FOR SELECT USING (auth.role() = 'authenticated');

-- Solo administradores y vendedores pueden modificar productos
CREATE POLICY "Admin y vendedores pueden modificar productos" ON public.producto
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.usuario 
            WHERE email = auth.email() AND id_rol IN (1, 2)
        )
    );

-- Políticas para pedidos
CREATE POLICY "Los usuarios pueden ver sus propios pedidos" ON public.pedido
    FOR SELECT USING (
        id_cliente IN (
            SELECT id_usuario FROM public.usuario WHERE email = auth.email()
        )
    );

CREATE POLICY "Los usuarios pueden crear sus propios pedidos" ON public.pedido
    FOR INSERT WITH CHECK (
        id_cliente IN (
            SELECT id_usuario FROM public.usuario WHERE email = auth.email()
        )
    );

-- Administradores y vendedores pueden ver todos los pedidos
CREATE POLICY "Admin y vendedores pueden ver todos los pedidos" ON public.pedido
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.usuario 
            WHERE email = auth.email() AND id_rol IN (1, 2)
        )
    );

-- USUARIO ADMINISTRADOR INICIAL
-- Para entrar como admin, usa: Usuario: "admin", Contraseña: "123456"
INSERT INTO public.usuario (nombre, apellido, contrasena, id_rol) VALUES 
    ('admin', 'principal', '123456', 1),
    ('vendedor', 'uno', '123456', 2),
    ('cliente', 'ejemplo', '123456', 3)
ON CONFLICT DO NOTHING;

-- DATOS DE EJEMPLO PARA TESTING
INSERT INTO public.producto (sku, nombre, categoria, precio, costo, stock) VALUES 
    ('PROD001', 'Laptop HP', 'Electrónicos', 799.99, 600.00, 25),
    ('PROD002', 'Mouse Inalámbrico', 'Electrónicos', 29.99, 15.00, 100),
    ('PROD003', 'Teclado Mecánico', 'Electrónicos', 89.99, 50.00, 50),
    ('PROD004', 'Monitor 24"', 'Electrónicos', 199.99, 120.00, 15),
    ('PROD005', 'Auriculares Bluetooth', 'Electrónicos', 59.99, 30.00, 80)
ON CONFLICT (sku) DO NOTHING;

-- Mensaje de confirmación
SELECT 'Base de datos configurada correctamente para InventarioApp' as mensaje;