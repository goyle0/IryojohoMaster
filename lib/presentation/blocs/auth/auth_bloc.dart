/// 認証関連の状態管理を行うBLoCクラス
///
/// ユーザーの認証状態（ログイン、ログアウトなど）を管理し、
/// 認証関連のイベントを処理する
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/domain/entities/user.dart';
import 'package:iryojoho_master/domain/repositories/auth_repository.dart';

/// 認証関連のイベント定義
abstract class AuthEvent {}

/// アプリ起動時などに認証状態を確認するイベント
class CheckAuthStatusEvent extends AuthEvent {}

/// ログインイベント
class SignInEvent extends AuthEvent {
  /// ログインに使用するメールアドレス
  final String email;

  /// ログインに使用するパスワード
  final String password;

  SignInEvent({required this.email, required this.password});
}

/// ユーザー登録イベント
class SignUpEvent extends AuthEvent {
  /// 登録するメールアドレス
  final String email;

  /// 登録するパスワード
  final String password;

  /// 登録するユーザー表示名
  final String displayName;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

/// ログアウトイベント
class LogoutEvent extends AuthEvent {}

/// 認証関連の状態定義
abstract class AuthState {}

/// 初期状態（認証状態未確認）
class AuthInitialState extends AuthState {}

/// 認証処理中の状態
class AuthLoadingState extends AuthState {}

/// 認証済み状態
class AuthenticatedState extends AuthState {
  /// 認証済みユーザー情報
  final User user;

  AuthenticatedState(this.user);
}

/// 認証エラー状態
class AuthErrorState extends AuthState {
  /// エラーメッセージ
  final String message;

  AuthErrorState(this.message);
}

/// 未認証状態
class UnauthenticatedState extends AuthState {}

/// 認証BLoCの実装
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// 認証リポジトリ
  final AuthRepository authRepository;

  /// AuthBlocのコンストラクタ
  ///
  /// [authRepository] 認証処理を行うリポジトリ
  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
  }

  /// 認証状態確認イベントのハンドラ
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthenticatedState(user));
      } else {
        emit(UnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  /// サインインイベントのハンドラ
  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.signInWithEmail(
        event.email,
        event.password,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState('メールアドレスまたはパスワードが正しくありません'));
    }
  }

  /// サインアップイベントのハンドラ
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.signUpWithEmail(
        event.email,
        event.password,
        event.displayName,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  /// ログアウトイベントのハンドラ
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      await authRepository.signOut();
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
