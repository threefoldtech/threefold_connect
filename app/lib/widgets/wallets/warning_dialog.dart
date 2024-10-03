import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class WarningDialogWidget extends StatefulWidget {
  const WarningDialogWidget({
    super.key,
    required this.title,
    required this.description,
    required this.onAgree,
  });
  final String title;
  final String description;
  final Future<bool> Function() onAgree;
  @override
  State<WarningDialogWidget> createState() => _WarningDialogWidgetState();
}

class _WarningDialogWidgetState extends State<WarningDialogWidget> {
  bool deleteLoading = false;

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      type: DialogType.Warning,
      image: Icons.warning,
      title: widget.title,
      description: widget.description,
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          onPressed: () async {
            deleteLoading = true;
            setState(() {});
            await widget.onAgree();
            deleteLoading = false;
            setState(() {});
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: deleteLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.warning,
                  ))
              : Text(
                  'Yes',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.warning),
                ),
        ),
      ],
    );
  }
}
