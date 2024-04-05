import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Att göra',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),
              // 2x2 grid of questionnaires
              SizedBox(height: 16),
              QuestionnaireItem(
                id: 'profile',
                name: 'Profil',
                description: 'Engångsformulär ( ca 2 min )',
                icon: Icon(Icons.person),
              ),
              SizedBox(height: 16),
              QuestionnaireItem(
                id: 'test',
                name: 'Testformulär',
                description: 'Testformulär för att testa appen',
                icon: Icon(Icons.abc_sharp),
              ),
              SizedBox(height: 16),
              QuestionnaireItem(
                id: 'smfa',
                name: 'SMFA Recall',
                description: 'Engångsformulär ( ca 10min )',
                icon: Icon(Icons.access_time),
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
