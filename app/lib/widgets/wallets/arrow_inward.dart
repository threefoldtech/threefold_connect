import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowInward extends StatelessWidget {
  const ArrowInward({super.key, required this.color, this.size = 24});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 180 * math.pi / 180,
      child: Icon(
        Icons.arrow_outward,
        color: color,
        size: size,
      ),
    );
  }
}
