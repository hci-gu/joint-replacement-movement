import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/screens/questionnaire/widgets/question.dart';
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
            Text(
              text,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
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

class QuestionnaireScreen extends HookConsumerWidget {
  final String id;

  const QuestionnaireScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(questionnaireProvider(id));
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
          questionnaire.answer(value);
          if (proceed) {
            await Future.delayed(answerDelay);
            controller.nextPage(
              duration: animationDuration,
              curve: animationCurve,
            );
          }
        },
        answer: questionnaire.answers[question.text],
        errorMessage: errorMessage.value,
      ));
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        questionnaire.lastIntroduction,
                        style: const TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PageView(
                      controller: controller,
                      scrollDirection: Axis.vertical,
                      physics: questionnaire.canGoForward
                          ? const AlwaysScrollableScrollPhysics()
                          : const ForwardBlockedScrollPhysics(),
                      onPageChanged: (value) {
                        errorMessage.value = null;
                        questionnaire.setPageIndex(value);
                      },
                      children: questionWidgets,
                    ),
                  ],
                ),
              ),
              Padding(
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
                        child: const Icon(Icons.keyboard_arrow_up),
                      ),
                      const SizedBox(width: 16),
                      CupertinoButton.filled(
                        padding: const EdgeInsets.all(12),
                        onPressed: () {
                          if (!questionnaire.canGoForward) {
                            errorMessage.value = 'Du måste svara på frågan';
                            return;
                          }
                          if (questionnaire.isLast) {
                            questionnaire.submit();
                            return;
                          }

                          controller.nextPage(
                            duration: animationDuration,
                            curve: animationCurve,
                          );
                        },
                        child: questionnaire.isLast
                            ? const Text('Skicka in')
                            : const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
