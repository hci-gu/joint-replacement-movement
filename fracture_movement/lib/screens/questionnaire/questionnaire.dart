import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fracture_movement/screens/questionnaire/state.dart';
import 'package:fracture_movement/screens/questionnaire/widgets/question.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class QuestionnaireScreen extends HookConsumerWidget {
  final String id;

  const QuestionnaireScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaire = ref.watch(questionnaireProvider(id));
    final controller = usePageController();

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
                value: questionnaire.currentQuestion /
                    questionnaire.questions.length,
                color: CupertinoColors.activeBlue,
              ),
              Expanded(
                child: PageView(
                  controller: controller,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (value) {
                    questionnaire.setCurrentQuestion(value);
                  },
                  children: [
                    for (var question in questionnaire.availableQuestions)
                      QuestionWidget(
                        question: question,
                        onAnswer: (value, [bool proceed = true]) async {
                          questionnaire.answer(value);
                          if (proceed) {
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        answer: questionnaire.answers[question.text],
                      ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (questionnaire.currentQuestion > 0)
                          CupertinoButton.filled(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.arrow_back),
                            onPressed: () => controller.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            ),
                          ),
                        const SizedBox(width: 16),
                        CupertinoButton.filled(
                          child: questionnaire.isLast
                              ? const Text('Skicka in')
                              : const Text('Nästa'),
                          onPressed: () {
                            if (questionnaire.isLast) {
                              questionnaire.submit();
                              return;
                            }

                            controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.jumpToPage(0);
                        questionnaire.setCurrentQuestion(0);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Se alla frågor',
                          textAlign: TextAlign.center,
                        ),
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
}
