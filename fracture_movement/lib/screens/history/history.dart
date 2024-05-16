import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fracture_movement/screens/history/state.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class DailyQuestionnaireList extends StatelessWidget {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  const DailyQuestionnaireList({
    super.key,
    required this.questionnaire,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    int days = daysForAnswers(answers);

    return ListView.builder(
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
                          const SizedBox(width: 8),
                          Container(
                            width: 12,
                            height: 12,
                            clipBehavior: Clip.none,
                            decoration: const BoxDecoration(
                              color: CupertinoColors.activeOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'med medicinering',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        }

        DateTime day = DateTime(
          now.year,
          now.month,
          now.day - index,
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
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dag ${(days - index) + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat.MEd().format(day),
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

  Widget _painLevel(BuildContext context, Answer answer) {
    // search for number value in answer.answers
    int painLevel = 0;
    answer.answers.forEach((key, value) {
      // check if value is number
      if (value is int) {
        painLevel = value;
      }
    });
    bool tookMedication = false;
    answer.answers.forEach((key, value) {
      if (value is String) {
        tookMedication = value == "Ja";
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
                  ? BoxDecoration(
                      color: tookMedication
                          ? CupertinoColors.activeOrange
                          : CupertinoColors.activeBlue,
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

class HistoryScreen extends ConsumerWidget {
  final String questionnaireId;

  const HistoryScreen({
    super.key,
    required this.questionnaireId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Historik'),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.chart_bar_alt_fill),
        ),
      ),
      child: ref.watch(questionnaireAnswersProvider(questionnaireId)).when(
            data: (data) {
              if (data.questionnaire.occurance == Occurance.daily) {
                return DailyQuestionnaireList(
                  questionnaire: data.questionnaire,
                  answers: data.answers,
                );
              }

              return ListView.builder(
                itemCount: data.answers.length,
                itemBuilder: (context, index) {
                  final answer = data.answers[index];
                  return CupertinoListTile.notched(
                    title: Text(answer.questionnaireId),
                    subtitle: Text(
                      answer.date.toIso8601String(),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CupertinoActivityIndicator(),
            ),
            error: (error, _) => Center(
              child: Text('Error: $error'),
            ),
          ),
    );
  }
}
