import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  late final SupabaseClient _client;
  
  SupabaseClient get client => _client;
  
  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase no configurado. '
        'Por favor actualiza las credenciales en lib/config/supabase_config.dart'
      );
    }
    
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
  
  // Auth helpers
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  // Stream para cambios de autenticación
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}