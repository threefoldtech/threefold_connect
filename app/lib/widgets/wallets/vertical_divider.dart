import 'package:flutter/material.dart';

class CustomVerticalDivider extends StatelessWidget {
  const CustomVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 35),
        child: SizedBox(
          height: 40,
          child: VerticalDivider(
            color: Colors.grey,
            width: 2,
          ),
        ),
      ),
    );
  }
}
