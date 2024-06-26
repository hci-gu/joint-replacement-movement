import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/storage.dart';
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('https://fracture-puff-api.prod.appadem.in');
// final pb = PocketBase('http://192.168.0.33:8090');

Future<List<Questionnaire>> getQuestionnaires([String filter = '']) async {
  final res = await pb
      .collection('questionnaires')
      .getList(expand: 'questions,questions.options', filter: filter);

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

Future submitQuestionnaire(Questionnaire questionnaire, String userId,
    DateTime startDate, DateTime date) async {
  await pb.collection('answers').create(
    body: {
      'user': userId,
      'questionnaire': questionnaire.id,
      'answers': questionnaire.answersToSubmit,
      'started': startDate.toIso8601String(),
      'date': date.toIso8601String(),
    },
  );
}

Future<DateTime?> getEventDate() async {
  List<Answer> answers = await getAnswersForQuestionnaire('o0kztzavvw04a8c');
  DateTime? date;

  for (var answer in answers) {
    // loop keys/vals of answer.answers
    for (var value in answer.answers.values) {
      // type of value is string
      if (value is String && DateTime.tryParse(value) != null) {
        date = DateTime.parse(value);
      }
    }
  }
  return date;
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
          sort: '-date',
        );

    List<Answer> answers = res.map((e) => Answer.fromRecord(e)).toList();
    return answers;
  } catch (e) {
    print(e);
    return [];
  }
}

Future<List<Answer>> getAnswersForQuestionnaire(String id) async {
  try {
    final res = await pb.collection('answers').getFullList(
          sort: '-date',
          filter: 'questionnaire="$id"',
        );

    List<Answer> answers = res.map((e) => Answer.fromRecord(e)).toList();
    return answers;
  } catch (e) {
    print(e);
    return [];
  }
}
