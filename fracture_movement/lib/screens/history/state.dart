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

  return QuestionnaireWithAnswers(questionnaire, answers);
});
