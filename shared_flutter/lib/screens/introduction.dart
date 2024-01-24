library movement_code;

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_dropdown.dart';
import 'package:movement_code/components/health_data_displayer.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/onboarding_feature.dart';
import 'package:movement_code/state.dart';

class IntroductionScreen extends ConsumerWidget {
  final String title;

  const IntroductionScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoOnboarding(
      onPressedOnLastPage: () => Navigator.pop(context),
      bottomButtonChild:
          Text(buttonTextForStep(ref.watch(onboardingStepProvider))),
      nextPageDisabled: !ref.watch(canContinueProvider),
      onPageChange: (page) {
        ref.read(onboardingStepProvider.notifier).state = page;
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
          titleTopIndent: 40,
          title: Text('Din stegdata'),
          description: Text(
            'De behöver ge oss tillgång till din data genom "Hälsa" appen på din iPhone.',
          ),
          bodyPadding: EdgeInsets.zero,
          body: HealthDataDisplayer(),
        ),
        CupertinoOnboardingPage(
          title: Text('Om din rörelse'),
          description: Text(
              'Kopplat till din stegdata vill vi ställa några frågor om din rörelse.'),
          bodyPadding: EdgeInsets.zero,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Text(
                    'Jämfört med tiden före din ledprotesoperation, hur mycket har din dagliga rörelse ökat eller minskat?'),
                CupertinoSlider(value: 0, onChanged: (_) {}),
                const SizedBox(height: 16),
                const Text(
                  'Hur mycket tid ägnar du en vanlig vecka åt fysisk träning som får dig att bli andfådd, till exempel löpning, motionsgymnastik eller bollsport?',
                ),
                const SizedBox(height: 8),
                DropDownCupertino<Gender>(
                    initialText: 'Välj ett alternativ',
                    onSelectedItemChanged: (_) {},
                    pickList: const {
                      Gender.male: 'Man',
                      Gender.female: 'Kvinna',
                      Gender.other: 'Annat'
                    }),
                const SizedBox(height: 16),
                const Text(
                  'Hur mycket tid ägnar du en vanlig vecka åt vardagsmotion, till exempel promenader, cykling eller trädgårdsarbete? Räkna samman all tid (minst 10 minuter åt gången).',
                ),
                const SizedBox(height: 8),
                DropDownCupertino<Gender>(
                    initialText: 'Välj ett alternativ',
                    onSelectedItemChanged: (_) {},
                    pickList: const {
                      Gender.male: 'Man',
                      Gender.female: 'Kvinna',
                      Gender.other: 'Annat'
                    }),
              ],
            ),
          ),
        ),
      ],
    );
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
        return 'Fortsätt';
      default:
        return 'Sätt igång';
    }
  }
}

enum Gender { male, female, other }
