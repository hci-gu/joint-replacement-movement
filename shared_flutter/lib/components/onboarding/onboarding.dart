// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movement_code/components/onboarding/dots_indicator.dart';
import 'package:movement_code/utils/single_direction_scroll.dart';

bool isSmallScreen(BuildContext context) {
  return MediaQuery.of(context).size.height < 670;
}

class CupertinoOnboarding extends HookWidget {
  CupertinoOnboarding({
    required this.pages,
    this.backgroundColor,
    this.bottomButtonChild = const Text('Continue'),
    this.widgetAboveBottomButton,
    this.pageTransitionAnimationDuration = const Duration(milliseconds: 500),
    this.pageTransitionAnimationCurve = Curves.fastEaseInToSlowEaseOut,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.onPressed,
    this.onPressedOnLastPage,
    this.onPageChange,
    this.beforePageChange = _defaultFunction,
    this.nextPageDisabled = false,
    this.nextPageScrollDisabled = false,
    this.widgetAboveTitle,
    super.key,
  }) : assert(
          pages.isNotEmpty,
          'Number of pages must be greater than 0',
        );
  static _defaultFunction() async {}

  final List<Widget> pages;
  final Color? backgroundColor;
  final Widget bottomButtonChild;
  final Widget? widgetAboveBottomButton;
  final Duration pageTransitionAnimationDuration;
  final Curve pageTransitionAnimationCurve;
  final ScrollPhysics scrollPhysics;
  final VoidCallback? onPressed;
  final VoidCallback? onPressedOnLastPage;
  final Function? onPageChange;
  final Function beforePageChange;
  final bool nextPageDisabled;
  final bool nextPageScrollDisabled;
  final Widget? widgetAboveTitle;

  @override
  Widget build(BuildContext context) {
    final currentPage = useState(0);
    final pageController = usePageController();

    useEffect(() {
      void listener() {
        currentPage.value = pageController.page!.toInt();
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, []);

    return SizedBox(
      height: MediaQuery.of(context).size.height -
          (isSmallScreen(context) ? 44 : 100),
      child: Column(
        children: [
          if (widgetAboveTitle != null) widgetAboveTitle!,
          Expanded(
            child: PageView(
              physics: nextPageDisabled
                  ? const LeftBlockedScrollPhysics()
                  : scrollPhysics,
              controller: pageController,
              children: pages,
              onPageChanged: (page) {
                currentPage.value = page;
                onPageChange?.call(page);
              },
            ),
          ),
          if (pages.length > 1)
            DotsIndicator(dotsCount: pages.length, position: currentPage.value),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(15),
              color: CupertinoTheme.of(context).primaryColor,
              padding: const EdgeInsets.all(16),
              onPressed: nextPageDisabled
                  ? null
                  : () async {
                      await beforePageChange();
                      if (currentPage.value == pages.length - 1) {
                        onPressedOnLastPage?.call();
                        return;
                      }
                      pageController.nextPage(
                        duration: pageTransitionAnimationDuration,
                        curve: pageTransitionAnimationCurve,
                      );
                      onPressed?.call();
                    },
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    bottomButtonChild,
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CupertinoOnboardingPage extends StatelessWidget {
  const CupertinoOnboardingPage({
    required this.title,
    required this.body,
    this.description,
    this.bodyPadding = const EdgeInsets.only(left: 20, right: 15),
    this.descriptionPadding = const EdgeInsets.only(bottom: 0, top: 16),
    this.bodyToBottomSpacing = 0,
    this.titleFlex = 3,
    super.key,
  });

  final Widget title;
  final Widget? description;
  final Widget body;
  final EdgeInsets bodyPadding;
  final EdgeInsets descriptionPadding;
  final double bodyToBottomSpacing;
  final int titleFlex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height / 36,
          ),
          child: DefaultTextStyle(
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              fontSize: 35,
            ),
            child: title,
          ),
        ),
        if (description != null)
          Padding(
            padding: descriptionPadding,
            child: DefaultTextStyle(
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontSize: 15,
                height: 1.3,
                letterSpacing: -0.1,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 6,
                    child: description!,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        Expanded(
          flex: 10,
          child: DefaultTextStyle(
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
            ),
            child: Padding(
              padding: bodyPadding,
              child: body,
            ),
          ),
        ),
        SizedBox(height: bodyToBottomSpacing),
      ],
    );
  }
}

class OnboardingFeaturesPage extends StatelessWidget {
  OnboardingFeaturesPage({
    required this.features,
    this.featuresSeperator = const SizedBox(height: 25),
    this.title = const Text("What's New"),
    this.description,
    this.bodyPadding = const EdgeInsets.only(left: 20, right: 15),
    this.bodyToBottomSpacing = 0,
    this.titleFlex = 3,
    this.scrollPhysics = const BouncingScrollPhysics(),
    super.key,
  }) : assert(
          features.isNotEmpty,
          'Feature list must contain at least 1 widget.',
        );

  final List<Widget> features;
  final Widget featuresSeperator;
  final Widget title;
  final Widget? description;
  final EdgeInsets bodyPadding;
  final double bodyToBottomSpacing;
  final int titleFlex;
  final ScrollPhysics scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return CupertinoOnboardingPage(
      title: title,
      description: description,
      bodyPadding: bodyPadding,
      bodyToBottomSpacing: bodyToBottomSpacing,
      descriptionPadding: const EdgeInsets.only(bottom: 24, top: 16),
      titleFlex: titleFlex,
      body: ListView(
        children: [
          for (var feature in features)
            Column(
              children: [
                feature,
                featuresSeperator,
              ],
            )
        ],
      ),
    );
  }
}
