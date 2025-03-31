/// アプリケーションのホーム画面
///
/// ホーム、問題、カレンダー、分析、設定の5つのタブを表示する
/// メインナビゲーションインターフェイスを提供する
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

/// ホーム画面のステートフルウィジェット
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// ホーム画面の状態クラス
class _HomePageState extends State<HomePage> {
  /// 現在選択されているタブのインデックス
  int _selectedIndex = 0;

  /// ナビゲーションの宛先定義
  final _destinations = const [
    AdaptiveScaffoldDestination(title: 'ホーム', icon: Icons.home),
    AdaptiveScaffoldDestination(title: '問題', icon: Icons.question_answer),
    AdaptiveScaffoldDestination(title: 'カレンダー', icon: Icons.calendar_month),
    AdaptiveScaffoldDestination(title: '分析', icon: Icons.bar_chart),
    AdaptiveScaffoldDestination(title: '設定', icon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    /// アダプティブなナビゲーションスカフォールドを構築
    return AdaptiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      destinations: _destinations,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      appBar: AppBar(
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

  /// 選択されているタブに基づいて本体部分を構築する
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

  /// ホームタブの構築
  Widget _buildHomeTab() {
    return BlocBuilder<StudyProgressBloc, StudyProgressState>(
      builder: (context, state) {
        if (state is StudyProgressLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserProgressLoadedState) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProgressSummary(state),
                const SizedBox(height: 16),
                _buildRecentActivity(state),
                const SizedBox(height: 16),
                _buildLearningPath(),
              ],
            ),
          );
        }
        return const Center(child: Text('データがありません。'));
      },
    );
  }

  /// 学習進捗のサマリーカードを構築
  Widget _buildProgressSummary(UserProgressLoadedState state) {
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
              ),
            ),
            const SizedBox(height: 16),
            Text('総問題数: $totalQuestions'),
            Text('正解数: $correctQuestions'),
            Text('正解率: ${(accuracy * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  /// 最近の学習活動を表示するカードを構築
  Widget _buildRecentActivity(UserProgressLoadedState state) {
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
                    subtitle: Text(
                      '${progress.isCorrect ? '正解' : '不正解'} - ${_formatDateTime(progress.answeredAt)}',
                    ),
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

  /// 学習パス（ロードマップ）を表示するカードを構築
  Widget _buildLearningPath() {
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
                title: Text('基礎を学ぶ'),
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

  /// 問題タブの構築
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

  /// カレンダータブの構築
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

  /// 分析タブの構築
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

  /// 設定タブの構築
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
                      title: Text(state.user.name ?? 'ユーザー'),
                      subtitle: Text(state.user.email ?? ''),
                    );
                  }
                  return const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('ゲスト'),
                    subtitle: Text('ログインしていません'),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.nightlight_round),
                title: const Text('ダークモード'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    // TODO: テーマ切り替え機能を実装
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('通知'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {
                    // TODO: 通知設定機能を実装
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('ヘルプ'),
                onTap: () {
                  // TODO: ヘルプ画面への遷移を実装
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('アプリについて'),
                onTap: () {
                  // TODO: アプリ情報画面への遷移を実装
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthenticatedState) {
                    return ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'ログアウト',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('ログアウト'),
                                content: const Text('本当にログアウトしますか？'),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('キャンセル'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.read<AuthBloc>().add(
                                        LogoutEvent(),
                                      );
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
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 日時を読みやすい形式にフォーマットする
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}

/// グラフ用のカテゴリデータモデル
class ChartData {
  /// カテゴリ名
  final String category;

  /// カテゴリの値
  final double value;

  ChartData(this.category, this.value);
}

/// 時系列データモデル
class TimeSeriesData {
  /// 日付
  final DateTime date;

  /// 学習時間（時間単位）
  final double hours;

  TimeSeriesData(this.date, this.hours);
}
