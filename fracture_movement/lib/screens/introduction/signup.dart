import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/password_input.dart';
import 'package:movement_code/components/personal_number_input.dart';

class ConsentModal extends HookWidget {
  const ConsentModal({super.key});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> consent = useState(false);

    return CupertinoAlertDialog(
      title: const Text('Ge ditt samtycke'),
      content: Column(
        children: [
          const Text(
            'Genom att fortsätta går du med på att din stegdata och dina svar i formulären används i forskningssyfte.',
          ),
          const SizedBox(height: 16),
          CupertinoListTile(
            leading: CupertinoSwitch(
              value: consent.value,
              onChanged: (value) {
                consent.value = value;
              },
            ),
            title: const Text(
              'Jag godkänner att delta i studien',
              maxLines: 2,
              style: TextStyle(fontSize: 15, color: CupertinoColors.label),
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Avbryt'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: consent.value
              ? () {
                  Navigator.of(context).pop(true);
                }
              : null,
          child: const Text('Fortsätt'),
        ),
      ],
    );
  }
}

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isLoading = useState(false);
    // ValueNotifier<bool> canSubmit = useState(false);
    final personalIdController = useTextEditingController(
      text: '',
    );
    final passwordController = useTextEditingController(
      text: '',
    );
    final confirmPasswordController = useTextEditingController(
      text: '',
    );

    // bool isPasswordValid = passwordController.text.isNotEmpty &&
    //     passwordController.text == confirmPasswordController.text;
    // bool canSubmit = personalIdController.text.isNotEmpty && isPasswordValid;
    print(personalIdController.text);

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
                        bool? consented = await _showAlertDialog(context);
                        if (consented == null || !consented) {
                          return;
                        }

                        try {
                          await ref.read(authProvider.notifier).signup(
                                Credentials(
                                  personalIdController.text,
                                  passwordController.text,
                                ),
                              );
                        } catch (_) {}
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

  Future<bool?> _showAlertDialog(BuildContext context) async {
    return showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) => const ConsentModal(),
    );
  }
}
