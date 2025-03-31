/// 認証リポジトリの実装クラス
/// Supabaseを使用してユーザー認証やプロファイル管理を行う
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:iryojoho_master/domain/repositories/auth_repository.dart';
import 'package:iryojoho_master/domain/entities/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  /// Supabaseクライアントのインスタンス
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  @override
  Future<User?> getCurrentUser() async {
    final supaUser = _supabase.auth.currentUser;
    if (supaUser == null) {
      return null;
    }

    try {
      // ユーザープロファイルデータを取得
      final profileData =
          await _supabase
              .from('profiles')
              .select()
              .eq('id', supaUser.id)
              .single();

      return User(
        id: supaUser.id,
        email: supaUser.email,
        name: profileData['name'] ?? supaUser.email?.split('@').first,
        avatarUrl: profileData['avatar_url'],
      );
    } catch (e) {
      // プロファイルデータがない場合は基本情報のみ返す
      return User(
        id: supaUser.id,
        email: supaUser.email,
        name: supaUser.email?.split('@').first,
      );
    }
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final supaUser = response.user;
    if (supaUser == null) {
      throw Exception('Failed to sign in');
    }

    try {
      // ユーザープロファイルデータを取得
      final profileData =
          await _supabase
              .from('profiles')
              .select()
              .eq('id', supaUser.id)
              .single();

      return User(
        id: supaUser.id,
        email: supaUser.email,
        name: profileData['name'] ?? supaUser.email?.split('@').first,
        avatarUrl: profileData['avatar_url'],
      );
    } catch (e) {
      // プロファイルデータがない場合は基本情報のみ返す
      return User(
        id: supaUser.id,
        email: supaUser.email,
        name: supaUser.email?.split('@').first,
      );
    }
  }

  @override
  Future<User> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final supaUser = response.user;
    if (supaUser == null) {
      throw Exception('Failed to sign up');
    }

    // プロファイルデータを作成
    await _supabase.from('profiles').insert({
      'id': supaUser.id,
      'name': name,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });

    return User(id: supaUser.id, email: supaUser.email, name: name);
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> updateUserProfile(
    String userId,
    String name,
    String? avatarUrl,
  ) async {
    final updates = {
      'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }
}
