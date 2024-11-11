import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/wizard/common_page.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonPage(
      title: 'THREEFOLD',
      subtitle: 'NEWS',
      imagePath: 'assets/news_outline.png',
      description: "Stay up to date with ThreeFold's latest news",
      heightPercentage: 0.35,
      widthPercentage: 0.70,
    );
  }
}
