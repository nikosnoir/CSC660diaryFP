import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'home_page.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import 'add_diary_page.dart';
import 'emotions.dart';

String _emotion = emotions.keys.first;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  int _selectedIndex = 0;
  List<DiaryEntry> _entries = [];

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _addEntry(DiaryEntry entry) {
    setState(() {
      _entries.insert(0, entry);
    });
  }

  void _editEntry(int index, DiaryEntry entry) {
    setState(() {
      _entries[index] = entry;
    });
  }

  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
    BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        entries: _entries,
        onAdd: _addEntry,
        onEdit: _editEntry,
        onDelete: _deleteEntry,
      ),
      const SizedBox.shrink(), // Add handled by navigation
      CalendarPage(entries: _entries),
      SettingsPage(
        isDarkMode: _isDarkMode,
        onThemeChanged: (val) => setState(() => _isDarkMode = val),
      ),
    ];

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Diary App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: _navItems,
          currentIndex: _selectedIndex,
          onTap: (index) async {
            if (index == 1) {
              final result = await _navigatorKey.currentState!.push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const AddDiaryPage(),
                  transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                ),
              );
              if (result is DiaryEntry) {
                _addEntry(result);
              }
              return;
            }
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}