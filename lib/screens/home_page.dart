import 'package:flutter/material.dart';
import 'package:focuszen/theme.dart';
import 'package:focuszen/screens/focus_screen.dart';
import 'package:focuszen/screens/shop_screen.dart';
import 'package:focuszen/screens/stats_screen.dart' show StatsScreen;
import 'package:provider/provider.dart';
import 'package:focuszen/services/session_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FocusScreen(),
    ShopScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLocked = context.watch<SessionService>().isFocusLocked;

    if (isLocked && _selectedIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedIndex = 0);
      });
    }

    return PopScope(
      canPop: !isLocked,
      child: Scaffold(
        body: isLocked ? const FocusScreen() : _screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            border: Border(
              top: BorderSide(color: AppColors.darkCardBorder.withValues(alpha: 0.3), width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: isLocked ? 0 : _selectedIndex,
            onTap: (index) {
              if (isLocked) return;
              setState(() => _selectedIndex = index);
            },
            backgroundColor: AppColors.darkBackground,
            selectedItemColor: AppColors.purple,
            unselectedItemColor: AppColors.ashGray,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.timelapse),
                label: 'Odak',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: 'Mağaza',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'İstatistik',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
