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

    Future request = Future.delayed(const Duration(seconds: 8));
    // Future request =
    //     Api().uploadData(personalId, operationDate, state.value!.allItems);

    ref.read(dataUploadProvider.notifier).state = request;
    request.whenComplete(() {
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

final personalIdProvider = StateProvider<String>((ref) => '');
final operationDateProvider = StateProvider<DateTime?>((ref) => null);

final onboardingStepProvider = StateProvider((ref) {
  String? personalId = Storage().getPersonalid();
  bool questionnaire1Done = Storage().getQuestionnaire1Done();

  // if (personalId != null && questionnaire1Done) {
  //   return 4;
  // }
  // if (!questionnaire1Done) {
  //   return 2;
  // }

  return 0;
});

final canContinueProvider = Provider((ref) {
  final step = ref.watch(onboardingStepProvider);
  final personalId = ref.watch(personalIdProvider);
  final operationDate = ref.watch(operationDateProvider);
  final movementForm = ref.watch(movementFormProvider);

  switch (step) {
    case 0:
      return true;
    case 1:
      return operationDate != null && Personnummer.valid(personalId);
    case 2:
      return movementForm.questionDuration1 != null &&
          movementForm.questionDuration2 != null;
    case 3:
      return true;
    default:
      return false;
  }
});

enum QuestionDuration1 {
  zero,
  lessThan30,
  between30And60,
  between60And90,
  between90And120,
  moreThan120,
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

  setQuestion1(QuestionDuration1 value) {
    questionDuration1 = value;
  }

  setQuestion2(QuestionDuration2 value) {
    questionDuration2 = value;
  }

  Future submitQuestionnaire(String personalId) async {
    await Api().submitQuestionnaire(personalId, toJson());
  }

  Map<String, dynamic> toJson() {
    return {
      'question1': movementChange,
      'question2': questionDuration1,
      'question3': questionDuration2,
    };
  }
}

final movementFormProvider =
    ChangeNotifierProvider<MovementForm>((ref) => MovementForm());
