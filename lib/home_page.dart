import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'diary_list_page.dart';
import 'placeholder_widget.dart';

class HomePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App name header
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: Text(
              'mydiary',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          // The grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // Diary box
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiaryListPage(
                          entries: entries,
                          onEdit: onEdit,
                          onDelete: onDelete,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.book, size: 40),
                        SizedBox(height: 8),
                        Text('Diary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Reserve box 1
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderWidget(label: 'Feature 1'),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('Feature 1')),
                  ),
                ),
                // Reserve box 2
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderWidget(label: 'Feature 2'),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('Feature 2')),
                  ),
                ),
                // Reserve box 3
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlaceholderWidget(label: 'Feature 3'),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text('Feature 3')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}