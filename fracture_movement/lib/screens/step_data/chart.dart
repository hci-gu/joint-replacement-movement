import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/step_data/state.dart';

class StepDataChart extends HookWidget {
  final ChartData data;
  final DisplayMode displayMode;

  const StepDataChart({
    super.key,
    required this.data,
    required this.displayMode,
  });

  @override
  Widget build(BuildContext context) {
    double eventIndex = data.points.indexOf(data.eventPoint).toDouble();
    ScrollController controller = useScrollController();

    useEffect(() {
      Future.delayed(Duration.zero, () {
        if (controller.hasClients) {
          controller.jumpTo(
              (data.points.indexOf(data.eventPoint) - 7).toDouble() * 8.0);
        }
      });
      return () {};
    }, [controller.hasClients]);

    if (data.points.isEmpty) {
      return const Center(
        child: Text('Ingen data'),
      );
    }
    final lineBarsData = [
      LineChartBarData(
        color: CupertinoColors.darkBackgroundGray,
        dotData: FlDotData(
          show: false,
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
            data.points.indexOf(e).toDouble(),
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
            return spot.x == eventIndex;
          },
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 3,
            color: CupertinoColors.activeOrange,
            strokeWidth: 1,
            strokeColor: CupertinoColors.black,
          ),
        ),
        isCurved: true,
        spots: data.pointsAfter
            .map((e) => FlSpot(
                  data.points.indexOf(e).toDouble(),
                  e.value,
                ))
            .toList(),
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
      child: SizedBox(
        height: 250,
        child: ListView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          children: [
            SizedBox(
              width: 8 * data.points.length.toDouble(),
              child: LineChart(
                LineChartData(
                  minX: minX,
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
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    checkToShowHorizontalLine: (value) => value == 5000,
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
                          String val = (value ~/ 1000).toString();

                          return Text('${val}k',
                              style: _chartTextStyle(context));
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          String val = (value ~/ 1000).toString();

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${val}k', style: _chartTextStyle(context)),
                            ],
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 7,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value == minX || value == maxX) {
                            return const SizedBox();
                          }

                          DataPoint point = data.points[value.toInt()];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              _shortDate(point.date),
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
                      tooltipBgColor:
                          CupertinoColors.activeBlue.withOpacity(0.9),
                      tooltipRoundedRadius: 4,
                      tooltipPadding: const EdgeInsets.all(6),
                      tooltipMargin: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                        return lineBarsSpot.map((lineBarSpot) {
                          return LineTooltipItem(
                            'Fraktur\n$date',
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
            )
          ],
        ),
      ),
    );
  }

  TextStyle _chartTextStyle(BuildContext context) => CupertinoTheme.of(context)
      .textTheme
      .tabLabelTextStyle
      .copyWith(fontSize: 12);

  double get minX => 0;
  double get maxX => ((data.points.length - 1)).toDouble();

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
