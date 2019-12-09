import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImageButton extends StatefulWidget {
  final imageId;
  final selectedImageId;
  final callback;

  ImageButton(this.imageId, this.selectedImageId, this.callback, {Key key}) : super(key: key);

  _ImageButtonState createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            border: (widget.selectedImageId == widget.imageId)
                ? Border.all(width: 2, color: Theme.of(context).primaryColor)
                : Border.all(width: 2, color: Colors.transparent),
            shape: BoxShape.circle,),
        width: 50,
        height: 50,
        child: FlatButton(
          onPressed: () {
            widget.callback(widget.imageId);
          },
          child: Image.asset(
            'assets/icons/' + widget.imageId.toString() + '.png',
          ),
          padding: EdgeInsets.all(10),
          shape: new CircleBorder(),
        )
    );
  }
}