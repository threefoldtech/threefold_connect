import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/wizard/common_page.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonPage(
      title: 'Welcome to',
      subtitle: '',
      imagePath: 'assets/TF_logo.svg',
      widthPercentage: 0.75,
      heightPercentage: 0.3,
      description:
          'Threefold Connect is your main access point to the Threefold Grid and more. Please allow us to quickly show you around!',
    );
  }
}
