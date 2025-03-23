import 'package:iryojoho_master/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String displayName);
  Future<void> signOut();
  Stream<User?> authStateChanges();
}

