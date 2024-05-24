import 'package:flutter/cupertino.dart';
import 'package:fracture_movement/screens/step_data/average_steps.dart';
import 'package:fracture_movement/screens/step_data/chart.dart';
import 'package:fracture_movement/screens/step_data/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StepDataScreen extends ConsumerWidget {
  const StepDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Text(
                'Din stegdata',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navTitleTextStyle
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Text(
                'Nedan ser du dina steg före och efter frakturen.',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .pickerTextStyle
                    .copyWith(fontSize: 16),
              ),
            ),
            _divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: CupertinoSegmentedControl<DisplayMode>(
                children: {
                  DisplayMode.day: _segmentItem('Dag'),
                  DisplayMode.week: _segmentItem('Vecka'),
                  DisplayMode.month: _segmentItem('Månad'),
                },
                onValueChanged: (value) {
                  ref.read(displayModeProvider.notifier).state = value;
                },
                groupValue: ref.watch(displayModeProvider),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            ref.watch(chartDataProvider).when(
                  data: (data) => data.pointsAfter.length >= 2
                      ? StepDataChart(
                          data: data,
                          displayMode: ref.watch(displayModeProvider),
                        )
                      : _notEnoughData(context),
                  error: (_, __) =>
                      _chartContainer(const Center(child: Text('-'))),
                  loading: () => _chartContainer(
                    const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  ),
                ),
            _divider(),
            const AverageSteps(),
            const SizedBox(height: 16),
            _disclaimerText(context),
          ],
        ),
      ),
    );
  }

  Widget _notEnoughData(BuildContext context) {
    return _chartContainer(
      Center(
        child: Text(
          'Det finns inte tillräckligt med data för att generera en graf.',
          style: CupertinoTheme.of(context).textTheme.pickerTextStyle.copyWith(
                fontSize: 16,
              ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        height: 1,
        color: CupertinoColors.black.withOpacity(0.1),
      ),
    );
  }

  Widget _chartContainer(Widget child) {
    return SizedBox(
      height: 250,
      child: child,
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Det här är en initiell visualsering av din data. Vi kommer att fortsätta att utveckla och förbättra den. Om du har några frågor eller funderingar, tveka inte att kontakta oss. Du kan själv utforska din data genom "Hälsa" appen.',
        style: CupertinoTheme.of(context).textTheme.pickerTextStyle.copyWith(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
      ),
    );
  }
}
