import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/widgets/farm_node_item.dart';

class FarmItemWidget extends StatefulWidget {
  const FarmItemWidget({super.key, required this.farm});
  final Farm farm;

  @override
  State<FarmItemWidget> createState() => _FarmItemWidgetState();
}

class _FarmItemWidgetState extends State<FarmItemWidget> {
  final walletAddressController = TextEditingController();
  final tfchainWalletSecretController = TextEditingController();
  final walletNameController = TextEditingController();
  final twinIdController = TextEditingController();
  final farmIdController = TextEditingController();
  bool showTfchainSecret = false;

  @override
  void dispose() {
    walletAddressController.dispose();
    tfchainWalletSecretController.dispose();
    walletNameController.dispose();
    twinIdController.dispose();
    farmIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    walletAddressController.text = widget.farm.walletAddress;
    tfchainWalletSecretController.text = widget.farm.tfchainWalletSecret;
    walletNameController.text = widget.farm.walletName;
    farmIdController.text = widget.farm.farmId;
    twinIdController.text = widget.farm.twinId;

    return ExpansionTile(
      title: Text(
        widget.farm.name,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        ListTile(
          title: TextField(
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              controller: walletAddressController,
              decoration: const InputDecoration(
                labelText: 'Stellar Payout Address',
              )),
          subtitle: const Text('This address will be used for payout.'),
          trailing: IconButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: walletAddressController.text));
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Copied!')));
              },
              icon: const Icon(Icons.copy)),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              obscureText: !showTfchainSecret,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              controller: tfchainWalletSecretController,
              decoration: InputDecoration(
                labelText: 'TFChain Secret',
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showTfchainSecret = !showTfchainSecret;
                      });
                    },
                    icon: Icon(showTfchainSecret
                        ? Icons.visibility_off
                        : Icons.visibility)),
              )),
          subtitle: const Text(
              'You can login into ThreeFold Dashboard using this secret for more farm management.'),
          trailing: IconButton(
              onPressed: () {
                Clipboard.setData(
                    ClipboardData(text: tfchainWalletSecretController.text));
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Copied!')));
              },
              icon: const Icon(Icons.copy)),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              controller: walletNameController,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
              )),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              controller: twinIdController,
              decoration: const InputDecoration(
                labelText: 'Twin ID',
              )),
        ),
        ListTile(
          title: TextField(
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
              controller: farmIdController,
              decoration: const InputDecoration(
                labelText: 'Farm ID',
              )),
        ),
        ExpansionTile(
          title: const Text('Nodes'),
          childrenPadding: const EdgeInsets.only(left: 20),
          children: [
            for (final node in widget.farm.nodes) FarmNodeItemWidget(node: node)
          ],
        )
      ],
    );
  }
}
