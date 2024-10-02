import 'package:flutter/material.dart';
import 'package:threebotlogin/models/contact.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/contact_service.dart';
import 'package:threebotlogin/widgets/wallets/add_edit_contact.dart';
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
      if (widget.chainType == ChainType.Stellar) {
        myWalletContacts.add(PkidContact(
            name: w.name, address: w.stellarAddress, type: ChainType.Stellar));
      }
      if (widget.chainType == ChainType.TFChain) {
        myWalletContacts.add(PkidContact(
            name: w.name, address: w.tfchainAddress, type: ChainType.TFChain));
      }
    }
  }

  _loadFavouriteContacts() async {
    myPkidContacts = await getPkidContacts();
    myPkidContacts =
        myPkidContacts.where((c) => c.type == widget.chainType).toList();
    setState(() {});
  }

  _onAddContact(PkidContact contact) async {
    myPkidContacts.add(contact);
    setState(() {});
  }

  _openAddContactOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => AddEditContact(
              onAddContact: _onAddContact,
              chainType: widget.chainType,
              contacts: [...myPkidContacts, ...myWalletContacts],
            ));
  }

  _openEditContactOverlay(String name, String address) {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => AddEditContact(
              chainType: widget.chainType,
              contacts: [...myPkidContacts, ...myWalletContacts],
              operation: ContactOperation.Edit,
              name: name,
              address: address,
              onEditContact: _onEditContact,
            ));
  }

  _onEditContact(String oldName, String newName, String newAddress) {
    for (final c in myPkidContacts) {
      if (c.name == oldName) {
        c.name = newName;
        c.address = newAddress;
      }
    }
    setState(() {});
  }

  _onDeleteContact(String name) {
    myPkidContacts = myPkidContacts.where((c) => c.name != name).toList();
    setState(() {});
  }

  @override
  void initState() {
    _loadMyWalletContacts();
    _loadFavouriteContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          actions: [
            IconButton(
                onPressed: _openAddContactOverlay, icon: const Icon(Icons.add))
          ],
        ),
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
                    labelStyle: Theme.of(context).textTheme.titleLarge,
                    unselectedLabelStyle:
                        Theme.of(context).textTheme.titleMedium,
                    tabs: const [
                      Tab(text: 'My Wallets'),
                      Tab(text: 'Favorites'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ContactsWidget(
                        contacts: myWalletContacts
                            .where(
                                (c) => c.address != widget.currentWalletAddress)
                            .toList(),
                        onSelectToAddress: widget.onSelectToAddress),
                    ContactsWidget(
                      contacts: myPkidContacts,
                      onSelectToAddress: widget.onSelectToAddress,
                      onDeleteContact: _onDeleteContact,
                      onEditContact: _openEditContactOverlay,
                      canEditAndDelete: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
