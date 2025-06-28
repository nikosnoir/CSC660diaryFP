import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'diary_entry.dart';
import 'diary_detail_page.dart';
import 'add_diary_page.dart';
import 'emotions.dart';

class HomePage extends StatefulWidget {
  final List<DiaryEntry> entries;
  final void Function(DiaryEntry) onAdd;
  final void Function(String, DiaryEntry) onEdit;
  final void Function(String) onDeleteById;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomePage({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDeleteById,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DiaryEntry? _recentlyDeletedEntry;
  String _sortOption = 'Newest';

  List<DiaryEntry> get _sortedEntries {
    List<DiaryEntry> sorted = List.from(widget.entries);
    if (_sortOption == 'Newest') {
      sorted.sort((a, b) => _parseDate(b.date).compareTo(_parseDate(a.date)));
    } else if (_sortOption == 'Oldest') {
      sorted.sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));
    } else if (_sortOption == 'Emotion A-Z') {
      sorted.sort((a, b) => a.emotion.compareTo(b.emotion));
    } else if (_sortOption == 'Latest Add') {
      sorted = List.from(widget.entries); // Reverse add order
    }
    return sorted;
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  void _handleDeleteWithUndo(DiaryEntry entry) {
    setState(() {
      _recentlyDeletedEntry = entry;
      widget.onDeleteById(entry.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            if (_recentlyDeletedEntry != null) {
              widget.onAdd(_recentlyDeletedEntry!);
              setState(() {
                _recentlyDeletedEntry = null;
              });
            }
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _sortedEntries;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(child: Text('Menu', style: TextStyle(fontSize: 24))),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      isDarkMode: widget.isDarkMode,
                      onThemeChanged: widget.onThemeChanged,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _sortOption,
                        style: Theme.of(context).textTheme.bodyMedium,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: const [
                          DropdownMenuItem(value: 'Newest', child: Text('Newest')),
                          DropdownMenuItem(value: 'Oldest', child: Text('Oldest')),
                          DropdownMenuItem(value: 'Emotion A-Z', child: Text('Emotion A-Z')),
                          DropdownMenuItem(value: 'Latest Add', child: Text('Latest Add')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sortOption = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Dismissible(
                        key: Key(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _handleDeleteWithUndo(entry);
                        },
                        child: GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiaryDetailPage(
                                  entry: entry,
                                  onEdit: (updated) => widget.onEdit(entry.id, updated),
                                  onDelete: () {
                                    widget.onDeleteById(entry.id);
                                    Navigator.pop(context, 'deleted');
                                  },
                                ),
                              ),
                            );
                            if (result == 'deleted') {
                              widget.onDeleteById(entry.id);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  emotions[entry.emotion] ?? emotions['Neutral'] ?? '😐',
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(entry.title, style: const TextStyle(fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(
                                        entry.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 80,
        width: 80,
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, size: 36),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddDiaryPage()),
            );
            if (result is DiaryEntry) {
              widget.onAdd(result);
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalendarPage(entries: widget.entries),
                    ),
                  );
                },
              ),
              const SizedBox(width: 60),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(entries: widget.entries),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
