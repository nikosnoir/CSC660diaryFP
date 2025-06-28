import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'diary_entry.dart';
import 'emotions.dart';
import 'package:fl_chart/fl_chart.dart';

class CalendarPage extends StatefulWidget {
  final List<DiaryEntry> entries;
  const CalendarPage({super.key, required this.entries});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  DateTime _weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  Map<String, List<DiaryEntry>> get _entriesByDate {
    final map = <String, List<DiaryEntry>>{};
    for (final entry in widget.entries) {
      map.putIfAbsent(entry.date, () => []).add(entry);
    }
    return map;
  }

  Map<String, int> _weeklyEmotionCounts(DateTime weekStart) {
    final startOfWeek = weekStart;
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final counts = <String, int>{};
    for (final key in emotions.keys) {
      counts[key] = 0;
    }
    for (final entry in widget.entries) {
      final parts = entry.date.split('/');
      if (parts.length == 3) {
        final entryDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        if (!entryDate.isBefore(startOfWeek) && !entryDate.isAfter(endOfWeek)) {
          counts[entry.emotion] = (counts[entry.emotion] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  Widget _buildSimpleWeeklyBarChartBox() {
    final counts = _weeklyEmotionCounts(_weekStart);
    final emotionKeys = emotions.keys.toList();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    _weekStart = _weekStart.subtract(const Duration(days: 7));
                  });
                },
              ),
              Text(
                'Week of ${_weekStart.day.toString().padLeft(2, '0')}/${_weekStart.month.toString().padLeft(2, '0')}/${_weekStart.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    _weekStart = _weekStart.add(const Duration(days: 7));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: emotionKeys.map((key) {
              return Column(
                children: [
                  Text(
                    emotions[key] ?? '',
                    style: const TextStyle(fontSize: 28),
                  ),
                  Container(
                    height: 60,
                    width: 18,
                    alignment: Alignment.bottomCenter,
                    child: counts[key]! > 0
                        ? Container(
                            height: counts[key]!.toDouble() * 20, // bar height
                            width: 16,
                            color: Colors.blue,
                          )
                        : const SizedBox(height: 2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    counts[key].toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesByDate = _entriesByDate;
    return Column(
      children: [
        const SizedBox(height: 24),
        // Make calendar bigger again
        SizedBox(
          height: 360, // or remove SizedBox for default
          child: TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            eventLoader: (day) {
              final dateStr = "${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}";
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
                  final uniqueEmojis = <String>[];
                  for (final entry in events as List<DiaryEntry>) {
                    final emoji = emotions[entry.emotion] ?? emotions['Neutral'] ?? '😐';
                    if (emoji.isNotEmpty && !uniqueEmojis.contains(emoji)) {
                      uniqueEmojis.add(emoji);
                      if (uniqueEmojis.length == 2) break;
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: uniqueEmojis
                        .map((emoji) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ))
                        .toList(),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Entries for ${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}/${_selectedDay!.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        SizedBox(
          height: 160, // Reduce this if you want more space for the bottom box
          child: ListView(
            children: [
              ...((entriesByDate[_selectedDay == null
                      ? ''
                      : "${_selectedDay!.day.toString().padLeft(2, '0')}/${_selectedDay!.month.toString().padLeft(2, '0')}/${_selectedDay!.year}"] ??
                  [])
                  .map((entry) => ListTile(
                        title: Text(entry.title),
                        subtitle: Text(entry.description),
                        leading: Text(
                          emotions[entry.emotion] ?? emotions['Neutral'] ?? '😐',
                          style: const TextStyle(fontSize: 28),
                        ),
                      ))
                  .toList()),
            ],
          ),
        ),
        // Make the statistics box smaller
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                setState(() {
                  _weekStart = _weekStart.add(const Duration(days: 7));
                });
              } else if (details.primaryVelocity! > 0) {
                setState(() {
                  _weekStart = _weekStart.subtract(const Duration(days: 7));
                });
              }
            }
          },
          child: _buildSimpleWeeklyBarChartBox(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}