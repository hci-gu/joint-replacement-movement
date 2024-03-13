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

  // return ChartData([
  //   DataPoint(DateTime(2022, 2, 22), 3912),
  //   DataPoint(DateTime(2022, 3, 22), 4321),
  //   DataPoint(DateTime(2022, 4, 22), 3121),
  //   DataPoint(DateTime(2022, 5, 22), 3400), // date
  //   DataPoint(DateTime(2022, 5, 23), 1231),
  //   DataPoint(DateTime(2022, 5, 24), 912),
  //   DataPoint(DateTime(2022, 5, 25), 2102),
  //   DataPoint(DateTime(2022, 5, 26), 2182),
  //   DataPoint(DateTime(2022, 5, 27), 2790),
  //   DataPoint(DateTime(2022, 5, 28), 3841),
  //   DataPoint(DateTime(2022, 5, 29), 5212),
  // ], DateTime(2022, 5, 22));

  if (eventDate == null) {
    return ChartData([], DateTime.now());
  }

  List<HealthDataPoint> stepData = await ref.watch(stepDataProvider.future);
  DateTime dataUntil = eventDate.add(Duration(days: period.days + 1));

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

  List<DataPoint> pointsBefore =
      points.where((element) => eventDate.isAfter(element.date)).toList();

  Map<int, List<DataPoint>> monthMap = {0: [], 1: [], 2: []};
  for (DataPoint point in pointsBefore) {
    int month = pointsBefore.indexOf(point) ~/ 30;
    monthMap[month]!.add(point);
  }

  List<DataPoint> monthsBeforePoints = monthMap.entries.map((e) {
    double sum = e.value.map((e) => e.value).reduce((value, element) {
          return value + element;
        }) /
        e.value.length;
    return DataPoint(eventDate.subtract(Duration(days: 30 * (e.key + 1))), sum);
  }).toList();

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

  DataPoint get eventPoint =>
      points.firstWhere((element) => isSameDay(element.date, eventDate),
          orElse: () => DataPoint(eventDate, 0));

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
  final Period period;

  const StepDataChart({
    super.key,
    required this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (data.points.isEmpty) {
      return const Center(
        child: Text('Ingen data'),
      );
    }
    final lineBarsData = [
      LineChartBarData(
        color: CupertinoColors.darkBackgroundGray,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 1,
            color: CupertinoColors.black,
            strokeWidth: 2,
            strokeColor: CupertinoColors.black,
          ),
        ),
        isCurved: true,
        spots: data.pointsBefore.map((e) {
          return FlSpot(
            data.points.indexOf(e).toDouble() * 7,
            e.value,
          );
        }).toList(),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              CupertinoColors.darkBackgroundGray.withOpacity(0.1),
              CupertinoColors.darkBackgroundGray.withOpacity(0),
            ],
            stops: const [0, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      LineChartBarData(
        color: CupertinoColors.activeOrange,
        dotData: FlDotData(
          show: true,
          checkToShowDot: (spot, barData) {
            return spot.x.toInt() == 21;
          },
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: CupertinoColors.activeOrange,
            strokeWidth: 1,
            strokeColor: CupertinoColors.black,
          ),
        ),
        isCurved: true,
        spots: spotsForPointsAfter,
        barWidth: period == Period.quarter ? 1 : 2,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              CupertinoColors.activeOrange.withOpacity(0.4),
              CupertinoColors.activeOrange.withOpacity(0),
            ],
            stops: const [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      )
    ];
    final tooltipsOnBar = lineBarsData[0];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            height: 250,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: maxX,
                minY: 0,
                maxY: maxY,
                showingTooltipIndicators: [
                  ShowingTooltipIndicators([
                    LineBarSpot(
                      tooltipsOnBar,
                      lineBarsData.indexOf(tooltipsOnBar),
                      tooltipsOnBar.spots.last,
                    ),
                  ])
                ],
                gridData: const FlGridData(
                  show: false,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2500,
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

                        return Text('${val}k', style: _chartTextStyle(context));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 7,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value > 21) {
                          if (value % 21 == 0) {
                            DataPoint point = data.pointsAfter[
                                (value - 21).toInt() ~/ multiplier];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                _shortDate(point.date),
                                style: _chartTextStyle(context),
                              ),
                            );
                          }
                        }
                        if (value > 14) {
                          return const SizedBox.shrink();
                        }
                        int index = value ~/ 7;

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${3 - index}',
                            style: _chartTextStyle(context),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(),
                ),
                lineBarsData: lineBarsData,
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: CupertinoColors.activeBlue.withOpacity(0.9),
                    tooltipRoundedRadius: 4,
                    tooltipPadding: const EdgeInsets.all(6),
                    tooltipMargin: 8,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                      return lineBarsSpot.map((lineBarSpot) {
                        return LineTooltipItem(
                          'Operation\n$date',
                          const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          Text(
            'Mån innan operation',
            style: _chartTextStyle(context),
          ),
        ],
      ),
    );
  }

  TextStyle _chartTextStyle(BuildContext context) => CupertinoTheme.of(context)
      .textTheme
      .tabLabelTextStyle
      .copyWith(fontSize: 12);

  double get minX => data.points.first.date.millisecondsSinceEpoch.toDouble();
  int get multiplier {
    switch (period) {
      case Period.week:
        return 13;
      case Period.month:
        return 3;
      case Period.quarter:
        return 1;
    }
  }

  double get maxX =>
      21 + ((data.pointsAfter.length - 1) * multiplier).toDouble();
  List<FlSpot> get spotsForPointsAfter {
    return data.pointsAfter
        .map((e) => FlSpot(
              21 + (data.pointsAfter.indexOf(e).toDouble() * multiplier),
              e.value,
            ))
        .toList();
  }

  double get maxY {
    return data.points.map((e) => e.value).reduce((value, element) {
      if (value > element) {
        return value;
      }
      return element;
    });
  }

  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _shortDate(DateTime d) {
    return '${_monthToShortName(d.month)}-${_pad(d.day)}';
  }

  String _displayDate(DateTime d) {
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  String get date => _displayDate(data.eventDate);

  String _monthToShortName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'Maj';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Okt';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return '';
  }
}
