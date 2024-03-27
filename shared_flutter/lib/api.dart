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

  Future testRequest() async {
    try {
      Response response = await api.get('/');
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  Future createUser(String personalId, [bool? consent]) async {
    try {
      Response response = await api.post(
        '/users',
        data: {
          'personalId': personalId,
          'consent': consent,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print(e);
    }
  }

  Future uploadDataInChunks(String personalId, DateTime? operationDate,
      List<HealthDataPoint> data) async {
    // split up data into 10 equal chunks
    List<Map<String, dynamic>> chunks = [];
    int chunkSize = (data.length / 10).ceil();
    for (int i = 0; i < data.length; i += chunkSize) {
      int endIndex = i + chunkSize;
      if (endIndex > data.length) {
        endIndex = data.length;
      }

      Map<String, dynamic> body = {
        'personalId': personalId,
        'data': data.sublist(i, endIndex).map((e) => e.toJson()).toList(),
      };
      if (operationDate != null) {
        body['eventDate'] = operationDate.toIso8601String();
      }
      chunks.add(body);
    }

    // Function to handle a single chunk upload
    Future<void> uploadChunk(Map<String, dynamic> chunk) async {
      await api.post('/data', data: chunk);
    }

    // run all chunks in series
    while (chunks.isNotEmpty) {
      Map<String, dynamic> chunk = chunks.removeAt(0);
      await uploadChunk(chunk);
    }
  }

  Future uploadData(String personalId, DateTime? operationDate,
          List<HealthDataPoint> data) =>
      uploadDataInChunks(personalId, operationDate, data);

  Future<bool> submitQuestionnaire(
      String personalId, String name, Map<String, dynamic> answers) async {
    try {
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
