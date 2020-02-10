import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  //@todo this is used for everything, just seems like a very bad idea. Make dialogs for the seperate things. Maybe a popup dialog with info ok/cancel and other dialogs for eg pin entry
  final String description;
  final Widget widgetDescription;
  final List<Widget> actions;
  final String title;
  final IconData image;
  final dynamic hiddenaction;

  CustomDialog({
    @required this.title,
    @required this.description,
    this.widgetDescription,
    this.actions,
    this.image = Icons.person,
    this.hiddenaction,
  });

  show(context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        image: Icons.error,
        title: this.title,
        description: this.description,
        widgetDescription: this.widgetDescription,
        actions: <Widget>[
          //@todo make this configurable, ok;okcancel
          FlatButton(
            child: new Text("Ok"),
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
      child: FlatButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          if (hiddenaction != null) {
            timesPressed++;
            // logger.log('= ' + hiddenaction.toString());
            // logger.log('--------------+++++++++ ' + timesPressed.toString());
            if (timesPressed >= timesPressedToReveal) {
              hiddenaction();
              timesPressed = 0;
            }
          }
        },
        child: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 30.0,
          child: Icon(
            image,
            size: 42.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  card(context) {
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: double.infinity, maxWidth: double.infinity),
      child: Container(
        padding: EdgeInsets.only(top: 30.0 + 20.0),
        margin: EdgeInsets.only(top: 30.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: ListView(
          shrinkWrap: true,
          // mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16.0),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 310),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: (widgetDescription == null)
                    ? Text(
                        description,
                        textAlign: TextAlign.center,
                      )
                    : widgetDescription,
              ),
            ),
            SizedBox(height: 24.0),
            actions != null && actions.length > 0
                ? Container(
                    decoration: new BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: const Offset(0.0, 10.0),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: actions,
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
