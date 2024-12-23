import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/scan_screen.dart';
import 'package:threebotlogin/screens/wallets/contacts.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/wallets/select_chain_widget.dart';
import 'package:threebotlogin/widgets/wallets/send_confirmation.dart';
import 'package:validators/validators.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChain;

class WalletSendScreen extends StatefulWidget {
  const WalletSendScreen(
      {super.key, required this.wallet, required this.allWallets});
  final Wallet wallet;
  final List<Wallet> allWallets;

  @override
  State<WalletSendScreen> createState() => _WalletSendScreenState();
}

class _WalletSendScreenState extends State<WalletSendScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  ChainType chainType = ChainType.Stellar;
  Decimal fee = Decimal.one.shift(-1); // 0.1
  String? toAddressError;
  String? amountError;
  bool reloadBalance = true;
  final FocusNode textFieldFocusNode = FocusNode();
  List percentages = [25, 50, 75, 100];
  @override
  void initState() {
    fromController.text = widget.wallet.stellarAddress;
    _reloadBalances();
    super.initState();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    amountController.dispose();
    memoController.dispose();
    reloadBalance = false;
    textFieldFocusNode.dispose();
    super.dispose();
  }

  _loadTFChainBalance() async {
    final chainUrl = Globals().chainUrl;
    final balance =
        await TFChain.getBalance(chainUrl, widget.wallet.tfchainAddress);
    widget.wallet.tfchainBalance =
        balance.toString() == '0.0' ? '0' : balance.toString();
    setState(() {});
  }

  _loadStellarBalance() async {
    widget.wallet.stellarBalance =
        (await Stellar.getBalance(widget.wallet.stellarSecret)).toString();
    setState(() {});
  }

  _reloadBalances() async {
    if (!reloadBalance) return;
    final refreshBalance = Globals().refreshBalance;
    final WalletsNotifier walletRef =
        ProviderScope.containerOf(context, listen: false)
            .read(walletsNotifier.notifier);
    final wallet = walletRef.getUpdatedWallet(widget.wallet.name)!;
    widget.wallet.tfchainBalance = wallet.tfchainBalance;
    widget.wallet.stellarBalance = wallet.stellarBalance;
    setState(() {});
    await Future.delayed(Duration(seconds: refreshBalance));
    await _reloadBalances();
  }

  onChangeChain(ChainType type) {
    fromController.text = type == ChainType.Stellar
        ? widget.wallet.stellarAddress
        : widget.wallet.tfchainAddress;
    chainType = type;
    toController.text = '';
    toAddressError = null;
    amountController.text = '';
    amountError = null;
    fee = Decimal.one
        .shift(chainType == ChainType.Stellar ? -1 : -2); // 0.1 : 0.01
    setState(() {});
  }

  Future<bool> _validateToAddress() async {
    final toAddress = toController.text.trim();
    final fromAddress = fromController.text.trim();
    toAddressError = null;
    if (toAddress.isEmpty) {
      toAddressError = "Address can't be empty";
      return false;
    }

    if (toAddress == fromAddress) {
      toAddressError = '"To" and "From" addresses must be different';
      return false;
    }

    if (chainType == ChainType.TFChain) {
      if (toAddress.length != 48) {
        toAddressError = 'Address length should be 48 characters';
        return false;
      }
    }

    if (chainType == ChainType.Stellar) {
      if (!isValidStellarAddress(toAddress)) {
        toAddressError = 'Invaild Stellar address';
        return false;
      }

      final matchingWallets = widget.allWallets
          .where((wallet) => wallet.stellarAddress == toAddress);
      final Wallet? wallet =
          matchingWallets.isNotEmpty ? matchingWallets.first : null;
      if (wallet != null && wallet.stellarBalance == '-1') {
        toAddressError = 'Wallet not activated on stellar';
        return false;
      } else {
        final balance = await Stellar.getBalanceByAccountId(toAddress);
        if (balance == '-1') {
          toAddressError = 'Wallet not activated on stellar';
          return false;
        }
      }
    }
    return true;
  }

  bool _validateAmount() {
    final amount = amountController.text.trim();
    amountError = null;

    if (amount.isEmpty) {
      amountError = "Amount can't be empty";
      return false;
    }
    if (!isFloat(amount)) {
      amountError = 'Amount should have numeric values only';
      return false;
    }
    final balance = roundAmount(chainType == ChainType.TFChain
        ? widget.wallet.tfchainBalance
        : widget.wallet.stellarBalance);

    if (balance - Decimal.parse(amount) - fee < Decimal.zero) {
      amountError = 'Balance is not enough';
      return false;
    }
    return true;
  }

  Future<bool> _validate() async {
    final validAddress = await _validateToAddress();
    final validAmount = _validateAmount();
    setState(() {});
    return validAddress && validAmount;
  }

  void _selectToAddress(String address) {
    toController.text = address;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool hideStellar = widget.wallet.stellarBalance == '-1';
    if (hideStellar && chainType == ChainType.Stellar) {
      onChangeChain(ChainType.TFChain);
    }
    String balance = chainType == ChainType.Stellar
        ? widget.wallet.stellarBalance
        : widget.wallet.tfchainBalance;
    final isBiggerThanFee = roundAmount(balance) > fee;

    return Scaffold(
        appBar: AppBar(title: const Text('Send')),
        body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  SelectChainWidget(
                      chainType: chainType,
                      onChangeChain: onChangeChain,
                      hideStellar: hideStellar),
                  const SizedBox(height: 40),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: TextButton(
                      onPressed: () {
                        scanQrCode();
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Scan QR Code',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: TextField(
                        readOnly: true,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        controller: fromController,
                        decoration: InputDecoration(
                          labelText: 'From (name: ${widget.wallet.name})',
                        )),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: TextField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        controller: toController,
                        decoration: InputDecoration(
                            labelText: 'To',
                            errorText: toAddressError,
                            suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ContactsScreen(
                                        chainType: chainType,
                                        currentWalletAddress:
                                            fromController.text,
                                        wallets: chainType == ChainType.Stellar
                                            ? widget.allWallets
                                                .where((w) =>
                                                    double.parse(
                                                        w.stellarBalance) >=
                                                    0)
                                                .toList()
                                            : widget.allWallets,
                                        onSelectToAddress: _selectToAddress),
                                  ));
                                },
                                icon: const Icon(Icons.person)))),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: TextField(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        focusNode: textFieldFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        controller: amountController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            labelText:
                                'Amount (Balance: ${formatAmount(balance)})',
                            hintText: '100',
                            suffixText: 'TFT',
                            errorText: amountError)),
                    subtitle: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Max Fee: $fee TFT')),
                  ),
                  const SizedBox(height: 10),
                  if (isBiggerThanFee)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: percentages
                            .map(
                              (percentage) => OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)))),
                                onPressed: () => calculateAmount(percentage),
                                child: Text('$percentage%'),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  if (chainType == ChainType.Stellar)
                    ListTile(
                      title: TextField(
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          controller: memoController,
                          decoration: const InputDecoration(
                            labelText: 'Memo',
                          )),
                    ),
                  const SizedBox(height: 40),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await _validate()) {
                          await _send_confirmation();
                        }
                      },
                      style: ElevatedButton.styleFrom(),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Transfer',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        }));
  }

  scanQrCode() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    // QRCode scanner is black if we don't sleep here.
    bool slept =
        await Future.delayed(const Duration(milliseconds: 400), () => true);
    late Barcode result;
    if (slept) {
      if (context.mounted) {
        result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ScanScreen()));
      }
    }
    if (result.code != null) {
      final code = Uri.parse(result.code!);
      toController.text = code.path;
      if (code.queryParameters.containsKey('amount')) {
        amountController.text = code.queryParameters['amount']!;
      }
      if (chainType == ChainType.Stellar &&
          code.queryParameters.containsKey('message')) {
        memoController.text = code.queryParameters['message']!;
      }
      setState(() {});
    }

    return result.code;
  }

  calculateAmount(int percentage) {
    final amount = (Decimal.parse(chainType == ChainType.TFChain
                ? widget.wallet.tfchainBalance
                : widget.wallet.stellarBalance) -
            fee) *
        (Decimal.fromInt(percentage).shift(-2));
    amountController.text = roundAmount(amount.toString()).toString();
  }

  _send_confirmation() async {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => SendConfirmationWidget(
              chainType: chainType,
              secret: chainType == ChainType.Stellar
                  ? widget.wallet.stellarSecret
                  : widget.wallet.tfchainSecret,
              from: fromController.text.trim(),
              to: toController.text.trim(),
              amount: amountController.text.trim(),
              memo: memoController.text.trim(),
              reloadBalance: chainType == ChainType.Stellar
                  ? _loadStellarBalance
                  : _loadTFChainBalance,
            ));
  }
}
