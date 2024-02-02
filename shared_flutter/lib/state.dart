library movement_code;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personnummer/personnummer.dart';

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

  HealthData(
    this.data, {
    required this.isAuthorized,
    required this.authorizationFailed,
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

class HealthDataManager extends AutoDisposeAsyncNotifier<HealthData> {
  HealthFactory health = HealthFactory();
  bool isAuthorized = false;
  bool authorizationFailed = false;

  @override
  FutureOr<HealthData> build() async {
    final now = DateTime.now();
    final fiveYearsAgo = now.subtract(const Duration(days: 365 * 5));

    List<HealthDataPoint> healthData =
        await health.getHealthDataFromTypes(fiveYearsAgo, now, types);
    Map<HealthDataType, List<HealthDataPoint>> healthDataMap = {};

    for (var type in types) {
      healthDataMap[type] =
          healthData.where((element) => element.type == type).toList();
    }
    healthDataMap.removeWhere((key, value) => value.isEmpty);

    return HealthData(
      healthDataMap,
      isAuthorized: healthDataMap.isNotEmpty || isAuthorized,
      authorizationFailed: healthDataMap.isEmpty && authorizationFailed,
    );
  }

  Future authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    bool isAuthorized =
        await health.requestAuthorization(types, permissions: permissions);

    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    if (!isAuthorized || hasPermissions != true) {
      authorizationFailed = true;
    }
    ref.invalidateSelf();
  }

  Future uploadData() async {
    if (ref.watch(dataUploadProvider) != null) {
      return;
    }

    String personalId = ref.read(personalIdProvider);
    DateTime? operationDate = ref.read(operationDateProvider);

    Future request =
        Api().uploadData(personalId, operationDate, state.value!.allItems);

    ref.read(dataUploadProvider.notifier).state = request;
    request.then((_) {
      Storage().storePersonalId(personalId);
      Storage().storeEventDate(operationDate!);
    });
  }
}

final dataUploadProvider = StateProvider<Future?>((ref) => null);

final healthDataProvider =
    AsyncNotifierProvider.autoDispose<HealthDataManager, HealthData>(
  HealthDataManager.new,
);

final personalIdProvider =
    StateProvider<String>((ref) => Storage().getPersonalid() ?? '');
final operationDateProvider =
    StateProvider<DateTime?>((ref) => Storage().getEventDate());
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
    if (Storage().getQuestionnaire1Done()) {
      return;
    }

    try {
      await Api()
          .submitQuestionnaire(personalId, 'questionnaire1', getAnswers());
    } catch (_) {
      return;
    }

    Storage().storeQuestionnaireDone();
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
