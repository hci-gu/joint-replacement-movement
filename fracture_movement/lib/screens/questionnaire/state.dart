import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum QuestionType {
  text,
  singleChoice,
  segmentControl,
  painMedication,
  painScale,
}

class Question {
  final String text;
  final QuestionType type;
  final List<String> options;

  const Question({
    required this.text,
    this.type = QuestionType.text,
    this.options = const [],
  });
}

class Questionnaire extends ChangeNotifier {
  final String name;
  final List<Question> questions;
  late Map<String, dynamic> answers;
  int currentQuestion = 0;

  Questionnaire({required this.name, this.questions = const []}) {
    answers = {for (var question in questions) question.text: null};
  }

  Question get current => questions[currentQuestion];
  String get progress =>
      '${currentQuestion + 1} / ${questions.length.toString()}';
  bool get isLast => currentQuestion == questions.length - 1;

  void setCurrentQuestion(int index) {
    currentQuestion = index;
    notifyListeners();
  }

  void next() {
    currentQuestion++;
    notifyListeners();
  }

  void previous() {
    currentQuestion--;
    notifyListeners();
  }

  void answer(dynamic answer) {
    answers[current.text] = answer;
    notifyListeners();
  }

  void submit() {
    print(answers);
  }
}

final questionnaireProvider = ChangeNotifierProvider.family(
  (ref, id) => Questionnaire(
    name: 'Hur går det?',
    questions: const [
      Question(
        text: 'Test question segment',
        type: QuestionType.segmentControl,
        options: [
          'Ja',
          'Nej',
        ],
      ),
      Question(
        text:
            'Ungefär hur många värktabletter av olika slag har du tagit idag?',
        type: QuestionType.painMedication,
      ),
      Question(
        text: 'Test question pain',
        type: QuestionType.painScale,
      ),
      Question(
        text: 'Test question',
        type: QuestionType.singleChoice,
        options: [
          'Option 1',
          'Option 2',
          'Option 3',
        ],
      ),
      Question(
        text: 'Vilken är din huvudsakliga sysselsättning',
        type: QuestionType.singleChoice,
        options: [
          'Arbete',
          'Studier',
          'Arbetslös',
          'Sjukskriven',
          'Pensionär',
        ],
      ),
      Question(text: 'Last question'),
    ],
  ),
);
