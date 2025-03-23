import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/presentation/pages/home/home_page.dart';
import 'package:iryojoho_master/presentation/blocs/auth/auth_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/question/question_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/study_progress/study_progress_bloc.dart';
import 'package:iryojoho_master/data/repositories/question_repository_impl.dart';
import 'package:iryojoho_master/data/repositories/study_progress_repository_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final questionRepository = QuestionRepositoryImpl();
    final studyProgressRepository = StudyProgressRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<QuestionBloc>(
          create:
              (context) => QuestionBloc(questionRepository: questionRepository),
        ),
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
