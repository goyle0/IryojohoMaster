/// 医療情報技師学習アプリのメインエントリーポイント
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:iryojoho_master/presentation/pages/home/home_page.dart';
import 'package:iryojoho_master/presentation/blocs/auth/auth_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/question/question_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/study_progress/study_progress_bloc.dart';
import 'package:iryojoho_master/data/repositories/question_repository_impl.dart';
import 'package:iryojoho_master/data/repositories/study_progress_repository_impl.dart';
import 'package:iryojoho_master/data/repositories/auth_repository_impl.dart';

/// アプリケーションの初期化と起動
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabaseの初期化
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // ここに実際のSupabase URLを設定
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // ここに実際のAnon Keyを設定
  );

  runApp(const MyApp());
}

/// アプリケーションのルートウィジェット
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 各リポジトリのインスタンスを作成
    final authRepository = AuthRepositoryImpl();
    final questionRepository = QuestionRepositoryImpl();
    final studyProgressRepository = StudyProgressRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        // 認証BLoCプロバイダー
        BlocProvider<AuthBloc>(
          create:
              (context) =>
                  AuthBloc(authRepository: authRepository)
                    ..add(CheckAuthStatusEvent()),
        ),
        // 問題管理BLoCプロバイダー
        BlocProvider<QuestionBloc>(
          create:
              (context) => QuestionBloc(questionRepository: questionRepository),
        ),
        // 学習進捗BLoCプロバイダー
        BlocProvider<StudyProgressBloc>(
          create:
              (context) => StudyProgressBloc(
                studyProgressRepository: studyProgressRepository,
              ),
        ),
      ],
      child: MaterialApp(
        title: '医療情報技師学習アプリ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
