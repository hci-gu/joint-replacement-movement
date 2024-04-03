import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/questionnaire/questionnaires/profile.dart';
import 'package:fracture_movement/screens/questionnaire/questionnaires/test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum QuestionType {
  text,
  singleChoice,
  segmentControl,
  painMedication,
  painScale,
  date,
}

class Dependency {
  final String question;
  final String answer;

  const Dependency({required this.question, required this.answer});
}

class Question {
  final String text;
  final QuestionType type;
  final List<String> options;
  final Dependency? dependsOn;

  const Question({
    required this.text,
    this.type = QuestionType.text,
    this.options = const [],
    this.dependsOn,
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

  Question get current => availableQuestions[currentQuestion];
  String get progress =>
      '${currentQuestion + 1} / ${availableQuestions.length.toString()}';
  bool get isLast => currentQuestion == availableQuestions.length - 1;
  List<Question> get availableQuestions {
    return questions
        .where((question) =>
            (question.dependsOn == null ||
                answers[question.dependsOn!.question] == null) ||
            (answers[question.dependsOn!.question] ==
                question.dependsOn!.answer))
        .toList();
  }

  void setCurrentQuestion(int index) {
    currentQuestion = index;
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

final questionnaireProvider = ChangeNotifierProvider.family((ref, id) {
  switch (id) {
    case 'profile':
      return profileQuestionnaire;
    default:
      return testQuestionnaire;
  }
});
