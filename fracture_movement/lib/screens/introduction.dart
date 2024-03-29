import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/onboarding/onboarding.dart';
import 'package:movement_code/components/onboarding/onboarding_feature.dart';
import 'package:movement_code/components/upload_progress.dart';
import 'package:movement_code/screens/step_data/step_data.dart';
import 'package:movement_code/state.dart';

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(children: [
      CupertinoOnboarding(
        onPressedOnLastPage: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
        bottomButtonChild:
            Text(buttonTextForStep(ref.watch(onboardingStepProvider))),
        nextPageDisabled: !ref.watch(canContinueProvider),
        onPageChange: (page) async {
          ref.read(onboardingStepProvider.notifier).state = page;
          if (page == 2) {
            await ref
                .read(healthDataProvider.notifier)
                .createUserAndUploadConsent();
            ref.read(healthDataProvider.notifier).uploadData();
          }
        },
        pages: [
          OnboardingFeaturesPage(
            title: const Text('Brytpunkten'),
            description: const Text(
              'Hej och välkommen till appen, nedan ser du en överblick på allt du behöver göra för att komma igång. Det tar bara några få minuter och behöver enbart genomföras vid ett tillfälle.',
            ),
            features: [
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.lock,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Din stegdata'),
                description: const Text(
                  'Först behöver du ge oss tillgång till din stegdata.',
                ),
              ),
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.person,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Ange personnr'),
                description: const Text(
                  'Ange personnummer och samtycke för att ladda upp din stegdata',
                ),
              ),
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.cloud_upload,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Ladda upp'),
                description: const Text(
                  'Det tar en liten stund att ladda upp stegdatan, du behöver inte göra något medans det sker ( ca 30 sekunder )',
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
          CupertinoOnboardingPage(
            title: const Text('Tack för din medverkan!'),
            description: const Text(
              'Vänligen stanna kvar här tills din stegdata har laddats upp. Det kan ta några minuter.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ref.watch(dataUploadProvider) == null
                    ? const Text('Uppladding färdig, du kan nu stänga av appen')
                    : const UploadProgress(),
              ],
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
        return 'Slutför';
      default:
        return 'Sätt igång';
    }
  }
}
