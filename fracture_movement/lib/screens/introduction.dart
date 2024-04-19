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
            ref.read(healthDataProvider.notifier).uploadData();
          }
        },
        beforePageChange: () async {
          if (ref.watch(onboardingStepProvider) == 1) {
            await ref
                .read(healthDataProvider.notifier)
                .createUserAndUploadConsent();
          }
        },
        pages: [
          OnboardingFeaturesPage(
            title: const Text('Brytpunkten'),
            description: const Text(
              'Välkommen till mobilapplikationen ”Brytpunkten”. Nedan har du en överblick över allt som krävs för att komma i gång. Det tar endast en par minuter och behöver enbart genomföras vid ett tillfälle.',
            ),
            features: [
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.lock,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Din stegdata'),
                description: const Text(
                  'Du behöver ge oss tillgång till din stegdata',
                ),
              ),
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.person,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Ange personnr'),
                description: const Text(
                  'Ange ditt personnummer och ge samtycke för att ladda upp din stegdata',
                ),
              ),
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.cloud_upload,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Uppladdning av stegdata'),
                description: const Text(
                  'Under tiden stegdatan laddas upp behöver du inte göra någonting. Detta tar ungefär 30 sekunder.',
                ),
              ),
            ],
          ),
          const CupertinoOnboardingPage(
            title: Text('Din stegdata'),
            description: Text(
              'Du behöver ge oss tillgång till din stegdata genom ”Hälsa” applikationen på din Iphone.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: StepDataScreen(
              includeDate: false,
            ),
          ),
          CupertinoOnboardingPage(
            title: const Text('Tack för din medverkan!'),
            description: const Text(
              'Vänligen stanna kvar på denna sida tills din stegdata har laddats upp. När ”Uppladdning klar!” symbolen dyker upp i rutan är allt klart. Det går då bra att stänga ner applikationen. Uppladdningen tar ungefär 30 sekunder ( kan ta längre tid beroende på uppkoppling ).',
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
