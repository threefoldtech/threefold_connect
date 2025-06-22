import 'package:mutex/mutex.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';

import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]) {
    list();
  }

  bool _reload = true;
  bool _loading = true;
  bool _isListed = false;
  bool _preloading = false;
  final Mutex _mutex = Mutex();
  final Map<String, DateTime> _balanceCache = {};
  final Duration _cacheTimeout = const Duration(minutes: 2);

  bool get isListed => _isListed;
  bool get isPreloading => _preloading;

  Future<void> list() async {
    if (_isListed) return;
    _loading = true;
    await _mutex.protect(() async {
      state = await listWallets();
    });
    _loading = false;
    _isListed = true;
  }

  Future<void> refresh() async {
    _loading = true;
    _isListed = false;
    _balanceCache.clear();

    await _mutex.protect(() async {
      state = await listWallets();
    });
    _loading = false;
    _isListed = true;
  }

  /// Preload wallet data in background for faster page transitions
  Future<void> preloadWalletData() async {
    if (_preloading || _isListed) return;
    _preloading = true;

    try {
      final wallets = await listWallets();
      if (wallets.isNotEmpty && !_isListed) {
        await _mutex.protect(() async {
          state = wallets;
          _isListed = true;
        });

        _preloadBalancesInBackground();
      }
    } catch (e) {
      logger.e('Failed to preload wallet data: $e');
    } finally {
      _preloading = false;
    }
  }

  /// Load balances in background without blocking UI
  void _preloadBalancesInBackground() async {
    if (state.isEmpty) return;

    final chainUrl = Globals().chainUrl;
    final futures = state.map((wallet) async {
      final cacheKey = '${wallet.name}_balance';
      final now = DateTime.now();

      // Check cache first
      if (_balanceCache.containsKey(cacheKey)) {
        final cacheTime = _balanceCache[cacheKey]!;
        if (now.difference(cacheTime) < _cacheTimeout) {
          return;
        }
      }

      try {
        final results = await Future.wait([
          TFChainService.getBalance(chainUrl, wallet.tfchainAddress),
          StellarService.getTFTBalance(wallet.stellarSecret),
        ]);

        final tfchainBalance = results[0].toString() == '0.0' ? '0' : results[0].toString();
        final stellarBalance = results[1].toString();

        // Update cache
        _balanceCache[cacheKey] = now;
        // Update wallet if values changed
        if (tfchainBalance != wallet.tfchainBalance ||
            stellarBalance != wallet.stellarBalances['TFT']) {
          wallet.stellarBalances['TFT'] = stellarBalance;
          wallet.tfchainBalance = tfchainBalance;
        }
      } catch (e) {
        logger.e('Failed to preload balance for ${wallet.name}: $e');
      }
    }).toList();

    await Future.wait(futures);

    // Update state once after all balances are loaded
    if (mounted) {
      await _mutex.protect(() async {
        state = [...state];
      });
    }
  }

  Future<void> waitUntilListed() async {
    if (_isListed) return;

    await for (final _
        in stream.where((wallets) => wallets.isNotEmpty && _isListed == true)) {
      break;
    }
  }

  Future<void> removeWallet(String name) async {
    await _mutex.protect(() async {
      state = state.where((wallet) => wallet.name != name).toList();
    });
  }

  Future<void> addWallet(Wallet wallet) async {
    await _mutex.protect(() async {
      state = [...state, wallet];
    });
  }

  Future<void> editWallet(String oldName, String newName) async {
    await _mutex.protect(() async {
      final wallet = state.where((w) => w.name == oldName).firstOrNull;
      if (wallet != null) {
        wallet.name = newName;
      }
      state = [...state];
    });
  }

  Future<void> verifyWallet(String walletName) async {
    final idenfyServiceUrl = Globals().idenfyServiceUrl;
    await _mutex.protect(() async {
      final wallet = state.where((w) => w.name == walletName).firstOrNull;
      if (wallet != null) {
        try {
          final updatedVerificationStatus = await getVerificationStatus(
            address: wallet.tfchainAddress,
            idenfyServiceUrl: idenfyServiceUrl,
          );
          wallet.verificationStatus = updatedVerificationStatus.status;
          state = [...state];
        } catch (e) {
          logger.e('[verifyWallet] Error during verification: $e');
        }
      }
    });
  }

  void reloadBalances() async {
    if (!_reload) return;
    if (!_loading) {
      final chainUrl = Globals().chainUrl;
      final now = DateTime.now();

      await _mutex.protect(() async {
        final List<Wallet> currentState = state.where((w) => true).toList();

        // Use parallel loading for better performance
        final futures = currentState.map((wallet) async {
          final cacheKey = '${wallet.name}_balance';

          // Check cache first to avoid unnecessary API calls
          if (_balanceCache.containsKey(cacheKey)) {
            final cacheTime = _balanceCache[cacheKey]!;
            if (now.difference(cacheTime) < _cacheTimeout) {
              return; // Skip if recently cached
            }
          }

          try {
            // Load both balances in parallel
            final results = await Future.wait([
              TFChainService.getBalance(chainUrl, wallet.tfchainAddress),
              StellarService.getTFTBalance(wallet.stellarSecret),
            ]);

            final tfchainBalance = results[0].toString() == '0.0' ? '0' : results[0].toString();
            final stellarBalance = results[1].toString();

            // Update cache
            _balanceCache[cacheKey] = now;

            if (tfchainBalance != wallet.tfchainBalance ||
                stellarBalance != wallet.stellarBalances['TFT']) {
              wallet.stellarBalances['TFT'] = stellarBalance;
              wallet.tfchainBalance = tfchainBalance;
            }
          } catch (e) {
            logger.e('Failed to reload balance for ${wallet.name}: $e');
          }
        }).toList();

        await Future.wait(futures);

        if (mounted) {
          state = currentState;
        }
      });
    }
    final refreshBalance = Globals().refreshBalance;
    await Future.delayed(Duration(seconds: refreshBalance));
    if (mounted) reloadBalances();
  }

  void stopReloadingBalance() {
    _reload = false;
  }

  void startReloadingBalance() {
    _reload = true;
  }

  void clear() {
    _isListed = false;
  }

  Wallet? getUpdatedWallet(String name) {
    return state.where((w) => w.name == name).firstOrNull;
  }
}

final walletsNotifier = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
    (ref) => WalletsNotifier());
