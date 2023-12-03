import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String? description;
  final Widget? widgetDescription;
  final List<Widget>? actions;
  final String title;
  final IconData image;
  final dynamic hiddenAction;

  const CustomDialog({
    super.key,
    required this.title,
    this.description,
    this.widgetDescription,
    this.actions,
    this.image = Icons.person,
    this.hiddenAction,
  });

  show(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: title,
        description: description,
        widgetDescription: widgetDescription,
        actions: <Widget>[
          //@todo make this configurable, ok;okcancel
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  show(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: widget.title,
        description: widget.description,
        widgetDescription: widget.widgetDescription,
        actions: <Widget>[
          //@todo make this configurable, ok;okcancel
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[card(context), circularImage(context)],
    );
  }

  circularImage(context) {
    int timesPressed = 0;
    const int timesPressedToReveal = 5;
    return Positioned(
      left: 20.0,
      right: 20.0,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: () {
          if (widget.hiddenAction != null) {
            timesPressed++;
            // logger.log('= ' + hiddenaction.toString());
            // logger.log('--------------+++++++++ ' + timesPressed.toString());
            if (timesPressed >= timesPressedToReveal) {
              widget.hiddenAction();
              timesPressed = 0;
            }
          }
        },
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 30.0,
          child: Icon(
            widget.image,
            size: 42.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  card(context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          maxHeight: double.infinity, maxWidth: double.infinity),
      child: Container(
        padding: const EdgeInsets.only(top: 30.0 + 20.0),
        margin: const EdgeInsets.only(top: 30.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 310),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: (widget.widgetDescription == null)
                    ? Text(
                        widget.description!,
                        textAlign: TextAlign.center,
                      )
                    : widget.widgetDescription,
              ),
            ),
            const SizedBox(height: 24.0),
            widget.actions != null && widget.actions!.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widget.actions!,
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
