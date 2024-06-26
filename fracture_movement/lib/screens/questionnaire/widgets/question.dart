import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/widgets/step_data.dart';

enum PainMedication {
  paracetamol,
  antiInflammatory,
  shortActingMorphine,
  longActingMorphine,
  other,
}

extension PainMedicationExtension on PainMedication {
  String get name {
    switch (this) {
      case PainMedication.paracetamol:
        return 'Paracetamoltyp\n( ex Panodil, Alvedon )';
      case PainMedication.antiInflammatory:
        return 'Inflammationsdämpande värktabletter (ex. Ipren )';
      case PainMedication.shortActingMorphine:
        return 'Kortverkande morfintabletter\n( ex Oxynorm )';
      case PainMedication.longActingMorphine:
        return 'Långverkande morfintabletter\n( ex Oxycontin )';
      case PainMedication.other:
        return 'Annan typ';
    }
  }
}

class PainMedicationQuestion extends HookWidget {
  final Question question;
  final void Function(dynamic, bool) onAnswer;

  const PainMedicationQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Map<String, int>> painMedication = useState(<String, int>{});

    return CupertinoListSection.insetGrouped(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (var option in PainMedication.values)
          CupertinoListTile(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            title: Text(
              option.name,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: SizedBox(
              width: 64,
              child: CupertinoTextField(
                placeholder: 'Antal',
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  painMedication.value[option.name] = int.tryParse(value) ?? 0;
                  onAnswer(painMedication.value, false);
                },
              ),
            ),
          ),
        const CupertinoTextField(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          placeholder: 'Om annan typ vilken medicin har du tagit?',
        )
      ],
    );
  }
}

class PainSlider extends HookWidget {
  final void Function(int) onAnswer;
  final int defaultValue;

  const PainSlider({
    required this.onAnswer,
    required this.defaultValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sliderValue = useState(defaultValue.toDouble());

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ingen\nsmärta',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
              Text(
                'Värsta\ntänkbara\nsmärta',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              11,
              (index) => Text(
                '$index',
                style: sliderValue.value == index
                    ? const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      )
                    : const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 13,
                      ),
              ),
            ).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: CupertinoSlider(
                  value: sliderValue.value,
                  onChanged: (value) {
                    sliderValue.value = value;
                  },
                  onChangeEnd: (value) {
                    onAnswer(value.toInt());
                  },
                  min: 0,
                  max: 10,
                  divisions: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Question question;
  final void Function(dynamic, [bool]) onAnswer;
  final dynamic answer;
  final dynamic valueFromQuestion;
  final String? errorMessage;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
    this.valueFromQuestion,
    this.errorMessage,
    this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            question.text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _question(),
        if (errorMessage != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: CupertinoColors.destructiveRed,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _question() {
    switch (question.type) {
      case QuestionType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CupertinoTextField(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            placeholder: question.placeholder,
            onChanged: (value) => onAnswer(value, false),
            onSubmitted: (value) {
              onAnswer(value);
            },
          ),
        );
      case QuestionType.singleChoice:
        return CupertinoListSection.insetGrouped(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (var option in question.options)
              CupertinoListTile(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                onTap: () => onAnswer(option),
                title: Text(
                  option,
                  maxLines: 3,
                ),
                trailing: answer == option
                    ? const Icon(CupertinoIcons.checkmark)
                    : null,
              ),
          ],
        );
      case QuestionType.painScale:
        return PainSlider(
          defaultValue: answer ?? 0,
          onAnswer: (value) {
            onAnswer(value);
          },
        );
      case QuestionType.painMedication:
        return PainMedicationQuestion(
          question: question,
          onAnswer: onAnswer,
        );
      case QuestionType.segmentControl:
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: CupertinoSegmentedControl(
                children: {
                  for (var option in question.options)
                    option: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(option),
                    ),
                },
                onValueChanged: (value) {
                  onAnswer(value.toString());
                },
                groupValue: answer,
              ),
            )
          ],
        );
      case QuestionType.date:
        return SizedBox(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            maximumDate: DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
              13,
            ),
            initialDateTime: answer ??
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  12,
                ),
            onDateTimeChanged: (value) {
              onAnswer(value, false);
            },
          ),
        );
      case QuestionType.stepDataAccess:
        return StepDataQuestion(
          date: valueFromQuestion as DateTime,
          onAnswer: (permission) => onAnswer(permission),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
