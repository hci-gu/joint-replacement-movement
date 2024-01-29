library movement_code;

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_dropdown.dart';
import 'package:movement_code/components/health_data_displayer.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/onboarding_feature.dart';
import 'package:movement_code/components/upload_progress.dart';
import 'package:movement_code/screens/movement_form/movement_form.dart';
import 'package:movement_code/screens/step_data/step_data.dart';
import 'package:movement_code/state.dart';

class IntroductionScreen extends ConsumerWidget {
  final String title;

  const IntroductionScreen({super.key, required this.title});

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
            title: Text(title),
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
            titleTopIndent: 32,
            title: Text('Din stegdata'),
            description: Text(
              'De behöver ge oss tillgång till din data genom "Hälsa" appen på din iPhone.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: StepDataScreen(),
          ),
          const CupertinoOnboardingPage(
            titleTopIndent: 32,
            title: Text('Om din rörelse'),
            description: Text(
              'Medans din stegdata laddas upp vill vi ställa några frågor om din rörelse.',
            ),
            bodyPadding: EdgeInsets.zero,
            body: MovementFormScreen(),
          ),
          const CupertinoOnboardingPage(
            titleTopIndent: 32,
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
