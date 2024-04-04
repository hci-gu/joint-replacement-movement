import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Hem'),
            // 2x2 grid of questionnaires
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('Profilformulär'),
              onPressed: () => context.goNamed(
                'questionnaire',
                pathParameters: {'id': 'profile'},
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('Testformulär'),
              onPressed: () => context.goNamed(
                'questionnaire',
                pathParameters: {'id': 'test'},
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              child: const Text('SMFAformulär'),
              onPressed: () => context.goNamed(
                'questionnaire',
                pathParameters: {'id': 'smfa'},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const Home();
            ;
          case 1:
            return const CupertinoPageScaffold(
              child: Center(
                child: Text('Stegdata'),
              ),
            );
          case 2:
            return CupertinoPageScaffold(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Profil'),
                    CupertinoButton(
                      child: const Text('Logga ut'),
                      onPressed: () => context.goNamed('login'),
                    ),
                  ],
                ),
              ),
            );
          default:
            return const SizedBox.shrink();
        }
      },
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Hem',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square),
            label: 'Stegdata',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
