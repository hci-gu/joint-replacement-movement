import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:joint_replacement_movement/screens/home.dart';
import 'package:joint_replacement_movement/screens/introduction.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/components/onboarding.dart';
import 'package:movement_code/components/onboarding_feature.dart';
import 'package:movement_code/screens/movement_form/movement_form.dart';
import 'package:movement_code/screens/step_data/step_data.dart';
import 'package:movement_code/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Api().init('http://192.168.0.33:4000');
  // Api().init('https://jr-movement-api.prod.appadem.in');
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
      child: const CupertinoApp(
        home: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          child: ScreenSelector(),
        ),
      ),
    );
  }
}

class ScreenSelector extends ConsumerWidget {
  const ScreenSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (Storage().getPersonalIdDone() && Storage().getQuestionnaire1Done()) {
      return const HomeScreen();
    }

    return const IntroductionScreen();
  }
}
