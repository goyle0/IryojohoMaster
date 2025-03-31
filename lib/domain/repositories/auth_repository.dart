/// 認証関連のリポジトリインターフェイス
import 'package:iryojoho_master/domain/entities/user.dart';

abstract class AuthRepository {
  /// 現在ログインしているユーザーを取得する
  ///
  /// 戻り値: ログイン中のユーザー情報。未ログインの場合はnull
  Future<User?> getCurrentUser();

  /// メールとパスワードでサインインする
  ///
  /// [email] サインインに使用するメールアドレス
  /// [password] サインインに使用するパスワード
  ///
  /// 戻り値: サインインしたユーザーの情報
  /// 例外: サインインに失敗した場合
  Future<User> signInWithEmail(String email, String password);

  /// メール、パスワード、名前でユーザー登録する
  ///
  /// [email] 登録するメールアドレス
  /// [password] 登録するパスワード
  /// [name] 登録するユーザー名
  ///
  /// 戻り値: 登録したユーザーの情報
  /// 例外: 登録に失敗した場合
  Future<User> signUpWithEmail(String email, String password, String name);

  /// ログアウトする
  ///
  /// 例外: ログアウトに失敗した場合
  Future<void> signOut();

  /// ユーザープロファイルを更新する
  ///
  /// [userId] 更新するユーザーのID
  /// [name] 更新する名前
  /// [avatarUrl] 更新するアバター画像URL
  ///
  /// 例外: 更新に失敗した場合
  Future<void> updateUserProfile(String userId, String name, String? avatarUrl);
}
