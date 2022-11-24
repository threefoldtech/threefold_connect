import 'package:flutter/material.dart';
import 'package:threebotlogin/api/3bot/services/user.service.dart';
import 'package:threebotlogin/api/kyc/services/kyc.service.dart';
import 'package:threebotlogin/core/router/tabs/views/tabs.views.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';
import 'package:threebotlogin/core/storage/kyc/kyc.storage.dart';
import 'package:threebotlogin/email/dialogs/email.dialogs.dart';
import 'package:threebotlogin/phone/dialogs/phone.dialogs.dart';
import 'package:threebotlogin/phone/helpers/phone.helpers.dart';
import 'package:threebotlogin/pkid/helpers/pkid.helpers.dart';
import 'package:threebotlogin/views/identity/dialogs/identity.dialogs.dart';
import 'package:threebotlogin/views/identity/widgets/identity.widgets.dart';

class IdentityScreen extends StatefulWidget {
  IdentityScreen();

  _IdentityScreenState createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  _IdentityScreenState();

  late String? email = '';
  late String? phone = '';

  bool validPhoneNumber = true;
  bool validEmail = true;

  String? countryCode;

  @override
  void initState() {
    super.initState();

    Globals().emailVerified.addListener(setEmailVerified);
    Globals().phoneVerified.addListener(setPhoneVerified);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await setIdentityData();
    });
  }

  @override
  Widget build(BuildContext context) {
    Globals().globalBuildContext = context;
    return LayoutDrawer(
        titleText: 'Identity',
        content: Stack(
          children: [
            Column(children: [
              Globals().canVerifyEmail ? emailTab(email) : Container(),
              Globals().canVerifyPhone ? phoneTab(phone, countryCode) : Container()
            ])
          ],
        ));
  }

  Future<void> setIdentityData() async {
    Globals().emailVerified.value = (await getEmail())['sei'] != null;
    Globals().phoneVerified.value = (await getPhone())['spi'] != null;

    this.email = (await getEmail())['email'];
    this.phone = (await getPhone())['phone'];

    if (Globals().smsSentOn + (Globals().smsMinutesCoolDown * 60 * 1000) < new DateTime.now().millisecondsSinceEpoch) {
      Globals().smsSentOn = 0;
      setState(() {});
    }

    this.countryCode = await getCountry();

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setEmailVerified() {
    if (!mounted) return;
    setState(() {});
  }

  void setPhoneVerified() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> saveEmail(String email) async {
    Globals().emailVerified.value = false;
    await setEmail(email, null);
    await saveEmailToPKid();
    bool isUpdated = await updateEmailAddressOfUser();

    if (!isUpdated) {
      showCouldNotUpdateEmail();
    }

    this.email = email;
    setState(() {});
  }

  Future<void> savePhone(String phone) async {
    Globals().phoneVerified.value = false;
    await setPhone(phone, null);
    await savePhoneToPKid();

    this.phone = phone;
    setState(() {});
  }

  Widget emailTab(String? email) {
    return GestureDetector(
      onTap: () async {
        String? email = await showChangeEmailDialog();
        if (email == null || email == '') return;

        await saveEmail(email);
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
        height: 75,
        width: MediaQuery.of(context).size.width * 100,
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 30.0,
              height: 30.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Globals().emailVerified.value ? verifiedIcon : stepIcon(1)],
              ),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
            ),
            Padding(padding: EdgeInsets.only(left: 20)),
            Icon(
              Icons.email,
              size: 20,
              color: Colors.black,
            ),
            Padding(padding: EdgeInsets.only(left: 15)),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width * 0.55,
                                maxWidth: MediaQuery.of(context).size.width * 0.55),
                            child: Text(email == null || email == '' ? 'Unknown' : email,
                                overflow: TextOverflow.clip,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [Globals().emailVerified.value ? verifiedText() : notVerifiedText()],
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Globals().emailVerified.value ? editIcon : verifyEmailButton()],
                )
              ],
            )),
            Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
      ),
    );
  }

  Widget phoneTab(String? phone, String? countryCode) {
    return GestureDetector(
        onTap: () async {
          if (Globals().emailVerified.value == false) return;

          String? phone = await showChangePhoneDialog(countryCode);
          if (phone == null || phone == '') return;
          await savePhone(phone);

          showVerifyNow();
        },
        child: Opacity(
          opacity: Globals().emailVerified.value == false ? 0.5 : 1,
          child: Container(
            decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
            height: 75,
            width: MediaQuery.of(context).size.width * 100,
            child: Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 10)),
                Container(
                  width: 30.0,
                  height: 30.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Globals().phoneVerified.value ? verifiedIcon : stepIcon(2)],
                  ),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                ),
                Padding(padding: EdgeInsets.only(left: 20)),
                Icon(
                  Icons.phone,
                  size: 20,
                  color: Colors.black,
                ),
                Padding(padding: EdgeInsets.only(left: 15)),
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                                constraints: BoxConstraints(
                                    minWidth: MediaQuery.of(context).size.width * 0.55,
                                    maxWidth: MediaQuery.of(context).size.width * 0.55),
                                child: Text(phone == null || phone == '' ? 'Unknown' : phone,
                                    overflow: TextOverflow.clip,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Globals().phoneVerified.value
                                ? verifiedText()
                                : Globals().smsSentOn != 0
                                    ? retryInSecondsText()
                                    : notVerifiedText()
                          ],
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Globals().phoneVerified.value ? editIcon : verifyPhoneButton(countryCode)],
                    )
                  ],
                )),
                Padding(padding: EdgeInsets.only(right: 10))
              ],
            ),
          ),
        ));
  }

  Future<void> showVerifyNow() async {
    bool? verifyNow = await showVerifyNowDialog();
    if (verifyNow == null || !verifyNow) return;

    await sendSms(this.phone!);

    Globals().smsSentOn = new DateTime.now().millisecondsSinceEpoch;
    setState(() {});

    showSmsSentDialog();
  }

  Widget verifyPhoneButton(String? countryCode) {
    if (Globals().smsSentOn != 0 || Globals().emailVerified.value == false) return Container();

    return ElevatedButton(
        onPressed: () async {
          if (this.phone == null || this.phone == '') {
            String? phoneNumber = await showChangePhoneDialog(countryCode);
            if (phoneNumber == null || phoneNumber == '') return;
          }

          showVerifyNow();
        },
        child: Text('Verify'));
  }
}
