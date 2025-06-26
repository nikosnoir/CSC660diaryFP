import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

final Map<String, String> _emotions = {
  'Happy': '😊',
  'Sad': '😢',
  'Angry': '😠',
  'Excited': '🤩',
  'Calm': '😌',
};

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

  void _onItemTapped(int index) async {
    if (index == 1) {
      // Add Entry with smooth transition
      final result = await Navigator.of(context).push(
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
      CalendarPage(entries: _entries), // <--- Use the real calendar page here
      SettingsPage(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
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

// Updated CalendarPage with table_calendar
class CalendarPage extends StatefulWidget {
  final List<DiaryEntry> entries;
  const CalendarPage({super.key, required this.entries});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Helper to group entries by date
  Map<String, List<DiaryEntry>> get _entriesByDate {
    final map = <String, List<DiaryEntry>>{};
    for (final entry in widget.entries) {
      map.putIfAbsent(entry.date, () => []).add(entry);
    }
    return map;
  }

  int _getWeeksInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;
    return ((firstWeekday - 1 + daysInMonth) / 7).ceil();
  }

  List<DateTime> _getWeekStartDates(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final weeks = <DateTime>[];
    DateTime weekStart = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    while (weekStart.month <= month.month && (weekStart.month < month.month || weekStart.day <= DateTime(month.year, month.month + 1, 0).day)) {
      weeks.add(weekStart);
      weekStart = weekStart.add(const Duration(days: 7));
    }
    return weeks;
  }

  Map<String, int> _emotionStatsForWeek(DateTime weekStart, List<DiaryEntry> entries) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final stats = <String, int>{};
    for (final e in _emotions.keys) {
      stats[e] = 0;
    }
    for (final entry in entries) {
      final entryDate = DateTime.tryParse(entry.date);
      if (entryDate != null && !entryDate.isBefore(weekStart) && !entryDate.isAfter(weekEnd)) {
        stats[entry.emotion] = (stats[entry.emotion] ?? 0) + 1;
      }
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final entriesByDate = _entriesByDate;
    final month = _focusedDay;
    final weekStarts = _getWeekStartDates(month);
    final entries = widget.entries;

    // Calculate initialWeekPage before returning the widget tree
    final int initialWeekPage = (() {
      if (_selectedDay == null) return 0;
      final idx = weekStarts.indexWhere((w) =>
          !w.isAfter(_selectedDay!) &&
          !w.add(const Duration(days: 6)).isBefore(_selectedDay!));
      return idx == -1 ? 0 : idx;
    })();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar View')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            eventLoader: (day) {
              final dateStr = "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
              return entriesByDate[dateStr] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (events as List<DiaryEntry>)
                        .map((e) => Text(
                              _emotions[e.emotion] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ))
                        .toList(),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          // Always a small box, just for emoji and text summary
          Container(
            height: 48,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedDay == null
                ? const Text(
                    'Select a day to view entries',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                : _buildDaySummary(entriesByDate),
          ),
          // --- Weekly Emotion Statistics ---
          Flexible(
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 320, // Make statistics box bigger
                child: PageView.builder(
                  itemCount: weekStarts.length,
                  controller: PageController(initialPage: initialWeekPage),
                  itemBuilder: (context, weekIndex) {
                    final weekStart = weekStarts[weekIndex];
                    final stats = _emotionStatsForWeek(weekStart, entries);
                    final weekEnd = weekStart.add(const Duration(days: 6));
                    final maxCount = stats.values.isEmpty ? 1 : (stats.values.reduce((a, b) => a > b ? a : b)).clamp(1, 999);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Week of ${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: _emotions.entries.map((e) {
                                  final count = stats[e.key] ?? 0;
                                  final barHeight = maxCount > 0 ? (count / maxCount) * 90 : 0; // reduce max bar height
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Bar on top
                                      Container(
                                        width: 28, // smaller bar width
                                        height: barHeight.toDouble(),
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueAccent.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Emoji and count below
                                      Text(e.value, style: const TextStyle(fontSize: 22)), // smaller emoji
                                      Text(
                                        '$count',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Remove the SizedBox(height: 8) at the bottom if you want to maximize space
        ],
      ),
    );
  }

  Widget _buildDaySummary(Map<String, List<DiaryEntry>> entriesByDate) {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }
    final dateStr = "${_selectedDay!.year.toString().padLeft(4, '0')}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
    final entries = entriesByDate[dateStr] ?? [];
    if (entries.isEmpty) {
      return const Text('No entries for this day', style: TextStyle(fontSize: 12, color: Colors.grey));
    }
    // Show all emojis and titles in a row
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Text(_emotions[entry.emotion] ?? '', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 4),
              Text(entry.title, style: const TextStyle(fontSize: 13)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildEntriesForSelectedDay(Map<String, List<DiaryEntry>> entriesByDate) {
    if (_selectedDay == null) {
      return const SizedBox.shrink();
    }
    final dateStr = "${_selectedDay!.year.toString().padLeft(4, '0')}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
    final entries = entriesByDate[dateStr] ?? [];
    if (entries.isEmpty) {
      return const Center(child: Text('No entries for this day'));
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          leading: Text(_emotions[entry.emotion] ?? '', style: const TextStyle(fontSize: 24)),
          title: Text(entry.title),
          subtitle: Text(entry.description),
        );
      },
    );
  }
}

class DiaryEntry {
  String title;
  String description;
  String date;
  String emotion;

  DiaryEntry({
    required this.title,
    required this.description,
    required this.date,
    required this.emotion,
  });
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
                  leading: Text(
                    _emotions[entry.emotion] ?? '❓',
                    style: const TextStyle(fontSize: 28),
                  ),
                  onTap: () => _openDetail(context, index),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                );
              },
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
  late String _emotion;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _title = widget.entry?.title ?? '';
    _description = widget.entry?.description ?? '';
    _emotion = widget.entry?.emotion ?? _emotions.keys.first;
    // Parse date if editing, else use today
    _selectedDate = widget.entry != null
        ? DateTime.tryParse(widget.entry!.date) ?? DateTime.now()
        : DateTime.now();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final entry = DiaryEntry(
        title: _title,
        description: _description,
        date: "${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
        emotion: _emotion,
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
              // Emotion selector at the top
              DropdownButtonFormField<String>(
                value: _emotion,
                decoration: const InputDecoration(
                  labelText: 'Emotion',
                  border: OutlineInputBorder(),
                ),
                items: _emotions.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text('${e.value} ${e.key}'),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _emotion = val);
                },
                onSaved: (val) => _emotion = val ?? _emotions.keys.first,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please select an emotion' : null,
              ),
              const SizedBox(height: 16),
              // Date picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Pick Date"),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emotion: ${_emotions[entry.emotion] ?? ''} ${entry.emotion}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(entry.description, style: const TextStyle(fontSize: 18)),
          ],
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