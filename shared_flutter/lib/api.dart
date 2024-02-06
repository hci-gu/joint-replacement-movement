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
    Map<String, dynamic> body = {
      'personalId': personalId,
      'data': data.map((e) => e.toJson()).toList(),
    };
    if (operationDate != null) {
      body['eventDate'] = operationDate.toIso8601String();
    }

    Future request = api.post('/data', data: body);
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
