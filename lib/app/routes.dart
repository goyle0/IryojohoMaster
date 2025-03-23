import 'package:flutter/material.dart';
import 'package:iryojoho_master/presentation/pages/auth/login_page.dart';
import 'package:iryojoho_master/presentation/pages/auth/register_page.dart';
import 'package:iryojoho_master/presentation/pages/home/home_page.dart';
import 'package:iryojoho_master/presentation/pages/questions/question_list_page.dart';
import 'package:iryojoho_master/presentation/pages/questions/question_detail_page.dart';
import 'package:iryojoho_master/presentation/pages/analysis/analysis_page.dart';
import 'package:iryojoho_master/presentation/pages/settings/settings_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String questionList = '/questions';
  static const String questionDetail = '/questions/detail';
  static const String analysis = '/analysis';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppRoutes.questionList:
        final args = settings.arguments as Map<String, dynamic>?;
        final category = args?['category'] as String?;
        return MaterialPageRoute(
          builder: (_) => QuestionListPage(category: category),
        );
      case AppRoutes.questionDetail:
        final args = settings.arguments as Map<String, dynamic>;
        final questionId = args['questionId'] as String;
        return MaterialPageRoute(
          builder: (_) => QuestionDetailPage(questionId: questionId),
        );
      case AppRoutes.analysis:
        return MaterialPageRoute(builder: (_) => const AnalysisPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('指定されたルート ${settings.name} は定義されていません'),
                ),
              ),
        );
    }
  }
}
