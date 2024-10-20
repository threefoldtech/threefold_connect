import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/wizard/common_page.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonPage(
      title: 'MAXIMUM',
      subtitle: 'SECURITY',
      imagePath: 'assets/finger_outline.png',
      widthPercentage: 0.6,
      heightPercentage: 0.4,
      description:
          'The app provides a secure authentication mechanism that provides your identity on the Threefold Grid.',
    );
  }
}
