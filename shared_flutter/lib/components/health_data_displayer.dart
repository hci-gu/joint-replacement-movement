import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_date_text_box.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:personnummer/personnummer.dart';

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
  final bool includeDate;

  const HealthDataForm({
    super.key,
    this.includeDate = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _focusNode = useFocusNode();
    final textController =
        useTextEditingController(text: ref.watch(personalIdProvider));
    ValueNotifier<String?> errorMessage = useState(null);

    useEffect(() {
      void listener() {
        ref.read(personalIdProvider.notifier).state = textController.text;
        if (Personnummer.valid(textController.text)) {
          errorMessage.value = null;
        }
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (textController.text.length < 13) {
          errorMessage.value = 'För kort';
        } else if (!Personnummer.valid(textController.text)) {
          errorMessage.value = 'Ogiltigt';
        } else {
          errorMessage.value = null;
        }
      }
    });

    return CupertinoListSection(
      header: Text(includeDate
          ? 'Fyll i ditt personnummer och datumet då du opererades'
          : 'Fyll i ditt personnummer'),
      children: [
        CupertinoTextField(
          controller: textController,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: false,
          ),
          inputFormatters: [
            PersonalIdFormatter(),
          ],
          prefix: _prefix('Personnr', errorMessage.value),
          placeholder: 'YYYYMMDD-XXXX',
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
        if (includeDate)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _prefix('Datum'),
              Expanded(
                child: CupertinoDateTextBox(
                  initialValue: ref.watch(operationDateProvider),
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

  Widget _prefix(String text, [String? error]) {
    return SizedBox(
      width: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: error != null
            ? Column(
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                  Text(
                    error,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
      ),
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
