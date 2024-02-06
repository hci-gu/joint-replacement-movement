import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/screens/introduction.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Api().init('https://192.168.10.100:4000');
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
          child: IntroductionScreen(),
        ),
      ),
    );
  }
}
