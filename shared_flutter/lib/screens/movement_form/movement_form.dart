import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_dropdown.dart';
import 'package:movement_code/state.dart';

const TextStyle _textStyle = TextStyle(
  color: CupertinoColors.black,
  fontSize: 16,
);

class MovementFormScreen extends ConsumerWidget {
  const MovementFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Text(
            'Jämfört med tiden före din ledprotesoperation, hur mycket har din dagliga rörelse ökat eller minskat?',
            textAlign: TextAlign.justify,
            style: _textStyle,
          ),
          Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  '${ref.watch(movementFormProvider).movementChange.toInt()}%',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 104,
                child: CupertinoSlider(
                  value: ref.watch(movementFormProvider).movementChange,
                  min: -100,
                  max: 200,
                  onChanged: (value) {
                    ref
                        .read(movementFormProvider.notifier)
                        .setMovementChange(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Hur mycket tid ägnar du en vanlig vecka åt fysisk träning som får dig att bli andfådd, till exempel löpning, motionsgymnastik eller bollsport?',
            textAlign: TextAlign.justify,
            style: _textStyle,
          ),
          const SizedBox(height: 8),
          DropDownCupertino<QuestionDuration1>(
              initialText: 'Välj ett alternativ',
              onSelectedItemChanged: (value) {
                ref.read(movementFormProvider.notifier).setQuestion1(value);
              },
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
              ),
              pickList: const {
                null: 'Välj ett alternativ',
                QuestionDuration1.zero: '0 minuter / Ingen tid',
                QuestionDuration1.lessThan30: 'Mindre än 30 minuter',
                QuestionDuration1.between30And60: '30–60 minuter (0,5–1 timme)',
                QuestionDuration1.between60And90:
                    '60–90 minuter (1–1,5 timmar)',
                QuestionDuration1.between90And120:
                    '90–120 minuter (1,5–2 timmar)',
                QuestionDuration1.moreThan120: 'Mer än 120 minuter (2 timmar)'
              }),
          const SizedBox(height: 16),
          const Text(
            'Hur mycket tid ägnar du en vanlig vecka åt vardagsmotion, till exempel promenader, cykling eller trädgårdsarbete? Räkna samman all tid (minst 10 minuter åt gången).',
            textAlign: TextAlign.justify,
            style: _textStyle,
          ),
          const SizedBox(height: 8),
          DropDownCupertino<QuestionDuration2>(
              initialText: 'Välj ett alternativ',
              onSelectedItemChanged: (value) {
                ref.read(movementFormProvider.notifier).setQuestion2(value);
              },
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
              ),
              pickList: const {
                null: 'Välj ett alternativ',
                QuestionDuration2.zero: '0 minuter / Ingen tid',
                QuestionDuration2.lessThan30: 'Mindre än 30 minuter',
                QuestionDuration2.between30And60: '30–60 minuter (0,5–1 timme)',
                QuestionDuration2.between60And90:
                    '60–90 minuter (1–1,5 timmar)',
                QuestionDuration2.between90And150:
                    '90–150 minuter (1,5–2,5 timmar)',
                QuestionDuration2.between150And300:
                    '150–300 minuter (2,5–5 timmar)',
                QuestionDuration2.moreThan300: 'Mer än 300 minuter (5 timmar)'
              }),
        ],
      ),
    );
  }
}
