import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movement_code/components/personal_number_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const PersonalNumberInput(),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: const Text('Skapa konto'),
                onPressed: () => context.goNamed('home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
