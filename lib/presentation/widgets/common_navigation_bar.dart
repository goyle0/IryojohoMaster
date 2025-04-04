import 'package:flutter/material.dart';
import 'package:iryojoho_master/presentation/pages/home/home_page.dart';
import 'package:iryojoho_master/presentation/pages/calendar/calendar_page.dart';
import 'package:iryojoho_master/presentation/pages/analysis/analysis_page.dart';

class CommonNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CommonNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        
        switch (index) {
          case 0:
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
            break;
          case 1:
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const CalendarPage()),
              (route) => false,
            );
            break;
          case 2:
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AnalysisPage()),
              (route) => false,
            );
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'ホーム',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: 'カレンダー',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart),
          label: '分析',
        ),
      ],
    );
  }
}