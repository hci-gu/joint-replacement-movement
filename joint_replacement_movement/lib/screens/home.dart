import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/components/average_steps.dart';
import 'package:movement_code/components/step_chart.dart';
import 'package:movement_code/screens/forms/app_form.dart';
import 'package:movement_code/storage.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart';

class DataTab extends ConsumerWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        children: [
          Text(
            'Tack för din medverkan',
            style: CupertinoTheme.of(context)
                .textTheme
                .navTitleTextStyle
                .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            'Nedan ser du dina steg före och efter operationen.',
            style: CupertinoTheme.of(context)
                .textTheme
                .pickerTextStyle
                .copyWith(fontSize: 16),
          ),
          _divider(),
          CupertinoSegmentedControl<Period>(
            children: {
              Period.week: _segmentItem('Vecka'),
              Period.month: _segmentItem('Månad'),
              Period.quarter: _segmentItem('Kvartal'),
            },
            onValueChanged: (value) {
              ref.read(periodProvider.notifier).state = value;
            },
            groupValue: ref.watch(periodProvider),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          ref.watch(chartDataProvider).when(
                data: (data) => StepDataChart(
                  data: data,
                  period: ref.watch(periodProvider),
                ),
                error: (_, __) =>
                    _chartContainer(const Center(child: Text('-'))),
                loading: () => _chartContainer(
                  const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
              ),
          _divider(),
          const AverageSteps(),
          const SizedBox(height: 16),
          _disclaimerText(context),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        height: 1,
        color: CupertinoColors.black.withOpacity(0.1),
      ),
    );
  }

  Widget _chartContainer(Widget child) {
    return SizedBox(
      height: 250,
      child: child,
    );
  }

  Widget _segmentItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(title),
    );
  }

  Widget _disclaimerText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Det här är en initiell visualsering av din data. Vi kommer att fortsätta att utveckla och förbättra den. Om du har några frågor eller funderingar, tveka inte att kontakta oss. Du kan själv utforska din data genom "Hälsa" appen.',
        style: CupertinoTheme.of(context).textTheme.pickerTextStyle.copyWith(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
      ),
    );
  }
}

class QuestionnaireTab extends StatelessWidget {
  const QuestionnaireTab({super.key});

  @override
  Widget build(BuildContext context) {
    bool questionnaireDone = Storage().getQuestionnaireDone('questionnaire2');

    if (questionnaireDone) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.check_mark_circled,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Tack för att du har fyllt i formuläret',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.black,
            ),
          ),
        ],
      );
    }

    return const AppFormScreen();
  }
}

class ContactTab extends StatelessWidget {
  const ContactTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Om forskningsprojektet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Artros är den vanligaste ledsjukdomen i världen. Majoriteten av dem som har genomgått protesoperation rapporterar minskad smärta, bättre rörlighet och återuppnår bättre livskvalitet, men det är inte helt klarlagd hur och i vilken utsträckning aktivitet och rörelsemönster ändras efter ledprotesoperation. Digitala verktyg som smarta telefoner och klockor ger oss nya förutsättningar att få en rättvisande bild av människors fysiska aktivitet under längre tid än vad som är möjligt med andra metoder såsom självskattning eller gånganalys i laboratorium. Med denna utgångspunkt kommer vi att utveckla en applikation för iPhone som registrerar rörelsedata före och efter en ledprotesoperation i höft och knä.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 15,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kontaktpersoner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Ansvariga för projektet är Ola Rolfson (huvudansvarig forskare), ',
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.black,
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('mailto:ola.rolfson@vgregion.se'));
                      },
                      child: const Text(
                        'ola.rolfson@vgregion.se',
                        style: TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text:
                        ', verksamhet ortopedi, Sahlgrenska Universitetssjukhuset, 43180, Mölndal, samt Aurora Tasa (doktorandstudent), ',
                    style: TextStyle(
                      fontSize: 15,
                      color: CupertinoColors.black,
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse('mailto:aurora.tasa@vgregion.se'));
                      },
                      child: const Text(
                        'aurora.tasa@vgregion.se',
                        style: TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: ', Göteborgs Universitet, Göteborg.',
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, keyboardVisible) {
        return CupertinoTabScaffold(
          tabBar: keyboardVisible
              ? InvisibleCupertinoTabBar()
              : CupertinoTabBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.graph_square),
                      label: 'Din data',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.doc_person),
                      label: 'Frågeformulär 2',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.mail),
                      label: 'Kontakta oss',
                    ),
                  ],
                ),
          resizeToAvoidBottomInset: false,
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return const DataTab();
              case 1:
                return const QuestionnaireTab();
              default:
                return const ContactTab();
            }
          },
        );
      },
    );
  }
}

class InvisibleCupertinoTabBar extends CupertinoTabBar {
  static const dummyIcon = Icon(IconData(0x0020));

  const InvisibleCupertinoTabBar({super.key})
      : super(
          height: 0,
          items: const [
            BottomNavigationBarItem(icon: dummyIcon),
            BottomNavigationBarItem(icon: dummyIcon),
          ],
        );

  @override
  Size get preferredSize => const Size.square(0);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
