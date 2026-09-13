import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../screens/watchlist/watchlist_screen.dart';
import '../screens/search/search_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  final _screens = const [WatchlistScreen(), SearchScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: context.colors.navActive,
        unselectedItemColor: context.colors.navInactive,
        backgroundColor: context.colors.surfaceRaised,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '관심'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
        ],
      ),
    );
  }
}
