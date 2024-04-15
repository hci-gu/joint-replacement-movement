import 'package:fracture_movement/screens/questionnaire/state.dart';

const difficultyOptions = [
  'Ingen svårighet',
  'Lite svårighet',
  'Måttlig svårighet',
  'Mycket svårt',
  'Kan inte alls',
];

const occuranceOptions = [
  'Aldrig',
  'Sällan',
  'Ibland',
  'Ofta',
  'Alltid',
];

const annoyanceOptions = [
  'Inte alls besvärad',
  'Lite besvärad',
  'Måttligt besvärad',
  'Mycket besvärad',
  'Extremt besvärad',
];

// ignore: prefer_function_declarations_over_variables
final smfaQuestionnaire = () => Questionnaire(
      id: 'smfa',
      name: 'SMFA',
      questions: const [
        Question(
          introduction:
              'FÖLJANDE FRÅGOR RÖR DE EVENTUELLA SVÅRIGHETER DU HAFT DEN SENASTE VECKAN TILL FÖLJD AV DIN SKADA/SKADOR.',
          text:
              'Hur svårt hade du att sätta dig i, och resa dig ur en låg stol?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att öppna medicinförpackningar eller burkar?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att göra inköp i affärer?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att gå i trappor?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att knyta handen hårt?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att komma i/ur badkar eller dusch?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att finna en bekväm sovställning?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att böja dig ner eller gå ned på knä?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att använda knappar, spännen, hakar eller blixtlås?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att klippa dina fingernaglar?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att klä dig?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att gå?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att komma igång att röra dig efter att ha suttit eller legat?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att gå ut ensam?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att köra bil eller använda allmänna kommunikationsmedel?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att torka dig efter toalettbesök?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att använda handtag, t ex för att öppna dörrar eller veva ned bilfönster?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att skriva, för hand eller på maskin?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att vända dig om?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att ägna dig åt din vanliga motion, t ex cykla, jogga eller promenera?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att ägna dig åt dina vanliga fritidsaktiviteter, t ex hobbies, handarbete, trädgårdsskötsel, kortspel eller umgås med vänner?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text: 'Hur svårt hade du att ha ett, för dig, normalt sexliv?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att utföra lättare hushålls- eller trädgårdssysslor, såsom damma, diska eller vattna rabatter?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att utföra tungt hushålls- eller trädgårdsarbete, såsom skura golv, dammsuga eller klippa gräsmattan?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        Question(
          text:
              'Hur svårt hade du att utföra ditt dagliga arbete/syssla, som t ex jobb, hushållsarbete eller ideell verksamhet?',
          type: QuestionType.singleChoice,
          options: difficultyOptions,
        ),
        // PÅ FÖLJANDE FRÅGOR ÖNSKAR VI FÅ VETA HUR OFTA DU HAFT SVÅRIGHETER UNDER VECKAN INNAN DU SKADADE DIG.
        Question(
          introduction:
              'PÅ FÖLJANDE FRÅGOR ÖNSKAR VI FÅ VETA HUR OFTA DU HAFT SVÅRIGHETER, TILL FÖLJD AV DIN SKADA/SKADOR DEN SENASTE VECKAN.',
          text: 'Hur ofta haltade du?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text: 'Hur ofta undvek du att använda din/ditt onda arm /ben/ rygg?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text: 'Hur ofta låste/vek sig ditt ben?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text: 'Hur ofta hade du koncentrationssvårigheter?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text:
              'Om Du överansträngde dig en dag, hur ofta påverkade det nästa dags aktivitet?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text:
              'Hur ofta visade du irritation mot din omgivning, t ex snäste, fräste ifrån, var kritisk för småsaker?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text: 'Hur ofta kände du dig trött?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text: 'Hur ofta kände du dig handikappad?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        Question(
          text:
              'Hur ofta kände du dig arg eller frustrerad över ditt hälsotillstånd?',
          type: QuestionType.singleChoice,
          options: occuranceOptions,
        ),
        // FÖLJANDE FRÅGOR RÖR HUR BESVÄRAD/STÖRD DU KÄNDE DIG AV SVÅRIGHETER UNDER VECKAN INNAN DU SKADADE DIG.
        Question(
          introduction:
              'FÖLJANDE FRÅGOR RÖR HUR BESVÄRAD/STÖRD DU KÄNNER DIG AV SVÅRIGHETER ORSAKADE AV SKADAN/SKADORNA DEN SENASTE VECKAN.',
          text:
              'Svårigheter att använda den/de kroppsdelar som du sedan skadade?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Svårigheter att röra/använda ryggen?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Svårigheter att utföra sysslor i hemmet?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text:
              'Svårigheter med dusch/bad, av- och påklädning, toa besök eller annan personlig vård?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Svårigheter med sömn och vila?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text:
              'Svårigheter att ägna dig åt fritidsaktiviteter och/eller motion?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text:
              'Problem med vänner, familj eller andra viktiga människor i ditt liv?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Svårigheter att tänka, koncentrera dig eller att komma ihåg?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Svårigheter att klara din normala sysselsättning?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Problem med att känna dig beroende av andra människor?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text: 'Problem med stelhet och/eller värk?',
          type: QuestionType.singleChoice,
          options: annoyanceOptions,
        ),
        Question(
          text:
              'Förväntar du dig att bli återställd efter din fraktur/dina frakturer',
          type: QuestionType.singleChoice,
          options: [
            'Ja, helt (1)',
            '(2)',
            '(3)',
            '(4)',
            'Nej, inte alls (5)',
          ],
        ),
        Question(
          text: 'Röker du?',
          type: QuestionType.singleChoice,
          options: [
            'Aldrig varit rökare',
            'Före detta rökare',
            'Röker, ej dagligen',
            'Dagligrökare',
          ],
        ),
      ],
    );
