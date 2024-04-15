import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/router.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Api().init('https://fracture-api.prod.appadem.in');
  await Storage().reloadPrefs();
  Credentials? credentials = Storage().getCredentials();
  Api().init('http://localhost:8090');

  runApp(
    ProviderScope(
      overrides: credentials != null
          ? [
              authProvider.overrideWith((ref) => Auth(credentials)),
            ]
          : [],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: CupertinoApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
