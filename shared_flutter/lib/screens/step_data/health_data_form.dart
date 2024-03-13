import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_date_text_box.dart';
import 'package:movement_code/components/input_prefix.dart';
import 'package:movement_code/components/personal_number_input.dart';
import 'package:movement_code/state.dart';

class ConsentCheckbox extends ConsumerWidget {
  const ConsentCheckbox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Genom att fortsätta går du med på att din stegdata används i forskningssyfte. Det som laddas upp är datat listat ovanför samt ditt personnummer.',
          ),
        ),
        CupertinoListTile(
          leading: CupertinoSwitch(
            value: ref.watch(consentProvider),
            onChanged: (value) {
              ref.read(consentProvider.notifier).state = value;
            },
          ),
          title: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '"Jag godkänner att dela min stegdata"',
              maxLines: 2,
              style: TextStyle(fontSize: 15, color: CupertinoColors.label),
            ),
          ),
        ),
      ],
    );
  }
}

class HealthDataForm extends HookConsumerWidget {
  final bool includeDate;
  final bool includeConsent;

  const HealthDataForm({
    super.key,
    this.includeDate = true,
    this.includeConsent = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        CupertinoListSection(
          topMargin: 4,
          header: Text(includeDate
              ? 'Fyll i ditt personnummer och datumet då du opererades'
              : 'Fyll i ditt personnummer'),
          children: [
            const PersonalNumberInput(),
            if (includeDate)
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const InputPrefix(text: 'Datum'),
                  Expanded(
                    child: CupertinoDateTextBox(
                      initialValue: ref.watch(operationDateProvider),
                      onDateChange: (value) {
                        ref.read(operationDateProvider.notifier).state = value;
                      },
                      hintText: 'Tryck för att välja datum',
                    ),
                  )
                ],
              ),
          ],
        ),
        if (includeConsent) const ConsentCheckbox(),
      ],
    );
  }
}
