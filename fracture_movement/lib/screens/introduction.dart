import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/onboarding_feature.dart';
import 'package:movement_code/components/upload_progress.dart';
import 'package:movement_code/screens/step_data/step_data.dart';
import 'package:movement_code/state.dart';

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

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
        },
        pages: [
          OnboardingFeaturesPage(
            title: const Text('Brytpunkten'),
            description: const Text(
              'Hej och välkommen till appen, nedan ser du en överblick på allt du behöver göra för att komma igång. Det tar bara några minuter.',
            ),
            features: [
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.lock,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Din stegdata'),
                description: const Text(
                  'Först behöver du ge oss tillgång till din stegdata och ange ditt personnummer samt det datum du hade din operation.',
                ),
              ),
            ],
          ),
          const CupertinoOnboardingPage(
            title: Text('Din stegdata'),
            description: Text(
              'De behöver ge oss tillgång till din data genom "Hälsa" appen på din iPhone.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: StepDataScreen(
              includeDate: false,
            ),
          ),
        ],
      ),
    ]);
  }

  String buttonTextForStep(int step) {
    switch (step) {
      case 0:
        return 'Sätt igång';
      case 1:
        return 'Skicka in';
      case 2:
        return 'Fortsätt';
      case 3:
        return 'Skicka in';
      default:
        return 'Sätt igång';
    }
  }
}
