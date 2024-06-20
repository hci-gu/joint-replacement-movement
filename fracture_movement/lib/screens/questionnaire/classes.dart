import 'package:pocketbase/pocketbase.dart';

class Answer {
  final String questionnaireId;
  final Map<String, dynamic> answers;
  final DateTime date;
  final DateTime created;

  const Answer({
    required this.questionnaireId,
    required this.answers,
    required this.date,
    required this.created,
  });

  factory Answer.fromRecord(RecordModel record) {
    final Map<String, dynamic> data = record.data;

    return Answer(
      questionnaireId: data['questionnaire'],
      answers: data['answers'],
      date: DateTime.parse(data['date']),
      created: DateTime.parse(record.created),
    );
  }
}

enum QuestionType {
  text,
  singleChoice,
  segmentControl,
  painMedication,
  painScale,
  date,
  stepDataAccess
}

QuestionType questionTypeForString(String value) {
  return QuestionType.values
      .firstWhere((e) => e.toString() == 'QuestionType.$value');
}

enum Occurance {
  once,
  daily,
  weekly,
  monthly,
}

extension OccuranceExtensions on Occurance {
  String get display {
    switch (this) {
      case Occurance.once:
        return 'Engångs';
      case Occurance.daily:
        return 'Dagligen';
      case Occurance.weekly:
        return 'Veckovis';
      case Occurance.monthly:
        return 'Månadsvis';
    }
  }

  DateTime nextOccurance(DateTime lastAnswered) {
    switch (this) {
      case Occurance.once:
        return DateTime.utc(3000);
      case Occurance.daily:
        return DateTime(
          lastAnswered.year,
          lastAnswered.month,
          lastAnswered.day + 1,
        );
      case Occurance.weekly:
        int weekday = lastAnswered.weekday;

        int daysUntilMonday;
        if (weekday == DateTime.sunday) {
          daysUntilMonday = 1;
        } else {
          daysUntilMonday = (8 - weekday) % 7;
        }
        return DateTime(
          lastAnswered.year,
          lastAnswered.month,
          lastAnswered.day + daysUntilMonday,
        );
      case Occurance.monthly:
        return DateTime(
          lastAnswered.year,
          lastAnswered.month + 1,
          1,
        );
    }
  }
}

Occurance occuranceFromString(String value) {
  return Occurance.values.firstWhere((e) => e.toString() == 'Occurance.$value');
}

class Dependency {
  final String question;
  final String answer;

  const Dependency({required this.question, required this.answer});
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final String? introduction;
  final String? placeholder;
  final Dependency? dependsOn;
  final String? valueFromQuestion;

  const Question({
    this.id = '',
    required this.text,
    this.type = QuestionType.text,
    this.options = const [],
    this.introduction,
    this.placeholder,
    this.dependsOn,
    this.valueFromQuestion,
  });

  factory Question.fromRecord(RecordModel record) {
    final Map<String, dynamic> data = record.data;
    final Map<String, dynamic> expand = record.expand;

    // final List<String> options = record.expand['options'] ?? [];
    final Dependency? dependsOn = data['dependency'].isNotEmpty
        ? Dependency(
            question: data['dependency'],
            answer: data['dependencyValue'],
          )
        : null;

    List<String> options = [];
    if (expand['options'] != null) {
      RecordModel optionsRecord = expand['options'].first;
      List<dynamic> values = optionsRecord.data['value'];

      options = values.map((e) => e.toString()).toList();
    }

    return Question(
      id: record.id,
      text: data['text'],
      type: QuestionType.values
          .firstWhere((e) => e.toString() == 'QuestionType.${data['type']}'),
      options: options,
      introduction:
          data['introduction'].isNotEmpty ? data['introduction'] : null,
      placeholder: data['placeholder'].isNotEmpty ? data['placeholder'] : null,
      dependsOn: dependsOn,
      valueFromQuestion: data['valueFromQuestion'],
    );
  }
}
