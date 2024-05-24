import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/history/state.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/utils.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class DataPoint {
  final DateTime date;
  final int value;

  DataPoint(this.date, this.value);
}

const hideChartTitle = AxisTitles(
  sideTitles: SideTitles(
    showTitles: false,
  ),
);

class DailyQuestionnaireChart extends HookWidget {
  final List<DataPoint> data;

  const DailyQuestionnaireChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double minX = data.first.date.millisecondsSinceEpoch.toDouble();
    double maxX = DateTime.now().millisecondsSinceEpoch.toDouble();
    int days = DateTime.now().difference(data.first.date).inDays + 1;
    ScrollController controller = useScrollController();

    useEffect(() {
      Future.delayed(Duration.zero, () {
        if (controller.hasClients) {
          controller.jumpTo(controller.position.maxScrollExtent);
        }
      });
      return () {};
    }, [controller.hasClients]);

    return SizedBox(
      height: 216,
      child: ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        children: [
          SizedBox(
            width: days * 48.0,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: hideChartTitle,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxX - minX) / days,
                      getTitlesWidget: (value, meta) {
                        if (value == minX || value == maxX) {
                          return const SizedBox.shrink();
                        }
                        DateTime date =
                            DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat.Md().format(date),
                              style: const TextStyle(
                                color: CupertinoColors.systemGrey,
                                fontSize: 11,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: minX,
                maxX: maxX,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var point in data)
                        FlSpot(
                          point.date.millisecondsSinceEpoch.toDouble(),
                          point.value.toDouble(),
                        ),
                    ],
                    isCurved: false,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    color: CupertinoColors.activeBlue,
                    dotData: const FlDotData(show: true),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    tooltipBgColor: CupertinoColors.systemGrey6,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          touchedSpot.y.toInt().toString(),
                          const TextStyle(
                            color: CupertinoColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
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

class DailyQuestionnaireHistory extends HookConsumerWidget {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  const DailyQuestionnaireHistory({
    super.key,
    required this.questionnaire,
    required this.answers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> chartVisible = useState(true);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(questionnaire.name),
        trailing: IconButton(
          onPressed: () {
            chartVisible.value = !chartVisible.value;
          },
          icon: chartVisible.value
              ? const Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                )
              : const Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  color: CupertinoColors.systemGrey,
                ),
        ),
      ),
      child: ListView(
        children: [
          DailyQuestionnaireChart(
            data: answers
                .map(
                  (e) => DataPoint(
                    e.date,
                    e.answers['g5j8zrq9amdc2op'] ?? 5,
                  ),
                )
                .sorted((a, b) => a.date.compareTo(b.date))
                .toList(),
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
}

class WeeklyQuestionnaireList extends StatelessWidget {
  final Questionnaire questionnaire;
  final List<Answer> answers;

  const WeeklyQuestionnaireList({
    super.key,
    required this.questionnaire,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    int weeks = weeksForAnswers(answers);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Historik'),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: weeks + 2,
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
                    'Vecka ${(weeks - weekIndex) + 1}',
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
