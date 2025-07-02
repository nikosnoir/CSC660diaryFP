// daily_quotes.dart
final List<String> _quotes = [
  "Keep your face always toward the sunshine—and shadows will fall behind you.",
  "Every day is a fresh start.",
  "You are capable of amazing things.",
  "Today is your opportunity to build the tomorrow you want.",
  "A little progress each day adds up to big results.",
  "Believe in yourself and all that you are.",
  "Don’t count the days, make the days count.",
  "You are stronger than you think.",
  "Progress, not perfection.",
  "Great things never come from comfort zones.",
];

String getQuoteOfTheDay() {
  final today = DateTime.now();
  final index = today.day % _quotes.length;
  return _quotes[index];
}
