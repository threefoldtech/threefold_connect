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
  final PageController _pageController =
      PageController(); // Controls the PageView

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                      'SKIP',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface),
                    ))
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int index) {
                setState(() {});
              },
              children: const [Page1(), Page2(), Page3(), Page4(), Page5()],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 5,
                  effect: ExpandingDotsEffect(
                    dotWidth: 20,
                    dotHeight: 20,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotColor: Theme.of(context).colorScheme.outline,
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
