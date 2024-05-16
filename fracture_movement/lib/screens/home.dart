import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/profile.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/screens/step_data.dart';
import 'package:fracture_movement/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

class QuestionnaireItem extends StatelessWidget {
  final Questionnaire questionnaire;

  const QuestionnaireItem({
    super.key,
    required this.questionnaire,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                if (questionnaire.answered)
                  const Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.systemGreen,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionnaire.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        if (questionnaire.answered) {
          return;
        }
        context.goNamed(
          'questionnaire',
          pathParameters: {'id': questionnaire.id},
        );
      },
    );
  }

  String get description {
    if (questionnaire.answered && questionnaire.lastAnswered != null) {
      return 'Avklarad ${timeago.format(questionnaire.lastAnswered!, locale: 'sv')}';
    }

    return questionnaire.occurance.display;
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
          child: ref.watch(questionnairesProvider).when(
                data: (data) => _body(context, ref, data),
                error: (_, __) {
                  return const Center(
                    child: Text('something went wrong'),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        ),
      ),
    );
  }

  Widget _body(
      BuildContext context, WidgetRef ref, HomeScreenQuestionnaires home) {
    int remainingDaily =
        daysForAnswers(home.dailyAnswers) - home.dailyAnswers.length + 1;

    return ListView(
      children: [
        const Text(
          'Dagbok',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          childAspectRatio: 1.3,
          children: [
            QuestionnaireItem(questionnaire: home.daily),
          ],
        ),
        const SizedBox(height: 16),
        CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se tidigare svar',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              remainingDaily > 0
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          size: 18,
                          color: CupertinoColors.systemRed,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Du har $remainingDaily obesvarade frågor',
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          onTap: () {
            context.goNamed('history', pathParameters: {
              'id': home.daily.id,
            });
          },
          trailing: const CupertinoListTileChevron(),
        ),
        const Divider(),
        const Text(
          'Formulär',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        // 2x2 grid of questionnaires
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          childAspectRatio: 1.3,
          children: [
            for (final questionnaire in home.other)
              QuestionnaireItem(
                questionnaire: questionnaire,
              ),
          ],
        ),
      ],
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
            return const StepDataScreen();
          case 2:
            return const ProfileScreen();
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
