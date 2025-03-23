import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_cert_app/app/routes.dart';
import 'package:medical_cert_app/domain/entities/user.dart';
import 'package:medical_cert_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:medical_cert_app/presentation/blocs/question/question_bloc.dart';
import 'package:medical_cert_app/presentation/blocs/study_progress/study_progress_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      final user = authState.user;
      
      // Load user progress
      context.read<StudyProgressBloc>().add(LoadUserProgressEvent(user.id));
      
      // Sync questions in background
      context.read<QuestionBloc>().add(SyncQuestionsEvent());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthenticatedState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = state.user;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('医療情報技師学習アプリ'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.settings);
                },
              ),
            ],
          ),
          body: _buildBody(user),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBar.item(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBar.item(
                icon: Icon(Icons.book),
                label: '問題',
              ),
              BottomNavigationBar.item(
                icon: Icon(Icons.analytics),
                label: '分析',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }

  Widget _buildBody(User user) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab(user);
      case 1:
        return _buildQuestionsTab();
      case 2:
        return _buildAnalysisTab(user);
      default:
        return _buildHomeTab(user);
    }
  }

  Widget _buildHomeTab(User user) {
    return BlocBuilder<StudyProgressBloc, StudyProgressState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'こんにちは、${user.displayName}さん',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('今日も学習を続けましょう！'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '学習状況',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (state is UserProgressLoadedState) ...[
                _buildProgressSummary(state),
              ] else if (state is StudyProgressLoadingState) ...[
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ] else ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('学習データを読み込めませんでした'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'カテゴリ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildCategoryCards(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSummary(UserProgressLoadedState state) {
    final totalQuestions = state.progressList.length;
    final correctQuestions = state.progressList
        .where((progress) => progress.isCorrect)
        .length;
    final accuracy = totalQuestions > 0
        ? (correctQuestions / totalQuestions * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('解答済み問題', '$totalQuestions問'),
                _buildStatItem('正解率', '$accuracy%'),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalQuestions > 0 ? correctQuestions / totalQuestions : 0,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryCards() {
    return Column(
      children: [
        _buildCategoryCard(
          '医学・医療系',
          Icons.medical_services,
          Colors.red.shade100,
          () {
            Navigator.of(context).pushNamed(
              AppRoutes.questionList,
              arguments: {'category': '医学・医療系'},
            );
          },
        ),
        const SizedBox(height: 8),
        _buildCategoryCard(
          '情報処理技術系',
          Icons.computer,
          Colors.blue.shade100,
          () {
            Navigator.of(context).pushNamed(
              AppRoutes.questionList,
              arguments: {'category': '情報処理技術系'},
            );
          },
        ),
        const SizedBox(height: 8),
        _buildCategoryCard(
          '医療情報システム系',
          Icons.health_and_safety,
          Colors.green.shade100,
          () {
            Navigator.of(context).pushNamed(
              AppRoutes.questionList,
              arguments: {'category': '医療情報システム系'},
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return BlocBuilder<QuestionBloc, QuestionState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '問題カテゴリ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildCategoryCard(
                    '医学・医療系',
                    Icons.medical_services,
                    Colors.red.shade100,
                    () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.questionList,
                        arguments: {'category': '医学・医療系'},
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryCard(
                    '情報処理技術系',
                    Icons.computer,
                    Colors.blue.shade100,
                    () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.questionList,
                        arguments: {'category': '情報処理技術系'},
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryCard(
                    '医療情報システム系',
                    Icons.health_and_safety,
                    Colors.green.shade100,
                    () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.questionList,
                        arguments: {'category': '医療情報システム系'},
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Start mock exam
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('模擬試験を開始'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisTab(User user) {
    return BlocBuilder<StudyProgressBloc, StudyProgressState>(
      builder: (context, state) {
        if (state is UserProgressLoadedState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '学習分析',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildAnalysisCard(state),
                const SizedBox(height: 24),
                Text(
                  'カテゴリ別成績',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildCategoryAnalysis(),
              ],
            ),
          );
        } else if (state is StudyProgressLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return const Center(
            child: Text('分析データを読み込めませんでした'),
          );
        }
      },
    );
  }

  Widget _buildAnalysisCard(UserProgressLoadedState state) {
    final totalQuestions = state.progressList.length;
    final correctQuestions = state.progressList
        .where((progress) => progress.isCorrect)
        .length;
    final accuracy = totalQuestions > 0
        ? (correctQuestions / totalQuestions * 100).toStringAsFixed(1)
        : '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '総合成績',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('解答済み問題', '$totalQuestions問'),
                _buildStatItem('正解数', '$correctQuestions問'),
                _buildStatItem('正解率', '$accuracy%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAnalysis() {
    // This would be populated with real data from the state
    return Column(
      children: [
        _buildCategoryProgressCard(
          '医学・医療系',
          0.75,
          '75%',
        ),
        const SizedBox(height: 8),
        _buildCategoryProgressCard(
          '情報処理技術系',
          0.60,
          '60%',
        ),
        const SizedBox(height: 8),
        _buildCategoryProgressCard(
          '医療情報システム系',
          0.80,
          '80%',
        ),
      ],
    );
  }

  Widget _buildCategoryProgressCard(
    String category,
    double progress,
    String percentage,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Text(
                    percentage,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

