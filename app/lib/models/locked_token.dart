class LockedToken {
  LockedToken({
    required this.address,
    required this.assetCode,
    required this.assetIssuer,
    required this.amount,
    required this.unlockHash,
    required this.unlockFrom,
    required this.canBeUnlocked,
  });

  /// The escrow (locked) Stellar account that holds the tokens.
  final String address;

  /// The asset code of the locked balance (e.g. `TFT`).
  final String assetCode;

  /// The issuer of the locked asset.
  final String assetIssuer;

  /// The locked amount.
  final double amount;

  /// The `preauth_tx` signer of the escrow account. `null` when the account can
  /// be unlocked immediately (no time-lock left).
  String? unlockHash;

  /// Unix timestamp (seconds) from which the tokens can be unlocked. `null` when
  /// there is no time-lock.
  final int? unlockFrom;

  /// Whether the tokens can currently be unlocked.
  bool canBeUnlocked;

  DateTime? get unlockFromDate => unlockFrom == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(unlockFrom! * 1000);
}
