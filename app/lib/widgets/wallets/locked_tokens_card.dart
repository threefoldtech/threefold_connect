import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/locked_token.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/locked_tokens_service.dart'
    as LockedTokens;
import 'package:threebotlogin/widgets/custom_dialog.dart';

class LockedTokensCard extends StatefulWidget {
  const LockedTokensCard({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<LockedTokensCard> createState() => _LockedTokensCardState();
}

class _LockedTokensCardState extends State<LockedTokensCard> {
  List<LockedToken> _lockedTokens = [];
  bool _loading = true;
  bool _unlocking = false;

  @override
  void initState() {
    super.initState();
    _loadLockedTokens();
  }

  Future<void> _loadLockedTokens() async {
    try {
      final tokens =
          await LockedTokens.getLockedTokens(widget.wallet.stellarAddress);
      if (!mounted) return;
      setState(() {
        _lockedTokens = tokens;
        _loading = false;
      });
    } catch (e) {
      logger.e('[LockedTokens] Failed to load locked tokens: $e');
      if (!mounted) return;
      setState(() {
        _lockedTokens = [];
        _loading = false;
      });
    }
  }

  double get _totalLocked =>
      _lockedTokens.fold(0, (sum, t) => sum + t.amount);

  bool get _hasUnlockable => _lockedTokens.any((t) => t.canBeUnlocked);

  Future<void> _unlock() async {
    setState(() => _unlocking = true);
    final unlockable =
        _lockedTokens.where((t) => t.canBeUnlocked).toList();
    try {
      final results = await LockedTokens.unlockTokens(
          unlockable, widget.wallet.stellarSecret);
      if (!mounted) return;

      final unlockedCount = results
          .where((r) => r.outcome == LockedTokens.UnlockOutcome.unlocked)
          .length;
      final transferFailed = results.any((r) =>
          r.outcome == LockedTokens.UnlockOutcome.unlockedButTransferFailed);
      final failed = results
          .any((r) => r.outcome == LockedTokens.UnlockOutcome.failed);

      if (transferFailed) {
        // The escrow was unlocked on-chain but the funds were not transferred;
        // a retry will claim them, so steer the user to try again rather than
        // reporting an outright failure.
        _showDialog(
          DialogType.Warning,
          'Almost there',
          'Your tokens were unlocked but could not be transferred to your '
              'wallet yet. Please try again to claim them.',
        );
      } else if (unlockedCount > 0) {
        _showDialog(
          DialogType.Info,
          'Tokens unlocked',
          'Your tokens have been unlocked and transferred to your wallet. '
              'Your balance will update shortly.',
        );
      } else if (failed) {
        _showDialog(
          DialogType.Error,
          'Failed to unlock',
          'Something went wrong while unlocking your tokens. Please try again.',
        );
      } else {
        _showDialog(
          DialogType.Warning,
          'Nothing unlocked',
          'The tokens could not be unlocked yet. Please try again later.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog(
        DialogType.Error,
        'Failed to unlock',
        'Something went wrong while unlocking your tokens. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _unlocking = false);
      await _loadLockedTokens();
    }
  }

  void _showDialog(DialogType type, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: type,
        image: type == DialogType.Error
            ? Icons.error
            : type == DialogType.Warning
                ? Icons.warning
                : Icons.check_circle,
        title: title,
        description: description,
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Render nothing until tokens are loaded, and stay hidden for the common
    // "no locked tokens" case. This avoids flashing the Divider + 'Locked'
    // header + spinner on every wallet open before collapsing again.
    if (_loading || _lockedTokens.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        Text(
          'Locked',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(5),
            ),
            leading: Icon(
              Icons.lock_clock,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Locked TFT',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            trailing: Text(
              '${formatAmount(_totalLocked.toString())} TFT',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              onPressed: (_hasUnlockable && !_unlocking) ? _unlock : null,
              child: _unlocking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _hasUnlockable
                          ? 'Unlock tokens'
                          : 'Tokens are still locked',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
            ),
          ),
      ],
    );
  }
}
