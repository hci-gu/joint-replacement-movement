import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/already_done_wrapper.dart';
import 'package:movement_code/screens/step_data/health_data_form.dart';
import 'package:movement_code/screens/step_data/health_list_tile.dart';
import 'package:movement_code/screens/step_data/redo_permissions.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movement_code/storage.dart';

class StepDataScreen extends HookConsumerWidget {
  final bool includeDate;

  const StepDataScreen({
    super.key,
    this.includeDate = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> loading = useState(false);

    return AlreadyDoneWrapper(
      alreadyDone: Storage().getPersonalIdDone(),
      child: loading.value
          ? _loading()
          : ref.watch(healthDataProvider).when(
                data: (data) => _body(ref, data, loading),
                error: _error,
                loading: _loading,
              ),
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

  Widget _body(WidgetRef ref, HealthData data, ValueNotifier<bool> loading) {
    if (data.hasData) {
      return Scrollbar(
        child: ListView(
          children: [
            CupertinoListSection(
              header: const Text('Data från "Hälsa" appen'),
              children: [
                for (final type in data.types)
                  HealthListTile(items: data.itemsForType(type), type: type),
              ],
            ),
            HealthDataForm(includeDate: includeDate),
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
              await ref.read(healthDataProvider.notifier).authorize();
              loading.value = false;
            },
          ),
        ),
      );
    }
    return const RedoPermissions();
  }
}
