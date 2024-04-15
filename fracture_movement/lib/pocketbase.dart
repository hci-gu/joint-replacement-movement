import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://127.0.0.1:8090');

Future<List<Questionnaire>> getQuestionnaires() async {
  final res = await pb.collection('questionnaires').getList(
        expand: 'questions,questions.options',
      );

  return res.items.map((e) => Questionnaire.fromRecord(e)).toList();
}

Future<Questionnaire> getQuestionnaire(String id) async {
  final res = await pb.collection('questionnaires').getOne(
        id,
        expand: 'questions,questions.options',
      );

  return Questionnaire.fromRecord(res);
}
