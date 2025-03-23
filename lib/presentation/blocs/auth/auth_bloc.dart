import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/domain/entities/user.dart';

// イベント
abstract class AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });
}

class LogoutEvent extends AuthEvent {}

// 状態
abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final User user;

  AuthenticatedState(this.user);
}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);
}

class UnauthenticatedState extends AuthState {}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());
    try {
      // デモ用に仮のユーザーを作成
      await Future.delayed(const Duration(seconds: 1));
      final demoUser = User(
        id: '1',
        email: 'demo@example.com',
        name: 'デモユーザー',
        lastLoginAt: DateTime.now(),
      );
      emit(AuthenticatedState(demoUser));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // デモ用の認証処理
      await Future.delayed(const Duration(seconds: 1));
      if (event.email == 'demo@example.com' && event.password == 'password') {
        final user = User(
          id: '1',
          email: event.email,
          name: 'デモユーザー',
          lastLoginAt: DateTime.now(),
        );
        emit(AuthenticatedState(user));
      } else {
        emit(AuthErrorState('メールアドレスまたはパスワードが正しくありません'));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // デモ用の登録処理
      await Future.delayed(const Duration(seconds: 1));
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: event.email,
        name: event.displayName,
        lastLoginAt: DateTime.now(),
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      // デモ用のログアウト処理
      await Future.delayed(const Duration(milliseconds: 500));
      emit(UnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }
}
