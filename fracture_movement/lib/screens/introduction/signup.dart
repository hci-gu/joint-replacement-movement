import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/password_input.dart';
import 'package:movement_code/components/personal_number_input.dart';

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isLoading = useState(false);
    final personalIdController = useTextEditingController(
      text: '',
    );
    final passwordController = useTextEditingController(
      text: '',
    );
    final confirmPasswordController = useTextEditingController(
      text: '',
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Skapa konto'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Image(
                  image: AssetImage('assets/icon.png'),
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Brytpunkten',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
              const Text(
                'Följ återhämtningen av din fotfraktur',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              PersonalNumberInput(controller: personalIdController),
              const SizedBox(height: 16),
              PasswordInput(
                controller: passwordController,
              ),
              const SizedBox(height: 16),
              PasswordInput(
                controller: confirmPasswordController,
                placeholder: 'Upprepa lösenord',
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        try {
                          await ref.read(authProvider.notifier).signup(
                                Credentials(
                                  personalIdController.text,
                                  passwordController.text,
                                ),
                              );
                        } catch (e) {}
                      },
                child: isLoading.value
                    ? const CupertinoActivityIndicator()
                    : const Text('Skapa konto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
