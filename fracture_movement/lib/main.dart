import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/screens/home.dart';
import 'package:fracture_movement/screens/login.dart';
import 'package:fracture_movement/screens/questionnaire/questionnaire.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/api.dart';
import 'package:movement_code/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Api().init('https://fracture-api.prod.appadem.in');
  Api().init('http://localhost:8090');

  // await Api().testRequest();
  await Storage().reloadPrefs();
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  App({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: CupertinoApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }

  final _router = GoRouter(
    initialLocation: '/questionnaire/smfa',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'questionnaire/:id',
            name: 'questionnaire',
            builder: (context, state) => QuestionnaireScreen(
              id: state.pathParameters['id'] ?? '',
            ),
          )
        ],
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
}
