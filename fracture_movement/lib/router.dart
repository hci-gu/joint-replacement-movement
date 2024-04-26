import 'package:flutter/cupertino.dart';
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

final routerProvider = Provider((ref) {
  final routerNotifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/introduction',
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
