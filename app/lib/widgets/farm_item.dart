import 'package:flutter/material.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/farm_details.dart';

class FarmItemWidget extends StatefulWidget {
  const FarmItemWidget({
    super.key,
    required this.farm,
    required this.wallets,
    required this.isV4,
  });

  final Farm farm;
  final List<Wallet> wallets;
  final bool isV4;

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
  bool edit = false;
  bool isSaving = false;

  final walletFocus = FocusNode();
  ChainType chainType = ChainType.Stellar;

  String? addressError;
  String? currentAddress;

  @override
  void initState() {
    super.initState();
    currentAddress = widget.farm.walletAddress;
    walletAddressController.text = currentAddress!;

    tfchainWalletSecretController.text = widget.farm.tfchainWalletSecret;
    walletNameController.text = widget.farm.walletName;
    farmIdController.text = widget.farm.farmId.toString();
    twinIdController.text = widget.farm.twinId.toString();
  }

  @override
  void dispose() {
    walletAddressController.dispose();
    tfchainWalletSecretController.dispose();
    walletNameController.dispose();
    twinIdController.dispose();
    farmIdController.dispose();
    walletFocus.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FarmDetails(
              farm: widget.farm,
              wallets: widget.wallets,
              isV4: widget.isV4,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        clipBehavior: Clip.antiAlias,
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(
                  Icons.menu,
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.farm.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: Colors.white,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.farm.nodes.isNotEmpty)
                      const SizedBox(height: 4.0),
                    if (widget.farm.nodes.isNotEmpty)
                      Text(
                        '${widget.farm.nodes.length} Node${widget.farm.nodes.length == 1 ? '' : 's'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Colors.white70,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}