import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Login screen'),
            CupertinoButton(
              child: const Text('Logga in'),
              onPressed: () => context.goNamed('home'),
            ),
          ],
        ),
      ),
    );
  }
}
