import 'package:flutter/material.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/contact_service.dart';
import 'package:threebotlogin/widgets/wallets/contacts_widget.dart';

class ContractsScreen extends StatefulWidget {
  const ContractsScreen(
      {super.key,
      required this.chainType,
      required this.currentWalletAddress,
      required this.wallets,
      required this.onSelectToAddress});

  final ChainType chainType;
  final String currentWalletAddress;
  final List<Wallet> wallets;
  final void Function(String address) onSelectToAddress;

  @override
  State<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends State<ContractsScreen> {
  List<PkidContact> myWalletContacts = [];
  List<PkidContact> myPkidContacts = [];

  _loadMyWalletContacts() {
    for (final w in widget.wallets) {
      if (widget.chainType == ChainType.Stellar &&
          w.stellarAddress != widget.currentWalletAddress) {
        myWalletContacts.add(PkidContact(
            name: w.name, address: w.stellarAddress, type: ChainType.Stellar));
      }
      if (widget.chainType == ChainType.TFChain &&
          w.tfchainAddress != widget.currentWalletAddress) {
        myWalletContacts.add(PkidContact(
            name: w.name, address: w.tfchainAddress, type: ChainType.TFChain));
      }
    }
  }

  _loadOtherContacts() async {
    myPkidContacts = await getPkidContacts();
    myPkidContacts =
        myPkidContacts.where((c) => c.type == widget.chainType).toList();
    setState(() {});
  }

  @override
  void initState() {
    _loadMyWalletContacts();
    _loadOtherContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Contacts')),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    labelColor: Theme.of(context).colorScheme.primary,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onBackground,
                    dividerColor: Theme.of(context).scaffoldBackgroundColor,
                    tabs: const [
                      Tab(text: 'My Wallets'),
                      Tab(text: 'Others'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ContactsWidget(
                        contacts: myWalletContacts,
                        onSelectToAddress: widget.onSelectToAddress),
                    ContactsWidget(
                        contacts: myPkidContacts,
                        onSelectToAddress: widget.onSelectToAddress),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
