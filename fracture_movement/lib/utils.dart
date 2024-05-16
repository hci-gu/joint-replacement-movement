import 'package:fracture_movement/screens/questionnaire/classes.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int daysForAnswers(List<Answer> answers) {
  answers.sort((a, b) => a.date.compareTo(b.date));
  DateTime now = DateTime.now();
  DateTime first = answers.first.date;
  return now.difference(first).inDays + 1;
}
