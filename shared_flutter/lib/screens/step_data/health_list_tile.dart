import 'package:flutter/cupertino.dart';
import 'package:movement_code/state.dart';

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
