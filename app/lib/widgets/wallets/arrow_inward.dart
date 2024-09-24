import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowInward extends StatelessWidget {
  const ArrowInward({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 180 * math.pi / 180,
      child: Icon(
        Icons.arrow_outward,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
