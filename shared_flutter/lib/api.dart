import 'package:dio/dio.dart';
import 'package:movement_code/state.dart';

// const apiEndpoint = 'https://jr-movement-api.prod.appadem.in';
// const apiEndpoint = 'http://192.168.10.100:4000';
const apiEndpoint = 'http://192.168.0.33:4000';

class Api {
  Dio api = Dio(
    BaseOptions(
      baseUrl: apiEndpoint,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  Future uploadData(
      String personalId, DateTime? operationDate, List<HealthDataPoint> data) {
    Future request = api.post(
      '/data',
      data: {
        'personalId': personalId,
        'eventDate': operationDate?.toIso8601String(),
        'data': data.map((e) => e.toJson()).toList(),
      },
    );
    return request;
  }

  Future<bool> submitQuestionnaire(
      String personalId, Map<String, dynamic> form) async {
    try {
      Response response = await api.post(
        '/:personalId/form',
        data: form,
      );
      return response.statusCode == 200;
    } catch (_) {}

    return false;
  }

  // Use API as a singleton
  static final Api _instance = Api._internal();
  factory Api() {
    return _instance;
  }
  Api._internal();
}
