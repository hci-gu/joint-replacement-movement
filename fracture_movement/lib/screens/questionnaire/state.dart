import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/questionnaire/questionnaires/profile.dart';
import 'package:fracture_movement/screens/questionnaire/questionnaires/smfa.dart';
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
  final String? introduction;
  final String? placeholder;
  final Dependency? dependsOn;

  const Question({
    required this.text,
    this.type = QuestionType.text,
    this.options = const [],
    this.introduction,
    this.placeholder,
    this.dependsOn,
  });
}

class Questionnaire extends ChangeNotifier {
  final String name;
  final List<Question> questions;
  late Map<String, dynamic> answers;
  int pageIndex = 0;

  Questionnaire({required this.name, this.questions = const []}) {
    answers = {for (var question in questions) question.text: null};
  }

  List<String> get pageTypes {
    List<String> pages = [];
    for (var question in availableQuestions) {
      if (question.introduction != null) {
        pages.add('intro');
      }
      pages.add('question');
    }
    return pages;
  }

  Question get current {
    int intros = 0;
    for (int i = 0; i < min(availableQuestions.length, pageIndex); i++) {
      if (availableQuestions[i].introduction != null) {
        intros++;
      }
    }
    return availableQuestions[max(0, pageIndex - intros)];
  }

  String get lastIntroduction {
    if (currentIsIntro) return '';
    for (int i = min(availableQuestions.length - 1, pageIndex); i >= 0; i--) {
      if (availableQuestions[i].introduction != null) {
        return availableQuestions[i].introduction!;
      }
    }
    return '';
  }

  bool get currentIsIntro => pageTypes[pageIndex] == 'intro';

  double get progressValue =>
      availableQuestions.indexOf(current) / (availableQuestions.length - 1);
  String get progress =>
      '${availableQuestions.indexOf(current) + 1} / ${availableQuestions.length.toString()}';
  bool get isLast => current == availableQuestions.last;
  List<Question> get availableQuestions {
    return questions
        .where((question) =>
            (question.dependsOn == null ||
                answers[question.dependsOn!.question] == null) ||
            (answers[question.dependsOn!.question] ==
                question.dependsOn!.answer))
        .toList();
  }

  bool get canGoForward {
    if (currentIsIntro) return true;
    if (answers[current.text] == null) return false;

    return true;
  }

  void setPageIndex(int index) {
    pageIndex = index;
    notifyListeners();
  }

  void answer(dynamic answer) {
    answers[current.text] = answer;
    notifyListeners();
  }

  void submit() {
    print(answers);
    notifyListeners();
  }
}

final questionnaireProvider =
    ChangeNotifierProvider.family.autoDispose((ref, id) {
  switch (id) {
    case 'smfa':
      return smfaQuestionnaire();
    case 'profile':
      return profileQuestionnaire();
    default:
      return testQuestionnaire();
  }
});
