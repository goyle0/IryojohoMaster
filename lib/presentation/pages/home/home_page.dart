import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:adaptive_navigation/adaptive_navigation.dart';
import 'package:iryojoho_master/presentation/blocs/auth/auth_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/study_progress/study_progress_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final _destinations = const [
    AdaptiveScaffoldDestination(title: 'ホーム', icon: Icons.home),
    AdaptiveScaffoldDestination(title: '問題', icon: Icons.question_answer),
    AdaptiveScaffoldDestination(title: '学習計画', icon: Icons.calendar_month),
    AdaptiveScaffoldDestination(title: '分析', icon: Icons.analytics),
    AdaptiveScaffoldDestination(title: '設定', icon: Icons.settings),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  void _loadUserProgress() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthenticatedState) {
      context.read<StudyProgressBloc>().add(
        LoadUserProgressEvent(authState.user.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      destinations: _destinations,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      appBar: AdaptiveAppBar(
        title: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              '医療情報技師学習アプリ',
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
        ),
      ),
      body: _buildBody(),
      navigationTypeResolver: (context) {
        if (MediaQuery.of(context).size.width > 1000) {
          return NavigationType.drawer;
        }
        return NavigationType.bottom;
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildQuestionTab();
      case 2:
        return _buildCalendarTab();
      case 3:
        return _buildAnalysisTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return BlocBuilder<StudyProgressBloc, StudyProgressState>(
      builder: (context, state) {
        if (state is StudyProgressLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserProgressLoadedState) {
          return MasonryGridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _buildProgressCard(state);
                case 1:
                  return _buildNextLessonCard();
                case 2:
                  return _buildRecentActivitiesCard(state);
                case 3:
                  return _buildStudyRoadmapCard();
                default:
                  return const SizedBox.shrink();
              }
            },
          );
        }

        return const Center(child: Text('データの読み込みに失敗しました'));
      },
    );
  }

  Widget _buildProgressCard(UserProgressLoadedState state) {
    final totalQuestions = state.progressList.length;
    final correctQuestions =
        state.progressList.where((progress) => progress.isCorrect).length;
    final accuracy =
        totalQuestions > 0 ? correctQuestions / totalQuestions : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学習進捗',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 12.0,
                percent: accuracy,
                center: Text(
                  '${(accuracy * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                animation: true,
                animationDuration: 1000,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextLessonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '次の学習',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.play_arrow)),
              title: const Text('医療情報システムの基礎'),
              subtitle: const Text('残り3問'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: 問題画面への遷移を実装
                },
                child: const Text('開始'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesCard(UserProgressLoadedState state) {
    final recentProgress = state.progressList.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近の活動',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentProgress.length,
              itemBuilder: (context, index) {
                final progress = recentProgress[index];
                return TimelineTile(
                  alignment: TimelineAlign.start,
                  isFirst: index == 0,
                  isLast: index == recentProgress.length - 1,
                  indicatorStyle: IndicatorStyle(
                    width: 20,
                    color: progress.isCorrect ? Colors.green : Colors.red,
                    padding: const EdgeInsets.all(6),
                  ),
                  endChild: ListTile(
                    title: Text('問題 ${progress.questionId}'),
                    subtitle: Text(_formatDateTime(progress.answeredAt)),
                    trailing: Icon(
                      progress.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: progress.isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyRoadmapCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学習ロードマップ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TimelineTile(
              alignment: TimelineAlign.start,
              isFirst: true,
              indicatorStyle: const IndicatorStyle(
                width: 20,
                color: Colors.green,
                padding: EdgeInsets.all(6),
              ),
              endChild: const ListTile(
                title: Text('基礎知識の習得'),
                subtitle: Text('医療情報の基礎を学ぶ'),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              indicatorStyle: const IndicatorStyle(
                width: 20,
                color: Colors.blue,
                padding: EdgeInsets.all(6),
              ),
              endChild: const ListTile(
                title: Text('実践問題に挑戦'),
                subtitle: Text('過去問を解いて実力をつける'),
              ),
            ),
            TimelineTile(
              alignment: TimelineAlign.start,
              isLast: true,
              indicatorStyle: const IndicatorStyle(
                width: 20,
                color: Colors.grey,
                padding: EdgeInsets.all(6),
              ),
              endChild: const ListTile(
                title: Text('模擬試験'),
                subtitle: Text('本番を想定した総合的な学習'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTab() {
    return MasonryGridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        final categories = [
          {
            'title': '医学・医療系',
            'icon': Icons.medical_services,
            'color': Colors.red,
          },
          {'title': '情報処理技術系', 'icon': Icons.computer, 'color': Colors.blue},
          {
            'title': '医療情報システム系',
            'icon': Icons.health_and_safety,
            'color': Colors.green,
          },
          {'title': '関連法規', 'icon': Icons.gavel, 'color': Colors.purple},
          {'title': '統計・分析', 'icon': Icons.analytics, 'color': Colors.orange},
          {'title': '総合問題', 'icon': Icons.library_books, 'color': Colors.teal},
        ];

        return Card(
          color: categories[index]['color'] as Color,
          child: InkWell(
            onTap: () {
              // TODO: カテゴリー別問題一覧への遷移を実装
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categories[index]['icon'] as IconData,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index]['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: DateTime.now(),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Expanded(
          child: Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日の学習計画',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text('医療情報システムの基礎 - 5問'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text('セキュリティ対策 - 3問'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text('用語の復習'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'カテゴリー別成績',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const titles = ['医療', '情報', 'システム', '法規', '統計'];
                                if (value < 0 || value >= titles.length) {
                                  return const Text('');
                                }
                                return Text(
                                  titles[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(show: false),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: 75,
                                color: Colors.red,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: 60,
                                color: Colors.blue,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: 80,
                                color: Colors.green,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: 65,
                                color: Colors.purple,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 4,
                            barRods: [
                              BarChartRodData(
                                toY: 70,
                                color: Colors.orange,
                                width: 20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '学習時間の推移',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 2),
                              FlSpot(1, 1.5),
                              FlSpot(2, 3),
                              FlSpot(3, 2.5),
                              FlSpot(4, 2),
                              FlSpot(5, 4),
                              FlSpot(6, 3),
                            ],
                            isCurved: true,
                            color: Theme.of(context).colorScheme.primary,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthenticatedState) {
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(state.user.displayName),
                      subtitle: Text(state.user.email),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('通知設定'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 通知設定画面への遷移を実装
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('ダークモード'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    // TODO: テーマの切り替えを実装
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('ログアウト', style: TextStyle(color: Colors.red)),
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('ログアウト'),
                          content: const Text('本当にログアウトしますか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(LogoutEvent());
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'ログアウト',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}

class ChartData {
  final String category;
  final double value;

  ChartData(this.category, this.value);
}

class TimeSeriesData {
  final DateTime date;
  final double hours;

  TimeSeriesData(this.date, this.hours);
}
