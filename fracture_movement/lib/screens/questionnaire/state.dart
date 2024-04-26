import 'dart:math';

import 'package:fracture_movement/pocketbase.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:collection/collection.dart';

class Answer {
  final String questionnaireId;
  final Map<String, dynamic> answers;
  final DateTime created;

  const Answer({
    required this.questionnaireId,
    required this.answers,
    required this.created,
  });

  factory Answer.fromRecord(RecordModel record) {
    final Map<String, dynamic> data = record.data;

    return Answer(
      questionnaireId: data['questionnaire'],
      answers: data['answers'],
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

  Duration get duration {
    switch (this) {
      case Occurance.once:
        return const Duration(days: 0);
      case Occurance.daily:
        return const Duration(days: 1);
      case Occurance.weekly:
        return const Duration(days: 7);
      case Occurance.monthly:
        return const Duration(days: 30);
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

class Questionnaire {
  final String name;
  final String id;
  final String description;
  final Occurance occurance;
  final List<Question> questions;
  final Map<String, dynamic> answers;
  final int pageIndex;
  late DateTime? lastAnswered;

  Questionnaire({
    required this.name,
    required this.id,
    this.occurance = Occurance.once,
    this.description = '',
    this.questions = const [],
    this.answers = const {},
    this.pageIndex = 0,
    this.lastAnswered,
  });

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
    if (answers[current.id] == null) return false;

    return true;
  }

  bool get canSubmit {
    return availableQuestions.every((question) {
      if (question.dependsOn != null) {
        return answers[question.dependsOn!.question] ==
            question.dependsOn!.answer;
      }

      return answers[question.id] != null;
    });
  }

  bool get answered {
    if (lastAnswered != null) {
      if (occurance == Occurance.once) {
        return true;
      }
      return lastAnswered!.isAfter(DateTime.now().subtract(occurance.duration));
    }
    return false;
  }

  Map<String, dynamic> get answersToSubmit {
    Map<String, dynamic> answersToSubmit = {};
    // loop through all values in answers
    for (var key in answers.keys) {
      // check if value is DateTime
      if (answers[key] is DateTime) {
        // convert to iso8601 string
        answersToSubmit[key] = (answers[key] as DateTime).toIso8601String();
      } else {
        // otherwise just copy the value
        answersToSubmit[key] = answers[key];
      }
    }
    return answersToSubmit;
  }

  bool get containsStepDataAccess {
    return questions
        .any((element) => element.type == QuestionType.stepDataAccess);
  }

  Questionnaire copyWith({
    String? name,
    String? id,
    List<Question>? questions,
    Map<String, dynamic>? answers,
    int? pageIndex,
  }) =>
      Questionnaire(
        name: name ?? this.name,
        id: id ?? this.id,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        pageIndex: pageIndex ?? this.pageIndex,
      );

  factory Questionnaire.fromRecord(RecordModel record) {
    final List<Question> questions = record.expand['questions']!
        .map<Question>((e) => Question.fromRecord(e))
        .toList();

    return Questionnaire(
      id: record.id,
      name: record.data['name'],
      occurance: occuranceFromString(record.data['occurance'] ?? 'once'),
      description: record.data['description'] ?? '',
      questions: questions,
    );
  }
}

class QuestionnaireNotifier
    extends AutoDisposeFamilyAsyncNotifier<Questionnaire, String> {
  final Map<String, dynamic> answers = {};
  final DateTime startDate = DateTime.now();

  @override
  build(String arg) => getQuestionnaire(arg);

  void setPageIndex(int index) async {
    state = await AsyncValue.guard(() async {
      return state.value!.copyWith(pageIndex: index);
    });
  }

  void answer(String question, dynamic answer) async {
    state = await AsyncValue.guard(() async {
      Map<String, dynamic> answers = {
        ...state.value!.answers,
      };
      answers[question] = answer;
      return state.value!.copyWith(answers: answers);
    });
  }

  Future submit() async {
    if (state.value != null) {
      await submitQuestionnaire(
        state.value!,
        ref.read(authProvider)!.record!.id,
        startDate,
      );
      if (state.value!.containsStepDataAccess) {
        // find answer of type date in answers
        DateTime date = state.value!.answers.values
            .firstWhere((element) => element is DateTime) as DateTime;

        String? personalId = Storage().getCredentials()?.personalNumber;
        if (personalId != null) {
          ref.read(healthDataProvider(date).notifier).uploadData(personalId);
        }
      }
      ref.invalidate(answersProvider);
    }
  }
}

final questionnairesProvider = FutureProvider<List<Questionnaire>>((ref) async {
  List<Questionnaire> questionnaires = await getQuestionnaires();
  List<Answer> answers = await ref.watch(answersProvider.future);

  for (var questionnaire in questionnaires) {
    Answer? answer = answers.firstWhereOrNull(
      (element) => element.questionnaireId == questionnaire.id,
    );

    if (answer != null) {
      questionnaire.lastAnswered = answer.created;
    }
  }

  questionnaires.sortBy((element) => element.lastAnswered ?? DateTime.now());

  return questionnaires.reversed.toList();
});

final questionnaireProvider = AutoDisposeAsyncNotifierProviderFamily<
    QuestionnaireNotifier, Questionnaire, String>(QuestionnaireNotifier.new);

final answersProvider = FutureProvider<List<Answer>>((ref) => getAnswers());
