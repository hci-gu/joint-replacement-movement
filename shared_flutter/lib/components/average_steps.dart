import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/step_chart.dart';

class AverageSteps extends ConsumerWidget {
  const AverageSteps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          'Ditt dagliga genomsnitt',
          style: CupertinoTheme.of(context)
              .textTheme
              .tabLabelTextStyle
              .copyWith(fontSize: 16),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                _averageSteps(context, ref, averageStepsBeforeProvider,
                    CupertinoColors.darkBackgroundGray),
                Text(
                  'Steg före',
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .tabLabelTextStyle
                      .copyWith(fontSize: 16),
                ),
              ],
            ),
            Column(
              children: [
                _averageSteps(context, ref, averageStepsAfterProvider,
                    CupertinoColors.activeOrange),
                Text(
                  'Steg efter',
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .tabLabelTextStyle
                      .copyWith(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _averageSteps(BuildContext context, WidgetRef ref,
      FutureProvider<double> provider, Color color) {
    return ref.watch(provider).when(
          data: (steps) => _stepWidget(context, steps, color),
          error: (_, __) => const Center(child: Text('oh no')),
          loading: () => const Center(
            child: CupertinoActivityIndicator(),
          ),
        );
  }

  Widget _stepWidget(BuildContext context, double steps, Color color) {
    return Text(
      steps.toStringAsFixed(0),
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
            fontSize: 32,
            color: color,
          ),
    );
  }
}
