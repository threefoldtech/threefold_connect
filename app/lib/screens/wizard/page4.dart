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
      description:
          "Stay updated with ThreeFold's latest updates via the News section within the app.",
      heightPercentage: 0.4,
      widthPercentage: 0.75,
    );
  }
}
