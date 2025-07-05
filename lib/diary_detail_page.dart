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

  void _showFavoriteAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/animations/favorite.gif', height: 100),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // close dialog
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Details'),
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
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text('Are you sure you want to delete this diary entry?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirm == true) {
                onDelete();
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // EMOTION IMAGE
            Row(
              children: [
                Image.asset(
                  emotions[entry.emotion] ?? 'assets/emojis/neutral_emoji.gif',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 8),
                Text(entry.date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: entry.isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    final updatedEntry = DiaryEntry(
                      id: entry.id,
                      title: entry.title,
                      description: entry.description,
                      date: entry.date,
                      emotion: entry.emotion,
                      user: entry.user,
                      createdAt: entry.createdAt,
                      updatedAt: DateTime.now(),
                      isFavorite: !entry.isFavorite,
                    );
                    onEdit(updatedEntry);
                    _showFavoriteAnimation(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(entry.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(entry.description, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
