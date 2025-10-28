import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'meals_screen.dart';
import 'sleep_screen.dart';
import 'steps_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    StepsScreen(),
    SleepScreen(),
    MealsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk_outlined),
            label: 'Langkah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime_outlined),
            label: 'Tidur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            label: 'Makan',
          ),
        ],
      ),
    );
  }
}
