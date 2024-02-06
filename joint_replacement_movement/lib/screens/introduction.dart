import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:joint_replacement_movement/state/state.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/onboarding_feature.dart';
import 'package:movement_code/components/upload_progress.dart';
import 'package:movement_code/screens/forms/movement_form.dart';
import 'package:movement_code/screens/step_data/step_data.dart';
import 'package:movement_code/state.dart';
import 'package:movement_code/storage.dart';
import 'package:personnummer/personnummer.dart';

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(children: [
      CupertinoOnboarding(
        widgetAboveTitle: const UploadProgress(),
        onPressedOnLastPage: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
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
        pages: [
          OnboardingFeaturesPage(
            title: const Text('Hur Går Det?'),
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
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.doc_person,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Svara på ett par frågor'),
                description: const Text(
                  "I samband med din stegdata så vill vi också ställa ett par frågor. Det är endast tre enkla frågor om din rörelse.",
                ),
              ),
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.graph_square,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Se ditt resultat'),
                description: const Text(
                  "Efter du har svarat på frågorna så kan du se ditt resultat direkt i appen.",
                ),
              ),
              OnboardingFeature(
                icon: Icon(
                  CupertinoIcons.time,
                  color: CupertinoColors.systemRed.resolveFrom(context),
                ),
                title: const Text('Återkoppling om 2 veckor'),
                description: const Text(
                  "Efter två veckor så finns det två frågor till att svara på kopplat till din stegdata.",
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
            body: StepDataScreen(),
          ),
          const CupertinoOnboardingPage(
            title: Text('Om din rörelse'),
            description: Text(
              'Medans din stegdata laddas upp vill vi ställa några frågor om din rörelse.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: MovementFormScreen(),
          ),
          const CupertinoOnboardingPage(
            title: Text('Tack för din medverkan!'),
            description: Text(
              'Du kan nu se ditt resultat och återkoppla om två veckor.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(CupertinoIcons.hand_thumbsup),
              ),
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
        String? storedPersonalId = Storage().getPersonalid();
        if (storedPersonalId != null && Personnummer.valid(storedPersonalId)) {
          return 'Fortsätt';
        }
        return 'Skicka in';
      case 2:
        return 'Skicka in';
      case 3:
        return 'Slutför';
      default:
        return 'Sätt igång';
    }
  }
}
