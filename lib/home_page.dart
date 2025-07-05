import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'diary_entry.dart';
import 'diary_detail_page.dart';
import 'add_diary_page.dart';
import 'emotions.dart';
import 'daily_quotes.dart';

class HomePage extends StatefulWidget {
  final List<DiaryEntry> entries;
  final void Function(DiaryEntry) onAdd;
  final void Function(String, DiaryEntry) onEdit;
  final void Function(String) onDeleteById;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.entries,
    required this.onAdd,
    required this.onEdit,
    required this.onDeleteById,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sortOption = 'Latest Added';
  String _searchQuery = '';
  String? _selectedEmotion;

  List<DiaryEntry> get _filteredEntries {
    List<DiaryEntry> entries = List.from(widget.entries);

    if (_selectedEmotion != null) {
      if (_selectedEmotion == 'Favorites') {
        entries = entries.where((e) => e.isFavorite).toList();
      } else {
        entries = entries.where((e) => e.emotion == _selectedEmotion).toList();
      }
    }

    if (_searchQuery.isNotEmpty) {
      entries = entries.where((e) =>
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (_sortOption == 'Latest Added') {
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortOption == 'Diary Date (Oldest First)') {
      entries.sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));
    } else if (_sortOption == 'Last Edited') {
      entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    return entries;
  }

  Map<String, List<DiaryEntry>> get _groupedEntries {
    final Map<String, List<DiaryEntry>> grouped = {};
    for (var entry in _filteredEntries) {
      grouped.putIfAbsent(entry.date, () => []).add(entry);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => _parseDate(b).compareTo(_parseDate(a)));
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  void _showUndoSnackBar(DiaryEntry entry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${entry.title}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => widget.onAdd(entry),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgImage = AssetImage(isDark ? 'assets/bg_dark.jpg' : 'assets/bg_light.jpg');
    final quoteOfDay = getQuoteOfTheDay();

    return Scaffold(
      drawer: Drawer(
        child: Column(
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
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: bgImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    '"$quoteOfDay"',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _sortOption,
                        items: const [
                          DropdownMenuItem(value: 'Latest Added', child: Text('Latest Added')),
                          DropdownMenuItem(value: 'Diary Date (Oldest First)', child: Text('Diary Date (Oldest First)')),
                          DropdownMenuItem(value: 'Last Edited', child: Text('Last Edited')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _sortOption = val);
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search diary...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text("Favorites", style: TextStyle(fontSize: 16)),
                          avatar: const Icon(Icons.star, size: 18),
                          selected: _selectedEmotion == 'Favorites',
                          onSelected: (_) {
                            setState(() {
                              _selectedEmotion = _selectedEmotion == 'Favorites' ? null : 'Favorites';
                            });
                          },
                        ),
                      ),
                      ...emotions.entries.map((e) {
                        final selected = _selectedEmotion == e.key;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(e.key, style: const TextStyle(fontSize: 16)),
                            avatar: Image.asset(e.value, height: 24),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedEmotion = selected ? null : e.key;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {}); // Triggers rebuild
                    },
                    child: _filteredEntries.isEmpty
                        ? const Center(child: Text("No diary entries found."))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _groupedEntries.length,
                            itemBuilder: (context, index) {
                              final date = _groupedEntries.keys.elementAt(index);
                              final entriesForDate = _groupedEntries[date]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8, top: 16),
                                    child: Text(
                                      date,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ...entriesForDate.map(_buildDiaryTile).toList(),
                                ],
                              );
                            },
                          ),
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
              MaterialPageRoute(builder: (_) => const AddDiaryPage()),
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarPage(entries: widget.entries)));
                },
              ),
              const SizedBox(width: 60),
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(entries: widget.entries)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryTile(DiaryEntry entry) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        widget.onDeleteById(entry.id);
        _showUndoSnackBar(entry);
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
              Image.asset(
                emotions[entry.emotion] ?? emotions['Neutral']!,
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(entry.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (entry.isFavorite)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Image.asset('assets/animations/favorite.gif', height: 32, width: 32),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
