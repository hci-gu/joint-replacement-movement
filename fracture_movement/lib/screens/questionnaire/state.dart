import 'dart:math';

import 'package:fracture_movement/pocketbase.dart';
import 'package:fracture_movement/screens/history/state.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/storage.dart';
import 'package:fracture_movement/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:collection/collection.dart';

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
      DateTime next = occurance.nextOccurance(lastAnswered!);
      if (next.isAfter(DateTime.now())) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> get answersToSubmit {
    Map<String, dynamic> answersToSubmit = {};
    for (var key in answers.keys) {
      if (answers[key] is DateTime) {
        answersToSubmit[key] = (answers[key] as DateTime).toIso8601String();
      } else {
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
  build(String arg) async {
    Questionnaire questionnaire = await getQuestionnaire(arg);
    if (answers.isEmpty && questionnaire.id == 'o0kztzavvw04a8c') {
      answers['u1w0g5x75afluwp'] = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        12,
      );
      return questionnaire.copyWith(answers: answers);
    }
    return questionnaire;
  }

  void setPageIndex(int index) async {
    var nextState = await AsyncValue.guard(() async {
      return state.value!.copyWith(pageIndex: index);
    });

    state = nextState;
  }

  Future<bool> answer(String question, dynamic answer) async {
    state = await AsyncValue.guard(() async {
      Map<String, dynamic> answers = {
        ...state.value!.answers,
      };
      answers[question] = answer;
      return state.value!.copyWith(answers: answers);
    });
    return !state.value!.canSubmit;
  }

  Future submit([DateTime? date]) async {
    if (state.value != null) {
      await submitQuestionnaire(
        state.value!,
        ref.read(authProvider)!.record!.id,
        startDate,
        date ?? DateTime.now(),
      );
      if (state.value!.id == 'o0kztzavvw04a8c') {
        DateTime? eventDate;
        for (var value in state.value!.answersToSubmit.values) {
          // type of value is string
          if (value is String && DateTime.tryParse(value) != null) {
            eventDate = DateTime.parse(value);
          }
        }

        if (eventDate != null) {
          await Storage().storeEventDate(eventDate);
          ref.invalidate(eventDateProvider);
        }
      }

      if (state.value!.containsStepDataAccess) {
        // find answer of type date in answers
        DateTime date = state.value!.answers.values
            .firstWhere((element) => element is DateTime) as DateTime;

        String? personalId = Storage().getCredentials()?.personalNumber;
        if (personalId != null) {
          ref
              .read(healthDataProvider(DateTime(
                date.year - 1,
                date.month,
                date.day,
              )).notifier)
              .uploadData(personalId);
        }
      }
      ref.invalidate(questionnaireAnswersProvider(state.value!.id));
      ref.invalidate(answersProvider);
    }

    DateTime? lastSync = await getLastStepData();
    String? personalId = Storage().getCredentials()?.personalNumber;
    if (lastSync != null && personalId != null) {
      uploadLatestHealthData(personalId, lastSync);
    }
  }
}

class HomeScreenQuestionnaires {
  final int days;
  final Questionnaire daily;
  final List<Answer> dailyAnswers;
  final int weeks;
  final Questionnaire weekly;
  final List<Answer> weeklyAnswers;
  final List<Questionnaire> answered;
  final List<Questionnaire> unanswered;

  HomeScreenQuestionnaires({
    required this.days,
    required this.daily,
    required this.dailyAnswers,
    required this.weeks,
    required this.weekly,
    required this.weeklyAnswers,
    required this.unanswered,
    required this.answered,
  });

  bool get answeredEverything {
    int remainingDaily = days - dailyAnswers.length + 1;
    int remainingWeekly = weeks - weeklyAnswers.length + 1;

    return unanswered.isEmpty && remainingDaily == 0 && remainingWeekly == 0;
  }

  String get doneDescription {
    if (answeredEverything) {
      return 'Du har inga obesvarade frågeformulär, bra jobbat!';
    }
    if (unanswered.isEmpty) {
      return 'Du har svarat på dagens formulär. Men du har missat tidigare formulär.';
    }
    return '';
  }
}

final questionnairesProvider =
    FutureProvider<HomeScreenQuestionnaires>((ref) async {
  int days = ref.watch(questionnaireCountForOccuranceProvider(Occurance.daily));
  int weeks =
      ref.watch(questionnaireCountForOccuranceProvider(Occurance.weekly));
  List<Questionnaire> questionnaires = await getQuestionnaires();
  List<Answer> answers = await ref.watch(answersProvider.future);

  for (var questionnaire in questionnaires) {
    Answer? answer = answers.firstWhereOrNull(
      (element) => element.questionnaireId == questionnaire.id,
    );

    if (answer != null) {
      questionnaire.lastAnswered = answer.date;
    }
  }

  questionnaires.sortBy((element) => element.lastAnswered ?? DateTime.now());

  Questionnaire dailyQuestionnaire = questionnaires
      .firstWhere((element) => element.occurance == Occurance.daily);
  Questionnaire weeklyQuestionnaire = questionnaires
      .firstWhere((element) => element.occurance == Occurance.weekly);

  List<Answer> dailyAnswers = answers
      .where((element) => element.questionnaireId == dailyQuestionnaire.id)
      .toList();

  List<Answer> weeklyAnswers = answers
      .where((element) => element.questionnaireId == weeklyQuestionnaire.id)
      .toList();

  return HomeScreenQuestionnaires(
    days: days,
    daily: dailyQuestionnaire,
    dailyAnswers: dailyAnswers,
    weeks: weeks,
    weekly: weeklyQuestionnaire,
    weeklyAnswers: weeklyAnswers,
    unanswered: questionnaires.where((element) => !element.answered).toList(),
    answered: questionnaires
        .where((element) =>
            element.answered && element.occurance == Occurance.once)
        .toList(),
  );
});

final questionnaireProvider = AutoDisposeAsyncNotifierProviderFamily<
    QuestionnaireNotifier, Questionnaire, String>(QuestionnaireNotifier.new);

final answersProvider = FutureProvider<List<Answer>>((ref) => getAnswers());
