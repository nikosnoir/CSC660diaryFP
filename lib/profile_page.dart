import 'package:flutter/material.dart';
import 'diary_entry.dart';
import 'emotions.dart';

class ProfilePage extends StatefulWidget {
  final List<DiaryEntry> entries;

  const ProfilePage({super.key, required this.entries});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _filter = 'All'; // All, Monthly, Weekly

  Map<String, int> _calculateEmotionCounts() {
    final counts = <String, int>{};
    final now = DateTime.now();

    for (final key in emotions.keys) {
      counts[key] = 0;
    }

    for (final entry in widget.entries) {
      try {
        final parts = entry.date.split('/');
        final entryDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));

        if (_filter == 'All') {
          counts[entry.emotion] = (counts[entry.emotion] ?? 0) + 1;
        } else if (_filter == 'Monthly') {
          if (entryDate.year == now.year && entryDate.month == now.month) {
            counts[entry.emotion] = (counts[entry.emotion] ?? 0) + 1;
          }
        } else if (_filter == 'Weekly') {
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));

          if (!entryDate.isBefore(weekStart) && !entryDate.isAfter(weekEnd)) {
            counts[entry.emotion] = (counts[entry.emotion] ?? 0) + 1;
          }
        }
      } catch (_) {}
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _calculateEmotionCounts();
    final highestCount = counts.values.isNotEmpty
        ? counts.values.reduce((a, b) => a > b ? a : b)
        : 1;

    final emotionKeys = emotions.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Title and Dropdown in same row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mood Report',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: _filter,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('Yearly')),
                          DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _filter = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  counts.isEmpty
                      ? const Center(child: Text('No data to display.'))
                      : SizedBox(
                          height: 220,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: emotionKeys.map((key) {
                              final count = counts[key]!;
                              final barHeight = (count / highestCount) * 120;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(emotions[key] ?? '😐', style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 20,
                                    height: barHeight.isNaN ? 0 : barHeight,
                                    decoration: BoxDecoration(
                                      color: count > 0 ? Colors.blue : Colors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$count'),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('More profile features coming soon...'),
          ],
        ),
      ),
    );
  }
}
