import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuestionnaireItem extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final Icon icon;

  const QuestionnaireItem({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.systemGrey4),
        ),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                Text(
                  description,
                  maxLines: 2,
                  style: const TextStyle(
                      color: CupertinoColors.systemGrey, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () => context.goNamed(
        'questionnaire',
        pathParameters: {'id': id},
      ),
    );
  }
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Att göra',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              // 2x2 grid of questionnaires
              const SizedBox(height: 16),
              ref.watch(questionnairesProvider).when(
                    data: (List<Questionnaire> questionnaires) {
                      return Column(
                        children: [
                          for (final questionnaire in questionnaires)
                            QuestionnaireItem(
                              id: questionnaire.id,
                              name: questionnaire.name,
                              description: 'TJENA',
                              icon: Icon(CupertinoIcons.checkmark_seal),
                            ),
                        ],
                      );
                    },
                    error: (_, __) {
                      return const Center(
                        child: Text('something went wrong'),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
            ],
          ),
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
