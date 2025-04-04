import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:iryojoho_master/presentation/widgets/common_navigation_bar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習カレンダー')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      '今日の学習計画',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStudyPlan(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CommonNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildStudyPlan() {
    return const Column(
      children: [
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
    );
  }
}
