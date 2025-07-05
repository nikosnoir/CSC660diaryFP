import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';
import 'diary_entry.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'globals.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  currentUserEmail = prefs.getString('loggedInEmail') ?? '';
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _showSplash = true;

  void _handleLogin(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInEmail', email);
    setState(() {
      currentUserEmail = email;
    });
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInEmail');
    setState(() {
      currentUserEmail = '';
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Diary',
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
      home: _showSplash
          ? const SplashScreen()
          : currentUserEmail.isEmpty
              ? LoginPage(onLogin: _handleLogin)
              : HomeWrapper(
                  isDarkMode: _isDarkMode,
                  onThemeChanged: (val) => setState(() => _isDarkMode = val),
                  onLogout: _handleLogout,
                ),
    );
  }
}

class HomeWrapper extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  const HomeWrapper({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  List<DiaryEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    if (currentUserEmail.isNotEmpty) {
      final loaded = await DBHelper().getEntries(currentUserEmail);
      setState(() {
        _entries = loaded;
        _isLoading = false;
      });
    }
  }

  Future<void> _addEntry(DiaryEntry entry) async {
    await DBHelper().insertEntry(entry);
    _loadEntries();
  }

  Future<void> _editEntry(String id, DiaryEntry updated) async {
    await DBHelper().updateEntry(updated);
    _loadEntries();
  }

  Future<void> _deleteEntry(String id) async {
    await DBHelper().deleteEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : HomePage(
            entries: _entries,
            onAdd: _addEntry,
            onEdit: _editEntry,
            onDeleteById: _deleteEntry,
            isDarkMode: widget.isDarkMode,
            onThemeChanged: widget.onThemeChanged,
            onLogout: widget.onLogout,
          );
  }
}
