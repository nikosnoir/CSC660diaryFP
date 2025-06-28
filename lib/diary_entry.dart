class DiaryEntry {
  String title;
  String description;
  String date; // Format: DD/MM/YYYY
  String emotion; // Should be one of the keys from emotions.dart

  DiaryEntry({
    required this.title,
    required this.description,
    required this.date,
    required this.emotion,
  });
}