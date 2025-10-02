// Configuración de Supabase

class SupabaseConfig {
  // Credenciales de Supabase configuradas
  static const String supabaseUrl = 'https://mvgcmaoegxbgexehbtbl.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12Z2NtYW9lZ3hiZ2V4ZWhidGJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkzMzU4MjQsImV4cCI6MjA3NDkxMTgyNH0.0hCxsD_KIm4Ei__uwfqOQ83S_zsjdA_C38opS758os8';
  




































  // Validar que las credenciales estén configuradas
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty;
}