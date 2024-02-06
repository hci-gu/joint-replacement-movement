import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 48.0,
          horizontal: 24,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Tack för din medverkan',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .copyWith(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Du har laddat upp dina steg och behöver inte göra något mer. Vi kommer att kontakta dig om vi behöver mer information.',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 32),
            Text(
              'Vad händer nu?',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .copyWith(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Vi kommer att analysera all data från appen och jobba vidare för att ta fram en nästa version.',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 32),
            Text(
              'Har du några frågor?',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navTitleTextStyle
                  .copyWith(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Om det är något du undrar över kan du också kontakta oss. Kontaktperson för projektet är Erik Börjesson som du kan nå via ',
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.black,
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(
                            Uri.parse('mailto:erik.borjesson@vgregion.se'));
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
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
