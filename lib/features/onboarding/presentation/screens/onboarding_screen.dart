import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_page.dart';
import '../widgets/onboarding_page_content.dart';

/// Generic 3-slide onboarding carousel — the caller supplies which pages to
/// show (patient vs. pharmacy content) and what happens once the user
/// finishes or skips (marking that role's onboarding seen, then navigating
/// to its login screen).
class OnboardingScreen extends StatefulWidget {
  final List<OnboardingPage> pages;
  final VoidCallback onFinished;

  const OnboardingScreen({super.key, required this.pages, required this.onFinished});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleActionPressed() {
    final isLast = _currentIndex == widget.pages.length - 1;
    if (isLast) {
      widget.onFinished();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.pages.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return OnboardingPageContent(
              page: widget.pages[index],
              pageCount: widget.pages.length,
              currentIndex: _currentIndex,
              isLast: index == widget.pages.length - 1,
              onActionPressed: _handleActionPressed,
              onSkipPressed: widget.onFinished,
            );
          },
        ),
      ),
    );
  }
}
