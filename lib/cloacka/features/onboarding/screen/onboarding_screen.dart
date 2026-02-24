import 'package:flutter/material.dart';
import 'package:neomoney/app/di.dart';
import 'package:neomoney/cloacka/core/storage/app_prefs.dart';
import 'package:neomoney/cloacka/features/onboarding/model/onboarding_item.dart';
import 'package:neomoney/cloacka/features/policy/widget/privacy_policy_widget.dart';
import 'package:neomoney/core/ui/theme/app_colors.dart';
import 'package:neomoney/core/ui/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.resolveNextRoute,
  });

  final Future<String> Function() resolveNextRoute;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _navigating = false;
  final _pageController = PageController();
  int _index = 0;

  void _next() {
    if (_index < onboardingItems.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      _finishOnboarding();
    }
  }

  void _prev() {
    if (_index > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _finishOnboarding() async {
    if (_navigating) return;
    _navigating = true;

    await getIt<AppPrefs>().setOnboardingDone();

    final next = await widget.resolveNextRoute();
    debugPrint('Onboarding next route: $next');

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      next,
          (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            _Background(),
            Column(
              children: [
                const SizedBox(height: 24),
                const _Header(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingItems.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _CenterContent(item: onboardingItems[i]),
                  ),
                ),
                _BottomControls(
                  index: _index,
                  length: onboardingItems.length,
                  onNext: _next,
                  onPrev: _prev,
                  onSkip: _finishOnboarding,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(decoration: const BoxDecoration(color: AppColors.primary)),
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/line.png',
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterContent extends StatelessWidget {
  final OnboardingItem item;

  const _CenterContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(item.image, height: 360, fit: BoxFit.contain),
          Container(
            height: 60,
            width: 340,
            decoration: BoxDecoration(
              color: const Color(0xFF3EC37A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                item.greenText,
                style: AppTypography.textTheme.displayMedium?.copyWith(
                  color: AppColors.scaffold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/icons/neomoney_logo.png'),
        const SizedBox(height: 15),
        Text(
          'Финансы под контролем',
          style: AppTypography.textTheme.displayMedium?.copyWith(
            color: AppColors.scaffold,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _BottomControls extends StatelessWidget {
  final int index;
  final int length;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;

  const _BottomControls({
    required this.index,
    required this.length,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                index != 0 ? IconButton(
                  onPressed: index > 0 ? onPrev : null,
                  icon: Image.asset('assets/icons/left_arrow.png'),
                ) : SizedBox(width: 52,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    length,
                        (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i <= index ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(i <= index ? 1 : 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onNext,
                  icon: Image.asset('assets/icons/right_arrow.png'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Пропустить',
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: AppColors.scaffold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 10),
          const PrivacyPolicyWidget(),
        ],
      ),
    );
  }
}