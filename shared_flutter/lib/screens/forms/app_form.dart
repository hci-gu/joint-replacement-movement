import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_dropdown.dart';
import 'package:movement_code/state.dart';
import 'package:movement_code/storage.dart';

const TextStyle _textStyle = TextStyle(
  color: CupertinoColors.black,
  fontSize: 16,
);

class AppFormScreen extends HookConsumerWidget {
  const AppFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> loading = useState<bool>(false);

    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 200),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height / 20),
        const Text(
          'Om appen',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CupertinoColors.label,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            fontSize: 35,
          ),
        ),
        const DefaultTextStyle(
          textAlign: TextAlign.justify,
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 15,
            height: 1.3,
            letterSpacing: -0.1,
          ),
          child: Row(
            children: [
              Spacer(),
              Expanded(
                flex: 6,
                child: Text(
                  'Du kan återvända till appen efter en vecka för att svara på dessa frågor kring appen.',
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 20),
        const Text(
          'Vad tycker du om innehållet av applikationen?',
          style: _textStyle,
        ),
        const SizedBox(height: 8),
        DropDownCupertino<QuestionSatisfied>(
            initialText: 'Välj ett alternativ',
            onSelectedItemChanged: (value) {
              ref.read(appFormProvider.notifier).setQuestion1(value);
            },
            style: const TextStyle(
              color: CupertinoColors.activeBlue,
            ),
            pickList: {
              null: 'Välj ett alternativ',
              ...QuestionSatisfied.values
                  .asMap()
                  .map((key, value) => MapEntry(value, value.displayString))
            }),
        const SizedBox(height: 24),
        const Text(
          'Vad tycker du om hur datan presenteras?',
          style: _textStyle,
        ),
        const SizedBox(height: 8),
        DropDownCupertino<QuestionSatisfied>(
            initialText: 'Välj ett alternativ',
            onSelectedItemChanged: (value) {
              ref.read(appFormProvider.notifier).setQuestion2(value);
            },
            style: const TextStyle(
              color: CupertinoColors.activeBlue,
            ),
            pickList: {
              null: 'Välj ett alternativ',
              ...QuestionSatisfied.values
                  .asMap()
                  .map((key, value) => MapEntry(value, value.displayString))
            }),
        const SizedBox(height: 24),
        const Text(
          'Hur upplever du förståelsen av rörelsemönstret och hur den har förändrats över tid?',
          style: _textStyle,
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          placeholder: 'Skriv ditt svar här',
          maxLines: 3,
          onChanged: (value) {
            ref.read(appFormProvider.notifier).setUnderStanding(value);
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Andra synpunkter?',
          textAlign: TextAlign.justify,
          style: _textStyle,
        ),
        const SizedBox(height: 8),
        CupertinoTextField(
          placeholder: 'Skriv ditt svar här',
          textAlign: TextAlign.start,
          maxLines: 3,
          onChanged: (value) {
            ref.read(appFormProvider.notifier).setComments(value);
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CupertinoButton(
            borderRadius: BorderRadius.circular(15),
            color: ref.watch(appFormProvider).canSubmit
                ? CupertinoTheme.of(context).primaryColor
                : CupertinoColors.inactiveGray,
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              if (!ref.watch(appFormProvider).canSubmit) return;

              String? personalId = Storage().getPersonalid();
              if (personalId == null) return;
              loading.value = true;

              await ref
                  .read(appFormProvider.notifier)
                  .submitQuestionnaire(personalId);
              loading.value = false;
            },
            child: DefaultTextStyle(
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  loading.value
                      ? const CupertinoActivityIndicator()
                      : const Text('Skicka in'),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
