import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';

HealthFactory health = HealthFactory();

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

enum Period {
  week,
  month,
  quarter,
}

extension PeriodToDays on Period {
  int get days {
    switch (this) {
      case Period.week:
        return 7;
      case Period.month:
        return 30;
      case Period.quarter:
        return 90;
    }
  }
}

final periodProvider = StateProvider((ref) => Period.week);

final stepDataProvider = FutureProvider<List<HealthDataPoint>>((ref) async {
  DateTime? eventDate = ref.watch(operationDateProvider);

  if (eventDate == null) {
    return [];
  }

  DateTime threeMonthsBefore = eventDate.subtract(const Duration(days: 90));
  DateTime threeMonthsAfter = eventDate.add(const Duration(days: 90));

  List<HealthDataPoint> stepData = await HealthFactory().getHealthDataFromTypes(
      threeMonthsBefore, threeMonthsAfter, [HealthDataType.STEPS]);

  return stepData;
});

final chartDataProvider = FutureProvider<ChartData>((ref) async {
  DateTime? eventDate = ref.watch(operationDateProvider);
  Period period = ref.watch(periodProvider);

  if (eventDate == null) {
    return ChartData([], DateTime.now());
  }

  List<HealthDataPoint> stepData = await ref.watch(stepDataProvider.future);
  DateTime dataUntil = eventDate.add(Duration(days: period.days));

  stepData = stepData.where((e) => e.dateFrom.isBefore(dataUntil)).toList();

  Map<String, List<HealthDataPoint>> deviceMap = {};
  for (HealthDataPoint point in stepData) {
    if (deviceMap[point.deviceId] == null) {
      deviceMap[point.deviceId] = [];
    }
    deviceMap[point.deviceId]!.add(point);
  }

  // take device with most data
  List<DataPoint> data = deviceMap.values
      .reduce((value, element) {
        if (value.length > element.length) {
          return value;
        }
        return element;
      })
      .map((e) => DataPoint.fromHealthDataPoint(e))
      .toList();

  Map<DateTime, List<DataPoint>> dayMap = {};

  for (DataPoint point in data) {
    DateTime date = DateTime(point.date.year, point.date.month, point.date.day);
    if (dayMap[date] == null) {
      dayMap[date] = [];
    }
    dayMap[date]!.add(point);
  }

  DataPoint eventPoint = DataPoint(eventDate, 0);

  List<DataPoint> points = dayMap.entries.map((e) {
    double sum = e.value.map((e) => e.value).reduce((value, element) {
      return value + element;
    });
    if (isSameDay(e.key, eventDate)) {
      eventPoint = DataPoint(e.key, sum);
    }
    return DataPoint(e.key, sum);
  }).toList();

  Map<DateTime, List<DataPoint>> monthMap = {};
  for (DataPoint point in points) {
    DateTime date = DateTime(point.date.year, point.date.month);
    if (monthMap[date] == null) {
      monthMap[date] = [];
    }
    monthMap[date]!.add(point);
  }

  List<DataPoint> monthsBeforePoints = monthMap.entries
      .map((e) {
        double sum = e.value.map((e) => e.value).reduce((value, element) {
              return value + element;
            }) /
            e.value.length;
        return DataPoint(e.key, sum);
      })
      .where((e) => e.date.isBefore(eventDate))
      .toList();

  List<DataPoint> dataToShow = [
    ...monthsBeforePoints,
    eventPoint,
    ...points.where((element) => element.date.isAfter(eventDate))
  ];
  dataToShow.sort((a, b) => a.date.compareTo(b.date));

  return ChartData(dataToShow, eventDate);
});

final averageStepsBeforeProvider = FutureProvider<double>((ref) async {
  ChartData data = await ref.watch(chartDataProvider.future);

  return data.pointsBefore.map((e) => e.value).reduce((value, element) {
        return value + element;
      }) /
      data.pointsBefore.length;
});

final averageStepsAfterProvider = FutureProvider<double>((ref) async {
  ChartData data = await ref.watch(chartDataProvider.future);

  return data.pointsAfter.map((e) => e.value).reduce((value, element) {
        return value + element;
      }) /
      data.pointsAfter.length;
});

class ChartData {
  final List<DataPoint> points;
  final DateTime eventDate;

  ChartData(this.points, this.eventDate);

  // List<DataPoint> get pointsBefore {
  //   Map<DateTime, List<DataPoint>> monthMap = {};
  //   List<DataPoint> pointsBefore = points
  //       .where((element) =>
  //           eventDate.isBefore(element.date) ||
  //           eventDate.isAtSameMomentAs(element.date))
  //       .toList();

  //   for (DataPoint point in pointsBefore) {
  //     DateTime date = DateTime(point.date.year, point.date.month);
  //     if (monthMap[date] == null) {
  //       monthMap[date] = [];
  //     }
  //     monthMap[date]!.add(point);
  //   }

  //   List<DataPoint> _points = monthMap.entries.map((e) {
  //     double sum = e.value.map((e) => e.value).reduce((value, element) {
  //           return value + element;
  //         }) /
  //         e.value.length;
  //     return DataPoint(e.key, sum);
  //   }).toList();

  //   return _points;
  // }
  List<DataPoint> get pointsBefore => points
      .where((element) =>
          eventDate.isAfter(element.date) ||
          eventDate.isAtSameMomentAs(element.date))
      .toList();

  List<DataPoint> get pointsAfter => points
      .where((element) =>
          eventDate.isBefore(element.date) ||
          eventDate.isAtSameMomentAs(element.date))
      .toList();
}

class DataPoint {
  final DateTime date;
  final double value;

  DataPoint(this.date, this.value);

  // from HealthDataPoint
  factory DataPoint.fromHealthDataPoint(HealthDataPoint hp) {
    Map<String, dynamic> json = hp.value.toJson();
    String value = json['numericValue'];
    return DataPoint(hp.dateFrom, double.parse(value));
  }
}

class StepDataChart extends StatelessWidget {
  final ChartData data;

  const StepDataChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.points.isEmpty) {
      return const Center(
        child: Text('Ingen data'),
      );
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        padding: const EdgeInsets.all(8.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: data.points.length.toDouble() - 1,
            minY: 0,
            maxY: maxY,
            gridData: const FlGridData(
              show: false,
            ),
            borderData: FlBorderData(
              show: false,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max) return const SizedBox.shrink();

                    String val = (value ~/ 1000).toString();

                    return Text('${val}k',
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .tabLabelTextStyle
                            .copyWith(fontSize: 14));
                  },
                ),
              ),
              rightTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                  // interval: 30 * 24 * 60 * 60 * 1000,
                  getTitlesWidget: (value, TitleMeta meta) {
                    DateTime date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text('${date.day}/${date.month}'),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(),
            ),
            lineBarsData: [
              LineChartBarData(
                color: CupertinoColors.darkBackgroundGray,
                dotData: FlDotData(
                  // show: false,
                  checkToShowDot: (spot, barData) {
                    return isSameDay(
                        DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()),
                        data.eventDate);
                  },
                ),
                isCurved: true,
                showingIndicators: [0, 3, 5],
                spots: data.pointsBefore
                    .map((e) => FlSpot(
                          data.points.indexOf(e).toDouble(),
                          e.value,
                        ))
                    .toList(),
              ),
              LineChartBarData(
                color: CupertinoColors.activeOrange,
                dotData: FlDotData(
                  // show: false,
                  checkToShowDot: (spot, barData) {
                    DataPoint dataPoint = data.points[spot.x.toInt()];
                    return isSameDay(dataPoint.date, data.eventDate);
                  },
                ),
                isCurved: true,
                spots: data.pointsAfter
                    .map((e) => FlSpot(
                          data.points.indexOf(e).toDouble(),
                          e.value,
                        ))
                    .toList(),
              )
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: CupertinoColors.destructiveRed,
                tooltipRoundedRadius: 8,
                getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                  return lineBarsSpot.map((lineBarSpot) {
                    return LineTooltipItem(
                      lineBarSpot.y.toString(),
                      const TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
              // getTouchedSpotIndicator:
              //     (LineChartBarData barData, List<int> spotIndexes) {
              //   return spotIndexes.map((index) {
              //     return TouchedSpotIndicatorData(
              //       const FlLine(
              //         color: CupertinoColors.activeBlue,
              //       ),
              //       FlDotData(
              //         show: true,
              //         getDotPainter: (spot, percent, barData, index) =>
              //             FlDotCirclePainter(
              //           radius: 8,
              //           color: CupertinoColors.destructiveRed,
              //           strokeWidth: 2,
              //           strokeColor: CupertinoColors.black,
              //         ),
              //       ),
              //     );
              //   }).toList();
              // },
            ),
          ),
        ),
      ),
    );
  }

  double get minX => data.points.first.date.millisecondsSinceEpoch.toDouble();
  double get maxX => data.points.last.date.millisecondsSinceEpoch.toDouble();
  double get maxY {
    return data.points.map((e) => e.value).reduce((value, element) {
      if (value > element) {
        return value;
      }
      return element;
    });
  }
}
