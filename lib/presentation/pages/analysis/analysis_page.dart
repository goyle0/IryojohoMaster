import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/study_progress/study_progress_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/auth/auth_bloc.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<StudyProgressBloc>().add(
        LoadUserProgressEvent(authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習分析')),
      body: BlocBuilder<StudyProgressBloc, StudyProgressState>(
        builder: (context, state) {
          if (state is StudyProgressLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserProgressLoadedState) {
            final progressList = state.progressList;
            final totalQuestions = progressList.length;
            if (totalQuestions == 0) {
              return const Center(child: Text('まだ学習データがありません'));
            }

            final correctAnswers =
                progressList.where((progress) => progress.isCorrect).length;
            final accuracy = (correctAnswers / totalQuestions * 100)
                .toStringAsFixed(1);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallProgress(
                    correctAnswers,
                    totalQuestions,
                    accuracy,
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryAnalysis(),
                  const SizedBox(height: 24),
                  _buildRecentProgress(progressList),
                ],
              ),
            );
          }

          return const Center(child: Text('分析データを読み込めませんでした'));
        },
      ),
    );
  }

  Widget _buildOverallProgress(
    int correctAnswers,
    int totalQuestions,
    String accuracy,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('総合成績', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('解答数', '$totalQuestions問'),
                _buildStatCard('正解数', '$correctAnswers問'),
                _buildStatCard('正答率', '$accuracy%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildCategoryAnalysis() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('カテゴリー別成績', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildCategoryProgressItem('医学・医療系', 0.75, '75%'),
            const SizedBox(height: 8),
            _buildCategoryProgressItem('情報処理技術系', 0.60, '60%'),
            const SizedBox(height: 8),
            _buildCategoryProgressItem('医療情報システム系', 0.80, '80%'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgressItem(
    String category,
    double progress,
    String percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Text(percentage),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentProgress(List progressList) {
    final recentProgress = progressList.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('最近の学習', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentProgress.length,
              itemBuilder: (context, index) {
                final progress = recentProgress[index];
                return ListTile(
                  leading: Icon(
                    progress.isCorrect ? Icons.check_circle : Icons.cancel,
                    color: progress.isCorrect ? Colors.green : Colors.red,
                  ),
                  title: Text('問題 ${progress.questionId}'),
                  subtitle: Text(
                    '回答日時: ${_formatDateTime(progress.answeredAt)}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} '
        '${dateTime.hour}:${dateTime.minute}';
  }
}
