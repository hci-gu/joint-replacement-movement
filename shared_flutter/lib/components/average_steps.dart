import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/step_chart.dart';

class AverageSteps extends ConsumerWidget {
  const AverageSteps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle textStyle = CupertinoTheme.of(context)
        .textTheme
        .tabLabelTextStyle
        .copyWith(
            fontSize: 16,
            color: CupertinoColors.black,
            fontWeight: FontWeight.w300);

    return Container(
      decoration: BoxDecoration(
        // color: CupertinoColors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CupertinoColors.black.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ditt dagliga genomsnitt', style: textStyle),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _averageSteps(
                    context,
                    ref,
                    averageStepsBeforeProvider,
                    CupertinoColors.black,
                  ),
                  Text('Steg före', style: textStyle),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _averageSteps(
                    context,
                    ref,
                    averageStepsAfterProvider,
                    CupertinoColors.activeOrange,
                  ),
                  Text('Steg efter', style: textStyle),
                ],
              ),
              Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _averageSteps(BuildContext context, WidgetRef ref,
      FutureProvider<double> provider, Color color) {
    return ref.watch(provider).when(
          data: (steps) => _stepWidget(context, steps, color),
          error: (_, __) => const Center(child: Text('oh no')),
          loading: () => const SizedBox(
            height: 24,
            child: Center(
              child: Text('-'),
            ),
          ),
        );
  }

  Widget _stepWidget(BuildContext context, double steps, Color color) {
    return Text(
      steps.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} '),
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 32,
            color: color,
          ),
    );
  }
}
