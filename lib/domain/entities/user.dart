/// ユーザー情報を表すエンティティクラス
class User {
  /// ユーザーの一意識別子
  final String id;

  /// ユーザーのメールアドレス
  final String? email;

  /// ユーザーの表示名
  final String? name;

  /// ユーザーのアバター画像URL
  final String? avatarUrl;

  /// ユーザーオブジェクトのコンストラクタ
  ///
  /// [id] ユーザーID（必須）
  /// [email] メールアドレス（オプション）
  /// [name] 表示名（オプション）
  /// [avatarUrl] アバター画像URL（オプション）
  User({required this.id, this.email, this.name, this.avatarUrl});

  /// 現在のユーザー情報をベースに新しいユーザーオブジェクトを作成
  ///
  /// [name] 更新する表示名
  /// [avatarUrl] 更新するアバター画像URL
  ///
  /// 指定されていないパラメータは現在の値を維持
  User copyWith({String? name, String? avatarUrl}) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
