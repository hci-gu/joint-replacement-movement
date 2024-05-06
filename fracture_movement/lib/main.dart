import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/router.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('sv', timeago.SvMessages());
  // Api().init('https://fracture-api.prod.appadem.in');
  await Storage().reloadPrefs();
  Credentials? credentials = Storage().getCredentials();
  Api().init('https://fracture-puff-api.prod.appadem.in');

  runApp(
    ProviderScope(
      overrides: credentials != null
          ? [
              authProvider.overrideWith((ref) => Auth(credentials)),
            ]
          : [],
      child: App(
        loggedIn: credentials != null,
      ),
    ),
  );
}

class App extends ConsumerWidget {
  final bool loggedIn;

  const App({
    super.key,
    this.loggedIn = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider(loggedIn));

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
