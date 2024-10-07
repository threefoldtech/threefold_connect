import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class HomeLogoWidget extends StatelessWidget {
  final bool animate;
  const HomeLogoWidget({super.key, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: animate
              ? Column(
                  children: [
                    Lottie.asset(
                      'assets/tfloading.json',
                      repeat: true,
                      animate: true,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'THREEFOLD',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : SvgPicture.asset(
                  'assets/TF_logo.svg',
                  alignment: Alignment.center,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onBackground,
                    BlendMode.srcIn,
                  ),
                ),
        ),
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
