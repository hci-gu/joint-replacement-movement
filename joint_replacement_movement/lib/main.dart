import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:movement_code/main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: CupertinoPageScaffold(
        // navigationBar: const CupertinoNavigationBar(
        //   middle: Text('HurGårDet?'),
        // ),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        // appBar: CupertinoApp(
        //   title: const Text('Hur GÅR det?'),
        // ),
        child: IntroductionScreen(
          title: "Hur Går Det?",
        ),
        // child: ListView(
        //   children: [
        //     IntroductionScreen(),
        //     HealthDataDisplayer(),
        //     Padding(
        //       padding: EdgeInsets.all(8.0),
        //       child: CupertinoTextField(
        //         prefix: Icon(CupertinoIcons.person),
        //         placeholder: 'YYYYMMDD-XXXX',
        //         maxLines: 10,
        //       ),
        //     ),
        //     Container(
        //       margin: EdgeInsets.all(8.0),
        //       decoration: BoxDecoration(
        //         color: CupertinoColors.white,
        //         borderRadius: BorderRadius.circular(12.0),
        //       ),
        //       clipBehavior: Clip.antiAlias,
        //       child: CupertinoListTile(
        //         leading: Icon(CupertinoIcons.person),
        //         additionalInfo: Text('2021-09-01 - 2021-09-30'),
        //         title: Text(
        //             'hallå eller det här var en lång text som går aasdasd'),
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }

  // List<Widget> displayData(BuildContext context) {
  //   // split healthDataTypes based on type
  //   Map<HealthDataType, List<HealthDataPoint>> healthDataMap = {};

  //   for (HealthDataPoint dataPoint
  //       in context.watch<HealthFetcher>().healthDataList) {
  //     if (!healthDataMap.containsKey(dataPoint.type)) {
  //       healthDataMap[dataPoint.type] = [];
  //     }
  //     healthDataMap[dataPoint.type]!.add(dataPoint);
  //   }

  //   List<Widget> widgets = [];

  //   for (HealthDataType type in healthDataMap.keys) {
  //     widgets.add(
  //       HealthDataDisplayer(
  //         healthDataList: healthDataMap[type]!,
  //         type: type,
  //       ),
  //     );
  //   }

  //   return widgets;
  // }
}
