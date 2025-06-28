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
  String _filter = 'All'; // All = Yearly
  late PageController _pageController;
  late int _currentIndex;

  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentIndex = _getInitialIndex();
    _pageController = PageController(initialPage: _currentIndex);
  }

  int _getInitialIndex() {
    if (_filter == 'All') {
      final years = _generateYearList();
      return years.indexOf(_now.year);
    } else if (_filter == 'Monthly') {
      return _now.month - 1;
    } else {
      final weeks = _generateWeekList();
      for (int i = 0; i < weeks.length; i++) {
        final weekStart = weeks[i];
        final weekEnd = weekStart.add(const Duration(days: 6));
        if (!(_now.isBefore(weekStart) || _now.isAfter(weekEnd))) {
          return i;
        }
      }
    }
    return 0;
  }

  List<int> _generateYearList() {
    int currentYear = _now.year;
    return List.generate(5, (index) => currentYear - 2 + index);
  }

  List<DateTime> _generateMonthList() {
    return List.generate(12, (i) => DateTime(_now.year, i + 1));
  }

  List<DateTime> _generateWeekList() {
    final today = DateTime(_now.year, _now.month, _now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(5, (i) => weekStart.subtract(Duration(days: 7 * (2 - i))));
  }

  Map<String, int> _calculateEmotionCountsFor(DateTime period) {
    final counts = <String, int>{};
    for (final key in emotions.keys) {
      counts[key] = 0;
    }

    for (final entry in widget.entries) {
      try {
        final parts = entry.date.split('/');
        final entryDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );

        if (_filter == 'All') {
          if (entryDate.year == period.year) {
            counts[entry.emotion] = (counts[entry.emotion] ?? 0) + 1;
          }
        } else if (_filter == 'Monthly') {
          if (entryDate.year == period.year && entryDate.month == period.month) {
            counts[entry.emotion] = (counts[entry.emotion] ?? 0) + 1;
          }
        } else if (_filter == 'Weekly') {
          final weekStart = period;
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
    final List<dynamic> periods = _filter == 'All'
        ? _generateYearList()
        : _filter == 'Monthly'
            ? _generateMonthList()
            : _generateWeekList();

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
                          if (val != null) {
                            setState(() {
                              _filter = val;
                              _currentIndex = _getInitialIndex();
                              _pageController = PageController(initialPage: _currentIndex);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemCount: periods.length,
                      itemBuilder: (context, index) {
                        final period = periods[index];
                        final counts = _calculateEmotionCountsFor(
                            period is int ? DateTime(period) : period);
                        final highest = counts.values.isEmpty ? 1 : counts.values.reduce((a, b) => a > b ? a : b);
                        final label = _filter == 'All'
                            ? period.toString()
                            : _filter == 'Monthly'
                                ? '${_monthName(period.month)} ${period.year}'
                                : 'Week of ${_formatDate(period)}';

                        return Column(
                          children: [
                            Text(label, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: emotions.keys.map((key) {
                                final count = counts[key] ?? 0;
                                final barHeight = (count / highest) * 120;
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
                          ],
                        );
                      },
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

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
