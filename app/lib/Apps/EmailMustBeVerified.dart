import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

mixin EmailMustBeVerified<T extends StatefulWidget> on State<T> {
  BuildContext get context;
  bool hidden = false;

  bool get isHidden {
    return hidden;
  }
  updateHidden(){
  setState(() {
      this.hidden = Globals().emailVerified.value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkEmailVerified());
    Globals().emailVerified.addListener(updateHidden);
  }
  
  checkEmailVerified() async {
    if (!mounted) return;
    var email = await getEmail();

    setState(() {
      hidden = true;
    });

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
    }
  }
}
