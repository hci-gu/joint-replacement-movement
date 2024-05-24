import 'package:fracture_movement/screens/questionnaire/classes.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isSameWeek(DateTime a, DateTime b) {
  DateTime startOfWeek(DateTime date) {
    // Assuming the week starts on Monday
    int dayOfWeek =
        date.weekday; // DateTime.weekday returns 1 for Monday, 7 for Sunday
    DateTime startOfWeek = date.subtract(Duration(days: dayOfWeek - 1));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  DateTime startOfWeek1 = startOfWeek(a);
  DateTime startOfWeek2 = startOfWeek(b);

  return startOfWeek1 == startOfWeek2;
}

int daysForAnswers(List<Answer> answers) {
  if (answers.isEmpty) return 0;

  answers.sort((a, b) => a.date.compareTo(b.date));
  DateTime now = DateTime.now();
  DateTime first = answers.first.date;
  return now.difference(first).inDays + 1;
}

int weeksForAnswers(List<Answer> answers) {
  if (answers.isEmpty) return 0;

  answers.sort((a, b) => a.date.compareTo(b.date));
  DateTime now = DateTime.now();
  DateTime first = answers.first.date;
  return now.difference(first).inDays ~/ 7 + 1;
}