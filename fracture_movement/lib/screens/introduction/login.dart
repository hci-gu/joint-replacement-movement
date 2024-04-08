import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/state/state.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/personal_number_input.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personalIdController = useTextEditingController(
      text: '',
    );
    final passwordController = useTextEditingController(
      text: '',
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Logga in'),
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
              CupertinoTextField(
                controller: passwordController,
                placeholder: 'Lösenord',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: const Text('Logga in'),
                onPressed: () async {
                  try {
                    await ref.read(authProvider.notifier).login(
                          Credentials(
                            personalIdController.text,
                            passwordController.text,
                          ),
                        );
                  } catch (e) {
                    // showCupertinoModalPopup(
                    //   context: context,
                    //   builder: (ctx) => Center(
                    //     child: Text('Hallå eller'),
                    //   ),
                    // );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
