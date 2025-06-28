import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;
  List<DiaryEntry> _entries = [];

  void _addEntry(DiaryEntry entry) {
    setState(() {
      _entries.insert(0, entry);
    });
  }

  void _editEntry(String id, DiaryEntry updated) {
    setState(() {
      final index = _entries.indexWhere((e) => e.id == id);
      if (index != -1) {
        _entries[index] = updated;
      }
    });
  }

  void _deleteEntryById(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      debugShowCheckedModeBanner: false,
      home: HomePage(
        entries: _entries,
        onAdd: _addEntry,
        onEdit: _editEntry,
        onDeleteById: _deleteEntryById,
        isDarkMode: _isDarkMode,
        onThemeChanged: (val) => setState(() => _isDarkMode = val),
      ),
    );
  }
}
