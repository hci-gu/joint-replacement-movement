import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/screens/step_data/health_list_tile.dart';
import 'package:movement_code/screens/step_data/redo_permissions.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class StepDataQuestion extends HookConsumerWidget {
  final DateTime date;
  final Function(bool) onAnswer;

  const StepDataQuestion({
    super.key,
    required this.onAnswer,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> loading = useState(false);

    return ref
        .watch(healthDataProvider(DateTime(
          date.year - 1,
          date.month,
          date.day,
        )))
        .when(
          data: (data) => _body(ref, data, loading),
          error: _error,
          loading: _loading,
        );
  }

  Widget _error(_, __) {
    return const Text('Error');
  }

  Widget _loading() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _noDataMessage() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Du verkar inte ha någon stegdata, du kan fortsätta och fylla i dagboken kring smärta men alla funktioner kommer inte vara tillgängliga.',
      ),
    );
  }

  Widget _body(WidgetRef ref, HealthData data, ValueNotifier<bool> loading) {
    if (data.hasData) {
      return Scrollbar(
        child: ListView(
          shrinkWrap: true,
          children: [
            CupertinoListSection(
              header: const Text('Data från "Hälsa" appen'),
              children: [
                for (final type in data.types)
                  HealthListTile(items: data.itemsForType(type), type: type),
              ],
            ),
          ],
        ),
      );
    }

    if (!data.isAuthorized) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: CupertinoButton.filled(
            borderRadius: BorderRadius.circular(15.0),
            child: const Row(
              children: [
                Spacer(),
                Text(
                  'Ge tillgång',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
              ],
            ),
            onPressed: () async {
              loading.value = true;
              await ref
                  .read(healthDataProvider(DateTime(
                    date.year - 1,
                    date.month,
                    date.day,
                  )).notifier)
                  .authorize();
              onAnswer(true);
              loading.value = false;
            },
          ),
        ),
      );
    }

    if (data.isAuthorized && !data.hasData) {
      return _noDataMessage();
    }
    return const RedoPermissions();
  }
}
