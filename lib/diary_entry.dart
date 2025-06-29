
class DiaryEntry {
  final String id;
  final String title;
  final String description;
  final String date; // format: dd/MM/yyyy
  final String emotion;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.emotion,
    required this.updatedAt,
  });

  // Convert DiaryEntry to Map (for saving to SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'emotion': emotion,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convert Map (from SQLite) back to DiaryEntry
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      emotion: map['emotion'],
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
