import 'package:flutter/material.dart';

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

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
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
      home: MainNavigation(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  const MainNavigation({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Move entries here
  List<DiaryEntry> _entries = [];

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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Pass entries and methods to HomePage
      HomePage(
        entries: _entries,
        onAdd: _addEntry,
        onEdit: _editEntry,
        onDelete: _deleteEntry,
      ),
      const PlaceholderWidget(label: "Reserved 1"),
      const SizedBox.shrink(),
      const PlaceholderWidget(label: "Reserved 2"),
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  void _onItemTapped(int index) async {
    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddDiaryPage()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Reserved 1'),
    BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
    BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Reserved 2'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class DiaryEntry {
  String title;
  String description;
  String date;

  DiaryEntry({required this.title, required this.description, required this.date});
}

class HomePage extends StatefulWidget {
  final List<DiaryEntry> entries;
  final void Function(DiaryEntry) onAdd;
  final void Function(int, DiaryEntry) onEdit;
  final void Function(int) onDelete;

  const HomePage({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openAddDiary(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDiaryPage()),
    );
    if (result is DiaryEntry) {
      widget.onAdd(result);
      setState(() {}); // Refresh UI
    }
  }

  void _openDetail(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryDetailPage(
          entry: widget.entries[index],
          onEdit: (editedEntry) {
            widget.onEdit(index, editedEntry);
            setState(() {});
          },
          onDelete: () {
            widget.onDelete(index);
            setState(() {});
          },
        ),
      ),
    );
    if (result == 'deleted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary entry deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
        centerTitle: true,
        elevation: 0,
      ),
      body: widget.entries.isEmpty
          ? const Center(child: Text('No diary entries yet.', style: TextStyle(fontSize: 16)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: widget.entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = widget.entries[index];
                return ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    '${entry.date}\n${entry.description}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _openDetail(context, index),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddDiary(context),
        tooltip: 'Add Diary Entry',
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddDiaryPage extends StatefulWidget {
  final DiaryEntry? entry;
  const AddDiaryPage({super.key, this.entry});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;

  @override
  void initState() {
    super.initState();
    _title = widget.entry?.title ?? '';
    _description = widget.entry?.description ?? '';
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final entry = DiaryEntry(
        title: _title,
        description: _description,
        date: widget.entry?.date ?? DateTime.now().toString().split(' ')[0],
      );
      Navigator.pop(context, entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Entry' : 'New Entry'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _title = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onSaved: (val) => _description = val ?? '',
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  child: Text(isEditing ? 'Save Changes' : 'Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiaryDetailPage extends StatelessWidget {
  final DiaryEntry entry;
  final ValueChanged<DiaryEntry> onEdit;
  final VoidCallback onDelete;

  const DiaryDetailPage({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDiaryPage(entry: entry),
                ),
              );
              if (result is DiaryEntry) {
                onEdit(result);
                Navigator.pop(context);
              }
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content: const Text('Are you sure you want to delete this entry?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                onDelete();
                Navigator.pop(context, 'deleted');
              }
            },
            tooltip: 'Delete',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          entry.description,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  const SettingsPage({super.key, required this.isDarkMode, required this.onThemeChanged});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _isDarkMode = widget.isDarkMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const CircleAvatar(
          radius: 40,
          child: Icon(Icons.person, size: 60, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Your Name',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 32),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: _isDarkMode,
          onChanged: (val) {
            setState(() {
              _isDarkMode = val;
            });
            widget.onThemeChanged(val);
          },
        ),
      ],
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String label;
  const PlaceholderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.grey,
        ),
      ),
    );
  }
}