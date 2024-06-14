import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Välkommen till Brytpunkten',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Det första du behöver göra är att välja datum då du skadades samt ge tillgång till din stegdata.',
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '\u2022 Din stegdata används för att du själv ska kunna se din rörelse före och efter skadan.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\u2022 Din senaste stegdata kommer även laddas upp automatiskt när du svarar på formulär.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: () {
                context.goNamed(
                  'onboarding-questionnaire',
                  pathParameters: {'id': 'o0kztzavvw04a8c'},
                );
              },
              child: const Text('Sätt igång'),
            ),
          ],
        ),
      ),
    );
  }
}
