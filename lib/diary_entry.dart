class DiaryEntry {
  final String id;
  final String title;
  final String description;
  final String date; // Format: dd/MM/yyyy
  final String emotion;
  final DateTime updatedAt; // <-- Make sure this exists

  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.emotion,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now(); // <-- Default to now
}
