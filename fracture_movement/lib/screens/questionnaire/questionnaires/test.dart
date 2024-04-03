import 'package:fracture_movement/screens/questionnaire/state.dart';

final testQuestionnaire = Questionnaire(
  name: 'Hur går det?',
  questions: const [
    Question(
      text: 'Test question pain',
      type: QuestionType.painScale,
    ),
    Question(
      text: 'Test question Date',
      type: QuestionType.date,
    ),
    Question(
      text: 'Test question segment',
      type: QuestionType.segmentControl,
      options: [
        'Ja',
        'Nej',
      ],
    ),
    Question(
      text: 'Ungefär hur många värktabletter av olika slag har du tagit idag?',
      type: QuestionType.painMedication,
    ),
    Question(
      text: 'Test question',
      type: QuestionType.singleChoice,
      options: [
        'Option 1',
        'Option 2',
        'Option 3',
      ],
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
    Question(text: 'Last question'),
  ],
);
