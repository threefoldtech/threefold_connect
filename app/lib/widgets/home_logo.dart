import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeLogoWidget extends StatelessWidget {
  const HomeLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
    
    child: Container(color: Colors.transparent,child: Lottie.asset(
      'assets/tfloading.json',
      repeat: true,
      animate: true,
        options: LottieOptions(enableMergePaths: true),    
),) 

        ),
      

        // SvgPicture.asset(
        //   'assets/TF_logo.svg',
        //   alignment: Alignment.center,
        //   colorFilter: ColorFilter.mode(
        //       Theme.of(context).colorScheme.onBackground, BlendMode.srcIn),
        // ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
          width: MediaQuery.of(context).size.width * 0.6,
          child: Divider(
            thickness: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          'ThreeFold Connect App',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
