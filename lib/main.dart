import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'home_page.dart';
import 'db_helper.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntriesFromDB();
  }

  Future<void> _loadEntriesFromDB() async {
    final loadedEntries = await DBHelper.getEntries();
    setState(() {
      _entries = loadedEntries;
      _isLoading = false;
    });
  }

  Future<void> _addEntry(DiaryEntry entry) async {
    await DBHelper.insertEntry(entry);
    _loadEntriesFromDB();
  }

  Future<void> _editEntry(String id, DiaryEntry updated) async {
    await DBHelper.updateEntry(updated);
    _loadEntriesFromDB();
  }

  Future<void> _deleteEntryById(String id) async {
    await DBHelper.deleteEntry(id);
    _loadEntriesFromDB();
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
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : HomePage(
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
