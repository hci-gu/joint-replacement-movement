import 'package:fracture_movement/screens/questionnaire/state.dart';

// ignore: prefer_function_declarations_over_variables
final testQuestionnaire = () => Questionnaire(
      name: 'Hur går det?',
      questions: const [
        Question(
            text: 'Har du tagit värktabletter idag?',
            type: QuestionType.segmentControl,
            options: [
              'Ja',
              'Nej',
            ]),
        Question(
          text:
              'Ungefär hur många värktabletter av olika slag har du tagit idag?',
          dependsOn: Dependency(
            question: 'Har du tagit värktabletter idag?',
            answer: 'Ja',
          ),
          type: QuestionType.painMedication,
        ),
        Question(
          introduction: 'Intro 1',
          text: 'Test question pain',
          type: QuestionType.painScale,
        ),
        Question(
          introduction: 'Intro 2',
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
