import 'package:bs58/bs58.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/wallets/contacts.dart';
import 'package:threebotlogin/services/stellar_service.dart';
import 'package:threebotlogin/widgets/wallets/bridge_confirmation.dart';
import 'package:threebotlogin/widgets/wallets/swap_transaction_widget.dart';
import 'package:validators/validators.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChain;

class WalletBridgeScreen extends ConsumerStatefulWidget {
  const WalletBridgeScreen({super.key, required this.wallet});
  final Wallet wallet;

  @override
  ConsumerState<WalletBridgeScreen> createState() => _WalletBridgeScreenState();
}

class _WalletBridgeScreenState extends ConsumerState<WalletBridgeScreen> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final amountController = TextEditingController();
  BridgeOperation transactionType = BridgeOperation.Withdraw;
  bool isWithdraw = true;
  Decimal transferFee = Decimal.parse('0.01');
  static Decimal BRIDGE_FEE = Decimal.parse('1.0');
  late Decimal totalFee;
  late Decimal totalAmount;
  String? toAddressError;
  String? amountError;
  bool reloadBalance = true;
  List percentages = [25, 50, 75, 100];
  bool isSolana = false;

  @override
  void initState() {
    fromController.text = widget.wallet.tfchainAddress;
    totalFee = transferFee + BRIDGE_FEE;
    _reloadBalances();
    super.initState();
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    amountController.dispose();
    reloadBalance = false;
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

  onTransactionChange(BridgeOperation type) {
    transactionType = type;
    isWithdraw = transactionType == BridgeOperation.Withdraw ? true : false;
    fromController.text = isWithdraw
        ? widget.wallet.tfchainAddress
        : widget.wallet.stellarAddress;
    toController.text = '';
    toAddressError = null;
    amountError = null;
    setState(() {
      if (isWithdraw) {
        transferFee = Decimal.parse('0.01');
        BRIDGE_FEE = Decimal.parse('1.0');
      } else if (isSolana) {
        transferFee = Decimal.parse('100.0');
        BRIDGE_FEE = Decimal.parse('0.0');
      } else {
        transferFee = Decimal.parse('0.1');
        BRIDGE_FEE = Decimal.parse('1.0');
      }
      totalFee = transferFee + BRIDGE_FEE;
    });
  }

  Future<bool> _validateToAddress() async {
    final toAddress = toController.text.trim();
    toAddressError = null;
    if (toAddress.isEmpty) {
      toAddressError = "Address can't be empty";
      return false;
    }

    if (!isWithdraw) {
      if (isSolana) {
        final isValidSolana = isValidSolanaAddress(toAddress);
        if (!isValidSolana) {
          toAddressError = 'Invaild Solana address';
        }
        return isValidSolana;
      }
      if (toAddress.length != 48) {
        toAddressError = 'Address length should be 48 characters';
        return false;
      }
      final twinId = await TFChain.getTwinIdByQueryClient(toAddress);
      if (twinId == 0) {
        toAddressError = 'Address must have a twin ID';
        return false;
      }

      if (isWithdraw) {
        if (!isValidStellarAddress(toAddress)) {
          toAddressError = 'Invaild Stellar address';
          return false;
        }
        if (toAddress == Globals().bridgeTFTAddress) {
          toAddressError = "Bridge address can't be the destination";
          return false;
        }
        final toAddrBalance = await Stellar.getBalanceByAccountId(toAddress);
        if (toAddrBalance == '-1') {
          toAddressError = 'Address must be active and have TFT trustline';
          return false;
        }
      }
    }
    return true;
  }

  bool isValidSolanaAddress(String address) {
    final decodeBytes = base58.decode(address);
    return decodeBytes.length == 32;
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
    if (Decimal.parse(amount) < Decimal.fromInt(2)) {
      amountError = "Amount can't be less than 2 excluding fees.";
      return false;
    }
    final balance = roundAmount(isWithdraw
        ? widget.wallet.tfchainBalance
        : widget.wallet.stellarBalance);
    if (balance - Decimal.parse(amount) - totalFee < Decimal.zero) {
      amountError = 'Insufficient balance (fees included).';
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

  updateIsSolana(bool value) {
    setState(() {
      isSolana = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Wallet> wallets = ref.read(walletsNotifier);
    final bool disableDeposit = widget.wallet.stellarBalance == '-1';
    if (disableDeposit && !isWithdraw) {
      onTransactionChange(BridgeOperation.Withdraw);
    }

    String balance = isWithdraw
        ? widget.wallet.tfchainBalance
        : widget.wallet.stellarBalance;
    final isBiggerThanFee = roundAmount(balance) > totalFee;

    return Scaffold(
        appBar: AppBar(title: const Text('Bridge')),
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
                    const SizedBox(height: 10),
                    SwapTransactionWidget(
                        bridgeOperation: transactionType,
                        onTransactionChange: onTransactionChange,
                        disableDeposit: disableDeposit,
                        updateIsSolana: updateIsSolana),
                    const SizedBox(height: 20),
                    ListTile(
                      title: TextField(
                          readOnly: true,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          controller: toController,
                          decoration: InputDecoration(
                              labelText: 'To',
                              errorText: toAddressError,
                              suffixIcon: !isSolana
                                  ? IconButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => ContactsScreen(
                                              chainType: isWithdraw
                                                  ? ChainType.Stellar
                                                  : ChainType.TFChain,
                                              currentWalletAddress:
                                                  fromController.text,
                                              wallets: isWithdraw
                                                  ? wallets
                                                      .where((w) =>
                                                          double.parse(w
                                                              .stellarBalance) >=
                                                          0)
                                                      .toList()
                                                  : wallets,
                                              onSelectToAddress:
                                                  _selectToAddress),
                                        ));
                                      },
                                      icon: const Icon(Icons.person))
                                  : null)),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                        title: TextField(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: amountController,
                            decoration: InputDecoration(
                                labelText:
                                    'Amount (Balance: ${formatAmount(balance)})',
                                hintText: '100',
                                suffixText: 'TFT',
                                errorText: amountError)),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Transfer Fee: $totalFee TFT'),
                        )),
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
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (await _validate()) {
                            await _bridge_confirmation();
                          }
                        },
                        style: ElevatedButton.styleFrom(),
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            'Submit',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ));
        }));
  }

  calculateAmount(int percentage) {
    final amount = (Decimal.parse(isWithdraw
                ? widget.wallet.tfchainBalance
                : widget.wallet.stellarBalance) -
            totalFee) *
        (Decimal.fromInt(percentage).shift(-2));
    amountController.text = roundAmount(amount.toString()).toString();
  }

  _bridge_confirmation() async {
    totalAmount = Decimal.parse(amountController.text.trim()) + BRIDGE_FEE;
    final memoHash = isSolana ? base58.decode(toController.text.trim()) : null;
    final memoText = !isWithdraw && !isSolana
        ? await TFChain.getMemo(toController.text.trim())
        : null;
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => BridgeConfirmationWidget(
              bridgeOperation: transactionType,
              secret: isWithdraw
                  ? widget.wallet.tfchainSecret
                  : widget.wallet.stellarSecret,
              from: fromController.text.trim(),
              to: toController.text.trim(),
              amount: amountController.text.trim(),
              isSolana: isSolana,
              // amount + fee
              totalAmount: totalAmount.toString(),
              totalFee: totalFee.toString(),
              memo: memoText,
              memoHash: memoHash,
              reloadBalance:
                  isWithdraw ? _loadTFChainBalance : _loadStellarBalance,
            ));
  }
}
