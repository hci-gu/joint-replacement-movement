import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/password_input.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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
        PasswordInput(
          controller: passwordController,
          placeholder: 'Nytt Lösenord',
        ),
        const SizedBox(height: 16),
        PasswordInput(
          controller: confirmPasswordController,
          placeholder: 'Upprepa Lösenord',
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

class EnableNotifications extends ConsumerWidget {
  const EnableNotifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authProvider);
    return FutureBuilder(
      future: ref.watch(authProvider.notifier).notificationsEnabled(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notifikationer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoSwitch(
              value: snapshot.data == true,
              onChanged: (value) async {
                await ref
                    .read(authProvider.notifier)
                    .toggleNotifications(value);
              },
            )
          ],
        );
      },
    );
  }
}

class ContactInfo extends StatelessWidget {
  const ContactInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text:
                'Om det är något du undrar över kan du kontakta oss. Kontaktperson för projektet är Erik Börjesson som du kan nå via ',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse('mailto:erik.borjesson@vgregion.se'));
              },
              child: const Text(
                'erik.borjesson@vgregion.se',
                style: TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.activeBlue,
                ),
              ),
            ),
          ),
          const TextSpan(
            text: '. ',
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 100),
          shrinkWrap: true,
          children: [
            const Text(
              'Profil',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            const SizedBox(height: 32),
            const UpdatePasswordForm(),
            const SizedBox(height: 32),
            const EnableNotifications(),
            const Divider(),
            const SizedBox(height: 16),
            _aboutTheStudy(context),
            const SizedBox(height: 16),
            const Divider(),
            CupertinoButton(
              child: const Text('Logga ut'),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.goNamed('introduction');
              },
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              child: const Text(
                'Radera konto',
                style: TextStyle(
                  color: CupertinoColors.destructiveRed,
                ),
              ),
              onPressed: () async {
                if (await _showDeleteDialog(context) ?? false) {
                  ref.read(authProvider.notifier).deleteAccount();
                  if (context.mounted) {
                    context.goNamed('introduction');
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _versionNumber(),
          ],
        ),
      ),
    );
  }

  Widget _aboutTheStudy(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Om Studien',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        Text(
          'Du som givit ditt samtycke till att delta i detta forskningsprojekt är mycket viktig för oss. I just detta projekt är ditt bidrag helt avgörande då nästan all den data vi ska analysera framöver är sådant som du kommer att rapportera till oss om hur du mår och hur du ser på olika delar i den behandling du får.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        Text(
          'Studien är en del av ett forskningsprojekt vid Sahlgrenska Universitetssjukhuset och Göteborgs Universitet.',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        ContactInfo(),
      ],
    );
  }

  Future _showDeleteDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Radera konto'),
          content: const Text('Är du säker på att du vill radera ditt konto?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Avbryt'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Radera'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
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
