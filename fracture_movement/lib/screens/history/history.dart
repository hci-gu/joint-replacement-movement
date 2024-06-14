import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/history/chart.dart';
import 'package:fracture_movement/screens/history/state.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/theme.dart';
import 'package:fracture_movement/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class DailyQuestionnaireList extends ConsumerWidget {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  const DailyQuestionnaireList({
    super.key,
    required this.questionnaire,
    required this.answers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime now = DateTime.now();

    int days = ref
        .watch(questionnaireCountForOccuranceProvider(questionnaire.occurance));

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: days + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.775,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Smärtnivå',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            clipBehavior: Clip.none,
                            decoration: const BoxDecoration(
                              color: CupertinoColors.activeBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Vald smärtnivå',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }
        int dayIndex = index - 1;

        DateTime day = DateTime(
          now.year,
          now.month,
          now.day - dayIndex,
          12,
        );
        Answer? answer = answers.firstWhereOrNull(
          (e) => isSameDay(e.date, day),
        );

        return Column(
          children: [
            CupertinoListTile(
              onTap: () {
                if (answer == null) {
                  context.goNamed(
                    'questionnaire-history',
                    pathParameters: {
                      'id': questionnaire.id,
                    },
                    queryParameters: {
                      'date': day.toIso8601String(),
                    },
                  );
                }
              },
              padding: paddingForContext(context),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dag ${days - dayIndex}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _dayString(day),
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              trailing: answer == null
                  ? const Row(
                      children: [
                        Text(
                          'Inte besvarad',
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                        SizedBox(width: 8),
                        CupertinoListTileChevron(),
                      ],
                    )
                  : _painLevel(context, answer),
            ),
            const Divider(
              indent: 8,
              height: 0,
            ),
          ],
        );
      },
    );
  }

  String _dayString(DateTime date) {
    if (isSameDay(date, DateTime.now())) {
      return 'Idag';
    }
    if (isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Igår';
    }

    return DateFormat.MEd().format(date);
  }

  Widget _painLevel(BuildContext context, Answer answer) {
    // search for number value in answer.answers
    int painLevel = 0;
    answer.answers.forEach((key, value) {
      // check if value is number
      if (value is int) {
        painLevel = value;
      }
    });

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i <= 10; i++)
            Container(
              width: 24,
              height: 24,
              clipBehavior: Clip.none,
              decoration: i == painLevel
                  ? const BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Center(
                child: Text(
                  '$i',
                  style: TextStyle(
                    color: i == painLevel
                        ? Colors.white
                        : CupertinoColors.systemGrey,
                    fontWeight:
                        i == painLevel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class DailyQuestionnaireHistory extends StatelessWidget {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  const DailyQuestionnaireHistory({
    super.key,
    required this.questionnaire,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(questionnaire.name),
      ),
      child: ListView(
        children: [
          DailyQuestionnaireChart(
            data: answersToDataPoints(answers),
          ),
          const Divider(indent: 16, endIndent: 16),
          DailyQuestionnaireList(
            questionnaire: questionnaire,
            answers: answers,
          ),
        ],
      ),
    );
  }

  List<DataPoint> answersToDataPoints(List<Answer> answers) {
    if (answers.isEmpty) {
      return [];
    }

    answers.sort((a, b) => a.date.compareTo(b.date));
    DateTime first = answers.first.date;
    DateTime now = DateTime.now();

    int days = now.difference(first).inDays + 2;

    List<DataPoint> dataPoints = [];

    for (int i = 0; i < days; i++) {
      DateTime date = DateTime(first.year, first.month, first.day + i);
      Answer? answer = answers.firstWhereOrNull(
        (e) => isSameDay(e.date, date),
      );

      dataPoints.add(
        DataPoint(
          i,
          answer?.answers['g5j8zrq9amdc2op'],
          answer?.answers['jfemvmwajnsfkex'],
        ),
      );
    }

    return dataPoints;
  }
}

class WeeklyQuestionnaireList extends ConsumerWidget {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  const WeeklyQuestionnaireList({
    super.key,
    required this.questionnaire,
    required this.answers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int weeks = ref
        .watch(questionnaireCountForOccuranceProvider(questionnaire.occurance));
    DateTime now = DateTime.now();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Historik'),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: weeks + 1,
        itemBuilder: (context, index) {
          int weekIndex = index - 1;

          DateTime week = DateTime(
            now.year,
            now.month,
            now.day - (weekIndex * 7),
            12,
          );
          Answer? answer = answers.firstWhereOrNull(
            (e) => isSameWeek(e.date, week),
          );

          return Column(children: [
            CupertinoListTile(
              onTap: () {
                if (answer == null) {
                  context.goNamed(
                    'questionnaire-history',
                    pathParameters: {
                      'id': questionnaire.id,
                    },
                    queryParameters: {
                      'date': week.toIso8601String(),
                    },
                  );
                }
              },
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vecka ${weeks - weekIndex}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat.MMMMEEEEd().format(week),
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              trailing: answer == null
                  ? const Row(
                      children: [
                        Text(
                          'Inte besvarad',
                          style: TextStyle(color: CupertinoColors.systemGrey),
                        ),
                        SizedBox(width: 8),
                        CupertinoListTileChevron(),
                      ],
                    )
                  : const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: CupertinoColors.activeGreen,
                    ),
            ),
          ]);
        },
      ),
    );
  }
}

class HistoryScreen extends ConsumerWidget {
  final String questionnaireId;

  const HistoryScreen({
    super.key,
    required this.questionnaireId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(questionnaireAnswersProvider(questionnaireId)).when(
          data: (data) {
            if (data.questionnaire.occurance == Occurance.daily) {
              return DailyQuestionnaireHistory(
                questionnaire: data.questionnaire,
                answers: data.answers,
              );
            }

            return WeeklyQuestionnaireList(
              questionnaire: data.questionnaire,
              answers: data.answers,
            );
          },
          loading: () => const Center(
            child: CupertinoActivityIndicator(),
          ),
          error: (error, _) => Center(
            child: Text('Error: $error'),
          ),
        );
  }
}

class OtherHistoryScreen extends ConsumerWidget {
  const OtherHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Historik'),
      ),
      child: ref.watch(otherQuestionnairesWithAnswersProvider).when(
            data: (List<QuestionnaireWithAnswers> questionnaires) => ListView(
              children: [
                for (var item in questionnaires)
                  Column(
                    children: [
                      CupertinoListTile(
                        onTap: () {
                          context.goNamed(
                            'questionnaire-history',
                            pathParameters: {
                              'id': item.questionnaire.id,
                            },
                          );
                        },
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        title: Text(
                          item.questionnaire.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: item.answers.isNotEmpty
                            ? Text(
                                DateFormat.MMMMEEEEd()
                                    .format(item.answers.first.date),
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                        trailing: item.answers.isEmpty
                            ? const Text(
                                'Inte besvarad',
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                ),
                              )
                            : const Icon(
                                CupertinoIcons.check_mark_circled,
                                color: CupertinoColors.activeGreen,
                              ),
                      ),
                      const Divider(
                        indent: 16,
                        endIndent: 16,
                        height: 0,
                      ),
                    ],
                  ),
              ],
            ),
            error: (_, __) => const Center(
              child: Text('error'),
            ),
            loading: () => const Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
    );
  }
}
