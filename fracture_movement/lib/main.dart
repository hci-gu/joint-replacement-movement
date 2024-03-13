import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/screens/home.dart';
import 'package:fracture_movement/screens/introduction.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Api().init('http://192.168.10.107:4000');
  Api().init('https://fracture-api.prod.appadem.in');
  // Api().init('http://localhost:4000');
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
    if (Storage().getPersonalIdDone()) {
      return const HomeScreen();
    }

    return const IntroductionScreen();
  }
}
