import 'package:flutter/material.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/styles/box.styles.dart';
import 'package:threebotlogin/core/styles/color.styles.dart';
import 'package:threebotlogin/views/identity/helpers/identity.helpers.dart';

Future<String?> showChangeEmailDialog() async {
  final TextEditingController emailController = TextEditingController();
  bool validEmail = false;

  return showDialog(
      context: Globals().globalBuildContext,
      builder: (context) {
        return StatefulBuilder(builder: (statefulContext, setCustomState) {
          return Dialog(
              child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 0.5, color: Colors.grey),
                        ),
                        color: Colors.white,
                      ),
                      child: Container(
                          padding: EdgeInsets.all(28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Change email',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black),
                              ),
                              GestureDetector(
                                  onTap: () async {
                                    Navigator.pop(context, null);
                                  },
                                  child: Container(
                                      width: 30.0,
                                      height: 30.0,
                                      decoration: kCloseBorder,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.close,
                                            size: 14,
                                            color: kThreeFoldGrey,
                                          )
                                        ],
                                      )))
                            ],
                          )),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 28, right: 28, bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        onChanged: (value) {
                          validEmail = isValidEmail(value);
                          setCustomState(() {});
                        },
                        controller: emailController,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: "Email",
                          border: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.teal)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 28, right: 28, bottom: 28),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(backgroundColor: kThreeFoldLightGrey),
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: kThreeFoldGrey),
                          )),
                      SizedBox(width: 10),
                      TextButton(
                          style: TextButton.styleFrom(backgroundColor: validEmail ? Colors.blue : kThreeFoldLightGrey),
                          onPressed: () {
                            setCustomState(() {});
                            if (!validEmail) return;

                            Navigator.pop(context, emailController.text);
                          },
                          child: Text(
                            'Change',
                            style: TextStyle(color: validEmail ? Colors.white : kThreeFoldGrey),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ));
        });
      });
}
