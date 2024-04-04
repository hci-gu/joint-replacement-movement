import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';

class PainMedicationQuestion extends HookWidget {
  final Question question;
  final void Function(String) onAnswer;

  const PainMedicationQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final haveTakenMedication = useState(false);

    return CupertinoListSection.insetGrouped(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        CupertinoListTile(
          // onTap: () => onAnswer('option'),
          title: Text('Jag har tagit värktabletter'),
          trailing: CupertinoSwitch(
            value: haveTakenMedication.value,
            onChanged: (value) {
              haveTakenMedication.value = value;
            },
          ),
        ),
        if (haveTakenMedication.value) ...[
          CupertinoListTile(
            title: Column(
              children: [
                Text('Paracetamoltyp ( ex Panodil, Alvedon )'),
              ],
            ),
          ),
          CupertinoTextField(
            placeholder: 'Vilken medicin har du tagit?',
            onSubmitted: (value) {},
          )
        ],
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Question question;
  final void Function(dynamic, [bool]) onAnswer;
  final dynamic answer;
  final String? errorMessage;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
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
        return CupertinoTextField(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          onSubmitted: (value) {
            onAnswer(value);
          },
        );
      case QuestionType.singleChoice:
        return CupertinoListSection.insetGrouped(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (var option in question.options)
              CupertinoListTile(
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
            maximumDate: DateTime.now().add(const Duration(days: 1)),
            initialDateTime: answer ?? DateTime.now(),
            onDateTimeChanged: (value) {
              onAnswer(value, false);
            },
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
