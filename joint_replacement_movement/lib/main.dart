import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:joint_replacement_movement/screens/introduction.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/onboarding_feature.dart';
import 'package:movement_code/screens/movement_form/movement_form.dart';
import 'package:movement_code/screens/step_data/step_data.dart';
import 'package:movement_code/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Api().init('http://192.168.10.100:4000');
  await Storage().reloadPrefs();
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: IntroductionScreen(
            title: "Hur Går Det?",
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
        ),
      ),
    );
  }
}
