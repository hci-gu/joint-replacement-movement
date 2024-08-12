import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fracture_movement/screens/questionnaire/classes.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/screens/questionnaire/widgets/question.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movement_code/utils/single_direction_scroll.dart';

const animationCurve = Curves.easeInOut;
const answerDelay = Duration(milliseconds: 500);
const animationDuration = Duration(milliseconds: 300);

class QuestionsIntroduction extends StatelessWidget {
  final String text;
  final void Function() onOk;

  const QuestionsIntroduction({
    super.key,
    required this.text,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HtmlWidget(text),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              onPressed: onOk,
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionnaireSubmit extends StatelessWidget {
  final void Function() onSubmit;

  const QuestionnaireSubmit({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoButton.filled(
        onPressed: onSubmit,
        child: const Text('Skicka in'),
      ),
    );
  }
}

class SmallQuestionsIntroduction extends StatelessWidget {
  final String text;

  const SmallQuestionsIntroduction({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: CupertinoColors.systemGroupedBackground,
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          child: HtmlWidget(
            text,
            textStyle: const TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        BackgroundWithOpacityGradient(
          colors: [
            CupertinoColors.systemGroupedBackground,
            CupertinoColors.systemGroupedBackground.withOpacity(0),
          ],
        ),
      ],
    );
  }
}

class BackgroundWithOpacityGradient extends StatelessWidget {
  final List<Color> colors;

  const BackgroundWithOpacityGradient({super.key, this.colors = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }
}

class QuestionnaireWidget extends HookConsumerWidget {
  final Questionnaire questionnaire;
  final Function onAnswer;
  final Function onPageChange;
  final DateTime? date;

  const QuestionnaireWidget({
    super.key,
    required this.questionnaire,
    required this.onAnswer,
    required this.onPageChange,
    this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> showIntroduction =
        useState(questionnaire.description.isNotEmpty);
    ValueNotifier<String?> errorMessage = useState(null);
    final controller = usePageController();
    List<Widget> questionWidgets = [];

    for (var question in questionnaire.availableQuestions) {
      if (question.introduction != null) {
        questionWidgets.add(
          QuestionsIntroduction(
            text: question.introduction!,
            onOk: () {
              controller.nextPage(
                duration: animationDuration,
                curve: animationCurve,
              );
            },
          ),
        );
      }
      questionWidgets.add(QuestionWidget(
        question: question,
        onAnswer: (value, [bool proceed = true]) async {
          await onAnswer(question.id, value);
          if (proceed) {
            await Future.delayed(answerDelay);
            controller.nextPage(
              duration: animationDuration,
              curve: animationCurve,
            );
          }
        },
        answer: questionnaire.answers[question.id],
        errorMessage: errorMessage.value,
        valueFromQuestion: question.valueFromQuestion != null
            ? questionnaire.answers[question.valueFromQuestion]
            : null,
      ));
    }
    questionWidgets.add(QuestionnaireSubmit(
      onSubmit: () {
        ref.read(questionnaireProvider(questionnaire.id).notifier).submit(date);
        context.pop();
      },
    ));

    if (showIntroduction.value) {
      return _introduction(context, showIntroduction);
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(questionnaire.name),
        trailing: Text(questionnaire.progress),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: questionnaire.progressValue,
                color: CupertinoColors.activeBlue,
              ),
              Expanded(
                child: Stack(
                  children: [
                    PageView(
                      controller: controller,
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        errorMessage.value = null;
                        onPageChange(value);
                      },
                      children: questionWidgets,
                    ),
                    SmallQuestionsIntroduction(
                      text: questionnaire.lastIntroduction,
                    ),
                    if (questionnaire.pageIndex > 0 ||
                        !questionnaire.currentIsIntro)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            BackgroundWithOpacityGradient(
                              colors: [
                                CupertinoColors.systemGroupedBackground
                                    .withOpacity(0),
                                CupertinoColors.systemGroupedBackground,
                              ],
                            ),
                            Container(
                              color: CupertinoColors.systemGroupedBackground,
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CupertinoButton.filled(
                                      padding: const EdgeInsets.all(12),
                                      onPressed: questionnaire.pageIndex > 0
                                          ? () => controller.previousPage(
                                                duration: animationDuration,
                                                curve: animationCurve,
                                              )
                                          : null,
                                      child:
                                          const Icon(Icons.keyboard_arrow_up),
                                    ),
                                    const SizedBox(width: 16),
                                    CupertinoButton.filled(
                                      padding: const EdgeInsets.all(12),
                                      onPressed: questionnaire.currentIsSubmit
                                          ? null
                                          : () async {
                                              controller.nextPage(
                                                duration: animationDuration,
                                                curve: animationCurve,
                                              );
                                            },
                                      child:
                                          const Icon(Icons.keyboard_arrow_down),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _introduction(
      BuildContext context, ValueNotifier<bool> showIntroduction) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(questionnaire.name),
        trailing: Text(questionnaire.progress),
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HtmlWidget(questionnaire.description),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () {
                  showIntroduction.value = false;
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionnaireScreen extends HookConsumerWidget {
  final String id;
  final DateTime? date;

  const QuestionnaireScreen({
    super.key,
    required this.id,
    this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(questionnaireProvider(id)).when(
          data: (questionnaire) => QuestionnaireWidget(
            date: date,
            questionnaire: questionnaire,
            onAnswer: (name, answer) => ref
                .read(questionnaireProvider(id).notifier)
                .answer(name, answer),
            onPageChange: (value) {
              ref.read(questionnaireProvider(id).notifier).setPageIndex(value);
            },
          ),
          error: (_, __) => _page(),
          loading: () => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: () => Navigator.of(context).pop(),
              ),
              middle: const Text('-'),
            ),
            backgroundColor: CupertinoColors.systemGroupedBackground,
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
        );
  }

  Widget _page() {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Frågeformulär'),
      ),
      child: Center(child: Text('halt!')),
    );
  }
}
