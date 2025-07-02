import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'emotions.dart';

class DiaryListPage extends StatelessWidget {
  final List<DiaryEntry> entries;
  final void Function(int, DiaryEntry) onEdit;
  final void Function(int) onDelete;

  const DiaryListPage({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary Entries')),
      body: entries.isEmpty
          ? const Center(child: Text('No diary entries yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final entry = entries[index];

                return Dismissible(
                  key: Key('${entry.title}_${entry.date}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text('Are you sure you want to delete this diary entry?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    onDelete(index);
                  },
                  child: ListTile(
                    leading: Text(
                      emotions[entry.emotion] ?? emotions['Neutral'] ?? '😐',
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(entry.title),
                    subtitle: Text('${entry.date}\n${entry.description}'),
                    onTap: () async {
                    },
                  ),
                );
              },
            ),
    );
  }
}
