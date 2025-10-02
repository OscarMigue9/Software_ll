# InventarioApp - Flutter + Supabase

Una aplicación móvil completa de gestión de inventarios desarrollada en Flutter con backend en Supabase.

## 🚀 Características

### Roles de Usuario
- **Administrador General**: Gestión completa de usuarios, productos, inventario, pedidos y reportes
- **Vendedor**: Gestión de productos, inventario, pedidos y ventas (limitado)
- **Cliente**: Tienda, carrito, pedidos y perfil

### Funcionalidades Principales
- ✅ **Autenticación completa** con Supabase Auth
- ✅ **Gestión de usuarios y roles**
- ✅ **CRUD completo de productos**
- ✅ **Control de inventario en tiempo real**
- ✅ **Sistema de pedidos con validación de stock**
- ✅ **Generación de reportes**
- ✅ **Navegación por roles** (Drawer/BottomNavigation)

## 🛠️ Instalación y Configuración

### Paso 1: Configurar Supabase
1. Ve a [supabase.com](https://supabase.com) y crea una cuenta
2. Crea un nuevo proyecto
3. Ve a **Settings > API**
4. Copia tu **Project URL** y **anon/public key**

### Paso 2: Configurar Base de Datos
1. Ve a **SQL Editor** en tu panel de Supabase
2. Ejecuta el script completo que está en `database/setup.sql`

### Paso 3: Configurar Credenciales
1. Abre `lib/config/supabase_config.dart`
2. Reemplaza con tus credenciales reales de Supabase

### Paso 4: Ejecutar
```bash
flutter pub get
flutter run
```

¡Tu aplicación InventarioApp está lista para usar! 🎉
