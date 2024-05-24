import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/profile.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/screens/step_data/step_data.dart';
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
    return ListView(
      children: [
        const Text(
          'Idag',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        home.unanswered.isEmpty
            ? _doneSection(context, home)
            : Text(
                _displayQuestionsLeft(home.unanswered.length),
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          childAspectRatio: 1.3,
          children: [
            for (final questionnaire in home.unanswered)
              QuestionnaireItem(
                questionnaire: questionnaire,
              ),
          ],
        ),
        const Divider(height: 32),
        _recurringQuestionnaireSection(context, home.daily, home.dailyAnswers),
        _recurringQuestionnaireSection(
            context, home.weekly, home.weeklyAnswers),
        const Text(
          'Tidigare frågeformulär',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
            for (final questionnaire in home.answered)
              QuestionnaireItem(
                questionnaire: questionnaire,
              ),
          ],
        ),
      ],
    );
  }

  Widget _doneSection(BuildContext context, HomeScreenQuestionnaires home) {
    return Column(
      children: [
        const Icon(
          CupertinoIcons.checkmark_alt_circle,
          color: CupertinoColors.systemGreen,
          size: 48,
        ),
        const SizedBox(height: 4),
        const Text(
          'Klart för idag',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          home.doneDescription,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _recurringQuestionnaireSection(
      BuildContext context, Questionnaire questionnaire, List<Answer> answers) {
    int remainingDaily = questionnaire.occurance == Occurance.daily
        ? daysForAnswers(answers) - answers.length + 1
        : weeksForAnswers(answers) - answers.length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historik för ${questionnaire.name}',
                style: const TextStyle(fontSize: 16),
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
                          _displayQuestionsLeft(remainingDaily),
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
              'id': questionnaire.id,
            });
          },
          trailing: const CupertinoListTileChevron(),
        ),
        const Divider(height: 32),
      ],
    );
  }

  String _displayQuestionsLeft(int remaining) {
    if (remaining == 1) {
      return 'Du har 1 obesvarad fråga';
    }
    return 'Du har $remaining obesvarade frågor';
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
