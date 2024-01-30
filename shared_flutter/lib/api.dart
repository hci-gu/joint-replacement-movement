import 'package:dio/dio.dart';
import 'package:movement_code/state.dart';

class Api {
  Dio api = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
  init(String baseUrl) {
    api.options.baseUrl = baseUrl;
  }

  Future uploadData(
      String personalId, DateTime? operationDate, List<HealthDataPoint> data) {
    print('upload: ${api.options.baseUrl}');
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
      String personalId, String name, Map<String, dynamic> answers) async {
    try {
      print({
        'name': name,
        'answers': answers,
      });
      Response response = await api.post(
        '/$personalId/form',
        data: {
          'name': name,
          'answers': answers,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
    }

    return false;
  }

  // Use API as a singleton
  static final Api _instance = Api._internal();
  factory Api() {
    return _instance;
  }
  Api._internal();
}
