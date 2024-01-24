import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_date_text_box.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HealthDataDisplayer extends HookConsumerWidget {
  const HealthDataDisplayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> loading = useState(false);

    return loading.value
        ? _loading()
        : ref.watch(healthDataProvider).when(
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

  Widget _body(WidgetRef ref, HealthData data, ValueNotifier<bool> loading) {
    if (data.authorizationFailed) {
      return const RedoPermissions();
    }

    if (!data.isAuthorized) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      );
    }

    return Column(
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
        const HealthDataForm(),
      ],
    );
  }
}

class PersonalIdFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll('-', '');

    // remove all non-digits
    newText = newText.replaceAll(RegExp(r'\D'), '');

    if (newText.length > 8) {
      newText = '${newText.substring(0, 8)}-${newText.substring(8)}';
    }
    if (newText.length > 13) {
      newText = newText.substring(0, 13);
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class HealthDataForm extends HookConsumerWidget {
  const HealthDataForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController(text: '');

    useEffect(() {
      void listener() {
        ref.read(personalIdProvider.notifier).state = textController.text;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    return CupertinoListSection(
      header:
          const Text('Fyll i ditt personnummer och datumet då du opererades'),
      children: [
        CupertinoTextField(
          controller: textController,
          inputFormatters: [
            PersonalIdFormatter(),
          ],
          prefix: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              'Personnr',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
          placeholder: 'YYYYMMDD-XXXX',
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Datum',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
            Expanded(
              child: CupertinoDateTextBox(
                initialValue: null,
                onDateChange: (value) {
                  ref.read(operationDateProvider.notifier).state = value;
                },
                hintText: 'Tryck för att välja datum',
              ),
            )
          ],
        ),
      ],
    );
  }
}

class RedoPermissions extends HookConsumerWidget {
  const RedoPermissions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        ref.read(healthDataProvider.notifier).authorize();
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.exclamationmark_octagon_fill,
                color: CupertinoColors.destructiveRed,
              ),
              SizedBox(width: 8.0),
              Text(
                'Du har nekat tillgång via Apple Health.',
                maxLines: 2,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Gå till inställingar, välj Hälsa -> Data -> HurGårDet? -> Slå på alla',
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8.0),
          CupertinoButton.filled(
            borderRadius: BorderRadius.circular(15.0),
            child: const Row(
              children: [
                Spacer(),
                Text(
                  'Öppna inställningar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Spacer(),
              ],
            ),
            onPressed: () {
              AppSettings.openAppSettings();
            },
          ),
        ],
      ),
    );
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
