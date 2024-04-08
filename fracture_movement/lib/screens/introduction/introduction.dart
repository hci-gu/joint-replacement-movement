import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/personal_number_input.dart';

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
            ],
          ),
        ),
      ),
    );
  }
}
