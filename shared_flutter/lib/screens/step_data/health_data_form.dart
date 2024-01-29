import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/cupertino_date_text_box.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:personnummer/personnummer.dart';
import 'package:reactive_forms/reactive_forms.dart';

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

class PersonalIdValidator extends Validator<dynamic> {
  const PersonalIdValidator() : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    return Personnummer.valid(control.value) ? null : {'personalId': true};
  }
}

class HealthDataForm extends HookConsumerWidget {
  const HealthDataForm({super.key});

  buildForm() {
    return {
      'personalId': FormControl<String>(value: null, validators: [
        Validators.required,
        const PersonalIdValidator(),
      ]),
      'operationDate': FormControl<DateTime>(value: null, validators: [
        Validators.required,
      ]),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController =
        useTextEditingController(text: ref.watch(personalIdProvider));

    useEffect(() {
      void listener() {
        ref.read(personalIdProvider.notifier).state = textController.text;
      }

      textController.addListener(listener);
      return () => textController.removeListener(listener);
    }, [textController]);

    return ReactiveFormBuilder(
      form: buildForm(),
      builder: (context, form, _) {
        return CupertinoListSection(
          header: const Text(
              'Fyll i ditt personnummer och datumet då du opererades'),
          children: [
            CupertinoTextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(
                signed: true,
                decimal: false,
              ),
              inputFormatters: [
                PersonalIdFormatter(),
              ],
              prefix: _prefix('Personnr'),
              placeholder: 'YYYYMMDD-XXXX',
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            ),
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
      },
    );
  }

  Widget _prefix(String text) {
    return SizedBox(
      width: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Text(
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
