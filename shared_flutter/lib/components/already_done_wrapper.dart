import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AlreadyDoneWrapper extends StatelessWidget {
  final Widget child;
  final bool alreadyDone;

  const AlreadyDoneWrapper({
    super.key,
    required this.child,
    required this.alreadyDone,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        alreadyDone
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: child,
              )
            : child,
        if (alreadyDone)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Text(
                'Du har redan gjort det här steget',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
