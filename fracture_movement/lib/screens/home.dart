import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/profile.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/screens/step_data/step_data.dart';
import 'package:fracture_movement/state/state.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final questionnaire in home.unanswered)
              QuestionnaireItem(questionnaire: questionnaire),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Historik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Divider(height: 32),
        _questionnaireHistorySection(
          context,
          ref,
          home.daily,
          home.dailyAnswers,
        ),
        _questionnaireHistorySection(
          context,
          ref,
          home.weekly,
          home.weeklyAnswers,
        ),
        _otherHistory(context, home.answered),
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

  Widget _questionnaireHistorySection(BuildContext context, WidgetRef ref,
      Questionnaire questionnaire, List<Answer> answers) {
    int remaining = ref.watch(
            questionnaireCountForOccuranceProvider(questionnaire.occurance)) -
        answers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                questionnaire.name,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              remaining > 0
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
                          _displayQuestionsLeft(remaining),
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
        const Divider(height: 24),
      ],
    );
  }

  Widget _otherHistory(BuildContext context, List<Questionnaire> answered) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Övriga svar', style: TextStyle(fontSize: 16)),
              Text(
                '${answered.length} besvarade frågeformulär',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              )
            ],
          ),
          onTap: () {
            context.goNamed('history-other');
          },
          trailing: const CupertinoListTileChevron(),
        ),
        const Divider(height: 24),
      ],
    );
  }

  String _displayQuestionsLeft(int remaining) {
    if (remaining == 1) {
      return 'Du har 1 obesvarat formulär';
    }
    return 'Du har $remaining obesvarade formulär';
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
