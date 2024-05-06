import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('https://fracture-puff-api.prod.appadem.in');

Future<List<Questionnaire>> getQuestionnaires() async {
  final res = await pb.collection('questionnaires').getList(
        expand: 'questions,questions.options',
      );

  return res.items.map((e) => Questionnaire.fromRecord(e)).toList();
}

Future<Questionnaire> getQuestionnaire(String id) async {
  // await Future.delayed(Duration(seconds: 3));
  final res = await pb.collection('questionnaires').getOne(
        id,
        expand: 'questions,questions.options',
      );

  return Questionnaire.fromRecord(res);
}

Future submitQuestionnaire(
    Questionnaire questionnaire, String userId, DateTime startDate) async {
  await pb.collection('answers').create(
    body: {
      'user': userId,
      'questionnaire': questionnaire.id,
      'answers': questionnaire.answersToSubmit,
      'started': startDate.toIso8601String(),
    },
  );
}

Future<DateTime?> getLastStepData() async {
  final res =
      await pb.collection('steps').getList(sort: '-date_to', perPage: 1);

  if (res.items.isNotEmpty) {
    return DateTime.parse(res.items.first.data['date_to']);
  }

  return null;
}

Future<List<Answer>> getAnswers() async {
  try {
    final res = await pb.collection('answers').getFullList(
          sort: '-created',
        );

    List<Answer> answers = res.map((e) => Answer.fromRecord(e)).toList();
    return answers;
  } catch (e) {
    print(e);
    return [];
  }
}
