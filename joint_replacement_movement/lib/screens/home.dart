import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:joint_replacement_movement/state/state.dart';
import 'package:movement_code/components/average_steps.dart';
import 'package:movement_code/components/step_chart.dart';

class DataTab extends ConsumerWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Tack för din medverkan!',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle
                          .copyWith(fontSize: 24),
                    ),
                    Text(
                      'Nedan ser du dina steg före och efter operationen.',
                      textAlign: TextAlign.center,
                      style:
                          CupertinoTheme.of(context).textTheme.pickerTextStyle,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            CupertinoSegmentedControl<Period>(
              children: {
                Period.week: _segmentItem('Vecka'),
                Period.month: _segmentItem('Månad'),
                Period.quarter: _segmentItem('Kvartal'),
              },
              onValueChanged: (value) {
                ref.read(periodProvider.notifier).state = value;
              },
              groupValue: ref.watch(periodProvider),
            ),
            const SizedBox(height: 16),
            ref.watch(chartDataProvider).when(
                  data: (data) => StepDataChart(data: data),
                  error: (_, __) => const Center(child: Text('oh no')),
                  loading: () => const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
            const SizedBox(height: 16),
            const AverageSteps(),
            const SizedBox(height: 48),
            _disclaimerText(context),
          ],
        ),
      ),
    );
  }

  Widget _segmentItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(title),
    );
  }

  Widget _disclaimerText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Det här är en initiell visualsering av din data. Vi kommer att fortsätta att utveckla och förbättra den. Om du har några frågor eller funderingar, tveka inte att kontakta oss. Du kan själv utforska din data genom "Hälsa" appen',
        style: CupertinoTheme.of(context).textTheme.pickerTextStyle.copyWith(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
      ),
    );
  }
}

class QuestionnaireTab extends StatelessWidget {
  const QuestionnaireTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Frågeformulär 2'),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.graph_square),
            label: 'Din data',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_person),
            label: 'Frågeformulär 2',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return index == 0 ? const DataTab() : const QuestionnaireTab();
      },
    );
  }
}
