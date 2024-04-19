import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/average_steps.dart';
import 'package:movement_code/components/step_chart.dart';

class StepDataScreen extends ConsumerWidget {
  const StepDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          children: [
            Text(
              'Dn stegdata',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'Nedan ser du dina steg före och efter frakturen.',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .pickerTextStyle
                  .copyWith(fontSize: 16),
            ),
            _divider(),
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
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ref.watch(chartDataProvider).when(
                  data: (data) => StepDataChart(
                    data: data,
                    period: ref.watch(periodProvider),
                  ),
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
