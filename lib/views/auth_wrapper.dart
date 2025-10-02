import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart';
import 'auth/login_screen.dart';
import 'admin/admin_home_screen.dart';
import 'vendedor/vendedor_home_screen.dart';
import 'cliente/cliente_home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Si está cargando, mostrar indicador
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si no está autenticado, mostrar login
    if (!authState.isAuthenticated || authState.usuario == null) {
      return const LoginScreen();
    }

    // Si está autenticado, mostrar pantalla según rol
    final usuario = authState.usuario!;
    
    if (usuario.esAdministrador) {
      return const AdminHomeScreen();
    } else if (usuario.esVendedor) {
      return const VendedorHomeScreen();
    } else {
      return const ClienteHomeScreen();
    }
  }
}