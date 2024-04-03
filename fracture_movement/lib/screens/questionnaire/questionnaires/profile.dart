import 'package:fracture_movement/screens/questionnaire/state.dart';

final profileQuestionnaire = Questionnaire(
  name: 'ProfilInformation',
  questions: const [
    Question(
      text: 'Vad heter du?',
      type: QuestionType.text,
    ),
    Question(
      text: 'Vilken är din huvudsakliga sysselsättning',
      type: QuestionType.singleChoice,
      options: [
        'Arbete',
        'Studier',
        'Arbetslös',
        'Sjukskriven',
        'Pensionär',
      ],
    ),
    Question(
      text: 'Om du arbetar, hur är ditt arbete mestadels?',
      type: QuestionType.singleChoice,
      options: [
        'Fysiskt tungt',
        'Fysiskt lätt med rörligt dvs går och står mycket',
        'Fysiskt lätt och i huvudsak stillasittande',
      ],
      dependsOn: Dependency(
        question: 'Vilken är din huvudsakliga sysselsättning',
        answer: 'Arbete',
      ),
    ),
    Question(
      text: 'Under veckan före din skada, hur mycket arbetade du?',
      type: QuestionType.singleChoice,
      options: [
        'Arbetat i ditt ordinarie arbete heltid',
        'Arbetat i ditt ordinarie arbete 75%',
        'Arbetat i ditt ordinarie arbete 50%',
        'Arbetat i ditt ordinarie arbete 25%',
        'Inte arbetat alls i mitt ordinarie arbete',
      ],
      dependsOn: Dependency(
        question: 'Vilken är din huvudsakliga sysselsättning',
        answer: 'Arbete',
      ),
    ),
    Question(
      text:
          'Har du under veckan före din skada huvudsakligen använt något gånghjälpmedel',
      type: QuestionType.singleChoice,
      options: [
        'Nej',
        'Ja= 2 kryckor',
        'Ja= 1 krycka',
        'Ja= Annat gånghjälpmedel som rullator',
        'Ja= Rullstol'
      ],
    ),
  ],
);
