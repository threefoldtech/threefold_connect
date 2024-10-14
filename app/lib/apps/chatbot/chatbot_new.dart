import 'package:crisp_chat/crisp_chat.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/apps/chatbot/chatbot_config.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart'; // Import the Crisp package

import 'package:flutter/material.dart';

class CrispChatbot extends StatefulWidget {
  final String email;

  const CrispChatbot({super.key, required this.email});

  @override
  _CrispChatbotState createState() => _CrispChatbotState(email: email);
}

class _CrispChatbotState extends State<CrispChatbot> with AutomaticKeepAliveClientMixin {
  final String email;
  late CrispConfig config;
  bool isLoading = true; // Loading state

  _CrispChatbotState({required this.email});

  @override
  void initState() {
    super.initState();
    config = CrispConfig(
      websiteID: '1a5a5241-91cb-4a41-8323-5ba5ec574da0',
    );
    _openChat();
  }

  void _openChat() async {
    try {
      await FlutterCrispChat.openCrispChat(config: config);
      FlutterCrispChat.setSessionString(
        key: "user_email",
        value: email,
      );

      Navigator.of(context).pop();
    } catch (e) {
      print("Error opening chat: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const SizedBox.shrink();
    // return const LayoutDrawer(
    //   titleText: 'Support',
    //   content: Center(
    //     child: CircularProgressIndicator()
    //   ),
    // );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    isLoading = false;
  }
}
