import 'package:flutter/material.dart';

class ImageButton extends StatefulWidget {
  final imageId;
  final selectedImageId;
  final callback;

  const ImageButton(this.imageId, this.selectedImageId, this.callback,
      {super.key});

  State<ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: (widget.selectedImageId == widget.imageId)
            ? Border.all(width: 2, color: Theme.of(context).primaryColor)
            : Border.all(width: 2, color: Colors.transparent),
        shape: BoxShape.circle,
      ),
      width: 50,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(10),
          shape: const CircleBorder(),
        ),
        onPressed: () {
          widget.callback(widget.imageId);
        },
        child: Image.asset(
          'assets/icons/${widget.imageId.toString()}.png',
        ),
      ),
    );
  }
}
