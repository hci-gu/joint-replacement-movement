import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:joint_replacement_movement/state/state.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/upload_progress.dart';
import 'package:movement_code/state.dart';
import 'package:movement_code/storage.dart';
import 'package:personnummer/personnummer.dart';

class IntroductionScreen extends ConsumerWidget {
  final String title;
  final List<Widget> pages;

  const IntroductionScreen({
    super.key,
    required this.title,
    this.pages = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(children: [
      CupertinoOnboarding(
        widgetAboveTitle: const UploadProgress(),
        onPressedOnLastPage: () => Navigator.pop(context),
        bottomButtonChild:
            Text(buttonTextForStep(ref.watch(onboardingStepProvider))),
        nextPageDisabled: !ref.watch(canContinueProvider),
        onPageChange: (page) {
          ref.read(onboardingStepProvider.notifier).state = page;
          if (page == 2) {
            ref.read(healthDataProvider.notifier).uploadData();
          }
          if (page == 3) {
            ref
                .read(movementFormProvider.notifier)
                .submitQuestionnaire(ref.read(personalIdProvider));
          }
        },
        pages: pages,
      ),
    ]);
  }

  String buttonTextForStep(int step) {
    switch (step) {
      case 0:
        return 'Sätt igång';
      case 1:
        String? storedPersonalId = Storage().getPersonalid();
        if (storedPersonalId != null && Personnummer.valid(storedPersonalId)) {
          return 'Fortsätt';
        }
        return 'Skicka in';
      case 2:
        return 'Skicka in';
      case 3:
        return 'Skicka in';
      default:
        return 'Sätt igång';
    }
  }
}
