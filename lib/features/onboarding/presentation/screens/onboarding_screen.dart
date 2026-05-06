import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingData> _buildPages(BuildContext context) {
    final l = context.l10n;
    return [
      _OnboardingData(
        imagePath: 'assets/images/logo.jpg',
        title: l.welcomeTitle,
        subtitle: l.welcomeSubtitle,
      ),
      _OnboardingData(
        icon: Icons.schedule_rounded,
        title: l.preciseTimesTitle,
        subtitle: l.preciseTimesSubtitle,
      ),
      _OnboardingData(
        icon: Icons.auto_awesome_rounded,
        title: l.guidedMakeupTitle,
        subtitle: l.guidedMakeupSubtitle,
      ),
      _OnboardingData(
        icon: Icons.explore_rounded,
        title: l.qiblaPlusTitle,
        subtitle: l.qiblaPlusSubtitle,
      ),
    ];
  }

  void _nextPage(int pageCount) {
    if (_currentPage < pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(RouteNames.profileSetup);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages(context);
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.goNamed(RouteNames.profileSetup),
                child: Text(
                  context.l10n.skipButton,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: pages.length,
                itemBuilder: (context, index) => OnboardingPageWidget(
                  icon: pages[index].icon,
                  imagePath: pages[index].imagePath,
                  title: pages[index].title,
                  subtitle: pages[index].subtitle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.deepPurple
                              : AppColors.lightPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _nextPage(pages.length),
                      child: Text(
                        _currentPage < pages.length - 1
                            ? context.l10n.nextButton
                            : context.l10n.startButton,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String subtitle;
  const _OnboardingData({
    this.icon,
    this.imagePath,
    required this.title,
    required this.subtitle,
  });
}
