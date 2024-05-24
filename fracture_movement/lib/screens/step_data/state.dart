import 'package:fracture_movement/pocketbase.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

final eventDateProvider = FutureProvider<DateTime?>((ref) async {
  List<Answer> answers = await getAnswersForQuestionnaire('o0kztzavvw04a8c');
  DateTime? date;

  for (var answer in answers) {
    // loop keys/vals of answer.answers
    for (var value in answer.answers.values) {
      // type of value is string
      if (value is String && DateTime.tryParse(value) != null) {
        date = DateTime.parse(value);
      }
    }
  }
  return date;
});

enum DisplayMode {
  day,
  week,
  month,
}

extension DisplayModeToDays on DisplayMode {
  int get days {
    switch (this) {
      case DisplayMode.day:
        return 1;
      case DisplayMode.week:
        return 7;
      case DisplayMode.month:
        return 30;
    }
  }
}

final displayModeProvider =
    StateProvider<DisplayMode>((ref) => DisplayMode.day);

final stepDataProvider = FutureProvider<List<HealthDataPoint>>((ref) async {
  DateTime? eventDate = await ref.watch(eventDateProvider.future);

  if (eventDate == null) {
    return [];
  }

  DateTime threeMonthsBefore = eventDate.subtract(const Duration(days: 90));

  List<HealthDataPoint> stepData = await HealthFactory().getHealthDataFromTypes(
      threeMonthsBefore, DateTime.now(), [HealthDataType.STEPS]);

  return stepData;
});

DateTime dateForPointAndMode(DateTime date, DisplayMode mode) {
  switch (mode) {
    case DisplayMode.day:
      return DateTime(date.year, date.month, date.day);
    case DisplayMode.week:
      return DateTime(date.year, date.month, date.day - date.weekday + 1);
    case DisplayMode.month:
      return DateTime(date.year, date.month, 1);
  }
}

final chartDataProvider = FutureProvider<ChartData>((ref) async {
  DateTime? eventDate = await ref.watch(eventDateProvider.future);
  if (eventDate == null) {
    return ChartData([], DateTime.now());
  }

  // DateTime eventDate = DateTime.now().subtract(Duration(days: 30));
  DisplayMode displayMode = ref.watch(displayModeProvider);

  List<HealthDataPoint> stepData = await ref.watch(stepDataProvider.future);
  DateTime dataUntil = DateTime.now();

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

  Map<DateTime, List<DataPoint>> dateMap = {};

  for (DataPoint point in data) {
    DateTime date = DateTime(point.date.year, point.date.month, point.date.day);
    if (dateMap[date] == null) {
      dateMap[date] = [];
    }
    dateMap[date]!.add(point);
  }

  DataPoint eventPoint = DataPoint(eventDate, 0);

  List<DataPoint> points = dateMap.entries.map((e) {
    double sum = e.value.map((e) => e.value).reduce((value, element) {
      return value + element;
    });
    if (isSameDay(e.key, eventDate)) {
      eventPoint = DataPoint(e.key, sum);
    }
    return DataPoint(e.key, sum);
  }).toList();

  List<DataPoint> pointsBefore =
      points.where((element) => element.date.isBefore(eventDate)).toList();
  List<DataPoint> pointsAfter =
      points.where((element) => element.date.isAfter(eventDate)).toList();

  List<DataPoint> dataToShow = [...pointsBefore, eventPoint, ...pointsAfter];
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
