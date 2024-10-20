import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';

enum DialogType { Info, Warning, Error }

class CustomDialog extends StatefulWidget {
  final String? description;
  final Widget? widgetDescription;
  final List<Widget>? actions;
  final String title;
  final IconData image;
  final dynamic hiddenAction;
  final DialogType type;

  const CustomDialog({
    super.key,
    required this.title,
    this.description,
    this.widgetDescription,
    this.actions,
    this.image = Icons.person,
    this.hiddenAction,
    this.type = DialogType.Info,
  });

  show(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        type: DialogType.Error,
        title: title,
        description: description,
        widgetDescription: widgetDescription,
        actions: <Widget>[
          //@todo make this configurable, ok;okcancel
          TextButton(
            child: const Text('Close'),
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
        type: DialogType.Error,
        image: Icons.error,
        title: widget.title,
        description: widget.description,
        widgetDescription: widget.widgetDescription,
        actions: <Widget>[
          //@todo make this configurable, ok;okcancel
          TextButton(
            child: const Text('Close'),
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
    Color backgroundColor;
    Color color;
    if (widget.type == DialogType.Error) {
      backgroundColor = Theme.of(context).colorScheme.error;
      color = Theme.of(context).colorScheme.onError;
    } else if (widget.type == DialogType.Warning) {
      backgroundColor = Theme.of(context).colorScheme.warning;
      color = Theme.of(context).colorScheme.onWarning;
    } else {
      backgroundColor = Theme.of(context).colorScheme.primary;
      color = Theme.of(context).colorScheme.onPrimary;
    }
    return Positioned(
      left: 20.0,
      right: 20.0,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
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
          backgroundColor: backgroundColor,
          radius: 30.0,
          child: Icon(
            widget.image,
            size: 42.0,
            color: color,
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
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
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
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 310),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: (widget.widgetDescription == null)
                    ? Text(
                        widget.description!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface),
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
