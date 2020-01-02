import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

mixin EmailMustBeVerified<T extends StatefulWidget> on State<T> {
  BuildContext get context;
  bool hidden = true;

  bool get isHidden {
    return hidden;
  }

  updateHidden() {
    setState(() {
      hidden = Globals().emailVerified.value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkEmailVerified());
    Globals().emailVerified.addListener(updateHidden);
  }

  checkEmailVerified() async {
    var email = await getEmail();
    if (email != null && !email['verified']) {
      var actions = <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ];

      showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
            title: 'Verify email',
            description: Text('Please verify email first.'),
            actions: actions),
      );
    } else {
      setState(() {
        hidden = false;
      });
    }
  }
}
