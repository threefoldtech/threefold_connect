import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/wizard/common_page.dart';

class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonPage(
      title: 'WELCOME TO',
      subtitle: '',
      imagePath: 'assets/TF_logo.svg',
      widthPercentage: 0.65,
      heightPercentage: 0.25,
      description:
          'ThreeFold Connect is your main access point to the ThreeFold Grid, ThreeFold Token, and more. Please allow us to quickly show you around!',
    );
  }
}
