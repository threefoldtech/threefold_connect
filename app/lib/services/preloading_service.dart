import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/providers/farms_provider.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';

/// Service to preload data in background for faster page transitions
class PreloadingService {
  static final PreloadingService _instance = PreloadingService._internal();
  factory PreloadingService() => _instance;
  PreloadingService._internal();

  bool _isPreloading = false;
  bool _hasPreloaded = false;

  bool get isPreloading => _isPreloading;
  bool get hasPreloaded => _hasPreloaded;

  /// Start preloading wallet and farm data in background
  Future<void> startPreloading(WidgetRef ref) async {
    if (_isPreloading || _hasPreloaded) return;

    _isPreloading = true;
    logger.i('Starting background data preloading...');

    try {
      final walletsNotifierInstance = ref.read(walletsNotifier.notifier);
      await walletsNotifierInstance.preloadWalletData();

      final wallets = ref.read(walletsNotifier);
      if (wallets.isNotEmpty) {
        final farmsNotifierInstance = ref.read(farmsNotifier.notifier);
        await farmsNotifierInstance.preloadFarmData(wallets);
      }

      _hasPreloaded = true;
      logger.i('Background data preloading completed successfully');
    } catch (e) {
      logger.e('Failed to preload data: $e');
    } finally {
      _isPreloading = false;
    }
  }

  Future<void> preloadWallets(WidgetRef ref) async {
    try {
      final walletsNotifierInstance = ref.read(walletsNotifier.notifier);
      await walletsNotifierInstance.preloadWalletData();
    } catch (e) {
      logger.e('Failed to preload wallets: $e');
    }
  }

  Future<void> preloadFarms(WidgetRef ref) async {
    try {
      final wallets = ref.read(walletsNotifier);
      if (wallets.isNotEmpty) {
        final farmsNotifierInstance = ref.read(farmsNotifier.notifier);
        await farmsNotifierInstance.preloadFarmData(wallets);
      }
    } catch (e) {
      logger.e('Failed to preload farms: $e');
    }
  }

  void reset() {
    _hasPreloaded = false;
    _isPreloading = false;
  }

  bool shouldPreload() {
    return !_hasPreloaded && !_isPreloading;
  }
}

final preloadingServiceProvider = Provider<PreloadingService>((ref) {
  return PreloadingService();
});
