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
                print('entry.emotion: "${entry.emotion}"');
                return ListTile(
                  leading: Text(
                    emotions[entry.emotion] ?? emotions['Neutral'] ?? '😐',
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(entry.title),
                  subtitle: Text('${entry.date}\n${entry.description}'),
                  // Optionally, add edit/delete actions here
                );
              },
            ),
    );
  }
}