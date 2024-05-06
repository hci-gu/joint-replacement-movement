library movement_code;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/storage.dart';
import 'package:permission_handler/permission_handler.dart';

export 'package:health/health.dart';

List<HealthDataType> types = [
  HealthDataType.STEPS,
  HealthDataType.WALKING_SPEED,
  HealthDataType.WALKING_ASYMMETRY_PERCENTAGE,
  HealthDataType.WALKING_STEADINESS,
  HealthDataType.WALKING_DOUBLE_SUPPORT_PERCENTAGE,
  HealthDataType.WALKING_STEP_LENGTH,
];
List<HealthDataAccess> permissions = [
  HealthDataAccess.READ,
  HealthDataAccess.READ,
  HealthDataAccess.READ,
  HealthDataAccess.READ,
  HealthDataAccess.READ,
  HealthDataAccess.READ
];

class HealthData {
  final Map<HealthDataType, List<HealthDataPoint>> data;
  final bool isAuthorized;
  final bool authorizationFailed;
  final bool triedToAuthorize;

  HealthData(
    this.data, {
    required this.isAuthorized,
    required this.authorizationFailed,
    required this.triedToAuthorize,
  });

  List<HealthDataType> get types => data.keys.toList();

  List<HealthDataPoint> itemsForType(HealthDataType type) {
    return data[type] ?? [];
  }

  List<HealthDataPoint> get allItems {
    return data.values.expand((element) => element).toList();
  }

  bool get hasData => data.values.any((element) => element.isNotEmpty);
}

Future uploadLatestHealthData(String personalId, DateTime from) async {
  HealthFactory health = HealthFactory();
  List<HealthDataPoint> healthData =
      await health.getHealthDataFromTypes(from, DateTime.now(), types);
  Map<HealthDataType, List<HealthDataPoint>> healthDataMap = {};

  for (var type in types) {
    healthDataMap[type] =
        healthData.where((element) => element.type == type).toList();
  }
  healthDataMap.removeWhere((key, value) => value.isEmpty);

  HealthData data = HealthData(
    healthDataMap,
    isAuthorized: true,
    authorizationFailed: false,
    triedToAuthorize: true,
  );

  await Api().uploadData(personalId, data.allItems);
}

class HealthDataManager
    extends AutoDisposeFamilyAsyncNotifier<HealthData, DateTime> {
  HealthFactory health = HealthFactory();
  bool isAuthorized = false;
  bool authorizationFailed = false;
  bool triedToAuthorize = false;

  @override
  FutureOr<HealthData> build(DateTime arg) async {
    List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(arg, DateTime.now(), types);
    Map<HealthDataType, List<HealthDataPoint>> healthDataMap = {};

    for (var type in types) {
      healthDataMap[type] =
          healthData.where((element) => element.type == type).toList();
    }
    healthDataMap.removeWhere((key, value) => value.isEmpty);

    return HealthData(
      healthDataMap,
      isAuthorized: isAuthorized,
      authorizationFailed: authorizationFailed,
      triedToAuthorize: triedToAuthorize,
    );
  }

  Future authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    isAuthorized =
        await health.requestAuthorization(types, permissions: permissions);

    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    if (!isAuthorized || hasPermissions != true) {
      authorizationFailed = true;
    }
    triedToAuthorize = true;
    ref.invalidateSelf();
  }

  Future uploadData(String personalId) async {
    if (ref.watch(dataUploadProvider) != null ||
        state.value == null ||
        state.value!.allItems.isEmpty) {
      return;
    }
    Future request = Api().uploadData(personalId, state.value!.allItems);

    ref.read(dataUploadProvider.notifier).state = request;
  }
}

final dataUploadProvider = StateProvider<Future?>((ref) => null);

final healthDataProvider = AutoDisposeAsyncNotifierProviderFamily<
    HealthDataManager, HealthData, DateTime>(
  HealthDataManager.new,
);

final personalIdProvider =
    StateProvider<String>((ref) => Storage().getPersonalid() ?? '');
final consentProvider = StateProvider<bool>((ref) => false);
final operationDateProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final onboardingStepProvider = StateProvider((ref) => 0);

enum QuestionDuration1 {
  zero,
  lessThan30,
  between30And60,
  between60And90,
  between90And120,
  moreThan120,
}

extension QuestionDuration1Display on QuestionDuration1 {
  String get displayString {
    switch (this) {
      case QuestionDuration1.zero:
        return '0 minuter / Ingen tid';
      case QuestionDuration1.lessThan30:
        return 'Mindre än 30 minuter';
      case QuestionDuration1.between30And60:
        return '30–60 minuter (0,5–1 timme)';
      case QuestionDuration1.between60And90:
        return '60–90 minuter (1–1,5 timmar)';
      case QuestionDuration1.between90And120:
        return '90–120 minuter (1,5–2 timmar)';
      case QuestionDuration1.moreThan120:
        return 'Mer än 120 minuter (2 timmar)';
    }
  }
}

enum QuestionDuration2 {
  zero,
  lessThan30,
  between30And60,
  between60And90,
  between90And150,
  between150And300,
  moreThan300,
}

extension QuestionDuration2Display on QuestionDuration2 {
  String get displayString {
    switch (this) {
      case QuestionDuration2.zero:
        return '0 minuter / Ingen tid';
      case QuestionDuration2.lessThan30:
        return 'Mindre än 30 minuter';
      case QuestionDuration2.between30And60:
        return '30–60 minuter (0,5–1 timme)';
      case QuestionDuration2.between60And90:
        return '60–90 minuter (1–1,5 timmar)';
      case QuestionDuration2.between90And150:
        return '90–150 minuter (1,5–2,5 timmar)';
      case QuestionDuration2.between150And300:
        return '150–300 minuter (2,5–5 timmar)';
      case QuestionDuration2.moreThan300:
        return 'Mer än 300 minuter (5 timmar)';
    }
  }
}

class MovementForm extends ChangeNotifier {
  double movementChange;
  QuestionDuration1? questionDuration1;
  QuestionDuration2? questionDuration2;

  MovementForm({
    this.movementChange = 0,
    this.questionDuration1,
    this.questionDuration2,
  });

  setMovementChange(double value) {
    movementChange = value;
    notifyListeners();
  }

  setQuestion1(QuestionDuration1? value) {
    questionDuration1 = value;
    notifyListeners();
  }

  setQuestion2(QuestionDuration2? value) {
    questionDuration2 = value;
    notifyListeners();
  }

  Future submitQuestionnaire(String personalId) async {
    if (Storage().getQuestionnaireDone('questionnaire1')) {
      return;
    }

    try {
      await Api()
          .submitQuestionnaire(personalId, 'questionnaire1', getAnswers());
    } catch (_) {
      return;
    }

    Storage().storeQuestionnaireDone('questionnaire1');
  }

  Map<String, dynamic> getAnswers() {
    return {
      'question1': movementChange,
      'question2': questionDuration1?.displayString,
      'question3': questionDuration2?.displayString,
    };
  }
}

final movementFormProvider =
    ChangeNotifierProvider<MovementForm>((ref) => MovementForm());

enum QuestionSatisfied {
  verySatisfied,
  satisfied,
  neutral,
  dissatisfied,
  veryDissatisfied,
}

extension QuestionSatisfiedDisplay on QuestionSatisfied {
  String get displayString {
    switch (this) {
      case QuestionSatisfied.verySatisfied:
        return 'Mycket nöjd';
      case QuestionSatisfied.satisfied:
        return 'Nöjd';
      case QuestionSatisfied.neutral:
        return 'Neutral';
      case QuestionSatisfied.dissatisfied:
        return 'Missnöjd';
      case QuestionSatisfied.veryDissatisfied:
        return 'Mycket missnöjd';
    }
  }
}

class AppForm extends ChangeNotifier {
  QuestionSatisfied? questionSatisfied1;
  QuestionSatisfied? questionSatisfied2;
  String understanding;
  String comments;

  AppForm({
    this.questionSatisfied1,
    this.questionSatisfied2,
    this.understanding = '',
    this.comments = '',
  });

  setQuestion1(QuestionSatisfied? value) {
    questionSatisfied1 = value;
    notifyListeners();
  }

  setQuestion2(QuestionSatisfied? value) {
    questionSatisfied2 = value;
    notifyListeners();
  }

  setUnderStanding(String value) {
    understanding = value;
    notifyListeners();
  }

  setComments(String value) {
    comments = value;
    notifyListeners();
  }

  bool get canSubmit =>
      questionSatisfied1 != null && questionSatisfied2 != null;

  Future submitQuestionnaire(String personalId) async {
    if (Storage().getQuestionnaireDone('questionnaire2')) {
      return;
    }

    try {
      await Api()
          .submitQuestionnaire(personalId, 'questionnaire2', getAnswers());
    } catch (_) {
      return;
    }

    Storage().storeQuestionnaireDone('questionnaire2');
    notifyListeners();
  }

  Map<String, dynamic> getAnswers() {
    return {
      'question1': questionSatisfied1?.displayString,
      'question2': questionSatisfied2?.displayString,
      'question3': understanding,
      'question4': comments,
    };
  }
}

final appFormDoneProvider = StateProvider<bool>(
    (ref) => Storage().getQuestionnaireDone('questionnaire2'));

final appFormProvider = ChangeNotifierProvider<AppForm>((ref) => AppForm());
