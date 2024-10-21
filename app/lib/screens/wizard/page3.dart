import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/wizard/common_page.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonPage(
      title: 'THREEFOLD',
      subtitle: 'WALLET',
      imagePath: 'assets/wallet_outline.png',
      description:
          'Access your ThreeFold Wallet and send/receive ThreeFold Tokens (TFT). More currencies can be added in the future.',
      heightPercentage: 0.4,
      widthPercentage: 0.75,
    );
  }
}
