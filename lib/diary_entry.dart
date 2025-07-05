class DiaryEntry {
  final String id;
  final String title;
  final String description;
  final String date;
  final String emotion;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;

  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.emotion,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'emotion': emotion,
      'user': user,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      emotion: map['emotion'],
      user: map['user'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }
}
