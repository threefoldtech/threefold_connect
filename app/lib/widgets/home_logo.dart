import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

class HomeLogoWidget extends StatelessWidget {
  final bool animate;
  const HomeLogoWidget({super.key, required this.animate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: animate
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Lottie.asset(
                        'assets/tfloading.json',
                        repeat: true,
                        animate: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'THREEFOLD',
                      style: textTheme.titleLarge!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  height: 50,
                  child: SvgPicture.asset(
                    'assets/TF_logo.svg',
                    alignment: Alignment.center,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 1.5,
          width: screenWidth * 0.45,
          child: Divider(
            thickness: 1.5,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'CONNECT',
          style: textTheme.bodyLarge!.copyWith(
            color: colorScheme.onSurface,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
