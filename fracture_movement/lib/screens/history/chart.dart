import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

enum Medication {
  paracetamol,
  antiInflammatory,
  morphineShort,
  morphineLong,
  other
}

extension MedicationDisplayExtension on Medication {
  int get sortValue {
    switch (this) {
      case Medication.paracetamol:
        return 0;
      case Medication.antiInflammatory:
        return 1;
      case Medication.morphineShort:
        return 2;
      case Medication.morphineLong:
        return 3;
      case Medication.other:
        return 4;
    }
  }

  String get display {
    switch (this) {
      case Medication.paracetamol:
        return 'Paracetamoltyp\n( ex Panodil, Alvedon )';
      case Medication.antiInflammatory:
        return 'Inflammationsdämpande värktabletter (ex. Ipren )';
      case Medication.morphineShort:
        return 'Kortverkande morfintabletter\n( ex Oxynorm )';
      case Medication.morphineLong:
        return 'Långverkande morfintabletter\n( ex Oxycontin )';
      case Medication.other:
        return 'Annan typ';
    }
  }

  String get shortName {
    switch (this) {
      case Medication.paracetamol:
        return 'Paracetamoltyp';
      case Medication.antiInflammatory:
        return 'Inflammationsdämpande';
      case Medication.morphineShort:
        return 'Kortverkande Morfintabletter';
      case Medication.morphineLong:
        return 'Långverkande Morfintabletter';
      case Medication.other:
        return 'Annan typ';
    }
  }

  Color get color {
    switch (this) {
      case Medication.paracetamol:
        return Colors.orange.shade900;
      case Medication.antiInflammatory:
        return Colors.orange.shade700;
      case Medication.morphineShort:
        return Colors.orange.shade500;
      case Medication.morphineLong:
        return Colors.orange.shade300;
      case Medication.other:
        return Colors.orange.shade100;
    }
  }
}

class DataPoint {
  final int day;
  final int? value;
  final Map<Medication, int>? medication;

  DataPoint(this.day, this.value, Map<String, dynamic>? medication)
      : medication = medication?.map((key, value) {
          Medication medication = Medication.values.firstWhere(
            (element) => element.display == key,
          );
          return MapEntry(medication, value);
        });
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
    ScrollController controller = useScrollController();
    ValueNotifier<List<Medication>> visibleMedications = useState([]);

    useEffect(() {
      listener() {
        List<Medication> medications = dataPointsForScrollOffset(
                context, controller.offset, controller.position.maxScrollExtent)
            .map((e) => e.medication?.keys)
            .where((element) => element != null)
            .expand((element) => element!)
            .toSet()
            .toList();
        visibleMedications.value = medications;
      }

      controller.addListener(listener);

      Future.delayed(Duration.zero, () {
        if (controller.hasClients) {
          controller.jumpTo(controller.position.maxScrollExtent);
        }
      });
      return () {
        controller.removeListener(listener);
      };
    }, [controller.hasClients]);

    return SizedBox(
      height: 216,
      child: Scrollbar(
        child: Stack(
          children: [
            _legend(visibleMedications.value),
            ListView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              children: [
                Stack(children: [
                  SizedBox(
                    width: max(
                        MediaQuery.of(context).size.width, data.length * 48.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceBetween,
                        maxY: 10,
                        minY: 0,
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: hideChartTitle,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        barGroups: barsForMedication,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: max(
                      MediaQuery.of(context).size.width,
                      data.length * 48.0,
                    ),
                    child: LineChart(
                      LineChartData(
                        backgroundColor: Colors.transparent,
                        gridData: const FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                        ),
                        titlesData: titles,
                        borderData: FlBorderData(
                          show: false,
                        ),
                        minX: 0,
                        maxX: (data.length - 1).toDouble(),
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var point in data)
                                if (point.value != null)
                                  FlSpot(
                                    point.day.toDouble(),
                                    point.value!.toDouble(),
                                  ),
                            ],
                            isCurved: false,
                            barWidth: 1,
                            color: CupertinoColors.activeBlue,
                            dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: CupertinoColors.activeBlue,
                                    strokeWidth: 1,
                                    strokeColor: CupertinoColors.black,
                                  );
                                }),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            tooltipBgColor: CupertinoColors.systemGrey6,
                            maxContentWidth: 160,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((touchedSpot) {
                                DataPoint point = data[touchedSpot.x.toInt()];

                                return LineTooltipItem(
                                    'Smärta: ${point.value}\n',
                                    const TextStyle(
                                      color: CupertinoColors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: medicationText(point),
                                        style: const TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ]);
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ])
              ],
            ),
          ],
        ),
      ),
    );
  }

  FlTitlesData get titles => FlTitlesData(
        show: true,
        topTitles: hideChartTitle,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              // if (value == 0 || value == (data.length - 1)) {
              //   return const SizedBox.shrink();
              // }
              DateTime date = dateFromIndex(value.toInt());
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
      );

  DateTime dateFromIndex(int index) {
    DateTime now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day - (data.length - index - 1),
    );
  }

  List<DataPoint> dataPointsForScrollOffset(
      context, double scrollOffset, double maxExtent) {
    double dayWidth = maxExtent / data.length;
    int visibleDays = MediaQuery.of(context).size.width ~/ dayWidth;
    int index = scrollOffset ~/ dayWidth;

    return data.sublist(
      max(0, index - visibleDays),
      min(data.length, index + visibleDays),
    );
  }

  List<BarChartGroupData> get barsForMedication {
    return data.map((e) {
      List<Medication> medications =
          e.medication != null ? e.medication!.keys.toList() : [];
      medications.sort((a, b) => a.sortValue.compareTo(b.sortValue));

      double maxY = e.medication?.entries
              .map((entry) => entry.value.toDouble())
              .reduce((value, element) => value + element) ??
          0;
      double currentY = 0;

      return BarChartGroupData(
        x: e.day,
        barRods: [
          BarChartRodData(
            fromY: 0,
            toY: maxY,
            width: 8,
            color: Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            borderSide: BorderSide(
              color: CupertinoColors.black.withOpacity(0.7),
              width: 1,
            ),
            rodStackItems: e.medication != null
                ? medications.map((entry) {
                    double value = e.medication![entry]!.toDouble();

                    var rod = BarChartRodStackItem(
                      currentY,
                      currentY + value,
                      entry.color,
                    );
                    currentY += value;
                    return rod;
                  }).toList()
                : [],
          )
        ],
      );
    }).toList();
  }

  String medicationText(DataPoint point) {
    if (point.medication == null) {
      return 'Ingen medicin';
    }
    return point.medication!.entries
        .map((entry) => '${entry.key.shortName}: ${entry.value}')
        .join('\n');
  }

  Widget _legend(List<Medication> medications) {
    // sort medications by name
    medications.sort((a, b) => a.sortValue.compareTo(b.sortValue));
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: CupertinoColors.systemGrey,
      //     width: 1,
      //   ),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Wrap(
          spacing: 8,
          children: [
            for (var medication in medications) _legendItem(medication),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Medication medication) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: medication.color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          medication.shortName,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
