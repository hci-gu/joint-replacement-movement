import 'package:fracture_movement/pocketbase.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuestionnaireWithAnswers {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  QuestionnaireWithAnswers(this.questionnaire, this.answers);
}

final questionnaireAnswersProvider =
    FutureProvider.family<QuestionnaireWithAnswers, String>(
        (ref, questionnaireId) async {
  final questionnaire = await getQuestionnaire(questionnaireId);
  final answers = await getAnswersForQuestionnaire(questionnaireId);

  // Sort answers by date
  answers.sort((a, b) => a.date.compareTo(b.date));

  return QuestionnaireWithAnswers(questionnaire, answers);
});

final otherQuestionnairesWithAnswersProvider =
    FutureProvider<List<QuestionnaireWithAnswers>>((ref) async {
  final questionnaires =
      await getQuestionnaires('occurance != "weekly" && occurance != "daily"');

  List<QuestionnaireWithAnswers> questionnairesWithAnswers = [];
  for (var questionnaire in questionnaires) {
    final answers = await getAnswersForQuestionnaire(questionnaire.id);
    answers.sort((a, b) => a.date.compareTo(b.date));
    questionnairesWithAnswers.add(
      QuestionnaireWithAnswers(questionnaire, answers),
    );
  }

  return questionnairesWithAnswers;
});
