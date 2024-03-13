import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/input_prefix.dart';
import 'package:movement_code/state.dart';
import 'package:personnummer/personnummer.dart';

class PersonalNumberFormatter extends TextInputFormatter {
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

class PersonalNumberInput extends HookConsumerWidget {
  const PersonalNumberInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
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

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (textController.text.length < 13) {
          errorMessage.value = 'För kort';
        } else if (!Personnummer.valid(textController.text)) {
          errorMessage.value = 'Ogiltigt';
        } else {
          errorMessage.value = null;
        }
      }
    });

    return CupertinoTextField(
      controller: textController,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: false,
      ),
      inputFormatters: [
        PersonalNumberFormatter(),
      ],
      prefix: InputPrefix(text: 'Personnr', error: errorMessage.value),
      placeholder: 'YYYYMMDD-XXXX',
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
    );
  }
}
