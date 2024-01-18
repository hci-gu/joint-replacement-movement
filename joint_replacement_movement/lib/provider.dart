import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

// const apiEndpoint = 'http://localhost:4000';
// const apiEndpoint = 'http://192.168.0.33:4000';
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

class HealthFetcher with ChangeNotifier {
  Dio api = Dio(
    BaseOptions(
      baseUrl: apiEndpoint,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
  HealthFactory health = HealthFactory();
  List<HealthDataPoint> healthDataList = [];
  bool isAuthorized = false;
  bool isLoading = false;
  bool uploadSuccess = false;

  setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future authorize() async {
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Check if we have permission
    bool? hasPermissions =
        await health.hasPermissions(types, permissions: permissions);

    // hasPermissions = false because the hasPermission cannot disclose if WRITE access exists.
    // Hence, we have to request with WRITE as well.
    hasPermissions = false;

    if (!hasPermissions) {
      // requesting access to the data types before reading them
      try {
        isAuthorized =
            await health.requestAuthorization(types, permissions: permissions);
      } catch (error) {
        print("Exception in authorize: $error");
      }
    }
  }

  Future fetchData() async {
    setLoading(true);

    await authorize();

    // get data within the last 5 years
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 365 * 5));

    try {
      // fetch health data
      List<HealthDataPoint> healthData =
          await health.getHealthDataFromTypes(yesterday, now, types);
      healthDataList = healthData;
      notifyListeners();
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }

    setLoading(false);
  }

  Future uploadData(String personalId) async {
    setLoading(true);

    try {
      Response res = await api.post(
        '/data',
        data: {
          'personalId': personalId,
          'data': healthDataList.map((e) => e.toJson()).toList(),
        },
      );
      if (res.statusCode == 200) {
        uploadSuccess = true;
      }
    } catch (_) {}

    setLoading(false);
  }
}
