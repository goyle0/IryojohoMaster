import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:iryojoho_master/app/routes.dart';
import 'package:iryojoho_master/presentation/blocs/auth/auth_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/question/question_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/study_progress/study_progress_bloc.dart';
import 'package:iryojoho_master/data/repositories/auth_repository_impl.dart';
import 'package:iryojoho_master/data/repositories/question_repository_impl.dart';
import 'package:iryojoho_master/data/repositories/study_progress_repository_impl.dart';

class IryojohoMasterApp extends StatelessWidget {
  const IryojohoMasterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authRepository: AuthRepositoryImpl(),
          )..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<QuestionBloc>(
          create: (context) => QuestionBloc(
            questionRepository: QuestionRepositoryImpl(),
          ),
        ),
        BlocProvider<StudyProgressBloc>(
          create: (context) => StudyProgressBloc(
            studyProgressRepository: StudyProgressRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: '医療情報技師資格取得学習アプリ',
        theme: FlexThemeData.light(
          scheme: FlexScheme.blueM3,
          useMaterial3: true,
        ),
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.blueM3,
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}

