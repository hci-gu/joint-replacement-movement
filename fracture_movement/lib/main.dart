import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/router.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:push/push.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('sv', timeago.SvMessages());
  // Api().init('http://192.168.0.33:8090');
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

    return NotificationLauncherWrapper(
      router: router,
      child: GestureDetector(
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
      ),
    );
  }
}

class NotificationLauncherWrapper extends HookWidget {
  final GoRouter router;
  final Widget child;

  const NotificationLauncherWrapper({
    super.key,
    required this.router,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final onNotificationTap = Push.instance.onNotificationTap.listen((data) {
        handleLaunchFromNotification(data);
      });

      // final onBackgroundMessageSubscription =
      //     Push.instance.addOnBackgroundMessage((message) {
      //   handleLaunchFromNotification(message);
      // });

      return () {
        onNotificationTap.cancel();
        // onBackgroundMessageSubscription.cancel();
      };
    }, []);

    return child;
  }

  handleRoute(String route) {
    String routeName = route.split('?').first;
    Map<String, String> query = Uri.splitQueryString(route.split('?').last);

    if (routeName == 'questionnaire') {
      if (query['id'] != null) {
        router.goNamed('questionnaire', pathParameters: {
          'id': query['id'] ?? '',
        });
      }
    }
  }

  handleLaunchFromNotification(data) {
    String? action = data['action'] as String?;
    if (action != null) {
      handleRoute(action);
    }
  }
}
