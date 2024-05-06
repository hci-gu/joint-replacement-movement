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

    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: true,
      prefix: InputPrefix(text: placeholder, error: errorMessage.value),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
    );
  }
}
