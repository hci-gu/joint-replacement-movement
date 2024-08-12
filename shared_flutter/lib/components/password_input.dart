import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movement_code/components/input_prefix.dart';

class PasswordInput extends HookWidget {
  final String placeholder;
  final TextEditingController controller;

  const PasswordInput({
    super.key,
    required this.controller,
    this.placeholder = 'Lösenord',
  });

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    ValueNotifier<String?> errorMessage = useState(null);

    useEffect(() {
      void listener() {
        if (controller.text.length >= 5) {
          errorMessage.value = null;
        }
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        if (controller.text.length < 5) {
          errorMessage.value =
              'Ditt lösenord behöver vara minst 5 tecken långt.';
        } else {
          errorMessage.value = null;
        }
      }
    });

    return Column(
      children: [
        CupertinoTextField(
          focusNode: focusNode,
          controller: controller,
          placeholder: placeholder,
          obscureText: true,
          prefix: InputPrefix(text: placeholder),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
        if (errorMessage.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorMessage.value!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }
}
