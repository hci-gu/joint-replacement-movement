import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/already_done_wrapper.dart';
import 'package:movement_code/components/health_data_displayer.dart';
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
      return ListView(
        children: [
          CupertinoListSection(
            header: const Text('Data från Apple Health'),
            children: [
              for (final type in data.types)
                HealthListTile(
                  items: data.itemsForType(type),
                  type: type,
                ),
            ],
          ),
          HealthDataForm(
            includeDate: includeDate,
          ),
        ],
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

class HealthListTile extends StatelessWidget {
  final List<HealthDataPoint> items;
  final HealthDataType type;

  const HealthListTile({
    super.key,
    required this.items,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      leading: icon,
      title: Text(displayType),
      subtitle: Text(displayPeriod),
    );
  }

  DateTime get firstDate => items.last.dateFrom;
  DateTime get lastDate => items.first.dateFrom;

  String get displayPeriod =>
      '${firstDate.toIso8601String().substring(0, 10)} - ${lastDate.toIso8601String().substring(0, 10)}';

  String get displayType {
    switch (type) {
      case HealthDataType.STEPS:
        return 'Steg';
      case HealthDataType.WALKING_SPEED:
        return 'Gånghastighet';
      case HealthDataType.WALKING_STEP_LENGTH:
        return 'Steglängd';
      case HealthDataType.WALKING_STEADINESS:
        return 'Stabilitet vid gång';
      case HealthDataType.WALKING_ASYMMETRY_PERCENTAGE:
        return 'Asymmetrisk gång';
      case HealthDataType.WALKING_DOUBLE_SUPPORT_PERCENTAGE:
        return 'Tid med båda fötterna på marken';
      default:
        return '';
    }
  }

  Widget get icon {
    if (type == HealthDataType.STEPS) {
      return const Icon(
        CupertinoIcons.flame_fill,
        color: CupertinoColors.destructiveRed,
      );
    }
    return const Icon(
      CupertinoIcons.arrow_left_right,
      color: CupertinoColors.activeOrange,
    );
  }
}
