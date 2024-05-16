import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/history/history.dart';
import 'package:fracture_movement/screens/home.dart';
import 'package:fracture_movement/screens/introduction/introduction.dart';
import 'package:fracture_movement/screens/introduction/login.dart';
import 'package:fracture_movement/screens/introduction/signup.dart';
import 'package:fracture_movement/screens/questionnaire/questionnaire.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<String?>(
      authProvider.select((value) => value?.token),
      (_, __) => notifyListeners(),
    );
  }

  String? _redirectLogic(BuildContext context, GoRouterState state) {
    bool loggedIn = _ref.read(authProvider) != null;

    // handle logging in
    if (!loggedIn && state.matchedLocation == '/loading') {
      return null;
    } else if (loggedIn && state.matchedLocation == '/loading') {
      return '/';
    }

    if (loggedIn && _isLoginRoute(state.matchedLocation)) {
      return '/';
    }
    if (!loggedIn && !_isLoginRoute(state.matchedLocation)) {
      return '/introduction';
    }
    return null;
  }

  bool _isLoginRoute(String route) {
    return route == '/introduction' ||
        route == '/introduction/login' ||
        route == '/introduction/signup';
  }
}

final routerProvider = Provider.family<GoRouter, bool>((ref, loggedIn) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: loggedIn ? '/loading' : '/introduction',
    routes: [
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'history/:id',
            name: 'history',
            builder: (context, state) => HistoryScreen(
              questionnaireId: state.pathParameters['id'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'questionnaire',
                name: 'questionnaire-history',
                builder: (context, state) => QuestionnaireScreen(
                  id: state.pathParameters['id'] ?? '',
                  date: state.uri.queryParameters['date'] != null
                      ? DateTime.parse(state.uri.queryParameters['date']!)
                      : null,
                ),
              )
            ],
          ),
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
        path: '/introduction',
        name: 'introduction',
        builder: (context, state) => const IntroductionScreen(),
        routes: [
          GoRoute(
            path: 'signup',
            name: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
          ),
        ],
      ),
    ],
    refreshListenable: routerNotifier,
    redirect: routerNotifier._redirectLogic,
  );
});

class LoadingScreen extends HookConsumerWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> waitedLongEnough = useState(false);

    useEffect(() {
      Future.delayed(const Duration(seconds: 5), () {
        if (context.mounted) {
          waitedLongEnough.value = true;
        }
      });
      return () => {};
    }, []);

    return CupertinoPageScaffold(
      child: waitedLongEnough.value
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: CupertinoActivityIndicator()),
                const SizedBox(height: 16),
                Center(
                  child: CupertinoButton.filled(
                    onPressed: () {
                      context.goNamed('introduction');
                    },
                    child: const Text('Abort'),
                  ),
                )
              ],
            )
          : const Center(
              child: CupertinoActivityIndicator(),
            ),
    );
  }
}
