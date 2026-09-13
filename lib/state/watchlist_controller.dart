import 'package:flutter/foundation.dart';
import '../data/remote/stock_api_client.dart';
import '../domain/models/domestic_stock.dart';
import '../domain/models/sort_option.dart';
import 'favorite_controller.dart';

class WatchlistController extends ChangeNotifier {
  final StockApiClient _api;
  final FavoriteController _favoriteController;

  WatchlistController(this._api, this._favoriteController) {
    _favoriteController.addListener(_onFavoritesChanged);
    Future.microtask(() => syncWithFavorites(_favoriteController.favoriteIds));
  }

  void _onFavoritesChanged() {
    syncWithFavorites(_favoriteController.favoriteIds);
  }

  @override
  void dispose() {
    _favoriteController.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  final Map<String, DomesticStock> _stocksById = {};
  SortOption _sortOption = SortOption.nameAsc;
  bool _isLoading = false;

  bool _refreshInFlight = false;
  bool _refreshQueued = false;

  bool get isLoading => _isLoading;
  SortOption get sortOption => _sortOption;
  bool get isEmpty => _stocksById.isEmpty;

  List<DomesticStock> get sortedStocks {
    final list = _stocksById.values.toList();

    final withQuote = list.where((s) => s.hasQuote).toList();
    final withoutQuote = list.where((s) => !s.hasQuote).toList();

    withQuote.sort((a, b) {
      switch (_sortOption) {
        case SortOption.priceDesc:
          return (b.currentPrice ?? 0).compareTo(a.currentPrice ?? 0);
        case SortOption.changeRateDesc:
          return (b.changeRate ?? 0).compareTo(a.changeRate ?? 0);
        case SortOption.nameAsc:
          return a.name.compareTo(b.name);
      }
    });

    return [...withQuote, ...withoutQuote];
  }

  void changeSort(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  Future<void> syncWithFavorites(List<String> canonicalIds) async {
    print('>>> syncWithFavorites called with: $canonicalIds');
    final newIds = canonicalIds.toSet();

    _stocksById.removeWhere((id, _) => !newIds.contains(id));

    for (final id in canonicalIds) {
      if (!_stocksById.containsKey(id)) {
        final symbol = id.replaceFirst('domestic:', '');
        _stocksById[id] = DomesticStock(
          canonicalId: id,
          symbol: symbol,
          name: symbol,
          market: '',
        );
      }
    }
    notifyListeners();

    await refresh();
  }

  Future<void> refresh() async {
    if (_refreshInFlight) {
      print('[watchlist] refresh already in flight, queueing');
      _refreshQueued = true;
      return;
    }
    _refreshInFlight = true;
    await _doRefresh();
    _refreshInFlight = false;

    if (_refreshQueued) {
      _refreshQueued = false;
      print('[watchlist] running queued refresh');
      await refresh();
    }
  }

  Future<void> _doRefresh() async {
    if (_stocksById.isEmpty) {
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final symbols = _stocksById.values.map((s) => s.symbol).toList();
      print('[watchlist] refresh start: $symbols');

      final metaResults = await Future.wait(
        symbols.map((s) async {
          try {
            final meta = await _api.fetchStockMeta(s);
            print('[watchlist] meta OK: $s -> ${meta?.stockName}');
            return meta;
          } catch (e) {
            print('[watchlist] meta FAIL: $s -> $e');
            return null;
          }
        }),
      );

      for (var i = 0; i < symbols.length; i++) {
        final meta = metaResults[i];
        if (meta == null) continue;
        final id = DomesticStock.canonicalIdOf(symbols[i]);
        final current = _stocksById[id];
        if (current == null) continue;
        _stocksById[id] = DomesticStock(
          canonicalId: current.canonicalId,
          symbol: current.symbol,
          name: meta.stockName,
          market: meta.stockExchangeNameKor,
          currentPrice: current.currentPrice,
          changeAmount: current.changeAmount,
          changeRate: current.changeRate,
          open: current.open,
          high: current.high,
          low: current.low,
          accumulatedVolume: current.accumulatedVolume,
          marketCap: current.marketCap,
        );
      }

      try {
        final quotes = await _api.fetchRealtimeQuotes(symbols);
        print('[watchlist] quotes OK: ${quotes.keys}');
        for (final entry in quotes.entries) {
          final id = DomesticStock.canonicalIdOf(entry.key);
          final current = _stocksById[id];
          if (current == null) continue;
          _stocksById[id] = current.withQuote(entry.value);
        }
      } catch (e) {
        print('[watchlist] quotes FAIL: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      print('[watchlist] refresh done');
    }
  }
}
