/// アプリケーションのホーム画面
///
/// 問題カテゴリー一覧を表示するメインインターフェイスを提供する
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iryojoho_master/presentation/blocs/auth/auth_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iryojoho_master/presentation/widgets/common_navigation_bar.dart';

/// ホーム画面のステートフルウィジェット
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('医療情報技師学習アプリ'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthenticatedState) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
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
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: MasonryGridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        itemCount: 4,
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
            {
              'title': '総合問題',
              'icon': Icons.library_books,
              'color': Colors.teal,
            },
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
      ),
      bottomNavigationBar: const CommonNavigationBar(currentIndex: 0),
    );
  }
}
