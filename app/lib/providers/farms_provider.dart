import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mutex/mutex.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;
import 'package:registrar_client/registrar_client.dart' as registrar;
import 'package:registrar_client/models/farm.dart' as registrarFarm;
import 'package:registrar_client/models/node.dart' as registrarNode;

class FarmsNotifier extends StateNotifier<List<Farm>> {
  FarmsNotifier() : super([]);

  bool _loading = true;
  bool _isListed = false;
  bool _preloading = false;
  final Mutex _mutex = Mutex();
  final Map<String, DateTime> _farmCache = {};
  final Duration _cacheTimeout = const Duration(minutes: 5);

  List<Farm> _v3Farms = [];
  List<Farm> _v4Farms = [];
  bool _reload = false;

  bool get isLoading => _loading;
  bool get isListed => _isListed;
  bool get isPreloading => _preloading;

  Future<void> list(List<Wallet> wallets) async {
    if (_isListed && state.isNotEmpty) return;
    _loading = true;
    try {
      await _mutex.protect(() async {
        final farms = await _listFarms(wallets);
        state = farms;
        _isListed = true;
      });
    } catch (e) {
      logger.e('Failed to load farms: $e');
      if (state.isEmpty) {
        rethrow;
      }
    } finally {
      _loading = false;
    }
  }

  Future<void> refresh(List<Wallet> wallets) async {
    _loading = true;
    _isListed = false;
    _farmCache.clear();

    await _mutex.protect(() async {
      state = await _listFarms(wallets);
    });
    _loading = false;
    _isListed = true;
  }

  /// Preload farm data in background for faster page transitions
  Future<void> preloadFarmData(List<Wallet> wallets) async {
    if (_preloading || _isListed) return;
    _preloading = true;

    try {
      logger.i('Preloading farm data in background...');
      
      // Load farms without blocking UI
      final farms = await _listFarms(wallets);
      if (farms.isNotEmpty && !_isListed) {
        await _mutex.protect(() async {
          state = farms;
          _isListed = true;
        });
      }
      logger.i('Farm data preloaded successfully');
    } catch (e) {
      logger.e('Failed to preload farm data: $e');
    } finally {
      _preloading = false;
    }
  }

  /// Internal method to load farms from wallets
  Future<List<Farm>> _listFarms(List<Wallet> wallets) async {
    if (wallets.isEmpty) return [];

    final now = DateTime.now();
    final cacheKey = 'farms_${wallets.map((w) => w.name).join('_')}';
    
    // Check cache first - if we have cached data and it's still valid, return it
    if (_farmCache.containsKey(cacheKey) && state.isNotEmpty) {
      final cacheTime = _farmCache[cacheKey]!;
      if (now.difference(cacheTime) < _cacheTimeout) {
        logger.i('Using cached farm data');
        return state;
      }
    }
    final twinIdFutures = wallets.map((wallet) async {
      try {
        final twinId = await TFChainService.getTwinId(wallet.tfchainSecret);
        return twinId != 0 ? MapEntry(twinId, wallet) : null;
      } catch (e) {
        logger.e('Failed to get twin ID for ${wallet.name}: $e');
        return null;
      }
    }).toList();

    final twinIdResults = await Future.wait(twinIdFutures);
    final Map<int, Wallet> twinIdWallets = {};
    
    for (final result in twinIdResults) {
      if (result != null) {
        twinIdWallets[result.key] = result.value;
      }
    }

    if (twinIdWallets.isEmpty) {
      return [];
    }

    try {
      final v3FarmsFuture = _loadV3Farms(twinIdWallets);
      final v4FarmsFuture = _loadV4Farms(twinIdWallets);

      final results = await Future.wait([v3FarmsFuture, v4FarmsFuture]);
      final v3Farms = results[0];
      final v4Farms = results[1];

      _v3Farms = v3Farms;
      _v4Farms = v4Farms;

      final allFarms = <Farm>[...v3Farms, ...v4Farms];

      _farmCache[cacheKey] = now;

      return allFarms;
    } catch (e) {
      logger.e('Failed to load farms from network: $e');

      if (state.isNotEmpty) {
        logger.i('Returning cached farm data due to network error');
        return state;
      }

      rethrow;
    }
  }

  Future<List<Farm>> _loadV3Farms(Map<int, Wallet> twinIdWallets) async {
    try {
      final farmsList = await getFarmsByTwinIds(twinIdWallets.keys.toList());
      
      final farmFutures = farmsList.map((farm) async {
        try {
          final nodes = await getNodesByFarmId(farm.farmID);
          final wallet = twinIdWallets[farm.twinId]!;
          
          return Farm(
            name: farm.name,
            walletAddress: farm.stellarAddress,
            tfchainWalletSecret: wallet.tfchainSecret,
            walletName: wallet.name,
            twinId: farm.twinId,
            farmId: farm.farmID,
            nodes: nodes.map((node) => Node(
              nodeId: node.nodeId,
              status: NodeStatus.values.firstWhere(
                (e) => e.toString().toLowerCase() == 'nodestatus.${node.status}',
              ),
              country: node.location!.country,
              uptime: node.uptime,
            )).toList(),
          );
        } catch (e) {
          logger.e('Failed to load V3 farm ${farm.name}: $e');
          return null;
        }
      }).toList();

      final results = await Future.wait(farmFutures);
      return results.where((farm) => farm != null).cast<Farm>().toList();
    } catch (e) {
      logger.e('Failed to load V3 farms: $e');
      return [];
    }
  }

  Future<List<Farm>> _loadV4Farms(Map<int, Wallet> twinIdWallets) async {
    try {
      final List<Farm> allV4Farms = [];

      for (final entry in twinIdWallets.entries) {
        final wallet = entry.value;

        try {
          final registrarClient = registrar.RegistrarClient(
            baseUrl: Globals().registrarURL,
            mnemonicOrSeed: wallet.tfchainSecret,
          );

          final publicKey = await derivePublicKey(wallet.tfchainSecret);
          final account = await registrarClient.accounts.getByPublicKey(publicKey);
          final v4Farms = await registrarClient.farms.list(
            registrarFarm.FarmFilter(twinID: account.twinID),
          );
          for (final v4Farm in v4Farms) {
            try {
              final farmNodes = await registrarClient.nodes.list(
                registrarNode.NodeFilter(farmID: v4Farm.farmID),
              );

              final nodes = farmNodes.map((n) {
                return Node(
                  nodeId: n.nodeID,
                  status: n.online ? NodeStatus.Up : NodeStatus.Down,
                  country: n.location.country,
                  uptime: (n.uptime.isNotEmpty) ? n.uptime.last.duration : 0,
                );
              }).toList();

              final farm = Farm(
                name: 'Farm ${v4Farm.farmID}',
                walletAddress: wallet.stellarAddress,
                tfchainWalletSecret: wallet.tfchainSecret,
                walletName: wallet.name,
                twinId: v4Farm.twinID,
                farmId: v4Farm.farmID!,
                nodes: nodes,
              );

              allV4Farms.add(farm);
            } catch (e) {
              logger.e('Failed to load V4 farm ${v4Farm.farmID}: $e');
              continue;
            }
          }
        } catch (e) {
          logger.e('Failed to load V4 farms for wallet ${wallet.name}: $e');
          continue;
        }
      }

      return allV4Farms;
    } catch (e) {
      logger.e('Failed to load V4 farms: $e');
      return [];
    }
  }

  /// Wait until farms are listed (similar to wallets)
  Future<void> waitUntilListed() async {
    if (_isListed) return;

    await for (final _ in stream.where((farms) => farms.isNotEmpty && _isListed == true)) {
      break;
    }
  }

  /// Add a new farm to the list
  Future<void> addFarm(Farm farm) async {
    await _mutex.protect(() async {
      state = [...state, farm];
    });
  }

  /// Remove a farm from the list
  Future<void> removeFarm(int farmId) async {
    await _mutex.protect(() async {
      state = state.where((farm) => farm.farmId != farmId).toList();
    });
  }

  /// Clear all farms and reset state
  void clear() {
    _isListed = false;
    _farmCache.clear();
    _v3Farms.clear();
    _v4Farms.clear();
    state = [];
  }

  /// Get farms by type (V3 vs V4)
  List<Farm> get v3Farms => _v3Farms;
  List<Farm> get v4Farms => _v4Farms;

  void startReloadingFarms() {
    _reload = true;
  }

  void stopReloadingFarms() {
    _reload = false;
  }

  void reloadFarms() async {
    if (!_reload) return;
    if (!_loading && _isListed) {
      try {
        final wallets = <Wallet>[];
        if (state.isNotEmpty) {
          await refresh(wallets);
        }
      } catch (e) {
        logger.e('Failed to reload farms: $e');
      }
    }

    final refreshInterval = 30;
    await Future.delayed(Duration(seconds: refreshInterval));
    if (mounted) reloadFarms();
  }

  Farm? getFarm(int farmId) {
    return state.where((farm) => farm.farmId == farmId).firstOrNull;
  }
}

final farmsNotifier = StateNotifierProvider<FarmsNotifier, List<Farm>>(
  (ref) => FarmsNotifier(),
);
