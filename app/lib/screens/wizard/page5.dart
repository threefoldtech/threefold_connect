import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/wizard/common_page.dart';

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonPage(
      title: 'START YOUR',
      subtitle: 'JOURNEY',
      imagePath: 'assets/rocket_outline.png',          
      heightPercentage: 0.4,
      widthPercentage: 0.75,
      showTermsAndConditions: true,
    );
  }
}