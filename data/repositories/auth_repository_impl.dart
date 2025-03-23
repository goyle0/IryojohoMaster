import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iryojoho_master/domain/entities/user.dart';
import 'package:iryojoho_master/domain/repositories/auth_repository.dart';
import 'package:iryojoho_master/data/models/user_model.dart';
import 'package:iryojoho_master/core/errors/auth_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<User?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();
      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('ログインに失敗しました');
      }

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      // 最終ログイン時間を更新
      await _supabase
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', response.user!.id);

      return UserModel.fromJson(userData);
    } catch (e) {
      throw AuthException('ログインに失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<User> signUp(String email, String password, String displayName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('アカウント作成に失敗しました');
      }

      // ユーザープロフィールを作成
      final userData = await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
      }).select().single();

      return UserModel.fromJson(userData);
    } catch (e) {
      throw AuthException('アカウント作成に失敗しました: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<User?> authStateChanges() {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session == null) return null;
      try {
        final response = await _supabase
            .from('users')
            .select()
            .eq('id', event.session!.user.id)
            .single();
        return UserModel.fromJson(response);
      } catch (e) {
        return null;
      }
    });
  }
}

