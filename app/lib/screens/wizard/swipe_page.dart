import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:threebotlogin/screens/wizard/page1.dart';
import 'package:threebotlogin/screens/wizard/page2.dart';
import 'package:threebotlogin/screens/wizard/page3.dart';
import 'package:threebotlogin/screens/wizard/page4.dart';
import 'package:threebotlogin/screens/wizard/page5.dart';

import '../../widgets/wizard/terms_and_conditions.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePagesState();
}

class _SwipePagesState extends State<SwipePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // Skip button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 60), // Balance skip button
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const TermsAndConditions();
                      },
                    );
                  },
                  child: Text(
                    'Skip',
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: const [Page1(), Page2(), Page3(), Page4(), Page5()],
            ),
          ),

          // Page Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _totalPages,
              effect: ExpandingDotsEffect(
                dotWidth: 12,
                dotHeight: 12,
                spacing: 8,
                activeDotColor: colorScheme.primary,
                dotColor: colorScheme.outline.withOpacity(0.3),
                expansionFactor: 3,
              ),
            ),
          ),

          // Navigation Buttons (only show if not on last page)
          if (_currentPage < _totalPages - 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  if (_currentPage > 0)
                    OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'Previous',
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),

                  // Next button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: colorScheme.primary,
                      elevation: 0,
                    ),
                    child: Text(
                      'Next',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
