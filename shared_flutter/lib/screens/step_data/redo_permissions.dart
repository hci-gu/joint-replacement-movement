import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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
