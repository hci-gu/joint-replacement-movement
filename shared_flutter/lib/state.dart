library movement_code;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:personnummer/personnummer.dart';

export 'package:health/health.dart';

const apiEndpoint = 'https://jr-movement-api.prod.appadem.in';

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
  Dio api = Dio(
    BaseOptions(
      baseUrl: apiEndpoint,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
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

  Future uploadData(String personalId, DateTime operationDate) async {
    await api.post(
      '/data',
      data: {
        'personalId': personalId,
        'operationDate': operationDate.toIso8601String(),
        'data': state.value!.allItems.map((e) => e.toJson()).toList(),
      },
    );
  }
}

final healthDataProvider =
    AsyncNotifierProvider.autoDispose<HealthDataManager, HealthData>(
  HealthDataManager.new,
);

final personalIdProvider = StateProvider<String>((ref) => '');
final operationDateProvider = StateProvider<DateTime?>((ref) => null);

final onboardingStepProvider = StateProvider((ref) => 0);

final canContinueProvider = Provider((ref) {
  final step = ref.watch(onboardingStepProvider);
  final personalId = ref.watch(personalIdProvider);
  final operationDate = ref.watch(operationDateProvider);

  switch (step) {
    case 0:
      return true;
    case 1:
      return operationDate != null && Personnummer.valid(personalId);
    default:
      return false;
  }
});
