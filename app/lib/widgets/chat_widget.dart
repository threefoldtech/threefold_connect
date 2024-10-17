import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class CrispChatbot extends StatefulWidget {
  const CrispChatbot({super.key});

  @override
  State<CrispChatbot> createState() => _CrispChatbotState();
}

class _CrispChatbotState extends State<CrispChatbot> {
  late CrispConfig config;

  @override
  void initState() {
    super.initState();

    _prepareConfig();
  }

  _prepareConfig() async {
    final email = await getEmail();
    final String emailAddress = email['email'].toString();
    config = CrispConfig(
      websiteID: '1a5a5241-91cb-4a41-8323-5ba5ec574da0',
      sessionSegment: 'test',
      user: User(email: emailAddress),
    );
  }

  void _openChat() async {
    try {
      await FlutterCrispChat.openCrispChat(config: config);
    } catch (e) {
      print('Error opening chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: _openChat,
        child: CircleAvatar(
          radius: 30,
          // backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundColor: Colors.blue,
          child: SvgPicture.asset(
            'assets/crisp.svg',
            // colorFilter: ColorFilter.mode(
            //     Theme.of(context).colorScheme.onPrimaryContainer,
            //     BlendMode.srcIn),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

}
