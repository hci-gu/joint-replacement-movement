import 'package:flutter/cupertino.dart';

class InputPrefix extends StatelessWidget {
  final String text;
  final String? error;

  const InputPrefix({super.key, required this.text, this.error});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: error != null
            ? Column(
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                  Text(
                    error ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
      ),
    );
  }
}
