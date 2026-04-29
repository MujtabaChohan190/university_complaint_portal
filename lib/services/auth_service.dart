import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. SIGN UP (Student Registration)
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'student', // Initial role is always student
        },
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // 2. SIGN IN (Login)
  Future<void> signIn(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw e.toString();
    }
  }

  // 3. ROLE CHECK (The "Gatekeeper" Logic)
  // This fetches the role from your 'profiles' table
  Future<String> getUserRole() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'none';

      final response = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return 'student'; // Default fallback
      return response['role'] as String;
    } catch (e) {
      print("Error fetching role: $e");
      return 'student';
    }
  }

  // 4. CURRENT USER DATA
  User? get currentUser => _supabase.auth.currentUser;

  // 5. LOGOUT
  Future<void> signOut() async => await _supabase.auth.signOut();
}