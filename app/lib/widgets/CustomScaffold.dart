import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget bottom;
  final double padding;
  final Widget footer;
  final Widget appBar;
  final bool renderBackground;

  const CustomScaffold(
      {Key key,
      @required this.body,
      this.title = '3Bot connect',
      this.bottom,
      this.footer,
      this.padding = 0.0,
      this.appBar,
      this.renderBackground = false})
      : super(key: key);

  @override
  Scaffold build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: this.footer == null
                    ? BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24))
                    : BorderRadius.all(
                        Radius.circular(24),
                      ),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Container(
                    decoration: renderBackground ? BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ) : BoxDecoration(),
                    width: double.infinity,
                    padding: EdgeInsets.all(padding),
                    child: body,
                  ),
                ),
              ),
            ),
            footer == null
                ? Container()
                : Container(
                    padding: EdgeInsets.only(top: padding),
                    color: Theme.of(context).primaryColor,
                    child: footer,
                  )
          ],
        ),
      ),
    );
  }
}
