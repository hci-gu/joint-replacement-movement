import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/introduction/signup.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:fracture_movement/widgets/error_message.dart';
import 'package:fracture_movement/widgets/version_number.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/personal_number_input.dart';
import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

class IntroductionScreenHistory extends HookConsumerWidget {
  const IntroductionScreenHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isLoading = useState(false);
    final personalIdController = useTextEditingController(
      text: '',
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Tillbaka',
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
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
              const SizedBox(height: 32),
              PersonalNumberInput(controller: personalIdController),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: isLoading.value
                    ? null
                    : () async {
                        bool? consented = await showCupertinoModalPopup<bool>(
                          context: context,
                          builder: (BuildContext context) =>
                              const ConsentModal(),
                        );
                        if (consented == null || !consented) {
                          return;
                        }

                        isLoading.value = true;
                        try {
                          await Future.wait([
                            ref.read(authProvider.notifier).signup(
                                  Credentials(
                                    personalIdController.text,
                                    getRandomString(10),
                                  ),
                                ),
                            Future.delayed(const Duration(seconds: 1))
                          ]);
                        } catch (e) {
                          if (!context.mounted) return;
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => ErrorMessage(
                              e: e,
                              title: 'Fel vid inloggning',
                              description:
                                  'Kunde inte logga in, kontrollera att personnummer och lösenord är korrekt',
                            ),
                          );
                        }
                        if (context.mounted) {
                          isLoading.value = false;
                        }
                      },
                child: isLoading.value
                    ? const CupertinoActivityIndicator()
                    : const Text('Logga in'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroductionScreenPuff extends StatelessWidget {
  const IntroductionScreenPuff({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Tillbaka',
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
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
              CupertinoButton.filled(
                child: const Text('Skapa konto'),
                onPressed: () => context.goNamed('signup'),
              ),
              const SizedBox(height: 16),
              const Text(
                '- Eller - ',
                style: TextStyle(
                  color: CupertinoColors.inactiveGray,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: const Text('Logga in'),
                onPressed: () => context.goNamed('login'),
              ),
              const Spacer(),
              const VersionNumber(),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroductionScreen extends ConsumerWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: const Image(
                  image: AssetImage('assets/icon.png'),
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Brytpunkten',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              const Text(
                'När skadade du dig?',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: const Text(
                  'Nyligen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  ref.read(appChoiceProvider.notifier).state = AppChoice.puff;
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const IntroductionScreenPuff(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Det här valet gäller dig som nyligen skadat dig och ska följa din återhämtning.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              const Text(
                '- Eller - ',
                style: TextStyle(
                  fontSize: 20,
                  color: CupertinoColors.inactiveGray,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: const Text(
                  'Ett tag sedan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  ref.read(appChoiceProvider.notifier).state =
                      AppChoice.history;
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => const IntroductionScreenHistory(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              const Text(
                'Det här valet gäller dig som skadat dig för mer än 1 år sedan och ska dela mig dig av historisk stegdata.',
                style: TextStyle(fontSize: 15),
              ),
              const Spacer(),
              const VersionNumber(),
            ],
          ),
        ),
      ),
    );
  }
}
