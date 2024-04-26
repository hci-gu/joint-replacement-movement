import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdatePasswordForm extends HookConsumerWidget {
  const UpdatePasswordForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> canSubmit = useState(false);
    final passwordController = useTextEditingController(
      text: '',
    );
    final confirmPasswordController = useTextEditingController(
      text: '',
    );

    useEffect(() {
      listener() {
        canSubmit.value = passwordController.text.isNotEmpty &&
            confirmPasswordController.text.isNotEmpty &&
            passwordController.text == confirmPasswordController.text;
      }

      passwordController.addListener(listener);
      confirmPasswordController.addListener(listener);

      return () => {
            passwordController.removeListener(listener),
            confirmPasswordController.removeListener(listener),
          };
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uppdatera Lösenord',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: passwordController,
          placeholder: 'Nytt Lösenord',
          obscureText: true,
        ),
        const SizedBox(height: 16),
        CupertinoTextField(
          controller: confirmPasswordController,
          placeholder: 'Upprepa Lösenord',
          obscureText: true,
        ),
        const SizedBox(height: 16),
        Center(
          child: CupertinoButton.filled(
            onPressed: canSubmit.value
                ? () {
                    ref.read(authProvider.notifier).updatePassword(
                          passwordController.text,
                        );
                  }
                : null,
            child: const Text('Uppdatera'),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListView(
                shrinkWrap: true,
                children: const [
                  Text(
                    'Profil',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  Divider(),
                  SizedBox(height: 32),
                  UpdatePasswordForm(),
                  SizedBox(height: 32),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Divider(),
                  CupertinoButton(
                    child: const Text('Logga ut'),
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.goNamed('introduction');
                    },
                  ),
                  const SizedBox(height: 16),
                  _versionNumber(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _versionNumber() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline),
              const SizedBox(width: 8),
              Text(
                snapshot.data?.appName ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${snapshot.data?.version} (${snapshot.data?.buildNumber})',
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}
