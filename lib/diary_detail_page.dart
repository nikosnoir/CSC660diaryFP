import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'emotions.dart';
import 'add_diary_page.dart';

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
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context, 'deleted');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${emotions[entry.emotion] ?? emotions['Neutral'] ?? '😐'} ${entry.date}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(entry.description, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}