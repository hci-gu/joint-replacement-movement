// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movement_code/components/dots_indicator.dart';
import 'package:movement_code/utils/single_direction_scroll.dart';

const CupertinoDynamicColor kBaseTextColor = CupertinoColors.label;
const CupertinoDynamicColor kDescriptionTextColor =
    CupertinoColors.secondaryLabel;
const EdgeInsets _kOnboardingPagePadding = EdgeInsets.only(left: 20, right: 15);
const double _kTitleTopIndent = 80;
const double _kTitleToBodySpacing = 16;

// Estimated from the iPhone Simulator running iOS 15
final CupertinoDynamicColor _kBackgroundColor =
    CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.white,
  darkColor: CupertinoColors.systemGrey6.darkColor,
);

final CupertinoDynamicColor _kActiveDotColor =
    CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.systemGrey2.darkColor,
  darkColor: CupertinoColors.systemGrey2.color,
);
final CupertinoDynamicColor _kInactiveDotColor =
    CupertinoDynamicColor.withBrightness(
  color: CupertinoColors.systemGrey2.color,
  darkColor: CupertinoColors.systemGrey2.darkColor,
);

const Size _kDotSize = Size(8, 8);

final BorderRadius _bottomButtonBorderRadius = BorderRadius.circular(15);
const EdgeInsets _kBottomButtonPadding = EdgeInsets.only(
  left: 22,
  right: 22,
  bottom: 0,
);

class CupertinoOnboarding extends StatefulWidget {
  CupertinoOnboarding({
    required this.pages,
    this.backgroundColor,
    this.bottomButtonChild = const Text('Continue'),
    this.bottomButtonColor,
    this.bottomButtonBorderRadius,
    this.bottomButtonPadding = _kBottomButtonPadding,
    this.widgetAboveBottomButton,
    this.pageTransitionAnimationDuration = const Duration(milliseconds: 500),
    this.pageTransitionAnimationCurve = Curves.fastEaseInToSlowEaseOut,
    this.scrollPhysics = const BouncingScrollPhysics(),
    this.onPressed,
    this.onPressedOnLastPage,
    this.onPageChange,
    this.nextPageDisabled = false,
    this.widgetAboveTitle,
    super.key,
  }) : assert(
          pages.isNotEmpty,
          'Number of pages must be greater than 0',
        );

  final List<Widget> pages;
  final Color? backgroundColor;
  final Widget bottomButtonChild;
  final Color? bottomButtonColor;
  final BorderRadius? bottomButtonBorderRadius;
  final EdgeInsets bottomButtonPadding;
  final Widget? widgetAboveBottomButton;
  final Duration pageTransitionAnimationDuration;
  final Curve pageTransitionAnimationCurve;
  final ScrollPhysics scrollPhysics;
  final VoidCallback? onPressed;
  final VoidCallback? onPressedOnLastPage;
  final Function? onPageChange;
  final bool nextPageDisabled;
  final Widget? widgetAboveTitle;

  @override
  State<CupertinoOnboarding> createState() => _CupertinoOnboardingState();
}

class _CupertinoOnboardingState extends State<CupertinoOnboarding> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          if (widget.widgetAboveTitle != null) widget.widgetAboveTitle!,
          Expanded(
            child: PageView(
              physics: widget.nextPageDisabled
                  ? const LeftBlockedScrollPhysics()
                  : widget.scrollPhysics,
              controller: _pageController,
              children: widget.pages,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                  widget.onPageChange?.call(_currentPage);
                });
              },
            ),
          ),
          if (widget.pages.length > 1)
            DotsIndicator(
              dotsCount: widget.pages.length,
              position: _currentPage,
              decorator: DotsDecorator(
                activeColor: _kActiveDotColor.resolveFrom(context),
                color: _kInactiveDotColor.resolveFrom(context),
                activeSize: _kDotSize,
                size: _kDotSize,
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoButton(
              borderRadius:
                  widget.bottomButtonBorderRadius ?? _bottomButtonBorderRadius,
              color: widget.bottomButtonColor ??
                  CupertinoTheme.of(context).primaryColor,
              padding: const EdgeInsets.all(16),
              onPressed: widget.nextPageDisabled
                  ? null
                  : _currentPage == widget.pages.length - 1
                      ? widget.onPressedOnLastPage
                      : _animateToNextPage,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    widget.bottomButtonChild,
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

  Future<void> _animateToNextPage() async {
    await _pageController.nextPage(
      duration: widget.pageTransitionAnimationDuration,
      curve: widget.pageTransitionAnimationCurve,
    );
    widget.onPressed?.call();
  }
}

/// Represents a swipeable page in the onboarding.
class CupertinoOnboardingPage extends StatelessWidget {
  /// Default constructor of the [CupertinoOnboardingPage] widget.
  const CupertinoOnboardingPage({
    required this.title,
    required this.body,
    this.description,
    this.bodyPadding = _kOnboardingPagePadding,
    this.titleTopIndent = _kTitleTopIndent,
    this.titleToBodySpacing = _kTitleToBodySpacing,
    this.bodyToBottomSpacing = 0,
    this.titleFlex = 3,
    super.key,
  });

  /// Title of the onboarding.
  ///
  /// It is recommended to keep it short.
  ///
  /// Defaults to Text("What's New").
  /// If another Text widget is provided, it will be
  /// defaultly styled to match the iOS 15 style onboarding.
  final Widget title;
  final Widget? description;

  /// Body of the onboarding.
  final Widget body;

  /// Padding of the body.
  final EdgeInsets bodyPadding;

  /// Top indent of the title.
  ///
  /// Defaults to 80.
  final double titleTopIndent;

  /// Spacing between the title and the body.
  ///
  /// Defaults to 55.
  final double titleToBodySpacing;

  /// Spacing between the body and the bottom buttons/page indicator.
  ///
  /// Defaults to 0.
  final double bodyToBottomSpacing;

  /// Flex value of the title.
  ///
  /// Determines how much horizontal space the title takes.
  ///
  /// Defaults to 3.
  final int titleFlex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: titleTopIndent,
            bottom: titleToBodySpacing,
          ),
          child: DefaultTextStyle(
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kBaseTextColor.resolveFrom(context),
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              fontSize: 35,
            ),
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: 3,
                  child: title,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: DefaultTextStyle(
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: kDescriptionTextColor.resolveFrom(context),
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
              color: kBaseTextColor.resolveFrom(context),
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

/// Represents an "What's new" screen in iOS 15 style.
///
/// It is possible to restyle this widget to match older iOS versions.
class OnboardingFeaturesPage extends StatelessWidget {
  /// Default constructor of the [WhatsNewPage] widget.
  ///
  /// Represents an "What's new" screen in iOS 15 style.
  /// It is possible to restyle this widget to match older iOS versions.
  OnboardingFeaturesPage({
    required this.features,
    this.featuresSeperator = const SizedBox(height: 25),
    this.title = const Text("What's New"),
    this.description,
    this.bodyPadding = _kOnboardingPagePadding,
    this.titleTopIndent = _kTitleTopIndent,
    this.titleToBodySpacing = _kTitleToBodySpacing,
    this.bodyToBottomSpacing = 0,
    this.titleFlex = 3,
    this.scrollPhysics = const BouncingScrollPhysics(),
    super.key,
  }) : assert(
          features.isNotEmpty,
          'Feature list must contain at least 1 widget.',
        );

  /// List of widgets that will be displayed
  /// under the title.
  ///
  /// Preferably, list of [WhatsNewFeature] widgets.
  final List<Widget> features;

  /// Widget that will be displayed between the features.
  ///
  /// Defaults to [SizedBox(height: 25)].
  final Widget featuresSeperator;

  /// Title of the onboarding.
  ///
  /// It is recommended to keep it short.
  ///
  /// Defaults to Text("What's New").
  /// If another Text widget is provided, it will be
  /// defaultly styled to match the iOS style.
  final Widget title;
  final Widget? description;

  /// Padding of the body.
  final EdgeInsets bodyPadding;

  /// Top indent of the title.
  ///
  /// Defaults to 80.
  final double titleTopIndent;

  /// Spacing between the title and the body.
  ///
  /// Defaults to 55.
  final double titleToBodySpacing;

  /// Spacing between the body and the bottom buttons/page indicator.
  ///
  /// Defaults to 0.
  final double bodyToBottomSpacing;

  /// Flex value of the title.
  ///
  /// Determines how much horizontal space the title takes.
  ///
  /// Defaults to 3.
  final int titleFlex;

  /// The physics to use for the features section.
  ///
  /// Defaults to [BouncingScrollPhysics].
  final ScrollPhysics scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return CupertinoOnboardingPage(
      title: title,
      description: description,
      bodyPadding: bodyPadding,
      titleTopIndent: titleTopIndent,
      titleToBodySpacing: titleToBodySpacing,
      bodyToBottomSpacing: bodyToBottomSpacing,
      titleFlex: titleFlex,
      body: Column(
        mainAxisSize: MainAxisSize.min,
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
