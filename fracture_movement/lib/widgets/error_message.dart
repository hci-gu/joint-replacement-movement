import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorMessage extends HookWidget {
  final Object e;
  final String title;
  final String description;

  const ErrorMessage(
      {super.key, required this.e, this.title = 'Fel', this.description = ''});

  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> showFullError = useState(false);

    return CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        children: [
          Text(description),
          if (showFullError.value) const Divider(),
          if (showFullError.value) Text(e.toString()),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CupertinoDialogAction(
          child: Text(showFullError.value ? 'Dölj' : 'Visa mer'),
          onPressed: () => showFullError.value = !showFullError.value,
        ),
        if (showFullError.value)
          CupertinoDialogAction(
            child: const Text('Skicka felrapport'),
            onPressed: () => _sendErrorReport(),
          ),
      ],
    );
  }

  _sendErrorReport() {
    final mailtoLink = Mailto(
      to: ['sebastian.andreasson@ait.gu.se'],
      subject: 'Brytpunkten felrapport',
      body: e.toString(),
    );
    launchUrl(Uri.parse('$mailtoLink'));
  }
}
