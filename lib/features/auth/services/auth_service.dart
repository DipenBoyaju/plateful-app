import '../../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  User? get currentUser => _supabase.auth.currentUser;

  bool get isLoggedIn => currentUser != null;
  //signup
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    try {
      //check if user exists
      final existingUser = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        return {'error': 'Username already taken'};
      }
      //signup user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'username': username},
      );

      if (response.user == null) {
        return {'error': 'Failed to create account'};
      }
      //create profile
      await _supabase.from('profiles').insert({
        'id': response.user!.id,
        'username': username,
        'full_name': fullName,
        'avatar_url':
            'https://api.dicebear.com/7.x/avataaars/svg?seed=$username',
      });
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  //signin
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return {'success': true};
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromMap({
        'id': userId,
        'email': currentUser?.email ?? '',
        ...response,
      });
    } catch (e) {
      return null;
    }
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
