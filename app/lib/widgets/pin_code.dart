import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:threebotlogin/helpers/globals.dart';

class PincodeWidget extends StatefulWidget {
  const PincodeWidget({
    super.key,
    required this.userMessage,
    required this.title,
    required this.handler,
    this.hideBackButton = false,
  });
  final String title;
  final String userMessage;
  final bool hideBackButton;
  final Function(String) handler;

  @override
  State<PincodeWidget> createState() => _PincodeWidgetState();
}

class _PincodeWidgetState extends State<PincodeWidget> {
  Globals globals = Globals();
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focusedBorderColor = Theme.of(context).colorScheme.primary;
    final fillColor = Theme.of(context).colorScheme.secondaryContainer;
    final borderColor = Theme.of(context).colorScheme.primaryContainer;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Text(widget.title),
          automaticallyImplyLeading: widget.hideBackButton == false),
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.userMessage,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 100),
              Pinput(
                autofocus: true,
                obscureText: true,
                controller: pinController,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                separatorBuilder: (index) => const SizedBox(width: 8),
                onCompleted: (value) {
                  widget.handler(value);
                  pinController.clear();
                },
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                cursor: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      width: 22,
                      height: 1,
                      color: focusedBorderColor,
                    ),
                  ],
                ),
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyBorderWith(
                  border:
                      Border.all(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
